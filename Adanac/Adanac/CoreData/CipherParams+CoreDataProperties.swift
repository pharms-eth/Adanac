//
//  CipherParams+CoreDataProperties.swift
//  Adanac
//
//  Created by Daniel Bell on 6/16/22.
//
//

import Foundation
import CoreData


extension CipherParams {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CipherParams> {
        return NSFetchRequest<CipherParams>(entityName: "CipherParams")
    }

    @NSManaged public var iv: String?
    @NSManaged public var crypto: CryptoParams?

}

extension CipherParams : Identifiable {

}
