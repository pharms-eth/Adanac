////
////  WebView.swift
////  Adanac
////
////  Created by Daniel Bell on 3/20/22.
////
//
// import SwiftUI
// import WebKit
// import web3swift
// import UIKit
//
// class BrwsrVC: BrowserViewController {
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//
//        webView.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(webView)
//
//        NSLayoutConstraint.activate([
//            webView.topAnchor.constraint(equalTo: view.topAnchor),
//            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//            ])
//
//
//        let urlToOpen = "https://1inch.exchange/"
////        urlToOpen = "https://app.compound.finance"
////        urlToOpen = "https://app.uniswap.org"
//
//        webView.load(URLRequest(url: URL(string: urlToOpen)!))
//
//// =======================================================================================
//
//        do {
//            let userDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
//            var keystoreManager = KeystoreManager.managerForPath(userDir + "/keystore")
//            var ks: EthereumKeystoreV3?
//            if (keystoreManager?.addresses?.count == 0) {
//                ks = try EthereumKeystoreV3(password: "web3swift")
//                let keydata = try JSONEncoder().encode(ks!.keystoreParams)
//                FileManager.default.createFile(atPath: userDir + "/keystore"+"/key.json", contents: keydata, attributes: nil)
//                keystoreManager = KeystoreManager.managerForPath(userDir + "/keystore")
//            }
//            guard let sender = keystoreManager?.addresses![0] else {return}
//            print(sender)
//
//            let web3 = Web3.InfuraRinkebyWeb3()
//            web3.addKeystoreManager(keystoreManager)
//
//            self.registerBridges(for: web3)
//        }
//        catch{
//            print(error)
//        }
//    }
// }
// struct BrowserView: UIViewControllerRepresentable {
//    func makeUIViewController(context: Context) -> BrwsrVC {
//        let webView = BrwsrVC()
//
//
//        //TODO: add browser web view to view
//
//
//        let urlToOpen = "https://1inch.exchange/"
////        let urlToOpen = "https://app.compound.finance"
//        webView.webView.load(URLRequest(url: URL(string: urlToOpen)!))
//
//        let mnemonics = "goddess cook glass fossil shrug tree rule raccoon useless phone valley frown".components(separatedBy: .whitespaces)
//
//        Task {
//            guard
//                let bip32keystore = try? BIP32Keystore(mnemonics: mnemonics, password: "", prefixPath: "m/44'/77777'/0'/0")
//            else {
//                return
//            }
//            let keystoreManager: KeystoreManager = KeystoreManager([bip32keystore])
//            let web3 = Web3.InfuraRinkebyWeb3()
//            web3.addKeystoreManager(keystoreManager)
//            webView.registerBridges(for: web3)
//        }
//
//
//        return webView
//    }
//
//    func updateUIViewController(_ uiViewController: BrwsrVC, context: Context) {
//    }
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator()
//    }
//
//    struct Coordinator {
//    }
// }
//
// struct WebView: UIViewRepresentable {
//
//    let url: URL
//
//    func makeUIView(context: Context) -> WKWebView {
//        let request = URLRequest(url: url)
//
//        let userController = WKUserContentController()
//        userController.add(context.coordinator, name: "pacific")
//        let configuration = WKWebViewConfiguration()
//        configuration.userContentController = userController
//
//        let websiteDataTypes = NSSet(array: [WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache])
//       let date = NSDate(timeIntervalSince1970: 0)
//
//       WKWebsiteDataStore.default().removeData(ofTypes: websiteDataTypes as! Set<String>, modifiedSince: date as Date, completionHandler:{ })
//       let webView = WKWebView(
//           frame: .zero,
//           configuration: configuration
//       )
//       webView.allowsBackForwardNavigationGestures = true
//       webView.scrollView.isScrollEnabled = true
//       webView.configuration.preferences.setValue(true, forKey: "developerExtrasEnabled")
//
//
//        webView.uiDelegate = context.coordinator
//        webView.navigationDelegate = context.coordinator
//
//
//        webView.load(request)
//        return webView
//    }
//
//    func updateUIView(_ webView: WKWebView, context: Context) {
//
//    }
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator()
//    }
//
//    class Coordinator: NSObject, WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler {
//
//        public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//                print("Navigation is completed")
//            }
//        public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
//                print("message \(message.body)")
//
//            }
//
//    }
//
// }
//
// struct WebView_Previews: PreviewProvider {
//    static var previews: some View {
//        WebView(url: URL(string: "https://www.appcoda.com")!)
//    }
// }
