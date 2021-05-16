//
//  NVActivityIndicatorView+Extension.swift
//  Document Scanner
//
//  Created by Sandesh on 15/05/21.
//

import NVActivityIndicatorView

extension NVActivityIndicatorView {
    static func start() {
        let activityData = ActivityData(type: .ballScaleMultiple)
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
    }
    
    static func stop() {
        NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
    }
}
