
//
//  CallMinimiser.swift
//  kalam
//
//  Created by apple on 3/16/20.
//  Copyright © 2020 apple. All rights reserved.
//

import Foundation
import UIKit
import SwiftEntryKit
import SDWebImage

class CallMinimiser: NSObject {
    
    static let sharedInstance = CallMinimiser()
    var newView:UIView?
    var labelTap:UITapGestureRecognizer?
    var labelTimer:UILabel?
    var isCallminimised = false
    
    @objc func labelTapped(_ sender: UITapGestureRecognizer) {
        RoomClient.sharedInstance.maximiseCall()
    }
    func hideCallBar()  {
        newView?.removeFromSuperview()
        isCallminimised = false
        
    }
    
    func updateTimerLabeltext(time:String){
        labelTimer?.text = time
    }
    @IBAction func panView(_ sender: UIPanGestureRecognizer) {
        guard let viewToDrag = sender.view else {
            return
        }

        let translation = sender.translation(in: viewToDrag)

        // Update the view's center for both x and y coordinates
        var updatedCenter = CGPoint(x: viewToDrag.center.x + translation.x,
                                    y: viewToDrag.center.y + translation.y)

        // Ensure the updated position is within the lower half of the screen
        let minY = UIScreen.main.bounds.height / 2
        let maxY = UIScreen.main.bounds.height - viewToDrag.bounds.height / 2

        updatedCenter.y = max(minY, min(updatedCenter.y, maxY))

        // Ensure the updated position is within the screen bounds horizontally
        let minX = viewToDrag.bounds.width / 2
        let maxX = UIScreen.main.bounds.width - viewToDrag.bounds.width / 2

        updatedCenter.x = max(minX, min(updatedCenter.x, maxX))

        // Update the view's center
        viewToDrag.center = updatedCenter

        // Reset the translation to zero for the next pan gesture
        sender.setTranslation(CGPoint.zero, in: viewToDrag)
    }
    func showCallBar(name:String) {
        
        let app = UIApplication.shared
        let statusbarheight = app.statusBarFrame.size.height
        
        
        if let tabController = appDelegate.window?.rootViewController as? UITabBarController {
            
            LogClass.debugLog(tabController)
            if let navController = tabController.selectedViewController as? UINavigationController {
                LogClass.debugLog(navController)
                
                let rootViewController = navController.viewControllers.first
                
                LogClass.debugLog(rootViewController as Any)
                let navbarheight = rootViewController?.navbarheight ?? 44
                LogClass.debugLog("navbarheight size \(navbarheight)")
                LogClass.debugLog("y_pos \(statusbarheight)")
                newView = UIView()
                //                newView?.frame = CGRect(x:0,y:statusbarheight+44, width: ScreenSizeUtil.width(), height: 30)
                newView?.frame = CGRect(x:ScreenSizeUtil.width()-100,y:ScreenSizeUtil.height()-400, width: 100, height: 100)
                newView?.backgroundColor = UIColor(displayP3Red: 27.0/255.0, green: 191.0/255.0, blue: 122.0/255.0, alpha: 1.0)
                
                newView?.circularView()
                
                var userimageView : UIImageView
                userimageView  = UIImageView(frame:CGRect(x: 0, y: 0, width: 100, height: 100));
                if RoomClient.sharedInstance.connectedUserPhoto != "" {
                    userimageView.setImage(url: RoomClient.sharedInstance.connectedUserPhoto)
                }else{
                    userimageView.image = UIImage(named: "avatar")
                }
                userimageView.circularView()
//                userimageView.image = userimageView.image?.withAlpha(0.8)
                newView?.addSubview(userimageView)
                
                var imageView : UIImageView
                imageView  = UIImageView(image: UIImage(named:"audio-call"))
                imageView.center = CGPoint(x: (newView?.bounds.height)! / 2, y: (newView?.bounds.width)! / 2)
                newView?.addSubview(imageView)
                newView?.bringSubviewToFront(imageView)
                
                let label = UILabel()
                label.frame = CGRect(x:imageView.frame.maxX+5,y:0, width: 100, height: 20)
                label.textAlignment = .left
                label.textColor = .white
                label.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
                label.text = "Return to call"
                let labelTap = UITapGestureRecognizer(target: self, action: #selector(self.labelTapped(_:)))
                label.isUserInteractionEnabled = true
                
                let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panView(_:)))
                newView?.addGestureRecognizer(panGestureRecognizer)
                newView?.isUserInteractionEnabled = true
                
                labelTimer = UILabel()
                labelTimer?.frame = CGRect(x:label.frame.maxX+10,y:0, width: 100, height: 30)
                labelTimer?.textAlignment = .left
                labelTimer?.textColor = .white
                labelTimer?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
                labelTimer?.text = "00:00"
                labelTimer?.isUserInteractionEnabled = true
                let namelabel = UILabel()
                if(SharedManager.shared.isiPadDevice){
                    namelabel.frame = CGRect(x:(newView?.frame.size.width ?? ScreenSizeUtil.width()) - 250 ,y:0, width: 245, height: 30)
                }else{
                    namelabel.frame = CGRect(x:(newView?.frame.size.width ?? ScreenSizeUtil.width()) - 150 ,y:0, width: 145, height: 30)
                }
                
                namelabel.textAlignment = .right
                namelabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
                namelabel.textColor = .white
                namelabel.text = name
                newView?.addGestureRecognizer(labelTap)
                imageView.autoresizingMask = [.flexibleTopMargin,.flexibleRightMargin, .flexibleBottomMargin]
                label.autoresizingMask = [.flexibleTopMargin,.flexibleRightMargin, .flexibleBottomMargin]
                labelTimer?.autoresizingMask = [.flexibleRightMargin, .flexibleLeftMargin]
                namelabel.autoresizingMask = [.flexibleTopMargin,.flexibleLeftMargin, .flexibleBottomMargin]
                
                UIApplication.shared.windows.first(where: {$0.isKeyWindow})?.addSubview(newView!)
                isCallminimised = true
            }
            
        }
    }
    
}


extension UIApplication {
    var statusBarUIView: UIView? {
        if #available(iOS 13.0, *) {
            let tag = 38482458385
            if let statusBar = self.keyWindow?.viewWithTag(tag) {
                return statusBar
            } else {
                let statusBarView = UIView(frame: UIApplication.shared.statusBarFrame)
                statusBarView.tag = tag
                
                self.keyWindow?.addSubview(statusBarView)
                return statusBarView
            }
        } else {
            if responds(to: Selector(("statusBar"))) {
                return value(forKey: "statusBar") as? UIView
            }
        }
        return nil
    }
    
}
