//
//  HomeViewController.swift
//  Document Scanner
//
//  Created by Sandesh on 04/03/21.
//

import UIKit
import Hero

protocol HomeViewControllerDelegate: class {
    func scanNewDocument(_ controller: HomeViewController)
    func pickNewDocument(_ controller: HomeViewController)
    func showSettings(_ controller: HomeViewController)
    func viewDocument(_ controller: HomeViewController, document: Document)
}

class HomeViewController: DocumentScannerViewController {
    
    weak var delegate: HomeViewControllerDelegate?
    typealias DataSource = UICollectionViewDiffableDataSource<Int, Document>
    typealias SnapShot = NSDiffableDataSourceSnapshot<Int, Document>
    
    private var footerCornerRadius: CGFloat = 8
    private lazy var dateSource = _getDocumentCollectionViewDataSource()
    
    private var documents = [Document]()
    

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
    }

    func _getDocuments() {
        let documents: [Document] = UserDefaults.standard.fetch(forKey: Constant.DocumentScannerDefaults.documentsListKey) ?? []
        self.documents = documents
        applySnapshot(animatingDifferences: true)
    }
    
    private func _setupViews() {
        //headerLabel.font = UIFont.font(style: .largeTitle)
        configureUI(title: "My Documents")
        footerView.hero.id = Constant.HeroIdentifiers.footerIdentifier
        
        let searchController = UISearchController(searchResultsController: nil)
        navigationItem.searchController = searchController
    }
    
    private func _setupCollectionView() {
        documentsCollectionView.register(UINib(nibName: DocumentCollectionViewCell.identifier, bundle: nil),
                                         forCellWithReuseIdentifier: DocumentCollectionViewCell.identifier)
        documentsCollectionView.collectionViewLayout = _collectionViewLayout()
        documentsCollectionView.delegate = self
        applySnapshot()
    }
    
    private func _collectionViewLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5),
            heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(200))
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
    
    func applySnapshot(animatingDifferences: Bool = true) {
        var snapShot = SnapShot()
        snapShot.appendSections([0])
        snapShot.appendItems(documents)
        dateSource.apply(snapShot, animatingDifferences: animatingDifferences)
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


extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let document = documents[indexPath.row]
        delegate?.viewDocument(self, document: document)
    }
}
