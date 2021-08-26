//
//  HomeViewController.swift
//  Document Scanner
//
//  Created by Sandesh on 04/03/21.
//

import UIKit
import Hero
import SwipeCellKit
import PMAlertController

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
    
    typealias FolderDataSource = UICollectionViewDiffableDataSource<Int, Folder>
    typealias FoldertSnapShot = NSDiffableDataSourceSnapshot<Int, Folder>
    
    typealias DocumentDataSource = UICollectionViewDiffableDataSource<Int, Document>
    typealias DocumentSnapShot = NSDiffableDataSourceSnapshot<Int, Document>
  
    private var isFloatingActionMenuExpanded: Bool = false {
        didSet {
            _showOrHideFloatinActionMenu()
            
        }
    }
    
    weak var delegate: HomeViewControllerDelegate?
    private lazy var documentDataSource = _getDocumentCollectionViewDataSource()
    private lazy var folderDataSource = _getFoldersCollectionViewDataSource()
    var allDocuments: [Document] = [Document]()
    var filteredDocuments: [Document]  = [Document]()
    var folders = [Folder]()


    @IBOutlet private weak var headerView: UIView!
    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var searchBarRightImageView: UIImageView!
    @IBOutlet private weak var noDocumentsMessageLabel: UILabel!
    
    //folder collection view
    @IBOutlet private weak var foldersHeaderView: UIView!
    @IBOutlet private weak var foldersHeaderLabel: UILabel!
    @IBOutlet private weak var addFolderButton: UIButton!
    @IBOutlet private weak var folderCollectionView: UICollectionView!
    
    //document collection view
    @IBOutlet private weak var documentsHeaderView: UIView!
    @IBOutlet private weak var documentsLabel: UILabel!
    @IBOutlet private weak var sortDocumentsButton: UIButton!
    @IBOutlet private weak var documentsCollectionView: UICollectionView!
    
    //floating button menu
    @IBOutlet private weak var floatingActionsContainer: UIView!
    @IBOutlet private weak var floatingActionsStackView: UIStackView!
    @IBOutlet private weak var floatingActionPlusButton: UIButton!
    @IBOutlet private weak var floatingActionSettingsButton: UIButton!
    @IBOutlet private weak var floatingActionScanButton: UIButton!
    @IBOutlet private weak var floatingActionPickButton: UIButton!
    @IBOutlet private weak var floatingActionMenuLeftPaddingConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var pickDocumentFooterButton: FooterButton!
    @IBOutlet private weak var scanDocumentFooterButton: FooterButton!
    @IBOutlet private weak var settingsFooterButton: FooterButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _setupViews()
        _setupCollectionViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        _showOrHideFloatinActionMenu()
        navigationController?.navigationBar.isHidden = true
        _getDocumentsAndFolders()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        _showOrHideFloatinActionMenu()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        delegate?.viewDidAppear(_controller: self)
    }

    func _getDocumentsAndFolders() {
        let documents: [Document] = DocumentHelper.shared.untaggedDocument
        self.allDocuments = documents
        self.filteredDocuments = documents
        noDocumentsMessageLabel.isHidden = allDocuments.count > 0
        folders = DocumentHelper.shared.folders
        _applyFolderSnapshot(animatingDifferences: true)
        _applyDocumentSnapshot(animatingDifferences: true)
    }
    
    private func _setupViews() {
        
        _setupSearchBar()
        foldersHeaderLabel.configure(with: UIFont.font(.DMSansBold, style: .title3))
        //TODO: - Localize
        foldersHeaderLabel.text = "My\nFolders"
        
        addFolderButton.titleLabel?.configure(with: UIFont.font(.DMSansMedium, style: .callout))
        addFolderButton.titleLabel?.textColor = .primary
        //TODO: - Localize
        addFolderButton.setTitle("Add Folder", for: .normal)
        
        documentsLabel.configure(with: UIFont.font(.DMSansBold, style: .title3))
        //TODO: - Localize
        documentsLabel.text = "My\nScans"
               
        noDocumentsMessageLabel.configure(with: UIFont.font(.avenirRegular, style: .body))
        noDocumentsMessageLabel.numberOfLines = 0
        noDocumentsMessageLabel.text = "No document available message".localized
        
        headerView.hero.id = Constants.HeroIdentifiers.headerIdentifier
        definesPresentationContext = true
    }
    
    private func _setupFloationActionMenu() {
        
    }
    
    private func _showOrHideFloatinActionMenu() {
        let transform = CGAffineTransform(rotationAngle: isFloatingActionMenuExpanded ? CGFloat.pi / 4 : 0)
        floatingActionMenuLeftPaddingConstraint.constant = isFloatingActionMenuExpanded ? 16 : 0
        floatingActionsStackView.isHidden = !isFloatingActionMenuExpanded
        UIView.animate(withDuration: 0.3, animations: { [self] in
            floatingActionPlusButton.transform = transform
            view.layoutIfNeeded()
        })
    }
    
    private func _setupSearchBar() {
        searchBar.searchTextField.leftView = nil
        searchBar.backgroundColor = .clear
        searchBar.delegate = self
    }
    
    private func _setupCollectionViews() {
        _setupFoldersCollectionViewCell()
        _setupDocumentsCollectionViewCell()
    }
    
    private func _setupFoldersCollectionViewCell() {
        folderCollectionView.isHeroEnabled = true
        folderCollectionView.hero.modifiers = [.cascade]
        folderCollectionView.register(UINib(nibName: FolderCollectionViewCell.reuseIdentifier, bundle: nil),
                                         forCellWithReuseIdentifier: FolderCollectionViewCell.reuseIdentifier)
        folderCollectionView.collectionViewLayout = _foldersCollectionViewLayout()
        folderCollectionView.delegate = self
        _applyFolderSnapshot()
    }
    
    private func _setupDocumentsCollectionViewCell() {
        documentsCollectionView.isHeroEnabled = true
        documentsCollectionView.hero.modifiers = [.cascade]
        documentsCollectionView.register(UINib(nibName: DocumentCollectionViewCell.reuseIdentifier, bundle: nil),
                                         forCellWithReuseIdentifier: DocumentCollectionViewCell.reuseIdentifier)
        documentsCollectionView.collectionViewLayout = _documentsCollectionViewLayout()
        documentsCollectionView.delegate = self
        _applyFolderSnapshot()
        _applyDocumentSnapshot()
    }
    
    private func _foldersCollectionViewLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets.leading = 8
        item.contentInsets.trailing = 8
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.6), heightDimension: .absolute(120))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    private func _documentsCollectionViewLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(80))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    
    private func _getFoldersCollectionViewDataSource() -> FolderDataSource {
        let dataSource = FolderDataSource(collectionView: folderCollectionView) { (collectionView, indexPath, str) -> UICollectionViewCell? in
            guard let collectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: FolderCollectionViewCell.reuseIdentifier, for: indexPath) as? FolderCollectionViewCell else {
                fatalError("ERROR: Unable to find and dequeue cell with identifier \(FolderCollectionViewCell.reuseIdentifier)")
            }
            collectionViewCell.folder = self.folders[indexPath.row]
            return collectionViewCell
        }
        return dataSource
    }
    
    private func _applyFolderSnapshot(animatingDifferences: Bool = true) {
        var snapShot = FoldertSnapShot()
        snapShot.appendSections([0])
        snapShot.appendItems(folders)
        folderDataSource.apply(snapShot, animatingDifferences: animatingDifferences)
    }
    
    
    private func _getDocumentCollectionViewDataSource() -> DocumentDataSource {
        let dataSource = DocumentDataSource(collectionView: documentsCollectionView) { (collectionView, indexPath, document) -> UICollectionViewCell? in
            guard let collectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: DocumentCollectionViewCell.reuseIdentifier, for: indexPath) as? DocumentCollectionViewCell else {
                fatalError("ERROR: Unable to find and dequeue cell with identifier \(DocumentCollectionViewCell.reuseIdentifier)")
            }
            collectionViewCell.document = document
            collectionViewCell.delegate = self
            return collectionViewCell
        }
        return dataSource
    }
    
    private func _applyDocumentSnapshot(animatingDifferences: Bool = true) {
        var snapShot = DocumentSnapShot()
        snapShot.appendSections([0])
        snapShot.appendItems(filteredDocuments)
        documentDataSource.apply(snapShot, animatingDifferences: animatingDifferences)
    }
    
    private func _rename(_ document: Document) {

            let alertVC = PMAlertController(title: "Enter Name".localized, description: nil, image: nil, style: .alert)
            alertVC.alertTitle.textColor = .primary
            
            alertVC.addTextField { (textField) in
                textField?.placeholder = "Document Name".localized
                    }
            
            alertVC.alertActionStackView.axis = .horizontal
            let doneAction = PMAlertAction(title: "Done".localized, style: .default) {
                let textField = alertVC.textFields[0]
                guard let documentName = textField.text,
                      !documentName.isEmpty else {
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.error)
                    return
                }
                document.rename(new: documentName)
                var snapshot = self.documentDataSource.snapshot()
                snapshot.reloadItems([document])
                self.documentDataSource.apply(snapshot,animatingDifferences: true)
            }
            doneAction.setTitleColor(.primary, for: .normal)
            alertVC.addAction(doneAction)
            
            let cancelAction = PMAlertAction(title: "Cancel".localized, style: .cancel) {  }
            alertVC.addAction(cancelAction)
            alertVC.gravityDismissAnimation = false

            
            self.present(alertVC, animated: true, completion: nil)
    }

    @IBAction func addNewFolder(_ sender: UIButton) {
        let alertVC = PMAlertController(title: "Enter Name".localized, description: nil, image: nil, style: .alert)
        alertVC.alertTitle.textColor = .primary
        
        alertVC.addTextField { (textField) in
            textField?.placeholder = "Folder Name".localized
                }
        
        alertVC.alertActionStackView.axis = .horizontal
        let doneAction = PMAlertAction(title: "Done".localized, style: .default) {
            let textField = alertVC.textFields[0]
            guard let folderName = textField.text,
                  !folderName.isEmpty else {
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.error)
                return
            }
            let folder = Folder(name: folderName, documetCount: 0)
            DocumentHelper.shared.addNewEmpty(folder: folder)
            self.folders.append(folder)
            self._applyFolderSnapshot()
        }
        doneAction.setTitleColor(.primary, for: .normal)
        alertVC.addAction(doneAction)
        
        let cancelAction = PMAlertAction(title: "Cancel".localized, style: .cancel) {  }
        alertVC.addAction(cancelAction)
        alertVC.gravityDismissAnimation = false

        
        self.present(alertVC, animated: true, completion: nil)
    }
    
    @IBAction func didTapFloatinActionPlusButton(sender: UIButton) {
        isFloatingActionMenuExpanded.toggle()
    }
    
    @IBAction func didTapPickImageButton(_ sender: FooterButton) {
        isFloatingActionMenuExpanded.toggle()
        delegate?.pickNewDocument(self)
    }
    
    @IBAction func didTapScanButton(_ sender: FooterButton) {
        isFloatingActionMenuExpanded.toggle()
        delegate?.scanNewDocument(self)
    }
    
    @IBAction func didTapSettingsButton(_ sender: FooterButton) {
        isFloatingActionMenuExpanded.toggle()
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
        searchBarRightImageView.isHidden = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        if searchBar.searchTextField.isEmpty {
            searchBarRightImageView.isHidden = false
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        UIView.animate(withDuration: 0.3) { self.navigationItem.searchController = nil }
        filteredDocuments = allDocuments
        searchBar.searchTextField.text = nil
        searchBar.searchTextField.endEditing(true)
        _applyFolderSnapshot()
        _applyDocumentSnapshot()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        search(for: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        search(for: searchBar.searchTextField.text ?? "")
        searchBar.endEditing(true)
    }
    
    private func search(for text: String) {
        if text.isEmpty {
            filteredDocuments = allDocuments
            _applyFolderSnapshot()
            _applyDocumentSnapshot()
        } else {
            filteredDocuments = allDocuments.filter { $0.name.lowercased().contains(text.lowercased()) }
            _applyFolderSnapshot()
            _applyDocumentSnapshot()
        }
    }
}

@available(iOS 13, *)
extension HomeViewController: SwipeCollectionViewCellDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        editActionsForItemAt indexPath: IndexPath,
                        for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }

        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { [self] _, indexPath in
            // handle action by updating model with deletion
            guard let document = self.documentDataSource.itemIdentifier(for: indexPath) else {
                return
            }
            
            DocumentHelper.shared.delete(document: document)
            self.allDocuments.removeAll { $0.id == document.id }
            self.filteredDocuments.removeAll { $0.id == document.id }
            self._applyFolderSnapshot()
            self._applyDocumentSnapshot()
        }

        let renameAction = SwipeAction(style: .default, title: "Rename") { _, indexPath in
            guard let document = self.documentDataSource.itemIdentifier(for: indexPath) else {
                return
            }
            
            self._rename(document)
        }
        
        // customize the action appearance
        renameAction.backgroundColor = .primary
        let renameImage = UIImage(named: "rename")?.withRenderingMode(.alwaysTemplate)
        renameImage?.withTintColor(.white)
        
        let deleteImage = UIImage(named: "delete")?.withRenderingMode(.alwaysTemplate)
        deleteImage?.withTintColor(.white)
        
        renameAction.image = renameImage
        deleteAction.image = deleteImage
    

        return [renameAction, deleteAction]
    }
}

