//
//  BIP39Key.swift
//  Adanac
//
//  Created by Daniel Bell on 3/11/22.
//

import Foundation
import CryptoSwift
import BigInt

public class ETHWallet {
    public static var curveOrder = BigUInt("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141", radix: 16)!
    public static var defaultPath: String = "m/44'/60'/0'/0"
    public static var defaultPathPrefix: String = "m/44'/60'/0'"
    public static var defaultPathMetamask: String = "m/44'/60'/0'/0/0"
//    public static var defaultPathMetamaskPrefix: String = "m/44'/60'/0'/0"
    public static var hardenedIndexPrefix: UInt32 = (UInt32(1) << 31)

    private static let KeystoreParamsBIP32Version = 4
    public private(set) var addresses: [EthAddress] = []
    public var isHDKeystore: Bool = true
    public var keystoreParams: BIP32KeystoreParams?
    public var rootPrefix: String

    public init(_ keystorePars: BIP32KeystoreParams) throws {
        if (keystorePars.version != Self.KeystoreParamsBIP32Version) {throw KeystoreError.noEntropyError}
        if (keystorePars.crypto.version != nil && keystorePars.crypto.version != "1") {throw KeystoreError.noEntropyError}
        if (!keystorePars.isHDWallet) {throw KeystoreError.noEntropyError}
        self.addresses = keystorePars.addresses

        keystoreParams = keystorePars
        if keystoreParams?.rootPath == nil {
            keystoreParams?.rootPath = Self.defaultPathPrefix
        }

        rootPrefix = keystorePars.rootPath ?? Self.defaultPathPrefix
    }

    public convenience init(mnemonics: [String], password: String, mnemonicsPassword: String, prefixPath: String = ETHWallet.defaultPath) throws {
        guard var seed = Entropy().getSeed(from: mnemonics) else {
            throw KeystoreError.noEntropyError
        }
        defer{
            Data.zero(&seed)
        }
        try self.init(seed: seed, password: password, prefixPath: prefixPath)
    }

    public init(seed: Data, password: String, prefixPath: String = ETHWallet.defaultPath) throws {
        guard let rootNode = try? HDTreeNode(seed: seed).derive(path: prefixPath, derivePrivateKey: true) else {
            throw KeystoreError.invalidAccountError
        }
        rootPrefix = prefixPath
        try createNewAccount(parentNode: rootNode, password: password)
        guard let serializedRootNode = rootNode.serialize(serializePublic: false) else {
            throw KeystoreError.keyDerivationError
        }
        try encryptDataToStorage(password, data: serializedRootNode)
    }

    func createNewAccount(parentNode: HDTreeNode, password: String) throws {
        var newIndex = UInt32(0)
        for p in addresses {
            guard let value = p.path.components(separatedBy: "/").last, let idx = UInt32(value) else {continue}
            if idx >= newIndex {
                newIndex = idx + 1
            }
        }
        guard let newNode = parentNode.derive(index: newIndex, derivePrivateKey: true, hardened: false) else {
            throw KeystoreError.keyDerivationError
        }
        guard let newAddress = PublicKey(newNode.publicKey).address() else {
            throw KeystoreError.keyDerivationError
        }

        var newPath: String
        if newNode.isHardened {
            newPath = rootPrefix + "/" + String(newNode.index % Self.hardenedIndexPrefix) + "'"
        } else {
            newPath = rootPrefix + "/" + String(newNode.index)
        }
        addresses.append(EthAddress(newAddress.address, path: newPath))
    }

    fileprivate func encryptDataToStorage(_ password: String, data: Data, dkLen: Int = 32, N: Int = 4096, R: Int = 6, P: Int = 1) throws {
        guard data.count == 82 else {
            throw KeystoreError.encryptionError("Invalid expected data length")
        }

        guard let saltData = Data.randomBytes(length: 32) else {
            throw KeystoreError.noEntropyError
        }
        guard let derivedKey = scrypt(password: password, salt: saltData, length: dkLen, N: N, R: R, P: P) else {
            throw KeystoreError.keyDerivationError
        }
        let last16bytes = derivedKey[(derivedKey.count - 16)...(derivedKey.count - 1)]
        let encryptionKey = derivedKey[0...15]
        guard let IV = Data.randomBytes(length: 16) else {
            throw KeystoreError.noEntropyError
        }

        let encryptedKey = try AES(key: encryptionKey.bytes, blockMode: CBC(iv: IV.bytes), padding: .pkcs7).encrypt(data.bytes)

        let encryptedKeyData = Data(encryptedKey)
        var dataForMAC = Data()
        dataForMAC.append(last16bytes)
        dataForMAC.append(encryptedKeyData)
        let mac = dataForMAC.sha3(.keccak256)
        let kdfparams = KdfParams(salt: saltData.toHexString(), dklen: dkLen, n: N, p: P, r: R, c: nil, prf: nil)
        let cipherparams = CipherParams(iv: IV.toHexString())
        let crypto = CryptoParams(ciphertext: encryptedKeyData.toHexString(), cipher: "aes-128-cbc", cipherparams: cipherparams, kdf: "scrypt", kdfparams: kdfparams, mac: mac.toHexString(), version: nil)

        var keystorePars = BIP32KeystoreParams(crypto: crypto, id: UUID().uuidString.lowercased(), version: Self.KeystoreParamsBIP32Version)
        keystorePars.addresses = addresses
        keystorePars.rootPath = self.rootPrefix
        keystoreParams = keystorePars
    }

    func scrypt(password: String, salt: Data, length: Int, N: Int, R: Int, P: Int) -> Data? {
        guard let passwordData = password.data(using: .utf8) else {return nil}
        guard let deriver = try? Scrypt(password: passwordData.bytes, salt: salt.bytes, dkLen: length, N: N, r: R, p: P) else {return nil}
        guard let result = try? deriver.calculate() else {return nil}
        return Data(result)
    }
}


