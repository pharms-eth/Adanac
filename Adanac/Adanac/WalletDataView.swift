//
//  WalletDataView.swift
//  Adanac
//
//  Created by Daniel Bell on 6/18/22.
//

import SwiftUI
import web3swift

struct WalletDataView: View {
    @Environment(\.managedObjectContext) var moc
    @StateObject private var viewModel = WalletsStoredManager()
    @ObservedObject var wcServer: WalletConnectServerManager
    @State private var accountName: String = ""
    @State private var accountColor: Color =  Color(.sRGB, red: 0.98, green: 0.9, blue: 0.2)

    var body: some View {
//        if let ethWallet = wallet, case .full(let addr) = ethWallet {
//            Text(addr.addresses?.first?.address ?? "no keys")
//        }

        Group {
        if viewModel.wallets?.isEmpty ?? true {
            WalletSetupMenuView(wallet: $viewModel.wallet)
        } else if viewModel.showingImportPopover {
            WalletImportView(wallet: $viewModel.wallet, showView: $viewModel.showingImportPopover)
        } else if viewModel.showingCreatePopover {
            WalletCreateView(ethWallet: $viewModel.wallet, showView: $viewModel.showingCreatePopover)
        } else if viewModel.showingWalletConnectPopover {
            WalletConnectView(wcServer: wcServer, showingWalletConnectPopover: $viewModel.showingWalletConnectPopover)
        } else {
//            WalletPortfolioView()//(addr: addr)
            VStack {
                VStack {
                    if let session = wcServer.session {
                        WalletConnectSessionView(session: session)
                        .onTapGesture {
                            wcServer.disconnect()
                        }
                    }
                    List {
                        ForEach(wcServer.sessions ?? []) { session in
                            WCSessionListTableCell(session: session)
//                            .onTapGesture {
//                                wcServer.disconnect(session: session)
//                            }
                        }
                        .onDelete(perform: wcServer.deleteSessions)
                    }
                    List {
                        ForEach(viewModel.wallets ?? []) { wallet in
                            WalletListTableCell(wallet: wallet)
                                .onTapGesture {
                                    viewModel.setCurrent(keystore: wallet)
                                    guard let newWallet = viewModel.currentWallet else { return }
                                    wcServer.set(privateKey: newWallet)
                                }
                        }
                        .onDelete(perform: viewModel.deleteKeystores)
                    }
                    .onAppear {
                        guard let newWallet = viewModel.currentWallet else { return }
                        wcServer.set(privateKey: newWallet)
                    }
                }
                HStack {
                    #if os(iOS)
                    EditButton()
                        .padding()
                        .background()
                    Spacer()
                    #endif
                    Text("add Test").padding().background(Color.background).padding()
                        .onTapGesture {
                            viewModel.bulkLoadTest()
                        }
                    VStack {
                        WalletSetupStyledButton(showingPopover: $viewModel.showingImportPopover, title: "Import Using Seed Phrase", background: Color(red: 32/255, green: 40/255, blue: 50/255))

                        WalletSetupStyledButton(showingPopover: $viewModel.showingCreatePopover, title: "Create a New Wallet", background: Color.primaryOrange)

                        WalletSetupStyledButton(showingPopover: $viewModel.showingWalletConnectPopover, title: "Create WC Session", background: Color.secondaryOrange)
                    }
                }
            }
        }
        }
        .onChange(of: viewModel.wallet) { newValue in
            var params: AbstractKeystoreParams? = nil

            switch newValue {
            case .full(let key):
                params = (key as? BIP32Keystore)?.keystoreParams ?? (key as? EthereumKeystoreV3)?.keystoreParams
            case .readOnly(let key):
                params = (key as? BIP32Keystore)?.keystoreParams ?? (key as? EthereumKeystoreV3)?.keystoreParams
            case .none:
                params = nil
            }
//
            viewModel.currentWallet = params
//            guard let newWallet = viewModel.currentWallet else { return }
//            wcServer.set(privateKey: newWallet)
        }
    }
}

struct WalletConnectView: View {
    @ObservedObject var wcServer: WalletConnectServerManager
    @Binding var showingWalletConnectPopover: Bool

    var body: some View {
        if let session = wcServer.session {
            VStack {
                WalletConnectSessionView(session: session)
                WalletButton(title: "Import") {
                    showingWalletConnectPopover = false
                }
                .padding(.bottom, 42)
            }
//                .onTapGesture {
//                    wcServer.disconnect()
//                }
        } else {
        #if os(iOS)
            WalletConnectScanView(WCServer: wcServer, showView: $showingWalletConnectPopover)
        #else
            Text("WALLET CONNECT IMPORT NOT IMPLEMENTED")
                .padding()
                .onTapGesture {
                    viewModel.showingWalletConnectPopover = false
                }
        #endif
        }
    }
}

struct WCSessionListTableCell: View {
    var session: WCSession
    var body: some View {
        VStack {
            HStack {
                VStack {
                    Text(session.dAppInfo?.peerMeta?.name ?? "dApp")
                    Text("\(session.dAppInfo?.chainID ?? 0)")
                            .padding(.bottom, 4)
                }
                .padding()
                Spacer()

                //4 possible UI states
                //4) icon: value  link: value
                Group {
                    if let urlValue = session.dAppInfo?.peerMeta?.url, let linkURL = URL(string: urlValue), let icon = session.dAppInfo?.peerMeta?.iconArray.first {
                        Link(destination: linkURL) {
                            AsyncImage(url: icon) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                case .success(let image):
                                    image.resizable()
                                         .aspectRatio(contentMode: .fit)
                                         .frame(maxWidth: 44, maxHeight: 44)
                                case .failure:
                                    Image(systemName: "photo")
                                }
                            }
                        }
                    }
                    //3) icon: nil  link: value
                    else if let urlValue = session.dAppInfo?.peerMeta?.url, let linkURL = URL(string: urlValue), session.dAppInfo?.peerMeta?.iconArray.first == nil {
                        Link("Visit " + (session.dAppInfo?.peerMeta?.name ?? "dApp"), destination: linkURL)
                    }
                    //2) icon: value  link: nil
                    else if let icon = session.dAppInfo?.peerMeta?.iconArray.first {
                        AsyncImage(url: icon) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                            case .success(let image):
                                image.resizable()
                                     .aspectRatio(contentMode: .fit)
                                     .frame(maxWidth: 44, maxHeight: 44)
                            case .failure:
                                Image(systemName: "photo")
                            }
                        }
                    }
                    //1) icon: nil  link: nil
                }
                .padding()
            }
            .background((session.dAppInfo?.approved ?? false) ? Color.green : .red )
            Text(session.dAppInfo?.peerMeta?.desc ?? "NO")
            .padding()
        }
    }
}


struct WalletListTableCell: View {
    var wallet: Keystore

    var body: some View {
        VStack {
            Text(wallet.nickName ?? "unknown")
//                                ColorPicker("Account Color", selection: $accountColor)
            Text("MORE >")
        }
        .background(wallet.tintColor)
        .swipeActions(allowsFullSwipe: false) {
            Button {
                print("Muting conversation")
            } label: {
                Label("Private Key", systemImage: "bell.slash.fill")
            }
            .tint(.indigo)

            Button(role: .destructive) {
                print("Deleting conversation")
            } label: {
                Label("Add Child", systemImage: "trash.fill")
            }
        }
    }
}

//struct WalletDataView_Previews: PreviewProvider {
//    static var previews: some View {
//        WalletDataView()
//    }
//}
