//
//  ImageCodeScannerView.swift
//  Adanac
//
//  Created by Daniel Bell on 6/20/22.
//

import PhotosUI
import SwiftUI

struct ImageCodeScannerView: UIViewControllerRepresentable {
    @Binding public var showView: Bool
    public var completion: (Result<ScanResult, ScanError>) -> Void
    //    @Binding var image: UIImage?

    //            if #available(iOS 16.0, *) {
    //                @State var selection: [PhotosPickerItem] = []
    //                PhotosPicker(selection: $selection, maxSelectionCount: 3) {
    //                    Text("Select QR code")
    //                }
    //            }
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .any(of: [.images])// .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {

    }

    func makeCoordinator() -> Coordinator {
        Coordinator(showView: $showView, completion: completion)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        @Binding public var showView: Bool
        public var completion: (Result<ScanResult, ScanError>) -> Void

        init(showView: Binding<Bool>, completion: @escaping (Result<ScanResult, ScanError>) -> Void) {
            _showView = showView
            self.completion = completion
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            showView = false

            guard let provider = results.first?.itemProvider else {
                completion(.failure(.badInput))
                return
            }

            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    guard let uiImage = image as? UIImage, let ciImage = CIImage(image:uiImage) else {
                        self.completion(.failure(.badInput))
                        return
                    }

                    var qrCodeLink = ""
                    var options: [String: Any]
                    let context = CIContext()
                    options = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
                    let qrDetector = CIDetector.init(ofType: CIDetectorTypeQRCode, context: context, options: options)
                    if ciImage.properties.keys.contains((kCGImagePropertyOrientation as String)){
                        options = [CIDetectorImageOrientation: ciImage.properties[(kCGImagePropertyOrientation as String)] ?? 1]
                    } else {
                        options = [CIDetectorImageOrientation: 1]
                    }
                    guard let features = qrDetector?.features(in: ciImage, options: options) as? [CIQRCodeFeature] else {
                        self.completion(.failure(.badInput))
                        return
                    }

                    for feature in features {
                        qrCodeLink += feature.messageString!
                    }

                    print(qrCodeLink)
                    self.completion(.success(ScanResult(string: qrCodeLink, type: .qr)))
                }
            }
        }
    }
}

struct ImageCodeScannerView_Previews: PreviewProvider {
    static var previews: some View {
        ImageCodeScannerView(showView: .constant(true), completion: {ans in print(ans)})
    }
}
