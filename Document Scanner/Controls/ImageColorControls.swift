//
//  ImageColorControls.swift
//  Document Scanner
//
//  Created by Sandesh on 21/04/21.
//

import Foundation

import UIKit
import SwiftUI
import SnapKit


class ImageColorControls: UIView {
    
    var onOriginalTap: ((FooterButton) -> Void)?
    var onGrayScaleTap: ((FooterButton) -> Void)?
    var onBlackAndWhiteTap: ((FooterButton) -> Void)?

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var originalFooterButton: FooterButton = {
        let footerButton = FooterButton()
        footerButton.title = "Original".localized
        footerButton.setImage(UIImage(named: "filter")!, for: .normal)
        footerButton.textColor = .text
        footerButton.addTarget(self, action: #selector(_originalButtonTapped(_:)), for: .touchUpInside)
        return footerButton
    }()
    
    private lazy var grayScaleFooterButton: FooterButton = {
        let footerButton = FooterButton()
        footerButton.title = "Gray Scale".localized
        footerButton.setImage(UIImage(named: "gray_scale")!, for: .normal)
        footerButton.textColor = .text
        footerButton.addTarget(self, action: #selector(_grayScaleButtonTapped(_:)), for: .touchUpInside)
        return footerButton
    }()
    
    private lazy var blackAndWhiteFooterButton: FooterButton = {
        let footerButton = FooterButton()
        footerButton.title = "B&W".localized
        footerButton.setImage(UIImage(named: "black_and_white")!, for: .normal)

        footerButton.textColor = .text
        footerButton.addTarget(self, action: #selector(_blackAndWhiteButtonTapped(_:)), for: .touchUpInside)
        return footerButton
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        _setupView()
    }
    
    private func _setupView() {
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.right.left.equalTo(self).inset(16)
            make.top.equalTo(self)
            make.bottom.equalTo(self)
        }
        
        stackView.spacing = self.bounds.width + 0.05
        stackView.addArrangedSubview(originalFooterButton)
        stackView.addArrangedSubview(grayScaleFooterButton)
        stackView.addArrangedSubview(blackAndWhiteFooterButton)
    }
    
    @objc private func _originalButtonTapped(_ sender: FooterButton) {
        onOriginalTap?(sender)
    }
    
    @objc private func _grayScaleButtonTapped(_ sender: FooterButton) {
        onGrayScaleTap?(sender)
    }
    
    @objc private func _blackAndWhiteButtonTapped(_ sender: FooterButton) {
        onBlackAndWhiteTap?(sender)
    }
}

@available(iOS 13, *)
struct ImageColorControls_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            UIKitPreview(view: ImageColorControls())
                .previewLayout(.fixed(width: 320, height:52))
        }
    }
}
