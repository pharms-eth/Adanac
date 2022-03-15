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
    @Binding public var ethWallet: Wallet?
    @Binding public var showView: Bool

    var body: some View {
        VStack {
            EllipticalProgress(progress: $model.progress)
            .padding(.horizontal, 88)
            .padding(.top)

            switch model.phase {
            case .password:
                WalletCreatePasswordView(model: model)
            case .seedRetrieve:
                WalletCreateSeedRetrieveView(seedPhrase: model.seedPhrase, setPhase: model.setPhase(_:))
            case .seedConfirmation:
                WalletCreateseedConfirmationView(model: model)
            case .creationSuccess:
                WalletCreateSuccessView(ethWallet: $ethWallet, showView: $showView, model: model)
            }
        }
    }
}

struct WalletCreateView_Previews: PreviewProvider {
    static var previews: some View {
        WalletCreateView(ethWallet: .constant(nil), showView: .constant(true))
    }
}



