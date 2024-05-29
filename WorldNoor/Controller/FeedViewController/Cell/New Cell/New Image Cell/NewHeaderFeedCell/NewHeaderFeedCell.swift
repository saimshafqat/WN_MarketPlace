//
//  NewHeaderFeedCell.swift
//  WorldNoor
//
//  Created by apple on 8/13/21.
//  Copyright © 2021 Raza najam. All rights reserved.
//

import Foundation
import UIKit
import FittedSheets
import ActiveLabel

class NewHeaderFeedCell : UITableViewCell {
    
    var cellDelegate : CellDelegate!
    
    @IBOutlet var lblUserName : UILabel!
    @IBOutlet var lblDate : UILabel!
    @IBOutlet var imgViewUser : UIImageView!

    
    @IBOutlet var viewAddFriend : UIView!
    @IBOutlet var btnAddFriend : UIButton!
    @IBOutlet var viewCancelFriend : UIView!
    @IBOutlet var lblCancelFriend : UILabel!
    @IBOutlet var btnCancelFriend : UIButton!
    
    
    @IBOutlet var btnMore : UIButton!
    @IBOutlet var btnUserInfo : UIButton!
    
    var isFromProfile: Bool = false
    var feedObj : FeedData!
    var indexObjMain : IndexPath!
    
    var isFromWatch : Bool = false
    
    func reloadHeaderData() {
        
//        self.viewAddFriend.isHidden = true
//        self.viewCancelFriend.isHidden = true
        self.lblUserName.dynamicHeadlineSemiBold17()
        self.lblDate.dynamicCaption1Regular12()
        
        self.btnAddFriend.isHidden = true
        self.btnCancelFriend.isHidden = true
        self.viewCancelFriend.isHidden = true
        
//        self.viewAddFriend.isHidden = true
//        self.viewCancelFriend.isHidden = true

        if self.feedObj.authorID == SharedManager.shared.getUserID() {
            self.viewCancelFriend.isHidden = true
        } else if self.feedObj.isAuthorFriendOfViewer == "pending" {
            self.viewCancelFriend.isHidden = true
            self.viewCancelFriend.backgroundColor = UIColor.red
            self.btnCancelFriend.isHidden = false
            self.lblCancelFriend.text = "Cancel Request".localized()
        }else if self.feedObj.isAuthorFriendOfViewer == "friend_or_my_post" {
            self.viewCancelFriend.isHidden = true
        } else {
//        if self.feedObj.isAuthorFriendOfViewer == "friend_not_exist" {
            self.viewCancelFriend.isHidden = true
            self.lblCancelFriend.text = "Add Friend".localized()
            self.btnAddFriend.isHidden = false
            self.viewCancelFriend.backgroundColor = UIColor.init(named: "Blue Color")
        }
        
        self.labelRotateCell(viewMain: self.imgViewUser)
        self.labelRotateCell(viewMain: self.lblDate)
        self.labelRotateCell(viewMain: self.lblUserName)
        self.contentView.rotateViewForLanguage()
        if isFromWatch {
            self.contentView.rotateViewForLanguage()
        }

        if self.feedObj!.profileImage != nil {
            self.imgViewUser.loadImageWithPH(urlMain: self.feedObj!.profileImage!)
        }
        
        self.lblDate.text = self.feedObj.postedTime
        self.lblUserName.text = self.feedObj.authorName
        
        self.lblUserName.rotateForTextAligment()
        self.lblDate.rotateForTextAligment()
        self.lblCancelFriend.rotateViewForLanguage()
    }
    
    
    @IBAction func moreAction(sender : UIButton){
        
        let reportController = AppStoryboard.TabBar.instance.instantiateViewController(withIdentifier: "ReportingViewController") as! ReportingViewController
        
        
        reportController.currentIndex = self.indexObjMain
        reportController.feedObj = feedObj
                
   
        if let parentVC = (UIApplication.topViewController()! as? NewGroupDetailVC) {
            reportController.delegate = parentVC
            reportController.reportType = "Post"
//            parentVC.sheetController = SheetViewController(controller: reportController, sizes: [.fixed(350)])
            parentVC.sheetController = SheetViewController(controller: reportController, sizes: [.fullScreen])
            parentVC.sheetController.overlayColor = UIColor.black.withAlphaComponent(0.3)
            parentVC.sheetController.extendBackgroundBehindHandle = true
            parentVC.sheetController.topCornersRadius = 20
            parentVC.present(parentVC.sheetController, animated: false, completion: nil)
        }else if let parentVC = (UIApplication.topViewController()! as? SavedPostController1) {
            reportController.delegate = parentVC
            reportController.reportType = "Saved"
//            parentVC.sheetController = SheetViewController(controller: reportController, sizes: [.fixed(350)])
            parentVC.sheetController = SheetViewController(controller: reportController, sizes: [.fullScreen])
            parentVC.sheetController.overlayColor = UIColor.black.withAlphaComponent(0.3)
            parentVC.sheetController.extendBackgroundBehindHandle = true
            parentVC.sheetController.topCornersRadius = 20
            parentVC.present(parentVC.sheetController, animated: false, completion: nil)
            
        } else if let parentVC = (UIApplication.topViewController()! as? FeedViewController) {
            reportController.delegate = parentVC
            reportController.reportType = "Post"
            reportController.feedsDelegate = parentVC
//            parentVC.sheetController = SheetViewController(controller: reportController, sizes: [.fixed(350)])
            parentVC.sheetController = SheetViewController(controller: reportController, sizes: [.fullScreen])
            parentVC.sheetController.overlayColor = UIColor.black.withAlphaComponent(0.3)
            parentVC.sheetController.extendBackgroundBehindHandle = true
            parentVC.sheetController.topCornersRadius = 20
            parentVC.present(parentVC.sheetController, animated: false, completion: nil)
        }else if let parentVC = (UIApplication.topViewController()! as? NewPageDetailVC) {
            reportController.delegate = parentVC
            reportController.reportType = "Post"
            
//            parentVC.sheetController = SheetViewController(controller: reportController, sizes: [.fixed(350)])
            parentVC.sheetController = SheetViewController(controller: reportController, sizes: [.fullScreen])
            parentVC.sheetController.overlayColor = UIColor.black.withAlphaComponent(0.3)
            parentVC.sheetController.extendBackgroundBehindHandle = true
            parentVC.sheetController.topCornersRadius = 20
            parentVC.present(parentVC.sheetController, animated: false, completion: nil)
            
           
        } else if let parentVC = (UIApplication.topViewController()! as? HiddenFeedViewController) {
            reportController.delegate = parentVC
            reportController.reportType = "UnHidePost"
            
            parentVC.sheetController = SheetViewController(controller: reportController, sizes: [.fixed(350)])
            parentVC.sheetController.overlayColor = UIColor.black.withAlphaComponent(0.3)
            parentVC.sheetController.extendBackgroundBehindHandle = true
            parentVC.sheetController.topCornersRadius = 20
            parentVC.present(parentVC.sheetController, animated: false, completion: nil)
        }else if let parentVC = (UIApplication.topViewController()! as? ProfileViewController) {
            reportController.delegate = parentVC
            reportController.reportType = "Post"
            
//            parentVC.sheetController = SheetViewController(controller: reportController, sizes: [.fixed(350)])
            parentVC.sheetController = SheetViewController(controller: reportController, sizes: [.fullScreen])
            parentVC.sheetController.overlayColor = UIColor.black.withAlphaComponent(0.3)
            parentVC.sheetController.extendBackgroundBehindHandle = true
            parentVC.sheetController.topCornersRadius = 20
            parentVC.present(parentVC.sheetController, animated: false, completion: nil)
        }
    }
    
    @IBAction func userAction(sender : UIButton){
        if let userId = feedObj.authorID {
            let controller = ProfileViewController.instantiate(fromAppStoryboard: .PostStoryboard)
            if userId != SharedManager.shared.getUserID() && !isFromProfile {
                controller.otherUserID = String(userId)
                controller.otherUserisFriend = "1"
                controller.isNavPushAllow = true
                UIApplication.topViewController()?.navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
    
    @IBAction func showPageDetail(sender : UIButton){
        
        let groupObj = GroupValue.init()
        groupObj.slug = self.feedObj.page_slug!
        let pageView = AppStoryboard.Kids.instance.instantiateViewController(withIdentifier: "PagePostController") as! PagePostController
        pageView.groupObj = groupObj
        UIApplication.topViewController()!.navigationController?.pushViewController(pageView, animated: true)
    }
    
    @IBAction func showDetail(sender : UIButton) {
 
    }
    
    @IBAction func addFriendAction(sender : UIButton){
        self.sendRequest()
    }
    
    func sendRequest() {
//        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        let parameters = ["action": "user/send_friend_request","token": SharedManager.shared.userToken() , "user_id" : String(self.feedObj.authorID!)]
        
        RequestManager.fetchDataPost(Completion: { (response) in
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            switch response {
            case .failure(let error):

SwiftMessages.apiServiceError(error: error)            case .success(let res):
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                } else if let newRes = res as? [String:Any] {
                    self.feedObj.isAuthorFriendOfViewer = "pending"
                    self.reloadHeaderData()
                    
                    // update list
                    self.cellDelegate.reloadTableDataFriendShipStatus(feedObj: self.feedObj)
                    
                }else if let newRes = res as? String {
                    SharedManager.shared.showAlert(message: newRes, view: UIApplication.topViewController()!)
                }
            }
        }, param: parameters)
    }
    
    @IBAction func cancelFriendAction(sender : UIButton){
        
//        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        let parameters = ["action": "user/cancel_friend_request","token": SharedManager.shared.userToken() , "user_id" : String(self.feedObj.authorID!)]
        
        RequestManager.fetchDataPost(Completion: { (response) in
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            switch response {
            case .failure(let error):
SwiftMessages.apiServiceError(error: error)            case .success(let res):
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                } else if let newRes = res as? [String:Any] {
                    self.successOfCancelRequest()
                } else if let newRes = res as? String {
                    self.successOfCancelRequest()
                    SharedManager.shared.showAlert(message: newRes, view: UIApplication.topViewController()!)
                }
            }
        }, param: parameters)
    }
    
    func successOfCancelRequest(){
        feedObj.isAuthorFriendOfViewer = "friend_not_exist"
        reloadHeaderData()
        
        // update list
        self.cellDelegate.reloadTableDataFriendShipStatus(feedObj: self.feedObj)
    }
}
