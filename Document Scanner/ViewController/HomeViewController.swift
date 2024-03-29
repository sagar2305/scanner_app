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
    func openFolder(_ controller: HomeVC, folder: Folder)
}

@available(iOS 13.0, *)
class HomeViewController: DocumentScannerViewController, HomeVC {
    
    let folderCollectionViewTAG = 44
    let documentsCollectionViewTAG = 55
    
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

    private var ascending = true

    @IBOutlet private weak var headerView: UIView!
    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var searchBarRightImageView: UIImageView!
    
    //folder collection view
    @IBOutlet private weak var foldersView: UIView!
    @IBOutlet private weak var foldersHeaderView: UIView!
    @IBOutlet private weak var foldersHeaderLabel: UILabel!
    @IBOutlet private weak var addFolderButton: UIButton!
    @IBOutlet private weak var folderCollectionView: UICollectionView!
    
    //document collection view
    @IBOutlet private weak var documentsHeaderView: UIView!
    @IBOutlet private weak var documentsLabel: UILabel!
    @IBOutlet private weak var sortDocumentsButton: UIButton!
    @IBOutlet private weak var documentsCollectionView: UICollectionView!
    @IBOutlet private weak var noScanAvailableView: UIView!
    @IBOutlet private weak var noScansAvailableDescriptionLabel: UILabel!
    
    //floating button menu
    @IBOutlet private weak var floatingActionsContainer: UIView!
    @IBOutlet private weak var floatingActionsStackView: UIStackView!
    @IBOutlet private weak var floatingActionPlusButton: UIButton!
    @IBOutlet private weak var floatingActionSettingsButton: UIButton!
    @IBOutlet private weak var floatingActionScanButton: UIButton!
    @IBOutlet private weak var floatingActionPickButton: UIButton!
    
    @IBOutlet private weak var floatingActionMenuLeftPaddingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var folderViewHeightConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        _setupCollectionViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        _setupViews()
        _showOrHideFloatinActionMenu()
        navigationController?.navigationBar.isHidden = true
        _getDocumentsAndFolders()
        _addObservers()
        NotificationCenter.default.addObserver(self, selector: #selector(_getDocumentsAndFolders), name: .documentMovedToFolder, object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        _showOrHideFloatinActionMenu()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        delegate?.viewDidAppear(_controller: self)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        NotificationCenter.default.removeObserver(self, name: .documentMovedToFolder, object: nil)
        _removeObservers()
    }
    
    private func _addObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateSnapshot),
                                               name: .documentFetchedFromiCloudNotification, object: nil)
    }
    
    private func _removeObservers() {
        NotificationCenter.default.removeObserver(self, name: .documentFetchedFromiCloudNotification, object: nil)
    }
    
    @objc func updateSnapshot() {
        DispatchQueue.main.async {
            self._getDocumentsAndFolders()
            self._setupNoScanAvailableView()
        }
    }
    
    @objc func _getDocumentsAndFolders() {
        let documents: [Document] = DocumentHelper.shared.untaggedDocument
        self.allDocuments = documents
        self.filteredDocuments = documents
        folders = DocumentHelper.shared.folders
        _applyFolderSnapshot(animatingDifferences: true)
        _applyDocumentSnapshot(animatingDifferences: true)
    }
    
    private func _setupViews() {
        _setupSearchBar()
        foldersHeaderLabel.configure(with: UIFont.font(.DMSansBold, style: .title3))
        //TODO: - Localize
        foldersHeaderLabel.text = "My Folders"
        
        addFolderButton.titleLabel?.configure(with: UIFont.font(.DMSansMedium, style: .callout))
        addFolderButton.titleLabel?.textColor = .primary
        //TODO: - Localize
        addFolderButton.setTitle("Add Folder", for: .normal)
        
        documentsLabel.configure(with: UIFont.font(.DMSansBold, style: .title3))
        //TODO: - Localize
        documentsLabel.text = "My Scans"
        
        headerView.hero.id = Constants.HeroIdentifiers.headerIdentifier
        definesPresentationContext = true
        
        _setupNoScanAvailableView()
    }
    
    private func _setupNoScanAvailableView() {
        noScanAvailableView.isHidden = DocumentHelper.shared.totalDocumentsCount != 0
        noScansAvailableDescriptionLabel.configure(with: UIFont.font(.DMSansRegular, style: .callout))
        noScansAvailableDescriptionLabel.textColor = .secondaryText
        //TODO: - Localize
        noScansAvailableDescriptionLabel.text = "Please scan your first \ndocument"
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
        folderCollectionView.tag = folderCollectionViewTAG
        folderCollectionView.hero.modifiers = [.cascade]
        folderCollectionView.register(UINib(nibName: FolderCollectionViewCell.reuseIdentifier, bundle: nil),
                                         forCellWithReuseIdentifier: FolderCollectionViewCell.reuseIdentifier)
        folderCollectionView.collectionViewLayout = _foldersCollectionViewLayout()
        folderCollectionView.delegate = self
        folderCollectionView.dropDelegate = self
        _applyFolderSnapshot()
    }
    
    private func _setupDocumentsCollectionViewCell() {
        documentsCollectionView.isHeroEnabled = true
        documentsCollectionView.tag = documentsCollectionViewTAG
        documentsCollectionView.hero.modifiers = [.cascade]
        documentsCollectionView.register(UINib(nibName: DocumentCollectionViewCell.reuseIdentifier, bundle: nil),
                                         forCellWithReuseIdentifier: DocumentCollectionViewCell.reuseIdentifier)
        documentsCollectionView.collectionViewLayout = _documentsCollectionViewLayout()
        documentsCollectionView.delegate = self
        documentsCollectionView.dragDelegate = self
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
            collectionViewCell.delegate = self
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
        self.documentDataSource.apply(snapShot, animatingDifferences: animatingDifferences)
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
            //check if folder with same name exists
            
            let results = self.folders.filter { $0.name == folderName }
            let folderExists = results.isEmpty == false
            if folderExists {
                let innerAlert = UIAlertController(title: nil, message: "Folder with same name already exists", preferredStyle: .alert)
                  innerAlert.addAction(UIAlertAction(title: "OK", style: .default, handler:nil))
                self.present(innerAlert, animated: true, completion: nil)
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
    
    @IBAction func didTapSortButton(_ sender: UIButton) {
        ascending = !ascending
        self.filteredDocuments.sort(by: ascending ? {$0.creationDate < $1.creationDate } : {$0.creationDate > $1.creationDate })
        _applyDocumentSnapshot(animatingDifferences: true)
    }
}

@available(iOS 13.0, *)
extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.tag == documentsCollectionViewTAG {
            let document = filteredDocuments[indexPath.row]
            delegate?.viewDocument(self, document: document)
        } else if collectionView.tag == folderCollectionViewTAG {
            let folder = folders[indexPath.row]
            delegate?.openFolder(self, folder: folder)
        }
    }
    
}

// MARK: - UISearchBarDelegate
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

// MARK: - SwipeCollectionViewCellDelegate
@available(iOS 13, *)
extension HomeViewController: SwipeCollectionViewCellDelegate {
        func moveDocument(document: Document) {
        let controller = UIAlertController(title: "Select Folder", message: nil, preferredStyle: .actionSheet)
        for folder in folders {
            let action = UIAlertAction(title: folder.name, style: .default) { _ in
                DocumentHelper.shared.move(document: document, to: folder)
            }
            controller.addAction(action)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
        controller.addAction(cancelAction)
        present(controller, animated: true)
    }
    
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
        
        let moveToFolderAction = SwipeAction(style: .default, title: "Move") { _, indexPath in
            guard let document = self.documentDataSource.itemIdentifier(for: indexPath) else {
                return
            }
            self.moveDocument(document: document)
        }
        
        moveToFolderAction.backgroundColor = .moveBackground
        let moveImage = UIImage(systemName: "folder")?.withRenderingMode(.alwaysTemplate)
        moveImage?.withTintColor(.white)
        
        // customize the action appearance
        renameAction.backgroundColor = .renameBackground
        let renameImage = UIImage(named: "rename")?.withRenderingMode(.alwaysTemplate)
        renameImage?.withTintColor(.white)
        
        deleteAction.backgroundColor = .deleteBackground
        let deleteImage = UIImage(named: "delete")?.withRenderingMode(.alwaysTemplate)
        deleteImage?.withTintColor(.white)
        
        renameAction.image = renameImage
        deleteAction.image = deleteImage
        moveToFolderAction.image = moveImage
    

        return [renameAction,moveToFolderAction, deleteAction]
    }
}

// MARK: - UICollectionViewDragDelegate
@available(iOS 13.0, *)
extension HomeViewController: UICollectionViewDragDelegate {
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        
        let document = filteredDocuments[indexPath.row]
        let itemProvider = NSItemProvider(object: document)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        return [dragItem]
    }
}

// MARK: - UICollectionViewDropDelegate
@available(iOS 13.0, *)
extension HomeViewController: UICollectionViewDropDelegate {
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        
        let destinationIndexPath: IndexPath
        let items = coordinator.items
        if  items.count == 1, let item = items.first,
            let indexPath = coordinator.destinationIndexPath {
            print("Destination Indexpath: \(indexPath)")
            destinationIndexPath = indexPath
            let folder = folders[destinationIndexPath.item]

            item.dragItem.itemProvider.loadObject(ofClass: Document.self) { document, error in
                guard let dropDocument = document as? Document else {
                    return
                }
                DispatchQueue.main.async {
                    DocumentHelper.shared.move(document: dropDocument, to: folder)
                }
            }
        }
    }
}

@available(iOS 13.0, *)
extension HomeViewController: FolderCollectionViewCellDelegate {
    func folderCollectionViewCell(_ folderCollectionViewCell: FolderCollectionViewCell, moreButtonTappedFor folder: Folder) {
        let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let renameAction = UIAlertAction(title: "Rename", style: .default) { _ in
            guard let indexpath = self.folderCollectionView.indexPath(for: folderCollectionViewCell), let folder = self.folderDataSource.itemIdentifier(for: indexpath) else {
                return
            }
            self.rename(folder)
        }
        
        let deleteAction = UIAlertAction(title: "Delete", style: .default) { _ in
            guard let indexpath = self.folderCollectionView.indexPath(for: folderCollectionViewCell), let folder = self.folderDataSource.itemIdentifier(for: indexpath) else {
                return
            }
            self.deleteFolder(folder)
        }
    
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
        controller.addAction(renameAction)
        controller.addAction(deleteAction)
        controller.addAction(cancelAction)
        present(controller, animated: true)
    }
    
    func rename(_ folder: Folder) {
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
            
            let results = self.folders.filter { $0.name == folderName }
            let folderExists = results.isEmpty == false
            if folderExists {
                let innerAlert = UIAlertController(title: nil, message: "Folder with same name already exists", preferredStyle: .alert)
                  innerAlert.addAction(UIAlertAction(title: "OK", style: .default, handler:nil))
                self.present(innerAlert, animated: true, completion: nil)
                return
            }
            
            DocumentHelper.shared.renamefolder(folder, with: folderName)
            self.folders = DocumentHelper.shared.folders
            self._applyFolderSnapshot(animatingDifferences: true)
        }
        
        doneAction.setTitleColor(.primary, for: .normal)
        alertVC.addAction(doneAction)
        
        let cancelAction = PMAlertAction(title: "Cancel".localized, style: .cancel) {  }
        alertVC.addAction(cancelAction)
        alertVC.gravityDismissAnimation = false
        self.present(alertVC, animated: true, completion: nil)
    }
    
    func deleteFolder(_ folder: Folder) {
        let deleteConfirmationAlert = PMAlertController(title: "Delete Folder".localized, description: "Are you sure you want to delete the folder?".localized, image: nil, style: .alert)
        deleteConfirmationAlert.alertTitle.textColor = .red
        
        
        deleteConfirmationAlert.alertActionStackView.axis = .horizontal
        let yesAction = PMAlertAction(title: "Yes".localized, style: .default) {
            DocumentHelper.shared.deleteFolder(folder)
            self.folders.removeAll { $0.id == folder.id }
            self._applyFolderSnapshot()
        }
        yesAction.setTitleColor(.red, for: .normal)
        deleteConfirmationAlert.addAction(yesAction)
        
        let cancelAction = PMAlertAction(title: "No".localized, style: .cancel) {  }
        deleteConfirmationAlert.addAction(cancelAction)
        deleteConfirmationAlert.gravityDismissAnimation = false
        
        self.present(deleteConfirmationAlert, animated: true, completion: nil)
    }
}

