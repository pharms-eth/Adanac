//
//  ImageCodeScannerView.swift
//  Adanac
//
//  Created by Daniel Bell on 6/20/22.
//

import SwiftUI

import PhotosUI
import SwiftUI

struct ImageCodeScannerView: UIViewControllerRepresentable {
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
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImageCodeScannerView

        init(_ parent: ImageCodeScannerView) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            guard let provider = results.first?.itemProvider else {
                return
            }

            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    guard let uiImage = image as? UIImage, let ciImage = CIImage(image:uiImage) else { return }

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
                        return
                    }

                    for feature in features {
                        qrCodeLink += feature.messageString!
                    }

                    print(qrCodeLink)
                }
            }
        }
    }
}

struct ImageCodeScannerView_Previews: PreviewProvider {
    static var previews: some View {
        ImageCodeScannerView()
    }
}
