//
//  ScanModels.swift
//  Adanac
//
//  Created by Daniel Bell on 6/20/22.
//

import AVFoundation
import SwiftUI

public struct ScanResult {
    /// The contents of the code.
    public let string: String

    /// The type of code that was matched.
    public let type: AVMetadataObject.ObjectType
}

public enum ScanError: Error {
    /// The camera could not be accessed.
    case badInput

    /// The camera was not capable of scanning the requested codes.
    case badOutput
    case cancelled

    /// Initialization failed.
    case initError(_ error: Error)
}
