//
//  Keystore+Customizations.swift
//  Adanac
//
//  Created by Daniel Bell on 5/28/22.
//

import Foundation
import web3swift
import SwiftUI

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

    var tintColor: Color? {
        set {
            tint = newValue?.description
        }
        get {
            guard let hex = tint?.trimmingCharacters(in: CharacterSet.alphanumerics.inverted) else {
                return nil
            }

            var int: UInt64 = 0
            Scanner(string: hex).scanHexInt64(&int)
            let a, r, g, b: UInt64
            switch hex.count {
            case 3: // RGB (12-bit)
                (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
            case 6: // RGB (24-bit)
                (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
            case 8: // ARGB (32-bit)
                (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
            default:
                (a, r, g, b) = (1, 1, 1, 0)
            }

            return Color(.sRGB,
                red: Double(r) / 255,
                green: Double(g) / 255,
                blue:  Double(b) / 255,
                opacity: Double(a) / 255
            )
        }
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
