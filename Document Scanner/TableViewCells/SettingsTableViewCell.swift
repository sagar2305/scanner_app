//
//  SettingsTableViewCell.swift
//  Document Scanner
//
//  Created by Sandesh on 16/03/21.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {
    
    static let identifier = "SettingsTableViewCell"
    
    @IBOutlet weak var titleLabel: UILabel!
 
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 4
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
