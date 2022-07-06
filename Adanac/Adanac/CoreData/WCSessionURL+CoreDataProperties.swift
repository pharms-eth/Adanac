//
//  WCSessionURL+CoreDataProperties.swift
//  Adanac
//
//  Created by Daniel Bell on 6/28/22.
//
//

import Foundation
import CoreData


extension WCSessionURL {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WCSessionURL> {
        return NSFetchRequest<WCSessionURL>(entityName: "WCSessionURL")
    }

    @NSManaged public var topic: String?
    @NSManaged public var version: String?
    @NSManaged public var bridgeURL: String?
    @NSManaged public var key: String?
    @NSManaged public var absoluteString: String?
    @NSManaged public var parent: WCSession?

}

extension WCSessionURL : Identifiable {

}
