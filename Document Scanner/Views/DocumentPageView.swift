//
//  DocumentPageView.swift
//  Document Scanner
//
//  Created by Sandesh on 30/04/21.
//

import UIKit
import SwiftUI

class DocumentPageViewController: UIViewController {
    
    var page: Page
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    init(_ page: Page) {
        self.page = page
        super.init(nibName: nil, bundle: nil)
        _setupView()
    }
    
    required init?(coder: NSCoder) {
        page = Page(documentID: "",
                    originalImage: UIImage(),
                    editedImage: UIImage())!
        super.init(coder: coder)
        view.isUserInteractionEnabled = false
        imageView.isUserInteractionEnabled = false
        _setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        imageView.image = page.editedImage
    }
    
    private func _setupView() {
        view.backgroundColor = .shadow
        view.addSubview(imageView)
        imageView.image = page.editedImage
        imageView.snp.makeConstraints { make in
            make.top.right.bottom.left.equalToSuperview()
        }
    }
    
}

// MARK: - dummy data
extension DocumentPageViewController {
    fileprivate static let page = Page(documentID: "xx"
                                       , originalImage: UIImage(named: "share-document")!,
                                       editedImage: UIImage(named: "share-document")!)!
}

@available(iOS 13, *)
struct DocumentPageView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            UIKitPreview(view: DocumentPageViewController(DocumentPageViewController.page).view)
                .previewLayout(.fixed(width: 200, height:400))
        }
    }
}
