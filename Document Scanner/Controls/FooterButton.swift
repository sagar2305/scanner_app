//
//  FooterButton.swift
//  Document Scanner
//
//  Created by Sandesh on 26/03/21.
//

import UIKit
import SwiftUI
import SnapKit

@IBDesignable
class FooterButton: UIButton {

    private var containerView: UIView?
    
    var onTap: ((FooterButton) -> Void)?
    
    @IBInspectable
    private lazy var iconContainerView: UIView = {
        let view = UIView()
        //view.backgroundColor = .green
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = false
        return view
    }()
    
    @IBInspectable
    private lazy var _titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Hello"
        label.textAlignment = .center
        label.font = UIFont.font(.avenirBook, style: .caption1)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = false
        return label
    }()
    
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        //imageView.backgroundColor = .red
        imageView.translatesAutoresizingMaskIntoConstraints = true
        imageView.isUserInteractionEnabled = false
        return imageView
    }()
    
    @IBInspectable
    var background: UIColor = .clear {
        didSet {
            backgroundColor = background
        }
    }

    @IBInspectable
    var icon: UIImage? {
        didSet {
            iconImageView.image = icon
        }
    }

    @IBInspectable
    var title: String = "" {
        didSet {
            _titleLabel.text = title
        }
    }

    @IBInspectable
    var textColor: UIColor = .text {
        didSet {
            _titleLabel.textColor = textColor
        }
    }

    @IBInspectable
    @IBOutlet private weak var iconImage: UIImageView!

    @IBInspectable
    @IBOutlet private weak var buttonTitle: UILabel!
    
    var iconView: UIImageView { return iconImageView }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        _setupView()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //_setupView()
    }
    
    private func _setupView() {
        isEnabled = true
        addSubview(iconContainerView)
        iconContainerView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.7)
        }
        
        addSubview(_titleLabel)
        _titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.bottom.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(iconContainerView.snp.bottom)
        }
        
        iconContainerView.addSubview(iconImageView)
        iconImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            
            make.height.equalToSuperview().multipliedBy(0.78)
            make.width.equalTo(iconImageView.snp.height)
        }
        //addTarget(self, action: #selector(_buttonTapped), for: .touchUpInside)
    }
    
    @objc private func _buttonTapped() {
        onTap?(self)
    }
    
    
    override func setImage(_ image: UIImage?, for state: UIControl.State) {
        self.icon = image
    }

    override func setTitle(_ title: String?, for state: UIControl.State) {
        self._titleLabel.text = title ?? ""
    }
}

@available(iOS 13, *)
struct FooterButton_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            UIKitPreview(view: FooterButton())
                .previewLayout(.fixed(width: 100, height: 100))
        }
    }
}
