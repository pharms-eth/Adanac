//
//  EthAddress.swift
//  Adanac
//
//  Created by Daniel Bell on 3/11/22.
//

import Foundation

public struct EthAddress: Codable {

    var _address: String = ""
    var path: String = ""
    public var address:String {
        return EthAddress.toChecksumAddress(_address)
    }

    public static func toChecksumAddress(_ addr:String) -> String {
        let address = addr.lowercased().stripHexPrefix()
        guard let hash = address.data(using: .ascii)?.sha3(.keccak256).toHexString().stripHexPrefix() else {return "0x"}

        return address.enumerated().reduce("0x") { partialResult, value in
            let startIdx = hash.index(hash.startIndex, offsetBy: value.offset)
            let endIdx = hash.index(hash.startIndex, offsetBy: value.offset+1)
            let hashChar = String(hash[startIdx..<endIdx])
            let c = String(value.element)
            guard let int = Int(hashChar, radix: 16) else {
                return "0x"
            }
            return partialResult + (int >= 8 ? c.uppercased() : c )
        }
    }

    public init(_ addressString:String, path: String?) {
        guard let data = Data.fromHex(addressString) else {return}
        guard data.count == 20 else {return}
        if !addressString.hasHexPrefix() {
            return
        }
        let hexDataString = data.toHexString()
        // check for checksum
        if let adrPath = path {
            self.path = adrPath
        }
        if hexDataString == addressString.stripHexPrefix() || hexDataString.uppercased() == addressString.stripHexPrefix(){
            _address = hexDataString.addHexPrefix()
        } else {
            let checksummedAddress = EthAddress.toChecksumAddress(hexDataString.addHexPrefix())
            guard checksummedAddress == addressString else {return}
            _address = hexDataString.addHexPrefix()
        }

    }

    public init(_ addressData:Data) {
        guard addressData.count == 20 else {return}
        _address = addressData.toHexString().addHexPrefix().lowercased()
    }

}
