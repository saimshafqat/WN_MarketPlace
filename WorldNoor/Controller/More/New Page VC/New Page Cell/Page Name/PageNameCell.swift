//
//  PageNameCell.swift
//  WorldNoor
//
//  Created by apple on 10/20/21.
//  Copyright © 2021 Raza najam. All rights reserved.
//

import Foundation
import UIKit

class PageNameVC : UITableViewCell {
    
    @IBOutlet var lblName : UILabel!
    @IBOutlet var lblLikes : UILabel!
    @IBOutlet var lblLikeText : UILabel!
    @IBOutlet var viewLikeText : UIView!
    @IBOutlet var imgViewLikeText : UIImageView!
    
    var groupObj: GroupValue!
    var categoryLikePageItem: CategoryLikePageModel?
    var isDisLikePage: Bool = false
    
    func reloadName() {
        self.lblName.text = !(groupObj.name.isEmpty) ? groupObj.name : groupObj.groupName
        self.lblLikes.text = self.groupObj.totalLikes
        viewLikeText.backgroundColor = groupObj.isLike ? .gray : .blueColor
        lblLikeText.text = "\(groupObj.isLike ? "Unlike" : "Like") Page"
        imgViewLikeText.image = groupObj.isLike ? .likeFilledWhite : .likeWhite
    }
    
    @IBAction func likeAction(sender : UIButton) {
        
        var parameters = ["token": SharedManager.shared.userToken()]
        parameters["page_id"] = self.groupObj.groupID
        
        if self.groupObj.isLike {
            parameters["action"] = "page/likes/unlike_page"
            
        } else {
            parameters["action"] = "page/likes/like_page"
        }
        
        RequestManager.fetchDataPost(Completion: { response in
            
            switch response {
            case .failure(let error):
                if error is String {
                }
            case .success(let res):
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                } else if res is String {
                    //  SharedManager.shared.showAlert(message: res as! String, view: self)
                    self.updateLikeView()
                } else {
                    self.updateLikeView()
                }
            }
        }, param:parameters)
    }
    
    func updateCatePageLike(_ item: CategoryLikePageModel) {
        categoryLikePageItem = item
    }
    
//    func updateLikeView() {
//        if self.groupObj.isLike {
//            if let liketotal = Int(self.groupObj.totalLikes) {
//                if (liketotal - 1) < 0 {
//                    self.groupObj.totalLikes = "0"
//                } else {
//                    self.groupObj.totalLikes = String(liketotal - 1)
//                }
//            }
//        } else {
//            if let liketotal = Int(self.groupObj.totalLikes) {
//                self.groupObj.totalLikes = String(liketotal + 1)
//            }
//        }
//        self.groupObj.isLike = !self.groupObj.isLike
//        self.reloadName()
//    }
    
    func updateLikeView() {
        if let liketotal = Int(self.groupObj.totalLikes) {
            self.groupObj.totalLikes = String(self.groupObj.isLike ? max(0, liketotal - 1) : liketotal + 1)
        }
        self.groupObj.isLike = !self.groupObj.isLike
        self.reloadName()
        LogClass.debugLog("Deleted Item ==> One")
        if !(self.groupObj.isLike) {
            NotificationCenter.default.post(name: .CategoryLikePages, object: self.categoryLikePageItem)
        }
    }
}
