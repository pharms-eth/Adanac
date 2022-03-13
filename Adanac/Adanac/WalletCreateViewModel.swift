//
//  WalletCreateViewModel.swift
//  Adanac
//
//  Created by Daniel Bell on 3/8/22.
//

import SwiftUI
import MEWwalletKit

class WalletCreateViewModel: ObservableObject {
    @Published var password1 = "web3swift"
    @Published var password2 = "web3swift"
    @Published var passwordOn = true
    @Published var progress: EllipticalProgress.Progress = .start
    @Published var phase: WalletCreateView.CreationPhase = .password
    @Published var seedAck = false
    public var seedPhrase: [String] = []

    public var wallet: Wallet = Wallet(address: nil, data: nil, name: nil)
    //let wallet = Wallet(address: address, data: keyData, name: name, isHD: true)

    func setPhase(_ phase: WalletCreateView.CreationPhase) {
        switch phase {
        case .password:
            progress = .start
        case .seedRetrieve:
            generateSeed()
            progress = .mid
        case .seedConfirmation:
            progress = .mid
        case .creationSuccess:
            progress = .end
            createAccountWallet()
        }

        self.phase = phase
    }

    func generateSeed() {
//        seedPhrase = Entropy().getWords()
    }

    func createAccountWallet() {
        guard password1 == password2 else {
            return
        }
        guard !password1.isEmpty else {
            return
        }

        let password = password1

//        let keystore = try! HDWalletKeyStore(mnemonics: seedPhrase, password: password, language: .english)


//        let keyData = try! JSONEncoder().encode(keystore.keystoreParams)
//
//
//        let address = keystore.addresses!.first!
//        let wallet = Wallet(address: address, data: keyData, name: "New HD Wallet", isHD: true)
//
//
//        let data = wallet.data!
//        let keystoreManager: KeystoreManager
//        if wallet.isHD {
//            let keystore = BIP32Keystore(data)!
//            keystoreManager = KeystoreManager([keystore])
//        } else {
//            let keystore = EthereumKeystoreV3(data)!
//            keystoreManager = KeystoreManager([keystore])
//        }


    }
}



