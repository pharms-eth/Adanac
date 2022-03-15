//
//  HDWalletKeyStore.swift
//  Adanac
//
//  Created by Daniel Bell on 3/9/22.
//

import Foundation
import web3swift
import CryptoSwift

struct HDWalletNode {
    public static var defaultPathMetamaskPrefix: String = "m/44'/60'/0'/0"
}

class HDWalletKeyStore {
    //TODO: rewrite components
    private (set) var addressStorage = PathAddressStorage()
    public var rootPrefix: String = HDWalletNode.defaultPathMetamaskPrefix
    public var keystoreParams: KeystoreParamsBIP32?
    private static let KeystoreParamsBIP32Version = 4

    init(mnemonics: [String], password: String, language: BIP39Language = .english) throws {

        //TODO: rewrite components
        guard var seed = seedFromMmemonics(mnemonics, password: "", language: language) else {
            throw AbstractKeystoreError.noEntropyError
        }
        //TODO: rewrite components
        defer{
            Data.zero(&seed)
        }
        //TODO: rewrite components
        guard let rootNode = HDNode(seed: seed)?.derive(path: rootPrefix, derivePrivateKey: true) else {
            throw AbstractKeystoreError.noEntropyError
        }

        //TODO: rewrite components
        try createNewAccount(parentNode: rootNode, password: password)

        //TODO: rewrite components
        guard let serializedRootNode = rootNode.serialize(serializePublic: false) else {
            throw AbstractKeystoreError.keyDerivationError
        }

        //TODO: rewrite components
        try encryptDataToStorage(password, data: serializedRootNode, aesMode: "aes-128-cbc")
    }

    //TODO: rewrite components
    func createNewAccount(parentNode: HDNode, password: String = "web3swift") throws {
        var newIndex = UInt32(0)
        for p in addressStorage.paths {
            guard let idx = UInt32(p.components(separatedBy: "/").last!) else {continue}
            if idx >= newIndex {
                newIndex = idx + 1
            }
        }
        guard let newNode = parentNode.derive(index: newIndex, derivePrivateKey: true, hardened: false) else {
            throw AbstractKeystoreError.keyDerivationError
        }
        guard let newAddress = Web3.Utils.publicToAddress(newNode.publicKey) else {
            throw AbstractKeystoreError.keyDerivationError
        }
        let prefixPath = self.rootPrefix
        var newPath: String
        if newNode.isHardened {
            newPath = prefixPath + "/" + String(newNode.index % HDNode.hardenedIndexPrefix) + "'"
        } else {
            newPath = prefixPath + "/" + String(newNode.index)
        }
        addressStorage.add(address: newAddress, for: newPath)
    }

    //TODO: rewrite components
    fileprivate func encryptDataToStorage(_ password: String, data: Data?, dkLen: Int = 32, N: Int = 4096, R: Int = 6, P: Int = 1, aesMode: String = "aes-128-cbc") throws {
        if (data == nil) {
            throw AbstractKeystoreError.encryptionError("Encryption without key data")
        }
        if (data!.count != 82) {
            throw AbstractKeystoreError.encryptionError("Invalid expected data length")
        }
        let saltLen = 32;
        guard let saltData = Data.randomBytes(length: saltLen) else {
            throw AbstractKeystoreError.noEntropyError
        }
        guard let derivedKey = scrypt(password: password, salt: saltData, length: dkLen, N: N, R: R, P: P) else {
            throw AbstractKeystoreError.keyDerivationError
        }
        let last16bytes = derivedKey[(derivedKey.count - 16)...(derivedKey.count - 1)]
        let encryptionKey = derivedKey[0...15]
        guard let IV = Data.randomBytes(length: 16) else {
            throw AbstractKeystoreError.noEntropyError
        }
        var aesCipher: AES?
        switch aesMode {
        case "aes-128-cbc":
            aesCipher = try? AES(key: encryptionKey.bytes, blockMode: CBC(iv: IV.bytes), padding: .pkcs7)
        case "aes-128-ctr":
            aesCipher = try? AES(key: encryptionKey.bytes, blockMode: CTR(iv: IV.bytes), padding: .pkcs7)
        default:
            aesCipher = nil
        }
        if aesCipher == nil {
            throw AbstractKeystoreError.aesError
        }
        guard let encryptedKey = try aesCipher?.encrypt(data!.bytes) else {
            throw AbstractKeystoreError.aesError
        }


        let encryptedKeyData = Data(encryptedKey)
        var dataForMAC = Data()
        dataForMAC.append(last16bytes)
        dataForMAC.append(encryptedKeyData)
        let mac = dataForMAC.sha3(.keccak256)

        let kdfparams = KdfParamsV3(salt: saltData.toHexString(), dklen: dkLen, n: N, p: P, r: R, c: nil, prf: nil)
        let cipherparams = CipherParamsV3(iv: IV.toHexString())

        let crypto = CryptoParamsV3(ciphertext: encryptedKeyData.toHexString(), cipher: aesMode, cipherparams: cipherparams, kdf: "scrypt", kdfparams: kdfparams, mac: mac.toHexString(), version: nil)


        var keystorePars = KeystoreParamsBIP32(crypto: crypto, id: UUID().uuidString.lowercased(), version: Self.KeystoreParamsBIP32Version)
        keystorePars.pathAddressPairs = addressStorage.toPathAddressPairs()
        keystorePars.rootPath = self.rootPrefix
        keystoreParams = keystorePars
    }

    func scrypt (password: String, salt: Data, length: Int, N: Int, R: Int, P: Int) -> Data? {
        guard let passwordData = password.data(using: .utf8) else {return nil}
        guard let deriver = try? Scrypt(password: passwordData.bytes, salt: salt.bytes, dkLen: length, N: N, r: R, p: P) else {return nil}
        guard let result = try? deriver.calculate() else {return nil}
        return Data(result)
    }

    func seedFromMmemonics(_ mnemonics: [String], password: String, language: BIP39Language = BIP39Language.english) -> Data? {
        guard mnemonicsToEntropy(mnemonics: mnemonics, language: language) != nil else {
            return nil
        }

        guard let mnemData = mnemonics.joined(separator: language.separator).data(using: .utf8) else {return nil}
        guard let saltData = ("mnemonic" + password).decomposedStringWithCompatibilityMapping.data(using: .utf8) else {return nil}
        guard let seedArray = try? PKCS5.PBKDF2(password: mnemData.bytes, salt: saltData.bytes, iterations: 2048, keyLength: 64, variant: HMAC.Variant.sha2(.sha512)).calculate() else {return nil}
        return Data(seedArray)
    }

    public func mnemonicsToEntropy(mnemonics wordList: [String], language: BIP39Language = BIP39Language.english) -> Data? {

        guard wordList.count == 12 else {return nil}

        let bitString = wordList.reduce(into: "") { partialResult, word in
            guard let idx = language.words.firstIndex(of: word) else {
                return
            }

            let stringForm = String(idx, radix: 2).leftPadding(toLength: 11, withPad: "0")

            partialResult.append(stringForm)
        }

        let stringCount = bitString.count
        if !stringCount.isMultiple(of: 33) {
            return nil
        }
        let entropyBits = bitString[0 ..< (bitString.count - bitString.count/33)]
        let checksumBits = bitString[(bitString.count - bitString.count/33) ..< bitString.count]
        guard let entropy = entropyBits.interpretAsBinaryData() else {
            return nil
        }
        let checksum = String(entropy.sha256().bitsInRange(0, checksumBits.count)!, radix: 2).leftPadding(toLength: checksumBits.count, withPad: "0")
        if checksum != checksumBits {
            return nil
        }
        return entropy
    }



}


//random number, also referred to as entropy.
//    multiples of 32 bits, between 128 and 256.
//The larger the entropy, the more mnemonic words generated, and the greater the security of your wallets.
//128-bit entropy expect to derive 12 mnemonic words
//each 32 bits beyond 128 adds three more mnemonic words to the sentence

