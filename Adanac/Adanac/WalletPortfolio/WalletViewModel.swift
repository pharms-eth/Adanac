//
//  WalletViewModel.swift
//  Adanac
//
//  Created by Daniel Bell on 3/29/22.
//

import Foundation
import web3swift
import BigInt

class WalletViewModel: ObservableObject {
    @Published var balance: String = ""
    @Published var nftHoldings: [NFTResult] = []
    @Published var erc20Holdings: [ERC20Holding] = []
    @Published var gasPrice: Double?
    @Published var addr: EthereumAddress?

    let baseURL = "https://deep-index.moralis.io/api/v2/"
    let chain = "chain=eth"
    var allCoins: [Coin]?

    init() {
        Task {
            guard let web = try? await Web3(provider: InfuraProvider(Networks.Mainnet)!) else {
                return
            }

            guard let gasPrice = try? await web.eth.getGasPrice() else {
                return
            }

            guard let balanceString = Web3.Utils.formatToEthereumUnits(gasPrice, toUnits: .Gwei, decimals: 3) else {
                return
            }

            let gasPriceValue = Double(balanceString)
            DispatchQueue.main.async {
                self.gasPrice = gasPriceValue
            }

        }
    }

    func setAddress(_ ethAddress: String) async {

        let allCoinURL = URL(string: "https://api.coingecko.com/api/v3/coins?sparkline=true")
        let allCoinbalance: [Coin]? = try? await getValueFrom(allCoinURL)
        self.allCoins = allCoinbalance
        DispatchQueue.main.async {
            self.addr = EthereumAddress(ethAddress)
        }
        await getAccountBalance(ethAddress)
        await getERCHoldings(ethAddress)
        await getNFTHolding(ethAddress)
    }
// tokenURI, name, symbol, tokenID, contractType
    // amount??
    // sort/group by symbol/name
    func getNFTHolding(_ ethAddress: String) async {
        let nftURL = URL(string: baseURL + ethAddress + "/nft?" + chain + "&format=decimal")
        let nftbalance: NFTHoldings? = try? await getValueFrom(nftURL)
        DispatchQueue.main.async {
            self.nftHoldings = nftbalance?.result ?? []
        }
    }// TODO: POAP

    func getAccountBalance(_ ethAddress: String) async {
        let balanceURL = URL(string: baseURL + ethAddress + "/balance?" + chain)
        guard let balanceValue: AccountBalance = try? await getValueFrom(balanceURL) else {
            return
        }

        guard let balanceString = Web3.Utils.formatToEthereumUnits(BigInt(stringLiteral: balanceValue.balance), toUnits: .eth, decimals: 3) else {
            return
        }
        DispatchQueue.main.async {
            self.balance = balanceString
        }

    }

    func getERCHoldings(_ ethAddress: String) async {
        let erc20URL = URL(string: baseURL + ethAddress + "/erc20?" + chain)
        let erc20balance: [ERC20Holding]? = try? await getValueFrom(erc20URL)
        DispatchQueue.main.async {
            self.erc20Holdings = []
        }
        var holdings: [ERC20Holding]? = erc20balance?.map {
            var erc20Holding = $0
            let coin = allCoins?.filter { aCoin in aCoin.symbol == erc20Holding.symbol }
            if coin?.count ?? 0 > 1 {
                print("hello")
            }
            if erc20Holding.decimals == 18.0, let erc20Balance = erc20Holding.balance {
                let balanceString = Web3.Utils.formatToEthereumUnits(BigInt(stringLiteral: erc20Balance), toUnits: .eth, decimals: 3)
                erc20Holding.displayBalance = Double( balanceString ?? erc20Balance)
            }

            if let mactchedCoin = coin?.first {
                erc20Holding.coin = mactchedCoin
            }
            return erc20Holding
        }

        let matchedCoinCount = holdings?.filter { $0.coin != nil }.count ?? 0

        if matchedCoinCount < 1 {
            holdings = holdings?.filter { $0.thumbnail != nil || $0.logo != nil }
        }

        holdings?.sort { hold1, hold2 in
            (hold1.displayBalance ?? 0) > (hold2.displayBalance ?? 0)
        }

        guard let holdings = holdings else {
            return
        }

        DispatchQueue.main.async {
            self.erc20Holdings = holdings
        }
    }

    func getValueFrom<T: Codable>(_ refUrl: URL? ) async throws -> T? {
        guard let url = refUrl else { return nil }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("7ijth7VhkveTjkydVHzpoCROONDAIJn36vdIYPO9vgxuvgWS4jOo0bU7nxM0rtW1", forHTTPHeaderField: "X-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "accept")

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            do {
                return try JSONDecoder().decode(T.self, from: data)
            } catch let error {
                print(error)
                return nil
            }
        } catch let error {
            print(error)
            return nil
        }
    }
}
