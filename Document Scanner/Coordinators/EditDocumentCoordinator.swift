//
//  EditDocumentCoordinator.swift
//  Document Scanner
//
//  Created by Sandesh on 17/03/21.
//

import UIKit

class EditDocumentCoordinator: Coordinator {
    
    
    var navigationController: UINavigationController
    var childCoordinator: [Coordinator] = []
    var rootViewController: UIViewController {
        return navigationController
    }
    var parentCoordinator: Coordinator!
    
    //document editing mode a document is passed for editing
    var document: Document?
    // document capturing mode images is passed for editing
    var image: [UIImage]?
    
    init(_ controller: UINavigationController) {
        navigationController = controller
    }
    
    func start() {
        
    }
}
