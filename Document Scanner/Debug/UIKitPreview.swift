//
//  UIKitPreview.swift
//  Document Scanner
//
//  Created by Sandesh on 19/04/21.
//

import SwiftUI

struct UIKitPreview: UIViewRepresentable {
    typealias UIViewType = UIView

    let view: UIViewType

    func makeUIView(context: Context) -> UIViewType {
        view
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {

    }
}
