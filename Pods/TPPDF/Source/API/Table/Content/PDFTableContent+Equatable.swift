//
//  PDFTableContent+Equatable.swift
//  TPPDF
//
//  Created by Philip Niedertscheider on 09/11/2017.
//

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

/**
 TODO: Documentation
 */
extension PDFTableContent: Equatable {

    /**
     TODO: Documentation
     */
    public static func == (lhs: PDFTableContent, rhs: PDFTableContent) -> Bool {
        guard lhs.type == rhs.type else {
            return false
        }
        if let lhsString = lhs.content as? String,
            let rhsString = rhs.content as? String,
            lhsString != rhsString {
            return false
        } else if let lhsString = lhs.content as? NSAttributedString,
            let rhsString = rhs.content as? NSAttributedString,
            lhsString != rhsString {
            return false
        } else if let lhsImage = lhs.content as? Image,
            let rhsImage = rhs.content as? Image,
            lhsImage != rhsImage {
            return false
        } else if (lhs.content == nil && rhs.content != nil) || (lhs.content != nil && rhs.content == nil) {
            return false
        }
        return true
    }

}
