//
//  FolderViewController.swift
//  Document Scanner
//
//  Created by Sandesh on 01/09/21.
//

import UIKit
import SwipeCellKit
import PMAlertController

@available(iOS 13.0, *)
protocol FolderViewControllerDelegate: AnyObject {
    func viewDidAppear(_controller: FolderViewController)
    func exit(_ controller: FolderViewController)
    func viewDocument(_ controller: FolderViewController, document: Document)
}


@available(iOS 13.0, *)
class FolderViewController: DocumentScannerViewController  {

    typealias DocumentDataSource = UICollectionViewDiffableDataSource<Int, Document>
    typealias DocumentSnapShot = NSDiffableDataSourceSnapshot<Int, Document>
    
    @IBOutlet private weak var noDocumentsMessageLabel: UILabel!
    @IBOutlet private weak var headerView: UIView!
    @IBOutlet private weak var headerLabel: UILabel!
    @IBOutlet private weak var backButton: UIButton!
    
    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var searchBarRightImageView: UIImageView!
    
    @IBOutlet private weak var documentsCollectionView: UICollectionView!
    
    var folder: Folder?
    
    var allDocuments: [Document] = [Document]()
    var filteredDocuments: [Document]  = [Document]()
    private lazy var documentDataSource = _getDocumentCollectionViewDataSource()
    weak var delegate: FolderViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _setupSearchBar()
        _setupDocumentsCollectionViewCell()
        _getDocumentsAndFolders()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(_getDocumentsAndFolders), name: .documentMovedToFolder, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        NotificationCenter.default.removeObserver(self, name: .documentMovedToFolder, object: nil)
    }
    
    private func _setupSearchBar() {
        searchBar.searchTextField.leftView = nil
        searchBar.backgroundColor = .clear
        searchBar.delegate = self
    }

    @objc func _getDocumentsAndFolders() {
        guard let folder = folder else {
            fatalError("ERROR: folder is not set")
        }
        headerLabel.text = folder.name
        let documents: [Document] = DocumentHelper.shared.getDocument(with: folder.name)
        self.allDocuments = documents
        self.filteredDocuments = documents
        noDocumentsMessageLabel.isHidden = allDocuments.count > 0
        _applyDocumentSnapshot(animatingDifferences: true)
    }
    
    private func _setupDocumentsCollectionViewCell() {
        documentsCollectionView.isHeroEnabled = true
        documentsCollectionView.hero.modifiers = [.cascade]
        documentsCollectionView.register(UINib(nibName: DocumentCollectionViewCell.reuseIdentifier, bundle: nil),
                                         forCellWithReuseIdentifier: DocumentCollectionViewCell.reuseIdentifier)
        documentsCollectionView.collectionViewLayout = _documentsCollectionViewLayout()
        documentsCollectionView.delegate = self
        _applyDocumentSnapshot()
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
    
    @IBAction func didTapExit(_ sender: UIButton) {
        delegate?.exit(self)
    }
}

@available(iOS 13.0, *)
extension FolderViewController: UISearchBarDelegate {
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
            _applyDocumentSnapshot()
        } else {
            filteredDocuments = allDocuments.filter { $0.name.lowercased().contains(text.lowercased()) }
            _applyDocumentSnapshot()
        }
    }
}

@available(iOS 13.0, *)
extension FolderViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let document = filteredDocuments[indexPath.row]
        delegate?.viewDocument(self, document: document)
    }
}

@available(iOS 13, *)
extension FolderViewController: SwipeCollectionViewCellDelegate {
    
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
    
    func collectionView(_ collectionView: UICollectionView,
                        editActionsForItemAt indexPath: IndexPath,
                        for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }

        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { [self] _, indexPath in
            // handle action by updating model with deletion
            guard let document = self.documentDataSource.itemIdentifier(for: indexPath) else {
                return
            }
            if self.allDocuments.count == 1, let folder = self.folder {
                DocumentHelper.shared.addNewEmpty(folder: Folder(name: folder.name, documetCount: 0))
            }
            DocumentHelper.shared.delete(document: document)
            self.allDocuments.removeAll { $0.id == document.id }
            self.filteredDocuments.removeAll { $0.id == document.id }
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
    
    func moveDocument(document: Document) {
        let controller = UIAlertController(title: "Select Folder", message: nil, preferredStyle: .actionSheet)
        let folders = DocumentHelper.shared.folders
        for folder in folders {
            if case folder.name = self.folder?.name { continue }
            let action = UIAlertAction(title: folder.name, style: .default) { _ in
                if self.allDocuments.count == 1, let folder = self.folder {
                    DocumentHelper.shared.addNewEmpty(folder: Folder(name: folder.name, documetCount: 0))
                }
                DocumentHelper.shared.move(document: document, to: folder)
            }
            controller.addAction(action)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
        controller.addAction(cancelAction)
        present(controller, animated: true)
    }
}
