//
//  FilterController.swift
//  Document Scanner
//
//  Created by Sandesh on 15/03/21.
//

import UIKit

@IBDesignable
class FilterController: UIView {

    private var containerView: UIView?
    @IBOutlet private weak var sliderOne: UISlider!
    @IBOutlet private weak var sliderTwo: UISlider!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _loadView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        _loadView()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    private func _setupViews() {
        
    }
    
    private func _loadView() {
        guard  let view = _loadViewFromNib() else {
            return
        }
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
        containerView = view
        //containerView?.isUserInteractionEnabled = false
    }
    
    private func _loadViewFromNib() -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let guideViewNib = UINib(nibName: "FilterController", bundle: bundle)
        return guideViewNib.instantiate(withOwner: self, options: nil).first as? UIView
    }
}
