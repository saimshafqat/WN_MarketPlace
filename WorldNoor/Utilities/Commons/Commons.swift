//
//  Commons.swift
//  WorldNoor
//
//  Created by Muhammad Asher on 01/06/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit

class Commons {
    
    static var share = Commons()
    
    // MARK: - App Theme -
    // here we will handle app theme
    func customizeAppTheme() {
        UINavigationBar.edgeBarAppearence()
        UITabBar.edgeBarAppearence()
        // UITabBar.itemAppearence()
    }
    
    func canOpenURL(value: String) {
        guard let settingsUrl = URL(string: value) else { return }
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, completionHandler: { (success) in })
        }
    }
}

