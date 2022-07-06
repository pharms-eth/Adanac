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

    @Published var wallet: WalletKeyStoreAccess?
    @Published var currentWallet: AbstractKeystoreParams?
    @Published var showingCreatePopover = false
    @Published var showingImportPopover = false
    @Published var showingWalletConnectPopover = false

    private var cancellables: [AnyCancellable] = []
    let moc = WalletDataController().container.viewContext


    @Published var wallets: [Keystore]?
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

    func setCurrent(keystore: Keystore) {

        let keystoreVersion = keystore.version

        guard let keystoreID = keystore.id,
              let keystoreCrypto = keystore.crypto,
              let keystoreCipher = keystore.crypto?.cipherparams,
              let keystoreKdf = keystore.crypto?.kdfparams else {
            return
        }

        let kdf = KdfParamsV3(salt: keystoreKdf.salt ?? "",
                              dklen: Int(keystoreKdf.dklen),
                              n: Int(keystoreKdf.n),
                              p: Int(keystoreKdf.p),
                              r: Int(keystoreKdf.r),
                              c: Int(keystoreKdf.c),
                              prf: keystoreKdf.prf)

        let crypto = CryptoParamsV3(ciphertext: keystoreCrypto.ciphertext ?? "",
                                    cipher: keystoreCrypto.cipher ?? "",
                                    cipherparams: CipherParamsV3(iv: keystoreCipher.iv ?? ""),
                                    kdf: keystoreCrypto.kdf ?? "",
                                    kdfparams: kdf,
                                    mac: keystoreCrypto.mac ?? "",
                                    version: keystoreCrypto.version)

        if keystore.isHDWallet {
            var crrnt = KeystoreParamsBIP32(crypto: crypto, id: keystoreID, version: Int(keystoreVersion), rootPath: keystore.rootPath)

            let addressValues: [PathAddressPair] = keystore.addressArray.compactMap {
                guard let path = $0.path, let address = $0.address else { return nil }
                return PathAddressPair(path: path, address: address)
            }
            crrnt.pathAddressPairs = addressValues

            self.currentWallet = crrnt

        } else {
            let addressValue: Address? = keystore.addressArray.first(where: { $0.address != nil })

            let crrnt = KeystoreParamsV3(address: addressValue?.address, crypto: crypto, id: keystoreID, version: Int(keystoreVersion))
            self.currentWallet = crrnt
        }
        
    }

    func bulkLoadTest() {
        let keyStrings = ["0x57757e3d981446d585af0d9ae4d7df6d64647806", "0xa9D60735AB0901F84F5D04b465FA2F1a6d0Aa7Ee", "0x853B811892B8107860E8b71e670a83C462B4A507", "0x84D34f4f83a87596Cd3FB6887cFf8F17Bf5A7B83", "0x1Db3439a222C519ab44bb1144fC28167b4Fa6EE6", "0x179456bf16752FE5Eb8789148E5C98Eb39D87Fe5", "0xca436e14855323927d6e6264470ded36455fc8bd", "0x220866b1a2219f40e72f5c628b65d54268ca3a9d", "0xc5ed2333f8a2C351fCA35E5EBAdb2A82F5d254C3", "0x068B65394EBB0e19DFF45880729C77fAAF3b5195", "0xf74344E4C2Dfdc9aB5DDF6E95379c7119e2bBc56", "0x853B811892B8107860E8b71e670a83C462B4A507", "0x1BC80b413562Bc3362f7e8d7431255d5D18441a7"]

        let ethAddr = keyStrings.compactMap { EthereumAddress($0) }
        let keyStores = ethAddr.compactMap { PublicKeyStore(addresses: [$0], isHDKeystore: false, ensDomain: nil) }

        let store = keyStores.randomElement()!
        Task {
            try? await save(keystore: store, accessLevel: .readOnly)
        }

//        keyStores.forEach { store in
//            try? save(keystore: store, accessLevel: .readOnly)
//        }

//        return .readOnly()

        
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
