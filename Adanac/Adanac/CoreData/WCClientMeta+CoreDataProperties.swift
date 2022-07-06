//
//  WCClientMeta+CoreDataProperties.swift
//  Adanac
//
//  Created by Daniel Bell on 6/28/22.
//
//

import Foundation
import CoreData


extension WCClientMeta {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WCClientMeta> {
        return NSFetchRequest<WCClientMeta>(entityName: "WCClientMeta")
    }

    @NSManaged public var name: String?
    @NSManaged public var desc: String?
    @NSManaged public var url: String?
    @NSManaged public var scheme: String?
    @NSManaged public var icons: String?
    @NSManaged public var dAppParent: WCDAppInfo?
    @NSManaged public var wCWalletParent: WCWalletInfo?

}

extension WCClientMeta : Identifiable {

}
