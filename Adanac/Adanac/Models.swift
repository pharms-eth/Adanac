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

// MARK: - Coin
struct Coin: Codable {
    let id, symbol, name: String
    let blockTimeInMinutes: String?
    let image: CoinImage
    let marketData: CoinMarketData
    let lastUpdated: String
    let localization: CoinLocalization

    enum CodingKeys: String, CodingKey {
        case id, symbol, name
        case blockTimeInMinutes = "block_time_in_minutes"
        case image
        case marketData = "market_data"
        case lastUpdated = "last_updated"
        case localization
    }
}

// MARK: - Image
struct CoinImage: Codable {
    let thumb, small, large: String
}

// MARK: - Localization
struct CoinLocalization: Codable {
    let en, de, es, fr: String
    let it, pl, ro, hu: String
    let nl, pt, sv, vi: String
    let tr, ru, ja, zh: String
    let zhTw, ko, ar, th: String
    let id: String

    enum CodingKeys: String, CodingKey {
        case en, de, es, fr, it, pl, ro, hu, nl, pt, sv, vi, tr, ru, ja, zh
        case zhTw = "zh-tw"
        case ko, ar, th, id
    }
}

// MARK: - MarketData
struct CoinMarketData: Codable {
    let currentPrice: [String: Double]
    let roi: Roi?
    let marketCap: [String: Double]
    let marketCapRank: Int
    let totalVolume, high24H, low24H: [String: Double]
    let priceChange24H, priceChangePercentage24H, priceChangePercentage7D, priceChangePercentage14D: Double
    let priceChangePercentage30D, priceChangePercentage60D, priceChangePercentage200D, priceChangePercentage1Y: Double
    let marketCapChange24H, marketCapChangePercentage24H: Double
    let priceChange24HInCurrency, priceChangePercentage1HInCurrency, priceChangePercentage24HInCurrency, priceChangePercentage7DInCurrency: [String: Double]
    let priceChangePercentage14DInCurrency, priceChangePercentage30DInCurrency, priceChangePercentage60DInCurrency, priceChangePercentage200DInCurrency: [String: Double]
    let priceChangePercentage1YInCurrency, marketCapChange24HInCurrency, marketCapChangePercentage24HInCurrency: [String: Double]
    let totalSupply: String?
    let circulatingSupply: String
    let sparkline7D: Sparkline7D

    enum CodingKeys: String, CodingKey {
        case currentPrice = "current_price"
        case roi
        case marketCap = "market_cap"
        case marketCapRank = "market_cap_rank"
        case totalVolume = "total_volume"
        case high24H = "high_24h"
        case low24H = "low_24h"
        case priceChange24H = "price_change_24h"
        case priceChangePercentage24H = "price_change_percentage_24h"
        case priceChangePercentage7D = "price_change_percentage_7d"
        case priceChangePercentage14D = "price_change_percentage_14d"
        case priceChangePercentage30D = "price_change_percentage_30d"
        case priceChangePercentage60D = "price_change_percentage_60d"
        case priceChangePercentage200D = "price_change_percentage_200d"
        case priceChangePercentage1Y = "price_change_percentage_1y"
        case marketCapChange24H = "market_cap_change_24h"
        case marketCapChangePercentage24H = "market_cap_change_percentage_24h"
        case priceChange24HInCurrency = "price_change_24h_in_currency"
        case priceChangePercentage1HInCurrency = "price_change_percentage_1h_in_currency"
        case priceChangePercentage24HInCurrency = "price_change_percentage_24h_in_currency"
        case priceChangePercentage7DInCurrency = "price_change_percentage_7d_in_currency"
        case priceChangePercentage14DInCurrency = "price_change_percentage_14d_in_currency"
        case priceChangePercentage30DInCurrency = "price_change_percentage_30d_in_currency"
        case priceChangePercentage60DInCurrency = "price_change_percentage_60d_in_currency"
        case priceChangePercentage200DInCurrency = "price_change_percentage_200d_in_currency"
        case priceChangePercentage1YInCurrency = "price_change_percentage_1y_in_currency"
        case marketCapChange24HInCurrency = "market_cap_change_24h_in_currency"
        case marketCapChangePercentage24HInCurrency = "market_cap_change_percentage_24h_in_currency"
        case totalSupply = "total_supply"
        case circulatingSupply = "circulating_supply"
        case sparkline7D = "sparkline_7d"
    }
}

// MARK: - Sparkline7D
struct Sparkline7D: Codable {
    let price: [Double]
}

// MARK: - Roi
struct Roi: Codable {
    let times: Double
    let currency: Currency
    let percentage: Double
}

enum Currency: String, Codable {
    case btc = "btc"
    case eth = "eth"
    case usd = "usd"
}
