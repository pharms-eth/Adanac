//
//  WalletCreateSuccessView.swift
//  Adanac
//
//  Created by Daniel Bell on 3/5/22.
//

import SwiftUI
import web3swift

struct WalletCreateSuccessView: View {
    @Binding public var ethWallet: WalletKeyStoreAccess?
    @Binding public var showView: Bool
    @ObservedObject public var model: WalletCreateViewModel
    var body: some View {
        VStack {

            // check mark
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .foregroundColor(.primaryOrange)
                .frame(width: 160, height: 160)
                .padding(.top, 72)

            Text("Success!")
                .font(.system(size: 40.0, weight: .regular))
                .foregroundColor(.primaryOrange)
                .padding(.vertical, 40)

            Spacer()
            VStack(spacing: 24) {
                Text("You've successfully protected your wallet. Remember to keep your seed phrase safe, it's your responsibility!")
                    .font(.system(size: 14.0, weight: .regular))
                    .lineSpacing(10.0)
                    .multilineTextAlignment(.center)
                Text("We cannot recover your wallet should you lose it. You can find your seedphrase in Setings > Security & Privacy")
                    .font(.system(size: 14.0, weight: .regular))
                    .lineSpacing(10.0)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .padding(.bottom, 65)
            WalletButton(title: "Next") {
                if let wallet = model.wallet {
                    ethWallet = .full(wallet)
                }
                showView = false
            }
            .padding(.bottom, 42)
        }
        .background(Color.background)
    }
}

struct WalletCreateSuccessView_Previews: PreviewProvider {
    static var previews: some View {
        WalletCreateSuccessView(ethWallet: .constant(nil), showView: .constant(true), model: WalletCreateViewModel())
    }
}
