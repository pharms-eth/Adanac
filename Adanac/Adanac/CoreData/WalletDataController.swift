//
//  WalletDataController.swift
//  Adanac
//
//  Created by Daniel Bell on 5/24/22.
//

import CoreData
import Foundation
//Note: Provides info which bundle we are working in
class WalletPersistentContainer: NSPersistentCloudKitContainer {}

class WalletDataController: ObservableObject {
    let container = WalletPersistentContainer(name: "AdanacWallet")

    init() {
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
            }
            self.container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
            self.container.viewContext.automaticallyMergesChangesFromParent = true
        }
    }
}
