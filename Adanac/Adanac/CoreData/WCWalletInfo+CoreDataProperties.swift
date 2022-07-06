//
//  WCWalletInfo+CoreDataProperties.swift
//  Adanac
//
//  Created by Daniel Bell on 6/28/22.
//
//

import Foundation
import CoreData


extension WCWalletInfo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WCWalletInfo> {
        return NSFetchRequest<WCWalletInfo>(entityName: "WCWalletInfo")
    }

    @NSManaged public var approved: Bool
    @NSManaged public var accounts: String?
    @NSManaged public var chainID: Int64
    @NSManaged public var peerID: String?
    @NSManaged public var peerMeta: WCClientMeta?
    @NSManaged public var parent: WCSession?

}

extension WCWalletInfo : Identifiable {

}
