//
//  AppTabBarViewController.swift
//  Document Scanner
//
//  Created by Sandesh on 09/08/21.
//

import UIKit

class TabVC: UIViewController { }

class AppTabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        setupVCs()
        navigationController?.navigationBar.isHidden = true
    }
    
    private lazy var tabItem1Image: UIImage = {
        guard let image = UIImage(named: "upload-document") else { return UIImage()}
        image.withRenderingMode(.alwaysOriginal)
        return image
    }()
    
    private lazy var tabItem2Image: UIImage = {
        guard let image = UIImage(named: "scan-document") else { return UIImage()}
        image.withRenderingMode(.alwaysOriginal)
        return image
    }()
    
    private lazy var tabItem3Image: UIImage = {
        guard let image = UIImage(named: "settings") else { return UIImage()}
        image.withRenderingMode(.alwaysOriginal)
        return image
    }()
    
    static func buildViewController() -> AppTabBarViewController {
      let controller = UIStoryboard(name: "AppTabBarViewController",
                                    bundle: .main).instantiateViewController(withIdentifier: String(describing: AppTabBarViewController.self))
      return controller as! AppTabBarViewController
    }
    
    private func createNavController(for rootViewController: UIViewController,
                                     title: String,
                                     image: UIImage) -> UIViewController {
        let navController = UINavigationController(rootViewController: rootViewController)
        navController.tabBarItem.title = title
        navController.tabBarItem.image = image
        navController.navigationBar.prefersLargeTitles = true
        rootViewController.navigationItem.title = title
        return navController
    }
    
    func setupVCs() {
        if #available(iOS 13.0, *) {
            viewControllers = [
                createNavController(for: HomeViewController(), title: NSLocalizedString("Search", comment: ""), image: tabItem1Image),
                createNavController(for: TabVC(), title: NSLocalizedString("Search", comment: ""), image: tabItem2Image),
                createNavController(for: SettingsVC(), title: NSLocalizedString("Home", comment: ""), image: tabItem3Image),
            ]
        } else {
            // Fallback on earlier versions
        }
    }
}

extension AppTabBarViewController: UITabBarControllerDelegate {
 
}

class AppTabBar: UITabBar {
    let barHeight: CGFloat = 54
    var shapeLayer: CALayer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _addShape()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        _addShape()
    }
    override func awakeFromNib() {
      super.awakeFromNib()
        tintColor = .white
        unselectedItemTintColor = UIColor.white.withAlphaComponent(0.4)
    }
    
    override func draw(_ rect: CGRect) {
        _addShape()
    }
    
    private func _addShape() {
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = _createPath()
        shapeLayer.fillColor = UIColor.primary.cgColor
        
        //shapeLayer.strokeColor = UIColor.red.cgColor
        shapeLayer.lineWidth = 0.5
        if let oldShapeLayer = self.shapeLayer {
          self.layer.replaceSublayer(oldShapeLayer, with: shapeLayer)
        } else {
          self.layer.insertSublayer(shapeLayer, at: 0)
        }
        self.shapeLayer = shapeLayer
    }
    
    
    private func _createPath() -> CGPath {
//        let leftArcCenter = CGPoint(x: 0 + barHeight/2, y: frame.height - barHeight/2)
//        let rightArcCenter = CGPoint(x: frame.width - barHeight/2, y: frame.height - barHeight/2)
//
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: barHeight/2))
        path.addCurve(to: CGPoint(x: barHeight/1.5, y: -10),
                      controlPoint1: CGPoint(x: 0, y: 25),
                      controlPoint2: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: frame.width - barHeight/1.5, y: -10))
        path.addCurve(to: CGPoint(x: frame.width, y: barHeight/2),
                      controlPoint1: CGPoint(x: frame.width, y: 0),
                      controlPoint2: CGPoint(x: frame.width, y: 25))
        path.addLine(to: CGPoint(x: frame.width, y: frame.height))
        path.addLine(to: CGPoint(x: 0, y: frame.height))
        path.close()
        return path.cgPath
    }
}
