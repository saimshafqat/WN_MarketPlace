//
//  IGStoryPreviewController.swift
//  InstagramStories
//
//  Created by Boominadha Prakash on 06/09/17.
//  Copyright © 2017 DrawRect. All rights reserved.
//

import UIKit
import FittedSheets
//import IQKeyboardManagerSwift
/**Road-Map: Story(CollectionView)->Cell(ScrollView(nImageViews:Snaps))
 If Story.Starts -> Snap.Index(Captured|StartsWith.0)
 While Snap.done->Next.snap(continues)->done
 then Story Completed
 */
final class IGStoryPreviewController: UIViewController, UIGestureRecognizerDelegate, ReactionDelegateResponse {
    
    func reactionResponse(feedObj: FeedData) {
    
        var cell = self._view.snapsCollectionView.visibleCells.first as? IGStoryPreviewCell
        cell?.likeView.lblcomments.text = feedObj.commentCount?.description
        cell?.likeView.modelObj.comments = feedObj.comments!
        cell?.likeView.modelObj.commentCount = feedObj.commentCount!.description
    }
    
    
    //MARK: - iVars
    var _view: IGStoryPreviewView {return view as! IGStoryPreviewView}
    private var viewModel: IGStoryPreviewModel?
    var navconContacts:UINavigationController?
    private(set) var stories: [FeedVideoModel]
    var sheetController = SheetViewController()
    /** This index will tell you which Story, user has picked*/
    private(set) var handPickedStoryIndex: Int //starts with(i)
    /** This index will help you simply iterate the story one by one*/
    var nStoryIndex: Int = 0 //iteration(i+1)
    private var story_copy: FeedVideoModel?
    private(set) var layoutType: IGLayoutType
    var storyReplyBottomConst: NSLayoutConstraint!
    let feedModel = FeedVideoModel.init()
    private let dismissGesture: UISwipeGestureRecognizer = {
        let gesture = UISwipeGestureRecognizer()
        gesture.direction = .down
        return gesture
    }()
    
    private(set) var executeOnce = false
    var loadStoriesBool = true
    
    //check whether device rotation is happening or not
    private(set) var isTransitioning = false
    weak var cellTemp:IGStoryPreviewCell?
   // weak var storyReplyView:StoryReplyView?
    var blackBtn = UIButton.init()
    var statusObj:IGSnap?
        
    var feedObj : FeedData!
    //MARK: - Overriden functions
    override func loadView() {
        super.loadView()
        view = IGStoryPreviewView.init(layoutType: self.layoutType)
        viewModel = IGStoryPreviewModel.init(self.stories, self.handPickedStoryIndex)
        _view.snapsCollectionView.decelerationRate = .fast
        dismissGesture.addTarget(self, action: #selector(didSwipeDown(_:)))
        _view.snapsCollectionView.addGestureRecognizer(dismissGesture)
     //   self.storyReplyView = Bundle.main.loadNibNamed("StoryReplyView", owner: nil, options: nil)?.first as? StoryReplyView
  //      self.view.insertSubview(self.storyReplyView!, aboveSubview: self._view.snapsCollectionView)
      //  self.storyReplyView?.replySendBtn.addTarget(self, action: #selector(replySendBtnClicked(sender:)), for: .touchUpInside)
    //    self.view.insertSubview(self.blackBtn, belowSubview: self.storyReplyView!)
     //   self.blackBtn.addTarget(self, action: #selector(blackBtnClicked(sender:)), for: .touchUpInside)
        
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
//        IQKeyboardManager.shared.enable = false
//        IQKeyboardManager.shared.enableAutoToolbar = false
        subscribeToShowKeyboardNotifications()
      //  self.manageStoryReplyView()
    //    SocketSharedManager.sharedSocket.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // AppUtility.lockOrientation(.portrait)
        // Or to rotate and lock
        if UIDevice.current.userInterfaceIdiom == .phone {
            IGAppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        }
        if !executeOnce {
            DispatchQueue.main.async {
                self._view.snapsCollectionView.delegate = self
                self._view.snapsCollectionView.dataSource = self
                let indexPath = IndexPath(item: self.handPickedStoryIndex, section: 0)
                
                if self.viewModel!.numberOfItemsInSection(indexPath.section) > 0 {
                    self._view.snapsCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
                    
                }
                self.handPickedStoryIndex = 0
                self.executeOnce = true
            }
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if UIDevice.current.userInterfaceIdiom == .phone {
            // Don't forget to reset when view is being removed
            IGAppUtility.lockOrientation(.all)
        }
        self.didTapCloseButton()
        if(cellTemp != nil){
        self.cellTemp?.stopPlayer()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        isTransitioning = true
        _view.snapsCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    init(layout:IGLayoutType = .cubic, stories: [FeedVideoModel], handPickedStoryIndex: Int) {
        self.layoutType = layout
        self.stories = stories
        self.handPickedStoryIndex = handPickedStoryIndex
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var prefersStatusBarHidden: Bool { return true }
    
    //MARK: - Selectors
    @objc func didSwipeDown(_ sender: Any) {

    }
    
    
    @objc func keyboardWillShow(_ notification: Notification) {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        let keyboardHeight = keyboardSize.cgRectValue.height
        
        let animationDuration = userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        UIView.animate(withDuration: animationDuration) { [self] in
        //    self.storyReplyBottomConst.constant = 1 - keyboardHeight
            self.view.layoutIfNeeded()
       //     self.storyReplyView?.isHidden = false
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        let userInfo = notification.userInfo
        let animationDuration = userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        UIView.animate(withDuration: animationDuration) {
     //       self.storyReplyBottomConst.constant = -10
            self.view.layoutIfNeeded()
    //        self.storyReplyView?.isHidden = true
        }
    }
    
    func subscribeToShowKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
//    func manageStoryReplyView() {
//        self.storyReplyView?.translatesAutoresizingMaskIntoConstraints = false
//        self.storyReplyView?.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0).isActive = true
//        self.storyReplyView?.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0).isActive = true
//        self.storyReplyBottomConst = self.storyReplyView?.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
//        self.storyReplyBottomConst.isActive = true
//        self.storyReplyView?.isHidden = true
//        self.blackBtn.isHidden = true
//        self.blackBtn.backgroundColor = UIColor.black.withAlphaComponent(0.50)
//        self.blackBtn.translatesAutoresizingMaskIntoConstraints = false
//        self.blackBtn.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0).isActive = true
//        self.blackBtn.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0).isActive = true
//        self.blackBtn.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
//        self.blackBtn.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0).isActive = true
//    }
}

//MARK:- Extension|UICollectionViewDataSource
extension IGStoryPreviewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let model = viewModel else {return 0}
        return model.numberOfItemsInSection(section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IGStoryPreviewCell.reuseIdentifier, for: indexPath) as? IGStoryPreviewCell else {
            fatalError()
        }
        
        let story = viewModel?.cellForItemAtIndexPath(indexPath)
        cell.viewParent = self
        if story?.postType == FeedType.Ad.rawValue {
            // Load PostAdsCollectionCell
            guard let adCell = collectionView.dequeueReusableCell(withReuseIdentifier: "FullScreenBannerAdCell", for: indexPath) as? FullScreenBannerAdCell else {
                fatalError()
            }
            adCell.displayCellContent(data: nil, parentData: nil, at: indexPath)
            return adCell
        } else {
            // Load IGStoryPreviewCell
            cell.story = story
            cell.setCustomViewValues(index: indexPath.row)
            cell.delegate = self
            nStoryIndex = indexPath.item
            cell.storyUserDelegate = self
            return cell
        }
    }

    
}

//MARK:- Extension|UICollectionViewDelegate
extension IGStoryPreviewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        guard let cell = cell as? IGStoryPreviewCell else {
            return
        }
        //Taking Previous(Visible) cell to store previous story
        let visibleCells = collectionView.visibleCells.sortedArrayByPosition()
        let visibleCell = visibleCells.first as? IGStoryPreviewCell
        if let vCell = visibleCell {
            vCell.story?.isCompletelyVisible = false
            vCell.pauseSnapProgressors(with: (vCell.story?.lastPlayedSnapIndex)!)
            story_copy = vCell.story
        }
        if indexPath.row == (self.viewModel?.stories!.count)! - 2
        {
//            if self.loadStoriesBool
//            {
            self.loadMoreStories()
       //     }
        }
        //Prepare the setup for first time story launch
        if story_copy == nil {
            cell.willDisplayCellForZerothIndex(with: cell.story?.lastPlayedSnapIndex ?? 0)
            return
        }
        if indexPath.item == nStoryIndex {
            let s = stories[nStoryIndex+handPickedStoryIndex]
            cell.willDisplayCell(with: s.lastPlayedSnapIndex)
           
        }
    }
    @objc func update()
    {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let visibleCells = collectionView.visibleCells.sortedArrayByPosition()
        let visibleCell = visibleCells.first as? IGStoryPreviewCell
        guard let vCell = visibleCell else {return}
        guard let vCellIndexPath = _view.snapsCollectionView.indexPath(for: vCell) else {
            return
        }
        vCell.story?.isCompletelyVisible = true
        
        if vCell.story == story_copy {
            nStoryIndex = vCellIndexPath.item
            vCell.resumePreviousSnapProgress(with: (vCell.story?.lastPlayedSnapIndex)!)
            if (vCell.story?.snaps[vCell.story?.lastPlayedSnapIndex ?? 0])?.postType == "video" {
                vCell.resumePlayer(with: vCell.story?.lastPlayedSnapIndex ?? 0)
            }
            if vCell.story?.postType == "video" {
                vCell.resumePlayer(with: vCell.story?.lastPlayedSnapIndex ?? 0)
            }
        }else {
            if let cell = cell as? IGStoryPreviewCell {
                cell.stopPlayer()
            }
            vCell.startProgressors()
        }
        if vCellIndexPath.item == nStoryIndex {
            vCell.didEndDisplayingCell()
        }
    }
}

//MARK:- Extension|UICollectionViewDelegateFlowLayout
extension IGStoryPreviewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        /* During device rotation, invalidateLayout gets call to make cell width and height proper.
         * InvalidateLayout methods call this UICollectionViewDelegateFlowLayout method, and the scrollView content offset moves to (0, 0). Which is not the expected result.
         * To keep the contentOffset to that same position adding the below code which will execute after 0.1 second because need time for collectionView adjusts its width and height.
         * Adjusting preview snap progressors width to Holder view width because when animation finished in portrait orientation, when we switch to landscape orientation, we have to update the progress view width for preview snap progressors also.
         * Also, adjusting progress view width to updated frame width when the progress view animation is executing.
         */
        if isTransitioning {
            let visibleCells = collectionView.visibleCells.sortedArrayByPosition()
            let visibleCell = visibleCells.first as? IGStoryPreviewCell
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) { [weak self] in
                guard let strongSelf = self,
                      let vCell = visibleCell,
                      let progressIndicatorView = vCell.getProgressIndicatorView(with: vCell.snapIndex),
                      let pv = vCell.getProgressView(with: vCell.snapIndex) else {
                    fatalError("Visible cell or progressIndicatorView or progressView is nil")
                }
                vCell.scrollview.setContentOffset(CGPoint(x: CGFloat(vCell.snapIndex) * collectionView.frame.width, y: 0), animated: false)
                vCell.adjustPreviousSnapProgressorsWidth(with: vCell.snapIndex)
                
                if pv.state == .running {
                    pv.widthConstraint?.constant = progressIndicatorView.frame.width
                }
                strongSelf.isTransitioning = false
            }
        }
        if #available(iOS 11.0, *) {
            return CGSize(width: _view.snapsCollectionView.safeAreaLayoutGuide.layoutFrame.width, height: _view.snapsCollectionView.safeAreaLayoutGuide.layoutFrame.height)
        } else {
            return CGSize(width: _view.snapsCollectionView.frame.width, height: _view.snapsCollectionView.frame.height)
        }
    }
}

//MARK:- Extension|UIScrollViewDelegate<CollectionView>
extension IGStoryPreviewController {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        guard let vCell = _view.snapsCollectionView.visibleCells.first as? IGStoryPreviewCell else {return}
        vCell.pauseSnapProgressors(with: (vCell.story?.lastPlayedSnapIndex)!)
        vCell.progressValue = 0.0
        if SharedManager.shared.updateSliderTimer != nil
        {
            SharedManager.shared.updateSliderTimer.invalidate()
            
        }
        vCell.pausePlayer(with: (vCell.story?.lastPlayedSnapIndex)!)
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let sortedVCells = _view.snapsCollectionView.visibleCells.sortedArrayByPosition()
        guard let f_Cell = sortedVCells.first as? IGStoryPreviewCell else {return}
        guard let l_Cell = sortedVCells.last as? IGStoryPreviewCell else {return}
        let f_IndexPath = _view.snapsCollectionView.indexPath(for: f_Cell)
        let l_IndexPath = _view.snapsCollectionView.indexPath(for: l_Cell)
        let numberOfItems = collectionView(_view.snapsCollectionView, numberOfItemsInSection: 0)-1
        if l_IndexPath?.item == 0 {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.2) {
//                self.dismiss(animated: true, completion: nil)
            }
        }else if f_IndexPath?.item == numberOfItems {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.2) {
//                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}

//MARK:- StoryPreview Protocol implementation
extension IGStoryPreviewController: StoryPreviewProtocol {
    
    func didToastStoryMessage(message:String) {
//        self.showToast(message: message)
    }
    
    func didForwardStory(storyID: String) {
//        DispatchQueue.main.async {
//            let contactsVC = self.chatStoryboard.instantiateViewController(withIdentifier: KalamContactsController.className) as! KalamContactsController
//            contactsVC.messageIDArray = [storyID]
//            contactsVC.isStory = true
//            self.navconContacts = UINavigationController.init(rootViewController: contactsVC)
//            self.present(self.navconContacts!, animated: true, completion: nil)
//        }
    }
    
    func didCompletePreview() {
        let n = handPickedStoryIndex+nStoryIndex+1
        if n < stories.count {
            //Move to next story
            story_copy = stories[nStoryIndex+handPickedStoryIndex]
            nStoryIndex = nStoryIndex + 1
            let nIndexPath = IndexPath.init(row: nStoryIndex, section: 0)
            //_view.snapsCollectionView.layer.speed = 0;
            _view.snapsCollectionView.scrollToItem(at: nIndexPath, at: .right, animated: true)
            /**@Note:
             Here we are navigating to next snap explictly, So we need to handle the isCompletelyVisible. With help of this Bool variable we are requesting snap. Otherwise cell wont get Image as well as the Progress move :P
             */
        }
//        else {
//            self.dismiss(animated: true, completion: nil)
//        }
    }
    
    func moveToPreviousStory() {
        //let n = handPickedStoryIndex+nStoryIndex+1
        let n = nStoryIndex+1
        if n <= stories.count && n > 1 {
            story_copy = stories[nStoryIndex+handPickedStoryIndex]
            story_copy?.lastPlayedSnapIndex = 0
            nStoryIndex = nStoryIndex - 1
            let nIndexPath = IndexPath.init(row: nStoryIndex, section: 0)
            _view.snapsCollectionView.scrollToItem(at: nIndexPath, at: .left, animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    func didTapCloseButton() {
        
        for indexObj in _view.snapsCollectionView.visibleCells {
            if let celltype  = indexObj as? IGStoryPreviewCell{

                self.cellTemp?.pauseEntireSnap()
                celltype.stopPlayer()
            }
        }
        
        self.dismiss(animated: true, completion:nil)
    }
    
    func showReportSheet(feedObj : FeedData){
        let reportController = AppStoryboard.TabBar.instance.instantiateViewController(withIdentifier: "ReportingViewController") as! ReportingViewController
        reportController.currentIndex = IndexPath.init(row: 0, section: 0)
        reportController.feedObj = feedObj
        self.feedObj = feedObj
        reportController.reportType = "Story"
        self.sheetController = SheetViewController(controller: reportController, sizes: [.fixed(350)])
        self.sheetController.overlayColor = UIColor.black.withAlphaComponent(0.3)
        self.sheetController.extendBackgroundBehindHandle = true
        reportController.delegate = self
        for indexObj in _view.snapsCollectionView.visibleCells {
            if let celltype  = indexObj as? IGStoryPreviewCell{

                self.cellTemp?.pauseEntireSnap()
                celltype.stopPlayer()
            }
        }
        
        
        self.sheetController.topCornersRadius = 20
        self.present(self.sheetController, animated: false, completion: nil)
    }
    
    func likeButtonTapped(feedObj: FeedData, dismisscompletion: (() -> Void)?) {
        let pagerController = AppStoryboard.TabBar.instance.instantiateViewController(withIdentifier: "WNPagerViewController") as! WNPagerViewController
                self.sheetController = SheetViewController(controller: pagerController, sizes: [.fixed(400), .fixed(250), .fullScreen])
        pagerController.feedObj = feedObj
        pagerController.parentView = UIApplication.topViewController()
        self.sheetController.overlayColor = UIColor.black.withAlphaComponent(0.3)
        self.sheetController.extendBackgroundBehindHandle = true
        self.sheetController.topCornersRadius = 20
        self.sheetController.willDismiss = { _ in
            // This is called after the sheet is dismissed
            dismisscompletion?()
        }
        self.present(self.sheetController, animated: false, completion: nil)
    }
    
    func commentButtonTapped(feedObj : FeedData, dismisscompletion: (()->Void)? = nil) {
        let pagerController = AppStoryboard.Comment.instance.instantiateViewController(withIdentifier: "CommentTableViewController") as! CommentTableViewController
                self.sheetController = SheetViewController(controller: pagerController, sizes: [.fixed(400), .fixed(250), .fullScreen])
        pagerController.feedObj = feedObj
        pagerController.delegateReaction = self
        self.sheetController.overlayColor = UIColor.black.withAlphaComponent(0.3)
        self.sheetController.extendBackgroundBehindHandle = true
        self.sheetController.topCornersRadius = 20
        self.sheetController.willDismiss = { _ in
            // This is called after the sheet is dismissed
            dismisscompletion?()
        }
        self.present(self.sheetController, animated: false, completion: nil)
    }
    func downloadfeed(feedObj : StoryObject, dismisscompletion: (()->Void)? = nil){
        if feedObj.postType == FeedType.image.rawValue {
            self.downloadFile(filePath: feedObj.videoUrl, isImage: true, isShare: true, FeedObj: FeedData.init(valueDict: [String : Any]())) {
                dismisscompletion?()
            }
            
        }else if feedObj.postType == FeedType.video.rawValue {
            self.downloadFile(filePath: feedObj.videoUrl, isImage: false, isShare: true , FeedObj: FeedData.init(valueDict: [String : Any]())) {
                dismisscompletion?()
            }
        }
        else if feedObj.postType == "post" {
            self.showShareActivity(msg: feedObj.body, sourceRect: nil) {
                dismisscompletion?()
            }
        }
    }
    func showShareActivity(msg:String? , sourceRect: CGRect?, dismisscompletion: (()->Void)? = nil){
        var objectsToShare = [Any]()
        if let msg = msg {
            objectsToShare.append(msg)
        }
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        activityVC.modalPresentationStyle = .popover
        activityVC.popoverPresentationController?.sourceView = self.view
        activityVC.excludedActivityTypes = [
            UIActivity.ActivityType.airDrop,
            UIActivity.ActivityType.print,
            UIActivity.ActivityType.saveToCameraRoll,
            UIActivity.ActivityType.addToReadingList
        ]
        if let sourceRect = sourceRect {
            activityVC.popoverPresentationController?.sourceRect = sourceRect
        }
        activityVC.completionWithItemsHandler = { (activityType, completed:Bool, returnedItems:[Any]?, error: Error?) in
            dismisscompletion?()
         }
        self.present(activityVC, animated: true, completion: nil)
    }
}


extension IGStoryPreviewController : DismissReportSheetDelegate {
    func dimissReportSheetClicked(type:String, currentIndex:IndexPath) {
        LogClass.debugLog("dimissReportSheetClicked ===>")
        LogClass.debugLog(type)
    }
    func dimissReportSheetForCommentsClicked(type:String, currentIndex:IndexPath, isReply:Bool) {
        LogClass.debugLog("dimissReportSheetForCommentsClicked ===>")
        LogClass.debugLog(type)
        
        if type == "Report" {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.showReportDetailSheet(isPost: false, currentIndex: currentIndex)
            }
        }else if type == "Rate" {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let reportDetail = AppStoryboard.StoryModule.instance.instantiateViewController(withIdentifier: "ReelsFeedBackVC") as! ReelsFeedBackVC
                self.sheetController = SheetViewController(controller: reportDetail, sizes: [.halfScreen])
                self.sheetController.overlayColor = UIColor.black.withAlphaComponent(0.3)
                self.sheetController.extendBackgroundBehindHandle = true
                self.sheetController.topCornersRadius = 20
                reportDetail.feedObj = self.feedObj
                reportDetail.delegate = self
                self.present(self.sheetController, animated: true, completion: nil)
            }
        }
        
        
    }
    func dismissReportWithMessage(message:String) {
        LogClass.debugLog("dismissReportWithMessage ===>")
        LogClass.debugLog(message)
    }
    func dismissUnSavedWith(msg: String, indexPath: IndexPath) {
        LogClass.debugLog("dismissUnSavedWith ===>")
        LogClass.debugLog(msg)
    }
    
    func showReportDetailSheet(isPost:Bool = false, currentIndex:IndexPath){
        let reportDetail = AppStoryboard.TabBar.instance.instantiateViewController(withIdentifier: "ReportDetailController") as! ReportDetailController
//        reportDetail.isPost = ReportType.Post
        reportDetail.isPost = ReportType.Story
        reportDetail.delegate = self
        self.sheetController = SheetViewController(controller: reportDetail, sizes: [.fullScreen])
        self.sheetController.overlayColor = UIColor.black.withAlphaComponent(0.3)
        self.sheetController.extendBackgroundBehindHandle = true
        self.sheetController.topCornersRadius = 20
        reportDetail.feedObj = self.feedObj
        self.present(self.sheetController, animated: true, completion: nil)
    }
}

extension IGStoryPreviewController: DismissReportDetailSheetDelegate {
    func dismissReport(message:String) {
        self.sheetController.closeSheet()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            SharedManager.shared.showAlert(message: message, view: self)
        }
    }
}


extension IGStoryPreviewController: StoryCellDelegate, StoryViewsControllerDelegate {
    
    func userViewBtnDelegate(storyID:Int, cell:IGStoryPreviewCell) {

    }

    
    func dismissUserViewDelegate() {
        self.cellTemp?.resumeEntireSnap()
    }
    
    func loadMoreStories() {
        var param = ["action": "stories/stories_for_all_users",
                     "token": SharedManager.shared.userToken()]
        param["starting_point_id"] = self.viewModel?.stories?.last?.videoID
        self.callingStoriesService(action: "stories/stories_for_all_users", param: param)
    }
    
    func callingStoriesService(action:String, param:[String:String]){
        RequestManager.fetchDataPost(Completion: { [self] response in
            switch response {
            
            case .failure(let error):
                if error is String {
                }
            case .success(let res):
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                }else if res is String {
                    
                }else {
                    
                    if action == "stories" {
                        let arr = res as! [[String : Any]]
                        if arr.count == 0 {
                            
                        }else {
                           // self.loadStoriesBool = false
                            var feedVideoObj:[FeedVideoModel] = self.feedModel.getVideoModelArray(arr:arr)
                            
                            FeedCallBManager.shared.videoClipArray.append(contentsOf: feedVideoObj)
                           
                            self.stories.append(contentsOf: feedVideoObj)
                            self.viewModel?.stories?.append(contentsOf: feedVideoObj)
                            
                          
                            self._view.snapsCollectionView.reloadData()
                        }
                    }
                    else if (action == "stories/stories_for_all_users") {
                        let arr = res as! [[String : Any]]
                        if arr.count == 0 {
                            
                        }else {
                           // self.loadStoriesBool = false
                            var feedVideoObj:[FeedVideoModel] = self.feedModel.getVideoModelArray(arr:arr)
                            
                            FeedCallBManager.shared.videoClipArray.append(contentsOf: feedVideoObj)
                            feedVideoObj.enumerated().forEach { index, _ in
                                 if (index + 1) % 10 == 0 {
                                     let mainData = [String: Any]()
                                     let newFeed = FeedVideoModel(dict: mainData)
                                     newFeed.postType = FeedType.Ad.rawValue
                                     feedVideoObj.insert(newFeed, at: index + 1)
                                     // Add the index path for the ad feed
                                 }
                             }
                            self.viewModel?.stories?.append(contentsOf: feedVideoObj)
                            self.stories.append(contentsOf: feedVideoObj)
                          
                            self._view.snapsCollectionView.reloadData()
                        }
                    }
                }
            }
        }, param:param)
    }
}

extension IGStoryPreviewController:SocketDelegate {
    func didReceiveForwardMessageAck(data: Any) {
        self.navconContacts!.dismiss(animated: true, completion: nil)
    }
}
