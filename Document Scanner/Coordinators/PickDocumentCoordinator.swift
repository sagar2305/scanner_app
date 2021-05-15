//
//  PickDocumentCoordinator.swift
//  Document Scanner
//
//  Created by Sandesh on 04/03/21.
//

import UIKit
import NVActivityIndicatorView
import WeScan
import PMAlertController
import Photos
import Tatsi

protocol PickerDocumentCoordinatorDelegate {
    func didFinishedPickingImage(_ coordinator: PickDocumentCoordinator)
    func didCancelPickingImage(_ coordinator: PickDocumentCoordinator)
}

class PickDocumentCoordinator: NSObject, Coordinator {
    var rootViewController: UIViewController {
        return navigationController
    }

    var childCoordinators: [Coordinator] = []
    var delegate: PickerDocumentCoordinatorDelegate?
    var navigationController: DocumentScannerNavigationController
    var correctionVC: CorrectionVC!
    private var isCorrectionVCPresented = false
    private var pageControlItems = [NewDocumentImageViewController]()

    func start() {
       _pickDocument()
    }
    
    init(_ rootViewController: DocumentScannerNavigationController) {
        navigationController = rootViewController
    }
    
    private func _pickDocument() {
        let tatsiImagePicker = TatsiPickerViewController()
        tatsiImagePicker.pickerDelegate = self
        navigationController.present(tatsiImagePicker, animated: true)
   }
    
    private func presentImageCorrectionViewController() {
        guard pageControlItems.count > 0 else {
            fatalError("No page control items are available")
        }
        correctionVC = CorrectionVC()
        correctionVC.delegate = self
        correctionVC.dataSource = self
        correctionVC.pageControllerItems = pageControlItems
        navigationController.pushViewController(correctionVC, animated: true)
        isCorrectionVCPresented = true
    }

}

extension PickDocumentCoordinator: CorrectionVCDelegate {
    func correctionVC(_ viewController: CorrectionVC, didFinishCorrectingImages imageVCs: [NewDocumentImageViewController]) {
        NVActivityIndicatorView.start()
        imageVCs.forEach { $0.cropImage() }
        let originalImages = imageVCs.map { $0.originalImage }
        let editedImages = imageVCs.map { $0.finalImage }
    
        if let document = Document(originalImages: originalImages, editedImages: editedImages) {
            document.save()
            NVActivityIndicatorView.stop()
            navigationController.popViewController(animated: true)
        } else {
            let alertVC = PMAlertController(title: "Something went wrong",
                                            description: "Unable to save generate your document, please try again",
                                            image: nil,
                                            style: .alert)
            alertVC.alertTitle.textColor = .primary
            let okAction = PMAlertAction(title: "OK", style: .default) {
                self.navigationController.popViewController(animated: true)
            }
            okAction.setTitleColor(.primary, for: .normal)
            alertVC.addAction(okAction)
            alertVC.gravityDismissAnimation = false
            viewController.present(alertVC, animated: true, completion: nil)
        }
    }
    
    func correctionVC(_ viewController: CorrectionVC, originalImages: [UIImage], finalImages: [UIImage]) {
        if let document = Document(originalImages: originalImages, editedImages: finalImages) {
            document.save()
            navigationController.popViewController(animated: true)
        }
    }
    
    func correctionVC(_ viewController: CorrectionVC, didTapBack button: UIButton) {
        delegate?.didCancelPickingImage(self)
    }
    
    func correctionVC(_ viewController: CorrectionVC, edit image: UIImage) {
        let editDocumentCoordinator = EditDocumentCoordinator(navigationController, edit: image)
        editDocumentCoordinator.delegate = self
        childCoordinators.append(editDocumentCoordinator)
        editDocumentCoordinator.start()
    }
    
    func correctionVC(_ viewController: CorrectionVC, didTapRetake button: UIButton) {
        _pickDocument()
    }
}

extension PickDocumentCoordinator: CorrectionVCDataSource {
    func correctionVC(_ viewController: CorrectionVC, titleFor nextPage: UIButton) -> String {
        return "Pick Next"
    }
}

extension PickDocumentCoordinator: EditDocumentCoordinatorDelegate {
    func didFinishEditing(_ image: UIImage, editedImage: UIImage, _ coordinator: EditDocumentCoordinator, isRotated: Bool) {
        correctionVC.updateEdited(image: editedImage, isRotated: isRotated)
        navigationController.popViewController(animated: true)
    }
    
    func didCancelEditing(_ coordinator: EditDocumentCoordinator) {
        navigationController.popViewController(animated: true)
    }
}

extension PickDocumentCoordinator: TatsiPickerViewControllerDelegate {
    func pickerViewController(_ pickerViewController: TatsiPickerViewController, didPickAssets assets: [PHAsset]) {
        NVActivityIndicatorView.start()
        let requestOptions = PHImageRequestOptions()
        requestOptions.resizeMode = PHImageRequestOptionsResizeMode.exact
        requestOptions.deliveryMode = PHImageRequestOptionsDeliveryMode.highQualityFormat
        // this one is key
        requestOptions.isSynchronous = true
        
        for asset in assets
        {
            if ((asset as AnyObject).mediaType == PHAssetMediaType.image)
            {
                
                PHImageManager.default().requestImage(for: asset,
                                                      targetSize: PHImageManagerMaximumSize,
                                                      contentMode: PHImageContentMode.default,
                                                      options: requestOptions, resultHandler: { (pickedImage, info) in
                                                        
                                                        guard let pickedImage = pickedImage else {
                                                            return
                                                        }
                                                        
                                                        let shouldRotate = !(pickedImage.imageOrientation == .up || pickedImage.imageOrientation == .down)
                                                        self.pageControlItems.append(NewDocumentImageViewController(pickedImage, shouldRotate: shouldRotate, quad: nil))
                                                        
                                                      })
                
            }
        }
        presentImageCorrectionViewController()
        NVActivityIndicatorView.stop()
        pickerViewController.dismiss(animated: true)
    }
    
    func pickerViewControllerDidCancel(_ pickerViewController: TatsiPickerViewController) {
        
    }
    
}
