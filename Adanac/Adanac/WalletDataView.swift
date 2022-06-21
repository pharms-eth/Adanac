//
//  WalletDataView.swift
//  Adanac
//
//  Created by Daniel Bell on 6/18/22.
//

import SwiftUI

struct WalletDataView: View {
    @Environment(\.managedObjectContext) var moc
    @StateObject private var viewModel = WalletsStoredManager()

    var body: some View {
//        if let ethWallet = wallet, case .full(let addr) = ethWallet {
//            Text(addr.addresses?.first?.address ?? "no keys")
//        }

        if viewModel.wallets?.isEmpty ?? true {
            WalletSetupMenuView(wallet: $viewModel.wallet)
        } else if viewModel.showingImportPopover {
            WalletImportView(wallet: $viewModel.wallet, showView: $viewModel.showingImportPopover)
        } else if viewModel.showingCreatePopover {
            WalletCreateView(ethWallet: $viewModel.wallet, showView: $viewModel.showingCreatePopover)
        } else {
//            WalletPortfolioView()//(addr: addr)
            VStack {
                VStack {
                    List {
                        ForEach(viewModel.wallets ?? []) { wallet in
                            ForEach(wallet.addressArray) { address in
                                Text(address.address ?? "unknown")
                            }
                        }
                        .onDelete(perform: viewModel.deleteKeystores)
                    }
                }
                HStack {
                    #if os(iOS)
                    EditButton()
                        .padding()
                        .background()
                    Spacer()
                    #endif
                    VStack {
                        WalletSetupStyledButton(showingPopover: $viewModel.showingImportPopover, title: "Import Using Seed Phrase", background: Color(red: 32/255, green: 40/255, blue: 50/255))

                        WalletSetupStyledButton(showingPopover: $viewModel.showingCreatePopover, title: "Create a New Wallet", background: Color.primaryOrange)
                    }
                }
            }
        }
    }



}

struct WalletDataView_Previews: PreviewProvider {
    static var previews: some View {
        WalletDataView()
    }
}
