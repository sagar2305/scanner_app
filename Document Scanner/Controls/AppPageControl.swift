//
//  AppPageControl.swift
//  Document Scanner
//
//  Created by Sandesh on 07/09/21.
//

import UIKit

@IBDesignable
class AppPageContol: UIControl {
    
    
    
    private var pageControlViews = [UIView]() {
        didSet{
          if pageControlViews.count == numberOfPages {
            setupViews()
          }
        }
      }
      
      @IBInspectable var numberOfPages: Int = 0 {
        didSet{
          for tag in 0 ..< numberOfPages {
            let dot = getDotView()
            dot.tag = tag
            dot.backgroundColor = pageIndicatorTintColor
            self.pageControlViews.append(dot)
          }
          
        }
      }
      
      var currentPage: Int = 0 {
        didSet{
            pageControlViews.forEach { dot in
                let isSelected = dot.tag == currentPage
                UIView.animate(withDuration: 0.2, animations: {
                    dot.backgroundColor = isSelected ?  self.currentPageIndicatorTintColor : self.pageIndicatorTintColor
                    if isSelected {
                        dot.widthAnchor.constraint(equalTo: self.stackView.heightAnchor, multiplier: 5, constant: 0).isActive = true
                    } else {
                        dot.widthAnchor.constraint(equalTo: self.stackView.heightAnchor, multiplier: 0.45, constant: 0).isActive = true
                    }
                    self.layoutIfNeeded()
                })
            }
        }
      }
    
    @IBInspectable var pageIndicatorTintColor: UIColor? = .lightGray
    @IBInspectable var currentPageIndicatorTintColor: UIColor? = .darkGray
   
    
    private lazy var stackView = UIStackView.init(frame: self.bounds)
    private lazy var constantSpace = ((stackView.spacing) * CGFloat(numberOfPages - 1) + ((self.bounds.height * 0.45) * CGFloat(numberOfPages)) - self.bounds.width)
     
     
     override var bounds: CGRect {
       didSet{
         self.pageControlViews.forEach { (dot) in
           self.setupDotAppearance(dot: dot)
         }
       }
     }

    //MARK: Helper methods...
     private func getDotView() -> UIView {
       let dot = UIView()
       self.setupDotAppearance(dot: dot)
       dot.translatesAutoresizingMaskIntoConstraints = false
       return dot
     }
     
     private func setupDotAppearance(dot: UIView) {
       dot.transform = .identity
       dot.layer.cornerRadius = dot.bounds.height / 2
        dot.clipsToBounds = true
       dot.backgroundColor = pageIndicatorTintColor
     }
    
    convenience init() {
        self.init(frame: .zero)
      }
      
      init(withNoOfPages pages: Int) {
        self.numberOfPages = pages
        self.currentPage = 0
        super.init(frame: .zero)
        setupViews()
      }
      
      override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
      }
      
      required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
        self.currentPage = 0
      }
    
    
    private func setupViews() {
      
      self.pageControlViews.forEach { (dot) in
        self.stackView.addArrangedSubview(dot)
      }
      
      stackView.alignment = .fill
      stackView.axis = .horizontal
      stackView.distribution = .fill
      stackView.spacing = 8
      
      stackView.translatesAutoresizingMaskIntoConstraints = false
      self.addSubview(stackView)
      
      
      self.addConstraints([
        
        stackView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
        stackView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
        stackView.heightAnchor.constraint(equalTo: self.heightAnchor),
        stackView.widthAnchor.constraint(equalTo: self.widthAnchor)
        
        ])
      
      self.pageControlViews.forEach { dot in
        
        self.addConstraints([
            dot.centerYAnchor.constraint(equalTo: stackView.centerYAnchor),
            dot.widthAnchor.constraint(equalTo: self.stackView.heightAnchor, multiplier: 0.45, constant: 0),
            dot.heightAnchor.constraint(equalTo: self.stackView.heightAnchor, multiplier: 0.45, constant: 0)
        ])
        
      }
        
    }
}
