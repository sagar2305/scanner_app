//
//  SettingsVC.swift
//  Document Scanner
//
//  Created by Sandesh on 16/03/21.
//

import UIKit


protocol SettingsVCDelegate: class {
    func settingsViewController(_ controller: SettingsVC, didSelect setting: Setting)
    func settingsViewController(exit controller: SettingsVC)
}

class SettingsVC: DocumentScannerViewController {

    private lazy var settings: [Setting] = {
        SettingsHelper.shared.allSettings()
    }()
    
    weak var delegate: SettingsVCDelegate?
    
    @IBOutlet private weak var settingsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI(title: "Settings")
        _setupTableView()
    }

    private func _setupTableView() {
        registerNib()
        settingsTableView.separatorStyle = .none
        settingsTableView.dataSource = self
        settingsTableView.delegate = self
        settingsTableView.reloadData()
    }

    private func registerNib() {
        settingsTableView.register(UINib(nibName: SettingsTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: SettingsTableViewCell.identifier)
    }
    
}

extension SettingsVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = settingsTableView.dequeueReusableCell(withIdentifier:
                                                                SettingsTableViewCell.identifier,
                                                               for: indexPath) as? SettingsTableViewCell else {
            fatalError("Unable to dequeue SettingsTableViewCell for identifier \(SettingsTableViewCell.identifier) ")
        }
        cell.titleLabel?.text = settings[indexPath.row].name
        return cell
    }
}

// MARK: - UITableViewDelegate
extension SettingsVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.settingsViewController(self, didSelect: settings[indexPath.row])
    }
}

