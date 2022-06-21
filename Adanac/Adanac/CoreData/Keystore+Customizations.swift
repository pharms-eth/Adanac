//
//  Keystore+Customizations.swift
//  Adanac
//
//  Created by Daniel Bell on 5/28/22.
//

import Foundation
import web3swift

extension Keystore {
    public var addressArray: [Address] {
        let set = address as? Set<Address> ?? []
        return Array(set)
    }

    var accessLevel: NetworkAccess {
        guard let levelRaw = access else {
            return .readOnly
        }

        return NetworkAccess(rawValue: levelRaw) ?? .readOnly
    }

    enum NetworkAccess: String, Equatable {
        static func == (lhs: NetworkAccess, rhs: NetworkAccess) -> Bool {
            switch (lhs, rhs) {
            case (.readOnly, .readOnly):
                return true
            case (.full, .full):
                return true
            case (.full, .readOnly):
                return false
            case (.readOnly, .full):
                return false
            }
        }

        case readOnly
        case full
    }
}


enum WalletKeyStoreAccess: Equatable {
    static func == (lhs: WalletKeyStoreAccess, rhs: WalletKeyStoreAccess) -> Bool {
        switch (lhs, rhs) {
        case (.readOnly(let addressLHS), .readOnly(let addressRHS)):
            return addressLHS.addresses == addressRHS.addresses
        case (.full(let addressLHS), .full(let addressRHS)):
            return addressLHS.addresses == addressRHS.addresses
        case (.full(_), .readOnly(_)):
            return false
        case (.readOnly(_), .full(_)):
            return false
        }
    }

    case readOnly(AbstractKeystore)
    case full(AbstractKeystore)
}
