//
//  ContentView.swift
//  Adanac
//
//  Created by Daniel Bell on 2/5/22.
//

import SwiftUI
import SafariWalletCore
//import MEWwalletKit

struct WalletSetupMenuView: View {

    @State private var showingCreatePopover = false
    @State private var showingImportPopover = false
    @Binding public var wallet: AddressBundle?

    var body: some View {
        VStack(alignment: .center){
            Spacer()
            Image(systemName: "creditcard")
                .resizable()
                .frame(width: 250, height: 250)
                .foregroundColor(.primaryOrange)
            Spacer()
            VStack {
                WalletSetupStyledButton(showingPopover: $showingImportPopover, title: "Import Using Seed Phrase", background: Color(red: 32/255, green: 40/255, blue: 50/255)) {
                    WalletImportView(wallet: $wallet, showView: $showingImportPopover)
                }
                WalletSetupStyledButton(showingPopover: $showingCreatePopover, title: "Create a New Wallet", background: Color.primaryOrange) {
                    WalletCreateView(ethWallet: $wallet, showView: $showingCreatePopover)
                }
            }
            .padding(.bottom, 56)
        }
    }
}

