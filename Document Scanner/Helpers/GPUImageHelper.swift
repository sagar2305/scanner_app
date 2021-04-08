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
        
    func convertToBlackAndWhite(_ image: UIImage, intensity: Float) -> UIImage? {
        let filter = MonochromeFilter()
        filter.intensity = 1.0
        filter.color = Color(red: 0.663, green: 0.663, blue: 0.663, alpha: 1.0)
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
    
    var availableFilters: [Filter] {
        return [
            Filter(name: "Brightness",
                   icon: Icons.blackAndWhite,
                   type: .brightness,
                   requiredFirstSlider: true,
                   requiredSecondSlider: false,
                   firstSliderRange: Filter.Range(low: -0.1, high: 1.0),
                   firstSliderDefaultValue: 0.0,
                   secondSliderRange: nil,
                   secondSliderDefaultValue: nil),
            Filter(name: "Exposure",
                   icon: Icons.crop,
                   type: .exposure,
                   requiredFirstSlider: true,
                   requiredSecondSlider: false,
                   firstSliderRange: Filter.Range(low: -10.0, high: 10.0),
                   firstSliderDefaultValue: 0.0,
                   secondSliderRange: nil,
                   secondSliderDefaultValue: nil),
        ]
    }
}
