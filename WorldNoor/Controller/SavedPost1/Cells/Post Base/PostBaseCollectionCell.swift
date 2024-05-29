//
//  PostBaseCollectionCell.swift
//  WorldNoor
//
//  Created by Muhammad Asher on 11/05/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit

protocol PostBaseCellDelegate: PostHeaderInfoDelegate, PostSharingDelegate {
    // using header info delegate methods
}

@objc(PostBaseCollectionCell)
class PostBaseCollectionCell: ConfigableCollectionCell {
    
    // MARK: - IBOutlets -
    @IBOutlet weak var peopleDetailView: PostHeaderInfoView?
    @IBOutlet weak var postSharingView: PostSharingView?
    @IBOutlet weak var postSharingViewHeightConstraint: NSLayoutConstraint?
    @IBOutlet weak var postSharingMemoriesView: PostSharingMemoriesView?
    
    // MARK: - Properties -
    var postBaseCellDelegate: PostBaseCellDelegate?
    var indexPath: IndexPath?
    public var postObj: FeedData?
    public var parentObj: FeedData?
    
    // MARK: - Configure Cell
    override func displayCellContent(data: AnyObject?, parentData: AnyObject?, at indexPath: IndexPath) {
        let obj = data as? FeedData
        let parentObject = (parentData as? FeedData)
        self.indexPath = indexPath
        self.postObj = obj
        self.parentObj = parentObject

        peopleDetailView?.displayViewContent(obj, parentData: parentObject, at: indexPath)
        peopleDetailView?.postHeaderInfoDelegate = self
        if parentObject?.username == SharedManager.shared.userObj?.data.username{
            peopleDetailView?.addFriendImage?.isHidden = true
            peopleDetailView?.frienRequestButton?.isHidden = true
        }
        if postSharingView != nil {
            postSharingView?.displayViewContent(obj, at: indexPath)
           // setSharingViewConstraint(obj)
            postSharingView?.postSharingDelegate = self
        }
        
         if postSharingMemoriesView != nil {
             postSharingMemoriesView?.displayViewContent(obj, at: indexPath)
             postSharingMemoriesView?.postSharingDelegate = self
         }
        // override me
    }
    
//    func setSharingViewConstraint(_ obj: FeedData?) {
//        let hasComment = (obj?.commentCount ?? 0 > 0)
//        let hasLike = (obj?.reationsTypesMobile?.count ?? 0 > 0)
//        let hasNoLikeAndComment = !(hasComment) && !(hasLike)
//        postSharingViewHeightConstraint?.constant = hasNoLikeAndComment ? 30 : 100
//    }
}

// MARK: - PostHeaderDelegate
extension PostBaseCollectionCell: PostHeaderInfoDelegate {
    func speechFinished(with feedData: FeedData, at indexPath: IndexPath) {
        postBaseCellDelegate?.speechFinished(with: feedData, at: indexPath)
    }
    
    func tappedMore(with feedData: FeedData, at indexPath: IndexPath) {
        postBaseCellDelegate?.tappedMore(with: feedData, at: indexPath)
    }
    func tappedSeeMore(with feedData: FeedData, at indexPath: IndexPath) {
        postBaseCellDelegate?.tappedSeeMore(with: feedData, at: indexPath)
    }
    func tappedTranslation(with feedData: FeedData, at indexPath: IndexPath) {
        postBaseCellDelegate?.tappedTranslation(with: feedData, at: indexPath)
    }
    func tappedUserInfo(with feedData: FeedData, at indexPath: IndexPath) {
        postBaseCellDelegate?.tappedUserInfo(with: feedData, at: indexPath)
    }
    
    func tappedShowPostDetail(with feedData: FeedData, at indexPath: IndexPath) {
        postBaseCellDelegate?.tappedShowPostDetail(with: feedData, at: indexPath)
    }
    
    func tappedHide(with feedData: FeedData, at indexPath: IndexPath) {
        postBaseCellDelegate?.tappedHide(with: feedData, at: indexPath)
    }
    func tappedHashTag(with hashTag: String, at indexPath: IndexPath) {
        postBaseCellDelegate?.tappedHashTag(with: hashTag, at: indexPath)
    }
}

// MARK: - PostSharingDelegate
extension PostBaseCollectionCell: PostSharingDelegate {
    func tappedShare(with feedData: FeedData, at indexPath: IndexPath) {
        postBaseCellDelegate?.tappedShare(with: feedData, at: indexPath)
    }
    
    func tappedComment(with feedData: FeedData, at indexPath: IndexPath) {
        postBaseCellDelegate?.tappedComment(with: feedData, at: indexPath)
    }
    
    func tappedLiked(with feedData: FeedData, at indexPath: IndexPath) {
        postBaseCellDelegate?.tappedLiked(with: feedData, at: indexPath)
    }
    
    func tappedLikesDetail(with feedData: FeedData, at indexPath: IndexPath) {
        postBaseCellDelegate?.tappedLikesDetail(with: feedData, at: indexPath)
    }
    
    func tappedKalamSend(with feedData: FeedData, at indexPath: IndexPath) {
        postBaseCellDelegate?.tappedKalamSend(with: feedData, at: indexPath)
    }
}
