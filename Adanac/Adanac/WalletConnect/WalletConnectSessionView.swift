//
//  WalletConnectSessionView.swift
//  Adanac
//
//  Created by Daniel Bell on 6/28/22.
//

import SwiftUI
import WalletConnectSwift

struct WalletConnectSessionView: View {
    var session: Session

    var body: some View {
        VStack {
            Text(session.url.absoluteString)
            if let walletInfo = session.walletInfo {
                VStack {
                    HStack {
                        Text("\(walletInfo.accounts.count)")
                        Text("\(walletInfo.chainId)")
                        Text(walletInfo.peerId)
                    }
                    .background(walletInfo.approved ? Color.green : Color.background)
                    VStack {
                        Text(walletInfo.peerMeta.name)
                        Text(walletInfo.peerMeta.description ?? "--")
                        Text("\(walletInfo.peerMeta.icons.count)")
                        Text(walletInfo.peerMeta.scheme ?? "--")
                    }
                }
            }
            VStack {
                HStack {
                    Text("\(session.dAppInfo.chainId ?? -1)")
                    Text(session.dAppInfo.peerId)
                }
                .background((session.dAppInfo.approved ?? false) ? Color.green : Color.background)
                VStack {
                    Text(session.dAppInfo.peerMeta.name)
                    Text(session.dAppInfo.peerMeta.description ?? "--")
                    Text("\(session.dAppInfo.peerMeta.icons.count)")
                    Text(session.dAppInfo.peerMeta.scheme ?? "--")
                }
            }
        }
    }
}

//struct WalletConnectSessionView_Previews: PreviewProvider {
//    static var previews: some View {
//        WalletConnectSessionView(session: <#Session#>)
//    }
//}
//
//extension Session {
//    static var previewData: Session {
//        let dAppClient = ClientMeta(name: "Test", description: "Testing", icons: [], url: URL(string: "example.com")!, scheme: "testing")
//        let dAppInfo = DAppInfo(peerId: "PeerID", peerMeta: dAppClient, chainId: 420, approved: true)
//
//        Session(url: <#T##WCURL#>, dAppInfo: dAppInfo, walletInfo: <#T##WalletInfo?#>)
//    }
//}
