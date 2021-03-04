//
//  ApplicationCoordinator.swift
//  Document Scanner
//
//  Created by Sandesh on 04/03/21.
//

import UIKit

class ApplicationCoordinator: Coordinator {
    
    var window: UIWindow
    
    var rootViewController: UIViewController
    var childCoordinator: [Coordinator] = []
    
    func start() {
        window.rootViewController = rootViewController
        window.makeKeyAndVisible()
    }
    
    
    init(_ window: UIWindow) {
        self.window = window
        let homeViewController = HomeViewController()
        rootViewController = homeViewController
        homeViewController.delegate = self
    }
}

extension ApplicationCoordinator: HomeViewControllerDelegate {
    func scanNewDocument(_ controller: HomeViewController) {
        
    }
    
    func pickNewDocument(_ controller: HomeViewController) {
        
    }
    
    func showSettings(_ controller: HomeViewController) {
        
    }
    
    
}
