//
//  ReelCollectionCell.swift
//  WorldNoor
//
//  Created by Asher Azeem on 07/04/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit
import AVFoundation
import Combine
import ActiveLabel

protocol ReelCellDelegate {
    func reelsUserTapped(at indexPath: IndexPath, playerView: VideoPlayerView?, obj: FeedData?)
    func reelCommentTapped(at indexPath: IndexPath, playerView: VideoPlayerView?)
    func reelSendTapped(at indexPath: IndexPath, playerView: VideoPlayerView?)
    func reelShareTapped(at indexPath: IndexPath, playerView: VideoPlayerView?, with url: URL)
    func reelMoreTapped(at indexPath: IndexPath, playerView: VideoPlayerView?, with url: URL)
    func reelHashTagTapped(at indexPath: IndexPath, playerView: VideoPlayerView?, text: String)
}

@objc(ReelCollectionCell)
class ReelCollectionCell: SSBaseCollectionCell {
    
    // MARK: - Properties
    @IBOutlet weak var playerView: VideoPlayerView? {
        didSet {
            if let playerView = playerView {
                reelCellViewModel.enableGestureOnView(on: playerView)
            }
        }
    }
    
    @IBOutlet weak var reelInformationView: UIView?
    @IBOutlet weak var optionsStackView: UIStackView?
    @IBOutlet weak var likeButton: UIButton? {
        didSet {
            addLongPressGesture()
        }
    }
    
    @IBOutlet weak var thumbnailImage: UIImageView?
    @IBOutlet weak var heightConstant: NSLayoutConstraint?
    @IBOutlet weak var userImageView: UIImageView?
    @IBOutlet weak var userNameLabel: UILabel? {
        didSet {
            userNameLabel?.addShadow(with: .darkText)
        }
    }
    @IBOutlet weak var pausePlayView: DesignableView?
    @IBOutlet weak var pausePlayImageView: UIImageView?
    @IBOutlet weak var likeAnimateView: DesignableView?
    @IBOutlet weak var likeAnimateImageView: UIImageView?
    @IBOutlet weak var infoTopConstraint: NSLayoutConstraint?
    @IBOutlet weak var infoStackBottomConstraint: NSLayoutConstraint!
    
    
    
    @IBOutlet weak var progressSlider: CustomSlider? {
        didSet {
            progressSlider?.addShadow(with: .darkText)
            progressSlider?.addTarget(self, action: #selector(sliderValueDidChange(_:)), for: .touchDown)
            progressSlider?.addTarget(self, action: #selector(sliderValueDidEndChange(_:)), for: .touchUpInside)
            progressSlider?.addTarget(self, action: #selector(sliderValueDidEndChange(_:)), for: .touchUpOutside)
        }
    }
    @IBOutlet weak var timeLabel: UILabel? {
        didSet {
            timeLabel?.addShadow(with: .darkText)
        }
    }
    @IBOutlet weak var likeCountLabel: UILabel? {
        didSet {
            likeCountLabel?.addShadow(with: .darkText)
        }
    }
    @IBOutlet weak var commentCountLabel: UILabel? {
        didSet {
            commentCountLabel?.addShadow(with: .darkText)
        }
    }
    @IBOutlet weak var shareCountLabel: UILabel? {
        didSet {
            shareCountLabel?.addShadow(with: .darkText)
        }
    }
    @IBOutlet weak var showMoreButton: UIButton? {
        didSet {
            showMoreButton?.addShadow(with: .darkText)
        }
    }
    @IBOutlet weak var activeTextLabel: ActiveLabel? {
        didSet {
            activeTextLabel?.addShadow(with: .darkText)
            activeTextLabel?.setNeedsDisplay()
        }
    }
    @IBOutlet weak var shareImageView: UIImageView? {
        didSet {
            shareImageView?.addShadow(with: .darkText)
        }
    }
    @IBOutlet weak var commentImageView: UIImageView! {
        didSet {
            commentImageView?.addShadow(with: .darkText)
        }
    }
    
    @IBOutlet weak var dotsImageView: UIImageView! {
        didSet {
            dotsImageView?.addShadow(with: .darkText)
        }
    }
    
    @IBOutlet weak var likeImageView: UIImageView! {
        didSet {
            likeImageView?.addShadow(with: .darkText)
        }
    }
    
    @IBOutlet weak var otherUserProfileImageView: DesignableView? {
        didSet {
            otherUserProfileImageView?.addShadow(with: .darkText)
        }
    }
    @IBOutlet weak var timeView: UIView?
    
    @IBOutlet weak var playPauseViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var likeImageViewWidthConstraint: NSLayoutConstraint!
    
    // MARK: - Properties
    var url: URL!
    var isMuteAll: Bool = true
    var reelCellDelegate: ReelCellDelegate?
    var indexPath: IndexPath?
    var feedData: FeedData?
    var postID: Int? = nil
    var reelCellViewModel = ReelCellViewModel()
    var cancellable = Set<AnyCancellable>()
    var isInitialLoad: Bool = false
    private var isLikeTapped = false
    
    // MARK: - Lazy Properties
    lazy var likeAnimator = LikeAnimator(container: contentView, layoutConstraint: likeImageViewWidthConstraint)
    lazy var pausePlayAnimator = LikeAnimator(container: contentView, layoutConstraint: playPauseViewWidthConstraint)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initilizeListner()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        resetUI()
    }
    
    override func configureCell(_ cell: Any!, atIndex thisIndex: IndexPath!, with object: Any!) {
        super.configureCell(cell, atIndex: thisIndex, with: object)
        if let obj = object as? FeedData {
            self.indexPath = thisIndex
            self.feedData = obj
            initialSetup(obj)
        }
    }
    
    // MARK: - IBAction
    @IBAction func onClickShowMore(_ sender: UIButton) {
        if let feedData  {
            feedData.isExpand = !(feedData.isExpand)
            showLessOrMoreDecision(feedData)
        }
    }
    
    @IBAction func onClickUser(_ sender: UIButton) {
        if let indexPath {
            reelCellDelegate?.reelsUserTapped(at: indexPath, playerView: playerView, obj: self.feedData)
        }
    }
    
    @IBAction func onClickComment(_ sender: UIButton) {
        if let indexPath {
            reelCellDelegate?.reelCommentTapped(at: indexPath, playerView: playerView)
        }
    }
    
    @IBAction func onClickReelSend(_ sender: UIButton) {
        if let indexPath {
            reelCellDelegate?.reelSendTapped(at: indexPath, playerView: playerView)
        }
    }
    
    @IBAction func onClickReelShare(_ sender: UIButton) {
        if let indexPath {
            reelCellDelegate?.reelShareTapped(at: indexPath, playerView: playerView, with: url)
        }
    }
    
    @IBAction func sliderChange(_ sender: UISlider) {
        let time = CMTime(seconds: (playerView?.totalDuration ?? 0.0) * Double(sender.value), preferredTimescale: 60)
        playerView?.seek(to: time)
    }
    
    @IBAction func onClickLike(_ sender: UIButton) {
        SoundManager.share.playSound(.pop)
        if let feedData {
            if let isReaction = feedData.isReaction, isReaction.count > 0 {
                setDislike(obj: feedData, indexPath: indexPath)
                return
            }
            postLikeCallService(feedData, indexPath: indexPath)
        }
    }
    
    func setDislike(obj: FeedData, indexPath: IndexPath?) {
        likeButton?.isUserInteractionEnabled = false
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
            let reaction = obj.isReaction ?? .emptyString
            if reaction.count > 0 {
                likeImageView.image = .reelLike
            } else {
                likeImageView.image = .reelLike
            }
            self.likeImageView.addShadow(with: .darkGray)
            setLikeCount(obj)
        } else {
            SwiftMessages.showMessagePopup(theme: .error, title: "Failed", body: APIError.unreachable.localizedDescription)  
            likeButton?.isUserInteractionEnabled = true
            return
        }
        reelCellViewModel.dislikeLike(obj, indexPath ?? IndexPath()) { [weak self] feedObj, index in
            guard let self else { return }
            likeButton?.isUserInteractionEnabled = true
            self.isLikeTapped = false
        }
    }
    
    func setLikeCount(_ obj: FeedData) {
        if ((feedData?.likeCount)!) < 1 {
            feedData?.likeCount = 0
        }
        let count = feedData?.likeCount ?? 0
        likeCountLabel?.text = String(count)
    }
    
    func postLikeCallService(_ obj: FeedData, indexPath: IndexPath?) {
        likeButton?.isUserInteractionEnabled = false
        if NetworkReachability.isConnectedToNetwork() {
            // when user will like the objec
            var isFound = false
            if feedData?.reationsTypesMobile != nil {
                if feedData?.reationsTypesMobile!.count ?? 0 > 0  {
                    for obj in 0..<(feedData?.reationsTypesMobile?.count ?? 0) {
                        if feedData?.reationsTypesMobile![obj].type == "like" {
                            isFound = true
                            self.feedData?.reationsTypesMobile![obj].count! = (feedData?.reationsTypesMobile![obj].count ?? 0) + 1
                        }
                    }
                }
            }
            if !isFound {
                let newreaction = ReactionModel.init(countP: 1, typeP: "like")
                if feedData?.reationsTypesMobile != nil {
                    feedData?.reationsTypesMobile?.append(newreaction)
                } else {
                    feedData?.reationsTypesMobile = [newreaction]
                }
            }
            if (obj.likeCount!) < 1 {
                obj.likeCount! = 0
            }
            if feedData?.likeCount == nil {
                feedData?.likeCount = 1
            } else {
                feedData?.likeCount! = 1 + (feedData?.likeCount ?? 0)
            }
            self.likeImageView.image = UIImage(named: "Img\("like").png")
            self.likeImageView.addShadow(with: .clear)
            self.setLikeCount(obj)
        } else {
            likeButton?.isUserInteractionEnabled = true
            return
        }
        let userToken = SharedManager.shared.userToken()
        let parameters = [
            "action": "react",
            "token": userToken,
            "type": "like",
            "post_id": String(obj.postID ?? 0)
        ]
        RequestManager.fetchDataPost(Completion: { response in
            DispatchQueue.main.async {
                self.likeButton?.isUserInteractionEnabled = true
                switch response {
                case .failure(let error):
                    SwiftMessages.apiServiceError(error: error)
                case .success(let res):
                    if res is Int {
                        AppDelegate.shared().loadLoginScreen()
                    } else if res is String {
                        SwiftMessages.showMessagePopup(theme: .error, title: "Alert", body: res as? String ?? .emptyString)
                    } else {
                        self.feedData?.isReaction = "like"
                    }
                    self.isLikeTapped = true
                }
            }
        }, param:parameters)
    }
    
    func setLikeImageView(_ obj: FeedData) {
        likeButton?.isSelected = obj.isLiked ?? false
        likeImageView.image = .newIconLikeU
        let reaction = obj.isReaction ?? .emptyString
        if reaction.count > 0 {
            likeImageView.image = UIImage(named: "Img" + reaction + ".png")
        }
    }
    
    @IBAction func onClickMore(_ sender: UIButton) {
        if let indexPath {
            reelCellDelegate?.reelMoreTapped(at: indexPath, playerView: playerView, with: url)
        }
    }
    
    // MARK: - Methods -
    private func setReelsUserInfo(_ obj: FeedData) {
        userImageView?.imageLoad(with: obj.profileImage)
        userNameLabel?.text = obj.authorName
        showCommentCount(obj)
        showLikeCount(obj)
        showShareCount(obj)
    }
    
    private func initialSetup(_ obj: FeedData) {
        // basic information
        setReelsUserInfo(obj)
        setExpandableText(obj)
        if let postFile = obj.post?.first {
            setBasicProperties(of: postFile)
            setReelThumbnail(postFile)
            setPlayerDimension(postFile)
        }
    }
    
    private func resetUI() {
        likeCountLabel?.text = .emptyString
        commentCountLabel?.text = .emptyString
        shareCountLabel?.text = .emptyString
        progressSlider?.isHidden = true
        likeImageView.image = .reelLike
        activeTextLabel?.text = .emptyString
        likeImageView.addShadow(with: .darkGray)
    }
    
    @objc func sliderValueDidChange(_ sender: UISlider) {
        AppLogger.log(tag: .success, "Slider value started changing")
        hideStackAndReelInfoViews(true)
        showTimeLabel(false)
    }
    
    @objc func sliderValueDidEndChange(_ sender: UISlider) {
        AppLogger.log(tag: .success, "Slider value stopped changing")
        hideStackAndReelInfoViews(false)
        showTimeLabel(true)
    }
    
    
    private func hideStackAndReelInfoViews(_ isShow: Bool) {
        optionsStackView?.isHidden = isShow
        reelInformationView?.isHidden = isShow
    }
    
    private func showTimeLabel(_ isShow: Bool) {
        timeLabel?.isHidden = isShow
        timeView?.isHidden = isShow
    }
    
    func showCommentCount(_ obj: FeedData) {
        commentCountLabel?.text = String(obj.commentCount ?? 0)
    }
    
    func showLikeCount(_ obj: FeedData) {
        likeCountLabel?.text = String(obj.likeCount ?? 0)
    }
    
    func showShareCount(_ obj: FeedData) {
        shareCountLabel?.text = String(obj.shareCount ?? 0)
    }
    
    private func setExpandableText(_ obj: FeedData)  {
        let hasNoText = ((obj.body ?? .emptyString).count == 0)
        if !(hasNoText) {
            setTextWithEnableURLHashtag(obj, label: activeTextLabel)
            setTextHashTagAction(at: activeTextLabel)
            setTextUrlAction(at: activeTextLabel)
        }
        setTextAlignment(of: activeTextLabel)
        setFont(of: activeTextLabel)
        setShowLessOrMore(obj)
        setConstraintInfoView()
    }
    
    private func setTextWithEnableURLHashtag(_ obj: FeedData, label: ActiveLabel?) {
        label?.text = obj.body
        label?.enabledTypes = [.url, .hashtag]
    }
    
    private func setTextHashTagAction(at label: ActiveLabel?) {
        label?.handleHashtagTap {[weak self] hashTag in
            guard let self else { return }
            if let indexPath {
                reelCellDelegate?.reelHashTagTapped(at: indexPath, playerView: playerView, text: hashTag)
            }
        }
    }
    
    private func setTextUrlAction(at label: ActiveLabel?) {
        activeTextLabel?.handleURLTap({ url in
            UIApplication.shared.open(url)
        })
    }
    
    private func setTextAlignment(of label: ActiveLabel?) {
        label?.textAlignment = reelCellViewModel.setTextDirection(label?.text)
    }
    
    private func setFont(of label: ActiveLabel?) {
        label?.font = reelCellViewModel.setFontStyleForText(label?.text ?? .emptyString)
    }
    
    private func setShowLessOrMore(_ obj: FeedData) {
        if let activeTextLabel {
            showLessOrMoreDecision(obj)
            showMoreButton?.isHidden = true
            if self.activeTextLabel?.text?.count ?? 0 > 0 {
                if activeTextLabel.isTruncated && !obj.isExpand {
                    showMoreButton?.isHidden = false
                }
            }
        }
    }
    
    private func setConstraintInfoView() {
        let hasText = self.activeTextLabel?.text?.count ?? 0 > 0
        infoTopConstraint?.constant = hasText ? 12 : 0
        infoStackBottomConstraint.constant = hasText ? 25 : 0
    }
    
    private func showLessOrMoreDecision(_ obj: FeedData) {
        showMoreButton?.setTitle((obj.isExpand) ? Const.showLess.localized() : Const.showMore.localized(), for: .normal)
        showMoreButton?.setImage(obj.isExpand ? .reelDropup : .reelDropdown, for: .normal)
        showMoreButton?.tintColor = .white
        activeTextLabel?.numberOfLines = obj.isExpand ? 0 : 1
    }
    
    func setBasicProperties(of obj: PostFile) {
        self.url = URL(string: obj.filePath ?? .emptyString)
        self.postID = obj.postID
    }
    
    func setPlayerDimension(_ obj: PostFile) {
        reelCellViewModel.calculateHeight(width: obj.videoWidth, height: obj.videoHeight)
    }
    
    func setReelThumbnail(_ obj: PostFile) {
        thumbnailImage?.imageLoad(with: obj.thumbnail, placeHolderImage: .grayPlaceholder)
    }
    
    func play() {
        reelCellViewModel.setVideo(playerView, of: postID, at: url, isVoice: isMuteAll, thumbnailImage, slider: progressSlider, timeLabel)
    }
    
    func pause() {
        reelCellViewModel.setPause(playerView: playerView)
    }
    
    private func addLongPressGesture() {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPress(gesture:)))
        longPress.minimumPressDuration = 1.0
        likeButton?.addGestureRecognizer(longPress)
    }
    
    @objc func longPress(gesture: UILongPressGestureRecognizer) {
        if feedData?.isReaction == nil || feedData?.isReaction?.count == 0 {
            if gesture.state == UIGestureRecognizer.State.began {
                if let feedData {
                    if let isReaction = feedData.isReaction, isReaction.count > 0 {
                        setDislike(obj: feedData, indexPath: indexPath)
                        return
                    }
                    if let viewReaction = loadNibView(.reactionView) as? ReactionView {
                        viewReaction.earlyUpdateReactionCompletion = {[weak self] reactionImg, index in
                            guard let self else { return }
                            feedData.isReaction = SharedManager.shared.arrayGifType[index.row]
                            
                            var isFound = false
                            if feedData.reationsTypesMobile != nil {
                                if feedData.reationsTypesMobile?.count ?? 0 > 0  {
                                    for obj in 0..<(self.feedData?.reationsTypesMobile?.count ?? 0) {
                                        if self.feedData?.reationsTypesMobile?[obj].type == SharedManager.shared.arrayGifType[index.row] {
                                            isFound = true
                                            self.feedData?.reationsTypesMobile![obj].count = (self.feedData?.reationsTypesMobile![obj].count ?? 0) + 1
                                        }
                                    }
                                }
                            }
                            
                            if !isFound {
                                let newreaction = ReactionModel.init(countP: 1, typeP: SharedManager.shared.arrayGifType[index.row])
                                if self.feedData?.reationsTypesMobile != nil {
                                    self.feedData?.reationsTypesMobile!.append(newreaction)
                                } else {
                                    self.feedData?.reationsTypesMobile = [newreaction]
                                }
                            }
                            
                            if self.feedData?.likeCount == nil {
                                self.feedData?.likeCount = 1
                            } else {
                                self.feedData?.likeCount! = 1 + (self.feedData?.likeCount)!
                            }
                            likeCountLabel?.text = String(describing: feedData.likeCount ?? 0)
                            likeImageView.image = UIImage(named: "Img\(reactionImg).png")
                            likeImageView.addShadow(with: .clear)
                            SharedManager.shared.popover.dismiss()
                        }
                        viewReaction.feedObj = feedData
                        let isScreenWidth = (UIScreen.main.bounds.size.width - 40) < 360
                        viewReaction.frame = CGRect(x: 0,
                                                    y: 0,
                                                    width: isScreenWidth ? (UIScreen.main.bounds.size.width - 40) : 360 ,
                                                    height: 40)
                        SharedManager.shared.popover = Popover(options: SharedManager.shared.popoverOptions)
                        if let likeButton {
                            SharedManager.shared.popover.show(viewReaction, fromView: likeButton)
                        }
                        viewReaction.delegateReaction = self
                    }
                }
            }
        }
    }
    
    func initilizeListner() {
        reelCellViewModel.$tapGesturePublisher
            .receive(on: DispatchQueue.main)
            .sink {[weak self] value in
                guard let self else { return }
                if value != nil {
                    AppLogger.log(tag: .success, "Received value of tapped Gesture: ", value as Any)
                    if let value {
                        if value.numberOfTapsRequired == 1 {
                            let isPlaying = playerView?.state == .playing
                            isPlaying ? playerView?.pause(reason: .userInteraction) : playerView?.resume()
                            pausePlayAnimator.animate {
                                self.pausePlayImageView?.image = isPlaying ? .reelPause : .reelPlay
                                self.pausePlayView?.isHidden = false
                            }
                        } else if value.numberOfTapsRequired == 2 {
                            likeAnimator.animate { [weak self] in
                                self?.likeAnimateView?.isHidden = false
                                SoundManager.share.playSound(.pop)
                            }
                            if let feedData {
                                if !isLikeTapped {
                                    postLikeCallService(feedData, indexPath: indexPath)
                                    isLikeTapped = true
                                }
                            }
                        }
                    }
                }
            }.store(in: &cancellable)
        
        reelCellViewModel.$heightPublisher
            .receive(on: DispatchQueue.main)
            .sink {[weak self] value in
                guard let self else { return }
                AppLogger.log(tag: .success, "Received value to height constraint:", value ?? 0.0)
                heightConstant?.constant = value != nil ? value! : UIScreen.main.bounds.height
            }.store(in: &cancellable)
        
        reelCellViewModel.$sliderPublisher
            .receive(on: DispatchQueue.main)
            .sink {[weak self] gesture in
                guard let self = self, let gesture = gesture else { return }
                switch gesture.state {
                case .ended:
                    AppLogger.log(tag: .success, "Received value to slider publisher:")
                    let pointTapped = gesture.location(in: self.contentView)
                    let positionOfSlider = progressSlider?.frame.origin ?? .zero
                    let widthOfSlider = progressSlider?.frame.size.width ?? 0.0
                    let relativePosition = max(min(pointTapped.x - positionOfSlider.x, widthOfSlider), 0.0)
                    let newValue = Float(relativePosition / widthOfSlider) * (self.progressSlider?.maximumValue ?? 0.0)
                    progressSlider?.setValue(newValue, animated: true)
                    if let progressSlider {
                        sliderChange(progressSlider)
                    }
                default:
                    break
                }
            }.store(in: &cancellable)
    }
    
    deinit {
        AppLogger.log(tag: .success, "Reel Collection cell has deinitilize")
    }
}


extension ReelCollectionCell : ReactionDelegateResponse {
    func reactionResponse(feedObj:FeedData) {
        setLikeCount(feedObj)
        setLikeImageView(feedObj)
        SharedManager.shared.popover.dismiss()
    }
}
