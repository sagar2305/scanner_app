//
//  FoldersCoordinator.swift
//  Document Scanner
//
//  Created by Sandesh on 02/09/21.
//

import UIKit

@available(iOS 13, *)
class FoldersCoordinator: Coordinator {
    var rootViewController: UIViewController {
        return navigationController
    }
    
    let navigationController: DocumentScannerNavigationController
    
    var folderViewController: FolderViewController
    var folder: Folder
    var childCoordinators: [Coordinator] = []
    
    
        
    init(_ navigationController: DocumentScannerNavigationController, folder: Folder) {
        self.navigationController = navigationController
        folderViewController = FolderViewController()
        self.folder = folder
        folderViewController.folder = folder
        folderViewController.delegate = self
    }
    
    func start() {
        navigationController.pushViewController(folderViewController, animated: true)
    }
}

@available(iOS 13, *)
extension FoldersCoordinator: FolderViewControllerDelegate {
    func viewDidAppear(_controller: FolderViewController) {
        
    }
    
    func exit(_ controller: FolderViewController) {
        navigationController.popViewController(animated: true)
    }
    
    func viewDocument(_ controller: FolderViewController, document: Document) {
        let documentViewerCoordinator = DocumentViewerCoordinator(navigationController, document: document)
        childCoordinators.append(documentViewerCoordinator)
        documentViewerCoordinator.start()
    }
    
    
}
