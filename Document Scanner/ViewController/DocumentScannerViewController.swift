//
//  DocumentScannerViewController.swift
//  Document Scanner
//
//  Created by Sandesh on 19/03/21.
//

import UIKit

class DocumentScannerViewController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        extendedLayoutIncludesOpaqueBars = true
        hero.isEnabled = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        hero.isEnabled = false
    }

}
