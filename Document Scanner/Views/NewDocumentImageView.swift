//
//  NewDocumentImageView.swift
//  Document Scanner
//
//  Created by Sandesh on 12/05/21.
//

import UIKit
import SwiftUI
import SnapKit
import WeScan

class NewDocumentImageViewController: UIViewController {
    
    private var image: UIImage
    private var quad: Quadrilateral?
    private var finalImage: UIImage?
    private let editImageVC: EditImageViewController!
    private var onCrop: ((UIImage) -> Void)?
    
    init(_ image: UIImage, shouldRotate: Bool, quad: Quadrilateral?) {
        self.image = image
        editImageVC = EditImageViewController(image: image,
                                              quad: quad,
                                              rotateImage: shouldRotate,
                                              strokeColor: UIColor.primary.cgColor)
        
        super.init(nibName: nil, bundle: nil)
        editImageVC.delegate = self
        _setupView()
    }
    
    required init?(coder: NSCoder) {
        image = UIImage()
        editImageVC = nil
        super.init(coder: coder)
        _setupView()
    }
    
    private func _setupView() {
        view.backgroundColor = .shadow
        view.addSubview(editImageVC.view)
        editImageVC.view.snp.makeConstraints { make in
            make.top.right.bottom.left.equalToSuperview()
        }
    }
    
    var currentImage: UIImage {
        return finalImage ?? image
    }
    
    func cropImage(completionHandler: @escaping ((UIImage) -> Void)) {
        self.onCrop = completionHandler
        editImageVC.cropImage()
    }
}

extension NewDocumentImageViewController: EditImageViewDelegate {
    func cropped(image: UIImage) {
        onCrop?(image)
    }
}

@available(iOS 13, *)
struct NewDocumentImageView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            UIKitPreview(view: NewDocumentImageViewController(UIImage(named: "share-document")!, shouldRotate: false, quad: nil).view)
                .previewLayout(.fixed(width: 200, height:400))
        }
    }
}
