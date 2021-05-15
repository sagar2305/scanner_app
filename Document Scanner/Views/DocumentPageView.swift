//
//  DocumentPageView.swift
//  Document Scanner
//
//  Created by Sandesh on 30/04/21.
//

import UIKit
import SwiftUI

class DocumentPageView: UIView {
    
    private var image: UIImage
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    init(_ page: Page) {
        guard let editedImage = page.editedImage else {
            fatalError("No edited image available for page")
        }
        self.image = editedImage
        super.init(frame: .zero)
        _setupView()
    }
    
    required init?(coder: NSCoder) {
        image = UIImage()
        super.init(coder: coder)
        _setupView()
    }
    
    private func _setupView() {
        backgroundColor = .shadow
        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.top.right.bottom.left.equalToSuperview()
        }
    }
    
}

// MARK: - dummy data
extension DocumentPageView {
    fileprivate static let page = Page(documentID: "xx"
                                       , originalImage: UIImage(named: "share-document")!,
                                       editedImage: UIImage(named: "share-document")!)!
}

@available(iOS 13, *)
struct DocumentPageView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            UIKitPreview(view: DocumentPageView(DocumentPageView.page))
                .previewLayout(.fixed(width: 200, height:400))
        }
    }
}
