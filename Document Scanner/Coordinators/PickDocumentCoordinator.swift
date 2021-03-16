//
//  PickDocumentCoordinator.swift
//  Document Scanner
//
//  Created by Sandesh on 04/03/21.
//

import UIKit
import NVActivityIndicatorView

protocol PickerDocumentCoordinatorDelegate {
    func didFinishedPickingImage(_ coordinator: PickDocumentCoordinator)
    func didCancelPickingImage(_ coordinator: PickDocumentCoordinator)
}

class PickDocumentCoordinator: NSObject, Coordinator {
    var rootViewController: UIViewController {
        return navigationController
    }
    var childCoordinator: [Coordinator] = []
    
    var delegate: PickerDocumentCoordinatorDelegate?
    var navigationController: UINavigationController
    var editImageVC: EditImageVC?
    
    func start() {
       _pickDocument()
    }
    
    init(_ rootViewController: UINavigationController) {
        navigationController = rootViewController
    }
    
    private func _pickDocument() {
        let imagePickerVC = UIImagePickerController()
        imagePickerVC.sourceType = .photoLibrary
        imagePickerVC.delegate = self
        navigationController.present(imagePickerVC, animated: true)
    }
    
    private func presentImageCorrectionViewController(for image: UIImage) {
        if editImageVC == nil {
            editImageVC = EditImageVC()
            editImageVC!.imageToEdit = image
            editImageVC!.imageEditingMode = .basic
            editImageVC!.imageSource = .photo_library
            editImageVC!.delegate = self
            navigationController.pushViewController(editImageVC!, animated: true)
        } else {
            editImageVC?.imageToEdit = image
        }
    }

}


extension PickDocumentCoordinator: UIImagePickerControllerDelegate,
                                   UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        delegate?.didCancelPickingImage(self)
        rootViewController.dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard  let selectedImage = info[.originalImage] as? UIImage else {
            fatalError("Failed to pick the image from photo library")
        }
        presentImageCorrectionViewController(for: selectedImage)
        picker.dismiss(animated: true)
    }
    
}

extension PickDocumentCoordinator: EditImageVCDelegate {
    func cancelImageEditing(_controller: EditImageVC) {
        delegate?.didCancelPickingImage(self)
    }
    
    func filterImage(_ image: UIImage, controller: EditImageVC) {
        
    }
    
    func rescanImage(_ controller: EditImageVC) {
        _pickDocument()
    }
    
    func finishedImageEditing(_ finalImage: UIImage, originalImage: UIImage, documentName: String, controller: EditImageVC) {
        var quadPoints = [CGPoint]()
        guard let quad = controller.quad else {
            fatalError("ERROR: No points available")
        }
        
        let activityIndicator = NVActivityIndicatorView(frame: rootViewController.view.frame,
                                                        type: .ballRotateChase,
                                                        color: UIColor.blue,
                                                        padding: 16)
        activityIndicator.startAnimating()
        
        quadPoints.append(quad.topLeft)
        quadPoints.append(quad.topRight)
        quadPoints.append(quad.bottomLeft)
        quadPoints.append(quad.bottomRight)
        
        let document = Document(documentName,
                                originalImage: originalImage,
                                editedImage: finalImage,
                                quadrilateral: quadPoints)
        
        if document.saveOriginalImage(originalImage) && document.saveEditedImage(finalImage) {
            document.save()
            activityIndicator.stopAnimating()
            delegate?.didFinishedPickingImage(self)
        }
    }
    
    
}
