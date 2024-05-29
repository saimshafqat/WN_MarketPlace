//
//  PostSharingMemoriesView.swift
//  WorldNoor
//
//  Created by Waseem Shah on 13/11/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import Foundation
import UIKit
import FittedSheets



class PostSharingMemoriesView: UIView {
    
    // MARK: - IBOutlets -
    @IBOutlet var contentView: UIView!
    
//    @IBOutlet var shareView: UIView!
//    @IBOutlet var likeLabel : UILabel!
//    @IBOutlet var commentLabel : UILabel!
    
//    @IBOutlet var likeView : UIView!
//    @IBOutlet var commentView : UIView!
//    @IBOutlet var likeImageView : UIImageView!
//    @IBOutlet var firstLikeImageView : UIImageView!
//    @IBOutlet var secondLikeImageView : UIImageView!
    
//    @IBOutlet var likeHeadingLabel : UILabel!
//    @IBOutlet var commentHeadingLabel : UILabel!
//    @IBOutlet var shareHeadingLabel : UILabel!
    
//    @IBOutlet var cstLeadinglbl : NSLayoutConstraint?
//    @IBOutlet var likeButton : UIButton!
//    @IBOutlet var commentButton : UIButton!
//    @IBOutlet var shareButton : UIButton!
    
    // MARK: - Properties -
    var postSharingDelegate: PostSharingDelegate?
    var indexPath: IndexPath?
    public var postObj: FeedData?
//    private var viewModel = PostSharingViewViewModel()
//    var isFromWatch : Bool = false
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: UIScreen.main.bounds)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    // MARK: - IBActions
    @IBAction func onClickShare(_ sender: UIButton) {
        if let indexPath, let postObj {
            postSharingDelegate?.tappedShare(with: postObj, at: indexPath)
        }
    }
    
//    @IBAction func onClickComment(_ sender: UIButton) {
//        if let indexPath, let postObj {
//            postSharingDelegate?.tappedComment(with: postObj, at: indexPath)
//        }
//    }
    
//    @IBAction func onClickLike(_ sender: UIButton) {
//        if let postObj {
//            if let isReaction = postObj.isReaction, isReaction.count > 0 {
//                setDislike(obj: postObj, indexPath: indexPath)
//                return
//            }
//            if let viewReaction = loadNibView(.reactionView) as? ReactionView {
//                viewReaction.feedObj = postObj
//                let isScreenWidth = (UIScreen.main.bounds.size.width - 40) < 360
//                viewReaction.frame = CGRect(x: 0,
//                                            y: 0,
//                                            width: isScreenWidth ? (UIScreen.main.bounds.size.width - 40) : 360 ,
//                                            height: 30)
//                SharedManager.shared.popover = Popover(options: SharedManager.shared.popoverOptions)
//                SharedManager.shared.popover.show(viewReaction, fromView: likeButton)
//                viewReaction.delegateReaction = self
//            }
//        }
//    }
    @IBAction func onClickLikeDetail(_ sender: UIButton) {
        if let postObj, let indexPath {
            postSharingDelegate?.tappedLikesDetail(with: postObj, at: indexPath)
        }
    }
    
    // MARK: - Method
    private func commonInit() {
        _ = loadNibView(.PostSharingMemoriesView)
        addSubview(contentView)
        contentView.setConstraintWithBoundary(self)
    }
    
    // main method
    public func displayViewContent(_ obj: FeedData? ,at indexPath: IndexPath) {
        postObj = obj
        self.indexPath = indexPath
        if let obj {

            setLanguageRotate()
        }
    }
    
    func setLanguageRotate() {
//        if isFromWatch {
            contentView.rotateViewForLanguage()
//        }
    }
    
    // comment count
//    func setCommentCount(_ obj: FeedData) {
//        commentLabel.dynamicSubheadRegular15()
//        let count = obj.commentCount ?? 0
//        let counterValue = (count == 0) ? "" : " " + String(count)
//        commentLabel.text = counterValue
//    }
    
//    func setTopLikeView(_ obj: FeedData) {
//        firstLikeImageView.image = .newIconLiked
//        secondLikeImageView.isHidden = true
//        cstLeadinglbl?.constant = 5
//        if let reationsTypesMobile = obj.reationsTypesMobile, !reationsTypesMobile.isEmpty {
//            if reationsTypesMobile.count > 1 {
//                cstLeadinglbl?.constant = 20
//            }
//            if let firstReactionType = reationsTypesMobile.first?.type {
//                firstLikeImageView.image = UIImage(named: "Img\(firstReactionType).png")
//                if reationsTypesMobile.count > 1, let secondReactionType = reationsTypesMobile[1].type {
//                    secondLikeImageView.image = UIImage(named: "Img\(secondReactionType).png")
//                    secondLikeImageView.isHidden = false
//                }
//            }
//        }
//    }
//
    // comment count
//    func setLikeCount(_ obj: FeedData) {
//        likeLabel.dynamicSubheadRegular15()
//        let count = obj.likeCount ?? 0
//        let counterValue = (count == 0) ? "" : " " + String(count)
//        commentLabel.text = counterValue
//    }
//
//    func setLikeHeading(_ obj: FeedData) {
//        likeHeadingLabel.dynamicSubheadRegular15()
//        let reaction = obj.isReaction ?? Const.emptyString
//        if reaction.count > 0 {
//            likeImageView.image = UIImage(named: "Img" + reaction + ".png")
//            likeHeadingLabel.isHidden = true
//        }
//    }
//
//    func setCommentHeading(_ obj: FeedData) {
//        commentHeadingLabel.dynamicSubheadRegular15()
//    }
    
//    func setShareHeading(_ obj: FeedData) {
//        shareHeadingLabel.dynamicSubheadRegular15()
//    }
    
//    func setDislike(obj: FeedData, indexPath: IndexPath?) {
//        viewModel.dislikeLike(obj, indexPath ?? IndexPath()) { [weak self] feedObj, index in
//            guard let strongSelf = self else { return }
//            strongSelf.displayViewContent(feedObj, at: index)
//        }
//    }
}

//extension PostSharingMemoriesView : ReactionDelegateResponse {
//    func reactionResponse(feedObj:FeedData) {
//        if let indexPath {
//            // reload to update display
//            displayViewContent(feedObj, at: indexPath)
//            SharedManager.shared.popover.dismiss()
//        }
//    }
//}
