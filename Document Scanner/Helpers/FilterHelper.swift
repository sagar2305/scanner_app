//
//  FilterHelper.swift
//  Document Scanner
//
//  Created by Sandesh on 23/04/21.
//

import UIKit
import CoreImage

struct FilterHelper {
    
    static let shared = FilterHelper()
    let context = CIContext()
    
    private init() { }
    
    enum Filters: String {
        case colors = "CIColorControls"
        case grayScale = "CIPhotoEffectMono"
        case blackAndWhite = "CIColorMonochrome"
    }
    
    enum ImageColorControls: String {
        case brightness = "kCIInputBrightnessKey"
        case saturation = "kCIInputSaturationKey"
        case contrast = "kCIInputContrastKey"
    }
    
    func adjustColor(_ control: ImageColorControls,of image: UIImage, intensity: Float) -> UIImage? {
        let beginImage = CIImage(image: image)
        let filter = CIFilter(name: Filters.colors.rawValue)
        filter?.setValue(beginImage, forKey: kCIInputImageKey)
        filter?.setValue(intensity, forKey: kCIInputBrightnessKey)
        guard let outputImage = filter?.outputImage else { return nil }
        if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
            let processedImage = UIImage(cgImage: cgImage)
            return processedImage
        }
        return nil
    }
    
    
    func convertToGrayScale(_ image: UIImage) -> UIImage? {
        let beginImage = CIImage(image: image)
        let filter = CIFilter(name: Filters.grayScale.rawValue)
        filter?.setValue(beginImage, forKey: "inputImage")
        guard let outputImage = filter?.outputImage else { return  nil}
        if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            let processedImage = UIImage(cgImage: cgimg)
            return processedImage
        }
        return nil
    }
    
    func convertToBlackAndWhit(_ image: UIImage) -> UIImage? {
        let beginImage = CIImage(image: image)
        let filter = CIFilter(name: Filters.blackAndWhite.rawValue)
        filter?.setValue(beginImage, forKey: "inputImage")
        filter?.setValue(CIColor(red: 0.7, green: 0.7, blue: 0.7), forKey: "inputColor")
        filter?.setValue(1, forKey: "inputIntensity")
        guard let outputImage = filter?.outputImage else { return  nil}
        if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            let processedImage = UIImage(cgImage: cgimg)
            return processedImage
        }
        return nil
    }
    
}
