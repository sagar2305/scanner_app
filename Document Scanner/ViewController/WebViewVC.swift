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
    weak var delegate: WebViewVCsDelegate?
    
    @IBOutlet private weak var webView: WKWebView!
    @IBOutlet private weak var cancelButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.cornerRadius = 44
        guard let link = webPageLink else {
            fatalError("webPageLink is not set")
        }
        guard let url  = URL(string: link) else {
            fatalError("Invalid URL")
        }
        webView.load(URLRequest(url: url))
    }
    
    @IBAction func didTapCancel(_ sender: UIButton) {
        delegate?.webViewVC(exit: self)
    }
}
