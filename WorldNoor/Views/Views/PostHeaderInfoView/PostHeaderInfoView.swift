//
//  EngagingView.swift
//  SweetSpot
//
//  Created by Asher Azeem on 10/31/22.

import UIKit
import ActiveLabel
import FittedSheets
import Combine

protocol PostHeaderInfoDelegate {
    func tappedSeeMore(with feedData: FeedData, at indexPath: IndexPath)
    func tappedTranslation(with feedData: FeedData, at indexPath: IndexPath)
    func tappedMore(with feedData: FeedData, at indexPath: IndexPath)
    func tappedHide(with feedData: FeedData, at indexPath: IndexPath)
    func tappedUserInfo(with feedData: FeedData, at indexPath: IndexPath)
    func tappedShowPostDetail(with feedData: FeedData, at indexPath: IndexPath)
    func speechFinished(with feedData: FeedData, at indexPath: IndexPath)
    func tappedHashTag(with hashTag: String, at indexPath: IndexPath)

}

class PostHeaderInfoView: UIView {
    
    // MARK: - IBOutlets -
    @IBOutlet var contentView: UIView!
    @IBOutlet var nameLabel : UILabel?
    @IBOutlet var dateLabel : UILabel?
    @IBOutlet var memoryDateLbl : UILabel?
    @IBOutlet weak var addFriendImage: UIImageView!
    
    @IBOutlet var userImageView : UIImageView?
    @IBOutlet var frienRequestButton : LoaderButton?
    @IBOutlet weak var activeTextLabel: ActiveLabel!
    @IBOutlet weak var sharedActiveTextLabel: ActiveLabel!
    
    @IBOutlet var userInfoButton : UIButton?
    @IBOutlet weak var textView: UIView!
    @IBOutlet weak var showMoreButton: UIButton!
    @IBOutlet weak var orignalButton: LoadingButton?
    @IBOutlet weak var speakerButton: UIButton!
    @IBOutlet weak var speakerImage: UIImageView!
    @IBOutlet weak var speakerListenLabel: UILabel!
    
    @IBOutlet weak var showPostDetailButton: UIButton!
    @IBOutlet weak var sharedView: UIView!
    @IBOutlet weak var memoryView: UIView!
    
    @IBOutlet weak var btnCross: LoaderButton?
    @IBOutlet weak var crossImageView: UIImageView!
    @IBOutlet weak var btnDot: UIButton?
    
    @IBOutlet weak var cstWidth: NSLayoutConstraint?
    
    @IBOutlet weak var sharedActiveTextTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var sharedActiveTextBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var sharedTranslationViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var sharedOrignalButton: LoadingButton!
    @IBOutlet weak var sharedSpeakerButton: UIButton!
    @IBOutlet weak var viewForMoreOrignalBtn: UIView!
    @IBOutlet weak var viewForSharedMoreOrignalBtn: UIView!
    @IBOutlet weak var friendRequestWidthConstraint: NSLayoutConstraint!
    
    
    // MARK: - Properties -
    private var viewModel = PostHeaderInfoViewViewModel()
    var postHeaderInfoDelegate: PostHeaderInfoDelegate?
    var indexPath: IndexPath?
    public var postObj: FeedData?
    private var parentPostObj: FeedData?
    var isFromWatch : Bool = false
    var isFromMemory : Bool = false
    
    private var subscription: Set<AnyCancellable> = []
    
    // MARK: - Computed properties
    var isShared: Bool {
        return parentPostObj?.postType == FeedType.shared.rawValue
    }
    
    // MARK: - Init -
    override init(frame: CGRect) {
        super.init(frame: UIScreen.main.bounds)
        commonInit()
    }
    
    // MARK: - Required Init -
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    // MARK: - IBAction
    @IBAction func onClickShowMore(_ sender: UIButton) {
        if let parentPostObj, let postObj  {
            parentPostObj.isExpand = !(parentPostObj.isExpand)
            showLessOrMoreDecision(postObj, parentObj: parentPostObj)
            if let indexPath {
                postHeaderInfoDelegate?.tappedSeeMore(with: isShared ? parentPostObj : postObj, at: indexPath)
            }
        }
    }
    
    @IBAction func onClickHidePost(_ sender: LoaderButton) {
        if let postObj, let indexPath, let parentPostObj {
            let feedData = isShared ? parentPostObj : postObj
            let postId = feedData.postID ?? 0
            let parameters = ["action": "post/hide", "post_id":String(postId)]
            self.callingService(parameters: parameters , indexpath: indexPath,feedData: feedData)
        }
    }
    
    func callingService(parameters: [String:Any] , indexpath : IndexPath , feedData: FeedData){
        btnCross?.startLoading(color: .darkGray)
        crossImageView?.isHidden = true
        RequestManager.fetchDataPost(Completion: { response in
            Loader.stopLoading()
            self.postHeaderInfoDelegate?.tappedHide(with: feedData, at: indexpath)
            self.btnCross?.stopLoading()
            self.crossImageView?.isHidden = false
        }, param: parameters)
    }

    @IBAction func onClickMore(_ sender: UIButton) {
        if let postObj, let indexPath, let parentPostObj {
            postHeaderInfoDelegate?.tappedMore(with: isShared ? parentPostObj : postObj, at: indexPath)
        }
    }
    
    @IBAction func onClickSpeaker(_ sender: UIButton) {
        speakerAction(at: activeTextLabel, of: speakerButton)
    }
    
    @IBAction func onClickSharedSpeakerBtn(_ sender: UIButton) {
        if activeTextLabel.text != Const.loading {
            speakerAction(at: sharedActiveTextLabel, of: sharedSpeakerButton)
        }
    }
    
    @IBAction func onClickUserInfo(_ sender: UIButton) {
        if let postObj, let indexPath, let parentPostObj {
            postHeaderInfoDelegate?.tappedUserInfo(with: isShared ? parentPostObj : postObj, at: indexPath)
        }
    }
    
    @IBAction func onClickShowPostDetail(_ sender: UIButton) {
        if let postObj, let indexPath, let parentPostObj {
            postHeaderInfoDelegate?.tappedShowPostDetail(with: isShared ? parentPostObj : postObj, at: indexPath)
        }
    }
    
    @IBAction func onClickShowUserDetail(_ sender: UIButton) {
        if let postObj, let indexPath, let parentPostObj {
            postHeaderInfoDelegate?.tappedUserInfo(with: isShared ? parentPostObj : postObj, at: indexPath)
        }
    }
    
    @IBAction func onClickFriendRequest(_ sender: LoaderButton) {
        viewModel.setfriendRequest(parentPostObj, postObj, frienRequestButton, addFriendImg: addFriendImage)
    }
    
    // MARK: - Methods
    private func commonInit() {
        _ = loadNibView(.postHeaderInfoView)
        addSubview(contentView)
        contentView.setConstraintWithBoundary(self)
    }
    
    func manageMemoryView(isFrom:Bool){
        isFromMemory = isFrom
        (self.isFromMemory) ? (self.memoryView.isHidden = false) : (self.memoryView.isHidden = true)
        self.memoryDateLbl?.text = postObj?.memoryValue
    }
    
    // main method
    public func displayViewContent(_ obj: FeedData?, parentData: FeedData?, at indexPath: IndexPath?) {
        speakerButton.tag = indexPath?.row ?? 0
        sharedSpeakerButton.tag = indexPath?.row ?? 0
        postObj = obj
        parentPostObj = parentData
        self.indexPath = indexPath
        if let obj, let parentData {
            // visibility shared view
            setSharedView(obj, parentData: parentData)
            setPersonHeaderInfo(obj ,parentData)
            visibilityRequestBtn(obj, parentObj: parentData)
            setExpandableText(obj, parentObj: parentData)
            setSharedExpandableText(obj, parentObj: parentData)
            setOrignalButton(obj, parentData)
            setSpeaker(at: activeTextLabel, of: speakerButton)
            setSpeaker(at: sharedActiveTextLabel, of: sharedSpeakerButton)
            setSharedOrignalButton(obj, parentData)
            setLanguageRotate()
        }
    }
    
    private func setSharedView(_ obj: FeedData, parentData: FeedData) {
        sharedView.isHidden = !(isShared)
    }
    
    private func setSpeaker(at label: ActiveLabel, of button: UIButton) {
        let speechManager = SpeechManager.shared
        speechManager.speechFinishCompletion = {
            button.isSelected = false
        }
        if label.text == SpeechManager.shared.speechText && SpeechManager.shared.isSpeaking {
            SpeechManager.shared.pauseSpeaking()
            button.isSelected = true
        } else {
            button.isSelected = false
        }
    }
    
    private func speakerAction(at label: ActiveLabel, of button: UIButton) {
        if activeTextLabel.text != Const.loading {
            SpeakerUtility.speakerUtility(button, with: label.text)
        }
    }
    
    func setLanguageRotate() {
        contentView.rotateViewForLanguage()
        [activeTextLabel, sharedActiveTextLabel, nameLabel!, dateLabel!, memoryDateLbl!].forEach { lable in
            labelRotateCell(viewMain: lable)
            lable.rotateViewForLanguage()
            lable.rotateForTextAligment()
        }
        
        if let langName = postObj?.language?.languageName as? String, langName != SharedManager.shared.getLang() {
            [self.activeTextLabel, self.sharedActiveTextLabel].forEach { $0.rotateForTextAligment(languageMain: langName) }
        }
        
        [viewForMoreOrignalBtn, viewForSharedMoreOrignalBtn].forEach { btnView in
            labelRotateCell(viewMain: btnView)
            btnView.rotateViewForLanguage()
        }
        
        [activeTextLabel, sharedActiveTextLabel].forEach({ label in
            setTextAlignment(of: label)
            setFont(of: label)
            label.sizeToFit()
        })
    }
    
    // header info
    private func setPersonHeaderInfo(_ obj: FeedData, _ parentObj: FeedData) {
        LogClass.debugLog("UIApplication.topViewController() ======> parentObj")
        self.cstWidth?.constant = 40.0
        self.btnCross?.isHidden = false
        self.btnDot?.isHidden = false
        if let topVC = UIApplication.topViewController(), topVC is MemoryVC {
            LogClass.debugLog("UIApplication.topViewController() ======> IF")
            self.cstWidth?.constant = 0.0
            self.btnCross?.isHidden = true
            self.btnDot?.isHidden = true
        }
        
        // header come from main object / parent Object not from shared obj
        let authorName = parentObj.authorName ?? .emptyString
        var name = authorName
        if isShared {
            let sharedPostPerson = obj.authorName ?? .emptyString
            var sharedText = " shared \(obj.authorName ?? .emptyString) post"
            if authorName == sharedPostPerson {
                sharedText = " shared his post"
            }
            name = "\(authorName)\(sharedText)"
            nameLabel?.attributedText = name.attributedStringWithColor([sharedText], color: .darkGray.withAlphaComponent(0.6), font: .systemFont(ofSize: 12, weight: .regular))
        } else {
            nameLabel?.text = name
        }
        
        dateLabel?.text = parentObj.postedTime
        let profileImage = parentObj.profileImage ?? .emptyString
        userImageView?.imageLoad(with: profileImage)
    }

    private func setExpandableText(_ obj: FeedData, parentObj: FeedData)  {
        let hasNoText = ((parentObj.body ?? .emptyString).count == 0)
        textView.isHidden = hasNoText
        if !(hasNoText) {
            activeTextLabel.dynamicBodyRegular17WithoutClip()
            setTextWithEnableURLHashtag(parentObj, label: activeTextLabel)
            setTextHashTagAction(at: activeTextLabel)
            setTextUrlAction(at: activeTextLabel)
        }
        setTextAlignment(of: activeTextLabel)
        setFont(of: activeTextLabel)
        setShowLessOrMore(obj: obj, parentObj: parentObj)
    }
    
    private func setSharedExpandableText(_ obj: FeedData, parentObj: FeedData) {
        let hasNoText = ((obj.body ?? .emptyString).count == 0)
        // when parent is shared and has text then hidden false
        let isShow = isShared && !(hasNoText)
        sharedView.isHidden = !(isShow)
        setSharedViewConstraint(isShow)
        if isShow {
            setTextWithEnableURLHashtag(obj, label: sharedActiveTextLabel)
            setTextHashTagAction(at: activeTextLabel)
            setTextUrlAction(at: sharedActiveTextLabel)
        }
        setTextAlignment(of: sharedActiveTextLabel)
        setFont(of: sharedActiveTextLabel)
    }
    
    private func setTextWithEnableURLHashtag(_ obj: FeedData, label: ActiveLabel) {
        label.text = obj.isSharedTranslation ? obj.orignalBody : obj.body
        label.enabledTypes = [.url,.hashtag]
    }
    
    private func setSharedViewConstraint(_ isShow: Bool) {
        sharedActiveTextTopConstraint.constant = isShow ? 8 : 0
        sharedActiveTextBottomConstraint.constant = isShow ? 8 : 0
        sharedTranslationViewHeightConstraint.constant = isShow ? 25 : 0
    }
    
    private func setTextAlignment(of label: ActiveLabel) {
        label.textAlignment = viewModel.setTextDirection(label.text)
    }
    
    private func setFont(of label: ActiveLabel) {
        label.font = viewModel.setFontStyleForText(label.text ?? .emptyString)
    }
    
    private func setTextHashTagAction(at label: ActiveLabel) {
        label.handleHashtagTap { hashTag in
            if let indexPath = self.indexPath {
                self.postHeaderInfoDelegate?.tappedHashTag(with: hashTag, at: indexPath)
            }
        }
    }
    
    private func setTextUrlAction(at label: ActiveLabel) {
        activeTextLabel.handleURLTap({ url in
            UIApplication.shared.open(url)
        })
    }
    
    private func visibilityRequestBtn(_ obj: FeedData, parentObj: FeedData) {
        let isFriendNotExist = (parentObj.isAuthorFriendOfViewer == Const.friendNotExist)
        viewModel.setRequestBtnLayout(frienRequestButton, addFriendImg: addFriendImage)
        if isFriendNotExist && parentObj.canIsendFriendRequest ?? false {
            viewModel.setRequestBtnLayout(frienRequestButton, addFriendImg: addFriendImage, isHide: false)
        }
    }
    
    private func setShowLessOrMore(obj: FeedData, parentObj: FeedData) {
        activeTextLabel.sizeToFit()
        showLessOrMoreDecision(obj, parentObj: parentObj)
        showMoreButton.isHidden = true
        if self.activeTextLabel.text?.count ?? 0 > 0 {
            if self.activeTextLabel.isTruncated || parentObj.isExpand {
                showMoreButton.isHidden = false
            }
        }
    }
    
    private func showLessOrMoreDecision(_ obj: FeedData, parentObj: FeedData) {
        showMoreButton.setTitle((parentObj.isExpand) ? Const.showLess.localized() : Const.showMore.localized(), for: .normal)
        showMoreButton.setImage(parentObj.isExpand ? .showLess : .showMore, for: .normal)
        activeTextLabel.numberOfLines = parentObj.isExpand ? 0 : 3
    }
    
    private func setOrignalButton(_ data: FeedData, _ parentData: FeedData)  {
        orignalButton?.setTitle(Const.viewTranslated.localized(), for: .selected)
        orignalButton?.isSelected = !(parentData.isTranslation)
        self.orignalButton?.isHidden = false
        if SharedManager.shared.getLang() == data.language?.languageName {
            self.orignalButton?.isHidden = true
        }
        if (data.language?.languageName != SharedManager.shared.getLang()) && parentData.language != nil {
            if let langName = data.language?.languageName as? String {
                activeTextLabel.rotateForTextAligment(languageMain: langName)
            }
        }
        // action
        setOrignalBtnAction(data, parentData)
    }
    
    private func setOrignalBtnAction(_ data: FeedData, _ parentData: FeedData) {
        orignalButton?.setTapClosure {[weak self] in
            guard let self else { return }
            orignalButton?.startLoading()
            orignalButton?.isSelected = !(orignalButton?.isSelected ?? false)
            let isNoOrignalBodyText = parentData.orignalBody == nil || parentData.orignalBody?.count == 0
            activeTextLabel.text = isNoOrignalBodyText ? Const.loading : (orignalButton?.isSelected ?? false) ? parentData.body : parentData.orignalBody
            if isNoOrignalBodyText {
                getTranslate(parentData, activeTextLabel, orignalButton)
            }
            data.isTranslation = !(orignalButton?.isSelected ?? false)
            if activeTextLabel.text != Const.loading {
                if let indexPath = indexPath {
                    orignalButton?.stopLoading()
                    postHeaderInfoDelegate?.tappedTranslation(with: parentData, at: indexPath)
                }
            }
            setTextAlignment(of: activeTextLabel)
            setFont(of: activeTextLabel)
        }
    }
    
    private func setSharedOrignalButton(_ data: FeedData, _ parentData: FeedData)  {
        sharedOrignalButton?.setTitle(Const.viewTranslated.localized(), for: .selected)
        sharedOrignalButton?.isSelected = !data.isSharedTranslation
        self.sharedOrignalButton.isHidden = false
        if data.language?.languageName == SharedManager.shared.getLang() {
            self.sharedOrignalButton.isHidden = true
        }
        if (data.language?.languageName != SharedManager.shared.getLang()) && data.language != nil {
            if let langName = data.language?.languageName as? String {
                sharedActiveTextLabel.rotateForTextAligment(languageMain: langName)
            }
        }
        // action
        setSharedOrignalBtnAction(data, parentData)
    }
    
    private func setSharedOrignalBtnAction(_ data: FeedData, _ parentData: FeedData) {
        sharedOrignalButton?.setTapClosure {[weak self] in
            guard let self else { return }
            sharedOrignalButton?.startLoading()
            sharedOrignalButton?.isSelected = !(sharedOrignalButton?.isSelected ?? false)
            let isNoOrignalBodyText = data.orignalBody == nil || data.orignalBody?.count == 0
            sharedActiveTextLabel.text = isNoOrignalBodyText ? Const.loading : (sharedOrignalButton?.isSelected ?? false) ? data.body : data.orignalBody
            if isNoOrignalBodyText {
                getTranslate(data, sharedActiveTextLabel, sharedOrignalButton)
            }
            data.isSharedTranslation = !(sharedOrignalButton?.isSelected ?? false)
            if sharedActiveTextLabel.text != Const.loading {
                if let indexPath = indexPath {
                    sharedOrignalButton?.stopLoading()
                    postHeaderInfoDelegate?.tappedTranslation(with: data, at: indexPath)
                }
            }
            setTextAlignment(of: sharedActiveTextLabel)
            setFont(of: sharedActiveTextLabel)
        }
    }
    
    /// Will help you to generate language translation
    /// - Parameters:
    ///   - obj: feed data object
    ///   - label: active label or shared active label
    ///   - button: orignal button and shared orignal button
    private func getTranslate(_ obj: FeedData, _ label: ActiveLabel, _ button: LoadingButton?) {
        viewModel.getTranslation(obj)
        viewModel.sendLanguageModel
            .sink {[weak self] langModel in
                guard let self else { return }
                button?.stopLoading()
                if langModel != nil {
                    let body = langModel?.data.first?.body
                    LogClass.debugLog("body ===> \(body)")
                    if isShared {
                        obj.orignalSharedBody = body
                    } else {
                        obj.orignalBody = body
                    }
                    label.text = (orignalButton?.isSelected ?? false) ? obj.body : (isShared ? obj.orignalSharedBody : obj.orignalBody)
                    setTextAlignment(of: label)
                    setFont(of: label)
                    if let indexPath = indexPath {
                        // reload cell
                        postHeaderInfoDelegate?.tappedTranslation(with: obj, at: indexPath)
                    }
                }
            }
            .store(in: &subscription)
    }
}
