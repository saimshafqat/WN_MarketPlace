//
//  ExtensionSegmentControl.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 04/03/24.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import Foundation

extension UISegmentedControl {
 
    // helpful in creating section
    func createSegments(_ list: [String]) {
        removeAllSegments()
        for (index, value) in list.enumerated() {
            insertSegment(withTitle: value, at: index, animated: false)
        }
        selectedSegmentIndex = 0
    }
    
    // will update text attributes
    func titleAttributes(selected: UIColor, unSelected: UIColor) {
        setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 14), .foregroundColor: unSelected], for: .normal)
        setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 14, weight: .medium), .foregroundColor: selected], for: .selected)
    }
    
    func backgrounTransparent() {
        for i in 0...(numberOfSegments - 1)  {
          subviews[i].isHidden = true
        }
        backgroundColor = .white
    }
}
