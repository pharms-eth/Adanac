//
//  WalletsStoredManager.swift
//  Adanac
//
//  Created by Daniel Bell on 6/18/22.
//

import SwiftUI
import Combine
import web3swift

class WalletsStoredManager: NSObject, ObservableObject {
    @Published var wallets: [Keystore]?
    @Published var wallet: WalletKeyStoreAccess?
    @Published var showingCreatePopover = false
    @Published var showingImportPopover = false

    private var cancellables: [AnyCancellable] = []
    let moc = WalletDataController().container.viewContext
    let fetchRequest = Keystore.fetchRequest()

    override init() {
        fetchRequest.fetchBatchSize = 10

        let sort = NSSortDescriptor(key: #keyPath(Keystore.version), ascending: true)
        fetchRequest.sortDescriptors = [sort]

        super.init()
        Task {
            await fetchWallets()
        }


        $wallet.sink { newWallet in
            guard let newWallet = newWallet else {
                return
            }
            Task {
                if case .full(let addr) = newWallet {
                    await self.save(keystore: addr, accessLevel: .full)
                } else if case .readOnly(let addr) = newWallet {
                    await self.save(keystore: addr, accessLevel: .readOnly)
                }
                await self.fetchWallets()
            }
        }
        .store(in: &cancellables)
        
    }

    func save(keystore addr: AbstractKeystore, accessLevel: Keystore.NetworkAccess) async {
        if let bip32Addr = addr as? BIP32Keystore {
            try? await self.save(keystore: bip32Addr, accessLevel: accessLevel)
        } else if let pubAddr = addr as? PublicKeyStore {
            try? await self.save(keystore: pubAddr, accessLevel: accessLevel)
        } else if let plnAddr = addr as? PlainKeystore {
            try? await self.save(keystore: plnAddr, accessLevel: accessLevel)
        } else if let ethAddr = addr as? EthereumKeystoreV3 {
            try? await self.save(keystore: ethAddr, accessLevel: accessLevel)
        }
    }

    func save(keystore: EthereumKeystoreV3, accessLevel: Keystore.NetworkAccess) async throws {
        guard let model = keystore.keystoreParams else {
            fatalError("Failed to build wallet")
        }
        guard KeyChain().store(wallet: keystore) else {
            return
        }

        guard let address = model.address else {
            return
        }

        try await moc.perform {

            let newWallet = Keystore(context: self.moc)
            newWallet.isHDWallet = model.isHDWallet
            newWallet.version = Int16(model.version)
            newWallet.id = model.id
            newWallet.access = accessLevel.rawValue

            let newCrypto = CryptoParams(context: self.moc)
            newCrypto.ciphertext = model.crypto.ciphertext
            newCrypto.cipher = model.crypto.cipher
            newCrypto.kdf = model.crypto.kdf
            newCrypto.mac = model.crypto.mac
            newCrypto.version = model.crypto.version
            newCrypto.keystore = newWallet

            let cipherparams = model.crypto.cipherparams
            let kdfparams = model.crypto.kdfparams

            let newCipher = CipherParams(context: self.moc)
            newCipher.crypto = newCrypto
            newCipher.iv = cipherparams.iv

            let newKDFParams = KdfParams(context: self.moc)
            newKDFParams.crypto = newCrypto
            newKDFParams.c = Int64(kdfparams.c ?? 0)
            newKDFParams.dklen = Int64(kdfparams.dklen)
            newKDFParams.n = Int64(kdfparams.n ?? 0)
            newKDFParams.p = Int64(kdfparams.p ?? 0)
            newKDFParams.prf = kdfparams.prf
            newKDFParams.r = Int64(kdfparams.r ?? 0)
            newKDFParams.salt = kdfparams.salt

            let newAddress = Address(context: self.moc)
            newAddress.address = address
            newAddress.keystore = newWallet

            try self.moc.save()
        }
        // TODO: save seedPhrase to icloud
    }

    func save(keystore: PlainKeystore, accessLevel: Keystore.NetworkAccess) async throws {
        guard let model = keystore.keystoreParams else {
            fatalError("Failed to build wallet")
        }
        guard KeyChain().store(wallet: keystore) else {
            return
        }

        guard let address = model.address else {
            return
        }

        try await moc.perform {

            let newWallet = Keystore(context: self.moc)
            newWallet.isHDWallet = model.isHDWallet
            newWallet.version = Int16(model.version)
            newWallet.id = model.id
            newWallet.access = accessLevel.rawValue

            let newCrypto = CryptoParams(context: self.moc)
            newCrypto.ciphertext = model.crypto.ciphertext
            newCrypto.cipher = model.crypto.cipher
            newCrypto.kdf = model.crypto.kdf
            newCrypto.mac = model.crypto.mac
            newCrypto.version = model.crypto.version
            newCrypto.keystore = newWallet

            let cipherparams = model.crypto.cipherparams
            let kdfparams = model.crypto.kdfparams

            let newCipher = CipherParams(context: self.moc)
            newCipher.crypto = newCrypto
            newCipher.iv = cipherparams.iv

            let newKDFParams = KdfParams(context: self.moc)
            newKDFParams.crypto = newCrypto
            newKDFParams.c = Int64(kdfparams.c ?? 0)
            newKDFParams.dklen = Int64(kdfparams.dklen)
            newKDFParams.n = Int64(kdfparams.n ?? 0)
            newKDFParams.p = Int64(kdfparams.p ?? 0)
            newKDFParams.prf = kdfparams.prf
            newKDFParams.r = Int64(kdfparams.r ?? 0)
            newKDFParams.salt = kdfparams.salt

            let newAddress = Address(context: self.moc)
            newAddress.address = address
            newAddress.keystore = newWallet

            try self.moc.save()
        }
        // TODO: save seedPhrase to icloud
    }

    func save(keystore: PublicKeyStore, accessLevel: Keystore.NetworkAccess) async throws {
        guard let address = keystore.addresses?.first else {
            return
        }

        try await moc.perform {

            let newWallet = Keystore(context: self.moc)
            newWallet.isHDWallet = false
            newWallet.id = UUID().uuidString
            let newCrypto = CryptoParams(context: self.moc)
            newCrypto.keystore = newWallet
            newWallet.access = accessLevel.rawValue

            let newAddress = Address(context: self.moc)
            newAddress.address = address.address
            newAddress.keystore = newWallet

            try self.moc.save()
        }
        // TODO: save seedPhrase to icloud
    }

    func save(keystore: BIP32Keystore, accessLevel: Keystore.NetworkAccess) async throws {
        guard let model = keystore.keystoreParams else {
            fatalError("Failed to build wallet")
        }
        guard KeyChain().store(wallet: keystore) else {
            return
        }

        guard let address = model.pathAddressPairs.compactMap({ EthereumAddress($0.address) != nil ? $0 : nil }).first else {
            return
        }

        try await moc.perform {

            let newWallet = Keystore(context: self.moc)
            newWallet.isHDWallet = model.isHDWallet
            newWallet.version = Int16(model.version)
            newWallet.id = model.id
            newWallet.rootPath = model.rootPath
            newWallet.access = accessLevel.rawValue

            let newCrypto = CryptoParams(context: self.moc)
            newCrypto.ciphertext = model.crypto.ciphertext
            newCrypto.cipher = model.crypto.cipher
            newCrypto.kdf = model.crypto.kdf
            newCrypto.mac = model.crypto.mac
            newCrypto.version = model.crypto.version
            newCrypto.keystore = newWallet

            let cipherparams = model.crypto.cipherparams
            let kdfparams = model.crypto.kdfparams

            let newCipher = CipherParams(context: self.moc)
            newCipher.crypto = newCrypto
            newCipher.iv = cipherparams.iv

            let newKDFParams = KdfParams(context: self.moc)
            newKDFParams.crypto = newCrypto
            newKDFParams.c = Int64(kdfparams.c ?? 0)
            newKDFParams.dklen = Int64(kdfparams.dklen)
            newKDFParams.n = Int64(kdfparams.n ?? 0)
            newKDFParams.p = Int64(kdfparams.p ?? 0)
            newKDFParams.prf = kdfparams.prf
            newKDFParams.r = Int64(kdfparams.r ?? 0)
            newKDFParams.salt = kdfparams.salt

            let newAddress = Address(context: self.moc)
            newAddress.address = address.address
            newAddress.path = address.path
            newAddress.keystore = newWallet

            try self.moc.save()
        }
        // TODO: save seedPhrase to icloud
    }

    func fetchWallets() async {
        await moc.perform {
            do {
                //        fetchRequest.predicate
                //        fetchRequest.sortDescriptors
                let directKeystores = try self.fetchRequest.execute()
                DispatchQueue.main.async {
                    self.wallets = directKeystores
                    if directKeystores.isEmpty {
                        self.wallet = nil
                    }
                }
            } catch {
                print(error)
            }
        }
    }

    func deleteKeystores(at offsets: IndexSet) {
        Task {
            await moc.perform {
                offsets.forEach { offset in
                    guard let keyStore = self.wallets?[offset] else {
                        return
                    }
                    self.moc.delete(keyStore)
                }

                try? self.moc.save()
            }

            await fetchWallets()
            if wallets?.isEmpty ?? true {
                wallet = nil
            }
        }
    }
}
