//
//  GenerateWeb3Interface.swift
//  Adanac
//
//  Created by Daniel Bell on 3/11/22.
//

import Foundation
import web3swift
struct GenerateWeb3Interface {
    init() {
        let password = "web3swift"
        let mnemonics = "fine have legal roof fury bread egg knee wrong idea must edit" // Some mnemonic phrase
        let keystore = try! ETHWallet(seed: Entropy().getSeed()!, password: password)
        let name = "New HD Wallet"
        let keyData = keystore.keystoreParams!
        let address = keystore.addresses.first!
        let wallet = ETHDataWallet(address: address, data: keyData, name: name, isHD: true)
        let data = wallet.data

        let keystore2 = try! ETHWallet(data)
//        let keystoreManager: KeystoreManager = KeystoreManager([keystore2])
//
////        let password = "web3swift"
//        let ethereumAddress = EthAddress(wallet.address!.address)!
//        let privatekeyData = try! keystoreManager.UNSAFE_getPrivateKeyData(password: password, account: ethereumAddress).toHexString()
//        let web3 = Web3.InfuraMainnetWeb3() // Mainnet Infura Endpoint Provider
////        let web3 = Web3.InfuraRinkebyWeb3() // Rinkeby Infura Endpoint Provider
////        let web3 = Web3.InfuraRopstenWeb3() // Ropsten Infura Endpoint Provider
//        web3.addKeystoreManager(keystoreManager)
//        let walletAddress = EthAddress(wallet.address)! // Address which balance we want to know
//        let balanceResult = try! web3.eth.getBalance(address: walletAddress)
//        let balanceString = Web3.Utils.formatToEthereumUnits(balanceResult, toUnits: .eth, decimals: 3)!
//        let walletAddress = EthAddress(wallet.address)! // Your wallet address
//        let exploredAddress = EthAddress(wallet.address)! // Address which balance we want to know. Here we used same wallet address
//        let erc20ContractAddress = EthAddress(token.address)!
//        let contract = web3.contract(Web3.Utils.erc20ABI, at: erc20ContractAddress, abiVersion: 2)!
//        var options = TransactionOptions.defaultOptions
//        options.from = walletAddress
//        options.gasPrice = .automatic
//        options.gasLimit = .automatic
//        let method = "balanceOf"
//        let tx = contract.read(
//            method,
//            parameters: [exploredAddress] as [AnyObject],
//            extraData: Data(),
//            transactionOptions: options)!
//        let tokenBalance = try! tx.call()
//        let balanceBigUInt = tokenBalance["0"] as! BigUInt
//        let balanceString = Web3.Utils.formatToEthereumUnits(balanceResult, toUnits: .eth, decimals: 3)!
//        let web = await Web3.InfuraMainnetWeb3()
//        let ens = ENS(web3: web)!
//        let node = "somename.eth"
//        let owner = try! ens.registry.getOwner(node: node)
////        let address = try! ens.getAddress(forNode: node)
////        let name = try! ens.getName(forNode: node)
//        let content = try! ens.getContent(forNode: node)
//        let abi = try! ens.getABI(forNode: node, contentType: .URI)
//        let pubkey = try! ens.getPublicKey(forNode: node)
//        let text = try! ens.getText(forNode: node, key: key)

//        let result = try! ens.setAddress(forNode: node, address: address, options: options, password: password)
//        let result = try! ens.setName(forNode: node, name: name, options: options, password: password)
//        let result = try! ens.setContent(forNode: node, hash: hash, options: options, password: password)
//        let result = try! ens.setABI(forNode: node, contentType: .JSON, data: data, options: options, password: password)
//        let result = try! ens.setPublicKey(forNode: node, publicKey: publicKey, options: options, password: password)
//        let result = try! ens.setText(forNode: node, key: key, value: value, options: options, password: password)
    }
}
