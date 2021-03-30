//
//  UIKit+Extension.swift
//  Document Scanner
//
//  Created by Sandesh on 18/03/21.
//

import UIKit


extension UIFont {
    
    static func sizeFor(_ style: UIFont.TextStyle) -> CGFloat {
        switch style {
        case .largeTitle:   return CGFloat(40)
        case .title1:       return CGFloat(32)
        case .title2:       return CGFloat(26)
        case .title3:       return CGFloat(22)
        case .headline:      return CGFloat(17)
        case .body:         return CGFloat(17)
        case .callout:      return CGFloat(16)
        case .subheadline:  return CGFloat(15)
        case .footnote:     return CGFloat(13)
        case .caption1:     return CGFloat(12)
        case .caption2:     return CGFloat(11)
        default: return CGFloat(17)
        }
    }
    
    static func font( style: UIFont.TextStyle) -> UIFont {
        let fontSize = UIFont.sizeFor(style)
        let font = UIFont(name: "Avenir Book", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
        return UIFontMetrics(forTextStyle: style).scaledFont(for: font)
    }
}

extension UIColor {
    static var backgroundColor: UIColor {
        UIColor(named: "background")!
    }
    
    static var cardBackground: UIColor {
        UIColor(named: "card-base")!
    }
    
    static var primary: UIColor {
        UIColor(named: "app-theme")!
    }
    
    static var text: UIColor {
        UIColor(named: "text")!
    }
}

extension UILabel {
    static func titleLabel(title: String?) -> UILabel {
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 80))
        titleLabel.text = title ?? ""
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.font(style: .title3)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.textColor = .text
        titleLabel.sizeToFit()
        return titleLabel
    }
}

extension UIViewController {
    func configureUI(title: String) {
        let titleView = UILabel.titleLabel(title: title)
        titleView.tintColor = .text
        navigationItem.titleView = titleView
    }
    
    func addChildViewController(_ viewController: UIViewController) {
        addChild(viewController)
        viewController.willMove(toParent: self)
        viewController.view.frame = view.bounds
        view.addSubview(viewController.view)
        viewController.didMove(toParent: self)
    }
}
