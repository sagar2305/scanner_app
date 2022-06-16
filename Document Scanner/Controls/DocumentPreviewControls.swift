//
//  DocumentPreviewControls.swift
//  Document Scanner
//
//  Created by Sandesh on 22/04/21.
//

import UIKit
import SwiftUI
import SnapKit

class DocumentPreviewControls: UIView {
    
    var onMarkupTap: ((FooterButton) -> Void)?
    var onShareTap: ((FooterButton) -> Void)?
    var onEditTap: ((FooterButton) -> Void)?
    var onDeleteTap: ((FooterButton) ->Void)?
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var markupButton: FooterButton =  {
        let footerButton = FooterButton()
        footerButton.title = "Signature".localized
        footerButton.textColor = .text
        footerButton.icon = UIImage(named: "signature")!
        footerButton.addTarget(self, action: #selector(_markupButtonTapped(_:)), for: .touchUpInside)
        return footerButton
    }()
    
    private lazy var shareButton: FooterButton =  {
        let footerButton = FooterButton()
        footerButton.title = "Share".localized
        footerButton.textColor = .text
        footerButton.icon = UIImage(named: "share")!
        footerButton.addTarget(self, action: #selector(_shareButtonTapped(_:)), for: .touchUpInside)
        return footerButton
    }()
    
    private lazy var editButton: FooterButton =  {
        let footerButton = FooterButton()
        footerButton.title = "Edit".localized
        footerButton.textColor = .text
        footerButton.icon = UIImage(named: "edit")!
        footerButton.addTarget(self, action: #selector(_editButtonTapped(_:)), for: .touchUpInside)
        return footerButton
    }()
    
    private lazy var deleteButton: FooterButton =  {
        let footerButton = FooterButton()
        footerButton.title = "Delete".localized
        footerButton.textColor = .text
        footerButton.icon = UIImage(named: "delete")!
        footerButton.addTarget(self, action: #selector(_deleteButtonTapped(_:)), for: .touchUpInside)
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
        if #available(iOS 13, *) {
            stackView.addArrangedSubview(markupButton)
        } 
        stackView.addArrangedSubview(shareButton)
        stackView.addArrangedSubview(editButton)
        stackView.addArrangedSubview(deleteButton)
    }
    
    @objc private func _markupButtonTapped(_ sender: FooterButton) {
        onMarkupTap?(sender)
    }
    
    @objc private func _shareButtonTapped(_ sender: FooterButton) {
        onShareTap?(sender)
    }
    
    @objc private func _editButtonTapped(_ sender: FooterButton) {
        onEditTap?(sender)
    }
    
    @objc private func _deleteButtonTapped(_ sender: FooterButton) {
        onDeleteTap?(sender)
    }
}


@available(iOS 13, *)
struct DocumentPreviewControls_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            UIKitPreview(view: DocumentPreviewControls())
                .previewLayout(.fixed(width: 320, height:52))
        }
    }
}
