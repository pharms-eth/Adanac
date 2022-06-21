//
//  WalletCreateView.swift
//  SIWE-Swift
//
//  Created by Daniel Bell on 2/18/22.
//

import SwiftUI
import web3swift

struct WalletCreateView: View {
    enum CreationPhase {
        case password
        case seedRetrieve
        case seedConfirmation
        case creationSuccess
    }

    @StateObject var model = WalletCreateViewModel()
    @Binding public var ethWallet: WalletKeyStoreAccess?
    @Binding public var showView: Bool
    @State private var animateLoading = false

    var body: some View {
        VStack {
            EllipticalProgress(progress: $model.progress)
            .padding(.horizontal, 88)
            .padding(.top)

            switch model.phase {
            case .password:
                WalletCreatePasswordView(model: model, showPasswordEntry: $model.showPasswordEntry)
            case .seedRetrieve:
                WalletCreateSeedRetrieveView(seedPhrase: model.seedPhrase, setPhase: model.setPhase(_:))
            case .seedConfirmation:
                WalletCreateseedConfirmationView(model: model)
            case .creationSuccess:
                WalletCreateSuccessView(ethWallet: $ethWallet, showView: $showView, model: model)
            }
        }
        .overlay {
            if model.creatingWalletInProgress {
                ZStack {
                    Color.black

                    Circle()
                    .fill(Color.primaryOrange)
                    .frame(width: 30, height: 30)
                    .overlay(
                        ZStack {
                            Circle()
                                .stroke(Color.primaryOrange, lineWidth: 100)
                                .scaleEffect(animateLoading ? 1 : 0)
                            Circle()
                                .stroke(Color.primaryOrange, lineWidth: 100)
                                .scaleEffect(animateLoading ? 1.5 : 0)
                            Circle()
                                .stroke(Color.primaryOrange, lineWidth: 100)
                                .scaleEffect(animateLoading ? 2 : 0)
                        }
                            .opacity(animateLoading ? 0.0 : 0.2)
                            .animation(.easeInOut(duration: 1).repeatForever(autoreverses: false), value: animateLoading)
                )
                }
                .onAppear {
                    animateLoading = true
                }
            }
        }
    }
}

struct WalletCreateView_Previews: PreviewProvider {
    static var previews: some View {
        WalletCreateView(ethWallet: .constant(nil), showView: .constant(true))
    }
}
