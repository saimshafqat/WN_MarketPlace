//
//  STableViewCell.swift
//  WorldNoor
//
//  Created by Asher Azeem on 19/04/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit

protocol Shadowable {
    func addShadow(with color: UIColor)
}

extension UILabel: Shadowable {}
extension UIButton: Shadowable {}
extension UISlider: Shadowable {}
extension UIImageView: Shadowable {}

extension Shadowable where Self: UIView {
    func addShadow(with color: UIColor) {
        layer.shadowOffset = CGSize(width: 1, height: 1)
        layer.shadowOpacity = 0.6
        layer.shadowRadius = 0.6
        layer.shadowColor = color.cgColor
    }
}
