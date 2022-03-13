//
//  Models.swift
//  Adanac
//
//  Created by Daniel Bell on 3/2/22.
//

import Foundation

struct Wallet {
    let address: String?
    let data: Data?
    let name: String?
    var isHD: Bool = false
}
