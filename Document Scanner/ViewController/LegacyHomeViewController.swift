//
//  LegacyHomeViewController.swift
//  Document Scanner
//
//  Created by Sandesh on 31/03/21.
//

import UIKit

class LegacyHomeViewController: DocumentScannerViewController, HomeVC {
    
    var allDocuments: [Document] = [Document]()
    var filteredDocuments: [Document] = [Document]()
    
    private var presentQuickAccess: Bool = true { didSet { showOrHideQuickAccessMenu() } }
    private var presentSearchBar: Bool = false { didSet { showOrHideSearchBar() } }
    private var searchBar: UISearchBar!
    
    var delegate: HomeViewControllerDelegate?
    
    @IBOutlet private weak var headerView: UIView!
    @IBOutlet private weak var headerLabel: UILabel!
    @IBOutlet private weak var searchButton: UIButton!
    @IBOutlet private weak var noDocumentsMessageLabel: UILabel!

    
    @IBOutlet private weak var footerView: UIView!
    @IBOutlet private weak var quickAccessButton: FooterButton!
    @IBOutlet private weak var footerHeaderView: UIView!
    @IBOutlet private weak var footerContentView: UIStackView!
    @IBOutlet private weak var footerViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var documentsCollectionView: UICollectionView!
    
    @IBOutlet private weak var pickDocumentFooterButton: FooterButton!
    @IBOutlet private weak var scanDocumentFooterButton: FooterButton!
    @IBOutlet private weak var settingsFooterButton: FooterButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _setupViews()
        _setupCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        _getDocuments()
        documentsCollectionView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        showOrHideQuickAccessMenu()
    }

    func _getDocuments() {
        let documents: [Document] = UserDefaults.standard.fetch(forKey: Constants.DocumentScannerDefaults.documentsListKey) ?? []
        self.allDocuments = documents
        self.filteredDocuments = documents
        noDocumentsMessageLabel.isHidden = allDocuments.count > 0
        documentsCollectionView.reloadData()
    }
    
    private func _setupViews() {
        pickDocumentFooterButton.textColor = .primaryText
        scanDocumentFooterButton.textColor = .primaryText
        settingsFooterButton.textColor = .primaryText
        
        pickDocumentFooterButton.setTitle("Pick Document".localized, for: .normal)
        scanDocumentFooterButton.setTitle("Scan Document", for: .normal)
        settingsFooterButton.setTitle("Settings".localized, for: .normal)
        
        noDocumentsMessageLabel.configure(with: UIFont.font(.avenirRegular, style: .body))
        noDocumentsMessageLabel.numberOfLines = 0
        noDocumentsMessageLabel.text = "No document available message".localized
        
        footerView.hero.id = Constants.HeroIdentifiers.footerIdentifier
        footerView.layer.cornerRadius = 16
        footerView.clipsToBounds = true
        headerLabel.configure(with: UIFont.font(.avenirMedium, style: .title3))
        headerLabel.text = "My Documents".localized
        definesPresentationContext = true
    }
    
    private func showOrHideQuickAccessMenu() {
        let footerViewHeight = footerView.getMyFrame(in: self.view).height
        let footerHeaderHeight = footerHeaderView.getMyFrame(in: footerView).height
        print(footerViewHeight)
        print(footerHeaderHeight)
        
        if presentQuickAccess {
            footerViewBottomConstraint.constant = -44
            footerContentView.isHidden = false
        } else {
            footerViewBottomConstraint.constant = UIDevice.current.hasNotch ? -(footerViewHeight - footerHeaderHeight - 22)
                                        : -(footerViewHeight - footerHeaderHeight)
            if UIDevice.current.hasNotch { self.footerContentView.isHidden = true }
        }
        
        UIView.animate(withDuration: 0.3, animations: { [self] in
            self.quickAccessButton.iconView.transform = self.presentQuickAccess ? CGAffineTransform(scaleX: 1, y: -1) : .identity
            self.view.layoutIfNeeded()
        })
    }
    
    private func showOrHideSearchBar() {
        if presentSearchBar {
            searchBar = UISearchBar(frame: searchButton.frame)
            searchBar.searchBarStyle = .minimal

            guard let searchTextField = searchBar.value(forKey: "searchField") as? UITextField else {
                fatalError("ERROR: No textfield is present in search bar")
            }
            searchTextField.backgroundColor = .clear
            searchTextField.layer.borderColor = UIColor.black.cgColor
            searchBar.tintColor = .text
            headerView.addSubview(searchBar)
            searchBar.delegate = self
            searchTextField.becomeFirstResponder()
            UIView.animateKeyframes(withDuration: 0.3,
                                    delay: 0,
                                    options: []) {
                self.searchBar.frame = CGRect(x: 16,
                                         y: 4,
                                         width: self.headerView.frame.width - 32,
                                         height: self.headerView.frame.height - 8)
                self.searchButton.alpha = 0
                self.headerLabel.alpha = 0
                
            } completion: { completed in
                self.searchButton.isHidden = true
                self.headerLabel.isHidden = true
            }

        } else {
            if searchBar != nil {
                UIView.animateKeyframes(withDuration: 0.3,
                                        delay: 0,
                                        options: []) {
                    self.searchBar.frame = self.searchButton.frame
                    self.searchButton.alpha = 1
                    self.headerLabel.alpha = 1
                } completion: { completed in
                    self.searchButton.isHidden = false
                    self.headerLabel.isHidden = false
                    self.searchBar.removeFromSuperview()
                    self.searchBar = nil
                }
            }
        }
    }
    
    
    private func _setupCollectionView() {
        documentsCollectionView.isHeroEnabled = true
        documentsCollectionView.register(UINib(nibName: DocumentCollectionViewCell.identifier, bundle: nil),
                                         forCellWithReuseIdentifier: DocumentCollectionViewCell.identifier)
        let layout = UICollectionViewFlowLayout()
        documentsCollectionView.collectionViewLayout = layout
        layout.sectionHeadersPinToVisibleBounds = true
        documentsCollectionView.dataSource = self
        documentsCollectionView.delegate = self
    }
     
    private func _collectionViewLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        return layout
    }
    
    @IBAction func didTapSearchButton(_ sender: UIButton) {
        presentSearchBar.toggle()
    }
    
    @IBAction func didTapShowQuickAccessButton(_ sender: FooterButton) {
        presentQuickAccess.toggle()
    }
    
    @IBAction func didTapPickImageButton(_ sender: FooterButton) {
        delegate?.pickNewDocument(self)
    }
    
    @IBAction func didTapScanButton(_ sender: FooterButton) {
        delegate?.scanNewDocument(self)
    }
    
    @IBAction func didTapSettingsButton(_ sender: FooterButton) {
        delegate?.showSettings(self)
    }

}


extension LegacyHomeViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.size.width * 0.92, height: 80)
    }
}


extension LegacyHomeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredDocuments.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let documentCell = collectionView.dequeueReusableCell(withReuseIdentifier: DocumentCollectionViewCell.identifier, for: indexPath) as? DocumentCollectionViewCell else {
            fatalError("ERROR: Unable to dequeue collection view cell with identifier \(DocumentCollectionViewCell.identifier)")
        }
        documentCell.document = filteredDocuments[indexPath.row]
        return documentCell
    }
}


extension LegacyHomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let document = filteredDocuments[indexPath.row]
        delegate?.viewDocument(self, document: document)
    }

}

extension LegacyHomeViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        UIView.animate(withDuration: 0.3) { self.navigationItem.searchController = nil }
        filteredDocuments = allDocuments
        guard let searchTextField = searchBar.value(forKey: "searchField") as? UITextField else {
            fatalError("ERROR: No textfield is present in search bar")
        }
        searchTextField.endEditing(true)
        presentSearchBar.toggle()
        documentsCollectionView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredDocuments = allDocuments
            documentsCollectionView.reloadData()
        } else {
            filteredDocuments = allDocuments.filter { $0.name.lowercased().contains(searchText.lowercased()) }
            documentsCollectionView.reloadData()
        }
    }
}

