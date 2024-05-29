//
//  GalleryCell.swift
//  WorldNoor
//
//  Created by Raza najam on 11/16/19.
//  Copyright © 2019 Raza najam. All rights reserved.
//

import UIKit

class GalleryCell: FeedParentCell {
    
//    @IBOutlet weak var collectionPageControl: UIPageControl!
    @IBOutlet weak var galleryCollectionView: UICollectionView!
    
    @IBOutlet weak var collectionViewBottom: UICollectionView!
    
    
    @IBOutlet weak var viewTwo: UIView!
    @IBOutlet weak var viewThree: UIView!
    @IBOutlet weak var viewFour: UIView!
    
    
    @IBOutlet weak var viewTwoFirst: GalleryCollectionCellView!
    @IBOutlet weak var viewTwoSecond: GalleryCollectionCellView!
    
    @IBOutlet weak var viewThirdFirst: GalleryCollectionCellView!
    @IBOutlet weak var viewThirdSecond: GalleryCollectionCellView!
    @IBOutlet weak var viewThirdThird: GalleryCollectionCellView!
    
    @IBOutlet weak var viewFourFirst: GalleryCollectionCellView!
    @IBOutlet weak var viewFourSecond: GalleryCollectionCellView!
    @IBOutlet weak var viewFourThird: GalleryCollectionCellView!
    @IBOutlet weak var viewFourFour: GalleryCollectionCellView!
    
    @IBOutlet weak var viewFourMore: UIView!
    @IBOutlet weak var lblCount: UILabel!
    
    
    @IBOutlet weak var topBar: UIView!
    @IBOutlet weak var commentView: UIView!
    @IBOutlet weak var bgView: DesignableView!
    @IBOutlet weak var collectionBgView: UIView!
    
    var isAppearFrom = ""
    var currentIndexPath = IndexPath()
    var feedDataObj:FeedData? = nil
    var isFromFeed = false
    
    var leftMargin : CGFloat = 0.0
    var rightMargin : CGFloat  = 0.0
    
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        textChanged = nil
        likeDislikeUpdated = nil
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        // do your thing
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.manageCollectionCell()
        self.commentViewRef = self.getCommentView()
        self.headerViewRef = self.getHeaderView()
//        self.commentViewRef.commentTextView.delegate = self
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    @IBAction func pageChanged(_ sender: Any) {
//        let page = collectionPageControl.currentPage
//        var frame = self.galleryCollectionView.frame
//        frame.origin.x = frame.size.width * CGFloat(page)
//        frame.origin.y = 0
//        self.galleryCollectionView.scrollRectToVisible(frame, animated: true)
//        self.collectionPageControl.currentPage = page
        
//        self.reloadPagecontroller()
    }
    
    
    
    func manageCollectionCell(){
        
        self.collectionViewBottom.register(UINib.init(nibName: "BottomCollectionCell", bundle: nil), forCellWithReuseIdentifier: "BottomCollectionCell")

        
        
        let nibName = UINib(nibName: Const.KGalleryCollectionCell, bundle:nil)
        self.galleryCollectionView.register(nibName, forCellWithReuseIdentifier: Const.KGalleryCollectionCell)
    }
    
    //Manage Feed Data inside cell...
    func manageCellData(feedObj:FeedData, indexValue:IndexPath, reloadClosure: ((IndexPath)->())?, didSelect:((IndexPath)->())?) {
        if self.commentViewRef != nil {
            self.updateTableClosure = reloadClosure
            self.headerViewRef.removeFromSuperview()
            self.commentViewRef.removeFromSuperview()
        }
        self.currentIndexPath = indexValue
        self.commentViewRef.currentIndex = indexValue
        self.topBar.addSubview(self.headerViewRef)
        self.topBar.sizeToFit()
        self.commentView.addSubview(self.commentViewRef)
        self.indexValue = indexValue
        self.manageHeaderFooter(feedObj: feedObj)
        self.manageCallbackhandler()
        self.headerViewRef.indexValue = indexValue
        self.headerViewRef.postSelected = didSelect
        self.commentViewRef.commentButtonHandler = didSelect
        self.headerViewRef.updateSingleRow = reloadClosure

        self.feedDataObj = feedObj
        
        
        self.viewTwo.isHidden = true
        self.viewThree.isHidden = true
        self.viewFour.isHidden = true
        
        if self.feedDataObj!.post!.count == 2 {
            self.viewTwo.isHidden = false
            self.viewTwoFirst.managePostData(postObj: self.feedDataObj!.post![0], mainIndex: IndexPath.init(row: 0, section: 0), currentIndex: IndexPath.init(row: 0, section: 0), isAppearFrom: self.isAppearFrom)
            
            
            self.viewTwoSecond.managePostData(postObj: self.feedDataObj!.post![1], mainIndex: IndexPath.init(row: 1, section: 0), currentIndex: IndexPath.init(row: 1, section: 0), isAppearFrom: self.isAppearFrom)
            
            
        }else if self.feedDataObj!.post!.count == 3 {
            self.viewThree.isHidden = false
            
            self.viewThirdFirst.managePostData(postObj: self.feedDataObj!.post![0], mainIndex: IndexPath.init(row: 0, section: 0), currentIndex: IndexPath.init(row: 0, section: 0), isAppearFrom: self.isAppearFrom)
            
            
            self.viewThirdSecond.managePostData(postObj: self.feedDataObj!.post![1], mainIndex: IndexPath.init(row: 1, section: 0), currentIndex: IndexPath.init(row: 1, section: 0), isAppearFrom: self.isAppearFrom)
            
            self.viewThirdThird.managePostData(postObj: self.feedDataObj!.post![2], mainIndex: IndexPath.init(row: 2, section: 0), currentIndex: IndexPath.init(row: 2, section: 0), isAppearFrom: self.isAppearFrom)
            
            
        }else {
            self.viewFour.isHidden = false
            
            
            self.viewFourFirst.managePostData(postObj: self.feedDataObj!.post![0], mainIndex: IndexPath.init(row: 0, section: 0), currentIndex: IndexPath.init(row: 0, section: 0), isAppearFrom: self.isAppearFrom)
            
            
            self.viewFourSecond.managePostData(postObj: self.feedDataObj!.post![1], mainIndex: IndexPath.init(row: 1, section: 0), currentIndex: IndexPath.init(row: 1, section: 0), isAppearFrom: self.isAppearFrom)
            
            self.viewFourThird.managePostData(postObj: self.feedDataObj!.post![2], mainIndex: IndexPath.init(row: 2, section: 0), currentIndex: IndexPath.init(row: 2, section: 0), isAppearFrom: self.isAppearFrom)
            
            self.viewFourMore.isHidden = true
            self.viewFourFour.isHidden = false
            self.viewFourMore.backgroundColor = UIColor.clear
            if self.feedDataObj!.post!.count == 4 {
                self.viewFourFour.managePostData(postObj: self.feedDataObj!.post![3], mainIndex: IndexPath.init(row: 3, section: 0), currentIndex: IndexPath.init(row: 3, section: 0), isAppearFrom: self.isAppearFrom)
            }else {
                
                if self.feedDataObj!.post![3].fileType == FeedType.image.rawValue {
                    self.viewFourFour.isHidden = false
                    self.viewFourFour.managePostData(postObj: self.feedDataObj!.post![3], mainIndex: IndexPath.init(row: 3, section: 0), currentIndex: IndexPath.init(row: 3, section: 0), isAppearFrom: self.isAppearFrom)
                    
                    self.lblCount.text = String(self.feedDataObj!.post!.count - 4) + " +"
                    
                    self.viewFourMore.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.5)
                    self.bringSubviewToFront(self.viewFourMore)


                }else {
                    self.viewFourFour.isHidden = true
                    self.viewFourMore.backgroundColor = UIColor.lightGray
                    self.lblCount.text = String(self.feedDataObj!.post!.count - 3) + " +"

                }
                
                
                self.viewFourMore.isHidden = false
            }
            
            
        }
        
        
        self.galleryCollectionView.isHidden = true
    }
    
    
    @IBAction func openImage(sender : UIButton){
        FeedCallBManager.shared.galleryCellIndexCallbackHandler?(self.currentIndexPath, IndexPath.init(row: sender.tag, section: 0), false)
    }
    
    
//    func firstViewReload(viewMain : UIView , postObj : PostFile ){
//        if postObj.fileType == FeedType.image.rawValue {
//            self.addImageView()
//            self.videoView?.removeFromSuperview()
//            self.audioView?.removeFromSuperview()
//        }else if postObj.fileType == FeedType.video.rawValue {
//            self.singleImageView?.removeFromSuperview()
//            self.audioView?.removeFromSuperview()
//            self.addVideoView()
//        }else if postObj.fileType == FeedType.audio.rawValue {
//            self.singleImageView?.removeFromSuperview()
//            self.videoView?.removeFromSuperview()
//            self.addAudioView()
//        }else if postObj.fileType == FeedType.file.rawValue {
//            self.addImageView()
//            self.videoView?.removeFromSuperview()
//            self.audioView?.removeFromSuperview()
//        }
//    }
    func pageControlMainThread(){
        self.loadEdge()
        self.collectionViewBottom.reloadData()
//        self.collectionPageControl.currentPage = 0
//        self.reloadPagecontroller()
    }
    
    func manageHeaderFooter(feedObj:FeedData) {
        self.headerViewRef.manageHeaderData(feedObj: feedObj)
        self.commentViewRef.manageMyView(feedObj: feedObj)

        self.commentView.frame.size.height = 110
        self.commentViewRef.frame.size.height = 110
    }
    
    @objc func micButtonClicked(sender:UIButton)    {
    }
}

extension GalleryCell:UITextViewDelegate   {
    // text change callback handler inside vm...
    func textChanged(action: @escaping (String) -> Void) {
        self.textChanged = action
    }
    
    func textViewDidChange(_ textView: UITextView){
        let fixedWidth = textView.frame.size.width
        textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        var newFrame = textView.frame
        newFrame.size = CGSize(width: max(fixedWidth, fixedWidth), height: newSize.height)
//        if newFrame.size.height < 100 {
//            self.commentViewRef.commentTextView.isScrollEnabled = false
//            self.commentViewRef.commentHeightContraint.constant = newFrame.size.height
//            textChanged?(textView.text)
//        }else {
//            self.commentViewRef.commentTextView.isScrollEnabled = true
//        }
    }
    
    func handleEmptyText(){
        self.commentViewRef.textEmptyCallbackHandler =  { (isTextEmpty) in
//            let fixedWidth = self.commentViewRef.commentTextView.frame.size.width
//            self.commentViewRef.commentTextView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
//            let newSize = self.commentViewRef.commentTextView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
//            var newFrame = self.commentViewRef.commentTextView.frame
//            newFrame.size = CGSize(width: max(fixedWidth, fixedWidth), height: newSize.height)
//            self.commentViewRef.commentTextView.isScrollEnabled = false
//            self.commentViewRef.commentHeightContraint.constant = 50
//            self.textChanged?("")
        }
    }
}

extension GalleryCell:FeedCallBackProtocol {
    func manageCallbackhandler(){
        self.handlingLikeDislike()
        self.handleEmptyText()
        self.handlingCommentCallback()
        self.handlingInstantCommentCallback()
    }
    
    // Hanlding LikeDislikeCallBack...
    func handlingLikeDislike(){
        self.commentViewRef.likeDislikeCallBack =  { (isLike, value) in
            let feedObjUpdate:FeedData = self.feedArray[self.indexValue.row]
            if isLike {
                if value {
                    feedObjUpdate.likeCount = feedObjUpdate.likeCount! + 1
                    if feedObjUpdate.isDisliked! {
                        feedObjUpdate.simple_dislike_count = feedObjUpdate.simple_dislike_count! - 1
                    }
                }else {
                    feedObjUpdate.likeCount = feedObjUpdate.likeCount! - 1
                }
                feedObjUpdate.isLiked = value
                feedObjUpdate.isDisliked = false
            }else {
                if value {
                    feedObjUpdate.simple_dislike_count = feedObjUpdate.simple_dislike_count! + 1
                    if feedObjUpdate.isLiked! {
                        feedObjUpdate.likeCount = feedObjUpdate.likeCount! - 1
                    }
                }else {
                    feedObjUpdate.simple_dislike_count = feedObjUpdate.simple_dislike_count! - 1
                }
                feedObjUpdate.isDisliked = value
                feedObjUpdate.isLiked = false
            }
            self.feedArray[self.indexValue.row] = feedObjUpdate
            self.commentViewRef.manageCount()
        }
    }
    
    // comment call back handler to update the comment instantly in feedobject
    func handlingInstantCommentCallback(){
        self.commentViewRef.commentSentInstantlyHandler = {(body) in
            let feedObjUpdate:FeedData = self.feedArray[self.indexValue.row]
            let commentObj:Comment = Comment(original_body:body ,body: body, firstName: SharedManager.shared.getFirstName(), lastName: SharedManager.shared.getlastName(), profileImage: SharedManager.shared.getProfileImage(), isPosting:false, identifierStr:"")
            var commentCount:Int = 0
            if feedObjUpdate.comments!.count > 0 {
                commentCount = (feedObjUpdate.comments?.count)!
            }
            feedObjUpdate.comments?.insert(commentObj, at: commentCount)
            feedObjUpdate.isPostingNow = false
            self.feedArray[self.indexValue.row] = feedObjUpdate
            self.updateTableClosure?(self.indexValue)
        }
    }
    
    // comment callback handler after service call
    func handlingCommentCallback(){
        self.commentViewRef.commentServiceCallbackHandler = {(res) in
            let feedObjUpdate:FeedData = self.feedArray[self.indexValue.row]
            if res is String {
                return
            }else if res is NSDictionary {
                let respDict:NSDictionary = res as! NSDictionary
                let dataDict:NSDictionary = respDict.value(forKey: "data") as! NSDictionary
                let commentObj:Comment = Comment(dict: dataDict)
                var commentCount:Int = 0
                if feedObjUpdate.comments!.count > 0 {
                    commentCount = (feedObjUpdate.comments?.count)! - 1
                }
                feedObjUpdate.comments![commentCount] = commentObj
                feedObjUpdate.isPostingNow = true
                self.feedArray[self.indexValue.row] = feedObjUpdate
                self.updateTableClosure?(self.indexValue)
            }
        }
    }
}

extension GalleryCell:UICollectionViewDataSource, UICollectionViewDelegate , UICollectionViewDelegateFlowLayout
{
    func resetCollectionCell(){
        self.feedDataObj = nil
        self.galleryCollectionView.reloadData()
    }
    func resetVisibleCellVideo(){
        for cell in self.galleryCollectionView.visibleCells {
            let galleryCell = cell as! GalleryCollectionCell
            galleryCell.stopPlayingVideo()
            galleryCell.stopPlayingAudio()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
                
        if self.feedDataObj != nil {
            
            if self.feedDataObj!.post!.count < 5 {
                return self.feedDataObj!.post!.count
            }else {
                return 4
            }
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView.tag == 100 {
//            let cellBottom = collectionView.dequeueReusableCell(withReuseIdentifier: "BottomCollectionCell", for: indexPath) as! BottomCollectionCell
            
            guard let cellBottom = collectionView.dequeueReusableCell(withReuseIdentifier: "BottomCollectionCell", for: indexPath) as? BottomCollectionCell else {
               return UICollectionViewCell()
            }
            
            var cellShow = 0
            
            if self.galleryCollectionView.indexPathsForVisibleItems.count > 0 {
                cellShow = (self.galleryCollectionView.indexPathsForVisibleItems.first)!.row
            }
            
            
            if (self.feedDataObj != nil) {
                let postVal:PostFile = self.feedDataObj!.post![indexPath.row]
                if postVal.fileType == FeedType.image.rawValue {
                    
                    if cellShow == indexPath.row {
                        cellBottom.imgViewMain.image = UIImage(named: "pagerAImg.png")!
                    }else {
                        cellBottom.imgViewMain.image = UIImage(named: "pagerAImgF.png")!
                    }
                }else if postVal.fileType == FeedType.video.rawValue {
                    if cellShow == indexPath.row {
                        cellBottom.imgViewMain.image = UIImage(named: "pagerVideo.png")!
                    }else {
                        cellBottom.imgViewMain.image = UIImage(named: "pagerVideoF.png")!
                    }

                }else if postVal.fileType == FeedType.audio.rawValue {
                    if cellShow == indexPath.row {
                        cellBottom.imgViewMain.image = UIImage(named: "pagerAA.png")!
                    }else {
                        cellBottom.imgViewMain.image = UIImage(named: "pagerAF.png")!
                    }
                }else if postVal.fileType == FeedType.file.rawValue {
                    if cellShow == indexPath.row {
                        cellBottom.imgViewMain.image = UIImage(named: "Attachment.png")!
                    }else {
                        cellBottom.imgViewMain.image = UIImage(named: "AttachmentF.png")!
                    }
                }
            }
            return cellBottom
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Const.KGalleryCollectionCell, for: indexPath) as! GalleryCollectionCell
        cell.managePostData(postObj:self.feedDataObj!.post![indexPath.row], mainIndex: self.currentIndexPath, currentIndex: indexPath, isAppearFrom: self.isAppearFrom)
        cell.isFromFeed = self.isFromFeed
        cell.layoutIfNeeded()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenSize: CGRect = UIScreen.main.bounds
        
        if collectionView.tag == 100 {
            if UIDevice.current.userInterfaceIdiom == .pad
            {
                return CGSize(width: collectionView.frame.size.height, height: collectionView.frame.size.height)
            }
            
            return CGSize(width: collectionView.frame.size.height, height: collectionView.frame.size.height)
        }else {
            if UIDevice.current.userInterfaceIdiom == .pad
            {
                return CGSize(width: screenSize.width-12, height: 400)
            }
            
            if self.feedDataObj!.post!.count == 2 {
                return CGSize(width: (screenSize.width-12), height: collectionView.frame.size.height / 2 )
            }else if self.feedDataObj!.post!.count == 3 {
                if indexPath.row == 2 {
                    
                    return CGSize(width: (screenSize.width-12), height: collectionView.frame.size.height/2)
                }else {
                    return CGSize(width: (screenSize.width-12)/2, height: collectionView.frame.size.height/2)

                }
            }else {
                
                return CGSize(width: (screenSize.width-12)/2, height: collectionView.frame.size.height/2)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell,forItemAt indexPath: IndexPath)    {
        if let postCell = cell as? GalleryCollectionCell {
            postCell.stopPlayingVideo()
            postCell.stopPlayingAudio()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView.tag == 100 {
            self.galleryCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
//
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.collectionViewBottom.reloadData()
            }
        }else {
            FeedCallBManager.shared.galleryCellIndexCallbackHandler?(self.currentIndexPath, indexPath, false)
        }
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        for cell in self.galleryCollectionView.visibleCells {
            let indexPath = self.galleryCollectionView.indexPath(for: cell)
            self.collectionViewBottom.reloadData()
            self.manageVideoDownloadBtn(pageNumber: indexPath!.row)

        }
    }
    
    func manageVideoDownloadBtn(pageNumber:Int) {
//        self.commentViewRef.downloadBtn.isHidden = true
//        self.commentViewRef.downloadPLbl.isHidden = true
//        let postObj = self.feedDataObj!.post![pageNumber]
//        self.commentViewRef.pageNumber = pageNumber
//        if postObj.fileType == FeedType.video.rawValue {
//            if postObj.processingStatus == "done" {
//                self.commentViewRef.downloadBtn.isHidden = false
//                self.commentViewRef.manageDownloadHandler(id: postObj.fileID!)
//            }
//        }
    }
    
    
    
    func loadEdge()  {
        
        if (self.feedDataObj != nil) {
            
            let CellCount = self.feedDataObj!.post!.count
            
            
            if (CGFloat(CellCount) * self.collectionViewBottom.frame.size.height) > self.collectionViewBottom.frame.size.width {
                leftMargin = 0.0
                rightMargin = 0.0
            }else {
                let CellWidth = self.collectionViewBottom.frame.size.height
                let CellSpacing = 0
                let totalCellWidth = Int(CellWidth) * CellCount
                let totalSpacingWidth = CellSpacing * (CellCount - 1)

                leftMargin = (self.collectionViewBottom.frame.size.width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {




        if collectionView.tag == 100 {

            return UIEdgeInsets(top: 0, left: self.leftMargin, bottom: 0, right: self.leftMargin)
        }


        return UIEdgeInsets.zero
    }
}



class BottomCollectionCell : UICollectionViewCell {
    @IBOutlet var imgViewMain : UIImageView!
}
