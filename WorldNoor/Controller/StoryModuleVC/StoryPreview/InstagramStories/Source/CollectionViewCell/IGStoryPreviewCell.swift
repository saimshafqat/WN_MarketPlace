//
//  IGStoryPreviewCell.swift
//  InstagramStories
//
//  Created by Boominadha Prakash on 06/09/17.
//  Copyright © 2017 DrawRect. All rights reserved.
//

import UIKit
import AVKit

protocol StoryPreviewProtocol: AnyObject {
    func didCompletePreview()
    func moveToPreviousStory()
    func didTapCloseButton()
    func didForwardStory(storyID:String)
    func didToastStoryMessage(message:String)
    func likeButtonTapped(feedObj : FeedData, dismisscompletion: (()->Void)?)
    func commentButtonTapped(feedObj : FeedData, dismisscompletion: (()->Void)?)
    func downloadfeed(feedObj : StoryObject, dismisscompletion: (()->Void)?)

}

protocol StoryCellDelegate:AnyObject {
    func userViewBtnDelegate(storyID:Int, cell:IGStoryPreviewCell)
  //  func userReplyViewBtnDelegate(statusObj:Status, storyID:Int, cell:IGStoryPreviewCell)
}

enum SnapMovementDirectionState {
    case forward
    case backward
}

//Identifiers
fileprivate let snapViewTagIndicator: Int = 8

final class IGStoryPreviewCell: UICollectionViewCell, UIScrollViewDelegate {
    var isFromReactResume: Bool = false
    var isFromReactPause: Bool = false
    
    var viewParent: UIViewController!
    
    //MARK: - Delegate
    public weak var delegate: StoryPreviewProtocol? {
        didSet { storyHeaderView.delegate = self }
    }
    var targetTime:CMTime = CMTimeMake(value: 0, timescale: 1)
    weak var storyUserDelegate:StoryCellDelegate?
    var isStripPlaying = true
    //MARK:- Private iVars
    private lazy var storyHeaderView: IGStoryPreviewHeaderView = {
        let v = IGStoryPreviewHeaderView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    var timerValue = 0
    var durationVideo = 0
    var storyTxtView: StoryTxtView!
    var likeView : StoriesBtnView!
    var storyTxtHConst: NSLayoutConstraint!
    var viewBack : UIView = UIView()
    let custProgressView = UISlider()
    var storyIndex : Int!

    var isVideoPlay : Bool = false
    private lazy var storyBottomView: StoryBottomView = {
        let v = StoryBottomView()
        v.backgroundColor = UIColor.clear
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
  
    var progressValue : Double = 0.05

    
    private lazy var longPress_gesture: UILongPressGestureRecognizer = {
        let lp = UILongPressGestureRecognizer.init(target: self, action: #selector(didLongPress(_:)))
        lp.minimumPressDuration = 0.2
        lp.delegate = self
        
        return lp
    }()
    
    private lazy var tap_gesture: UITapGestureRecognizer = {
        let tg = UITapGestureRecognizer(target: self, action: #selector(didTapSnap(_:)))
        tg.cancelsTouchesInView = true;
        tg.numberOfTapsRequired = 1
        tg.delegate = self
        return tg
    }()
    
    
    private var previousSnapIndex: Int {
        return snapIndex - 1
    }
    private var snapViewXPos: CGFloat {
        return (snapIndex == 0) ? 0 : scrollview.subviews[previousSnapIndex].frame.maxX
    }
    private var videoSnapIndex: Int = 0
    
    var retryBtn: IGRetryLoaderButton!
    
    //MARK:- Public iVars
    public var direction: SnapMovementDirectionState = .forward
    public let scrollview: UIScrollView = {
        let sv = UIScrollView()
        sv.backgroundColor = UIColor.black
       
        sv.showsVerticalScrollIndicator = false
        sv.showsHorizontalScrollIndicator = false
        sv.isScrollEnabled = false
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    public var getSnapIndex: Int {
        return snapIndex
    }
    public var snapIndex: Int = 0 {
        didSet {
            scrollview.isUserInteractionEnabled = true
            switch direction {
            case .forward:
                if snapIndex < story?.snapsCount ?? 0 {
                    if let snap = story?.snaps[snapIndex] {
                        self.storyHeaderView.type = snap.postType
                        self.manageStoryTxtHeight(snapObj: snap, snapIndex: snapIndex)
                        if snap.videoID != SharedManager.shared.userObj?.data.id?.description {

                        }
                        storyBottomView.countLbl.isHidden = true
                        if story?.internalidentifier == SharedManager.shared.userObj?.data.id?.description {
                            storyBottomView.countLbl.isHidden = false
                        }
                        if SharedManager.shared.updateSliderTimer != nil
                        {
                            SharedManager.shared.updateSliderTimer.invalidate()
                            progressValue = 0.05
                        }
                        if snap.postType == "image" {
                            if let snapView = getSnapview() {
                                snapView.backgroundColor = UIColor.black
                                startRequest(snapView: snapView, with: snap.videoUrl)
                            } else {
                                let snapView = createSnapView()
                                snapView.backgroundColor = UIColor.black
                                startRequest(snapView: snapView, with: snap.videoUrl)
                               
                            }
                        }else if snap.postType == "video" {
                            if let videoView = getVideoView(with: snapIndex) {
                                startPlayer(videoView: videoView, with: snap.videoUrl)
                            } else {
                                let videoView = createVideoView()
                                startPlayer(videoView: videoView, with: snap.videoUrl)
                            }
                        }else if snap.postType == "post" {
                            if getTextSnapview() != nil
                            {                               
                                self.startProgressors(isType: "post")
                            } else {
                                _ = createTextSnapView()
                                self.startProgressors(isType: "post")
                            }
                        }
                    }
                }
            case .backward:
                if snapIndex < story?.snapsCount ?? 0 {
                    if let snap = story?.snaps[snapIndex] {
                        self.storyHeaderView.type = snap.postType ?? ""
                        self.manageStoryTxtHeight(snapObj: snap, snapIndex: snapIndex)
                        storyBottomView.countLbl.isHidden = true
                        if SharedManager.shared.updateSliderTimer != nil
                        {
                            SharedManager.shared.updateSliderTimer.invalidate()
                            progressValue = 0.05
                        }
                        if snap.postType == "image" {
                            if let snapView = getSnapview() {
                                snapView.backgroundColor = UIColor.black
                                startRequest(snapView: snapView, with: snap.videoUrl)
                            } else {
                                let snapView = createSnapView()
                                snapView.backgroundColor = UIColor.black
                                startRequest(snapView: snapView, with: snap.videoUrl)
                            }
                        }else if snap.postType == "video" {
                            if let videoView = getVideoView(with: snapIndex) {
                                startPlayer(videoView: videoView, with: snap.videoUrl)
                            }else {
                                let videoView = createVideoView()
                                startPlayer(videoView: videoView, with: snap.videoUrl)
                            }
                        }else if snap.postType == "post" {
                            self.custProgressView.isHidden = true
                            if getTextSnapview() != nil
                            {
                                self.startProgressors(isType: "post")
                            } else {
                                _ = createTextSnapView()
                                self.startProgressors(isType: "post")
                            }
                    }
                }
            }
        }
    }
    }
   @objc func update() {
       if(story?.snaps[snapIndex].postType == "image" || story?.snaps[snapIndex].postType == "post")
       {
        if(progressValue < 10.0)
    {
            self.didTrack(progress: Float(progressValue), total: 10.0)
            progressValue = progressValue + 0.05
    } else
       {
        SharedManager.shared.updateSliderTimer.invalidate()
        self.didCompletePlay()
        progressValue = 0.05
    }
       }
    }
    public var story: FeedVideoModel? {
        didSet {
            storyHeaderView.story = story
            if let picture = story?.user?.picture {
                storyHeaderView.snaperImageView.setImage(url: picture)
            }
        }
    }
    
    //MARK: - Overriden functions
    override init(frame: CGRect) {
        super.init(frame: frame)
        scrollview.frame = bounds
        loadUIElements()
        loadViews()
        installLayoutConstraints()
    }

    func loadViews(){
        self.viewBack.frame = CGRect.init(x: 0, y: 0, width: contentView.frame.size.width, height: contentView.frame.size.height)
        self.viewBack.backgroundColor = UIColor.clear
        contentView.addSubview(self.viewBack)
    }
    
    
    func addUserImage(){
        if(self.likeView != nil)
        {
            self.likeView.removeFromSuperview()
            self.likeView = nil
        }
        self.likeView = Bundle.main.loadNibNamed("StoriesBtnView", owner: self, options: nil)?.first as! StoriesBtnView
        self.likeView.customDelegate = self
        self.likeView.parentView = self.viewParent
        self.likeView.frame = self.viewBack.frame
        if snapIndex < story!.snaps.count
        {
       
        }
        else
        {
      snapIndex = 0
            
        }
        self.likeView.modelObj = story!.snaps[snapIndex]
        self.likeView.modelObj.snapIndex = snapIndex
        self.likeView.storyIndex = self.storyIndex
        
     //   likeView.imgviewStoryUser.loadImageWithPH(urlMain: likeView.modelObj.authorImage)
        self.likeView.reloadData()
        self.viewBack.addSubview(self.likeView)
        
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        direction = .forward
        clearScrollViewGarbages()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
      
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - Private functions
    private func loadUIElements() {
        self.storyTxtView = Bundle.main.loadNibNamed("StoryTxtView", owner: nil, options: nil)?.first as? StoryTxtView
        
        self.backgroundColor = UIColor.black
        scrollview.delegate = self
        scrollview.isPagingEnabled = true
        scrollview.backgroundColor = .black
        contentView.addSubview(scrollview)
        contentView.addSubview(storyHeaderView)
        contentView.addSubview(self.storyTxtView)
        contentView.addSubview(storyBottomView)
        contentView.backgroundColor = UIColor.black
        scrollview.addGestureRecognizer(longPress_gesture)
        scrollview.addGestureRecognizer(tap_gesture)
      //  contentView.addSubview(custProgressView)
        custProgressView.thumbTintColor = UIColor.clear

    }
    
    private func installLayoutConstraints() {
        //Setting constraints for scrollview
        NSLayoutConstraint.activate([
            scrollview.igLeftAnchor.constraint(equalTo: contentView.igLeftAnchor),
            contentView.igRightAnchor.constraint(equalTo: scrollview.igRightAnchor),
            scrollview.igTopAnchor.constraint(equalTo: contentView.igTopAnchor),
            contentView.igBottomAnchor.constraint(equalTo: scrollview.igBottomAnchor),
            scrollview.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 1.0),
            scrollview.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 1.0)
        ])
        
        NSLayoutConstraint.activate([
            storyHeaderView.igLeftAnchor.constraint(equalTo: contentView.igLeftAnchor),
            contentView.igRightAnchor.constraint(equalTo: storyHeaderView.igRightAnchor),
            storyHeaderView.igTopAnchor.constraint(equalTo: contentView.igTopAnchor),
            storyHeaderView.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        NSLayoutConstraint.activate([
            storyBottomView.igLeftAnchor.constraint(equalTo: contentView.igLeftAnchor, constant: 120),
            contentView.igRightAnchor.constraint(equalTo: storyBottomView.igRightAnchor, constant: 120),
            storyBottomView.igBottomAnchor.constraint(equalTo: contentView.igBottomAnchor),
            storyBottomView.heightAnchor.constraint(equalToConstant: 80)
        ])
        self.storyTxtView.translatesAutoresizingMaskIntoConstraints = false
        //      self.storyTxtView.txtView.text = "Testing one of my message lets see how its working. Same message testing, lets see how its wg, lets see how its workingTesting one of my message lets see how its working. Same message testing, lets see how its working."
        NSLayoutConstraint.activate([
            self.storyTxtView.igLeftAnchor.constraint(equalTo: contentView.igLeftAnchor),
            contentView.igRightAnchor.constraint(equalTo: self.storyTxtView.igRightAnchor),
            self.storyTxtView.igBottomAnchor.constraint(equalTo: contentView.igBottomAnchor, constant: 0.0),
            self.storyTxtView.heightAnchor.constraint(lessThanOrEqualTo: contentView.heightAnchor, constant: -70)
        ])
        storyTxtHConst = self.storyTxtView.heightAnchor.constraint(equalToConstant: 20)
        storyTxtHConst.isActive = true
        self.storyTxtView.readMoreBtn.addTarget(self, action: #selector(readMoreBtnClicked(sender:)), for: .touchUpInside)
        self.storyTxtView.readMoreAboveBtn.addTarget(self, action: #selector(readMoreAboveBtnClicked(sender:)), for: .touchUpInside)
    }
    
    @objc func readMoreAboveBtnClicked(sender : UIButton) {
        self.readMoreBtnClicked(sender: sender)
    }
    
    @objc func readMoreBtnClicked(sender : UIButton) {
        if self.storyTxtView.readMoreBtn.titleLabel?.text == "Read More" {
            pauseEntireSnap()
            self.storyTxtView.readMoreBtn.setTitle("Read Less", for: .normal)
            if let snap = story?.snaps[sender.tag] {
                self.storyTxtView.readMoreBtn.tag = snapIndex
                self.storyTxtView.readMoreAboveBtn.tag = snapIndex
                self.storyTxtView.txtView.text = story?.body
                let txtH = self.storyTxtView.txtView.getHeightFrame(self.storyTxtView.txtView).height + 50
                storyTxtHConst.constant = txtH
            }
        }else {
            resumeEntireSnap()
            self.storyTxtView.readMoreBtn.setTitle("Read More", for: .normal)
            storyTxtHConst.constant = 135
        }
    }
    
    func manageStoryTxtHeight(snapObj:StoryObject, snapIndex:Int){
        self.storyTxtView.isHidden = false
        self.storyTxtView.readMoreBtn.isHidden = true
        self.storyTxtView.readMoreBtn.setTitle("Read More", for: .normal)
        if snapObj.postType == "post" {
            self.storyTxtView.isHidden = true
        }else {
            self.storyTxtView.readMoreBtn.tag = snapIndex
            self.storyTxtView.readMoreAboveBtn.tag = snapIndex
            self.storyTxtView.txtView.text = story?.snaps[snapIndex].body
            let txtH = self.storyTxtView.txtView.getHeightFrame(self.storyTxtView.txtView).height + 50
            if txtH > 135 {
                storyTxtHConst.constant = 135
                self.storyTxtView.readMoreBtn.isHidden = false
            }else {
                self.storyTxtView.readMoreBtn.isHidden = true
                storyTxtHConst.constant = txtH
            }
        }
    }
    
    private func createSnapView() -> UIImageView {
        let snapView = UIImageView()
        snapView.backgroundColor = UIColor.black
        snapView.contentMode = .scaleAspectFit
        snapView.translatesAutoresizingMaskIntoConstraints = false
        snapView.tag = snapIndex + snapViewTagIndicator
      //  self.manageStoryBottomData()
        scrollview.addSubview(snapView)
        
        // Setting constraints for snap view.
        NSLayoutConstraint.activate([
            snapView.leadingAnchor.constraint(equalTo: (snapIndex == 0) ? scrollview.leadingAnchor : scrollview.subviews[previousSnapIndex].trailingAnchor),
            snapView.igTopAnchor.constraint(equalTo: scrollview.igTopAnchor),
            snapView.widthAnchor.constraint(equalTo: scrollview.widthAnchor),
            snapView.heightAnchor.constraint(equalTo: scrollview.heightAnchor),
            scrollview.igBottomAnchor.constraint(equalTo: snapView.igBottomAnchor)
        ])
        return snapView
    }
    
    private func createTextSnapView() -> UIView {
        let snapView = UIView.init()
        let txtView = UITextView(frame: .zero, textContainer: nil)
        txtView.font = UIFont.systemFont(ofSize: 35)
        txtView.isEditable = false
        txtView.isScrollEnabled = false   // causes expanding height
        txtView.backgroundColor = UIColor.clear
        txtView.textColor = UIColor.white
        txtView.text = "No Text found."
        txtView.contentOffset = .zero
        snapView.backgroundColor = UIColor.black
        if let snap = story?.snaps[snapIndex] {
            txtView.text = snap.body
             let snapColor = snap.colorcode
                if snapColor != "" {
                    if  snapColor == "#9b9b9b" || snapColor == "#4BE84F" || snapColor == "#0eee91" || snapColor == "#98f9b4" || snapColor == "#FDD900" {
                        txtView.textColor = UIColor.black
                    }
                    snapView.backgroundColor = UIColor.init().hexStringToUIColor(hex:snapColor)
                }
    
        }
      //  self.manageStoryBottomData()
        snapView.translatesAutoresizingMaskIntoConstraints = false
        snapView.tag = snapIndex + snapViewTagIndicator
        snapView.addSubview(txtView)
        txtView.translatesAutoresizingMaskIntoConstraints = false
        
        // txtView constraints...
        NSLayoutConstraint.activate([
            //          txtView.topAnchor.constraint(equalTo: snapView.topAnchor, constant: 80),
            txtView.leadingAnchor.constraint(equalTo: snapView.leadingAnchor, constant: 20),
            txtView.trailingAnchor.constraint(equalTo: snapView.trailingAnchor, constant: -20),
            //          txtView.cen
            txtView.igCenterXAnchor.constraint(equalTo: snapView.igCenterXAnchor),
            txtView.igCenterYAnchor.constraint(equalTo: snapView.igCenterYAnchor),
            //          txtView.bottomAnchor.constraint(equalTo: snapView.bottomAnchor, constant: -60)
        ])
        
        scrollview.addSubview(snapView)
        
        NSLayoutConstraint.activate([
            snapView.leadingAnchor.constraint(equalTo: (snapIndex == 0) ? scrollview.leadingAnchor : scrollview.subviews[previousSnapIndex].trailingAnchor),
            snapView.igTopAnchor.constraint(equalTo: scrollview.igTopAnchor),
            snapView.widthAnchor.constraint(equalTo: scrollview.widthAnchor),
            snapView.heightAnchor.constraint(equalTo: scrollview.heightAnchor),
            scrollview.igBottomAnchor.constraint(equalTo: snapView.igBottomAnchor)
        ])
        
        txtView.textAlignment = .center
        return snapView
    }
    
    private func getTextSnapview() -> UIView? {
        
        if let txtView = scrollview.subviews.filter({$0.tag == snapIndex + snapViewTagIndicator}).first {
            return txtView
        }
        return nil
    }
    
    private func getSnapview() -> UIImageView? {
        if let imageView = scrollview.subviews.filter({$0.tag == snapIndex + snapViewTagIndicator}).first as? UIImageView {
            imageView.backgroundColor = UIColor.black
            return imageView
        }
        return nil
    }
    
    func manageStoryBottomData() {
        var viewCount = 0
        var isMyStory = false
        let btn = storyBottomView.snaperBtn
    //    if let snap = story?.snaps[snapIndex] {
            if story?.internalidentifier == SharedManager.shared.userObj?.data.id?.description {
                isMyStory = true
            }
         //   viewCount = snap.views
            btn.tag = Int(story!.videoID)!
            let viewsLbl = storyBottomView.countLbl
            if isMyStory {
                viewsLbl.text = String(viewCount)
                btn.setTitle("", for: .normal)
                btn.setImage(UIImage.init(named: "storyViews"), for: .normal)
                btn.addTarget(self, action: #selector(storyUserViews(sender:)), for: .touchUpInside)
                storyBottomView.countLbl.isHidden = false
            }else {
                if story?.internalidentifier != SharedManager.shared.userObj?.data.id?.description {
                    btn.setImage(UIImage.init(named: ""), for: .normal)
                    btn.setTitle("Reply", for: .normal)
                    btn.addTarget(self, action: #selector(storyReplyUserViews(sender:)), for: .touchUpInside)
                    storyBottomView.countLbl.isHidden = true
                }else {
                    btn.isHidden = true
                }
            }
      //  }
    }
    
    private func createVideoView() -> IGPlayerView {
        let videoView = IGPlayerView()
        videoView.translatesAutoresizingMaskIntoConstraints = false
        videoView.tag = snapIndex + snapViewTagIndicator
        videoView.playerObserverDelegate = self
        scrollview.addSubview(videoView)
        NSLayoutConstraint.activate([
            videoView.leadingAnchor.constraint(equalTo: (snapIndex == 0) ? scrollview.leadingAnchor : scrollview.subviews[previousSnapIndex].trailingAnchor),
            videoView.igTopAnchor.constraint(equalTo: scrollview.igTopAnchor),
            videoView.widthAnchor.constraint(equalTo: scrollview.widthAnchor),
            videoView.heightAnchor.constraint(equalTo: scrollview.heightAnchor),
            scrollview.igBottomAnchor.constraint(equalTo: videoView.igBottomAnchor)
        ])
      //  self.manageStoryBottomData()
        return videoView
    }
    
    private func getVideoView(with index: Int) -> IGPlayerView? {
        if let videoView = scrollview.subviews.filter({$0.tag == index + snapViewTagIndicator}).first as? IGPlayerView {
            return videoView
        }
        return nil
    }
    
    private func startRequest(snapView: UIImageView, with url: String) {
        snapView.setImage(url: url, style: .squared) {[weak self] (result) in
            guard let strongSelf = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    snapView.backgroundColor = UIColor.black
//                    if SharedManager.shared.updateSliderTimer != nil
//                    {
//                        SharedManager.shared.updateSliderTimer.invalidate()
//                        self!.progressValue = 0.05
//                    }
//                    SharedManager.shared.updateSliderTimer = Timer.scheduledTimer(timeInterval: self!.progressValue, target: self, selector: #selector(self!.update), userInfo: nil, repeats: true)
                    strongSelf.startProgressors()
                case .failure(_):
                    snapView.backgroundColor = UIColor.black
                    strongSelf.showRetryButton(with: url, for: snapView)
                }
            }
        }
    }
    
    @objc func storyReplyUserViews(sender : UIButton) {

    }
    
    @objc func storyUserViews(sender : UIButton) {
        self.storyUserDelegate?.userViewBtnDelegate(storyID: sender.tag, cell: self)
        pauseEntireSnap()
    }
    
    func getViewBtn()->UIButton  {
        let btn = UIButton.init()
        btn.setTitleShadowColor(UIColor.black, for: .normal)
        btn.layer.masksToBounds = false
        btn.layer.shadowColor = UIColor.black.cgColor
        btn.layer.shadowOpacity = 1
        btn.layer.shadowOffset = CGSize(width: -1, height: 1)
        btn.layer.shadowRadius = 1
        return btn
    }
    
    func getViewLbl()->UILabel{
        let viewLbl = UILabel.init()
        viewLbl.textColor = UIColor.white
        viewLbl.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        viewLbl.translatesAutoresizingMaskIntoConstraints = false
        viewLbl.layer.masksToBounds = false
        viewLbl.layer.shadowColor = UIColor.black.cgColor
        viewLbl.layer.shadowOpacity = 1
        viewLbl.layer.shadowOffset = CGSize(width: -1, height: 1)
        viewLbl.layer.shadowRadius = 2
        return viewLbl
    }
    
    private func showRetryButton(with url: String, for snapView: UIImageView) {
        self.retryBtn = IGRetryLoaderButton.init(withURL: url)
        self.retryBtn.translatesAutoresizingMaskIntoConstraints = false
        self.retryBtn.delegate = self
        self.isUserInteractionEnabled = true
        snapView.addSubview(self.retryBtn)
        NSLayoutConstraint.activate([
            self.retryBtn.igCenterXAnchor.constraint(equalTo: snapView.igCenterXAnchor),
            self.retryBtn.igCenterYAnchor.constraint(equalTo: snapView.igCenterYAnchor)
        ])
    }
    
    private func startPlayer(videoView: IGPlayerView, with url: String) {
        if scrollview.subviews.count > 0 {
            if story?.isCompletelyVisible == true {
                videoView.startAnimating()
                IGVideoCacheManager.shared.getFile(for: url) { (result) in
                    switch result {
                    case .success(let url):
                        let videoResource = VideoResource(filePath: url.absoluteString)

                        videoView.play(with: videoResource)
                    case .failure(let error):
                        let videoResource = VideoResource(filePath: url)
                        videoView.play(with: videoResource)
                        videoView.stopAnimating()
                    }
                }
            }
        }
    }
    
    @objc private func didLongPress(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began || sender.state == .ended {
            if sender.state == .began {
                pauseEntireSnap()
            }else {
                resumeEntireSnap()
            }
        }
    }
    
    @objc private func didTapSnap(_ sender: UITapGestureRecognizer) {
        let touchLocation = sender.location(ofTouch: 0, in: self.scrollview)

        if let snapCount = story?.snapsCount {
            var n = snapIndex
            /*!
             * Based on the tap gesture(X) setting the direction to either forward or backward
             */
            if let snap = story?.snaps[n], snap.postType == "image", getSnapview()?.image == nil {
                //Remove retry button if tap forward or backward if it exists
                if let snapView = getSnapview(), let btn = retryBtn, snapView.subviews.contains(btn) {
                    snapView.removeRetryButton()
                }
                fillupLastPlayedSnap(n)
            }else {
                //Remove retry button if tap forward or backward if it exists
                if let videoView = getVideoView(with: n), let btn = retryBtn, videoView.subviews.contains(btn) {
                    videoView.removeRetryButton()
                }
                if getVideoView(with: n)?.player?.timeControlStatus != .playing {
                    fillupLastPlayedSnap(n)
                }
            }
            if touchLocation.x < scrollview.contentOffset.x + (scrollview.frame.width/2) {
                direction = .backward
                if snapIndex >= 1 && snapIndex <= snapCount {
                    clearLastPlayedSnaps(n)
                    stopSnapProgressors(with: n)
                    n -= 1
                    resetSnapProgressors(with: n)
                    willMoveToPreviousOrNextSnap(n: n)
                } else {
                    delegate?.moveToPreviousStory()
                }
            } else {
                if snapIndex >= 0 && snapIndex <= snapCount {
                    //Stopping the current running progressors
                    stopSnapProgressors(with: n)
                    direction = .forward
                    n += 1
                    willMoveToPreviousOrNextSnap(n: n)
                }
            }
        }
    }
    
    @objc private func didEnterForeground() {
        if !isVideoPlay {
            isVideoPlay = true
            if let topStory = UIApplication.topViewController()! as? IGStoryPreviewController {
                if let snap = story?.snaps[snapIndex] {
                    if story?.postType == "video" {
                        resumeEntireSnap()
                        let videoView = getVideoView(with: snapIndex)
                        videoView?.handleSeek(seekTime: Int(self.custProgressView.value))
                        videoView?.player?.play()
                        videoView?.player?.volume = 0.0
                        videoView?.player?.isMuted = true
                    }else {
                        isVideoPlay = true
                        startSnapProgress(with: snapIndex)
                    }
                }
            }
        }
        DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(2)) { [self] in
            isVideoPlay = false     // Code
        }
    }
    
    @objc private func didEnterBackground() {
       if let snap = story?.snaps[snapIndex] {
            if snap.postType == "video" {
          self.stopPlayer()
            }
       }
        resetSnapProgressors(with: snapIndex)
    }
    
    private func willMoveToPreviousOrNextSnap(n: Int) {
        if let count = story?.snapsCount {
            if n < count {
                let x = n.toFloat * frame.width
                let offset = CGPoint(x: x,y: 0)
                scrollview.setContentOffset(offset, animated: false)
                story?.lastPlayedSnapIndex = n
                snapIndex = n
                self.setCustomViewValues(index: self.storyIndex)
            } else {
                delegate?.didCompletePreview()
            }
            
        }
    }
    
    @objc private func didCompleteProgress() {
        var checkValue = 0
        if self.story?.snaps[self.snapIndex].postType == "video" {
            checkValue = self.durationVideo
        } else {
            checkValue = 5
        }
        
        if self.story?.snaps[self.snapIndex].postType != "video" {
            self.timerValue = 5
        } 
        LogClass.debugLog("Timer Progress Complete ==> \(timerValue)")
        LogClass.debugLog("Check Value Progress Complete ==> \(timerValue)")
        if timerValue == -1 || checkValue == timerValue {
            self.timerValue = 0
            SharedManager.shared.timerMainNew.invalidate()
            let n = snapIndex + 1
            if let count = story?.snapsCount {
                if n < count {
                    //Move to next snap
                    let x = n.toFloat * frame.width
                    let offset = CGPoint(x: x,y: 0)
                    scrollview.setContentOffset(offset, animated: false)
                    story?.lastPlayedSnapIndex = n
                    direction = .forward
                    snapIndex = n
                    self.setCustomViewValues(index: self.storyIndex)
                    
                }else {
                    stopPlayer()
                    delegate?.didCompletePreview()
                }
            }
        }
    }
    
    private func fillUpMissingImageViews(_ sIndex: Int) {
        if sIndex != 0 {
            for i in 0..<sIndex {
                snapIndex = i
            }
            let xValue = sIndex.toFloat * scrollview.frame.width
            scrollview.contentOffset = CGPoint(x: xValue, y: 0)
        }
    }
    //Before progress view starts we have to fill the progressView
    private func fillupLastPlayedSnap(_ sIndex: Int) {
        if let snap = story?.snaps[sIndex], snap.postType == "video" {
            videoSnapIndex = sIndex
            stopPlayer()
        }
        if let holderView = self.getProgressIndicatorView(with: sIndex),
           let progressView = self.getProgressView(with: sIndex){
            progressView.widthConstraint?.isActive = false
            progressView.widthConstraint = progressView.widthAnchor.constraint(equalTo: holderView.widthAnchor, multiplier: 1.0)
            progressView.widthConstraint?.isActive = true
        }
    }
    private func fillupLastPlayedSnaps(_ sIndex: Int) {
        //Coz, we are ignoring the first.snap
        if sIndex != 0 {
            for i in 0..<sIndex {
                if let holderView = self.getProgressIndicatorView(with: i),
                   let progressView = self.getProgressView(with: i){
                    progressView.widthConstraint?.isActive = false
                    progressView.widthConstraint = progressView.widthAnchor.constraint(equalTo: holderView.widthAnchor, multiplier: 1.0)
                    progressView.widthConstraint?.isActive = true
                }
            }
        }
    }
    private func clearLastPlayedSnaps(_ sIndex: Int) {
        if let _ = self.getProgressIndicatorView(with: sIndex),
           let progressView = self.getProgressView(with: sIndex) {
            progressView.widthConstraint?.isActive = false
            progressView.widthConstraint = progressView.widthAnchor.constraint(equalToConstant: 0)
            progressView.widthConstraint?.isActive = true
        }
    }
    private func clearScrollViewGarbages() {
        scrollview.contentOffset = CGPoint(x: 0, y: 0)
        if scrollview.subviews.count > 0 {
            var i = 0 + snapViewTagIndicator
            var snapViews = [UIView]()
            scrollview.subviews.forEach({ (imageView) in
                if imageView.tag == i {
                    snapViews.append(imageView)
                    i += 1
                }
            })
            if snapViews.count > 0 {
                snapViews.forEach({ (view) in
                    view.removeFromSuperview()
                })
            }
        }
    }
    private func gearupTheProgressors(type: MimeType, playerView: IGPlayerView? = nil) {
        if let holderView = getProgressIndicatorView(with: snapIndex),
           let progressView = getProgressView(with: snapIndex){
            progressView.story_identifier = self.story?.internalidentifier
            progressView.snapIndex = snapIndex
            DispatchQueue.main.async {
                if type == .image || type == .post {
                    self.timerValue = 0
                    if (SharedManager.shared.timerMainNew != nil) {
                        SharedManager.shared.timerMainNew.invalidate()
                    }
                    SharedManager.shared.timerMainNew = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.timerAction), userInfo: nil, repeats: self.isFromReactPause ? false : true)
                            progressView.start(with: 5.0, holderView: holderView, completion: {(identifier, snapIndex, isCancelledAbruptly) in
                                if isCancelledAbruptly == false {
                                    if (type == .image || type == .post) && self.isFromReactPause {
                                        self.timerValue = 5
                                    }
                                    self.didCompleteProgress()
                                }
                            })
                } else {
                    //Handled in delegate methods for videos
                }
            }
        }
    }
    
    @objc func timerAction() {
        if !isFromReactPause {
            timerValue += 1
        }
    }
    
    //MARK:- Internal functions
    func startProgressors(isType:String = "") {
            DispatchQueue.main.async {
                if self.scrollview.subviews.count > 0 {
                    let imageView = self.scrollview.subviews.filter{v in v.tag == self.snapIndex + snapViewTagIndicator}.first as? UIImageView
                    let txtView = self.scrollview.subviews.filter{v in v.tag == self.snapIndex + snapViewTagIndicator}.first
                    if imageView?.image != nil && self.story?.isCompletelyVisible == true {
                        self.gearupTheProgressors(type: .image)
                    }else if txtView != nil  && isType == "post"{
                        self.gearupTheProgressors(type: .post)
                    } else {
                        if self.story?.isCompletelyVisible == true {
                            let videoView = self.scrollview.subviews.filter{v in v.tag == self.snapIndex + snapViewTagIndicator}.first as? IGPlayerView
                            let snap = self.story?.snaps[self.snapIndex]
                            if let vv = videoView, self.story?.isCompletelyVisible == true {
                                self.startPlayer(videoView: vv, with: snap!.videoUrl)
                            }
                        }
                    }
                }
            }
        
        
    }
    func getProgressView(with index: Int) -> IGSnapProgressView? {
        let progressView = storyHeaderView.getProgressView
        if progressView.subviews.count > 0 {
            let pv = getProgressIndicatorView(with: index)?.subviews.first as? IGSnapProgressView
            guard let currentStory = self.story else {
                fatalError("story not found")
            }
            pv?.story = currentStory
            return pv
        }
        return nil
    }
    func getProgressIndicatorView(with index: Int) -> UIView? {
        let progressView = storyHeaderView.getProgressView
        return progressView.subviews.filter({v in v.tag == index+progressIndicatorViewTag}).first ?? nil
    }
    func adjustPreviousSnapProgressorsWidth(with index: Int) {
        fillupLastPlayedSnaps(index)
    }
    //MARK: - Public functions
    public func willDisplayCellForZerothIndex(with sIndex: Int) {
        story?.isCompletelyVisible = true
        willDisplayCell(with: sIndex)
    }
    public func willDisplayCell(with sIndex: Int) {
        //Todo:Make sure to move filling part and creating at one place
        //Clear the progressor subviews before the creating new set of progressors.
        storyHeaderView.clearTheProgressorSubviews()
        storyHeaderView.createSnapProgressors()
        fillUpMissingImageViews(sIndex)
        fillupLastPlayedSnaps(sIndex)
        snapIndex = sIndex
        
        //Remove the previous observors
        NotificationCenter.default.removeObserver(self)
      
        NotificationCenter.default.addObserver(self, selector: #selector(self.didEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.didEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    public func setCustomViewValues(index : Int)
    {
        self.storyIndex = index
        self.addUserImage()
    }
    public func startSnapProgress(with sIndex: Int) {
        if let indicatorView = getProgressIndicatorView(with: sIndex),
           let pv = getProgressView(with: sIndex) {
            pv.start(with: 5.0, holderView: indicatorView, completion: { (identifier, snapIndex, isCancelledAbruptly) in
                if isCancelledAbruptly == false {
                    self.didCompleteProgress()
                }
            })
        }
    }
    public func pauseSnapProgressors(with sIndex: Int) {
        story?.isCompletelyVisible = false
        
        getProgressView(with: sIndex)?.pause()
    }
    public func stopSnapProgressors(with sIndex: Int) {
       // timerValue = -1
        timerValue = 0
        getProgressView(with: sIndex)?.stop()
    }
    public func resetSnapProgressors(with sIndex: Int) {
        // timerValue = -1
        timerValue = 0
        self.getProgressView(with: sIndex)?.reset()
    }
    public func pausePlayer(with sIndex: Int) {
        getVideoView(with: sIndex)?.pause()
    }
    
    public func stopPlayer() {
        let videoView = getVideoView(with: videoSnapIndex)
        if videoView?.player?.timeControlStatus != .playing {
            getVideoView(with: videoSnapIndex)?.player?.replaceCurrentItem(with: nil)
        }
        videoView?.stop()
        //getVideoView(with: videoSnapIndex)?.player = nil
    }
    
    public func resumePlayer(with sIndex: Int) {
        getVideoView(with: sIndex)?.play()
    }
    
    public func didEndDisplayingCell() {
        progressValue = 0.0
    }
    
    public func resumePreviousSnapProgress(with sIndex: Int) {
        getProgressView(with: sIndex)?.resume()
    }
    public func muteSnap(isMute: Bool, completion: ((Bool?) -> Void)? = nil) {
        let videoView = scrollview.subviews.first { $0.tag == snapIndex + snapViewTagIndicator } as? IGPlayerView
        if let videoPlayer = videoView?.player {
            // Toggle the mute state
            videoPlayer.isMuted = !isMute
            if(isMute){
                videoPlayer.volume = 1.0
            }else{
                videoPlayer.volume = 0.0
            }
           
            completion?(videoPlayer.isMuted)
        } else {
            completion?(nil) // Indicate failure if player is not found
        }
    }

    public func pauseEntireSnap(completion : ((Double?) -> Void)? = nil) {
        let v = getProgressView(with: snapIndex)
        let videoView = scrollview.subviews.filter{v in v.tag == snapIndex + snapViewTagIndicator}.first as? IGPlayerView
//        if SharedManager.shared.updateSliderTimer != nil
//        {
//            SharedManager.shared.updateSliderTimer.invalidate()
//        }
        if videoView != nil {
            v?.pause()
            videoView?.pause()
        }else {
            v?.pause()
        }
        isStripPlaying = false
        if completion != nil {
            completion?(progressValue)
        }
    }
    
    public func resumeEntireSnap(isFromReact: Bool = false) {
        let v = getProgressView(with: snapIndex)
        let videoView = scrollview.subviews.filter{v in v.tag == snapIndex + snapViewTagIndicator}.first as? IGPlayerView
        if videoView != nil {
            v?.resume()
            videoView?.play()
        } else {
            v?.resume()
        }
        if story?.snaps[snapIndex].postType == "image" || story?.snaps[snapIndex].postType == "post" {
          // SharedManager.shared.updateSliderTimer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
        }
         isStripPlaying = true
    }
    
    //Used the below function for image retry option
    public func retryRequest(view: UIView, with url: String) {
        if let v = view as? UIImageView {
            v.removeRetryButton()
            self.startRequest(snapView: v, with: url)
        } else if let v = view as? IGPlayerView {
            v.removeRetryButton()
            self.startPlayer(videoView: v, with: url)
        }
    }
}
extension IGStoryPreviewCell : igpreviewCellProtocols {
   
    func didtap(touchLocation : CGPoint)
    {
        if let snapCount = story?.snapsCount {
            var n = snapIndex
            /*!
             * Based on the tap gesture(X) setting the direction to either forward or backward
             */
            if let snap = story?.snaps[n], snap.postType == "image", getSnapview()?.image == nil {
                //Remove retry button if tap forward or backward if it exists
                if let snapView = getSnapview(), let btn = retryBtn, snapView.subviews.contains(btn) {
                    snapView.removeRetryButton()
                }
                fillupLastPlayedSnap(n)
            }else {
                //Remove retry button if tap forward or backward if it exists
                if let videoView = getVideoView(with: n), let btn = retryBtn, videoView.subviews.contains(btn) {
                    videoView.removeRetryButton()
                }
                if getVideoView(with: n)?.player?.timeControlStatus != .playing {
                    fillupLastPlayedSnap(n)
                }
            }
            if touchLocation.x < (scrollview.frame.width/2) {
                direction = .backward
                if snapIndex >= 1 && snapIndex <= snapCount {
                    clearLastPlayedSnaps(n)
                    stopSnapProgressors(with: n)
                    n -= 1
                    resetSnapProgressors(with: n)
                    willMoveToPreviousOrNextSnap(n: n)
                } else {
                    delegate?.moveToPreviousStory()
                }
            } else {
                if snapIndex >= 0 && snapIndex <= snapCount {
                    //Stopping the current running progressors
                    stopSnapProgressors(with: n)
                    direction = .forward
                    n += 1
                    willMoveToPreviousOrNextSnap(n: n)
                }
            }
        }
    }
    func pauseProtocol(completion : ((Double?) -> Void)? = nil) {
        isFromReactPause = true
        self.pauseEntireSnap { progress in
            completion?(progress)
        }
    }
    
    func pauseAndPlayProtocol(with progressValue: Double?) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if self.isFromReactPause {
                self.resumeEntireSnap(isFromReact: true)
                if self.story?.snaps[self.snapIndex].postType == "image" || self.story?.snaps[self.snapIndex].postType == "post" {
                    self.isFromReactPause = false
                }
            }
        }
    }
    
    func backButtonProtocol() {
        if SharedManager.shared.updateSliderTimer != nil {
            SharedManager.shared.updateSliderTimer.invalidate()
        }
        if story?.snaps[snapIndex].postType == "video" {
            stopPlayer()
        }
        self.pauseEntireSnap()
        delegate?.didTapCloseButton()

        if SharedManager.shared.timerMainNew != nil {
            SharedManager.shared.timerMainNew.invalidate()
        }
    }
    
    func likeButtonProtocol(feedObj : FeedData!, dismissCompletion: (()->Void)? = nil) {
        delegate!.likeButtonTapped(feedObj : feedObj) {
            dismissCompletion?()
        }
    }
    
    func commentButtonProtocol(feedObj : FeedData!, dismissCompletion: (()->Void)? = nil) {
        delegate!.commentButtonTapped(feedObj : feedObj) {
            dismissCompletion?()
        }
    }
    
    func shareButtonProtocol(feedObj : StoryObject!, dismissCompletion: (()->Void)? = nil) {
        delegate!.downloadfeed(feedObj: feedObj) {
            dismissCompletion?()
        }
    }
}

//MARK: - Extension|StoryPreviewHeaderProtocol
extension IGStoryPreviewCell: StoryPreviewHeaderProtocol {
    func didDownloadSnapDelegate() {
        if let snap = story?.snaps[snapIndex] {
            if story?.postType == "video" || story?.postType == "image" {
                if let snapUrlStr = story?.videoUrl {
                    if snapUrlStr.contains("https") || snapUrlStr.contains("http") {
                        let snapUrl = URL.init(string: snapUrlStr)
                        let downloadObj = DownloadStoryManager.init()
                        downloadObj.statusObj = snap
                        downloadObj.startDownload(downloadUrl: snapUrl!, type: snap.videoUrl)
                        self.delegate?.didToastStoryMessage(message: "downloading...")
                        self.resumeEntireSnap()
                    }
                }
            }
        }
    }
    
    func didForwardSnapDelegate()   {
        if let snap = story?.snaps[snapIndex] {
            delegate?.didForwardStory(storyID:String(snap.videoID))
        }
    }
    
    
    func didPausingSnapDelegate() {
        self.pauseEntireSnap()
    }
    
    func didResumeSnapDelegate() {
        self.resumeEntireSnap()
    }
    
    func didTapCloseButton() {
        self.pauseEntireSnap()
        delegate?.didTapCloseButton()
    }
}

//MARK: - Extension|RetryBtnDelegate
extension IGStoryPreviewCell: RetryBtnDelegate {
    func retryButtonTapped() {
        self.retryRequest(view: retryBtn.superview!, with: retryBtn.contentURL!)
    }
}

//MARK: - Extension|IGPlayerObserverDelegate
extension IGStoryPreviewCell: IGPlayerObserver {
    
    func didStartPlaying() {
        
        if let videoView = getVideoView(with: snapIndex) {
            if videoView.error == nil && (story?.isCompletelyVisible)! == true {
                if let holderView = getProgressIndicatorView(with: snapIndex),
                   let progressView = getProgressView(with: snapIndex) {
                    progressView.story_identifier = self.story?.internalidentifier
                    progressView.snapIndex = snapIndex
                    if let duration = videoView.currentItem?.asset.duration {
                        if Float(duration.value) > 0 {
                            self.timerValue = 0
                            if (SharedManager.shared.timerMainNew != nil) {
                                SharedManager.shared.timerMainNew.invalidate()
                            }
                            SharedManager.shared.timerMainNew = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.timerAction), userInfo: nil, repeats: isFromReactPause ? false : true)
                            durationVideo = Int(duration.seconds)
                            LogClass.debugLog("Video Duration ==> \(durationVideo)")
                                progressView.start(with: duration.seconds, holderView: holderView, completion: {(identifier, snapIndex, isCancelledAbruptly) in
                                    if isCancelledAbruptly == false {
                                        self.videoSnapIndex = snapIndex
                                        if !(self.isFromReactPause) {
                                            self.timerValue = Int(duration.seconds)
                                            self.stopPlayer()
                                            self.isFromReactPause = false
                                        }
                                        self.didCompleteProgress()
                                    } else {
                                        self.videoSnapIndex = snapIndex
                                        self.stopPlayer()
                                    }
                                })
                        } else {
                            
                        }
                    }
                }
            }
        }
    }
    func didFailed(withError error: String, for url: URL?) {
        if let videoView = getVideoView(with: snapIndex), let videoURL = url {
            self.retryBtn = IGRetryLoaderButton(withURL: videoURL.absoluteString)
            self.retryBtn.translatesAutoresizingMaskIntoConstraints = false
            self.retryBtn.delegate = self
            self.isUserInteractionEnabled = true
            videoView.addSubview(self.retryBtn)
            NSLayoutConstraint.activate([
                self.retryBtn.igCenterXAnchor.constraint(equalTo: videoView.igCenterXAnchor),
                self.retryBtn.igCenterYAnchor.constraint(equalTo: videoView.igCenterYAnchor)
            ])
        }
    }
    
    func didCompletePlay() {
        //Video completed
        stopPlayer()
        if(SharedManager.shared.updateSliderTimer != nil)
        {
            SharedManager.shared.updateSliderTimer.invalidate()
            
        }
        progressValue = 0.05
                 delegate?.didCompletePreview()
    }
    
    func didTrack(progress: Float ,total : Float) {
        custProgressView.frame = CGRect(x: 0.0 , y: 20.0, width: contentView.frame.size.width, height: 3.0)
        custProgressView.maximumTrackTintColor = UIColor.white
        custProgressView.minimumTrackTintColor = UIColor.red
        custProgressView.maximumValue = total
        custProgressView.value = progress
    //    self.storyHeaderView.getProgressView1
    }
}

extension IGStoryPreviewCell: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
