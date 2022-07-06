//
//  WCSession+CoreDataProperties.swift
//  Adanac
//
//  Created by Daniel Bell on 6/28/22.
//
//

import Foundation
import CoreData


extension WCSession {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WCSession> {
        return NSFetchRequest<WCSession>(entityName: "WCSession")
    }

    @NSManaged public var url: WCSessionURL?
    @NSManaged public var dAppInfo: WCDAppInfo?
    @NSManaged public var walletInfo: WCWalletInfo?

}

extension WCSession : Identifiable {

}
