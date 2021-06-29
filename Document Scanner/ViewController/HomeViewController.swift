//
//  HomeViewController.swift
//  Document Scanner
//
//  Created by Sandesh on 04/03/21.
//

import UIKit
import Hero

protocol HomeVC: DocumentScannerViewController {
    var delegate: HomeViewControllerDelegate? { get set }
    var allDocuments: [Document] { get }
    var filteredDocuments: [Document] { get }
}

protocol HomeViewControllerDelegate: AnyObject {
    func viewDidAppear(_controller: HomeVC)
    func scanNewDocument(_ controller: HomeVC)
    func pickNewDocument(_ controller: HomeVC)
    func showSettings(_ controller: HomeVC)
    func viewDocument(_ controller: HomeVC, document: Document)
}

@available(iOS 13.0, *)
class HomeViewController: DocumentScannerViewController, HomeVC {
    
    typealias DataSource = UICollectionViewDiffableDataSource<Int, Document>
    typealias SnapShot = NSDiffableDataSourceSnapshot<Int, Document>
    
    private var presentQuickAccess: Bool = true { didSet { showOrHideQuickAccessMenu() } }
    private var presentSearchBar: Bool = false { didSet { showOrHideSearchBar() } }
    
    weak var delegate: HomeViewControllerDelegate?
    private lazy var dateSource = _getDocumentCollectionViewDataSource()
    var allDocuments: [Document] = [Document]()
    var filteredDocuments: [Document]  = [Document]()
    
    private var searchBar: UISearchBar!

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
        
        quickAccessButton.onTap = ({ [self] button in
            presentQuickAccess.toggle()
        })
        
        #warning("below is test code remove it")
        //allDocuments.first?.saveToCloudKit()
        CloudKitHelper.shared.fetchDocumentsFromiCloudIfAny()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        showOrHideQuickAccessMenu()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        delegate?.viewDidAppear(_controller: self)
    }

    func _getDocuments() {
        let documents: [Document] = DocumentHelper.shared.documents
        self.allDocuments = documents
        self.filteredDocuments = documents
        noDocumentsMessageLabel.isHidden = allDocuments.count > 0
        _applySnapshot(animatingDifferences: true)
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
        
        headerView.hero.id = Constants.HeroIdentifiers.headerIdentifier
        
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
            searchBar.searchTextField.backgroundColor = .clear
            searchBar.searchTextField.layer.borderColor = UIColor.black.cgColor
            searchBar.tintColor = .text
            headerView.addSubview(searchBar)
            searchBar.delegate = self
            self.searchBar.searchTextField.becomeFirstResponder()
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
        documentsCollectionView.hero.modifiers = [.cascade]
        documentsCollectionView.register(UINib(nibName: DocumentCollectionViewCell.identifier, bundle: nil),
                                         forCellWithReuseIdentifier: DocumentCollectionViewCell.identifier)
        documentsCollectionView.collectionViewLayout = _collectionViewLayout()
        documentsCollectionView.delegate = self
        _applySnapshot()
    }
    
    private func _collectionViewLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(80))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    private func _getDocumentCollectionViewDataSource() -> DataSource {
        let dataSource = DataSource(collectionView: documentsCollectionView) { (collectionView, indexPath, document) -> UICollectionViewCell? in
            guard let collectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: DocumentCollectionViewCell.identifier, for: indexPath) as? DocumentCollectionViewCell else {
                fatalError("ERROR: Unable to find and dequeue cell with identifier \(DocumentCollectionViewCell.identifier)")
            }
            collectionViewCell.document = document
            return collectionViewCell
        }
        return dataSource
    }
    
    private func _applySnapshot(animatingDifferences: Bool = true) {
        var snapShot = SnapShot()
        snapShot.appendSections([0])
        snapShot.appendItems(filteredDocuments)
        dateSource.apply(snapShot, animatingDifferences: animatingDifferences)
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

@available(iOS 13.0, *)
extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let document = filteredDocuments[indexPath.row]
        delegate?.viewDocument(self, document: document)
    }

}

@available(iOS 13.0, *)
extension HomeViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        UIView.animate(withDuration: 0.3) { self.navigationItem.searchController = nil }
        filteredDocuments = allDocuments
        searchBar.searchTextField.endEditing(true)
        presentSearchBar.toggle()
        _applySnapshot()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredDocuments = allDocuments
            _applySnapshot()
        } else {
            filteredDocuments = allDocuments.filter { $0.name.lowercased().contains(searchText.lowercased()) }
            _applySnapshot()
        }
    }
}

