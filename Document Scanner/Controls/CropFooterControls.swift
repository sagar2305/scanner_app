//
//  CropFooterControls.swift
//  Document Scanner
//
//  Created by Sandesh on 25/04/21.
//

import UIKit
import SwiftUI
import SnapKit

class CropFooterControls: UIView {
    
    var onCropTap: ((UIButton) -> Void)?
    var onCancelTap: ((UIButton) -> Void)?

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var cancelFooterButton: UIButton = {
        let footerButton = UIButton()
        footerButton.titleLabel?.configure(with: UIFont.font(.avenirMedium, style: .callout))
        footerButton.setTitle("Cancel".localized, for: .normal)
        footerButton.setTitleColor(.text, for: .normal)
        footerButton.addTarget(self, action: #selector(_cancelButtonTapped(_:)), for: .touchUpInside)
        footerButton.translatesAutoresizingMaskIntoConstraints = false
        return footerButton
    }()
    
    private lazy var cropFooterButton: UIButton = {
        let footerButton = UIButton()
        footerButton.titleLabel?.configure(with: UIFont.font(.avenirMedium, style: .callout))
        footerButton.setTitle("Crop".localized, for: .normal)
        footerButton.setTitleColor(.text, for: .normal)
        footerButton.addTarget(self, action: #selector(_cropButtonTapped(_:)), for: .touchUpInside)
        footerButton.translatesAutoresizingMaskIntoConstraints = false
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
        addSubview(cancelFooterButton)
        cancelFooterButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(8)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(55)
        }
        
        addSubview(cropFooterButton)
        cropFooterButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-8)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(55)
        }
    }
    
    @objc private func _cropButtonTapped(_ sender: UIButton) {
        onCropTap?(sender)
    }
    
    @objc private func _cancelButtonTapped(_ sender: UIButton) {
        onCancelTap?(sender)
    }
}

@available(iOS 13, *)
struct CropFooterControl_Preview: PreviewProvider {
    static var previews: some View {
        Group {
            UIKitPreview(view: CropFooterControls())
                .previewLayout(.fixed(width: 320, height:52))
        }
    }
}
