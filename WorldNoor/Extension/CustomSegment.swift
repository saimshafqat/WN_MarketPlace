////
////  CustomSegment.swift
////  WorldNoor
////
////  Created by Waseem Shah on 31/08/2023.
////  Copyright © 2023 Raza najam. All rights reserved.
////
//
//import Foundation
//import UIKit
//
//class PlainSegmentedControl: UISegmentedControl {
//    override init(items: [Any]?) {
//        super.init(items: items)
//
//        setup()
//    }
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//    }
//
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
////        fatalError("init(coder:) has not been implemented")
//    }
//
//    // Used for the unselected labels
//    override var tintColor: UIColor! {
//        didSet {
//            setTitleTextAttributes([.foregroundColor: UIColor.blueColor, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13, weight: .regular)], for: .normal)
//        }
//    }
//
//    // Used for the selected label
//    override var selectedSegmentTintColor: UIColor? {
//        didSet {
//            setTitleTextAttributes([.foregroundColor: UIColor.blueColor, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13, weight: .regular)], for: .selected)
//        }
//    }
//
//    private func setup() {
//        backgroundColor = .clear
//
//        // Use a clear image for the background and the dividers
//        let tintColorImage = UIImage()
//        setBackgroundImage(tintColorImage, for: .normal, barMetrics: .default)
//        setDividerImage(tintColorImage, forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
//
//        // Set some default label colors
//        setTitleTextAttributes([.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13, weight: .regular)], for: .normal)
//        setTitleTextAttributes([.foregroundColor: tintColor!, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13, weight: .regular)], for: .selected)
//    }
//}
