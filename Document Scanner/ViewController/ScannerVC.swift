//
//  ScannerVC.swift
//  Document Scanner
//
//  Created by Sandesh on 08/03/21.
//

import UIKit
import WeScan

protocol ScannerVCDelegate: class {
    func cancelScanning(_ controller: ScannerVC)
    func didScannedDocumentImage(_ image: UIImage, quad: Quadrilateral?, controller: ScannerVC)
}
class ScannerVC: UIViewController {
    
    private var footerCornerRadius: CGFloat = 24
    private var scannerVC: CameraScannerViewController!
    private var images = [UIImage]() {
        didSet {
            if images.count > 0 {
                //for multiple scan
            }
        }
    }
    
    var delegate: ScannerVCDelegate?

    // MARK: - IBOutlets
    @IBOutlet private weak var cameraPreview: UIView!
    @IBOutlet private weak var footerView: UIView!
    @IBOutlet private weak var scanImage: UIButton!
    @IBOutlet private weak var cancelButton: UIButton!
    @IBOutlet private weak var flashButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _setupViews()
        _setupCameraPreview()
    }
    
    private func _setupViews() {
        footerView.layer.cornerRadius = footerCornerRadius
        footerView.clipsToBounds = true
    }
    
    private func _setupCameraPreview() {
        scannerVC = CameraScannerViewController()
        scannerVC.view.frame = cameraPreview.bounds
        scannerVC.willMove(toParent: self)
        scannerVC.isAutoScanEnabled = false
        cameraPreview.addSubview(scannerVC.view)
        self.addChild(scannerVC)
        scannerVC.didMove(toParent: self)
        scannerVC.delegate = self
    }
    
    @IBAction func flashButtonTapped(_ sender: UIButton) {
        scannerVC.toggleFlash()
    }
    
    @IBAction func captureButtonTapped(_ sender: UIButton) {
        scannerVC.capture()
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        delegate?.cancelScanning(self)
    }
    
}

extension ScannerVC : CameraScannerViewOutputDelegate {
    func captureImageFailWithError(error: Error) {
        print("Image Captured Failed")
    }
    
    func captureImageSuccess(image: UIImage, withQuad quad: Quadrilateral?) {
        delegate?.didScannedDocumentImage(image,quad: quad, controller: self)
    }
}
