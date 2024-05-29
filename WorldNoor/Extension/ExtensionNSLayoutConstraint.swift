//
//  NSLayoutConstraint.swift
//  WorldNoor
//
//  Created by ogouluser1-mac6 on 10/07/2023.
//  Copyright © 2023 Asher Azeem. All rights reserved.
//

import UIKit

extension NSLayoutConstraint {
    func setMultiplier(_ multiplier: CGFloat) -> NSLayoutConstraint {
        NSLayoutConstraint.deactivate([self])
        let newConstraint = NSLayoutConstraint(
            item: firstItem as Any,
            attribute: firstAttribute,
            relatedBy: relation,
            toItem: secondItem,
            attribute: secondAttribute,
            multiplier: multiplier,
            constant: constant)
        newConstraint.priority = priority
        newConstraint.shouldBeArchived = self.shouldBeArchived
        newConstraint.identifier = self.identifier
        NSLayoutConstraint.activate([
            newConstraint
        ])
        return newConstraint
    }
}
