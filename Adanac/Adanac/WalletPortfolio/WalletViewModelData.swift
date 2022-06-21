//
//  WalletViewModelData.swift
//  Adanac
//
//  Created by Daniel Bell on 3/29/22.
//

import Foundation

struct AccountBalance: Codable {
    let balance: String
}

struct ERC20Holding: Codable, Identifiable {
    var id: String {
        tokenAddress ?? coin?.id ?? UUID().uuidString
    }

    let tokenAddress, name, symbol: String?
    let logo, thumbnail: String?
    let decimals: Double?
    let balance: String?
    var displayBalance: Double?
    var coin: Coin?

    enum CodingKeys: String, CodingKey {
        case tokenAddress = "token_address"
        case name, symbol, logo, thumbnail, decimals, balance
    }
}

struct NFTHoldings: Codable {
    let status: String
    let total, page, pageSize: Int
    let cursor: String
    let result: [NFTResult]

    enum CodingKeys: String, CodingKey {
        case status, total, page
        case pageSize = "page_size"
        case cursor, result
    }
}

// MARK: - Result
struct NFTResult: Codable, Identifiable {
    var id: String {
        tokenAddress + tokenID
    }

    let tokenAddress, tokenID, contractType, ownerOf: String
    let blockNumber, blockNumberMinted, tokenURI, metadata: String?
    let syncedAt, amount, name, symbol: String?

    enum CodingKeys: String, CodingKey {
        case tokenAddress = "token_address"
        case tokenID = "token_id"
        case contractType = "contract_type"
        case ownerOf = "owner_of"
        case blockNumber = "block_number"
        case blockNumberMinted = "block_number_minted"
        case tokenURI = "token_uri"
        case metadata
        case syncedAt = "synced_at"
        case amount, name, symbol
    }
}
