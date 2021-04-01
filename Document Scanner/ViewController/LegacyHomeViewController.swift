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
    
    var delegate: HomeViewControllerDelegate?
    
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.searchBar.tintColor = .text
        searchController.searchBar.showsCancelButton = true
        navigationItem.hidesSearchBarWhenScrolling = false
        
        searchController.searchBar.backgroundColor = .primary
        
        if let textField = searchController.searchBar.value(forKey: "searchField") as? UITextField {
            textField.backgroundColor = .primary
            textField.subviews.first?.backgroundColor = .backgroundColor
            textField.textColor = .text
            textField.attributedPlaceholder = NSAttributedString(string: "Search Document",
                                                                 attributes: [.foregroundColor: UIColor.text])
        }
        
        return searchController
    }()

    @IBOutlet private weak var footerView: UIView!
    @IBOutlet private weak var documentsCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _setupViews()
        _setupCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        _getDocuments()
        documentsCollectionView.reloadData()
    }

    func _getDocuments() {
        let documents: [Document] = UserDefaults.standard.fetch(forKey: Constant.DocumentScannerDefaults.documentsListKey) ?? []
        self.allDocuments = documents
        self.filteredDocuments = documents
    }
    
    private func _setupViews() {
        //headerLabel.font = UIFont.font(style: .largeTitle)
        configureUI(title: "My Documents")
        footerView.hero.id = Constant.HeroIdentifiers.footerIdentifier
        definesPresentationContext = true
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchButtonTapped(_:)))
    }
    
    @objc private func searchButtonTapped(_ sender: UIBarButtonItem) {
        UIView.animate(withDuration: 0.3) { self.navigationItem.searchController = self.searchController }
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
        return CGSize(width: UIScreen.main.bounds.size.width * 0.45, height: 200)
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

extension LegacyHomeViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text
        
        if searchText == nil || searchText!.isEmpty {
            filteredDocuments = allDocuments
            documentsCollectionView.reloadData()
        } else {
            filteredDocuments = allDocuments.filter { $0.name.lowercased().contains(searchText!.lowercased()) }
            documentsCollectionView.reloadData()
        }
    }
}

extension LegacyHomeViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchController.searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        UIView.animate(withDuration: 0.3) { self.navigationItem.searchController = nil }
        filteredDocuments = allDocuments
        documentsCollectionView.reloadData()
    }
}

