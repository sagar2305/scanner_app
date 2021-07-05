//
//  MarkupVC.swift
//  Document Scanner
//
//  Created by Sandesh on 21/06/21.
//

import Foundation
import QuickLook

@available(iOS 13.0, *)
class MarkupVC: QLPreviewController {
    override var editingInteractionConfiguration: UIEditingInteractionConfiguration {
      return .none
    }
    
    override func viewDidLoad() {
      super.viewDidLoad()
      navigationController?.hidesBarsOnTap = true
    }

    override func viewDidAppear(_ animated: Bool) {
      super.viewDidAppear(animated)
      enableEditingMode()
    }
    
    @objc func enableEditingMode() {
        if let navigation = self.children.first as? UINavigationController {
          if #available(iOS 14.0, *) {
            if let markupButton = (navigation.view.subviews.filter { $0 is UINavigationBar }.first as? UINavigationBar)?.items?.first?.rightBarButtonItems?.last {
              _ = markupButton.target?.perform(markupButton.action, with: markupButton)
            }
          } else {
            if let markupButton = (navigation.view.subviews.filter { $0 is UINavigationBar }.first as? UINavigationBar)?.items?.first?.rightBarButtonItems?.last?.customView as? UIButton {
              markupButton.sendActions(for: .touchUpInside)
            }
          }
        }
    }
}
