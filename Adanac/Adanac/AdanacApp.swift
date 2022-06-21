//
//  AdanacApp.swift
//  Adanac
//
//  Created by Daniel Bell on 3/2/22.
//

import SwiftUI
import CryptoKit
import web3swift
import CryptoSwift
import CoreData
import AuthenticationServices
import PhotosUI


@main
struct AdanacApp: App {
    @StateObject private var dataController = WalletDataController()

    @StateObject private var WCServer = WalletConnectServerManager()

    var body: some Scene {
        WindowGroup {
            ImageCodeScannerView()
            CodeScannerView { result in
                switch result {
                case .success(let code):
                    print("yay!: \(code)")
                    WCServer.didScan(code.string)
                case .failure(_):
                    print("boo!")
                }
            }
            .onDisappear {
                WCServer.disconnect()
            }
            WalletDataView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .onOpenURL { url in
//                    guard let controller = window?.rootViewController as? MainViewController else {
//                        return false
//                    }
//                    controller.didScan(url.absoluteString.replacingOccurrences(of: "wc://wc?uri=", with: ""))
//                    guard let url = WCURL(code) else { return }
//                            scanQRCodeButton.isEnabled = false
//                            scannerController?.dismiss(animated: true)
//                            do {
//                                try self.server.connect(to: url)
//                            } catch {
//                                return
//                            }
                }
        }

        #if os(macOS)
        MenuBarExtra {
            Text("exxtra view")
        } label: {
            Label("My Wallet", image: "Image")
        }
        .menuBarExtraStyle(.window)
        #endif

    }
}

//struct WalletFilterView: View {
//    @FetchRequest var fetchRequest: FetchedResults<Keystore>
//    var body: some View {
//        Text("Some Text")
//    }
//    init(filter: String) {
//        _fetchRequest = FetchRequest(sortDescriptors: [], predicate: nil, animation: .linear)
////        fetchRequest.sortDescriptors
////        fetchRequest.nsPredicate
//    }
//    @FetchRequest(entity: Keystore.entity(), sortDescriptors: []) var wallets: FetchedResults<Keystore>
//}


// class AdanacASAuth: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
//    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
////        UIWindow()
//        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
//                let window = windowScene?.windows.first
//        return window!
//    }
//    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
//        print(error)
//    }
//    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
//        print(authorization)
//    }
// }


//    var adanacASAuth = AdanacASAuth()
//                    .onAppear {
//                        let request = ASAuthorizationPasswordProvider().createRequest() // Initialize Apple ID authorization request
//
//                           let controller = ASAuthorizationController(authorizationRequests: [request]) // Initialize the authorization controller
//                           controller.delegate = adanacASAuth
//                           controller.presentationContextProvider = adanacASAuth
//                           controller.performRequests() // Perform the authorization request
//                    }
