//
//  PageBaseNameCell.swift
//  WorldNoor
//
//  Created by Waseem Shah on 27/03/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//


import Foundation
import UIKit

class PageBaseNameCell : UICollectionViewCell {
    
    @IBOutlet var lblName : UILabel!
    @IBOutlet var lblLikes : UILabel!
    @IBOutlet var lblLikeText : UILabel!
    @IBOutlet var viewLikeText : UIView!
    @IBOutlet var imgViewLikeText : UIImageView!
    
    var delegate: ProfileTabSelectionDelegate?
    
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
        
        self.updateLikeView()
        self.delegate?.profileTabSelection(tabValue: 102)
        
        var parameters = ["token": SharedManager.shared.userToken()]
        parameters["page_id"] = self.groupObj.groupID
        parameters["action"] = self.groupObj.isLike ? "page/likes/like_page" : "page/likes/unlike_page"
            
        
        RequestManager.fetchDataPost(Completion: { response in
            
            switch response {
            case .failure(let error):
                if error is String {
                }
            case .success(let res):
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                } else if res is String {
//                    self.updateLikeView()
//                    self.delegate?.profileTabSelection(tabValue: 102)
                } else {
//                    self.updateLikeView()
//                    self.delegate?.profileTabSelection(tabValue: 102)
                }
                
                
            }
        }, param:parameters)
    }
    
    func updateCatePageLike(_ item: CategoryLikePageModel) {
        categoryLikePageItem = item
    }
    

    
    func updateLikeView() {
        if let liketotal = Int(self.groupObj.totalLikes) {
            self.groupObj.totalLikes = String(self.groupObj.isLike ? max(0, liketotal - 1) : liketotal + 1)
        }
        self.groupObj.isLike = !self.groupObj.isLike
        self.reloadName()
        if !(self.groupObj.isLike) {
            NotificationCenter.default.post(name: .CategoryLikePages, object: self.categoryLikePageItem)
        }
    }
}

