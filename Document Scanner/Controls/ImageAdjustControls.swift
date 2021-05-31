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
    var onSaturationSliderValueChanged: ((Float, UISlider) -> Void)?
    
    private lazy var brightnessLabel: UILabel = {
        let label = UILabel()
        label.configure(with: UIFont.font(.avenirRegular, style: .footnote))
        label.text = "Brightness".localized
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var contrastLabel: UILabel = {
        let label = UILabel()
        label.configure(with: UIFont.font(.avenirRegular, style: .footnote))
        label.text = "Contrast".localized
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var saturationLabel: UILabel = {
        let label = UILabel()
        label.configure(with: UIFont.font(.avenirRegular, style: .footnote))
        label.text = "Saturation".localized
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var brightnessSlider: UISlider = {
        let slider = UISlider()
        slider.tintColor = .primary
        slider.thumbTintColor = .primary
        slider.minimumValue = -1.0
        slider.maximumValue = 1.0
        slider.value = 0.0
        slider.addTarget(self, action: #selector(_brightnessValueChanged(_:)), for: .valueChanged)
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()
    
    private lazy var contrastSlider: UISlider = {
        let slider = UISlider()
        slider.tintColor = .primary
        slider.thumbTintColor = .primary
        slider.minimumValue = 0.0
        slider.maximumValue = 4.0
        slider.value = 1.0
        slider.addTarget(self, action: #selector(_contrastValueChanged(_:)), for: .valueChanged)
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()
    
    private lazy var saturationSlider: UISlider = {
        let slider = UISlider()
        slider.tintColor = .primary
        slider.thumbTintColor = .primary
        slider.minimumValue = 0.0
        slider.maximumValue = 2.0
        slider.value = 1.0
        slider.addTarget(self, action: #selector(_saturationValueChanged(_:)), for: .valueChanged)
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
        backgroundColor = UIColor.white.withAlphaComponent(0.45)
        
        addSubview(brightnessLabel)
        brightnessLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(4)
            make.height.equalToSuperview().multipliedBy(0.33)
        }
        
        addSubview(brightnessSlider)
        brightnessSlider.snp.makeConstraints { make in
            make.left.equalTo(brightnessLabel.snp.right).offset(4)
            make.top.equalToSuperview()
            make.right.equalToSuperview().inset(4)
            make.height.equalToSuperview().multipliedBy(0.33)
            make.centerY.equalTo(brightnessLabel.snp.centerY)
            make.width.equalToSuperview().multipliedBy(0.65)
        }
        
        addSubview(contrastLabel)
        contrastLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(4)
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
            make.width.equalToSuperview().multipliedBy(0.64)
        }
        
        addSubview(saturationLabel)
        saturationLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(4)
            make.top.equalTo(contrastLabel.snp.bottom)
            make.bottom.equalToSuperview()
        }

        addSubview(saturationSlider)
        saturationSlider.snp.makeConstraints { make in
            make.left.equalTo(saturationLabel.snp.right).offset(4)
            make.top.equalTo(contrastSlider.snp.bottom)
            make.right.equalToSuperview().inset(4)
            make.bottom.equalToSuperview()
            make.centerY.equalTo(saturationLabel.snp.centerY)
            make.width.equalToSuperview().multipliedBy(0.65)
        }
    }
    
    @objc private func _brightnessValueChanged(_ sender: UISlider) {
        onBrightnessSliderValueChanged?(sender.value, sender)
    }
    
    @objc private func _contrastValueChanged(_ sender: UISlider) {
        onContrastSliderValueChanged?(sender.value, sender)
    }
    
    @objc private func _saturationValueChanged(_ sender: UISlider) {
        onSaturationSliderValueChanged?(sender.value, sender)
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
