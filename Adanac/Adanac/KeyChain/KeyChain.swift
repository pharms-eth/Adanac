//
//  KeyChain.swift
//  Adanac
//
//  Created by Daniel Bell on 5/21/22.
//

import Foundation
import web3swift

struct KeyChain {
    let keychain = KeychainSwift()

    private func encode(wallet: AbstractKeystore) -> Data? {
        var walletData: Data?
        if let keystore = wallet as? BIP32Keystore {
            guard let params = keystore.keystoreParams else {
                return nil
            }

            guard let keyData = try? JSONEncoder().encode(params) else {
                return nil
            }
            walletData = keyData
        } else if let keystore = wallet as? EthereumKeystoreV3 {
            guard let params = keystore.keystoreParams else {
                return nil
            }

            guard let keyData = try? JSONEncoder().encode(params) else {
                return nil
            }
            walletData = keyData
        }
        return walletData
    }

    func store(wallet: AbstractKeystore, synchronizable: Bool = true) -> Bool {
        guard let walletData = encode(wallet: wallet) else {
            return false
        }

        keychain.synchronizable = synchronizable
        keychain.set(walletData, forKey: "ADANAC KEYSTORE")

        guard keychain.lastResultCode == errSecSuccess else {
            print(keychain.lastResultCode)
            return false
        }

        return true
    }

    func getWalletData() -> Data? {
        keychain.getData("ADANAC KEYSTORE")
    }

    func getWallet() -> AbstractKeystore? {
        guard let restoredData = getWalletData() else { return nil }
        return BIP32Keystore(restoredData) ?? EthereumKeystoreV3(restoredData)
    }
}
