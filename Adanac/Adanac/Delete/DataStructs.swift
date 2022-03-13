////
////  DataStructs.swift
////  Adanac
////
////  Created by Daniel Bell on 3/11/22.
////
//
//import Foundation
//
//public struct CryptoParams: Codable {
//    public var ciphertext: String
//    public var cipher: String
//    public var cipherparams: CipherParams
//    public var kdf: String
//    public var kdfparams: KdfParams
//    public var mac: String
//    public var version: String?
//}
//
//public struct BIP32KeystoreParams: Codable {
//    public var crypto: CryptoParams
//    public var id: String?
//    public var version: Int = 32
//    public var isHDWallet: Bool = true
//    public var addresses: [String] = []
//    public var rootPath: String? = nil
//}
//
//struct ETHDataWallet {
//    var address: String
//    var data: BIP32KeystoreParams
//    var name: String
//    var isHD: Bool
//}
//
//public enum KeystoreError: Error {
//    case noEntropyError
//    case keyDerivationError
//    case aesError
//    case invalidAccountError
//    case invalidPasswordError
//    case encryptionError(String)
//}
//
//public struct CipherParams: Codable {
//    public var iv: String
//}
//
//public struct KdfParams: Codable {
//    public var salt: String
//    public var dklen: Int
//    public var n: Int?
//    public var p: Int?
//    public var r: Int?
//    public var c: Int?
//    public var prf: String?
//}
