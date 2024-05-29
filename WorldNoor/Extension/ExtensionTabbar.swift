//
//  ExtensionTabbar.swift
//  WorldNoor
//
//  Created by Muhammad Asher on 01/06/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit

extension UITabBar {
    // transparent for iOS 15.0 and onward
    static func edgeBarAppearence() {
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}
