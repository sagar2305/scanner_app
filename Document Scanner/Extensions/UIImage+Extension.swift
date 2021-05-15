//
//  UIImage+Extension.swift
//  Document Scanner
//
//  Created by Sandesh on 15/03/21.
//

import UIKit

extension UIImage {
    
    func rotateImage(withRotation radians: CGFloat) -> UIImage {
        // calculate the size of the rotated view's containing box for our drawing space
        let rotatedViewBox = UIView(frame: CGRect(origin: .zero, size: size))
        rotatedViewBox.transform = CGAffineTransform(rotationAngle: radians)
        let rotatedSize = rotatedViewBox.frame.size
        
        UIGraphicsBeginImageContext(rotatedSize)
        if let bitmap = UIGraphicsGetCurrentContext() {
            bitmap.translateBy(x: rotatedSize.width / 2.0, y: rotatedSize.height / 2.0)
            bitmap.rotate(by: radians)
            bitmap.scaleBy(x: 1.0, y: -1.0)
            if let cgImage = self.cgImage {
                bitmap.draw(cgImage, in: CGRect(x: -size.width / 2, y: -size.height / 2, width: size.width, height: size.height))
            }
            guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else {
                debugPrint("Failed to rotate image. Returning the same as input..."); return self
            }
            UIGraphicsEndImageContext()
            return newImage
        } else {
            debugPrint("Failed to create graphics context. Returning the same as input...")
            return self
        }
    }

    func rotateRight() -> UIImage {
        return self.rotateImage(withRotation: 1.5708)
    }
    
    func rotateLeft() -> UIImage {
        return self.rotateImage(withRotation: -1.5708)
    }
    
    func mirror() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
            let context = UIGraphicsGetCurrentContext()!
            context.translateBy(x: self.size.width, y: self.size.height)
            context.scaleBy(x: -self.scale, y: -self.scale)
            context.draw(self.cgImage!, in: CGRect(origin:CGPoint.zero, size: self.size))
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return newImage
    }
    
    func removeRotation() -> UIImage {
        if imageOrientation == .up { return  self }
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: CGPoint(x: 0, y: 0), size: size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return normalizedImage
    }
}
