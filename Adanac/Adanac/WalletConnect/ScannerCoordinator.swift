//
//  ScannerCoordinator.swift
//  Adanac
//
//  Created by Daniel Bell on 6/19/22.
//

import AVFoundation
import SwiftUI


public class ScannerCoordinator: NSObject, ScannerViewController.ScannerViewControllerCaptureDelegate {

    public var codesFound = Set<String>()
    public var shouldVibrateOnSuccess: Bool
    public var completion: (Result<ScanResult, ScanError>) -> Void

    init(shouldVibrateOnSuccess: Bool, completion: @escaping (Result<ScanResult, ScanError>) -> Void) {
        self.shouldVibrateOnSuccess = shouldVibrateOnSuccess
        self.completion = completion
    }

    public func reset() {
        codesFound.removeAll()
    }

    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let readableObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject else {
            return
        }
        guard let stringValue = readableObject.stringValue else { return }
        let result = ScanResult(string: stringValue, type: readableObject.type)

        if !codesFound.contains(stringValue) {
            codesFound.insert(stringValue)
            found(result)
        }
    }

    func found(_ result: ScanResult) {

        if shouldVibrateOnSuccess {
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        }

        completion(.success(result))
    }

    func didFail(reason: ScanError) {
        completion(.failure(reason))
    }
}


