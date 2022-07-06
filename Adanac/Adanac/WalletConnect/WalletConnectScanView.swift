//
//  WalletConnectScanView.swift
//  Adanac
//
//  Created by Daniel Bell on 6/28/22.
//

import SwiftUI
import PhotosUI

struct WalletConnectScanView: View {
    @ObservedObject var WCServer: WalletConnectServerManager
    @Binding public var showView: Bool

    var body: some View {
        Group {
            if AVCaptureDevice.default(for: .video) == nil {
                ImageCodeScannerView(showView: $showView) { result in
                    switch result {
                    case .success(let code):
                        print("yay!: \(code)")
                        WCServer.didScan(code.string)
                    case .failure(_):
                        print("boo!")
                    }
                }
            } else {
                CodeScannerView { result in
                    switch result {
                    case .success(let code):
                        print("yay!: \(code)")
                        WCServer.didScan(code.string)
                    case .failure(_):
                        print("boo!")
                    }
                }
            }
        }
    }
}

//struct WalletConnectScanView_Previews: PreviewProvider {
//    static var previews: some View {
//        WalletConnectScanView()
//    }
//}
