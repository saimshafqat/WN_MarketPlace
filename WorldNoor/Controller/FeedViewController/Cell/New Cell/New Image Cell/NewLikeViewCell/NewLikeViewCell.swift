//
//  NewLikeViewCell.swift
//  WorldNoor
//
//  Created by apple on 11/15/21.
//  Copyright © 2021 Raza najam. All rights reserved.
//

import Foundation
import UIKit
import FittedSheets

class NewLikeViewCell : UITableViewCell {
    
    @IBOutlet var lblLike : UILabel!
    @IBOutlet var lblComment : UILabel!
    
    @IBOutlet var viewLike : UIView!
    @IBOutlet var viewComment : UIView!
    @IBOutlet var imgViewlike : UIImageView!
    @IBOutlet var imgViewlikeSecond : UIImageView!
    @IBOutlet var imgViewlikeFirst : UIImageView!
    
    @IBOutlet var lblLikeHeading : UILabel!
    @IBOutlet var lblCommentHeading : UILabel!
    @IBOutlet var lblShareHeading : UILabel!
    
    @IBOutlet var cstLeadinglbl : NSLayoutConstraint?
    @IBOutlet var btnLike : UIButton!
    @IBOutlet var btnComment : UIButton!
    @IBOutlet var btnShare : UIButton!
    
    var feedObj : FeedData!
    var indexPathMain : IndexPath!
    
    var isFromWatch : Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        addLongPressGesture()
    }
    
    func reloadData(feedObjP : FeedData) {
        
        self.lblLike.dynamicSubheadRegular15()
        self.lblComment.dynamicSubheadRegular15()
        self.lblLikeHeading.dynamicSubheadRegular15()
        self.lblCommentHeading.dynamicSubheadRegular15()
        self.lblShareHeading.dynamicSubheadRegular15()
        
        self.feedObj = feedObjP
        self.cstLeadinglbl?.constant = 5
        self.imgViewlike.image = UIImage.init(named: "NewIconLikeU")
        self.imgViewlikeFirst.image = UIImage.init(named: "NewIconLiked")
        self.imgViewlikeSecond.isHidden = true
        self.btnLike.isSelected = self.feedObj?.isLiked ?? false
        self.manageCount()
        
        
        if isFromWatch {
            self.contentView.rotateViewForLanguage()
        }
    }
    
    func manageCount() {
        if let likeCounter = self.feedObj?.likeCount {
            var counterValue = ""
            if likeCounter == 0 {
                counterValue = ""
            }else {
                counterValue = String(likeCounter)
            }
            self.lblLike.text = counterValue
        }
        
        if let commentCount = self.feedObj?.commentCount {
            var counterValue = ""
            if commentCount == 0 {
                counterValue = ""
            }else {
                counterValue = " "+String(commentCount)
            }
            self.lblComment.text = counterValue
        }
        
        self.lblLikeHeading.isHidden = false
        if self.feedObj.isReaction != nil {
            if self.feedObj.isReaction!.count > 0 {
                self.imgViewlike.image = UIImage.init(named: "Img" + self.feedObj.isReaction!+".png")
                self.lblLikeHeading.isHidden = true
            }
            
        }
        
        if self.feedObj.reationsTypesMobile != nil {
            if self.feedObj.reationsTypesMobile!.count >  1 {
                
                self.cstLeadinglbl?.constant = 20
            }
            
            if self.feedObj.reationsTypesMobile!.count > 0 {
                self.imgViewlikeFirst.image = UIImage.init(named: "Img" + String(self.feedObj.reationsTypesMobile![0].type!) + ".png")
                if self.feedObj.reationsTypesMobile!.count > 1 {
                    self.imgViewlikeSecond.image = UIImage.init(named: "Img" + String(self.feedObj.reationsTypesMobile![1].type!) + ".png")
                    self.imgViewlikeSecond.isHidden = false
                }
            }
        }
    }
    
    
    @IBAction func likeAction(sender : UIButton) {
        
        if self.feedObj.isReaction != nil {
            if self.feedObj.isReaction!.count > 0 {
                
                self.dislikeLike()
                
                return
            }
        }
        
        
        self.likePost()
        
        
    }
    
    func setTopLikeView(_ obj: FeedData) {
        imgViewlikeFirst.image = .newIconLikeU
        imgViewlikeSecond.isHidden = true
        cstLeadinglbl?.constant = 5
        if let reationsTypesMobile = obj.reationsTypesMobile, !reationsTypesMobile.isEmpty {
            if reationsTypesMobile.count > 1 {
                cstLeadinglbl?.constant = 20
            }
            if let firstReactionType = reationsTypesMobile.first?.type {
                imgViewlikeFirst.image = UIImage(named: "Img\(firstReactionType).png")
                if reationsTypesMobile.count > 1, let secondReactionType = reationsTypesMobile[1].type {
                    imgViewlikeSecond.image = UIImage(named: "Img\(secondReactionType).png")
                    imgViewlikeSecond.isHidden = false
                }
            }
        }
    }
    
    
    @objc func longPress(gesture: UILongPressGestureRecognizer) {
        
        if feedObj?.isReaction == nil || feedObj?.isReaction?.count == 0 {
            if gesture.state == UIGestureRecognizer.State.began {
                if let feedObj {
                    if let isReaction = feedObj.isReaction, isReaction.count > 0 {
                        return
                    }
                    if let viewReaction = loadNibView(.reactionView) as? ReactionView {
                        viewReaction.earlyUpdateReactionCompletion = {[weak self] reactionImg, index in
                            guard let self else { return }
                            feedObj.isReaction = SharedManager.shared.arrayGifType[index.row]
                            
                            var isFound = false
                            if feedObj.reationsTypesMobile != nil {
                                if feedObj.reationsTypesMobile?.count ?? 0 > 0  {
                                    for obj in 0..<(self.feedObj?.reationsTypesMobile?.count ?? 0) {
                                        if self.feedObj?.reationsTypesMobile?[obj].type == SharedManager.shared.arrayGifType[index.row] {
                                            isFound = true
                                            self.feedObj?.reationsTypesMobile![obj].count = (self.feedObj?.reationsTypesMobile![obj].count ?? 0) + 1
                                        }
                                    }
                                }
                            }
                            
                            if !isFound {
                                var newreaction = ReactionModel.init(countP: 1, typeP: SharedManager.shared.arrayGifType[index.row])
                                
                                if self.feedObj?.reationsTypesMobile != nil {
                                    self.feedObj?.reationsTypesMobile!.append(newreaction)
                                } else {
                                    self.feedObj?.reationsTypesMobile = [newreaction]
                                }
                            }
                            
                            if self.feedObj?.likeCount == nil {
                                self.feedObj?.likeCount = 1
                            } else {
                                self.feedObj?.likeCount! = 1 + (self.feedObj?.likeCount)!
                            }
                            let selfLiked = (self.feedObj?.likeCount! ?? 0) - 1
                            if self.feedObj?.likeCount ?? 0 == 1{
                                lblLike.text = "You"
                            }
                            else{
                                lblLike.text = "You and \(selfLiked) others"
                            }
                            self.lblLikeHeading.isHidden = true
                            imgViewlike.image = UIImage(named: "Img\(reactionImg).png")
                            
                            if feedObj.likeCount == 1 {
                                self.imgViewlikeFirst.image = UIImage(named: "Img\(reactionImg).png")
                            } else {
                                if self.imgViewlikeFirst.image == UIImage(named: "Img\(reactionImg)") {
                                    LogClass.debugLog("First Image already have")
                                } else if self.imgViewlikeSecond.image == UIImage(named: "Img\(reactionImg)") {
                                    LogClass.debugLog("Second Image already have")
                                    self.imgViewlikeSecond.isHidden = false
                                } else {
                                    self.imgViewlikeSecond.isHidden = false
                                    self.imgViewlikeSecond.image = UIImage(named: "Img\(reactionImg).png")
                                }
                            }
                            self.setTopLikeView(self.feedObj!)
                            SharedManager.shared.popover.dismiss()
                        }
                        viewReaction.feedObj = feedObj
                        let isScreenWidth = (UIScreen.main.bounds.size.width - 40) < 360
                        viewReaction.frame = CGRect(x: 0,
                                                    y: 0,
                                                    width: isScreenWidth ? (UIScreen.main.bounds.size.width - 40) : 360 ,
                                                    height: 40)
                        SharedManager.shared.popover = Popover(options: SharedManager.shared.popoverOptions)
                        SharedManager.shared.popover.show(viewReaction, fromView: btnLike)
                        viewReaction.delegateReaction = self
                    }
                }
            }
            
        }
        
    }
    
    func addLongPressGesture() {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPress(gesture:)))
        //        longPress.minimumPressDuration = 1.0
        self.btnLike.addGestureRecognizer(longPress)
    }
    
    
    func likePost() {
        
        if NetworkReachability.isConnectedToNetwork() {
            self.imgViewlike.image = UIImage(named: "Img\("like").png")
            self.imgViewlike.image = UIImage(named: "Img\("like").png")
        } else {
            SwiftMessages.showMessagePopup(theme: .error, title: "Failed", body: APIError.unreachable.localizedDescription)   
            btnLike.isUserInteractionEnabled = true
            return
        }
        
        btnLike.isEnabled = false
        let userToken = SharedManager.shared.userToken()
        
        let parameters = ["action": "react", "token": userToken,
                          "type": SharedManager.shared.arrayGifType[6],
                          "post_id":String(self.feedObj!.postID!)]
        DispatchQueue.global(qos: .userInitiated).async {
            RequestManager.fetchDataPost(Completion: { response in
                //                SharedManager.shared.hideLoadingHubFromKeyWindow()
                Loader.stopLoading()
                DispatchQueue.main.async {
                    switch response {
                    case .failure(let error):
                        self.btnLike.isEnabled = true
                        SwiftMessages.apiServiceError(error: error)
                    case .success(let res):
                        self.btnLike.isEnabled = true
                        LogClass.debugLog("res ===> success")
                        LogClass.debugLog(res)
                        if res is Int {
                            AppDelegate.shared().loadLoginScreen()
                        } else if res is String {
                            SwiftMessages.showMessagePopup(theme: .error, title: "Alert", body: res as? String ?? .emptyString)
                        } else {
                            
                            self.feedObj.isReaction = SharedManager.shared.arrayGifType[6]
                            
                            var isFound = false
                            
                            if self.feedObj.reationsTypesMobile != nil {
                                if self.feedObj.reationsTypesMobile!.count > 0  {
                                    for obj in 0..<self.feedObj.reationsTypesMobile!.count {
                                        if self.feedObj.reationsTypesMobile![obj].type == SharedManager.shared.arrayGifType[6] {
                                            isFound = true
                                            self.feedObj.reationsTypesMobile![obj].count! = self.feedObj.reationsTypesMobile![obj].count! + 1
                                        }
                                    }
                                }
                            }
                            
                            if !isFound {
                                var newreaction = ReactionModel.init(countP: 1,
                                                                     typeP: SharedManager.shared.arrayGifType[6])
                                
                                if self.feedObj.reationsTypesMobile != nil {
                                    self.feedObj.reationsTypesMobile!.append(newreaction)
                                } else {
                                    self.feedObj.reationsTypesMobile = [newreaction]
                                }
                            }
                            
                            if self.feedObj.likeCount == nil {
                                self.feedObj.likeCount = 1
                            } else {
                                self.feedObj.likeCount! = 1 + self.feedObj.likeCount!
                            }
                            
                            self.reloadData(feedObjP: self.feedObj)
                        }
                    }
                }
            }, param:parameters)
            
        }
    }
    
    func dislikeLike() {
        btnLike.isEnabled = false
        let userToken = SharedManager.shared.userToken()
        let parameters = ["action": "react", "token":userToken, "type": self.feedObj.isReaction! , "post_id": String(self.feedObj!.postID!)]
        DispatchQueue.global(qos: .userInitiated).async {
            RequestManager.fetchDataPost(Completion: { response in
                //                SharedManager.shared.hideLoadingHubFromKeyWindow()
                Loader.stopLoading()
                DispatchQueue.main.async {
                    switch response {
                    case .failure(let error):
                        self.btnLike.isEnabled = true
                        SwiftMessages.apiServiceError(error: error)
                    case .success(let res):
                        self.btnLike.isEnabled = true
                        if res is Int {
                            AppDelegate.shared().loadLoginScreen()
                        } else if res is String {
                            SharedManager.shared.showAlert(message: res as! String, view: UIApplication.topViewController()!)
                        } else {
                            if self.feedObj.reationsTypesMobile != nil {
                                if self.feedObj.reationsTypesMobile!.count > 0  {
                                    for obj in 0..<self.feedObj.reationsTypesMobile!.count {
                                        
                                        if self.feedObj.reationsTypesMobile![obj].type == self.feedObj.isReaction {
                                            //                                    isFound = true
                                            self.feedObj.reationsTypesMobile![obj].count! = self.feedObj.reationsTypesMobile![obj].count! - 1
                                            if self.feedObj.reationsTypesMobile![obj].count! == 0 {
                                                self.feedObj.reationsTypesMobile!.remove(at: obj)
                                            }
                                            break
                                        }
                                    }
                                }
                            }
                            
                            if self.feedObj.likeCount == nil {
                                self.feedObj.likeCount = 0
                            } else {
                                self.feedObj.likeCount =  self.feedObj.likeCount! - 1
                            }
                            self.feedObj.isReaction = ""
                            self.reloadData(feedObjP: self.feedObj)
                            
                        }
                    }
                    
                }
            }, param:parameters)
        }
    }
    
    @IBAction func shareAction(sender : UIButton){
        let shareController = AppStoryboard.TabBar.instance.instantiateViewController(withIdentifier: "SharePostController") as! SharePostController
        shareController.postID = String(feedObj.postID!)
        let navigationObj = UINavigationController.init(rootViewController: shareController)
        if let parentVC = UIApplication.topViewController() as? NewGroupDetailVC{
            parentVC.sheetController = SheetViewController(controller: navigationObj, sizes: [.fixed(550), .fullScreen])
            parentVC.sheetController.overlayColor = UIColor.black.withAlphaComponent(0.3)
            parentVC.sheetController.extendBackgroundBehindHandle = true
            parentVC.sheetController.topCornersRadius = 20
            SharedManager.shared.feedRef!.present(parentVC.sheetController, animated: true, completion: nil)
            
            
        }else  if let parentVC = UIApplication.topViewController() as? FeedViewController{
            parentVC.sheetController = SheetViewController(controller: navigationObj, sizes: [.fixed(550), .fullScreen])
            parentVC.sheetController.overlayColor = UIColor.black.withAlphaComponent(0.3)
            parentVC.sheetController.extendBackgroundBehindHandle = true
            parentVC.sheetController.topCornersRadius = 20
            SharedManager.shared.feedRef!.present(parentVC.sheetController, animated: true, completion: nil)
            
        }else  if let parentVC = UIApplication.topViewController() as? NewPageDetailVC{
            parentVC.sheetController = SheetViewController(controller: navigationObj, sizes: [.fixed(550), .fullScreen])
            parentVC.sheetController.overlayColor = UIColor.black.withAlphaComponent(0.3)
            parentVC.sheetController.extendBackgroundBehindHandle = true
            parentVC.sheetController.topCornersRadius = 20
            SharedManager.shared.feedRef!.present(parentVC.sheetController, animated: true, completion: nil)
        } else  if let parentVC = UIApplication.topViewController() as? HiddenFeedViewController {
            parentVC.sheetController = SheetViewController(controller: navigationObj, sizes: [.fixed(550), .fullScreen])
            parentVC.sheetController.overlayColor = UIColor.black.withAlphaComponent(0.3)
            parentVC.sheetController.extendBackgroundBehindHandle = true
            parentVC.sheetController.topCornersRadius = 20
            SharedManager.shared.feedRef!.present(parentVC.sheetController, animated: true, completion: nil)
        }else  if let parentVC = UIApplication.topViewController() as? ProfileViewController {
            parentVC.sheetController = SheetViewController(controller: navigationObj, sizes: [.fixed(550), .fullScreen])
            parentVC.sheetController.overlayColor = UIColor.black.withAlphaComponent(0.3)
            parentVC.sheetController.extendBackgroundBehindHandle = true
            parentVC.sheetController.topCornersRadius = 20
            SharedManager.shared.feedRef!.present(parentVC.sheetController, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func commentAction(sender : UIButton) {
        
        
        let feedController = FeedDetailController.instantiate(fromAppStoryboard: .PostDetail)
        
        feedController.feedObj = self.feedObj
        feedController.feedArray = [self.feedObj]
        feedController.indexPath = IndexPath.init(row: 0, section: 0)
        
        
        //        if  (UIApplication.topViewController()?.isKind(of: UISearchController.self) ?? false) { // for search
        //            UIApplication.topViewController()!.modalPresentationStyle = .fullScreen
        //        } else {
        //            UIApplication.topViewController()!.modalPresentationStyle = .overFullScreen
        //        }
        
        //        UIApplication.topViewController()!.present(feedController, animated: true)
        UIApplication.topViewController()!.navigationController?.pushViewController(feedController, animated: true)
        //        let feedController = AppStoryboard.TabBar.instance.instantiateViewController(withIdentifier: "FeedNewDetailController") as! FeedNewDetailController
        //        feedController.feedObj = self.feedObj
        //        feedController.feedArray = [self.feedObj]
        //        feedController.indexPath = IndexPath.init(row: 0, section: 0)
        //
        //
        //        if  (UIApplication.topViewController()?.isKind(of: UISearchController.self) ?? false) { // for search
        //            UIApplication.topViewController()!.modalPresentationStyle = .fullScreen
        //        } else {
        //            UIApplication.topViewController()!.modalPresentationStyle = .overFullScreen
        //        }
        //
        //        UIApplication.topViewController()!.present(feedController, animated: true)
    }
    
    
    @IBAction func showLikeSheetAction(sender : UIButton){
        let feedObj = self.feedObj
        let pagerController = AppStoryboard.TabBar.instance.instantiateViewController(withIdentifier: "WNPagerViewController") as! WNPagerViewController
        pagerController.feedObj = feedObj
        pagerController.parentView = UIApplication.topViewController()
        
        if let parentVC = (UIApplication.topViewController()! as? NewGroupDetailVC) {
            parentVC.sheetController = SheetViewController(controller: pagerController, sizes: [.fixed(400), .fixed(250), .fullScreen])
            parentVC.sheetController.overlayColor = UIColor.black.withAlphaComponent(0.3)
            parentVC.sheetController.extendBackgroundBehindHandle = true
            parentVC.sheetController.topCornersRadius = 20
            parentVC.present(parentVC.sheetController, animated: false, completion: nil)
        } else if let parentVC = (UIApplication.topViewController()! as? FeedViewController) {
            parentVC.sheetController = SheetViewController(controller: pagerController, sizes: [.fixed(400), .fixed(250), .fullScreen])
            parentVC.sheetController.overlayColor = UIColor.black.withAlphaComponent(0.3)
            parentVC.sheetController.extendBackgroundBehindHandle = true
            parentVC.sheetController.topCornersRadius = 20
            parentVC.present(parentVC.sheetController, animated: false, completion: nil)
        }else if let parentVC = (UIApplication.topViewController()! as? NewPageDetailVC) {
            parentVC.sheetController = SheetViewController(controller: pagerController, sizes: [.fixed(400), .fixed(250), .fullScreen])
            parentVC.sheetController.overlayColor = UIColor.black.withAlphaComponent(0.3)
            parentVC.sheetController.extendBackgroundBehindHandle = true
            parentVC.sheetController.topCornersRadius = 20
            parentVC.present(parentVC.sheetController, animated: false, completion: nil)
        } else if let parentVC = (UIApplication.topViewController()! as? HiddenFeedViewController) {
            parentVC.sheetController = SheetViewController(controller: pagerController, sizes: [.fixed(400), .fixed(250), .fullScreen])
            parentVC.sheetController.overlayColor = UIColor.black.withAlphaComponent(0.3)
            parentVC.sheetController.extendBackgroundBehindHandle = true
            parentVC.sheetController.topCornersRadius = 20
            parentVC.present(parentVC.sheetController, animated: false, completion: nil)
        }else if let parentVC = (UIApplication.topViewController()! as? ProfileViewController) {
            parentVC.sheetController = SheetViewController(controller: pagerController, sizes: [.fixed(400), .fixed(250), .fullScreen])
            parentVC.sheetController.overlayColor = UIColor.black.withAlphaComponent(0.3)
            parentVC.sheetController.extendBackgroundBehindHandle = true
            parentVC.sheetController.topCornersRadius = 20
            parentVC.present(parentVC.sheetController, animated: false, completion: nil)
        }
    }
}




extension NewLikeViewCell : ReactionDelegateResponse {
    
    func reactionResponse(feedObj:FeedData){
        self.reloadData(feedObjP: feedObj)
        SharedManager.shared.popover.dismiss()
    }
}
