//
//  ScannerViewController.swift
//  Adanac
//
//  Created by Daniel Bell on 6/19/22.
//

import AVFoundation
import UIKit

protocol ScannerViewControllerDelegate {
    func didFail(reason: ScanError)
    func found(_ result: ScanResult)
    func reset()
}

public class ScannerViewController: UIViewController, UINavigationControllerDelegate {

    typealias ScannerViewControllerCaptureDelegate = ScannerViewControllerDelegate & AVCaptureMetadataOutputObjectsDelegate
    var captureSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    let videoCaptureDevice = AVCaptureDevice.default(for: .video)
    public let codeTypes: [AVMetadataObject.ObjectType] = [.qr]
    var delegate: ScannerViewControllerCaptureDelegate?

    public init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateOrientation),
                                               name: Notification.Name("UIDeviceOrientationDidChangeNotification"),
                                               object: nil)

        view.backgroundColor = UIColor.black

        guard let videoCaptureDevice = videoCaptureDevice else {
            return
        }

        AVCaptureDevice.requestAccess(for: .video) { _ in

            DispatchQueue.main.async {
                self.setNeedsStatusBarAppearanceUpdate()
            }

            let videoInput: AVCaptureDeviceInput

            do {
                videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            } catch {
                self.delegate?.didFail(reason: .initError(error))
                return
            }

            if (self.captureSession.canAddInput(videoInput)) {
                self.captureSession.addInput(videoInput)
            } else {
                self.delegate?.didFail(reason: .badInput)
                return
            }

            let metadataOutput = AVCaptureMetadataOutput()

            if (self.captureSession.canAddOutput(metadataOutput)) {
                self.captureSession.addOutput(metadataOutput)

                metadataOutput.setMetadataObjectsDelegate(self.delegate, queue: .main)
                metadataOutput.metadataObjectTypes = self.codeTypes
            } else {
                self.delegate?.didFail(reason: .badOutput)
                return
            }
        }
    }

    override public func viewWillLayoutSubviews() {
        videoPreviewLayer?.frame = view.layer.bounds
    }

    @objc func updateOrientation() {
        guard let orientation = view.window?.windowScene?.interfaceOrientation else { return }
        guard let connection = captureSession.connections.last, connection.isVideoOrientationSupported else { return }
        connection.videoOrientation = AVCaptureVideoOrientation(rawValue: orientation.rawValue) ?? .portrait
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateOrientation()
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if videoPreviewLayer == nil {
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        }

        videoPreviewLayer?.frame = view.layer.bounds
        videoPreviewLayer?.videoGravity = .resizeAspectFill
        view.layer.addSublayer(videoPreviewLayer!)

        delegate?.reset()

        if (captureSession.isRunning == false) {
            DispatchQueue.global(qos: .userInitiated).async {
                self.captureSession.startRunning()
            }
        }
    }

    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        if (captureSession.isRunning == true) {
            DispatchQueue.global(qos: .userInitiated).async {
                self.captureSession.stopRunning()
            }
        }

        NotificationCenter.default.removeObserver(self)
    }

    override public var prefersStatusBarHidden: Bool {
        true
    }

    override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .all
    }

    /** Touch the screen for autofocus */
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard touches.first?.view == view,
              let touchPoint = touches.first,
              let device = videoCaptureDevice,
              device.isFocusPointOfInterestSupported
        else { return }

        let videoView = view
        let screenSize = videoView!.bounds.size
        let xPoint = touchPoint.location(in: videoView).y / screenSize.height
        let yPoint = 1.0 - touchPoint.location(in: videoView).x / screenSize.width
        let focusPoint = CGPoint(x: xPoint, y: yPoint)

        do {
            try device.lockForConfiguration()
        } catch {
            return
        }

        // Focus to the correct point, make continiuous focus and exposure so the point stays sharp when moving the device closer
        device.focusPointOfInterest = focusPoint
        device.focusMode = .continuousAutoFocus
        device.exposurePointOfInterest = focusPoint
        device.exposureMode = AVCaptureDevice.ExposureMode.continuousAutoExposure
        device.unlockForConfiguration()
    }

    func updateViewController(isTorchOn: Bool) {
        if let backCamera = AVCaptureDevice.default(for: AVMediaType.video),
           backCamera.hasTorch
        {
            try? backCamera.lockForConfiguration()
            backCamera.torchMode = isTorchOn ? .on : .off
            backCamera.unlockForConfiguration()
        }
    }

}
