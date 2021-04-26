//
//  WebViewVC.swift
//  Document Scanner
//
//  Created by Sandesh on 16/03/21.
//

import UIKit
import WebKit

protocol WebViewVCsDelegate: class {
    func webViewVC(exit controller: WebViewVC)
}

class WebViewVC: UIViewController {

    var webPageLink: String?
    var webPageTitle: String?
    weak var delegate: WebViewVCsDelegate?
    
    @IBOutlet private weak var webView: WKWebView!
    @IBOutlet private weak var headerLabel: UILabel!
    @IBOutlet private weak var backButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _setupView()
        guard let link = webPageLink else {
            fatalError("webPageLink is not set")
        }
        guard let url  = URL(string: link) else {
            fatalError("Invalid URL")
        }
        webView.load(URLRequest(url: url))
    }
    
    private func _setupView() {
        headerLabel.configure(with: UIFont.font(.avenirMedium, style: .title3))
        headerLabel.text = webPageTitle?.localized ?? ""
    }
    
    @IBAction func exit(_ sender: UIButton) {
        delegate?.webViewVC(exit: self)
    }
    
}
