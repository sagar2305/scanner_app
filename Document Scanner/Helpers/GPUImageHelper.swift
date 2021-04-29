//
//  MetalPetalHelper.swift
//  Document Scanner
//
//  Created by Sandesh on 15/03/21.
//

import UIKit
import GPUImage

class GPUImageHelper {
    static let shared = GPUImageHelper()
    private init() { }
        
    func convertToBlackAndWhite(_ image: UIImage) -> UIImage? {
        let filter = MonochromeFilter()
        filter.intensity = 1.0
        filter.color = Color(red: 0, green: 0, blue: 0, alpha: 1.0)
        return image.filterWithOperation(filter)
    }
    
    func adjustBrightness(_ image: UIImage, intensity: Float) -> UIImage? {
        let filter = BrightnessAdjustment()
        filter.brightness = intensity
        return image.filterWithOperation(filter)
    }
    
    func adjustContrast(_ image: UIImage, intensity: Float) -> UIImage? {
        let filter =  ContrastAdjustment()
        filter.contrast = intensity
        return image.filterWithOperation(filter)
    }
    
    func adjustSaturation(_ image: UIImage, intensity: Float) -> UIImage? {
        let filter = SaturationAdjustment()
        filter.saturation = intensity
        return image.filterWithOperation(filter)
    }
}
