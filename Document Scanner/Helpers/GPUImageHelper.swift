//
//  MetalPetalHelper.swift
//  Document Scanner
//
//  Created by Sandesh on 15/03/21.
//

import UIKit
import GPUImage

struct GPUImageHelper {
    static let shared = GPUImageHelper()
    private init() { }
    
    func convertToBlackAndWhite(_ image: UIImage) -> UIImage? {
        let filter = MonochromeFilter()
        filter.intensity = 1.0
        filter.color = Color(red: 0.663, green: 0.663, blue: 0.663, alpha: 1.0)
        return image.filterWithOperation(filter)
    }
    
}
