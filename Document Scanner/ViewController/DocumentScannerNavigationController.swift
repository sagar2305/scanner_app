//
//  DocumentScannerNavigationController.swift
//  Document Scanner
//
//  Created by Sandesh on 19/03/21.
//

import UIKit

class DocumentScannerNavigationController: UINavigationController, UINavigationControllerDelegate {

    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        _customizeNavigationBar()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _customizeNavigationBar()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.prefersLargeTitles = false
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        delegate = self
    }
    
    private func _customizeNavigationBar() {
        
       
        
        UINavigationBar.appearance().barTintColor = .primary
        UINavigationBar.appearance().tintColor = .text
        UINavigationBar.appearance().isTranslucent = false
        
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        UINavigationBar.appearance().shadowImage = UIImage()
        
        
        UINavigationBar.appearance().backIndicatorImage = Icons.backArrow
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = Icons.backArrow
        UINavigationBar.appearance().backgroundColor = .primary
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hero.isEnabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        hero.isEnabled = false
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        let item = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
        viewController.navigationItem.backBarButtonItem = item
    }
    
}
 
