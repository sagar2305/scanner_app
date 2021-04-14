//
//  CorrectionVC.swift
//  Document Scanner
//
//  Created by Sandesh on 14/04/21.
//

import UIKit
import WeScan

protocol CorrectionVCDelegate: class {
    func correctionVC(_ viewController: CorrectionVC, didTapBack button: UIButton)
    func correctionVC(_ viewController: CorrectionVC, final image: UIImage)
    func correctionVC(_ viewController: CorrectionVC, didTapRetake button: UIButton)
}

class CorrectionVC: DocumentScannerViewController {

    private var _editVC: EditImageViewController!
    var image: UIImage?
    var quad: Quadrilateral?
    
    @IBOutlet private weak var backButton: UIButton!
    @IBOutlet private weak var doneButton: UIButton!
    @IBOutlet private weak var retakeButton: UIButton!
    @IBOutlet private weak var imageContainerView: UIView!
    
    weak var delegate: CorrectionVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _setupViews()
    }
    
    private func _setupViews() {
        guard  let image = image else {
            fatalError("ERROR: Image is not set")
        }
        _editVC = WeScan.EditImageViewController(image: image, quad: quad,rotateImage: false, strokeColor: UIColor.primary.cgColor)
        _editVC?.view.backgroundColor = .backgroundColor
        _editVC.view.frame = imageContainerView.bounds
        _editVC.willMove(toParent: self)
        imageContainerView.addSubview(_editVC.view)
        self.addChild(_editVC)
        _editVC.didMove(toParent: self)
        _editVC.delegate = self
    }
    
    @IBAction func didTapDoneButton(_ sender: UIButton) {
        _editVC.cropImage()
    }
    
    @IBAction func didTapRescanButton(_ sender: UIButton) {
        delegate?.correctionVC(self, didTapRetake: sender)
    }
    
    @IBAction func didTapBackButton(_ sender: UIButton) {
        delegate?.correctionVC(self, didTapBack: sender)
    }
}

extension CorrectionVC: EditImageViewDelegate {
    func cropped(image: UIImage) {
        delegate?.correctionVC(self, final: image)
    }
}
