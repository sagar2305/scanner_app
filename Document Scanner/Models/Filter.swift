//
//  Filter.swift
//  Document Scanner
//
//  Created by Sandesh on 16/03/21.
//

import UIKit

struct Filter {
    
    struct Range {
        let low: Double
        let high: Double
    }

    enum FilterType {
        case monochrome
        case brightness
        case exposure
        case contrast
        case saturation
        case sharpen
    }
    
    let id = UUID()
    let name: String
    let icon: UIImage
    let type: FilterType
    let requiredFirstSlider: Bool
    let requiredSecondSlider: Bool
    let firstSliderRange: Filter.Range?
    let firstSliderDefaultValue: Double?
    let secondSliderRange: Filter.Range?
    let secondSliderDefaultValue: Double?
}

extension Filter: Hashable {
    static func == (lhs: Filter, rhs: Filter) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
