//
//  WalletImportViewModel.swift
//  Adanac
//
//  Created by Daniel Bell on 3/2/22.
//

import Foundation
import Combine

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
        return true
//        mnemonic.map { value in BIP39Language.english.words.contains(value)}.filter { $0 }.count == 12
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
}
