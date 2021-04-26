//
//  OnboardingView.swift
//  Document Scanner
//
//  Created by Sandesh on 26/04/21.
//

import UIKit
import SnapKit
import SwiftUI

class OnboardingView: UIView {
    
    private var header: String
    private var desc: String
    private var image: UIImage
    private lazy var headerLabel: UILabel = {
        let label = UILabel()
        label.configure(with: UIFont.font(.avenirMedium, style: .title1))
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.configure(with: UIFont.font(.avenirLight, style: .title3))
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .secondaryText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    
    
    init(header: String, description: String, image: UIImage) {
        self.header = header
        self.desc = description
        self.image = image
        super.init(frame: .zero)
        _setupView()
    }
    
    required init?(coder: NSCoder) {
        self.header = ""
        self.desc = ""
        self.image = UIImage()
        super.init(coder: coder)
        _setupView()
    }
    
    private func _setupView() {
        addSubview(headerLabel)
        headerLabel.text = header
        headerLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(12)
            make.top.equalToSuperview().inset(16)
        }
        
        addSubview(descriptionLabel)
        descriptionLabel.text = desc
        descriptionLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(8)
            make.top.equalTo(headerLabel.snp.bottom).offset(12)
        }
        
        addSubview(imageView)
        imageView.image = image
        imageView.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(16)
            make.left.right.equalToSuperview().offset(8)
            make.bottom.lessThanOrEqualToSuperview()
            
        }
    }
}


@available(iOS 13, *)
struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            UIKitPreview(view: OnboardingView(header: "EASY TO USE",
                                              description:"Quickly scan or select and generate digital copy of your document",
                                              image: UIImage(named: "share-document")!))
                .previewLayout(.fixed(width: 200, height:400))
        }
    }
}

