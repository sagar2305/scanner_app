//
//  ImageEditingControls.swift
//  Document Scanner
//
//  Created by Sandesh on 20/04/21.
//

import UIKit
import SwiftUI
import SnapKit

class ImageEditorControls: UIView {
    
    var onTransformTap: ((FooterButton) -> Void)?
    var onAdjustTap: ((FooterButton) -> Void)?
    var onColorTap: ((FooterButton) -> Void)?
    var onOriginalTap: ((FooterButton) -> Void)?
    var onUndoTap: ((FooterButton) -> Void)?

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var transformFooterButton: FooterButton = {
        let footerButton = FooterButton()
        footerButton.title = "Transform"
        footerButton.textColor = .text
        footerButton.icon = UIImage(named: "transform")!
        footerButton.addTarget(self, action: #selector(_transformButtonTapped(_:)), for: .touchUpInside)
        return footerButton
    }()
    
    private lazy var adjustFooterButton: FooterButton = {
        let footerButton = FooterButton()
        footerButton.title = "Adjust"
        footerButton.textColor = .text
        footerButton.icon = UIImage(named: "adjust")!
        footerButton.addTarget(self, action: #selector(_adjustButtonTapped(_:)), for: .touchUpInside)
        return footerButton
    }()
    
    private lazy var colorFooterButton: FooterButton = {
        let footerButton = FooterButton()
        footerButton.title = "Color"
        footerButton.textColor = .text
        footerButton.icon = UIImage(named: "filter")!
        footerButton.addTarget(self, action: #selector(_colorButtonTapped(_:)), for: .touchUpInside)
        return footerButton
    }()
    
    private lazy var editOriginalFooterButton: FooterButton = {
        let footerButton = FooterButton()
        footerButton.title = "Original"
        footerButton.textColor = .text
        footerButton.icon = UIImage(named: "edit")!
        footerButton.addTarget(self, action: #selector(_originalButtonTapped(_:)), for: .touchUpInside)
        return footerButton
    }()
    
    var editOriginalImageOptionIsHidden = false {
        didSet { editOriginalFooterButton.isHidden = editOriginalImageOptionIsHidden }
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
        stackView.addArrangedSubview(transformFooterButton)
        stackView.addArrangedSubview(adjustFooterButton)
        stackView.addArrangedSubview(colorFooterButton)
        stackView.addArrangedSubview(editOriginalFooterButton)
        //stackView.addArrangedSubview(undoFooterButton)
    }
    
    @objc private func _transformButtonTapped(_ sender: FooterButton) {
        onTransformTap?(sender)
    }
    
    @objc private func _adjustButtonTapped(_ sender: FooterButton) {
        onAdjustTap?(sender)
    }
    
    @objc private func _colorButtonTapped(_ sender: FooterButton) {
        onColorTap?(sender)
    }
    
    @objc private func _originalButtonTapped(_ sender: FooterButton) {
        onOriginalTap?(sender)
    }
    
    @objc private func _undoButtonTapped(_ sender: FooterButton) {
        onUndoTap?(sender)
    }
}


@available(iOS 13, *)
struct ImageEditorControls_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            UIKitPreview(view: ImageEditorControls())
                .previewLayout(.fixed(width: 320, height:52.0))
        }
    }
}
