//
//  FooterButton.swift
//  Document Scanner
//
//  Created by Sandesh on 26/03/21.
//

import UIKit
import SwiftUI
import SnapKit

//@IBDesignable
class FooterButton: UIButton {

    private var containerView: UIView?
    
    private lazy var iconContainerView: UIView = {
        let view = UIView()
        //view.backgroundColor = .green
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var _titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Hello"
        label.textAlignment = .center
        label.font = UIFont.font(.avenirBook, style: .caption1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        //imageView.backgroundColor = .red
        imageView.translatesAutoresizingMaskIntoConstraints = true
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
            //iconImage.image = icon
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
           // buttonTitle.textColor = textColor
        }
    }

    @IBInspectable
    @IBOutlet private weak var iconImage: UIImageView!

    @IBInspectable
    @IBOutlet private weak var buttonTitle: UILabel!
    
    var iconView: UIImageView { return iconImage }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //loadView()
        _setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        //loadView()
        _setupView()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        isEnabled = true
        //_setupView()
    }
    
    private func _setupView() {
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
    }
    
    
    override func setImage(_ image: UIImage?, for state: UIControl.State) {
        self.icon = image
    }

    override func setTitle(_ title: String?, for state: UIControl.State) {
        self._titleLabel.text = title ?? ""
    }

    func loadView() {
        guard  let view = loadViewFromNib() else {
            return
        }
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
        containerView = view
        containerView?.isUserInteractionEnabled = false

    }

    func loadViewFromNib() -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let guideViewNib = UINib(nibName: "FooterButton", bundle: bundle)
        return guideViewNib.instantiate(withOwner: self, options: nil).first as? UIView
    }
}

@available(iOS 13, *)
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            UIKitPreview(view: FooterButton())
                .previewLayout(.fixed(width: 100, height: 100))
        }
    }
}
