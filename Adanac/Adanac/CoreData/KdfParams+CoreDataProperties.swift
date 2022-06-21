//
//  KdfParams+CoreDataProperties.swift
//  Adanac
//
//  Created by Daniel Bell on 6/16/22.
//
//

import Foundation
import CoreData


extension KdfParams {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<KdfParams> {
        return NSFetchRequest<KdfParams>(entityName: "KdfParams")
    }

    @NSManaged public var c: Int64
    @NSManaged public var dklen: Int64
    @NSManaged public var n: Int64
    @NSManaged public var p: Int64
    @NSManaged public var prf: String?
    @NSManaged public var r: Int64
    @NSManaged public var salt: String?
    @NSManaged public var crypto: CryptoParams?

}

extension KdfParams : Identifiable {

}
