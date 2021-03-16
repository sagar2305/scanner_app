//
//  FilterController.swift
//  Document Scanner
//
//  Created by Sandesh on 15/03/21.
//

import UIKit

class FilterController: UIView {

    @IBOutlet private weak var sliderOne: UISlider!
    @IBOutlet private weak var sliderTwo: UISlider!
    @IBOutlet private weak var filterListCollectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
