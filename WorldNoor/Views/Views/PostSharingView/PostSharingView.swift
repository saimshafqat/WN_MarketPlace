//
//  EngagingView.swift
//  SweetSpot
//
//  Created by Asher Azeem on 10/31/22.
//

import UIKit
import FittedSheets

protocol PostSharingDelegate {
    func tappedShare(with feedData: FeedData, at indexPath: IndexPath)
    func tappedComment(with feedData: FeedData, at indexPath: IndexPath)
    func tappedLiked(with feedData: FeedData, at indexPath: IndexPath)
    func tappedLikesDetail(with feedData: FeedData, at indexPath: IndexPath)
    func tappedKalamSend(with feedData: FeedData, at indexPath: IndexPath)
}

class PostSharingView: UIView {
    
    // MARK: - IBOutlets -
    @IBOutlet var contentView: UIView!
    @IBOutlet var likeLabel : UILabel!
    @IBOutlet var commentLabel : UILabel!
    
    @IBOutlet var likeView : UIView!
    @IBOutlet var commentView : UIView!
    @IBOutlet var likeImageView : UIImageView!
    @IBOutlet var firstLikeImageView : UIImageView!
    @IBOutlet var secondLikeImageView : UIImageView!
    @IBOutlet weak var countDisplayStackView: UIStackView!
    @IBOutlet weak var countDisplayHeightContraint: NSLayoutConstraint!
    
    @IBOutlet weak var countDisplayTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var countDisplayBottomConstraint: NSLayoutConstraint!
    @IBOutlet var likeHeadingLabel : UILabel!
    @IBOutlet var commentHeadingLabel : UILabel!
    @IBOutlet var shareHeadingLabel : UILabel!
    @IBOutlet weak var sendHeadingLabel: UILabel!
    
    @IBOutlet var cstLeadinglbl : NSLayoutConstraint?
    @IBOutlet var likeButton : UIButton! {
        didSet {
            addLongPressGesture()
        }
    }
    @IBOutlet var commentButton : UIButton!
    @IBOutlet var shareButton : UIButton!
    
    // MARK: - Properties -
    var postSharingDelegate: PostSharingDelegate?
    var indexPath: IndexPath?
    public var postObj: FeedData?
    private var viewModel = PostSharingViewViewModel(apiService: APITarget())
    var isFromWatch : Bool = false
    
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
    
    @IBAction func onClickCommentCount(_ sender: Any) {
       
        if let indexPath, let postObj {
            postSharingDelegate?.tappedComment(with: postObj, at: indexPath)
        }
    }
    @IBAction func onClickComment(_ sender: UIButton) {
        SharedManager.shared.isFromReply = true
        if let indexPath, let postObj {
            postSharingDelegate?.tappedComment(with: postObj, at: indexPath)
        }
    }
    
    @IBAction func onClickLike(_ sender: UIButton) {
        SoundManager.share.playSound(.pop)
        if let postObj {
            if let isReaction = postObj.isReaction, isReaction.count > 0 {
                setDislike(obj: postObj, indexPath: indexPath)
                return
            }
            postLikeCallService(postObj, indexPath: indexPath)
        }
    }
    
    @IBAction func onClickLikeDetail(_ sender: UIButton) {
        if let postObj, let indexPath {
            postSharingDelegate?.tappedLikesDetail(with: postObj, at: indexPath)
        }
    }
    
    @IBAction func onClickSend(_ sender: UIButton) {
        if let postObj, let indexPath {
            postSharingDelegate?.tappedKalamSend(with: postObj, at: indexPath)
        }
    }
    
    // MARK: - Method
    private func commonInit() {
        _ = loadNibView(.postSharingView)
        addSubview(contentView)
        contentView.setConstraintWithBoundary(self)
    }
    
    // main method
    public func displayViewContent(_ obj: FeedData? ,at indexPath: IndexPath) {
        postObj = obj
        self.indexPath = indexPath
        if let obj {
            setLikeHeading(obj)
            setTopLikeView(obj)
            setLikeCount(obj)
            setCommentCount(obj)
            // setCountStackDisplayView(obj)
            setLanguageRotate()
        }
    }
    
    func setLanguageRotate() {
        if isFromWatch {
            contentView.rotateViewForLanguage()
        }
    }
    
    // comment count
    func setCommentCount(_ obj: FeedData) {
  //      commentLabel.dynamicSubheadRegular15()
        let count = obj.commentCount ?? 0
        let counterValue = (count == 0) ? "" : " " + String(count)
        commentLabel.text = counterValue
    }
    
    func setCountStackDisplayView(_ obj: FeedData) {
        let hasComment = (obj.commentCount ?? 0 > 0)
        let hasLike = (obj.reationsTypesMobile?.count ?? 0 > 0)
        let hasNoLikeAndComment = !(hasComment) && !(hasLike)
        countDisplayStackView.isHidden = hasNoLikeAndComment
        countDisplayTopConstraint.constant = hasNoLikeAndComment ? 0 : 12
        countDisplayBottomConstraint.constant = hasNoLikeAndComment ? 0 : 12
        countDisplayHeightContraint.constant =  hasNoLikeAndComment ? 0 : 30
    }
    
    func setTopLikeView(_ obj: FeedData) {
        firstLikeImageView.image = .newIconLikeU
        secondLikeImageView.isHidden = true
        cstLeadinglbl?.constant = 5
        if let reationsTypesMobile = obj.reationsTypesMobile, !reationsTypesMobile.isEmpty {
            if reationsTypesMobile.count > 1 {
                cstLeadinglbl?.constant = 20
            }
            if let firstReactionType = reationsTypesMobile.first?.type {
                firstLikeImageView.image = UIImage(named: "Img\(firstReactionType).png")
                if reationsTypesMobile.count > 1, let secondReactionType = reationsTypesMobile[1].type {
                    secondLikeImageView.image = UIImage(named: "Img\(secondReactionType).png")
                    secondLikeImageView.isHidden = false
                }
            }
        }
    }
    
    // comment count
    func setLikeCount(_ obj: FeedData) {
       // likeLabel.dynamicSubheadRegular15()
        if (obj.likeCount!) < 1 {
            obj.likeCount! = 0
        }
        let count = obj.likeCount ?? 0
        let counterValue = (count == 0) ? "" : " " + String(count)
        let selfLikedCount = (obj.likeCount ?? 0) - 1
        if obj.likeCount ?? 0 == 1 && obj.isLiked == true {
            likeLabel.text = "You"
        }
        else if obj.likeCount ?? 0 > 1 && obj.isLiked == true{
            likeLabel.text = "You and \(selfLikedCount) others"
        }
        else{
            likeLabel.text = counterValue
        }
    }
    
    func setLikeHeading(_ obj: FeedData) {
        likeButton.isSelected = obj.isLiked ?? false
        likeImageView.image = .newIconLikeU
   //     likeHeadingLabel.dynamicSubheadRegular15()
        self.setCommentHeading(obj)
        let reaction = obj.isReaction ?? .emptyString
        if reaction.count > 0 {
            likeImageView.image = UIImage(named: "Img" + reaction + ".png")
        }
        if likeImageView.image == .newIconLikeU {
            likeHeadingLabel.isHidden = false
        } else if likeImageView.image == UIImage(named: "Imglike") {
            likeHeadingLabel.isHidden = false
        } else {
            likeHeadingLabel.isHidden = true
        }
        // likeHeadingLabel.isHidden = likeImageView.image != .newIconLikeU
    }
    
    func setCommentHeading(_ obj: FeedData) {
   //     commentHeadingLabel.dynamicSubheadRegular15()
        self.setShareHeading(obj)
        self.setSendHeading(obj)
    }
    
    func setShareHeading(_ obj: FeedData) {
     //   shareHeadingLabel.dynamicSubheadRegular15()
    }
    
    func setSendHeading(_ obj: FeedData) {
  //      sendHeadingLabel.dynamicSubheadRegular15()
    }
        
    
    func setDislike(obj: FeedData, indexPath: IndexPath?) {
        likeButton.isUserInteractionEnabled = false
        if NetworkReachability.isConnectedToNetwork() {

            // when user will dislike
            if let reactionsMobile = obj.reationsTypesMobile, !reactionsMobile.isEmpty {
                if let index = reactionsMobile.firstIndex(where: { $0.type == obj.isReaction }) {
                    reactionsMobile[index].count! -= 1
                    if reactionsMobile[index].count! == 0 {
                        obj.reationsTypesMobile!.remove(at: index)
                    }
                }
            }
            
            obj.likeCount = (obj.likeCount) == nil ? 0 : (obj.likeCount ?? 0) - 1
            self.likeHeadingLabel.isHidden = false
            let reaction = obj.isReaction ?? .emptyString
            if reaction.count > 0 {
                likeImageView.image = .newIconLikeU
                if obj.likeCount == 0 {
                    self.firstLikeImageView.image = .newIconLikeU
                } else {
                    self.firstLikeImageView.image = UIImage(named: "Img" + reaction + ".png")
                }
            } else {
                self.firstLikeImageView.image = .newIconLikeU
                likeImageView.image = .newIconLikeU
            }
            setLikeCount(obj)
            setTopLikeView(obj)
            
        } else {
            SwiftMessages.showMessagePopup(theme: .error, title: "Failed", body: APIError.unreachable.localizedDescription)
            likeButton.isUserInteractionEnabled = true
            return
        }
        viewModel.dislikeLike(obj, indexPath ?? IndexPath()) { [weak self] feedObj, index in
            guard let strongSelf = self else { return }
            strongSelf.likeButton.isUserInteractionEnabled = true
        }
    }
    
    func addLongPressGesture() {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPress(gesture:)))
        longPress.minimumPressDuration = 1.0
        likeButton.addGestureRecognizer(longPress)
    }
    
    @objc func longPress(gesture: UILongPressGestureRecognizer) {
        if postObj?.isReaction == nil || postObj?.isReaction?.count == 0 {
            if gesture.state == UIGestureRecognizer.State.began {
                if let postObj {
                    if let isReaction = postObj.isReaction, isReaction.count > 0 {
                        setDislike(obj: postObj, indexPath: indexPath)
                        return
                    }
                    if let viewReaction = loadNibView(.reactionView) as? ReactionView {
                        viewReaction.earlyUpdateReactionCompletion = {[weak self] reactionImg, index in
                            guard let self else { return }
                            postObj.isReaction = SharedManager.shared.arrayGifType[index.row]
                            
                            var isFound = false
                            if postObj.reationsTypesMobile != nil {
                                if postObj.reationsTypesMobile?.count ?? 0 > 0  {
                                    for obj in 0..<(self.postObj?.reationsTypesMobile?.count ?? 0) {
                                        if self.postObj?.reationsTypesMobile?[obj].type == SharedManager.shared.arrayGifType[index.row] {
                                            isFound = true
                                            self.postObj?.reationsTypesMobile![obj].count = (self.postObj?.reationsTypesMobile![obj].count ?? 0) + 1
                                        }
                                    }
                                }
                            }
                            
                            if !isFound {
                                var newreaction = ReactionModel.init(countP: 1, typeP: SharedManager.shared.arrayGifType[index.row])
                                
                                if self.postObj?.reationsTypesMobile != nil {
                                    self.postObj?.reationsTypesMobile!.append(newreaction)
                                } else {
                                    self.postObj?.reationsTypesMobile = [newreaction]
                                }
                            }
                            
                            if self.postObj?.likeCount == nil {
                                self.postObj?.likeCount = 1
                            } else {
                                self.postObj?.likeCount! = 1 + (self.postObj?.likeCount)!
                            }
                            let selfLiked = (self.postObj?.likeCount! ?? 0) - 1
                            if self.postObj?.likeCount ?? 0 == 1{
                                likeLabel.text = "You"
                            }
                            else{
                                likeLabel.text = "You and \(selfLiked) others"
                            }
                            self.likeHeadingLabel.isHidden = true
                            likeImageView.image = UIImage(named: "Img\(reactionImg).png")
                            
                            if postObj.likeCount == 1 {
                                self.firstLikeImageView.image = UIImage(named: "Img\(reactionImg).png")
                            } else {
                                if self.firstLikeImageView.image == UIImage(named: "Img\(reactionImg)") {
                                    LogClass.debugLog("First Image already have")
                                } else if self.secondLikeImageView.image == UIImage(named: "Img\(reactionImg)") {
                                    LogClass.debugLog("Second Image already have")
                                    self.secondLikeImageView.isHidden = false
                                } else {
                                    self.secondLikeImageView.isHidden = false
                                    self.secondLikeImageView.image = UIImage(named: "Img\(reactionImg).png")
                                }
                            }
                             self.setTopLikeView(self.postObj!)
                            SharedManager.shared.popover.dismiss()
                        }
                        viewReaction.feedObj = postObj
                        let isScreenWidth = (UIScreen.main.bounds.size.width - 40) < 360
                        viewReaction.frame = CGRect(x: 0,
                                                    y: 0,
                                                    width: isScreenWidth ? (UIScreen.main.bounds.size.width - 40) : 360 ,
                                                    height: 40)
                        SharedManager.shared.popover = Popover(options: SharedManager.shared.popoverOptions)
                        SharedManager.shared.popover.show(viewReaction, fromView: likeButton)
                        viewReaction.delegateReaction = self
                    }
                }
            }
        }
    }
    
    func postLikeCallService(_ obj: FeedData, indexPath: IndexPath?) {
        likeButton.isUserInteractionEnabled = false
        if NetworkReachability.isConnectedToNetwork() {
            // when user will like the objec
            var isFound = false
            if self.postObj?.reationsTypesMobile != nil {
                if self.postObj?.reationsTypesMobile!.count ?? 0 > 0  {
                    for obj in 0..<(self.postObj?.reationsTypesMobile?.count ?? 0) {
                        if self.postObj?.reationsTypesMobile![obj].type == "like" {
                            isFound = true
                            self.postObj?.reationsTypesMobile![obj].count! = (self.postObj?.reationsTypesMobile![obj].count ?? 0) + 1
                        }
                    }
                }
            }
            if !isFound {
                let newreaction = ReactionModel.init(countP: 1, typeP: "like")
                if self.postObj?.reationsTypesMobile != nil {
                    self.postObj?.reationsTypesMobile?.append(newreaction)
                } else {
                    self.postObj?.reationsTypesMobile = [newreaction]
                }
            }
       //     likeLabel.dynamicSubheadRegular15()
            if (obj.likeCount!) < 1 {
                obj.likeCount! = 0
            }
           
//            self.setLikeCount(obj)
            if self.postObj?.likeCount == nil {
                self.postObj?.likeCount = 1
            } else {
                self.postObj?.likeCount! = 1 + (self.postObj?.likeCount ?? 0)
            }
            let count = self.postObj?.likeCount ?? 0
            let selfCount = count - 1
            if count == 1{
                likeLabel.text = "You"
            }
            else{
                likeLabel.text = "You and \(selfCount) others"
            }
            self.likeHeadingLabel.isHidden = false
            self.firstLikeImageView.image = UIImage(named: "Img\("like").png")
            self.likeImageView.image = UIImage(named: "Img\("like").png")
            
            
          
            
            
        } else {
            SwiftMessages.showMessagePopup(theme: .error, title: "Failed", body: APIError.unreachable.localizedDescription)
            likeButton.isUserInteractionEnabled = true
            return
        }
        let userToken = SharedManager.shared.userToken()
        DispatchQueue.global(qos: .userInitiated).async {
            let parameters = [
                "action": "react",
                "token": userToken,
                "type": "like",
                "post_id": String(obj.postID ?? 0)
            ]
            RequestManager.fetchDataPost(Completion: { response in
                
                DispatchQueue.main.async {
                    self.likeButton.isUserInteractionEnabled = true
                    switch response {
                    case .failure(let error):
                        SwiftMessages.apiServiceError(error: error)
                    case .success(let res):
                        if res is Int {
                            AppDelegate.shared().loadLoginScreen()
                        } else if res is String {
                            SwiftMessages.showMessagePopup(theme: .error, title: "Alert", body: res as? String ?? .emptyString)
                        } else {
                            self.postObj?.isReaction = "like"
                            self.likeHeadingLabel.isHidden = false
                           
//                            var isFound = false
//                            if self.postObj?.reationsTypesMobile != nil {
//                                if self.postObj?.reationsTypesMobile!.count ?? 0 > 0  {
//                                    for obj in 0..<(self.postObj?.reationsTypesMobile?.count ?? 0) {
//                                        if self.postObj?.reationsTypesMobile![obj].type == "like" {
//                                            isFound = true
//                                            self.postObj?.reationsTypesMobile![obj].count! = (self.postObj?.reationsTypesMobile![obj].count ?? 0) + 1
//                                        }
//                                    }
//                                }
//                            }
//                            if !isFound {
//                                let newreaction = ReactionModel.init(countP: 1, typeP: "like")
//                                if self.postObj?.reationsTypesMobile != nil {
//                                    self.postObj?.reationsTypesMobile?.append(newreaction)
//                                } else {
//                                    self.postObj?.reationsTypesMobile = [newreaction]
//                                }
//                            }
//                            if self.postObj?.likeCount == nil {
//                                self.postObj?.likeCount = 1
//                            } else {
//                                self.postObj?.likeCount! = 1 + (self.postObj?.likeCount ?? 0)
//                            }
                            
                            
//                            self.firstLikeImageView.image = UIImage(named: "Img\("like").png")
//                            self.likeImageView.image = UIImage(named: "Img\("like").png")
//                            if self.postObj != nil {
//                                self.setLikeCount(self.postObj!)
//                            }
                        }
                    }
                }
            }, param:parameters)
        }
    }
}

extension PostSharingView : ReactionDelegateResponse {
    func reactionResponse(feedObj:FeedData) {
        if let indexPath {
            // reload to update display
            displayViewContent(feedObj, at: indexPath)
            SharedManager.shared.popover.dismiss()
        }
    }
}
