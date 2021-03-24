//
//  DocumentReviewVC.swift
//  Document Scanner
//
//  Created by Sandesh on 17/03/21.
//

import UIKit

class DocumentReviewVC: UIViewController {

    
    var document: Document?
    @IBOutlet private weak var cancelButton: UIButton!
    @IBOutlet private weak var documentImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _setupView()
        
    }

    private func _setupView() {
        guard  let document = document else {
            fatalError("ERROR: document is not set")
        }
        documentImageView.image = document.pages.first?.editedImage
    }
    
    @IBAction func didTapCancel(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}
