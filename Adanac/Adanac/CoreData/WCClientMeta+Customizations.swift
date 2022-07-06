//
//  WCClientMeta+Customizations.swift
//  Adanac
//
//  Created by Daniel Bell on 6/28/22.
//

import Foundation

extension WCClientMeta {
    var iconArray : [URL] {
        get {
            let data = Data((icons ?? "").utf8)
            return (try? JSONDecoder().decode([URL].self, from: data)) ?? []
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                icons = nil
                return
            }
            icons = String(data: data, encoding: .utf8)
        }
    }
}
