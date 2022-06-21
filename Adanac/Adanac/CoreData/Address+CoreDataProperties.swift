//
//  Address+CoreDataProperties.swift
//  Adanac
//
//  Created by Daniel Bell on 6/16/22.
//
//

import Foundation
import CoreData


extension Address {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Address> {
        return NSFetchRequest<Address>(entityName: "Address")
    }

    @NSManaged public var address: String?
    @NSManaged public var path: String?
    @NSManaged public var keystore: Keystore?

}

extension Address : Identifiable {

}
