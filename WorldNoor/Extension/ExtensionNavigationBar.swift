//
//  ExtensionNavigationBar.swift
//  WorldNoor
//
//  Created by Muhammad Asher on 01/06/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit

extension UINavigationBar {
    
    @objc static func edgeBarAppearence() {
        if #available(iOS 15, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}
