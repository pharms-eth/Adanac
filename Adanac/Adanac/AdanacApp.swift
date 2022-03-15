//
//  AdanacApp.swift
//  Adanac
//
//  Created by Daniel Bell on 3/2/22.
//

import SwiftUI
//import CryptoKit
//import CryptoSwift
import SafariWalletCore
import MEWwalletKit

@main
struct AdanacApp: App {
    @State private var wallet: AddressBundle? = nil
    var body: some Scene {
        WindowGroup {
            if let ethWallet = wallet {//}, let addr = ethWallet.address {
                Text(wallet?.addresses.first?.addressString ?? "hello")
            } else {
                WalletSetupMenuView(wallet: $wallet)
            }
        }
    }
}

extension String {
   /// Splits a string into groups of `every` n characters, grouping from left-to-right by default. If `backwards` is true, right-to-left.
   public func split(every: Int, backwards: Bool = false) -> [String] {
       var result = [String]()

       for i in stride(from: 0, to: self.count, by: every) {
           switch backwards {
           case true:
               let endIndex = self.index(self.endIndex, offsetBy: -i)
               let startIndex = self.index(endIndex, offsetBy: -every, limitedBy: self.startIndex) ?? self.startIndex
               result.insert(String(self[startIndex..<endIndex]), at: 0)
           case false:
               let startIndex = self.index(self.startIndex, offsetBy: i)
               let endIndex = self.index(startIndex, offsetBy: every, limitedBy: self.endIndex) ?? self.endIndex
               result.append(String(self[startIndex..<endIndex]))
           }
       }

       return result
   }
}
