//
//  ScannerVC.swift
//  Document Scanner
//
//  Created by Sandesh on 08/03/21.
//

import UIKit
import WeScan
import PMAlertController

protocol ScannerVCDelegate: AnyObject {
    func cancelScanning(_ controller: ScannerVC)
    func scannerVC(_ controller: ScannerVC, finishedScanning images: [NewDocumentImageViewController])
}
class ScannerVC: UIViewController {
    
    private var scannerVC: CameraScannerViewController!
    private var images = [NewDocumentImageViewController]() {
        didSet {
            if images.count > 0 {
                scanImageButton.setTitle("\(images.count)", for: .normal)
            } else {
                scanImageButton.setTitle("", for: .normal)
            }
        }
    }
    
    var delegate: ScannerVCDelegate?

    // MARK: - IBOutlets
    @IBOutlet private weak var cameraPreview: UIView!
    
    @IBOutlet private weak var scanImageButton: UIButton!
    @IBOutlet private weak var cancelButton: UIButton!
    @IBOutlet private weak var flashButton: UIButton!
    @IBOutlet private weak var doneButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _setupViews()
        _setupCameraPreview()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        images = []
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    private func _setupViews() {
        doneButton.titleLabel?.configure(with: UIFont.font(.avenirMedium, style: .callout))
        doneButton.setTitle("Done".localized, for: .normal)
        scanImageButton.titleLabel?.configure(with: UIFont.font(.avenirBook, style: .headline))
        scanImageButton.setTitle("", for: .normal)
    }
    
    private func _setupCameraPreview() {
        scannerVC = CameraScannerViewController()
        scannerVC.view.frame = cameraPreview.bounds
        scannerVC.willMove(toParent: self)
        scannerVC.isAutoScanEnabled = true
        cameraPreview.subviews.forEach { $0.removeFromSuperview()  }
        cameraPreview.addSubview(scannerVC.view)
        self.addChild(scannerVC)
        scannerVC.didMove(toParent: self)
        scannerVC.delegate = self
    }
    
    @IBAction private func didTapDone(_ sender: UIButton) {
        if images.count > 0 {
            delegate?.scannerVC(self, finishedScanning: images)
        } else {
            let alertVC = PMAlertController(title: "Scan at-least one document to continue.".localized,
                                            description: nil,
                                            image: nil,
                                            style: .alert)
            alertVC.alertTitle.textColor = .primary
            let okAction = PMAlertAction(title: "OK".localized, style: .default) {
            }
            okAction.setTitleColor(.primary, for: .normal)
            alertVC.addAction(okAction)
            alertVC.gravityDismissAnimation = false
            present(alertVC, animated: true, completion: nil)
        }
        
    }
    
    @IBAction private func flashButtonTapped(_ sender: UIButton) {
        scannerVC.toggleFlash()
    }
    
    @IBAction private func captureButtonTapped(_ sender: UIButton) {
        scannerVC.capture()
    }
    
    @IBAction private func cancelButtonTapped(_ sender: UIButton) {
        delegate?.cancelScanning(self)
    }
    
}

extension ScannerVC : CameraScannerViewOutputDelegate {
    func captureImageFailWithError(error: Error) {
        print("Image Captured Failed")
    }
    
    func captureImageSuccess(image: UIImage, withQuad quad: Quadrilateral?) {
        images.append(NewDocumentImageViewController(image,
                                                     shouldRotate: true,
                                                     quad: quad))
        scannerVC.viewWillAppear(true)
    }
}
