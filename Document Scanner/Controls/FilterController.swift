//
//  FilterController.swift
//  Document Scanner
//
//  Created by Sandesh on 15/03/21.
//

import UIKit

class FilterController: UIView {

    typealias DataSource = UICollectionViewDiffableDataSource<Int, Filter>
    @IBOutlet private weak var sliderOne: UISlider!
    @IBOutlet private weak var sliderTwo: UISlider!
    @IBOutlet private weak var filterListCollectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        loadView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadView()
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
            
    }
    
    override func didMoveToSuperview() {
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadView()
    }
    
    private func _setupViews() {
        
    }
    
    private func loadView() {
        let allXibViews = Bundle.main.loadNibNamed("FilterController", owner: self, options: nil)
        guard let filterView = allXibViews?.first as? UIView else { return }
        filterView.frame = bounds
        filterView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(filterView)
    }
    
}
