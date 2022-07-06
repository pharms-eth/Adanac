//
//  CodeScannerView.swift
//  Adanac
//
//  Created by Daniel Bell on 6/20/22.
//

import SwiftUI

public struct CodeScannerView: UIViewControllerRepresentable {

    public var shouldVibrateOnSuccess: Bool
    public var isTorchOn: Bool
    public var completion: (Result<ScanResult, ScanError>) -> Void

    public init(shouldVibrateOnSuccess: Bool = true, isTorchOn: Bool = false, completion: @escaping (Result<ScanResult, ScanError>) -> Void) {
        self.shouldVibrateOnSuccess = shouldVibrateOnSuccess
        self.isTorchOn = isTorchOn
        self.completion = completion
    }

    public func makeCoordinator() -> ScannerCoordinator {
        ScannerCoordinator(shouldVibrateOnSuccess: shouldVibrateOnSuccess, completion: completion)
    }

    public func makeUIViewController(context: Context) -> ScannerViewController {
        let viewController = ScannerViewController()
        viewController.delegate = context.coordinator
        return viewController
    }

    public func updateUIViewController(_ uiViewController: ScannerViewController, context: Context) {
        uiViewController.updateViewController(isTorchOn: isTorchOn)
    }

}

//struct CodeScannerView_Previews: PreviewProvider {
//    static var previews: some View {
//        CodeScannerView()
//    }
//}
