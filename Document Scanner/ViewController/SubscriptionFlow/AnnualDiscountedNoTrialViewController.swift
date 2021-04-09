////
////  AnnualDiscountedNoTrialViewController.swift
////  CallRecorder
////
////  Created by Sagar on 8/12/20.
////  Copyright © 2020 Smart Apps. All rights reserved.
////
//
//import UIKit
//import LGButton
//import NVActivityIndicatorView
//import Lottie
//
//class AnnualDiscountedNoTrialViewController: UIViewController, SubscriptionViewControllerProtocol {
//
//    private let bounds = UIScreen.main.bounds
//    private var featureLabelTextStyle: UIFont.TextStyle = .callout
//    private var restoreButtonTextStyle: UIFont.TextStyle = .footnote
//    private let lottieView = AnimationView(name: "HelloAnimation")
//    
//    weak var delegate: SubscriptionViewControllerDelegate?
//    weak var uiProviderDelegate: UpgradeUIProviderDelegate?
//    weak var specialOfferUIProviderDelegate: SpecialOfferUIProviderDelegate?
//    
//    @IBOutlet weak var cancelButton: UIButton!
//    
//    @IBOutlet weak var primaryHeaderLabel: UILabel!
//    @IBOutlet weak var pricingTopLabel: UILabel!
//    @IBOutlet weak var animationView: UIView!
//    
//    @IBOutlet weak var pricingBottomLabel: UILabel!
//    @IBOutlet weak var restorePurchasesButton: UIButton!
//    
//    @IBOutlet weak var stackViewHeightConstraint: NSLayoutConstraint!
//    
//    @IBOutlet weak var feature1Label: UILabel!
//    @IBOutlet weak var feature2Label: UILabel!
//    @IBOutlet weak var feature3Label: UILabel!
//    @IBOutlet weak var feature4Label: UILabel!
//    @IBOutlet weak var continueButton: UIButton!
//    
//    @IBOutlet weak var privacyAndTermsOfLawLabel: UILabel!
//    var giftOffer: Bool = false
//    var hideCloseButton: Bool = false
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        _configureUI()
//        _configureFeatureLabel()
//        _configurePrimaryHeaderLabel()
//        _configurePricingBottomLabel()
//        _configureFeatureLabel()
//        _configureContinueButton()
//        _configurePrivacyAndTermsOfLawLabel()
//        _configurePricingTopLabel()
//        _configureRestorePurchasesButton()
//        _configureCancelButton()
//        
//        if uiProviderDelegate!.productsFetched() {
//            setupSubscriptionButtons(notification: nil)
//        } else {
//            NotificationCenter.default.addObserver(self, selector:
//                                                    #selector(setupSubscriptionButtons(notification:)), name:
//                                                        Notification.Name.iapProductsFetchedNotification,
//                                                   object: nil)
//        }
//        
//        lottieView.frame = animationView.bounds
//        lottieView.contentMode = .scaleAspectFit
//        lottieView.loopMode = .loop
//        lottieView.animationSpeed = 1.0
//        let xOffset: CGFloat = bounds.width >= 400 ? -18 : -40
//        lottieView.frame = lottieView.frame.offsetBy(dx: xOffset, dy: 0)
//        animationView.addSubview(lottieView)
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        delegate?.viewWillAppear(self)
//        lottieView.play()
//    }
//    
//    @objc func setupSubscriptionButtons(notification: Notification?) {
//        NVActivityIndicatorView.stop()
//        _configurePrimaryHeaderLabel()
//        _configurePricingTopLabel()
//        _configurePricingBottomLabel()
//    }
//    
//    private func _configureUI() {
//        primaryHeaderLabel.configure(with: UIFont.font(.sofiaProBlack, style: .largeTitle))
//        
//        if bounds.height >= 896 {
//        // 12 PRO MAX, 11 PRO MAX, XS MAX, XR , 11
//            featureLabelTextStyle = bounds.height >= 926 ? .title3 : .headline
//            // 12 PRO MAX
//            stackViewHeightConstraint.constant = bounds.height >= 926 ? 170 : 160
//            restoreButtonTextStyle = .body
//            pricingTopLabel.configure(with: UIFont.font(.sofiaProBold, style: .title2))
//        } else if bounds.height >= 812 {
//        // 11 PRO, iPhoneXS  & iPhone X, iPhone 12 & 12 PRO
//            featureLabelTextStyle = .body
//            restoreButtonTextStyle = .body
//            pricingTopLabel.configure(with: UIFont.font(.sofiaProBold, style: .title3))
//        } else {
//        // all the rest
//            restoreButtonTextStyle = .callout
//            pricingTopLabel.configure(with: UIFont.font(.sofiaProBold, style: .headline))
//            featureLabelTextStyle = .body
//        }
//    }
//    
//    private func _configurePrimaryHeaderLabel() {
//        if giftOffer {
//            primaryHeaderLabel.text = "A gift to yourself".localized.capitalized
//        } else {
//            primaryHeaderLabel.text = uiProviderDelegate?.headerMessage(for: 0)
//        }
//    }
//    
//    private func _configurePricingTopLabel() {
//        
//        if ConfigurationHelper.shared.isLifetimePlanAvailable && PhoneNumberHelper.shared.isIndianUser {
//            pricingTopLabel.configure(with: UIFont.font(.sofiaProRegular, style: .title2))
//            let attributedString = NSMutableAttributedString(string: "\(uiProviderDelegate!.subscriptionPrice(for: 0, withDurationSuffix: false))")
//            pricingTopLabel.attributedText = attributedString
//        } else {
//            let attributedString = NSMutableAttributedString(string: "\(uiProviderDelegate!.introductoryPrice(for: 0, withDurationSuffix: true)) ")
//            let attributedString1 = NSMutableAttributedString(string:
//                                                                "(\(uiProviderDelegate!.subscriptionPrice(for: 0, withDurationSuffix: false)))".localized,
//                                                              attributes: [NSAttributedString.Key.strikethroughStyle: 1])
//            
//            attributedString.append(attributedString1)
//            pricingTopLabel.attributedText = attributedString
//        }
//    }
//    
//    private func _configurePricingBottomLabel() {
//        pricingBottomLabel.configure(with: UIFont.font(.sofiaProRegular, style: .subheadline))
//        if ConfigurationHelper.shared.isLifetimePlanAvailable && PhoneNumberHelper.shared.isIndianUser {
//            pricingBottomLabel.configure(with: UIFont.font(.sofiaProRegular, style: .title3))
//            pricingBottomLabel.text = "for lifetime".localized.localizedCapitalized
//        } else {
//            let price = specialOfferUIProviderDelegate!.monthlyComputedDiscountPrice(withIntroDiscount: true, withDurationSuffix: true)
//            pricingBottomLabel.text = "( \(price) " + "only".localized + " )"
//        }
//    }
//    
//    private func _configureFeatureLabel() {
//        
//        feature1Label.configure(with: UIFont.font(.sofiaProRegular, style: featureLabelTextStyle))
//        feature1Label.text = SubscribeCoordinator.attributedFeatureText("Automatic call recordings".localized)
//        
//        feature2Label.configure(with: UIFont.font(.sofiaProRegular, style: featureLabelTextStyle))
//        feature2Label.text = SubscribeCoordinator.attributedFeatureText("Unlimited recordings".localized)
//        
//        feature3Label.configure(with: UIFont.font(.sofiaProRegular, style: featureLabelTextStyle))
//        feature3Label.text = SubscribeCoordinator.attributedFeatureText("No per minute fees".localized)
//        
//        feature4Label.configure(with: UIFont.font(.sofiaProRegular, style: featureLabelTextStyle))
//        feature4Label.text = SubscribeCoordinator.attributedFeatureText("Cancel at any time".localized)
//    }
//    
//    private func _configureContinueButton() {
//        continueButton.layer.cornerRadius = 27
//        continueButton.backgroundColor = .primaryColor
//        continueButton.titleLabel?.configure(with: UIFont.font(.sofiaProBold, style: .headline))
//        let title = giftOffer ? "Redeem my offer".localized.uppercased() : "Continue".localized.uppercased()
//        continueButton.setTitle(title, for: .normal)
//    }
//    
//    private func _configureCancelButton() {
//        cancelButton.titleLabel?.configure(with: UIFont.font(.sofiaProBold, style: .title2))
//        cancelButton.setTitle("𝘅", for: .normal)
//        cancelButton.isHidden = hideCloseButton ? true : false
//    }
//    
//    private func _configureRestorePurchasesButton() {
//        let attributes: [NSAttributedString.Key: Any] = [
//            NSAttributedString.Key.underlineStyle: 1,
//            NSAttributedString.Key.foregroundColor: UIColor.secondaryTextColor,
//            NSAttributedString.Key.font: UIFont.font(.sofiaProRegular, style: restoreButtonTextStyle)
//        ]
//        let attributedHeader = NSAttributedString(string: "Restore Purchase".localized, attributes: attributes)
//        restorePurchasesButton.setAttributedTitle(attributedHeader, for: .normal)
//    }
//    
//    private func _configurePrivacyAndTermsOfLawLabel() {
//        let text = "Terms of law".localized + " " + "and".localized + " " + "Privacy policy".localized
//        let attributedString = NSMutableAttributedString(string: text)
//        let range1 = (text as NSString).range(of: "Terms of law".localized)
//        attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: 1, range: range1)
//        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.primaryColor, range: range1)
//        let range2 = (text as NSString).range(of: "Privacy policy".localized)
//        attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: 1, range: range2)
//        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.primaryColor, range: range2)
//        
//        privacyAndTermsOfLawLabel.configure(with: UIFont.font(.sofiaProRegular, style: .footnote))
//        privacyAndTermsOfLawLabel.attributedText = attributedString
//        
//        //Adding Tap gesture
//        privacyAndTermsOfLawLabel.isUserInteractionEnabled = true
//        let tapGesture = UITapGestureRecognizer()
//        tapGesture.numberOfTouchesRequired = 1
//        tapGesture.numberOfTapsRequired = 1
//        tapGesture.addTarget(self, action: #selector(didTapLabel(_:)))
//        privacyAndTermsOfLawLabel.addGestureRecognizer(tapGesture)
//    }
//    
//    @objc func didTapLabel(_ tapGesture: UITapGestureRecognizer) {
//        let labelString = privacyAndTermsOfLawLabel.text! as NSString
//        
//        let termsOfLaw = labelString.range(of: "Terms of law".localized)
//        let privacyPolicyRange = labelString.range(of: "Privacy policy".localized)
//        
//        if tapGesture.didTapAttributedTextInLabel(label: privacyAndTermsOfLawLabel, inRange: termsOfLaw) {
//            delegate?.showTermsOfLaw(self)
//        } else  if tapGesture.didTapAttributedTextInLabel(label: privacyAndTermsOfLawLabel, inRange: privacyPolicyRange) {
//            delegate?.showPrivacyPolicy(self)
//        }
//    }
//    
//    @IBAction func didTapCancelButton(_ sender: UIButton) {
//        delegate?.exit(self)
//    }
//    
//    @IBAction func didTapRestorePurchaseButton(_ sender: UIButton) {
//        delegate?.restorePurchases(self)
//    }
//    
//    @IBAction func didTapContinueButton(_ sender: UIButton) {
//        delegate?.selectPlan(at: 0, controller: self)
//    }
//}
