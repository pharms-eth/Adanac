//
//  WalletImportViewModel.swift
//  Adanac
//
//  Created by Daniel Bell on 3/2/22.
//

import Foundation
import Combine
import web3swift

//guard let wallet = wallet else {return}
//
//let data = wallet.data
//let keystoreManager: KeystoreManager
//
//if wallet.isHD {
//    let keystore = BIP32Keystore(data)!
//    keystoreManager = KeystoreManager([keystore])
//
//    guard let signature = try? Web3Signer.signPersonalMessage(meessageData, keystore: keystore, account: ethWallet.address, password: "web3swift") else {
////                            throw Web3Error.dataError
//        return
//    }
//    do {
//        Task {
//            guard !meessageData.isEmpty, try await message.validate(signature: signature, meessageData: meessageData) else {
//                //error: 'Expected prepareMessage object as body.'
//                return
//            }
//        }
//    } catch {
//        print("error")
//    }
//
//} else {
//    let keystore = EthereumKeystoreV3(data)!
//    keystoreManager = KeystoreManager([keystore])
//
//    guard let signature = try? Web3Signer.signPersonalMessage(meessageData, keystore: keystore, account: ethWallet.address, password: "web3swift") else {
////                            throw Web3Error.dataError
//        return
//    }
//    do {
//        Task {
//            guard !meessageData.isEmpty, try await message.validate(signature: signature, meessageData: meessageData) else {
//                //error: 'Expected prepareMessage object as body.'
//                return
//            }
//        }
//    } catch {
//        print("error")
//    }
//}h
//
//Task {
//    guard let web3 = await Web3.InfuraMainnetWeb3() else { return }  // Mainnet Infura Endpoint Provider
//    web3.addKeystoreManager(keystoreManager)
//}

class WalletImportViewModel: ObservableObject {

    enum ImportSource: String {
        case seed = "Seed Phrase"
        case privateKey = "Private Key"
        case ensDomain = "ENS domain"
        case ethAddress = "Ethereum Address"
    }

    @Published var error: String?
    @Published var editText: String = ""
    @Published var password1Text: String = ""
    @Published var password2Text: String = ""
    @Published var faceIsOn = false
    @Published var source: ImportSource?
    var textCancellable: AnyCancellable?

    public init() {
        textCancellable = $editText.sink { value in
            if value.contains(".ETH") {
                self.source = .ensDomain
            } else if value.hasPrefix("0x") {
                self.source = .ethAddress
            } else {
                self.source = nil
            }
        }
    }

    func sourceType(from value: String) -> ImportSource? {
        guard !value.isEmpty else {
            return nil
        }

        if value.count >= 64 && isHexStringIgnorePrefix(value: value) {
            return .privateKey
        } else if isValidSeedPhrase(value) {
            return .seed
        } else if isValidAddress(value) {
            return .ethAddress
        } else if isUnstoppableAddress(value) || isENSAddress(value) {
            return .ensDomain
        }

        return nil
    }

    func isHexStringIgnorePrefix(value: String) -> Bool {
        guard !value.isEmpty else {
            return false
        }
        let updatedValue = value.hasPrefix("0x") ? value : "0x" + value
        return isHexString(value: updatedValue)
    }

    func isHexString(value: String) -> Bool {
        value.range(of: #"^0x[0-9A-Fa-f]*$"#, options: .regularExpression) != nil
    }

    func isValidSeedPhrase(_ seedPhrase: String) -> Bool {
        let sanitizedSeedPhrase = seedPhrase.components(separatedBy: .whitespacesAndNewlines)
        return sanitizedSeedPhrase.count >= 12 && isValidMnemonic(sanitizedSeedPhrase)
    }

    func isValidMnemonic(_ mnemonic: [String]) -> Bool {
        mnemonic.map { value in BIP39Language.english.words.contains(value)}.filter { $0 }.count == 12
    }

    func isValidAddress(_ address: String) -> Bool {
        address.range(of: #"^0x[0-9a-fA-F]{40}$"#, options: .regularExpression) != nil
    }

    let supportedUnstoppableDomains = ["888", "bitcoin", "coin", "crypto", "dao", "nft", "wallet", "x", "zil"]
    func isUnstoppableAddress(_ address: String) -> Bool {
        hasTLDs(address: address, tlds: supportedUnstoppableDomains)
    }

    func isENSAddress(_ address: String) -> Bool {
        hasTLDs(address: address, tlds: ["eth"])

    }

    func hasTLDs(address: String, tlds: [String]) -> Bool {
        guard let addressURL = URL(string: address) else { return false }
        let host = addressURL.host
        guard let parts = host?.split(separator: ".").last?.lowercased() else { return false }

        return tlds.contains(parts)
    }



//    func importWallet() async -> Wallet? {
//        var password: String? = nil
//
//        editText = ""//"5be307eed5a14f93eccb720abb9febaeeefcae43609566920ac573864fe294e0"
//        //        editText = "goddess cook glass fossil shrug tree rule raccoon useless phone valley frown"
//
//        if !password1Text.isEmpty && !password2Text.isEmpty {
//            if password1Text != password1Text {
//                error = "It looks like you attempted to create a password, please complete"
//                return nil
//            } else {
//                password = password1Text
//            }
//        } else if !password1Text.isEmpty || !password2Text.isEmpty {
//            error = "It looks like you attempted to create a password, please complete or clear"
//            return nil
//        }
//
//        let wordList = editText.components(separatedBy: " ")
//
//        if wordList.count >= 12 && wordList.count.isMultiple(of: 3) && wordList.count <= 24 {
//            return importWalletWithMnemonics(password: password ?? "web3swift")
//        } else if editText.count == 32 {
//            return importWalletWithPrivateKey(password: password ?? "web3swift")
//        } else {
//            guard let web = await Web3.InfuraMainnetWeb3() else { return nil } // Mainnet Infura Endpoint Provider
//            let ens = ENS(web3: web)!
//
//            return nil
//        }
//    }
//
//    func importWalletWithPrivateKey(password: String = "web3swift") -> Wallet? {
//
//        let privateKey = editText
//
//        let formattedKey = privateKey.trimmingCharacters(in: .whitespacesAndNewlines)
//        guard let dataKey = Data.fromHex(formattedKey) else {
//            self.error = "Please enter a valid Private key"
//            return nil
//        }
//
//        do {
//            guard let keystore =  try EthereumKeystoreV3(privateKey: dataKey, password: password) else {
//                self.error = "Please enter correct Private key"
//                return nil
//            }
//
//            guard let keyData = try? JSONEncoder().encode(keystore.keystoreParams), let address = keystore.addresses?.first else {
//                return nil
//            }
//
//            let wallet = Wallet(address: address, data: keyData, name: "New Wallet", isHD: false)
//            return wallet
//        } catch {
//            self.error = "Please enter correct Private key"
//        }
//
//        return nil
//    }
//
//    func importWalletWithMnemonics(password: String = "web3swift") -> Wallet? {
//        let mnemonics = editText
//
//        guard
//            let bip32keystore = try? BIP32Keystore(mnemonics: mnemonics, password: password, prefixPath: "m/44'/77777'/0'/0"),
//            let bip32keyData = try? JSONEncoder().encode(bip32keystore.keystoreParams),
//            let bip32address = bip32keystore.addresses?.first
//        else {
//            return nil
//        }
//
//        let wallet = Wallet(address: bip32address, data: bip32keyData, name: "New Wallet", isHD: true)
//        return wallet
//    }
}
