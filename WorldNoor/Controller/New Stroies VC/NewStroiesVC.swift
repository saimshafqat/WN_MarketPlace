//
//  NewStroiesVC.swift
//  WorldNoor
//
//  Created by apple on 5/19/22.
//  Copyright © 2022 Raza najam. All rights reserved.
//


import UIKit
import FittedSheets
import Photos
import Alamofire

class NewStroiesVC: UIViewController {
    var collectionArray:[PostFile] = []
    var feedObj:FeedData?
    var movedIndexpath:Int? = 0
    public var minimumVelocityToHide = 1500 as CGFloat
    public var minimumScreenRatioToHide = 0.3 as CGFloat
    public var animationDuration = 0.5 as TimeInterval
    private lazy var transitionDelegate: TransitionDelegate = TransitionDelegate()
    @IBOutlet weak var galleryCollectionView: UICollectionView!
    var isPan = true
    var currentIndex = IndexPath(row: 0, section: 0)
    var sheetController = SheetViewController()
    
    @IBOutlet var viewInfo: UIView!
    var isInfoViewShow = false
    var CurrentpageNumber = 0
    var isFromStories = false
    @IBOutlet var lblCount : UILabel!
    var isPageLoad = true
    var cellArray = [Any]()
    var startingPoint = ""
    var isNextVideoExist = true
    var isViewDisapper = false
    
    
    @IBOutlet var lblHeadingUserName : UILabel!
    @IBOutlet var lblHeadingDate : UILabel!
    @IBOutlet var lblHeadingSharedTitle : UILabel!
    @IBOutlet var imgViewHEadingUser : UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lblCount.text = ""
        let nibName = UINib(nibName: "NewGalleryImageCell", bundle:nil)
        self.galleryCollectionView.register(nibName, forCellWithReuseIdentifier: "NewGalleryImageCell")
        self.testingPanGesture()
        
        NotificationCenter.default.addObserver(self,selector: #selector(nextVideo),name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,object: nil)
        
        
    }
    
    @objc func nextVideo(){
        self.rightAction(sender: UIButton.init())
    }
    override func viewWillAppear(_ animated: Bool) {
        
        
        
        self.viewInfo.isHidden = self.isInfoViewShow
        if self.isPageLoad {
            self.CurrentpageNumber = 0
            SharedManager.shared.currentIndex = IndexPath.init(row: self.CurrentpageNumber, section: 0)
            self.lblCount.text = "1/" + String(self.collectionArray.count)
            self.lblCount.isHidden = self.isFromStories
        }
        
        self.reloadHeader()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        if self.isFromStories {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadTableWithNewdata"), object: nil,userInfo: nil)
        }
        SharedManager.shared.timerMain = nil
        self.isViewDisapper = true
        self.stopAudio()
    }
    override func viewDidAppear(_ animated: Bool) {
        if self.isPageLoad {
            self.stopAudio()

            if isPan {
                self.CurrentpageNumber = self.movedIndexpath!
                SharedManager.shared.currentIndex = IndexPath.init(row: self.CurrentpageNumber, section: 0)
                self.galleryCollectionView.scrollToItem(at: IndexPath.init(row: movedIndexpath!, section: 0), at: .left, animated: false)
                self.lblCount.text = String(self.CurrentpageNumber + 1) + "/" + String(self.collectionArray.count)
            }
            
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(4000) , execute: {

                
                if !self.isViewDisapper {
                    self.ResetVideo(pageNumberP: self.CurrentpageNumber)
                }
                
                

            })
        }
        isPageLoad = false
    }
    
    
    func reloadHeader(){

        self.imgViewHEadingUser.loadImageWithPH(urlMain: self.feedObj!.profileImage!)
        self.lblHeadingDate.text = self.feedObj!.postedTime
        self.lblHeadingUserName.text = self.feedObj!.authorName
        self.managePostTitleLabel()
    }
    
    func managePostTitleLabel(){
        if self.feedObj!.postType == FeedType.shared.rawValue {
            
            
            self.lblHeadingSharedTitle.text = "shared".localized()
            if SharedManager.shared.getUserID() == self.feedObj?.sharedData?.authorID {
                self.lblHeadingSharedTitle.text = "his".localized() + " " + self.feedObj!.sharedData!.postType!
            }else {
                self.lblHeadingSharedTitle.text = "post of".localized() + " " + self.feedObj!.sharedData!.authorName!
            }
        }else {
            
            self.lblHeadingSharedTitle.text = "shared a".localized() + " " + self.feedObj!.postType!.localized()
        }
    }
   
    
    
    
    
    @IBAction func shareAction(sender : UIButton){
        self.downloadfeed(isShare: true)
        
    }
    
    func testingPanGesture(){
        self.transitioningDelegate = self.transitionDelegate
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(onPan(_:)))
        self.view.addGestureRecognizer(panGesture)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)   {
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .overFullScreen;
        self.modalTransitionStyle = .coverVertical;
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.modalPresentationStyle = .overFullScreen;
        self.modalTransitionStyle = .coverVertical;
    }
    
    
    @IBAction func saveAction(sender : UIButton){
        self.downloadfeed(isShare: false)
    }
    
    
    func downloadfeed(isShare : Bool){
        
        if self.feedObj?.isLive == 1{
            return
        }
        
        if self.collectionArray[self.CurrentpageNumber].fileType == FeedType.image.rawValue {
            self.downloadFile(filePath: (self.collectionArray[self.CurrentpageNumber].filePath!), isImage: true, isShare: isShare , FeedObj: feedObj!)
        }else {
            self.downloadFile(filePath: (self.collectionArray[self.CurrentpageNumber].filePath!), isImage: false, isShare: isShare ,FeedObj: feedObj!)
        }
    }
    
    @objc func onPan(_ panGesture: UIPanGestureRecognizer) {
        self.isPan = false
        let translation = panGesture.translation(in: self.view)
        let verticalMovement = translation.y / self.view.bounds.height
        let downwardMovement = fmaxf(Float(verticalMovement), 0.0)
        
        let downwardMovementPercent = fminf(downwardMovement, 1.0)
        let progress = CGFloat(downwardMovementPercent)
        
        let velocity = panGesture.velocity(in: self.view)
        let shouldFinish = progress > self.minimumScreenRatioToHide || velocity.y > self.minimumVelocityToHide
        
        
        switch panGesture.state {
        case .began:
            self.transitionDelegate.interactiveTransition.hasStarted = true
            self.stopAudio()
            self.dismiss(animated: true, completion: nil)
        case .changed:
            self.view.backgroundColor = UIColor.black.withAlphaComponent((1 - progress))
            self.transitionDelegate.interactiveTransition.shouldFinish = shouldFinish
            self.transitionDelegate.interactiveTransition.update(progress)
        case .cancelled:
            self.view.backgroundColor = UIColor.black.withAlphaComponent(1)
            self.transitionDelegate.interactiveTransition.hasStarted = false
            self.transitionDelegate.interactiveTransition.cancel()
        case .ended:
            self.transitionDelegate.interactiveTransition.hasStarted = false
            if self.transitionDelegate.interactiveTransition.shouldFinish {
                self.transitionDelegate.interactiveTransition.finish()
            }else {
                self.view.backgroundColor = UIColor.black.withAlphaComponent(1)
                self.transitionDelegate.interactiveTransition.cancel()
            }
        default:
            break
        }
    }
    
    @IBAction func doneBtnPressed(_ sender: Any)
    {
        self.stopAudio()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func rightAction(sender : UIButton){
        if self.CurrentpageNumber < self.collectionArray.count - 1 {
            self.CurrentpageNumber = self.CurrentpageNumber + 1
            
            SharedManager.shared.currentIndex = IndexPath.init(row: self.CurrentpageNumber, section: 0)
            
            self.galleryCollectionView.scrollToItem(at: IndexPath.init(row: self.CurrentpageNumber , section: 0), at: .centeredHorizontally, animated: true)
            
            self.lblCount.text = String(self.CurrentpageNumber + 1) + "/" + String(self.collectionArray.count)
            self.stopAudio()
            SharedManager.shared.arrayVideoURL.removeAll()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(100) , execute: {
                self.ResetVideo(pageNumberP: self.CurrentpageNumber)
                self.reloadHeader()
            })
            
            if self.isFromStories {
                self.isFeedReachEnd(indexPath: IndexPath.init(row: self.CurrentpageNumber, section: 0))
            }
            
        }
        
        
    }
    
    @IBAction func leftAction(sender : UIButton){
        if self.CurrentpageNumber > 0 {
            self.CurrentpageNumber = self.CurrentpageNumber - 1
            
            SharedManager.shared.currentIndex = IndexPath.init(row: self.CurrentpageNumber, section: 0)
            
            
            self.galleryCollectionView.scrollToItem(at: IndexPath.init(row: self.CurrentpageNumber , section: 0), at: .centeredHorizontally, animated: true)
            
            self.lblCount.text = String(self.CurrentpageNumber + 1) + "/" + String(self.collectionArray.count)
            self.stopAudio()
            SharedManager.shared.arrayVideoURL.removeAll()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(100) , execute: {
                self.ResetVideo(pageNumberP: self.CurrentpageNumber)
                self.reloadHeader()
            })
        }
        
    }
}

extension NewStroiesVC:UICollectionViewDataSource, UICollectionViewDelegate , UICollectionViewDelegateFlowLayout
{
    func resetCollectionCell(){
        self.collectionArray.removeAll()
        self.cellArray.removeAll()
        self.galleryCollectionView.reloadData()
        
        self.lblCount.text = "1/" + String(self.collectionArray.count)
        self.reloadHeader()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        if self.collectionArray.count > 0 {
            return self.collectionArray.count
        }
        return 0
    }
    
    

    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        

        if(self.collectionArray[indexPath.row].fileType == FeedType.image.rawValue)
        {
            
            guard let cellimage = collectionView.dequeueReusableCell(withReuseIdentifier: "NewGalleryImageCell", for: indexPath) as? NewGalleryImageCell else {
                return UICollectionViewCell()
            }
            
            cellimage.imageMain.loadImageWithPH(urlMain:self.collectionArray[indexPath.row].filePath ?? "")
            if SharedManager.shared.checkLanguageAlignment() {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(10) , execute: {
                    cellimage.scrollView.zoomScale = 1.01
                })
            }
            
            self.view.labelRotateCell(viewMain: cellimage.imageMain)
            self.cellArray.append(cellimage)
            return cellimage
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Const.KFullGalleryCollectionCell, for: indexPath) as! FullGalleryCollectionCell


            cell.managePostData(postObj:self.collectionArray[indexPath.row], mainIndex:self.currentIndex, currentIndex:indexPath)

        
        self.cellArray.append(cell)
        return cell
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
        self.CurrentpageNumber = pageNumber
        
        SharedManager.shared.currentIndex = IndexPath.init(row: self.CurrentpageNumber, section: 0)
        
        
        self.lblCount.text = String(pageNumber + 1)
        self.lblCount.text = self.lblCount.text! + "/" + String(self.collectionArray.count)
        self.stopAudio()
        SharedManager.shared.arrayVideoURL.removeAll()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(10) , execute: {
            
            self.ResetVideo(pageNumberP: pageNumber)
            self.reloadHeader()
            if self.isFromStories {
                self.isFeedReachEnd(indexPath: IndexPath.init(row: self.CurrentpageNumber, section: 0))
            }
        })
    }
    
    
    func ResetVideo(pageNumberP : Int ){
        self.stopAudio()

        if(self.collectionArray[pageNumberP].fileType == FeedType.video.rawValue) {
            if let cellVideo = galleryCollectionView.cellForItem(at: IndexPath.init(row: pageNumberP, section: 0)) as? FullGalleryCollectionCell
            {

            }
        }
    }
    
    func stopAudio(){
        
        for indexObj in self.cellArray {
            
            if let cellGallery = indexObj as? FullGalleryCollectionCell {
                
                
                if cellGallery.audioView?.xqAudioPlayer.audioPlayer != nil {
                    cellGallery.audioView?.xqAudioPlayer.audioPlayer!.rate = 0.0
                    cellGallery.audioView?.xqAudioPlayer.audioPlayer!.pause()
                }
  
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenSize: CGRect = UIScreen.main.bounds
        if UIDevice.current.userInterfaceIdiom == .pad
        {
            return CGSize(width: screenSize.width, height: collectionView.frame.size.height)
        }
        return CGSize(width: screenSize.width, height: screenSize.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell,forItemAt indexPath: IndexPath)    {
        if let postCell = cell as? GalleryCollectionCell {
            postCell.stopPlayingVideo()
            postCell.stopPlayingAudio()
        }
    }
}


//MARK:- Stories API
extension NewStroiesVC {
    
    func isFeedReachEnd(indexPath:IndexPath){
        if  self.isNextVideoExist {
            let feedCurrentCount = self.collectionArray.count
            if indexPath.row == feedCurrentCount-3 {
                let videoObj = self.collectionArray[indexPath.row]
                self.startingPoint = String(videoObj.postID!)
                
                    self.callAPIForNExt()
            }
        }
    }
    
    func callAPIForNExt(){
        var param = ["action": "stories/search",
                     "token": SharedManager.shared.userToken(),
                     "filters[section_type]":"all_stories"]
        if startingPoint != "" {
            param["starting_point_id"] = self.startingPoint
        }
        self.callingGetService(action: "storiesList", param: param)
    }
    
    func callingGetService(action:String, param:[String:String]){
        RequestManager.fetchDataGet(Completion: { response in
            switch response {
            case .failure(let error):
                if error is String {
                }
            case .success(let res):
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                }else if res is String {
                    self.isNextVideoExist = false
                }else {
                    
                    let arr =  res as! [[String : Any]]
                    if arr.count == 0 {
                        self.isNextVideoExist = false
                    }else {
                        let feedVideoObj:[FeedVideoModel] = self.getVideoModelArray(arr:arr)
                        FeedCallBManager.shared.videoClipArray.append(contentsOf: feedVideoObj)
                        
                        var indexArray = [IndexPath]()
                        
                        for indexObj in feedVideoObj {
                            let newPostfile = PostFile.init()
                            newPostfile.fileType = FeedType.video.rawValue
                            newPostfile.filePath = indexObj.videoUrl
                            newPostfile.postID = Int(indexObj.videoID)
                            self.collectionArray.append( newPostfile)
                            indexArray.append(IndexPath.init(row: self.collectionArray.count - 1, section: 0))
                        }
                        
                        self.galleryCollectionView.insertItems(at: indexArray)
                        //                            self.galleryCollectionView.reloadData()
                    }
                }
            }
        }, param:param)
    }
    
    func getVideoModelArray(arr:[[String:Any]])->[FeedVideoModel] {
        var videoArray:[FeedVideoModel] = [FeedVideoModel]()
        for dict in arr {
            let videoModel = FeedVideoModel.init(dict: dict)
            videoArray.append(videoModel)
        }
        return videoArray
    }
}



