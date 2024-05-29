//
//  AppDelegate.swift
//  WorldNoor
//
//  Created by Raza najam on 9/3/19.
//  Copyright © 2019 Raza najam. All rights reserved.
//

import Foundation
import  UIKit

final class AppAppearance {
    
    static func setupAppearance() {
        //   UINavigationBar.appearance().barTintColor = .black
        //   UINavigationBar.appearance().tintColor = .white
        //   UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        //   UITabBar.appearance().tintColor = .white
        //   UITabBar.appearance().barTintColor = .white
    }
}

extension UINavigationController {
 
    
    
      func popToVC(ofClass: AnyClass, animated: Bool = true) {
        if let vc = viewControllers.last(where: { $0.isKind(of: ofClass) }) {
          popToViewController(vc, animated: animated)
        }
      }
    
    
    func addTitle(_ target: UIViewController, title : String , selector: Selector) {
        
        
        let viewMain = UIView.init(frame: CGRect(x: 0, y: 0, width: 150.0, height: 45.0))
        viewMain.backgroundColor = UIColor.clear
        
        
        let titleLabel = UILabel.init(frame: CGRect(x: 0, y: 0, width: 150, height: 30.0))
        titleLabel.text = title;
        titleLabel.textColor = UIColor.black
        titleLabel.backgroundColor = UIColor.clear
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: (UIScreen.main.bounds.height / 568) * 12)
        
        let button = UIButton.init(frame: viewMain.frame)
        button.addTarget(target, action: selector, for: UIControl.Event.touchUpInside)
        viewMain.addSubview(titleLabel)
        viewMain.addSubview(button)
        target.navigationItem.titleView = viewMain
    }
    
    func addChatTitle(to target: UIViewController, title: String, userImage: String?, selector: Selector) {
        let viewMain = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width * 0.7, height: 45))
        viewMain.backgroundColor = .clear
        
        if let userImage = userImage {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFill
            imageView.frame = CGRect(x: 0, y: 3, width: 36, height: 36)
            imageView.roundTotally()
            viewMain.addSubview(imageView)
            
            imageView.loadImageWithPH(urlMain:userImage)
        }
        
        let titleLabel = UILabel(frame: CGRect(x: userImage != nil ? 46 : 0, y: 6, width: viewMain.frame.width - 50, height: 30))
        titleLabel.text = title
        titleLabel.textColor = .black
        titleLabel.backgroundColor = .clear
        titleLabel.textAlignment = .left
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        viewMain.addSubview(titleLabel)
        
        let button = UIButton(frame: viewMain.bounds)
        button.addTarget(target, action: selector, for: .touchUpInside)
        viewMain.addSubview(button)
        
        target.navigationItem.titleView = viewMain
    }
    
    
    func removeRighttButton(_ target: UIViewController) {
        let viewMain = UIView.init(frame: CGRect(x: 0, y: 0, width: 0.0, height: 0.0))
        viewMain.backgroundColor = UIColor.clear
        let barButtonItem = UIBarButtonItem.init(customView: viewMain)
        target.navigationItem.setRightBarButton(barButtonItem, animated: true)
    }
    
    func removeLefttButton(_ target: UIViewController) {
        let viewMain = UIView.init(frame: CGRect(x: 0, y: 0, width: 0.0, height: 0.0))
        viewMain.backgroundColor = UIColor.clear
        let barButtonItem = UIBarButtonItem.init(customView: viewMain)
        target.navigationItem.setLeftBarButton(barButtonItem, animated: true)
    }
    
    
    func addRightButtonWithTitle(_ target: UIViewController, selector: Selector , lblText : String ,widthValue : Double ) {
        
        
        let viewMain  = UIView.init(frame: CGRect(x: 0, y: 0, width: widthValue, height: 30.0))
        viewMain.backgroundColor = UIColor.clear
        
        let viewBg  = UIView.init(frame: CGRect(x: 0, y: 29, width: lblText.widthOfString() - 5, height: 1.0))
        viewBg.backgroundColor = UIColor.clear
        
        viewBg.center = CGPoint.init(x:viewMain.center.x , y: viewBg.center.y)
        
        let lblMain = UILabel.init(frame: CGRect(x: 0, y: 5, width: widthValue, height: 20.0))
        lblMain.textColor = UIColor.black
        lblMain.text = lblText
        lblMain.textAlignment = .center
        lblMain.font = UIFont.systemFont(ofSize: (UIScreen.main.bounds.height / 568) * 10.0)
        
        let button = UIButton.init(frame: CGRect(x: 0, y: 0, width: widthValue, height: 30.0))
        button.addTarget(target, action: selector, for: UIControl.Event.touchUpInside)
        button.backgroundColor = UIColor.clear
        
        viewMain.addSubview(lblMain)
        viewMain.addSubview(button)
        viewMain.addSubview(viewBg)
        
        let barButtonItem = UIBarButtonItem.init(customView: viewMain)
        target.navigationItem.setRightBarButton(barButtonItem, animated: true)
    }
    
    func addLeftButtonWithTitle(_ target: UIViewController, selector: Selector , lblText : String ,widthValue : Double ) {
        
        let viewMain  = UIView.init(frame: CGRect(x: 0, y: 0, width: widthValue, height: 30.0))
        viewMain.backgroundColor = UIColor.clear
        
        let viewBg  = UIView.init(frame: CGRect(x: 0, y: 29, width: lblText.widthOfString() - 5, height: 1.0))
        viewBg.backgroundColor = UIColor.clear
        
        viewBg.center = CGPoint.init(x:viewMain.center.x , y: viewBg.center.y)
        
        let lblMain = UILabel.init(frame: CGRect(x: 0, y: 5, width: widthValue, height: 20.0))
        lblMain.textColor = UIColor.black
        lblMain.text = lblText
        lblMain.textAlignment = .center
        //            lblMain.font = UIFont.init(name: "OpenSans-Regular", size: (UIScreen.main.bounds.height / 568) * 10.0)
        lblMain.font = UIFont.systemFont(ofSize: (UIScreen.main.bounds.height / 568) * 10.0)
        
        let button = UIButton.init(frame: CGRect(x: 0, y: 0, width: widthValue, height: 30.0))
        button.addTarget(target, action: selector, for: UIControl.Event.touchUpInside)
        button.backgroundColor = UIColor.clear
        
        viewMain.addSubview(lblMain)
        viewMain.addSubview(button)
        viewMain.addSubview(viewBg)
        
        let barButtonItem = UIBarButtonItem.init(customView: viewMain)
        target.navigationItem.setLeftBarButton(barButtonItem, animated: true)
    }
    
    func addRightButton(_ target: UIViewController, selector: Selector , image : UIImage) {

        let viewMain = UIView.init(frame: CGRect(x: 0, y: 0, width: 45.0, height: 35.0))
        viewMain.backgroundColor = UIColor.clear
        
        let imgViewMain = UIImageView.init(frame: CGRect(x: 25, y: 8, width: 20.0, height: 20.0))
        imgViewMain.image = image
        imgViewMain.contentMode = .scaleAspectFit
        imgViewMain.backgroundColor = UIColor.clear
        
        
        let button = UIButton.init(frame: CGRect(x: 0, y: 0, width: viewMain.frame.size.width, height: viewMain.frame.size.height))
        button.addTarget(target, action: selector, for: UIControl.Event.touchUpInside)
        
        viewMain.addSubview(imgViewMain)
        viewMain.addSubview(button)
        let barButtonItem = UIBarButtonItem.init(customView: viewMain)
        target.navigationItem.setRightBarButton(barButtonItem, animated: true)
    }
    
}
