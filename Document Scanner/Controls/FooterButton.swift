//
//  FooterButton.swift
//  Document Scanner
//
//  Created by Sandesh on 26/03/21.
//

import UIKit

@IBDesignable
class FooterButton: UIButton {

    private var containerView: UIView?
    
    @IBInspectable
    var background: UIColor = .clear {
        didSet {
            backgroundColor = background
        }
    }
    
    @IBInspectable
    var icon: UIImage? {
        didSet {
            iconImage.image = icon
        }
    }
    
    @IBInspectable
    var title: String = "" {
        didSet {
            buttonTitle.text = title
        }
    }
    
    @IBInspectable
    @IBOutlet private weak var iconImage: UIImageView!
    
    @IBInspectable
    @IBOutlet private weak var buttonTitle: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadView()
        _setupView()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        isEnabled = true
        _setupView()
    }
    
    private func _setupView() {
        buttonTitle.font = UIFont.font(style: .caption1)
    }
    
    
    override func setImage(_ image: UIImage?, for state: UIControl.State) {
        self.icon = image
    }
    
    override func setTitle(_ title: String?, for state: UIControl.State) {
        self.title = title ?? ""
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
