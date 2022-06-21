//
//  WalletCreateSeedRetrieveView.swift
//  Adanac
//
//  Created by Daniel Bell on 3/7/22.
//

import SwiftUI

struct WalletCreateSeedRetrieveView: View {

    @State var passwordOn: Bool = false
    var seedPhrase: [String]
    var setPhase: (WalletCreateView.CreationPhase) -> Void

    let gridItems = [
        GridItem(.adaptive(minimum: 131.0)),
        GridItem(.adaptive(minimum: 131.0))
        ]

    @State var redacted = true
    var body: some View {
        VStack {

            VStack(spacing: 8.0) {
                Text("Your Seed Phrase")
                    .font(.system(size: 18.0, weight: .bold))
                    .foregroundColor(.primaryOrange)
                Text("Save your seed phrase in the correct order in a safe place. You'll be asked to re-enter this phrase (in order) on the next step.")
                    .font(.system(size: 14, weight: .regular))
                    .lineSpacing(10.0)
                    .foregroundColor(.secondaryOrange)
            }
            .padding(.vertical, 40)
            .padding(.horizontal, 24)

            LazyVGrid(columns: gridItems, spacing: 16.0) {
                // TODO:
                ForEach((0...11), id: \.self) {index in
                    HStack {
                        Spacer()
                        Text("\(index + 1). \(seedPhrase[index])")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.textForeground)
                        Spacer()
                    }
                    .padding(.vertical)
                    .background(Color.textBackground)
                    .cornerRadius(8.0)
                }
            }
            .padding(24)
            .cornerRadius(8.0)
            .border(Color.cardBorder, width: 1)
            .privacySensitive(redacted)
            .padding(.horizontal, 24)
            Spacer()
            WalletButton(title: "Next") {
                setPhase(.seedConfirmation)
            }
            .padding(.bottom, 42)
        }
        .background(Color.background)
        .blur(radius: redacted ? 8 : 0)
        .overlay(
            VStack {
                if redacted {
                    VStack(spacing: 0) {
                        VStack {
                            Text("What is a 'Seed phrase'")
                                .font(.system(size: 16, weight: .regular))
                                .padding(.top)
                                .padding(.bottom, 40)
                                .foregroundColor(.primaryOrange)
                            Text("A seed phrase is a set of twelve words that provides access to all the information about your wallet, including your funds. It's like a secret code used to access your entire wallet.\n\nYou must keep your seed phrase secret and safe. If someone gets your seed phrase, they'll gain control over your accounts.\n\nSave it in a place where only you can access it. If you lose it, no one can help you recover it.\n\nIt’s the only way to recover your wallet if you get locked out of the app or Apple Services,")
                                .font(.system(size: 14.0, weight: .regular))
                                .lineSpacing(10.0)
                                .foregroundColor(.textForeground)
                                .padding(.bottom)
//                            HStack {
//                                Text("save seed to icloud?")
//                                    .foregroundColor(Color.secondaryOrange)
//                                    .font(.system(size: 16, weight: .heavy))
//                                Toggle("Save Seed to iCloud", isOn: $passwordOn)
//                                    .tint(Color.primaryOrange)
//                                            .labelsHidden()
//                            }
//                            .padding()
//                            .border(Color.cardBorder)
                        }
                        .padding()
                        WalletButton(title: "I Understand") {
                            redacted = false
                        }
                        .padding(.vertical)
                    }
                    .background(Color.background)
                    .cornerRadius(16)
                    .padding(24)
                }
            }
        )
    }
}

// struct WalletCreateSeedRetrieveView_Previews: PreviewProvider {
//    static var previews: some View {
//        WalletCreateSeedRetrieveView(seedPhrase: ["Future", "Missing"], setPhase: <#(WalletCreateView.CreationPhase) -> ()#>)
//            .preferredColorScheme(.dark)
//    }
// }
