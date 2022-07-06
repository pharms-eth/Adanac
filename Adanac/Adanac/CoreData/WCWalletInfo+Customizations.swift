//
//  WCWalletInfo+Customizations.swift
//  Adanac
//
//  Created by Daniel Bell on 6/28/22.
//

import Foundation

extension WCWalletInfo {
    var accountsArray: [String] {
        get {
            let data = Data((accounts ?? "").utf8)
            return (try? JSONDecoder().decode([String].self, from: data)) ?? []
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                accounts = nil
                return
            }
            accounts = String(data: data, encoding: .utf8)
        }
    }
}
