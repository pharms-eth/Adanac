//
//  Models.swift
//  Adanac
//
//  Created by Daniel Bell on 3/2/22.
//

import Foundation
import web3swift

struct Wallet {
    let address: EthereumAddress?
    let data: Data?
    let name: String?
    var isHD: Bool = false
}
