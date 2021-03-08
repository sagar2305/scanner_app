//
//  HomeViewController.swift
//  Document Scanner
//
//  Created by Sandesh on 04/03/21.
//

import UIKit

protocol HomeViewControllerDelegate: class {
    func scanNewDocument(_ controller: HomeViewController)
    func pickNewDocument(_ controller: HomeViewController)
    func showSettings(_ controller: HomeViewController)
}

class HomeViewController: UIViewController {
    
    private var footerCornerRadius: CGFloat = 24
    weak var delegate: HomeViewControllerDelegate?
    
    @IBOutlet weak private var footerView: UIView!
    @IBOutlet weak private var documentsCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    @IBAction func test(_ sender: UIButton) {
        print("WTF")
    }
    private func setupViews() {
        footerView.layer.cornerRadius = footerCornerRadius
        footerView.clipsToBounds = true
        footerView.isUserInteractionEnabled = true
    }
    
    
    @IBAction func didTapPickImageButton(_ sender: UIButton) {
        delegate?.pickNewDocument(self)
    }
    
    @IBAction func didTapScanButton(_ sender: UIButton) {
        delegate?.scanNewDocument(self)
    }
    
    @IBAction func didTapSettingsButton(_ sender: UIButton) {
        delegate?.showSettings(self)
    }
    
}
