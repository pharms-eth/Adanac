//
//  ContentView.swift
//  Adanac
//
//  Created by Daniel Bell on 2/5/22.
//

import SwiftUI
import web3swift

struct WalletSetupMenuView: View {

    @State private var showingCreatePopover = false
    @State private var showingImportPopover = false
    @Binding public var wallet: WalletKeyStoreAccess?

    var body: some View {
        if showingImportPopover {
            WalletImportView(wallet: $wallet, showView: $showingImportPopover)
        } else if showingCreatePopover {
            WalletCreateView(ethWallet: $wallet, showView: $showingCreatePopover)
        } else {
            VStack(alignment: .center) {
                Spacer()
                Image(systemName: "creditcard")
                    .resizable()
                    .frame(width: 250, height: 250)
                    .foregroundColor(.primaryOrange)
                Spacer()
                if wallet == nil {
                    VStack {
                        WalletSetupStyledButton(showingPopover: $showingImportPopover, title: "Import Using Seed Phrase", background: Color(red: 32/255, green: 40/255, blue: 50/255))

                        WalletSetupStyledButton(showingPopover: $showingCreatePopover, title: "Create a New Wallet", background: Color.primaryOrange)
                    }
                    .padding(.bottom, 56)
                }
            }
        }

    }
}
