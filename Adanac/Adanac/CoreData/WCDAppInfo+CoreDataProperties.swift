//
//  WCDAppInfo+CoreDataProperties.swift
//  Adanac
//
//  Created by Daniel Bell on 6/28/22.
//
//

import Foundation
import CoreData


extension WCDAppInfo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WCDAppInfo> {
        return NSFetchRequest<WCDAppInfo>(entityName: "WCDAppInfo")
    }

    @NSManaged public var peerID: String?
    @NSManaged public var chainID: Int64
    @NSManaged public var approved: Bool
    @NSManaged public var peerMeta: WCClientMeta?
    @NSManaged public var parent: WCSession?

}

extension WCDAppInfo : Identifiable {

}
