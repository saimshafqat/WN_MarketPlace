//
//  CommonExtension.swift
//  WorldNoor
//
//  Created by apple on 9/22/21.
//  Copyright © 2021 Raza najam. All rights reserved.
//

import Foundation
import UIKit

extension UIApplication {
    
    public var mainKeyWindow: UIWindow? {
        return windows.first(where: { $0.isKeyWindow }) ?? keyWindow
    }

    public var rootViewController: UIViewController? {
        guard let keyWindow = UIApplication.shared.mainKeyWindow, let rootViewController = keyWindow.rootViewController else {
            return nil
        }
        return rootViewController
    }

    public func topViewController(controller: UIViewController? = UIApplication.shared.rootViewController) -> UIViewController? {

        if controller == nil {
            return topViewController(controller: rootViewController)
        }
        
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }

        if let tabController = controller as? UITabBarController {
            if let selectedViewController = tabController.selectedViewController {
                return topViewController(controller: selectedViewController)
            }
        }

        if let presentedViewController = controller?.presentedViewController {
            return topViewController(controller: presentedViewController)
        }

        return controller
    }
}
