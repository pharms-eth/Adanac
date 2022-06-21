//
//  WalletConnect.swift
//  Adanac
//
//  Created by Daniel Bell on 6/19/22.
//

import Foundation
import VisionKit
import UIKit
import AVFoundation
import WalletConnectSwift

//Create, reconnect, disconnect, and update session

//Default implementation of WalletConnect SDK API
//personal_sign
//eth_sign
//eth_signTypedData
//eth_sendTransaction
//eth_signTransaction
//eth_sendRawTransaction
//Wallet Example App:
//Connecting via QR code reader
//Connecting via deep link ("wc" scheme)
//Reconnecting after restart
//Examples of request handlers

//let controller = DataScannerViewController()

class WalletConnectServerManager: ObservableObject {
    var server: Server? = nil
    var session: Session? = nil
    let sessionKey = "sessionKey"
    init(){
        self.server = Server(delegate: self)
        configureServer()
    }

//        let privateKey: EthereumPrivateKey = try! EthereumPrivateKey(privateKey: .init(hex: "BD9F406A928238E9500E4C7276F77E6D15118D62CC6B65B5A39C442BE6F1262F"))


    func disconnect() {
        guard let session = session else {
            return
        }
        
        try? server?.disconnect(from: session)
    }

    private func configureServer() {
        server = Server(delegate: self)
//        server.register(handler: PersonalSignHandler(for: self, server: server, privateKey: privateKey))
//        server.register(handler: SignTransactionHandler(for: self, server: server, privateKey: privateKey))
//        if let oldSessionObject = UserDefaults.standard.object(forKey: sessionKey) as? Data,
//            let session = try? JSONDecoder().decode(Session.self, from: oldSessionObject) {
//            try? server?.reconnect(to: session)
//        }
    }
}

extension WalletConnectServerManager: ServerDelegate {
    func server(_ server: Server, didFailToConnect url: WCURL) {
        //RESET UI TO SCAN QR
        //Alert user scan failed
    }

    func server(_ server: Server, shouldStart session: Session, completion: @escaping (Session.WalletInfo) -> Void) {
        let walletMeta = Session.ClientMeta(name: "Test Wallet",
                                            description: nil,
                                            icons: [],
                                            url: URL(string: "https://safe.gnosis.io")!)
        let walletInfo = Session.WalletInfo(approved: true,
                                            accounts: ["0x00"],//[privateKey.address.hex(eip55: true)],
                                            chainId: 4,
                                            peerId: UUID().uuidString,
                                            peerMeta: walletMeta)

//        let onClose: (() -> Void) = {
//            completion(Session.WalletInfo(approved: false, accounts: [], chainId: 4, peerId: "", peerMeta: walletMeta))
//            //RESET UI TO SCAN QR
//        }

        let alert = UIAlertController(title: "Request to start a session", message: session.dAppInfo.peerMeta.name, preferredStyle: .alert)
        let startAction = UIAlertAction(title: "Start", style: .default) { _ in completion(walletInfo) }
        alert.addAction(startAction)
//        self.present(alert.withCloseButton(onClose: onClose), animated: true)
    }

    func server(_ server: Server, didConnect session: Session) {
        if let currentSession = self.session, currentSession.url.key != session.url.key {
            print("App only supports 1 session atm, cleaning...")
            try? self.server?.disconnect(from: currentSession)
        }
        self.session = session
//        let sessionData = try! JSONEncoder().encode(session)
//        cache set(sessionData, forKey: sessionKey)
        //UPDATE UI to show disconnect button, hide QR scan button
//            self.statusLabel.text = "Connected to \(session.dAppInfo.peerMeta.name)"
    }

    func server(_ server: Server, didDisconnect session: Session) {
        //remove session key from useage
        //RESET UI TO SCAN QR
        //Alert User session disconnected
    }

    func server(_ server: Server, didUpdate session: Session) {
        // no-op
    }
}

extension WalletConnectServerManager: ScannerViewControllerDelegate {
    func didFail(reason: ScanError) {
        //UPDateUI
    }

    func found(_ result: ScanResult) {
        didScan(result.string)
    }

    func reset() {
        //UPDATE UI
    }

    func didScan(_ code: String) {
        guard let url = WCURL(code) else { return }
//        scanQRCodeButton.isEnabled = false
//        scannerController?.dismiss(animated: true)
        do {
            try self.server?.connect(to: url)
        } catch {
            return
        }
    }
}






////You do this by registering request handlers. You have the flexibility to register one handler per request method, or a catch-all request handler.
//
//server.register(handler: PersonalSignHandler(for: self, server: server, wallet: wallet))
////Handlers are asked (in order of registration) whether they can handle each request. First handler that returns true from canHandle(request:) method will get the handle(request:) call. All other handlers will be skipped.
////
////In the request handler, check the incoming request's method in canHandle implementation, and handle actual request in the handle(request:) implementation.
//
//func canHandle(request: Request) -> Bool {
//   return request.method == "eth_signTransaction"
//}
////You can send back response for the request through the server using send method:
//
//func handle(request: Request) {
//  // do you stuff here ...
//
//  // error response - rejected by user
//  server.send(.reject(request))
//
//  // or send actual response - assuming the request.id exists, and MyCodableStruct type defined
//  try server.send(Response(url: request.url, value: MyCodableStruct(value: "Something"), id: request.id!))
//}
////For more details, see the ExampleApps/ServerApp




//class BaseHandler: RequestHandler {
//    weak var controller: UIViewController!
//    weak var sever: Server!
//    weak var privateKey: EthereumPrivateKey!
//
//    init(for controller: UIViewController, server: Server, privateKey: EthereumPrivateKey) {
//        self.controller = controller
//        self.sever = server
//        self.privateKey = privateKey
//    }
//
//    func canHandle(request: Request) -> Bool {
//        return false
//    }
//
//    func handle(request: Request) {
//        // to override
//    }
//
//    func askToSign(request: Request, message: String, sign: @escaping () -> String) {
//        let onSign = {
//            let signature = sign()
//            self.sever.send(.signature(signature, for: request))
//        }
//        let onCancel = {
//            self.sever.send(.reject(request))
//        }
//        DispatchQueue.main.async {
//            UIAlertController.showShouldSign(from: self.controller,
//                                             title: "Request to sign a message",
//                                             message: message,
//                                             onSign: onSign,
//                                             onCancel: onCancel)
//        }
//    }
//}

//class PersonalSignHandler: BaseHandler {
//    override func canHandle(request: Request) -> Bool {
//        return request.method == "personal_sign"
//    }
//
//    override func handle(request: Request) {
//        do {
//            let messageBytes = try request.parameter(of: String.self, at: 0)
//            let address = try request.parameter(of: String.self, at: 1)
//
//            guard address == privateKey.address.hex(eip55: true) else {
//                sever.send(.reject(request))
//                return
//            }
//
//            let decodedMessage = String(data: Data(hex: messageBytes), encoding: .utf8) ?? messageBytes
//
//            askToSign(request: request, message: decodedMessage) {
//                let personalMessageData = self.personalMessageData(messageData: Data(hex: messageBytes))
//                let (v, r, s) = try! self.privateKey.sign(message: .init(hex: personalMessageData.toHexString()))
//                return "0x" + r.toHexString() + s.toHexString() + String(v + 27, radix: 16) // v in [0, 1]
//            }
//        } catch {
//            sever.send(.invalid(request))
//            return
//        }
//    }
//
//    private func personalMessageData(messageData: Data) -> Data {
//        let prefix = "\u{19}Ethereum Signed Message:\n"
//        let prefixData = (prefix + String(messageData.count)).data(using: .ascii)!
//        return prefixData + messageData
//    }
//}

//class SignTransactionHandler: BaseHandler {
//    override func canHandle(request: Request) -> Bool {
//        return request.method == "eth_signTransaction"
//    }
//
//    override func handle(request: Request) {
//        do {
//            let transaction = try request.parameter(of: EthereumTransaction.self, at: 0)
//            guard transaction.from == privateKey.address else {
//                self.sever.send(.reject(request))
//                return
//            }
//
//            askToSign(request: request, message: transaction.description) {
//                let signedTx = try! transaction.sign(with: self.privateKey, chainId: 4)
//                let (r, s, v) = (signedTx.r, signedTx.s, signedTx.v)
//                return r.hex() + s.hex().dropFirst(2) + String(v.quantity, radix: 16)
//            }
//        } catch {
//            self.sever.send(.invalid(request))
//        }
//    }
//}

//==============================================================
//==============================================================


//extension Response {
//    static func signature(_ signature: String, for request: Request) -> Response {
//        return try! Response(url: request.url, value: signature, id: request.id!)
//    }
//}

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


