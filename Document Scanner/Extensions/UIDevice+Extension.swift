//
//  UIDevice+Extension.swift
//  Document Scanner
//
//  Created by Sandesh on 18/03/21.
//

import UIKit

extension UIDevice {
    static var current: UIDevice {
        UIDevice()
    }
    
    var hasNotch: Bool {
        let currentWindow = UIApplication.shared.windows.first { $0.isKeyWindow }
        let bottom = currentWindow?.safeAreaInsets.bottom ?? 0
        return bottom > 0
    }
}


