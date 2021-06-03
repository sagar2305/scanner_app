//
//  SettingsVC.swift
//  Document Scanner
//
//  Created by Sandesh on 16/03/21.
//

import UIKit


protocol SettingsVCDelegate: AnyObject {
    func viewDidLoad(_ controller: DocumentScannerViewController)
    func viewDidAppear(controller: DocumentScannerViewController)
    func settingsViewController(_ controller: SettingsVC, didSelect setting: Setting)
    func settingsViewController(exit controller: SettingsVC)
}

class SettingsVC: DocumentScannerViewController {

    var settings: [[Setting]] = []
    weak var delegate: SettingsVCDelegate?
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet private weak var settingsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate?.viewDidLoad(self)
        _setupViews()
        _setupTableView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        delegate?.viewDidAppear(controller: self)
    }
    
    private func _setupViews() {
        headerLabel.configure(with: UIFont.font(.avenirMedium, style: .title3))
        headerLabel.text = "Settings".localized
    }

    private func _setupTableView() {
        registerNib()
        settingsTableView.separatorStyle = .singleLine
        settingsTableView.dataSource = self
        settingsTableView.delegate = self
        settingsTableView.reloadData()
        navigationController?.navigationBar.isHidden = true
        settingsTableView.tableFooterView = UIView()
    }

    private func registerNib() {
        settingsTableView.register(UINib(nibName: SettingsTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: SettingsTableViewCell.identifier)
    }
    
    @IBAction func didTapBackButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}

extension SettingsVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return settings.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settings[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = settingsTableView.dequeueReusableCell(withIdentifier:
                                                                SettingsTableViewCell.identifier,
                                                               for: indexPath) as? SettingsTableViewCell else {
            fatalError("Unable to dequeue SettingsTableViewCell for identifier \(SettingsTableViewCell.identifier) ")
        }
        cell.titleLabel?.text = settings[indexPath.section][indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return SettingTypes.documentScanner.description
        case 1: return SettingTypes.manage.description
        case 2: return SettingTypes.support.description
        case 3: return SettingTypes.miscellaneous.description
        default: return nil
        }
    }
}

// MARK: - UITableViewDelegate
extension SettingsVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedSetting = settings[indexPath.section][indexPath.row]
        delegate?.settingsViewController(self, didSelect: selectedSetting)
    }
}

