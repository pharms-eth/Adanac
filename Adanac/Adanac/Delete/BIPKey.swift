//
//  BIPKey.swift
//  Adanac
//
//  Created by Daniel Bell on 3/11/22.
//

import Foundation
import web3swift
import CryptoSwift
import BigInt

class BIPKey {
    public static var defaultETHPath: String = "m/44'/60'/0'/0"
    public static var defaultETHPathPrefix: String = "m/44'/60'/0'"
    public static var defaultETHPathAccount: String = "m/44'/60'/0'/0/0"

    public var parentFingerprint: Data = Data(repeating: 0, count: 4)
    public var path: String? = "m"
    public var privateKey: Data? = nil
    public var publicKey: Data
    public var chaincode: Data
    public var depth: UInt8 = 0x00
    public var childNumber: UInt32 = UInt32(0)
    
    public init(seed: Data, prefixPath: String = BIPKey.defaultETHPath) throws {
        publicKey = Data()
        chaincode = Data()
        node(from: seed)
//        derive(path: prefixPath)

//        guard let serializedRootNode = self.serialize(serializePublic: false) else {
//            throw AbstractKeystoreError.keyDerivationError
//        }
    }

    func node(from seed: Data) {
        guard seed.count >= 16 else {return}
        let hmacKey = "Bitcoin seed".data(using: .ascii)!
        let hmac:Authenticator = HMAC(key: hmacKey.bytes, variant: .sha2(.sha512))
        guard let entropy = try? hmac.authenticate(seed.bytes) else {return}
        guard entropy.count == 64 else { return}
        let I_L = entropy[0..<32]
        let I_R = entropy[32..<64]
        chaincode = Data(I_R)
        let privKeyCandidate = Data(I_L)
        guard SECP256K1.verifyPrivateKey(privateKey: privKeyCandidate) else {return}
        guard let pubKeyCandidate = SECP256K1.privateToPublic(privateKey: privKeyCandidate, compressed: true) else {return}
        guard pubKeyCandidate.bytes[0] == 0x02 || pubKeyCandidate.bytes[0] == 0x03 else {return}
        publicKey = pubKeyCandidate
        privateKey = privKeyCandidate
        depth = 0x00
        childNumber = UInt32(0)
    }

//    public func derive(path: String) {
//        let components = path.components(separatedBy: "/")
//        var firstComponent = 0
//        if path.hasPrefix("m") {
//            firstComponent = 1
//        }
//
//        components[firstComponent ..< components.count].forEach { component in
//            let hardened = component.hasSuffix("'")
//            guard let index = UInt32(component.replacingOccurrences(of: "'", with: "")) else {return}
//            derive(index: index, hardened: hardened)
//        }
//    }
//
//    public func derive (index: UInt32, hardened: Bool = false) {
//        var entropy:Array<UInt8>
//        var trueIndex: UInt32
//        if index >= (UInt32(1) << 31) || hardened {
//            trueIndex = index
//            if trueIndex < (UInt32(1) << 31) {
//                trueIndex = trueIndex + (UInt32(1) << 31)
//            }
//            let hmac:Authenticator = HMAC(key: self.chaincode.bytes, variant: .sha512)
//            var inputForHMAC = Data()
//            inputForHMAC.append(Data([UInt8(0x00)]))
//            inputForHMAC.append(self.privateKey!)
//            inputForHMAC.append(trueIndex.serialize32())
//            guard let ent = try? hmac.authenticate(inputForHMAC.bytes) else {return }
//            guard ent.count == 64 else { return }
//            entropy = ent
//        } else {
//            trueIndex = index
//            let hmac:Authenticator = HMAC(key: self.chaincode.bytes, variant: .sha512)
//            var inputForHMAC = Data()
//            inputForHMAC.append(self.publicKey)
//            inputForHMAC.append(trueIndex.serialize32())
//            guard let ent = try? hmac.authenticate(inputForHMAC.bytes) else {return }
//            guard ent.count == 64 else { return }
//            entropy = ent
//        }
//        let I_L = entropy[0..<32]
//        let I_R = entropy[32..<64]
//        let cc = Data(I_R)
//        let bn = BigUInt(Data(I_L))
//        if bn > HDNode.curveOrder {
//            if trueIndex < UInt32.max {
//                return self.derive(index:index+1, hardened:hardened)
//            }
//            return
//        }
//        let newPK = (bn + BigUInt(self.privateKey!)) % HDNode.curveOrder
//        if newPK == BigUInt(0) {
//            if trueIndex < UInt32.max {
//                return self.derive(index:index+1, hardened:hardened)
//            }
//            return
//        }
//        guard let privKeyCandidate = newPK.serialize().setLengthLeft(32) else {return}
//        guard SECP256K1.verifyPrivateKey(privateKey: privKeyCandidate) else {return}
//        guard let pubKeyCandidate = SECP256K1.privateToPublic(privateKey: privKeyCandidate, compressed: true) else {return}
//        guard pubKeyCandidate.bytes[0] == 0x02 || pubKeyCandidate.bytes[0] == 0x03 else {return}
//        guard self.depth < UInt8.max else {return}
//
//
//
//        chaincode = cc
//        depth = self.depth + 1
//        publicKey = pubKeyCandidate
//        privateKey = privKeyCandidate
//        childNumber = trueIndex
//        guard let fprint = try? RIPEMD160.hash(message: self.publicKey.sha256())[0..<4] else {
//            return
//        }
//        parentFingerprint = fprint
//        var newPath = String()
//        if childNumber >= (UInt32(1) << 31) {
//            newPath = self.path! + "/"
//            newPath += String(index % HDNode.hardenedIndexPrefix) + "'"
//        } else {
//            newPath = self.path! + "/" + String(index)
//        }
//        path = newPath
//    }
//
//    public func serialize(serializePublic: Bool = true, version: HDNode.HDversion = HDNode.HDversion()) -> Data? {
//        var data = Data()
//        if serializePublic {
//            data.append(version.publicPrefix)
//        } else {
//            data.append(version.privatePrefix)
//        }
//        data.append(contentsOf: [self.depth])
//        data.append(self.parentFingerprint)
//        data.append(self.childNumber.serialize32())
//        data.append(self.chaincode)
//        if serializePublic {
//            data.append(self.publicKey)
//        } else {
//            data.append(contentsOf: [0x00])
//            data.append(self.privateKey!)
//        }
//        let hashedData = data.sha256().sha256()
//        let checksum = hashedData[0..<4]
//        data.append(checksum)
//        return data
//    }









    //    public init(seed: Data, password: String, prefixPath: String = HDNode.defaultPathMetamaskPrefix, aesMode: String = "aes-128-cbc") throws {
    //        addressStorage = PathAddressStorage()
    //        self.rootPrefix = prefixPath
    //        try createNewAccount(parentNode: rootNode, password: password)
    //        try encryptDataToStorage(password, data: serializedRootNode, aesMode: aesMode)
    //    }


//    public init(seed: Data, password: String, prefixPath: String = HDNode.defaultPathMetamaskPrefix, aesMode: String = "aes-128-cbc") throws {
////        addressStorage = PathAddressStorage()
//        guard let rootNode = HDNode(seed: seed)?.derive(path: prefixPath, derivePrivateKey: true) else {return nil}
//        self.rootPrefix = prefixPath
//        try createNewAccount(parentNode: rootNode, password: password)
//        guard let serializedRootNode = rootNode.serialize(serializePublic: false) else {
//            throw AbstractKeystoreError.keyDerivationError
//        }
//        try encryptDataToStorage(password, data: serializedRootNode, aesMode: aesMode)
//    }
}
