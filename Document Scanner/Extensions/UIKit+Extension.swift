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
    
    static func font(_ name: Constants.Fonts, style: UIFont.TextStyle) -> UIFont {
        let fontSize = UIFont.sizeFor(style)
        let font = UIFont(name: name.rawValue, size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
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
        UIColor(named: "primary")!
    }
    
    static var text: UIColor {
        UIColor(named: "text")!
    }
    
    static var primaryText: UIColor {
        UIColor(named: "primary-text")!
    }
    
    static var secondaryText: UIColor {
        UIColor(named: "secondary-text")!
    }
    
    static var shadow: UIColor {
        UIColor(named: "shadow")!
    }
    
    static var renameBackground: UIColor {
        UIColor(named: "renameBackground")!
    }
    
    static var deleteBackground: UIColor {
        UIColor(named: "deleteBackground")!
    }
    
    static var moveBackground: UIColor {
        UIColor(named: "moveBackground")!
    }
}

extension UILabel {
    static func titleLabel(title: String?) -> UILabel {
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 80))
        titleLabel.text = title ?? ""
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.font(.avenirBook, style: .title3)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.textColor = .text
        titleLabel.sizeToFit()
        return titleLabel
    }
    
    func configure(with font: UIFont) {
        self.font = font
        adjustsFontForContentSizeCategory = true
        adjustsFontSizeToFitWidth = true
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

extension UITapGestureRecognizer {

    func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: label.attributedText!)

        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)

        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize

        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
                                          y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x,
                                                     y: locationOfTouchInLabel.y - textContainerOffset.y)
        let indexOfCharacter = layoutManager.characterIndex(
                            for: locationOfTouchInTextContainer,
                            in: textContainer,
                            fractionOfDistanceBetweenInsertionPoints: nil)

        return NSLocationInRange(indexOfCharacter, targetRange)
    }
}
