//
//  WalletConnect.swift
//  Adanac
//
//  Created by Daniel Bell on 6/19/22.
//

import Foundation
#if os(iOS)
import VisionKit
import UIKit
#endif
import AVFoundation
import WalletConnectSwift
import Combine
import web3swift

//Default implementation of WalletConnect SDK API
//personal_sign
//eth_sign
//eth_signTypedData
//eth_sendTransaction
//eth_signTransaction
//eth_sendRawTransaction

//Connecting via deep link ("wc" scheme)

//let controller = DataScannerViewController()

class WalletConnectServerManager: ObservableObject {
    private var server: Server? = nil
    @Published var session: Session? = nil
    private let sessionKey = "sessionKey"
    
    let moc = WalletDataController().container.viewContext

    @Published var sessions: [WCSession]?
    let fetchRequest = WCSession.fetchRequest()
    private var cancellables: [AnyCancellable] = []

    init(){
        self.server = Server(delegate: self)
        configureServer(privateKey: nil)
        Task {
            await fetchSessions()
        }
        $session.sink { newSession in
            guard let newSession = newSession else {
                return
            }
            Task {
                try? await self.save(newSession)
                await self.fetchSessions()
            }
        }
        .store(in: &cancellables)
    }

    var privateKey: AbstractKeystoreParams? = nil

    func set(privateKey: AbstractKeystoreParams) {
        self.privateKey = privateKey
        configureServer(privateKey: privateKey)
    }


    func disconnect() {
        guard let session = session else {
            return
        }
        
        try? server?.disconnect(from: session)
    }

    private func configureServer(privateKey: AbstractKeystoreParams?) {
        guard let key = privateKey ?? self.privateKey else {
            return
        }
        server?.register(handler: BaseHandler(server: server!, privateKey: key))
        server?.register(handler: PersonalSignHandler(server: server!, privateKey: key))
//        server.register(handler: SignTransactionHandler(for: self, server: server, privateKey: privateKey))
    }

    func save(_ session: Session) async throws {

        try await moc.perform {
            let walletInfo = session.walletInfo

            let walletInfoPeer = walletInfo?.peerMeta
            let peerMeta = WCClientMeta(context: self.moc)
            peerMeta.name = walletInfoPeer?.name
            peerMeta.desc = walletInfoPeer?.description
            peerMeta.url = walletInfoPeer?.url.absoluteString
            peerMeta.scheme = walletInfoPeer?.scheme
            if let iconSet = walletInfoPeer?.icons {
                peerMeta.iconArray = iconSet
            }

            let newWalletInfo = WCWalletInfo(context: self.moc)
            newWalletInfo.accountsArray = walletInfo?.accounts ?? []
            newWalletInfo.peerID = walletInfo?.peerId
            newWalletInfo.approved = walletInfo?.approved ?? false
            newWalletInfo.chainID = Int64(walletInfo?.chainId ?? 0)
            newWalletInfo.peerMeta = peerMeta

            let sessionURL = session.url

            let newSessionURL = WCSessionURL(context: self.moc)
            newSessionURL.topic = sessionURL.topic
            newSessionURL.version = sessionURL.version
            newSessionURL.bridgeURL = sessionURL.bridgeURL.absoluteString
            newSessionURL.key = sessionURL.key
            newSessionURL.absoluteString = sessionURL.absoluteString

            let dAppInfo = session.dAppInfo

            let dAppInfoPeer = dAppInfo.peerMeta
            let dAppInfoPeerMeta = WCClientMeta(context: self.moc)
            dAppInfoPeerMeta.name = dAppInfoPeer.name
            dAppInfoPeerMeta.desc = dAppInfoPeer.description
            dAppInfoPeerMeta.url = dAppInfoPeer.url.absoluteString
            dAppInfoPeerMeta.scheme = dAppInfoPeer.scheme
            dAppInfoPeerMeta.iconArray = dAppInfoPeer.icons

            let newDAppInfo = WCDAppInfo(context: self.moc)
            newDAppInfo.peerID = dAppInfo.peerId
            newDAppInfo.chainID = Int64(dAppInfo.chainId ?? -1)
            newDAppInfo.approved = dAppInfo.approved ?? false
            newDAppInfo.peerMeta = dAppInfoPeerMeta

            let newWCSession = WCSession(context: self.moc)
            newWCSession.walletInfo = newWalletInfo
            newWCSession.dAppInfo = newDAppInfo
            newWCSession.url = newSessionURL

            try self.moc.save()
        }
        // TODO: save seedPhrase to icloud
    }

    func fetchSessions() async {
        await moc.perform {
            do {
                //        fetchRequest.predicate
                //        fetchRequest.sortDescriptors
                let directKeystores = try self.fetchRequest.execute()
                DispatchQueue.main.async {
                    let badElements = directKeystores.filter { $0.dAppInfo?.peerMeta?.icons == nil && $0.dAppInfo?.peerMeta?.name == nil }
                    var storedSessions = directKeystores
                    for el in badElements {
                        if let index = storedSessions.firstIndex(of: el) {
                            storedSessions.remove(at: index)
                        }
                    }

                    self.sessions = storedSessions

                    guard !badElements.isEmpty else {
                        return
                    }

                    Task {
                        await self.moc.perform {

                            badElements.forEach { element in
                                guard let index = self.sessions?.firstIndex(where: { $0.dAppInfo?.peerID == element.dAppInfo?.peerID } ) else {
                                    return
                                }
                                guard let keyStore = self.sessions?[index] else {
                                    return
                                }
                                self.moc.delete(keyStore)
                            }

                            try? self.moc.save()
                        }

                        await self.fetchSessions()
                    }

                }
            } catch {
                print(error)
            }
        }
    }

    func deleteSessions(at offsets: IndexSet) {
        Task {
            await moc.perform {
                offsets.forEach { offset in
                    guard let keyStore = self.sessions?[offset] else {
                        return
                    }
                    self.moc.delete(keyStore)
                }

                try? self.moc.save()
            }

            await fetchSessions()
        }
    }

    func disconnect(session: WCSession) {

        guard let parsedSession = generateSession(from: session) else {
            return
        }

        try? server?.disconnect(from: parsedSession)
        Task {
            await moc.perform {
                self.moc.delete(session)

                try? self.moc.save()
            }

            await fetchSessions()
        }
    }

    func reconnect(session: WCSession) {

        guard let parsedSession = generateSession(from: session) else {
            return
        }

        try? server?.reconnect(to: parsedSession)
    }

    func generateSession(from session: WCSession) -> Session? {
        guard let wcURL = session.url, let bridgeURLValue = wcURL.bridgeURL, let bridgeURL = URL(string: bridgeURLValue), let wcDAppInfo = session.dAppInfo else {
            return nil
        }

        let url = WCURL(topic: wcURL.topic ?? "", version: wcURL.version ?? "0", bridgeURL: bridgeURL, key: wcURL.key ?? "")

        guard let dAppInfoPeerMetaURLValue = wcDAppInfo.peerMeta?.url, let dAppInfoPeerMetaURL = URL(string: dAppInfoPeerMetaURLValue) else {
            return nil
        }

        let dAppInfoPeerMeta = Session.ClientMeta(name: wcDAppInfo.peerMeta?.name ?? "", description: wcDAppInfo.peerMeta?.desc, icons: wcDAppInfo.peerMeta?.iconArray ?? [], url: dAppInfoPeerMetaURL, scheme: wcDAppInfo.peerMeta?.scheme)
        let dAppInfo = Session.DAppInfo(peerId: wcDAppInfo.peerID ?? "", peerMeta: dAppInfoPeerMeta, chainId: Int(wcDAppInfo.chainID), approved: wcDAppInfo.approved)

        var parsedSession = Session(url: url, dAppInfo: dAppInfo, walletInfo: nil)


        if let wcWalletInfo = session.walletInfo {

            guard let walletInfoPeerMetaURLValue = wcWalletInfo.peerMeta?.url, let walletInfoPeerMetaURL = URL(string: walletInfoPeerMetaURLValue) else {
                return nil
            }

            let walletInfoPeerMeta = Session.ClientMeta(name: wcWalletInfo.peerMeta?.name ?? "", description: wcWalletInfo.peerMeta?.desc, icons: wcWalletInfo.peerMeta?.iconArray ?? [], url: walletInfoPeerMetaURL, scheme: wcWalletInfo.peerMeta?.scheme)


            let walletInfo =  Session.WalletInfo(approved: wcWalletInfo.approved, accounts: wcWalletInfo.accountsArray, chainId: Int(wcWalletInfo.chainID), peerId: wcWalletInfo.peerID ?? "", peerMeta: walletInfoPeerMeta)

            parsedSession.walletInfo = walletInfo
        }

        return parsedSession
    }
}

extension WalletConnectServerManager: ServerDelegate {
    func server(_ server: Server, didFailToConnect url: WCURL) {
        //Alert user scan failed
    }

    func server(_ server: Server, shouldStart session: Session, completion: @escaping (Session.WalletInfo) -> Void) {
        let walletMeta = Session.ClientMeta(name: "Adanac Wallet",
                                            description: "Adanac makes exploring Crypto fun and accessible ",
                                            icons: [URL(string:"https://example.com/1.png")!, URL(string:"https://example.com/2.png")!],
                                            url: URL(string: "https://Adanac.eth")!)

        var accounts = [String]()

        if let keyStore = privateKey as? KeystoreParamsBIP32 {
            accounts = keyStore.pathAddressPairs.map { $0.address }
        } else if let keyStore = privateKey as? KeystoreParamsV3 {
            if let address = keyStore.address {
                accounts = [address]
            }
        }

        let walletInfo = Session.WalletInfo(approved: true,
                                            accounts: accounts,
                                            chainId: 4,
                                            peerId: UUID().uuidString,
                                            peerMeta: walletMeta)

//        let alert = UIAlertController(title: "Request to start a session", message: session.dAppInfo.peerMeta.name, preferredStyle: .alert)
//        let startAction = UIAlertAction(title: "Start", style: .default) { _ in completion(walletInfo) }
//        alert.addAction(startAction)
        completion(walletInfo)
    }

    func server(_ server: Server, didConnect session: Session) {
        if let currentSession = self.session, currentSession.url.key != session.url.key {
            print("App only supports 1 session atm, cleaning...")
            try? self.server?.disconnect(from: currentSession)
        }
        DispatchQueue.main.async {
            self.session = session
        }

        Task {
            do {
                try await save(session)
            } catch {
                print(error)
            }
        }

    }

    func server(_ server: Server, didDisconnect session: Session) {
        //remove session key from useage
        if self.session == session {
            DispatchQueue.main.async {
                self.session = nil
            }
        }



        Task {
            await moc.perform {
                guard let index = self.sessions?.firstIndex(where: { $0.dAppInfo?.peerID == session.dAppInfo.peerId } ) else {
                    return
                }
                guard let keyStore = self.sessions?[index] else {
                    return
                }
                self.moc.delete(keyStore)

                try? self.moc.save()
            }

            await fetchSessions()
        }
    }

    func server(_ server: Server, didUpdate session: Session) {
        // no-op
    }
}

extension WalletConnectServerManager {

    func didScan(_ code: String) {
        guard let url = WCURL(code) else { return }
        do {
            try self.server?.connect(to: url)
        } catch {
            return
        }
    }
}


//extension UIAlertController {
//    func withCloseButton(title: String = "Close", onClose: (() -> Void)? = nil ) -> UIAlertController {
//        addAction(UIAlertAction(title: title, style: .cancel) { _ in onClose?() } )
//        return self
//    }
//
//
//    static func showShouldSign(from controller: UIViewController, title: String, message: String, onSign: @escaping () -> Void, onCancel: @escaping () -> Void) {
//        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        let startAction = UIAlertAction(title: "Sign", style: .default) { _ in onSign() }
//        alert.addAction(startAction)
//        controller.present(alert.withCloseButton(title: "Reject", onClose: onCancel), animated: true)
//    }
//}


