//
//  AdanacApp.swift
//  Adanac
//
//  Created by Daniel Bell on 3/2/22.
//

import SwiftUI
//import web3swift
//import CoreData
//import AuthenticationServices



@main
struct AdanacApp: App {
    @StateObject private var dataController = WalletDataController()
//    @SceneStorage("text")
    @StateObject private var wcServer = WalletConnectServerManager()

    var body: some Scene {
        WindowGroup {
            WalletDataView(wcServer: wcServer)
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .onOpenURL { url in
                    wcServer.didScan(url.absoluteString.replacingOccurrences(of: "wc://wc?uri=", with: ""))
                }
                .userActivity("ETH.ADANAC.OPENAPP", isActive: true) { activity in
                    print("")
                }
                .onContinueUserActivity("ETH.ADANAC.OPENAPP") { activity in
                    print("")
                }
        }

        #if os(macOS)
//        MenuBarExtra {
//            Text("exxtra view")
//        } label: {
//            Label("My Wallet", image: "Image")
//        }
//        .menuBarExtraStyle(.window)
        Settings {
            Text("YOUR SETTINGS")
        }
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
