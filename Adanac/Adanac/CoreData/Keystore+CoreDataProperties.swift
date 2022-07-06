//
//  Keystore+CoreDataProperties.swift
//  Adanac
//
//  Created by Daniel Bell on 7/1/22.
//
//

import Foundation
import CoreData


extension Keystore {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Keystore> {
        return NSFetchRequest<Keystore>(entityName: "Keystore")
    }

    @NSManaged public var access: String?
    @NSManaged public var id: String?
    @NSManaged public var isHDWallet: Bool
    @NSManaged public var rootPath: String?
    @NSManaged public var version: Int16
    @NSManaged public var nickName: String?
    @NSManaged public var tint: String?
    @NSManaged public var address: NSSet?
    @NSManaged public var crypto: CryptoParams?

}

// MARK: Generated accessors for address
extension Keystore {

    @objc(addAddressObject:)
    @NSManaged public func addToAddress(_ value: Address)

    @objc(removeAddressObject:)
    @NSManaged public func removeFromAddress(_ value: Address)

    @objc(addAddress:)
    @NSManaged public func addToAddress(_ values: NSSet)

    @objc(removeAddress:)
    @NSManaged public func removeFromAddress(_ values: NSSet)

}

extension Keystore : Identifiable {

}
