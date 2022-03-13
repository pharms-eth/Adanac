//
//  PublicKey.swift
//  Adanac
//
//  Created by Daniel Bell on 3/11/22.
//

import Foundation

//import CryptoSwift
//import BigInt

import web3swift

struct PublicKey {
    var publicKeyRaw: Data
    init(_ publicKey: Data) {
        publicKeyRaw = publicKey
    }

    public func address() -> EthAddress? {
        guard let addressData = publicToAddressData(publicKeyRaw) else {return nil}
        return EthAddress(addressData)
    }

    public func publicToAddressData(_ publicKey: Data) -> Data? {
        if publicKey.count == 33 {
            guard let decompressedKey = SECP256K1.combineSerializedPublicKeys(keys: [publicKey], outputCompressed: false) else {return nil}
            return publicToAddressData(decompressedKey)
        }
        var stipped = publicKey
        if (stipped.count == 65) {
            if (stipped[0] != 4) {
                return nil
            }
            stipped = stipped[1...64]
        }
        if (stipped.count != 64) {
            return nil
        }
        let sha3 = stipped.sha3(.keccak256)
        return sha3[12...31]
    }
}
