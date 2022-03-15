//
//  WalletCreateViewModel.swift
//  Adanac
//
//  Created by Daniel Bell on 3/8/22.
//

import SwiftUI

import SafariWalletCore
import MEWwalletKit

class WalletCreateViewModel: ObservableObject {
    private var bip39: BIP39? = try? BIP39(bitsOfEntropy: 128)

    @Published var password1 = "web3swift"
    @Published var password2 = "web3swift"
    @Published var passwordOn = true
    @Published var progress: EllipticalProgress.Progress = .start
    @Published var phase: WalletCreateView.CreationPhase = .password
    @Published var seedAck = false
    public var seedPhrase: [String] = []

    public var bundle: AddressBundle?
//    public var wallet: Wallet = Wallet(address: nil, data: nil, name: nil)
    //let wallet = Wallet(address: address, data: keyData, name: name, isHD: true)

    func setPhase(_ phase: WalletCreateView.CreationPhase) async {
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
            
            try? await createAccountWallet()
        }
        DispatchQueue.main.async {
            self.phase = phase
        }
    }

    func generateSeed() {
        seedPhrase = bip39?.mnemonic ?? []
    }

    func createAccountWallet() async throws {
        guard password1 == password2 else {
            return
        }
        guard !password1.isEmpty else {
            return
        }

        let password = password1
//need to edit bip39 to save mnemonic
        guard let seed = try bip39?.seed() else { throw WalletError.addressGenerationError }
        let wallet: Wallet<PrivateKeyEth1> = try Wallet(seed: seed, network: .ethereum)

        let addresses = try wallet.generateAddresses(count: 5)

        let id = UUID()
        let adrBundle = AddressBundle(id: id, walletName: "Eth Wallet", type: .keystorePassword, network: .ethereum, addresses: addresses)
        try await adrBundle.addresses.concurrentForEach { address in
            try await address.fetchENSname(network: .ethereum, provider: .alchemy(key: ApiKeys.alchemyMainnet))
        }

        //saves persistante storage//        try await bundle.save()
        // 4. Save seed

        // 5. Store password in keychain
//        try await KeychainPasswordItem.store(password: password, account: id.uuidString)

        // 6. Set default wallet
        self.bundle = adrBundle

        // 7. Print debug
        #if DEBUG
        print(addresses)
        #endif

    }
}

extension KeychainPasswordItem {


    /// Convenience method to store password in keychain
    /// - Parameters:
    ///   - password: The password to be stored
    ///   - account: UUIDstring of the keystore file the password belongs to
    ///   - reusableDuration: Time password can be used without FaceID/TouchID verification. Default is 1200 seconds (20 minutes)
    static func store(password: String, account: String, reusableDuration: TimeInterval = 1200) async throws {
        let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName,
                                                account: account,
                                                accessGroup: KeychainConfiguration.accessGroup)
        try passwordItem.savePassword(password, userPresence: true, reusableDuration: reusableDuration)
    }
}

extension KeystoreV3 {

    convenience init(bip39: BIP39, password: String) async throws {

        // 1. Create keystore V3
        guard let entropy = bip39.entropy,
              let passwordData = password.data(using: .utf8)?.sha256()
        else {
            throw WalletError.invalidInput(nil)
        }
        try await self.init(privateKey: entropy, passwordData: passwordData)
    }
}

struct ApiKeys {
    static let alchemyMainnet = "<YOUR KEY HERE>"
    static let alchemyRopsten = "<YOUR KEY HERE>"
    static let infuraRopsten = "<YOUR KEY HERE>"
    static let infuraMainnet = "<YOUR KEY HERE>"
    static let covalent = "<YOUR KEY HERE>"
    static let unmarshal = "<YOUR KEY HERE>"
    static let etherscan = "<YOUR KEY HERE>"
    static let zerion = "Demo.ukEVQp6L5vfgxcz4sBke7XvS873GMYHy"
}

enum WalletError: Error {
    case invalidAppGroupIdentifier(String)
    case invalidInput(String?)
    case invalidPassword
    case wrongPassword
    case passwordRequired
    case addressNotFound(String)
    case addressGenerationError
    case addressFileError
    case seedError
    case noDefaultWalletSet
    case noDefaultAddressSet
    case noAddressBundles
    case unexpectedResponse(String)
    case noMethod
    case errorOpeningKeyStore(String)
    case viewOnly
    case notImplemented
    case outOfBounds
    case fileNotFound(String)
    case invalidAppGroup(String)
}

extension WalletError: LocalizedError {

    /// A localized message describing what error occurred.
    var errorDescription: String? {
        switch self {
        case .invalidAppGroupIdentifier (let group):
            return "Invalid App Group identifier: \(group)"
        case .invalidInput (let input):
            return input == nil ? "Invalid input" : "Invalid input: \(input!)"
        case .invalidPassword:
            return "Invalid password"
        case .wrongPassword:
            return "Wrong password"
        case .passwordRequired:
            return "Password required"
        case .addressNotFound(let address):
            return "No account found for address \(address)"
        case .addressGenerationError:
            return "Error generating address"
        case .addressFileError:
            return "Error opening address file"
        case .seedError:
            return "Invalid recovery phrase"
        case .noDefaultWalletSet:
            return "No default wallet set"
        case .noDefaultAddressSet:
            return "No default address set"
        case .unexpectedResponse(let response):
            return "Unexpected response: \(response)"
        case .noMethod:
            return "Call with no method"
        case .errorOpeningKeyStore(let name):
            return "Error opening keystore file \(name)"
        case .viewOnly:
            return "This wallet is view-only"
        case .notImplemented:
            return "Method not implemented"
        case .outOfBounds:
            return "Out of bounds"
        case .noAddressBundles:
            return "No address bundles found"
        case .fileNotFound(let file):
            return "File not found: \(file)"
        case .invalidAppGroup(let group):
            return "Invalid app group: \(group)"
        }
    }

    /// A localized message describing the reason for the failure.
    var failureReason: String? { return nil }

    /// A localized message describing how one might recover from the failure.
    var recoverySuggestion: String? { return nil }

    /// A localized message providing "help" text if the user requests help.
    var helpAnchor: String? { return nil }
}

extension Sequence {

    func asyncMap<T>(_ transform: (Element) async throws -> T) async rethrows -> [T] {
        var values = [T]()

        for element in self {
            try await values.append(transform(element))
        }

        return values
    }

    func asyncForEach(_ operation: (Element) async throws -> Void) async rethrows {
        for element in self {
            try await operation(element)
        }
    }

    func concurrentForEach(_ operation: @escaping (Element) async -> Void) async {
        // A task group automatically waits for all of its
        // sub-tasks to complete, while also performing those
        // tasks in parallel:
        await withTaskGroup(of: Void.self) { group in
            for element in self {
                group.addTask {
                    await operation(element)
                }
            }
        }
    }

    func concurrentForEach(_ operation: @escaping (Element) async throws -> Void) async throws {
        // A task group automatically waits for all of its
        // sub-tasks to complete, while also performing those
        // tasks in parallel:
        await withThrowingTaskGroup(of: Void.self) { group in
            for element in self {
                group.addTask {
                    try await operation(element)
                }
            }
        }
    }
}
