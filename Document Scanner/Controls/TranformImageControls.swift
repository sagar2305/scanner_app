//
//  TransformImageControls.swift
//  Document Scanner
//
//  Created by Sandesh on 19/04/21.
//

import UIKit
import SwiftUI
import SnapKit


class TransformImageControls: UIView {
    
    var onRotationTap: ((FooterButton) -> Void)?
    var onCropTap: ((FooterButton) -> Void)?
    var onMirrorTap: ((FooterButton) -> Void)?

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var rotateFooterButton: FooterButton = {
        let footerButton = FooterButton()
        footerButton.title = "Rotate".localized
        footerButton.textColor = .text
        footerButton.icon = UIImage(named: "rotate")!
        footerButton.addTarget(self, action: #selector(_rotationButtonTapped(_:)), for: .touchUpInside)
        return footerButton
    }()
    
    private lazy var cropFooterButton: FooterButton = {
        let footerButton = FooterButton()
        footerButton.title = "Crop".localized
        footerButton.textColor = .text
        footerButton.icon = UIImage(named: "crop")!
        footerButton.addTarget(self, action: #selector(_cropButtonTapped(_:)), for: .touchUpInside)
        return footerButton
    }()
    
    private lazy var mirrorFooterButton: FooterButton = {
        let footerButton = FooterButton()
        footerButton.title = "Mirror".localized
        footerButton.textColor = .text
        footerButton.icon = UIImage(named: "mirror")!
        footerButton.addTarget(self, action: #selector(_mirrorButtonTapped(_:)), for: .touchUpInside)
        return footerButton
    }()
    
    var cropImageOptionIsHidden = false {
        didSet { cropFooterButton.isHidden = cropImageOptionIsHidden }
    }
    
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
        stackView.addArrangedSubview(rotateFooterButton)
        stackView.addArrangedSubview(cropFooterButton)
        stackView.addArrangedSubview(mirrorFooterButton)
    }
    
    @objc private func _rotationButtonTapped(_ sender: FooterButton) {
        onRotationTap?(sender)
    }
    
    @objc private func _cropButtonTapped(_ sender: FooterButton) {
        onCropTap?(sender)
    }
    
    @objc private func _mirrorButtonTapped(_ sender: FooterButton) {
        onMirrorTap?(sender)
    }
    
}

@available(iOS 13, *)
struct TransformImageControls_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            UIKitPreview(view: TransformImageControls())
                .previewLayout(.fixed(width: 320, height:52.0))
        }
    }
}
