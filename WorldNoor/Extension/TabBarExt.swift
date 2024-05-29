//
//  TabBarExt.swift
//  WorldNoor
//
//  Created by Raza najam on 10/16/19.
//  Copyright © 2019 Raza najam. All rights reserved.
//

import Foundation
import UIKit

//
//extension UITabBarController {
//    func orderedTabBarItemViews() -> [UIView] {
//        let interactionViews = tabBar.subviews.filter({$0.isUserInteractionEnabled})
//        return interactionViews.sorted(by: {$0.frame.minX < $1.frame.minX})
//    }
//}


extension UITabBar {
        func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
//            guard let viewControllers = viewController else { return false }
            
            let index = tabBarController.viewControllers?.firstIndex(of: viewController)

            
            LogClass.debugLog("viewControllers ===>")
            LogClass.debugLog(index)
//            if viewController == viewControllers[selectedIndex] {
//                if let nav = viewController as? UINavigationController {
//                    guard let topController = nav.viewControllers.last else { return true }
//                    if !topController.isScrolledToTop {
//                        topController.scrollToTop()
//                        return false
//                    } else {
//                        nav.popViewController(animated: true)
//                    }
//                    return true
//                }
//            }
    
            return true
        }
    
}

//class TabBarController: UITabBarController,UITabBarControllerDelegate {
//
//       override func viewDidLoad() {
//    super.viewDidLoad()
//
//    // Do any additional setup after loading the view.
//    self.delegate = self
//}
//
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//
//    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
//        guard let viewControllers = viewControllers else { return false }
//        if viewController == viewControllers[selectedIndex] {
//            if let nav = viewController as? UINavigationController {
//                guard let topController = nav.viewControllers.last else { return true }
//                if !topController.isScrolledToTop {
//                    topController.scrollToTop()
//                    return false
//                } else {
//                    nav.popViewController(animated: true)
//                }
//                return true
//            }
//        }
//
//        return true
//    }
//
//}


extension UIViewController {
    func scrollToTop() {
        func scrollToTop(view: UIView?) {
            guard let view = view else { return }
            
            switch view {
            case let scrollView as UIScrollView:
                if scrollView.scrollsToTop == true {
                    scrollView.setContentOffset(CGPoint(x: 0.0, y: -scrollView.contentInset.top), animated: true)
                    return
                }
            default:
                break
            }
            
            for subView in view.subviews {
                scrollToTop(view: subView)
            }
        }
        
        scrollToTop(view: view)
    }
    
    // Changed this
    
    var isScrolledToTop: Bool {
        if self is UITableViewController {
            return (self as! UITableViewController).tableView.contentOffset.y == 0
        }
        for subView in view.subviews {
            if let scrollView = subView as? UIScrollView {
                return (scrollView.contentOffset.y == 0)
            }
        }
        return true
    }
}
