//
//  CryptoParams+CoreDataProperties.swift
//  Adanac
//
//  Created by Daniel Bell on 6/16/22.
//
//

import Foundation
import CoreData


extension CryptoParams {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CryptoParams> {
        return NSFetchRequest<CryptoParams>(entityName: "CryptoParams")
    }

    @NSManaged public var cipher: String?
    @NSManaged public var ciphertext: String?
    @NSManaged public var kdf: String?
    @NSManaged public var mac: String?
    @NSManaged public var version: String?
    @NSManaged public var cipherparams: CipherParams?
    @NSManaged public var kdfparams: KdfParams?
    @NSManaged public var keystore: Keystore?

}

extension CryptoParams : Identifiable {

}
