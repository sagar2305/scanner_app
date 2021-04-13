//
//  SpecialOfferViewController.swift
//  CallRecorder
//
//  Created by Sandesh on 27/07/20.
//  Copyright © 2020 Smart Apps. All rights reserved.
//

import UIKit

protocol SpecialOfferViewControllerProtocol: UIViewController {
    var delegate: SpecialOfferViewControllerDelegate? { get set}
    var uiProviderDelegate: SpecialOfferUIProviderDelegate? { get set }
    func updateTimer(_ timeString: String)
}

protocol SpecialOfferViewControllerDelegate: class {
    func viewDidLoad(_ controller: SpecialOfferViewController)
    func viewWillAppear(_ controller: SpecialOfferViewController)
    func restorePurchases(_ controller: SpecialOfferViewController)
    func didTapBackButton(_ controller: SpecialOfferViewController)
    func didTapCancelButton(_ controller: SpecialOfferViewController)
    func showPrivacyPolicy(_ controller: SpecialOfferViewController)
    func showTermsOfLaw(_ controller: SpecialOfferViewController)
    func purchaseOffer(_ controller: SpecialOfferViewController)
}

protocol SpecialOfferUIProviderDelegate: class {
    func productsFetched() -> Bool
    func originalPrice() -> String
    func discountedPrice() -> String
    func percentDiscount() -> String
    func monthlyComputedDiscountPrice(withIntroDiscount: Bool, withDurationSuffix: Bool) -> String
}

class SpecialOfferViewController: UIViewController, SpecialOfferViewControllerProtocol {
    
    weak var delegate: SpecialOfferViewControllerDelegate?
    weak var uiProviderDelegate: SpecialOfferUIProviderDelegate?

    private var borderLayer: CALayer!
    private var lastBounds: CGRect!
    
    @IBOutlet weak var offerHeaderView: UIView!
    @IBOutlet weak var offerDescriptionLabel: UILabel!
    @IBOutlet weak var offerDescriptionSubheadingLabel: UILabel!
    @IBOutlet weak var offerTimerLabel: UILabel!
    
    @IBOutlet weak var saveExtraHeaderLabel: UILabel!
    @IBOutlet weak var savingPercentageLabel: UILabel!
    
    @IBOutlet weak var actualPriceLabel: UILabel!
    @IBOutlet weak var discountedPriceLabel: UILabel!
    @IBOutlet weak var savingBreakdownLabel: UILabel!
    
    @IBOutlet weak var featureLabelsStackView: UIStackView!
    @IBOutlet weak var feature1Label: UILabel!
    @IBOutlet weak var feature2Label: UILabel!
    @IBOutlet weak var feature3Label: UILabel!
    @IBOutlet weak var feature4Label: UILabel!
    
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var privacyPolicyAndTermsLabel: UILabel!
    @IBOutlet weak var restoreButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate?.viewDidLoad(self)
        _configureVerticalSpaceBetweenContinueAndFeatureList()
        _configureRestoreButton()
        _configureOfferDescriptionAndSubheadingLabel()
        _configureOfferTimerLabel()
        _configureSaveExtraHeaderAndPercentageLabel()
        _configureActualPriceLabel()
        _configureDiscountedPriceLabel()
        _configureSavingBreakdownLabel()
        _configureFeatureLabel()
        _configureContinueButton()
        _configurePrivacyPolicyAndTermsAndConditionLabel()
        _configureCancelButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        delegate?.viewWillAppear(self)
        print("**********uiProviderDelegate!.productsFetched() else ")
        
        NotificationCenter.default.addObserver(self, selector:
                                                #selector(_configureSubscriptionButtonsAndLabels(notification:)), name:
                                                    Notification.Name.iapProductsFetchedNotification,
                                               object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        _configureOfferDescriptionView()
    }
    
    @objc private func _configureSubscriptionButtonsAndLabels(notification: Notification?) {
        _configureSaveExtraHeaderAndPercentageLabel()
        _configureOfferDescriptionView()
        _configureActualPriceLabel()
        _configureDiscountedPriceLabel()
        _configureSavingBreakdownLabel()
    }
    
    private func _configureCancelButton() {
        cancelButton.titleLabel?.configure(with: UIFont.font(.avenirBook, style: .title2))
        cancelButton.setTitle("𝘅", for: .normal)
    }
    
    private func _configureVerticalSpaceBetweenContinueAndFeatureList() {
        let bounds = UIScreen.main.bounds
        
        if bounds.height <= 568 {
            //4" devices
            featureLabelsStackView.spacing = 4
            featureLabelsStackView.isHidden = true
        } else if bounds.height <= 667 {
            //4.7" devices
            featureLabelsStackView.spacing = 4
        } else if bounds.height <= 736 {
            // 5.5"
            featureLabelsStackView.spacing = 10
        } else if bounds.height <= 844 {
            // 11 PRO, iPhoneXS  & iPhone X
            featureLabelsStackView.spacing = 20
        } else if bounds.height > 844 {
            // 11 PRO MAX, XS MAX, XR & 11
            featureLabelsStackView.spacing = 26
        }
    }
    
    private func _configureRestoreButton() {
        let attributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.underlineStyle: 1,
            NSAttributedString.Key.foregroundColor: UIColor.gray,
            NSAttributedString.Key.font: UIFont.font(.avenirBook, style: .body)
            ]
        let attributedHeader = NSAttributedString(string: "Restore Purchase".localized, attributes: attributes)
        restoreButton.setAttributedTitle(attributedHeader, for: .normal)
    }
    
    private func _configureOfferDescriptionView() {
        if lastBounds == nil || lastBounds != offerHeaderView.bounds {
            lastBounds = offerHeaderView.bounds
            borderLayer?.removeFromSuperlayer()
            borderLayer = CALayer()
            borderLayer.frame = offerHeaderView.bounds
            print(offerHeaderView.bounds)
            borderLayer.borderColor = UIColor.gray.cgColor
            borderLayer.borderWidth = 2.2
            borderLayer.cornerRadius = 18
            offerHeaderView.layer.insertSublayer(borderLayer, at: 0)
        }
    }
    
    private func _configureOfferDescriptionAndSubheadingLabel() {
        offerDescriptionLabel.configure(with: UIFont.font(.avenirBook, style: .largeTitle))
        offerDescriptionLabel.text = "LIMITED \nTIME \nOFFER".localized
        
        offerDescriptionSubheadingLabel.configure(with: UIFont.font(.avenirBook, style: .title2))
        offerDescriptionSubheadingLabel.text = "ENDS IN".localized
    }
    
    private func _configureOfferTimerLabel() {
        offerTimerLabel.configure(with: UIFont.font(.avenirBook, style: .title1))
    }
    
    private func _configureSaveExtraHeaderAndPercentageLabel() {            
        saveExtraHeaderLabel.configure(with: UIFont.font(.avenirBook, style: .title3))
        saveExtraHeaderLabel.adjustsFontForContentSizeCategory = true
        saveExtraHeaderLabel.adjustsFontSizeToFitWidth = true
        
        savingPercentageLabel.configure(with: UIFont.font(.avenirBook, style: .largeTitle))
        savingPercentageLabel.adjustsFontForContentSizeCategory = true
        savingPercentageLabel.adjustsFontSizeToFitWidth = true
        savingPercentageLabel.text = "\(uiProviderDelegate!.percentDiscount())%"
    }
    
    private func _configureActualPriceLabel() {
        actualPriceLabel.configure(with: UIFont.font(.avenirBook, style: .title3))
        let attributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.strikethroughStyle: 1,
                                                         NSAttributedString.Key.strikethroughColor: UIColor.text
        ]
        let attributedActualPrice = NSAttributedString(string: uiProviderDelegate!.originalPrice(), attributes: attributes)
        actualPriceLabel.attributedText = attributedActualPrice
    }
    
    private func _configureDiscountedPriceLabel() {
        discountedPriceLabel.adjustsFontForContentSizeCategory = true
        discountedPriceLabel.adjustsFontSizeToFitWidth = true
        discountedPriceLabel.configure(with: UIFont.font(.avenirBook, style: .title2))
        discountedPriceLabel.text = "NOW".localized + "\(uiProviderDelegate!.discountedPrice())"
    }
    
    private func _configureSavingBreakdownLabel() {
        savingBreakdownLabel.configure(with: UIFont.font(.avenirBook, style: .subheadline))
        //styles definition
        let blackFont = UIFont.font(.avenirBook, style: .subheadline)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        paragraphStyle.alignment = .center
        
        
        let attributedString = NSMutableAttributedString(string: "For 1 year\n".localized)
        let attributedString1 = NSMutableAttributedString(string: "only".localized)
        let attributedString2 = NSMutableAttributedString(string: "\(uiProviderDelegate!.monthlyComputedDiscountPrice(withIntroDiscount: true, withDurationSuffix: false)) / ",
                                                          attributes: [NSAttributedString.Key.font: blackFont])
        let attributedString3 = NSMutableAttributedString(string: "month".localized, attributes: [NSAttributedString.Key.font: blackFont])
        
        attributedString.append(attributedString1)
        attributedString.append(attributedString2)
        attributedString.append(attributedString3)
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.string.count))
        savingBreakdownLabel.attributedText = attributedString
        
    }
    
    private func _configureFeatureLabel() {
        let bounds = UIScreen.main.bounds
        let style: UIFont.TextStyle = bounds.height > 812 ? .title3 : .callout
        
        feature1Label.configure(with: UIFont.font(.avenirBook, style: style))
        feature1Label.text = "Automatic call recordings".localized
         
        feature2Label.configure(with: UIFont.font(.avenirBook, style: style))
        feature2Label.text = "Unlimited recordings".localized

        feature3Label.configure(with: UIFont.font(.avenirBook, style: style))
        feature3Label.text = "No per minute fees".localized

        feature4Label.configure(with: UIFont.font(.avenirBook, style: style))
        feature4Label.text = "Cancel at any time".localized
    }
    
    private func _configureContinueButton() {
        continueButton.backgroundColor = .systemGreen
        continueButton.titleLabel?.configure(with: UIFont.font(.avenirBook, style: .title3))
        continueButton.titleLabel?.textColor = .text
        continueButton.setTitle("Continue".localized, for: .normal)
    }
    
    private func _configurePrivacyPolicyAndTermsAndConditionLabel() {
        let text = "By signing up you agree to our Terms of law and Privacy policy".localized
        let attributedString = NSMutableAttributedString(string: text)
        let range1 = (text as NSString).range(of: "Terms of law".localized)
        attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: 1, range: range1)
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.primary, range: range1)
        let range2 = (text as NSString).range(of: "Privacy policy".localized)
        attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: 1, range: range2)
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.primary, range: range2)
        
        //adding spacing
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        paragraphStyle.alignment = .center
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: text.count))
        
        privacyPolicyAndTermsLabel.configure(with: UIFont.font(.avenirBook, style: .subheadline))
        privacyPolicyAndTermsLabel.attributedText = attributedString
        
        //Adding Tap geture
        privacyPolicyAndTermsLabel.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer()
        tapGesture.numberOfTouchesRequired = 1
        tapGesture.numberOfTapsRequired = 1
        tapGesture.addTarget(self, action: #selector(didTapLabel(_:)))
        privacyPolicyAndTermsLabel.addGestureRecognizer(tapGesture)
    }
    
    @objc func didTapLabel(_ tapGesture: UITapGestureRecognizer) {
        let labelString = privacyPolicyAndTermsLabel.text! as NSString
        
        let termsOfLaw = labelString.range(of: "Terms of law".localized)
        let privacyPolicyRange = labelString.range(of: "Privacy policy".localized)
        
        if tapGesture.didTapAttributedTextInLabel(label: privacyPolicyAndTermsLabel, inRange: termsOfLaw) {
            delegate?.showTermsOfLaw(self)
        } else  if tapGesture.didTapAttributedTextInLabel(label: privacyPolicyAndTermsLabel, inRange: privacyPolicyRange) {
            delegate?.showPrivacyPolicy(self)
        }
    }
    
    @IBAction func restorePurchases(_ sender: UIButton) {
        delegate?.restorePurchases(self)
    }
    
    @IBAction func continueWithOffer(_ sender: UIButton) {
        delegate?.purchaseOffer(self)
    }
    
    @IBAction func didTapBackButton(_ sender: UIButton) {
        delegate?.didTapBackButton(self)
    }
    
    @IBAction func didTapCancelButton(_ sender: UIButton) {
        delegate?.didTapCancelButton(self)
    }
    
    func updateTimer(_ timeString: String) {
        offerTimerLabel.text = timeString
    }
}
