//
//  ImageAdjustControls.swift
//  Document Scanner
//
//  Created by Sandesh on 20/04/21.
//

import UIKit
import SwiftUI
import SnapKit

class ImageAdjustControls: UIView {
    
    var onBrightnessSliderValueChanged: ((Float, UISlider) -> Void)?
    var onContrastSliderValueChanged: ((Float, UISlider) -> Void)?
    var onSharpnessSliderValueChanged: ((Float, UISlider) -> Void)?
    
    private lazy var brightnessLabel: UILabel = {
        let label = UILabel()
        label.configure(with: UIFont.font(.avenirRegular, style: .footnote))
        label.text = "Brightness"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var contrastLabel: UILabel = {
        let label = UILabel()
        label.configure(with: UIFont.font(.avenirRegular, style: .footnote))
        label.text = "Contrast"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var sharpnessLabel: UILabel = {
        let label = UILabel()
        label.configure(with: UIFont.font(.avenirRegular, style: .footnote))
        label.text = "Sharpness"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var brightnessSlider: UISlider = {
        let slider = UISlider()
        slider.tintColor = .primary
        slider.thumbTintColor = .primary
        slider.addTarget(self, action: #selector(_brightnessValueChanged(_:)), for: .valueChanged)
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()
    
    private lazy var contrastSlider: UISlider = {
        let slider = UISlider()
        slider.tintColor = .primary
        slider.thumbTintColor = .primary
        slider.addTarget(self, action: #selector(_contrastValueChanged(_:)), for: .valueChanged)
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()
    
    private lazy var sharpnessSlider: UISlider = {
        let slider = UISlider()
        slider.tintColor = .primary
        slider.thumbTintColor = .primary
        slider.value = 34
        slider.addTarget(self, action: #selector(_sharpnessValueChanged(_:)), for: .valueChanged)
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        _setupView()
    }
    
    private func _setupView() {
        backgroundColor = UIColor.white.withAlphaComponent(0.3)
        addSubview(brightnessLabel)
        brightnessLabel.snp.makeConstraints { make in
            make.left.top.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.33)
        }
        
        addSubview(brightnessSlider)
        brightnessSlider.snp.makeConstraints { make in
            make.left.equalTo(brightnessLabel.snp.right).offset(4)
            make.top.equalToSuperview()
            make.right.equalToSuperview().inset(4)
            make.height.equalToSuperview().multipliedBy(0.33)
            make.centerY.equalTo(brightnessLabel.snp.centerY)
            make.width.equalToSuperview().multipliedBy(0.7)
        }
        
        addSubview(contrastLabel)
        contrastLabel.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalTo(brightnessLabel.snp.bottom)
            make.height.equalToSuperview().multipliedBy(0.33)
        }
        
        addSubview(contrastSlider)
        contrastSlider.snp.makeConstraints { make in
            make.left.equalTo(contrastLabel.snp.right).offset(4)
            make.top.equalTo(brightnessSlider.snp.bottom)
            make.right.equalToSuperview().inset(4)
            make.height.equalToSuperview().multipliedBy(0.33)
            make.centerY.equalTo(contrastLabel.snp.centerY)
            make.width.equalToSuperview().multipliedBy(0.7)
        }
        
        addSubview(sharpnessLabel)
        sharpnessLabel.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalTo(contrastLabel.snp.bottom)
            make.bottom.equalToSuperview()
        }
        
        addSubview(sharpnessSlider)
        sharpnessSlider.snp.makeConstraints { make in
            make.left.equalTo(sharpnessLabel.snp.right).offset(4)
            make.top.equalTo(contrastSlider.snp.bottom)
            make.right.equalToSuperview().inset(4)
            make.bottom.equalToSuperview()
            make.centerY.equalTo(sharpnessLabel.snp.centerY)
            make.width.equalToSuperview().multipliedBy(0.7)
        }
    }
    
    @objc private func _brightnessValueChanged(_ sender: UISlider) {
        onBrightnessSliderValueChanged?(sender.value, sender)
    }
    
    @objc private func _contrastValueChanged(_ sender: UISlider) {
        onContrastSliderValueChanged?(sender.value, sender)
    }
    
    @objc private func _sharpnessValueChanged(_ sender: UISlider) {
        onSharpnessSliderValueChanged?(sender.value, sender)
    }
    
    
}

@available(iOS 13, *)
struct ImageAdjustControls_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            UIKitPreview(view: ImageAdjustControls())
                .previewLayout(.fixed(width: 200, height:120))
        }
    }
}
