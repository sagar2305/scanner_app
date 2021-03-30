//
//  Coordinator.swift
//  Document Scanner
//
//  Created by Sandesh on 04/03/21.
//

import UIKit

protocol Coordinator: class {
    var rootViewController: UIViewController { get }
    var childCoordinator: [Coordinator] { get set }
    
    func start()
}
