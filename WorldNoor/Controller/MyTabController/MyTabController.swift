//
//  MyTabController.swift
//  WorldNoor
//
//  Created by Raza najam on 10/16/19.
//  Copyright © 2019 Raza najam. All rights reserved.
//

import UIKit
import SDWebImage

class CustomTabBarBadgeView: UIView {
    
}


class MyTabController: UITabBarController {
    
    @IBOutlet weak var myTabBar: UITabBar!
    let customTabBarBadgeView = CustomTabBarBadgeView()
    
    var isSameIndex:Bool = false
    
    var upperLineView: UIView?
    
    let spacing: CGFloat = 12
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.handleFontSize()
            self.addTabbarIndicatorView(index: 0, isFirstTime: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.setProfileTabImage()
        }
    }
    
    func handleFontSize() {
        if let items = self.tabBar.items {
            for item in items {
                // Adjust the font size and other attributes as needed
                item.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 9)], for: .normal)
            }
        }
    }
    
    func addTabbarIndicatorView(index: Int, isFirstTime: Bool = false){
        guard let tabView = tabBar.items?[index].value(forKey: "view") as? UIView else {
            return
        }
        if !isFirstTime{
            upperLineView?.removeFromSuperview()
        }
        upperLineView = UIView(frame: CGRect(x: tabView.frame.minX + spacing, y: tabView.frame.minY + 0.1, width: tabView.frame.size.width - spacing * 2, height: 2))
//        upperLineView.backgroundColor = UIColor.tabSelectionBG
        upperLineView?.backgroundColor = UIColor.init(red: (58/255), green: (125/255), blue: (161/255), alpha: 1.0)
        if upperLineView != nil {
            tabBar.addSubview(upperLineView!)
        }
    }
    
    func setProfileTabImage(_ borderColor: UIColor = .darkGray) {
        let fileName = "myImageToUpload.jpg"
        let thirdTabBarItemIndex = 4
        var customImage = FileBasedManager.shared.loadProfileImage(pathMain: fileName)
        let resizedImage = resizeImage(image: customImage, targetSize: CGSize(width: 30, height: 30))
        let roundedImage = makeRoundedImageWithBorder(image: resizedImage, borderWidth: 2.5, borderColor: borderColor)?.withRenderingMode(.alwaysOriginal)
        if customImage != nil {
            self.tabBar.items?[thirdTabBarItemIndex].image = roundedImage
            self.tabBar.items?[thirdTabBarItemIndex].selectedImage = roundedImage
        } else {
            self.tabBar.items?[thirdTabBarItemIndex].image = UIImage(named: "personPlaceholder")
            self.tabBar.items?[thirdTabBarItemIndex].selectedImage = UIImage(named: "personPlaceholder")
        }
        if let tabBarItems = self.tabBar.items, tabBarItems.count >= 4 {
            // Get the fourth tabBarItem's icon
            let batchSize = 18.0
            if let fourthTabBarItem = tabBarItems[thirdTabBarItemIndex].value(forKey: "view") as? UIView,

                let fourthTabImageView = fourthTabBarItem.value(forKey: "imageView") as? UIImageView {
                let fourthTabIconFrame = fourthTabImageView.convert(fourthTabImageView.bounds, to: self.tabBar)
                
                // Calculate the x-coordinate for the customTabBarBadgeView
                let badgeX = fourthTabIconFrame.origin.x + (fourthTabBarItem.frame.size.width / 2.0)
                
                // Set the frame for the custom view based on the fourth tab's icon frame
                customTabBarBadgeView.frame = CGRect(
                    x: badgeX,
                    y: fourthTabIconFrame.origin.y + (fourthTabBarItem.frame.size.height / 2.0) - 9,
                    width: batchSize,
                    height: batchSize
                )
                
                // Rest of your customization code
                customTabBarBadgeView.layer.cornerRadius = 9.0
                customTabBarBadgeView.borderWidth = 1.5
                customTabBarBadgeView.borderColor = self.selectedIndex == 4 ? UIColor.init(red: (58/255), green: (125/255), blue: (161/255), alpha: 1.0) : .white
                customTabBarBadgeView.backgroundColor = self.selectedIndex == 4 ? .white : .darkGray
                
                let xCoordinate = customTabBarBadgeView.frame.size.width / 2.0 - 5.5
                let yCoordinate = customTabBarBadgeView.frame.size.height / 2.0 - 5.5
                
                let imageView = UIImageView(frame: CGRect(x: xCoordinate, y: yCoordinate, width: 11, height: 11))
                imageView.image = UIImage(named: "menu")?.withRenderingMode(.alwaysTemplate)
                imageView.tintColor = self.selectedIndex == 4 ? UIColor.init(red: (58/255), green: (125/255), blue: (161/255), alpha: 1.0) : .white
                
                customTabBarBadgeView.addSubview(imageView)
                self.tabBar.addSubview(customTabBarBadgeView)
                self.tabBar.bringSubviewToFront(customTabBarBadgeView)
                customTabBarBadgeView.layer.zPosition = CGFloat(Float.greatestFiniteMagnitude)
            }
        }
    }
    
    func resizeImage(image: UIImage?, targetSize: CGSize) -> UIImage? {
        guard let image = image else { return nil }
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        let newImage = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
        return newImage
    }
    
    func makeRoundedImageWithBorder(image: UIImage?, borderWidth: CGFloat, borderColor: UIColor) -> UIImage? {
        guard let image = image else { return nil }
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = imageView.frame.size.width / 2
        imageView.layer.borderWidth = borderWidth
        imageView.layer.borderColor = borderColor.cgColor
        imageView.clipsToBounds = true
        let renderer = UIGraphicsImageRenderer(bounds: imageView.bounds)
        let roundedImage = renderer.image { context in
            imageView.layer.render(in: context.cgContext)
        }
        return roundedImage
    }
}

extension MyTabController:UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        guard let viewControllers = viewControllers else { return false }
        
        if self.isSameIndex {
            LogClass.debugLog("UIApplication.topViewController() ===>")
            LogClass.debugLog(UIApplication.topViewController())
            LogClass.debugLog((UIApplication.topViewController()!.isKind(of: FeedViewCollectionController.self)))
            
            if ((UIApplication.topViewController()?.isKind(of: FeedViewCollectionController.self)) != nil) {
                ((UIApplication.topViewController() as? FeedViewCollectionController)?.viewModel?.collectionView?.setContentOffset(.zero, animated: false))
                LogClass.debugLog("UIApplication.topViewController() ===> 1122")
                (UIApplication.topViewController() as? FeedViewCollectionController)?.reloadData()
            }
        }
        
        
//        if viewController == viewControllers[selectedIndex] {
//            
//            LogClass.debugLog("viewController ===>")
//            LogClass.debugLog(viewController)
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
        if let tabBarView = tabBarController.tabBar.subviews[5] as? UIView, tabBarView.tag == 999 {
            // Exclude the custom view from handling the tap
            return false
        }
        return true
    }
    
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController)   {
        addTabbarIndicatorView(index: self.selectedIndex)
        setProfileTabImage(self.selectedIndex == 4 ? UIColor.init(red: (58/255), green: (125/255), blue: (161/255), alpha: 1.0) : .darkGray)
        if self.isSameIndex {
            LogClass.debugLog("UIApplication.topViewController() ===>")
            LogClass.debugLog(UIApplication.topViewController())
            LogClass.debugLog((UIApplication.topViewController()?.isKind(of: FeedViewCollectionController.self)))
            
            if ((UIApplication.topViewController()?.isKind(of: FeedViewCollectionController.self)) != nil) {
                LogClass.debugLog("UIApplication.topViewController() ===> 1122")
                ((UIApplication.topViewController() as? FeedViewCollectionController)?.viewModel?.collectionView?.setContentOffset(.zero, animated: false))
                (UIApplication.topViewController() as? FeedViewCollectionController)?.reloadData()
            }
        }
//        if !self.isSameIndex {
//            let someController = SharedManager.shared.selectedTabController
//            if someController is UINavigationController {
//                let previousController = someController as! UINavigationController
//                if previousController.children.count > 0 {
//                    let someControl = previousController.children[0]
//                    if someControl is FeedViewController {
//                        let feed = someControl as! FeedViewController
//                        feed.resetAllActivities()
//                    }
//                }
//                SharedManager.shared.selectedTabController = viewController
//            } else {
//                let someController = SharedManager.shared.selectedTabController
//                if someController is FeedViewController {
//                    let feed = someController as! FeedViewController
//                    feed.resetAllActivities()
//                }
//                SharedManager.shared.selectedTabController = viewController
//            }
//        }
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        let currentIndex = tabBar.items?.firstIndex(of: item)
        self.isSameIndex = false
        if currentIndex == selectedIndex {
            self.isSameIndex = true
        }
        if currentIndex != 0{
                  NotificationCenter.default.post(name: .removeNewsFeedReactionObserver, object: nil)
              }
    }
}
