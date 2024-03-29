//
//  ImageCorrectionControls.swift
//  Document Scanner
//
//  Created by Sandesh on 04/05/21.
//

import UIKit
import SwiftUI
import SnapKit

class ImageCorrectionControls: UIView {
    
    var onEditTap: ((FooterButton) -> Void)?
    var onRescanTap: ((FooterButton) -> Void)?
    var onDoneTap: ((UIButton) -> Void)?
    var onPreviousPageTap: ((FooterButton) -> Void)?
    var onNextPageTap: ((FooterButton) -> Void)?

    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var editFooterButton: FooterButton = {
        let footerButton = FooterButton()
        footerButton.setTitle("Edit".localized, for: .normal)
        footerButton.setImage(UIImage(named: "edit")!, for: .normal)
        footerButton.addTarget(self, action: #selector(_editButtonTapped(_:)), for: .touchUpInside)
        footerButton.translatesAutoresizingMaskIntoConstraints = false
        return footerButton
    }()
    
    private lazy var rescanFooterButton: FooterButton = {
        let footerButton = FooterButton()
        footerButton.setTitle("Rescan".localized, for: .normal)
        footerButton.setImage(UIImage(named: "rescan")!, for: .normal)
        footerButton.addTarget(self, action: #selector(_rescanButtonTapped(_:)), for: .touchUpInside)
        footerButton.translatesAutoresizingMaskIntoConstraints = false
        return footerButton
    }()
    
    private lazy var doneButton: UIButton = {
        let footerButton = UIButton()
        footerButton.setTitleColor(.text, for: .normal)
        footerButton.setImage(UIImage(named: "done-ellipse")!, for: .normal)
        footerButton.addTarget(self, action: #selector(_doneButtonTapped(_:)), for: .touchUpInside)
        footerButton.translatesAutoresizingMaskIntoConstraints = false
        return footerButton
    }()
    
    private lazy var previousPageFooterButton: FooterButton = {
        let footerButton = FooterButton()
        footerButton.setTitle("Previous".localized, for: .normal)
        footerButton.setImage(UIImage(named: "previous")!, for: .normal)
        footerButton.addTarget(self, action: #selector(_previousPageButtonTapped(_:)), for: .touchUpInside)
        footerButton.translatesAutoresizingMaskIntoConstraints = false
        return footerButton
    }()
    
    private lazy var nextPageFooterButton: FooterButton = {
        let footerButton = FooterButton()
        footerButton.setTitle("Next", for: .normal)
        footerButton.setImage(UIImage(named: "next")!, for: .normal)
        footerButton.addTarget(self, action: #selector(_nextPageButtonTapped(_:)), for: .touchUpInside)
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
    
    var setPreviousButtonHidden = false {
        didSet {
            previousPageFooterButton.alpha = setPreviousButtonHidden ? 0.0 : 1.0
        }
    }
    
    var setNextButtonHidden = false {
        didSet {
            nextPageFooterButton.alpha = setNextButtonHidden ? 0.0 : 1.0
        }
    }
    
    private func _setupView() {
        
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.right.greaterThanOrEqualToSuperview().inset(2)
            make.left.lessThanOrEqualToSuperview().inset(32)
            make.centerX.equalToSuperview()
            make.top.equalTo(self)
            make.bottom.equalTo(self)
        }
        
       
        editFooterButton.snp.makeConstraints { make in
            make.height.width.equalTo(32)
        }
        
        rescanFooterButton.snp.makeConstraints { make in
            make.height.width.equalTo(32)
        }
        
        previousPageFooterButton.snp.makeConstraints { make in
            make.height.width.equalTo(32)
        }
        
        nextPageFooterButton.snp.makeConstraints { make in
            make.height.width.equalTo(32)
        }
        
        let container = UIView()
        container.addSubview(doneButton)
       
        doneButton.snp.makeConstraints { make in
            make.height.equalToSuperview()
            make.width.equalTo(doneButton.snp .height)
            make.centerX.centerY.equalToSuperview()
        }
        
        stackView.addArrangedSubview(previousPageFooterButton)
        stackView.addArrangedSubview(editFooterButton)
        stackView.addArrangedSubview(container)
        stackView.addArrangedSubview(rescanFooterButton)
        stackView.addArrangedSubview(nextPageFooterButton)
        
        
        container.snp.makeConstraints {make in
            make.height.equalToSuperview()
        }
        
    }
    
    @objc private func _rescanButtonTapped(_ sender: FooterButton) {
        onRescanTap?(sender)
    }
    
    @objc private func _editButtonTapped(_ sender: FooterButton) {
        onEditTap?(sender)
    }
    
    @objc private func _doneButtonTapped(_ sender: UIButton) {
        onDoneTap?(sender)
    }
    
    @objc private func _previousPageButtonTapped(_ sender: FooterButton) {
        onPreviousPageTap?(sender)
    }
    
    @objc private func _nextPageButtonTapped(_ sender: FooterButton) {
        onNextPageTap?(sender)
    }
}

@available(iOS 13, *)
struct ImageCorrectionControls_Preview: PreviewProvider {
    static var previews: some View {
        Group {
            UIKitPreview(view: ImageCorrectionControls())
                .previewLayout(.fixed(width: 320, height:52))
        }
    }
}
