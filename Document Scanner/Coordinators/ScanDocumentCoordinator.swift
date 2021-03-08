//
//  ScanDocumentCoordinator.swift
//  Document Scanner
//
//  Created by Sandesh on 05/03/21.
//

import UIKit
import WeScan

class ScanDocumentCoordinator: Coordinator {
    
    var rootViewController: UIViewController {
        return navigationController
    }
    
    var childCoordinator: [Coordinator] = []
    
    var navigationController: UINavigationController
    
    init(_ controller: UINavigationController) {
        self.navigationController = controller
    }
    
    func start() {
        let scanDocumentVC = ScannerVC()
        scanDocumentVC.delegate = self
        navigationController.pushViewController(scanDocumentVC, animated: true)
    }
}


extension ScanDocumentCoordinator: ScannerVCDelegate {
    func cancelScanning(_ controller: ScannerVC) {
        navigationController.popViewController(animated: true)
    }
    
    func didScannedDocumentImage(_ image: UIImage,quad: Quadrilateral?, controller: ScannerVC) {
        let editImageVC = EditImageVC()
        editImageVC.imageToEdit = image
        editImageVC.quad = quad
        navigationController.pushViewController(editImageVC, animated: true)
    }
    
    
}
