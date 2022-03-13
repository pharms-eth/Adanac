//
//  HDTreeNode.swift
//  Adanac
//
//  Created by Daniel Bell on 3/11/22.
//

import Foundation
import CryptoSwift
import BigInt
import web3swift
import secp256k1

struct HDTreeNode {

    public struct HDversion{
        public var privatePrefix: Data = Data.fromHex("0x0488ADE4")!
        public var publicPrefix: Data = Data.fromHex("0x0488B21E")!
        public init() {

        }
    }

    public static var curveOrder = BigUInt("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141", radix: 16)!
    public static var hardenedIndexPrefix: UInt32 = (UInt32(1) << 31)
    public var path: String? = "m"
    public var privateKey: Data? = nil
    public var publicKey: Data
    public var chaincode: Data
    public var depth: UInt8
    public var parentFingerprint: Data = Data(repeating: 0, count: 4)
    public var childNumber: UInt32 = UInt32(0)
    public var isHardened:Bool {
        get {
            return self.childNumber >= (UInt32(1) << 31)
        }
    }
    public var index: UInt32 {
        get {
            if self.isHardened {
                return self.childNumber - (UInt32(1) << 31)
            } else {
                return self.childNumber
            }
        }
    }
    public var hasPrivate:Bool {
        get {
            return privateKey != nil
        }
    }

    init() {
        publicKey = Data()
        chaincode = Data()
        depth = UInt8(0)
    }

    public init(seed: Data) throws {
        guard seed.count >= 16 else {
            throw KeystoreError.noEntropyError
        }
        let hmacKey = "Bitcoin seed".data(using: .ascii)!
        let hmac:Authenticator = HMAC(key: hmacKey.bytes, variant: HMAC.Variant.sha512)
        guard let entropy = try? hmac.authenticate(seed.bytes) else {
            throw KeystoreError.noEntropyError
        }
        guard entropy.count == 64 else {
            throw KeystoreError.noEntropyError
        }
        let I_L = entropy[0..<32]
        let I_R = entropy[32..<64]
        chaincode = Data(I_R)
        let privKeyCandidate = Data(I_L)
        guard PrivateKey.verifyPrivateKey(privateKey: privKeyCandidate) else {
            throw KeystoreError.invalidAccountError
        }
        guard let pubKeyCandidate = PrivateKey.privateToPublic(privateKey: privKeyCandidate, compressed: true) else {
            throw KeystoreError.invalidAccountError
        }
        guard pubKeyCandidate.bytes[0] == 0x02 || pubKeyCandidate.bytes[0] == 0x03 else {
            throw KeystoreError.invalidAccountError
        }
        publicKey = pubKeyCandidate
        privateKey = privKeyCandidate
        depth = 0x00
        childNumber = UInt32(0)
    }
    public func derive(path: String, derivePrivateKey: Bool = true) -> HDTreeNode? {
        let components = path.components(separatedBy: "/")
        var currentNode:HDTreeNode = self
        var firstComponent = 0
        if path.hasPrefix("m") {
            firstComponent = 1
        }
        for component in components[firstComponent ..< components.count] {
            var hardened = false
            if component.hasSuffix("'") {
                hardened = true
            }
            guard let index = UInt32(component.trimmingCharacters(in: CharacterSet(charactersIn: "'"))) else {return nil}
            guard let newNode = currentNode.derive(index: index, derivePrivateKey: derivePrivateKey, hardened: hardened) else {return nil}
            currentNode = newNode
        }
        return currentNode
    }

    public func derive(index: UInt32, derivePrivateKey:Bool, hardened: Bool = false) -> HDTreeNode? {
        if derivePrivateKey {
            if self.hasPrivate { // derive private key when is itself extended private key
                var entropy:Array<UInt8>
                var trueIndex: UInt32
                if index >= (UInt32(1) << 31) || hardened {
                    trueIndex = index;
                    if trueIndex < (UInt32(1) << 31) {
                        trueIndex = trueIndex + (UInt32(1) << 31)
                    }
                    let hmac:Authenticator = HMAC(key: self.chaincode.bytes, variant: .sha512)
                    var inputForHMAC = Data()
                    inputForHMAC.append(Data([UInt8(0x00)]))
                    inputForHMAC.append(self.privateKey!)
                    inputForHMAC.append(trueIndex.serialize32())
                    guard let ent = try? hmac.authenticate(inputForHMAC.bytes) else {return nil }
                    guard ent.count == 64 else { return nil }
                    entropy = ent
                } else {
                    trueIndex = index
                    let hmac:Authenticator = HMAC(key: self.chaincode.bytes, variant: .sha512)
                    var inputForHMAC = Data()
                    inputForHMAC.append(self.publicKey)
                    inputForHMAC.append(trueIndex.serialize32())
                    guard let ent = try? hmac.authenticate(inputForHMAC.bytes) else {return nil }
                    guard ent.count == 64 else { return nil }
                    entropy = ent
                }
                let I_L = entropy[0..<32]
                let I_R = entropy[32..<64]
                let cc = Data(I_R)
                let bn = BigUInt(Data(I_L))
                if bn > HDTreeNode.curveOrder {
                    if trueIndex < UInt32.max {
                        return self.derive(index:index+1, derivePrivateKey: derivePrivateKey, hardened:hardened)
                    }
                    return nil
                }
                let newPK = (bn + BigUInt(self.privateKey!)) % HDTreeNode.curveOrder
                if newPK == BigUInt(0) {
                    if trueIndex < UInt32.max {
                        return self.derive(index:index+1, derivePrivateKey: derivePrivateKey, hardened:hardened)
                    }
                    return nil
                }
                guard let privKeyCandidate = newPK.serialize().setLengthLeft(32) else {return nil}
                guard PrivateKey.verifyPrivateKey(privateKey: privKeyCandidate) else {return nil }
                guard let pubKeyCandidate = PrivateKey.privateToPublic(privateKey: privKeyCandidate, compressed: true) else {return nil}
                guard pubKeyCandidate.bytes[0] == 0x02 || pubKeyCandidate.bytes[0] == 0x03 else {return nil}
                guard self.depth < UInt8.max else {return nil}
                var newNode = HDTreeNode()
                newNode.chaincode = cc
                newNode.depth = self.depth + 1
                newNode.publicKey = pubKeyCandidate
                newNode.privateKey = privKeyCandidate
                newNode.childNumber = trueIndex
                guard let fprint = try? RIPEMD160.hash(message: self.publicKey.sha256())[0..<4] else {
                    return nil
                }
                newNode.parentFingerprint = fprint
                var newPath = String()
                if newNode.isHardened {
                    newPath = self.path! + "/"
                    newPath += String(newNode.index % HDTreeNode.hardenedIndexPrefix) + "'"
                } else {
                    newPath = self.path! + "/" + String(newNode.index)
                }
                newNode.path = newPath
                return newNode
            } else {
                return nil // derive private key when is itself extended public key (impossible)
            }
        }
        else { // deriving only the public key
            var entropy:Array<UInt8> // derive public key when is itself public key
            if index >= (UInt32(1) << 31) || hardened {
                return nil // no derivation of hardened public key from extended public key
            } else {
                let hmac:Authenticator = HMAC(key: self.chaincode.bytes, variant: .sha512)
                var inputForHMAC = Data()
                inputForHMAC.append(self.publicKey)
                inputForHMAC.append(index.serialize32())
                guard let ent = try? hmac.authenticate(inputForHMAC.bytes) else {return nil }
                guard ent.count == 64 else { return nil }
                entropy = ent
            }
            let I_L = entropy[0..<32]
            let I_R = entropy[32..<64]
            let cc = Data(I_R)
            let bn = BigUInt(Data(I_L))
            if bn > HDTreeNode.curveOrder {
                if index < UInt32.max {
                    return self.derive(index:index+1, derivePrivateKey: derivePrivateKey, hardened:hardened)
                }
                return nil
            }
            guard let tempKey = bn.serialize().setLengthLeft(32) else {return nil}
            guard PrivateKey.verifyPrivateKey(privateKey: tempKey) else {return nil }
            guard let pubKeyCandidate = PrivateKey.privateToPublic(privateKey: tempKey, compressed: true) else {return nil}
            guard pubKeyCandidate.bytes[0] == 0x02 || pubKeyCandidate.bytes[0] == 0x03 else {return nil}
            guard let newPublicKey = PrivateKey.combineSerializedPublicKeys(keys: [self.publicKey, pubKeyCandidate], outputCompressed: true) else {return nil}
            guard newPublicKey.bytes[0] == 0x02 || newPublicKey.bytes[0] == 0x03 else {return nil}
            guard self.depth < UInt8.max else {return nil}
            var newNode = HDTreeNode()
            newNode.chaincode = cc
            newNode.depth = self.depth + 1
            newNode.publicKey = newPublicKey
            newNode.childNumber = index
            guard let fprint = try? RIPEMD160.hash(message: self.publicKey.sha256())[0..<4] else {
                return nil
            }
            newNode.parentFingerprint = fprint
            var newPath = String()
            if newNode.isHardened {
                newPath = self.path! + "/"
                newPath += String(newNode.index % HDTreeNode.hardenedIndexPrefix) + "'"
            } else {
                newPath = self.path! + "/" + String(newNode.index)
            }
            newNode.path = newPath
            return newNode
        }
    }

    public func serialize(serializePublic: Bool = true, version: HDversion = HDversion()) -> Data? {
        var data = Data()
        if (!serializePublic && !self.hasPrivate) {return nil}
        if serializePublic {
            data.append(version.publicPrefix)
        } else {
            data.append(version.privatePrefix)
        }
        data.append(contentsOf: [self.depth])
        data.append(self.parentFingerprint)
        data.append(self.childNumber.serialize32())
        data.append(self.chaincode)
        if serializePublic {
            data.append(self.publicKey)
        } else {
            data.append(contentsOf: [0x00])
            data.append(self.privateKey!)
        }
        let hashedData = data.sha256().sha256()
        let checksum = hashedData[0..<4]
        data.append(checksum)
        return data
    }
}


struct PrivateKey {
    static let context = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_SIGN|SECP256K1_CONTEXT_VERIFY))


    public static func verifyPrivateKey(privateKey: Data) -> Bool {
        if (privateKey.count != 32) {return false}

        var seckey = privateKey.bytes
        let result = secp256k1_ec_seckey_verify(context!, &seckey)

        return result == 1
    }




    public static func privateToPublic(privateKey: Data, compressed: Bool = false) -> Data? {
        if (privateKey.count != 32) {return nil}
        guard var publicKey = privateKeyToPublicKey(privateKey: privateKey) else {return nil}
        guard let serializedKey = serializePublicKey(publicKey: &publicKey, compressed: compressed) else {return nil}
        return serializedKey
    }

    private static func privateKeyToPublicKey(privateKey: Data) -> secp256k1_pubkey? {
        if (privateKey.count != 32) {return nil}
        var publicKey = secp256k1_pubkey()
        let result = privateKey.withUnsafeBytes { (pkRawBufferPointer: UnsafeRawBufferPointer) -> Int32? in
            if let pkRawPointer = pkRawBufferPointer.baseAddress, pkRawBufferPointer.count > 0 {
                let privateKeyPointer = pkRawPointer.assumingMemoryBound(to: UInt8.self)
                let res = secp256k1_ec_pubkey_create(context!, UnsafeMutablePointer<secp256k1_pubkey>(&publicKey), privateKeyPointer)
                return res
            } else {
                return nil
            }
        }
        guard let res = result, res != 0 else {
            return nil
        }
        return publicKey
    }

    private static func serializePublicKey(publicKey: inout secp256k1_pubkey, compressed: Bool = false) -> Data? {
        var keyLength = compressed ? 33 : 65
        var serializedPubkey = Data(repeating: 0x00, count: keyLength)
        let result = serializedPubkey.withUnsafeMutableBytes { (serializedPubkeyRawBuffPointer) -> Int32? in
            if let serializedPkRawPointer = serializedPubkeyRawBuffPointer.baseAddress, serializedPubkeyRawBuffPointer.count > 0 {
                let serializedPubkeyPointer = serializedPkRawPointer.assumingMemoryBound(to: UInt8.self)
                return withUnsafeMutablePointer(to: &keyLength, { (keyPtr:UnsafeMutablePointer<Int>) -> Int32 in
                    withUnsafeMutablePointer(to: &publicKey, { (pubKeyPtr:UnsafeMutablePointer<secp256k1_pubkey>) -> Int32 in
                        let res = secp256k1_ec_pubkey_serialize(context!,
                                                                serializedPubkeyPointer,
                                                                keyPtr,
                                                                pubKeyPtr,
                                                                UInt32(compressed ? SECP256K1_EC_COMPRESSED : SECP256K1_EC_UNCOMPRESSED))
                        return res
                    })
                })
            } else {
                return nil
            }
        }
        guard let res = result, res != 0 else {
            return nil
        }
        return Data(serializedPubkey)
    }


    public static func combineSerializedPublicKeys(keys: [Data], outputCompressed: Bool = false) -> Data? {
        let numToCombine = keys.count
        guard numToCombine >= 1 else { return nil}
        var storage = ContiguousArray<secp256k1_pubkey>()
        let arrayOfPointers = UnsafeMutablePointer< UnsafePointer<secp256k1_pubkey>? >.allocate(capacity: numToCombine)
        defer {
            arrayOfPointers.deinitialize(count: numToCombine)
            arrayOfPointers.deallocate()
        }
        for i in 0 ..< numToCombine {
            let key = keys[i]
            guard let pubkey = parsePublicKey(serializedKey: key) else {return nil}
            storage.append(pubkey)
        }
        for i in 0 ..< numToCombine {
            withUnsafePointer(to: &storage[i]) { (ptr) -> Void in
                arrayOfPointers.advanced(by: i).pointee = ptr
            }
        }
        let immutablePointer = UnsafePointer(arrayOfPointers)
        var publicKey: secp256k1_pubkey = secp256k1_pubkey()
        let result = withUnsafeMutablePointer(to: &publicKey) { (pubKeyPtr: UnsafeMutablePointer<secp256k1_pubkey>) -> Int32 in
            let res = secp256k1_ec_pubkey_combine(context!, pubKeyPtr, immutablePointer, numToCombine)
            return res
        }
        if result == 0 {
            return nil
        }
        let serializedKey = serializePublicKey(publicKey: &publicKey, compressed: outputCompressed)
        return serializedKey
    }

    private static func parsePublicKey(serializedKey: Data) -> secp256k1_pubkey? {
        guard serializedKey.count == 33 || serializedKey.count == 65 else {
            return nil
        }
        let keyLen: Int = Int(serializedKey.count)
        var publicKey = secp256k1_pubkey()
        let result = serializedKey.withUnsafeBytes { (serializedKeyRawBufferPointer: UnsafeRawBufferPointer) -> Int32? in
            if let serializedKeyRawPointer = serializedKeyRawBufferPointer.baseAddress, serializedKeyRawBufferPointer.count > 0 {
                let serializedKeyPointer = serializedKeyRawPointer.assumingMemoryBound(to: UInt8.self)
                let res = secp256k1_ec_pubkey_parse(context!, UnsafeMutablePointer<secp256k1_pubkey>(&publicKey), serializedKeyPointer, keyLen)
                return res
            } else {
                return nil
            }
        }
        guard let res = result, res != 0 else {
            return nil
        }
        return publicKey
    }
}
