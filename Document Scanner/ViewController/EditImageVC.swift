//
//  EditImageVC.swift
//  Document Scanner
//
//  Created by Sandesh on 08/03/21.
//

import UIKit
import WeScan

class EditImageVC: UIViewController {

    private var editVC: EditImageViewController!
    
    var quad: Quadrilateral?
    var imageToEdit: UIImage?
    
    // MARK: - IBoutlets
    @IBOutlet weak var imageEditorView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        _setupEditorView()
    }
    
    private func setupViews() {
        
    }
    
    private func _setupEditorView() {
        
        guard let imageToEdit = imageToEdit , let quad = quad else {
            fatalError("ERROR: No image or quad is set for editings")
        }
        
        editVC = WeScan.EditImageViewController(image: imageToEdit, quad: quad, strokeColor: UIColor(red: (69.0 / 255.0), green: (194.0 / 255.0), blue: (177.0 / 255.0), alpha: 1.0).cgColor)
        editVC.view.frame = imageEditorView.bounds
        editVC.willMove(toParent: self)
        imageEditorView.addSubview(editVC.view)
               self.addChild(editVC)
        editVC.didMove(toParent: self)
        editVC.delegate = self
    }

}

extension EditImageVC: EditImageViewDelegate {
    func cropped(image: UIImage) {
        
    }
}
