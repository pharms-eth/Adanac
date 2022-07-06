//
//  WalletConnectRequestHandler.swift
//  Adanac
//
//  Created by Daniel Bell on 7/1/22.
//

import Foundation
import WalletConnectSwift
import web3swift

////You do this by registering request handlers. You have the flexibility to register one handler per request method, or a catch-all request handler.
//
//server.register(handler: PersonalSignHandler(for: self, server: server, wallet: wallet))
////Handlers are asked (in order of registration) whether they can handle each request. First handler that returns true from canHandle(request:) method will get the handle(request:) call. All other handlers will be skipped.
////
////In the request handler, check the incoming request's method in canHandle implementation, and handle actual request in the handle(request:) implementation.
//
//func canHandle(request: Request) -> Bool {
//   return request.method == "eth_signTransaction"
//}
////You can send back response for the request through the server using send method:
//
//func handle(request: Request) {
//  // do you stuff here ...
//
//  // error response - rejected by user
//  server.send(.reject(request))
//
//  // or send actual response - assuming the request.id exists, and MyCodableStruct type defined
//  try server.send(Response(url: request.url, value: MyCodableStruct(value: "Something"), id: request.id!))
//}
////For more details, see the ExampleApps/ServerApp
///
class BaseHandler: RequestHandler {

    weak var sever: Server?
    var privateKey: AbstractKeystoreParams

    init(server: Server, privateKey: AbstractKeystoreParams) {
        self.sever = server
        self.privateKey = privateKey
    }

    func canHandle(request: Request) -> Bool {
        return false
//        po request.method
//        "personal_sign"
    }

    func handle(request: Request) {
        // to override
    }

//    func askToSign(request: Request, message: String, sign: @escaping () -> String) {
//        let onSign = {
//            let signature = sign()
////            self.sever.send(.signature(signature, for: request))
//        }
//        let onCancel = {
//            self.sever?.send(.reject(request))
//        }
////        DispatchQueue.main.async {
////            UIAlertController.showShouldSign(from: self.controller,
////                                             title: "Request to sign a message",
////                                             message: message,
////                                             onSign: onSign,
////                                             onCancel: onCancel)
////        }
//    }
}

class PersonalSignHandler: BaseHandler {
    override func canHandle(request: Request) -> Bool {
        return request.method == "personal_sign"
    }

    override func handle(request: Request) {
        do {
            let messageBytes = try request.parameter(of: String.self, at: 0)
            let address = try request.parameter(of: String.self, at: 1)
//0xCF4140193531B8b2d6864cA7486Ff2e18da5cA95
            let decodedMessage = String(data: Data(hex: messageBytes), encoding: .utf8) ?? messageBytes
//"My email is john@doe.com - Sat, 02 Jul 2022 19:15:19 GMT"

            //===================================================
            /// Returns the ethereum address representing the public key associated with this private key.
            /**
                * Returns this ethereum address as a hex string.
                *
                * Adds the EIP 55 mixed case checksum if `eip55` is set to true.
                *
                * - parameter eip55: Whether to add the mixed case checksum as described in eip 55.
                *
                * - returns: The hex string representing this `EthereumAddress`.
                *            Either lowercased or mixed case (checksumed) depending on the parameter `eip55`.
                */

            var accounts = [String]()

            if let keyStore = privateKey as? KeystoreParamsBIP32 {
                accounts = keyStore.pathAddressPairs.map { $0.address.lowercased() }
            } else if let keyStore = privateKey as? KeystoreParamsV3 {
                if let address = keyStore.address {
                    accounts = [address.lowercased()]
                }
            }

            guard accounts.contains(address.lowercased()) else {
                sever?.send(.reject(request))
                return
            }

            sever?.send(.reject(request))

            Task {
                let web3 = await Web3.InfuraMainnetWeb3()
                var account: EthereumAddress?
                if let keyStore = privateKey as? KeystoreParamsBIP32, let store = BIP32Keystore(keyStore) {
                    let keystoreManager = KeystoreManager([store])
                    web3.addKeystoreManager(keystoreManager)
                    account = store.addressStorage.addresses.first { $0.address.lowercased() == address.lowercased() }
                } else if let keyStore = privateKey as? KeystoreParamsV3, let store = EthereumKeystoreV3(keyStore) {
                    let keystoreManager = KeystoreManager([store])
                    web3.addKeystoreManager(keystoreManager)
                    account = store.getAddress()
                } else {
                    return
                }

                let data = Data(hex: messageBytes)
                let signMsg = try web3.wallet.signPersonalMessage(data, account: account!, password: "web3swift_0")
                print(signMsg.toHexString().addHexPrefix())

                let unmarshalledSignature = SECP256K1.unmarshalSignature(signatureData: signMsg)!
                print("V = " + String(unmarshalledSignature.v))
                print("R = " + Data(unmarshalledSignature.r).toHexString())
                print("S = " + Data(unmarshalledSignature.s).toHexString())

                let (v, r, s) = (unmarshalledSignature.v, Data(unmarshalledSignature.r), Data(unmarshalledSignature.s))
                let signature = "0x" + r.toHexString() + s.toHexString() + String(v + 27, radix: 16) // v in [0, 1]

                print(signature)
                self.sever?.send(.signature(signature, for: request))
//                sever?.send(.reject(request))
            }


//            let onCancel = {
//                self.sever?.send(.reject(request))
//            }
    //            UIAlertController.showShouldSign(from: self.controller,
    //                                             title: "Request to sign a message",
    //                                             message: decodedMessage,
    //                                             onSign: onSign,
    //                                             onCancel: onCancel)
        } catch {
            sever?.send(.invalid(request))
        }
    }

//    private func personalMessageData(messageData: Data) -> Data {
//        let prefix = "\u{19}Ethereum Signed Message:\n"
//        let prefixData = (prefix + String(messageData.count)).data(using: .ascii)!
//        return prefixData + messageData
//    }
}





//class SignTransactionHandler: BaseHandler {
//    override func canHandle(request: Request) -> Bool {
//        return request.method == "eth_signTransaction"
//    }
//
//    override func handle(request: Request) {
//        do {
//            let transaction = try request.parameter(of: EthereumTransaction.self, at: 0)
//            guard transaction.from == privateKey.address else {
//                self.sever.send(.reject(request))
//                return
//            }
//
//            askToSign(request: request, message: transaction.description) {
//                let signedTx = try! transaction.sign(with: self.privateKey, chainId: 4)
//                let (r, s, v) = (signedTx.r, signedTx.s, signedTx.v)
//                return r.hex() + s.hex().dropFirst(2) + String(v.quantity, radix: 16)
//            }
//        } catch {
//            self.sever.send(.invalid(request))
//        }
//    }
//}

//==============================================================
//==============================================================


extension Response {
    static func signature(_ signature: String, for request: Request) -> Response {
        return try! Response(url: request.url, value: signature, id: request.id!)
    }
}
