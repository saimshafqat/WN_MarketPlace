//
//  FeedViewModel.swift
//  WorldNoor
//
//  Created by Raza najam on 9/5/19.
//  Copyright © 2019 Raza najam. All rights reserved.
//

import Foundation
import UIKit
import FittedSheets

class PageViewModel: NSObject {
    var reloadTableViewClosure: (()->())?
    var hideSkeletonClosure: (()->())?
    var didSelectTableClosure:((IndexPath)->())?
    var reloadTableViewWithNoneClosure: (()->())?
    var hideFooterClosure: (()->())?
    var showAlertMessageClosure:((String)->())?
    var showloadingBar:(()->())?
    var reloadSpecificRow:((IndexPath)->())?
    var reloadVisibleRows:((IndexPath)->())?
    var cellHeightDictionary:NSMutableDictionary = NSMutableDictionary()
    var presentImageFullScreenClosure:((Int, Bool)->())?
    var feedArray:[FeedData] = []
    var currentlyPlayingIndexPath : IndexPath? = nil
    var isNextFeedExist:Bool = true
    var refreshControl = UIRefreshControl()
    var postID:Int?
    var groupObj:GroupValue?
//    var parentView : UIViewController!
    
    override init() {
        super.init()
    }
    
    func initializeMe(){
        self.callingFeedService(lastPostID: "", isLastTrue: false, isRefresh: false)
    }
    
    @objc open func refresh(sender:AnyObject) {
        self.isNextFeedExist = true
        self.callingFeedService(lastPostID: "", isLastTrue: false, isRefresh: true)
    }
}

extension PageViewModel:UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.feedArray.count > 0 {
            return self.feedArray.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.feedArray.count > 0 {
            let feedObj:FeedData = self.feedArray[indexPath.row] as FeedData
            var feedCell:FeedParentCell? = nil
            switch feedObj.postType! {
            case FeedType.post.rawValue:
                if let cell = tableView.dequeueReusableCell(withIdentifier: PostCell.identifier, for: indexPath) as? PostCell {
                    cell.feedArray = self.feedArray
                    cell.manageCellData(feedObj: feedObj, indexValue: indexPath, reloadClosure: self.reloadSpecificRow, didSelect: self.didSelectTableClosure)
                    feedCell = cell
                    cell.textChanged {[weak self]newText in
                        DispatchQueue.main.async {
                            self!.beginAndEndUpdate(tableView: tableView)
                        }
                    }
                }
            case FeedType.audio.rawValue:
                if let cell = tableView.dequeueReusableCell(withIdentifier: AudioCell.identifier, for: indexPath) as? AudioCell {
                    cell.feedArray = self.feedArray
                    cell.manageCellData(feedObj: feedObj, indexValue: indexPath, reloadClosure: self.reloadSpecificRow, didSelect: self.didSelectTableClosure)
                    feedCell = cell
                    cell.textChanged {[weak self]newText in
                        self!.beginAndEndUpdate(tableView: tableView)
                    }
                }
            case FeedType.video.rawValue:
                if let cell = tableView.dequeueReusableCell(withIdentifier: VideoCell.identifier, for: indexPath) as? VideoCell {
                    cell.feedArray = self.feedArray
                    cell.manageCellData(feedObj: feedObj, shouldPlay: self.currentlyPlayingIndexPath == indexPath, indexValue: indexPath,reloadClosure: self.reloadSpecificRow, didSelect: self.didSelectTableClosure)
                    feedCell = cell
                    cell.textChanged {[weak self]newText in
                        self!.beginAndEndUpdate(tableView: tableView)
                    }
                    cell.videoPlayerIndexCallback = { (indexValue) in
                        self.currentlyPlayingIndexPath = indexValue
                    }
                }
            case FeedType.image.rawValue:
                
                if let cellImage = tableView.dequeueReusableCell(withIdentifier: "NewImageFeedCell", for: indexPath) as? NewImageFeedCell {
                    cellImage.postObj = feedObj
                    cellImage.indexPathMain = indexPath
                    cellImage.reloadData()
                    cellImage.tblViewImg.invalidateIntrinsicContentSize()
//                    cellImage.cellDelegate = self
                    self.isFeedReachEnd(indexPath: indexPath)
                    return cellImage
                }
                
//                if let cell = tableView.dequeueReusableCell(withIdentifier: ImageCellSingle.identifier, for: indexPath) as? ImageCellSingle {
//                    cell.feedArray = self.feedArray
//                    cell.manageCellData(feedObj: feedObj, indexValue: indexPath, reloadClosure: self.reloadSpecificRow, didSelect: self.didSelectTableClosure)
//                    feedCell = cell
//                    cell.textChanged {[weak self]newText in
//                        self!.beginAndEndUpdate(tableView: tableView)
//                    }
//                    cell.imageSelectedClosure = { (indexValue, isGroup) in
//                        self.presentImageFullScreenClosure?(indexValue, isGroup)
//                    }
//
//                    cell.btnShare.tag = indexPath.row
//                    cell.btnShare.addTarget(self, action: #selector(self.DownloadImage), for: .touchUpInside)
//                }
            case FeedType.gallery.rawValue:
                if let cell = tableView.dequeueReusableCell(withIdentifier: GalleryCell.identifier, for: indexPath) as? GalleryCell {
                    cell.feedArray = self.feedArray
                    cell.isAppearFrom = "Feed"
                    cell.manageCellData(feedObj: feedObj, indexValue: indexPath, reloadClosure: self.reloadSpecificRow, didSelect: self.didSelectTableClosure)
                    feedCell = cell
                    cell.textChanged {[weak self]newText in
                        DispatchQueue.main.async {
                            self!.beginAndEndUpdate(tableView: tableView)
                        }
                    }
                    
                    
                    if let viewComment = cell.commentView as? FeedCommentBarView {
                    }
                }
            default:
                LogClass.debugLog("Feed type missing.")
            }
            self.isFeedReachEnd(indexPath: indexPath)
            if feedCell != nil {
                feedCell?.layoutIfNeeded()
                return feedCell!
            }
        }else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: SkeletonCell.identifier, for: indexPath) as? SkeletonCell{
                cell.layoutIfNeeded()
                return cell
            }
        }
        return UITableViewCell()
    }
    
    
    @objc func DownloadImage(sender : UIButton){
//        let postFile:PostFile = self.feedArray[sender.tag].post![0]
//        self.parentView.downloadFile(filePath: postFile.filePath!, isImage: true, isShare: true)
    }
    
    @objc func openUSerProfileAction(sender : UIButton){
//        let vcProfile = AppStoryboard.PostStoryboard.instance.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
//        vcProfile.otherUserID = String(sender.tag)
//                      vcProfile.otherUserisFriend = "1"
//        self.parentView.navigationController!.pushViewController(vcProfile, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if self.feedArray.count>0 {
            cellHeightDictionary.setObject(cell.frame.size.height, forKey: indexPath as NSCopying)
            if self.isNextFeedExist {
                let lastSectionIndex = tableView.numberOfSections - 1
                let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 1
                if indexPath.section ==  lastSectionIndex && indexPath.row == lastRowIndex {
                    let spinner = UIActivityIndicatorView(style: .gray)
                    spinner.startAnimating()
                    spinner.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(60))
                    tableView.tableFooterView = spinner
                    tableView.tableFooterView?.isHidden = false
                }
            }else {
                tableView.tableFooterView?.isHidden = true
                tableView.tableFooterView?.removeFromSuperview()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if self.feedArray.count > 0 {
            if indexPath.row > self.feedArray.count-1 {
                return
            }
            let feedObj:FeedData = self.feedArray[indexPath.row] as FeedData
            switch feedObj.postType! {
            case FeedType.video.rawValue:
                if cell is VideoCell {
                    let cell = cell as! VideoCell
                    cell.resetVideoPlayer()
                    if  let xqPlayer = cell.commentViewRef.xqAudioPlayer {
                        xqPlayer.resetXQPlayer()
                    }
                    cell.commentViewRef.audioRecorderObj?.doResetRecording()
                    //                    cell.commentViewRef.removeDropDown()
                }
            case FeedType.audio.rawValue:
                if cell is AudioCell {
                    let cell = cell as! AudioCell
                    if  let xqPlayer = cell.commentViewRef.xqAudioPlayer {
                        xqPlayer.resetXQPlayer()
                    }
                    cell.xqAudioPlayer.resetXQPlayer()
                    cell.commentViewRef.audioRecorderObj?.doResetRecording()
                    //                    cell.commentViewRef.removeDropDown()
                }
            case FeedType.post.rawValue:
                if cell is PostCell {
                    let cell = cell as! PostCell
                    if  let xqPlayer = cell.commentViewRef.xqAudioPlayer {
                        xqPlayer.resetXQPlayer()
                    }
                    cell.commentViewRef.audioRecorderObj?.doResetRecording()
                    //                    cell.commentViewRef.removeDropDown()
                }
            case FeedType.gallery.rawValue:
                if cell is GalleryCell {
                    let cell = cell as! GalleryCell
                    if  let xqPlayer = cell.commentViewRef.xqAudioPlayer {
                        xqPlayer.resetXQPlayer()
                    }
                    cell.resetCollectionCell()
                    cell.commentViewRef.audioRecorderObj?.doResetRecording()
                    //                    cell.commentViewRef.removeDropDown()
                }
            case FeedType.image.rawValue:
                if cell is ImageCellSingle {
                    let cell = cell as! ImageCellSingle
                    if  let xqPlayer = cell.commentViewRef.xqAudioPlayer {
                        xqPlayer.resetXQPlayer()
                    }
                    cell.commentViewRef.audioRecorderObj?.doResetRecording()
                    //                    cell.commentViewRef.removeDropDown()
                }
            default:
                LogClass.debugLog("Case not deailing.")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //        let feedObj:FeedData = self.feedArray[indexPath.row] as FeedData
        //        if(feedObj.postType == FeedType.video.rawValue){
        //            FeedCallBManager.shared.videoCellIndexCallbackHandler?(indexPath)
        //        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat    {
        if self.feedArray.count>0   {
            let feedObj:FeedData = self.feedArray[indexPath.row] as FeedData
            switch feedObj.postType! {
            case FeedType.post.rawValue:
                return UITableView.automaticDimension
            case FeedType.audio.rawValue:
                return UITableView.automaticDimension
            case FeedType.gallery.rawValue:
                return UITableView.automaticDimension
            case FeedType.video.rawValue:
                return UITableView.automaticDimension
            case FeedType.image.rawValue:
                return UITableView.automaticDimension
            default:
                return 0
            }
        }
        return 256
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.feedArray.count>0   {
            if cellHeightDictionary.object(forKey: indexPath) != nil {
                let feedObj:FeedData = self.feedArray[indexPath.row] as FeedData
                switch feedObj.postType! {
                case FeedType.post.rawValue:
                    let height = cellHeightDictionary.object(forKey: indexPath) as! CGFloat
                    return height
                case FeedType.audio.rawValue:
                    let height = cellHeightDictionary.object(forKey: indexPath) as! CGFloat
                    return height
                case FeedType.gallery.rawValue:
                    let height = cellHeightDictionary.object(forKey: indexPath) as! CGFloat
                    return height
                case FeedType.video.rawValue:
                    let height = cellHeightDictionary.object(forKey: indexPath) as! CGFloat
                    return height
                case FeedType.image.rawValue:
                    let height = cellHeightDictionary.object(forKey: indexPath) as! CGFloat
                    return height
                default:
                    return 0
                }
            }
        }
        return UITableView.automaticDimension
    }
    // Begin and update
    func beginAndEndUpdate(tableView:UITableView){
        DispatchQueue.main.async {
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
    
    //Manage pagging
    func isFeedReachEnd(indexPath:IndexPath){
        if  self.isNextFeedExist {
            let feedCurrentCount = self.feedArray.count
            if indexPath.row == feedCurrentCount-1 {
                let postObj:FeedData = self.feedArray[indexPath.row] as FeedData
                self.callingFeedService(lastPostID: String(postObj.postID!), isLastTrue: true, isRefresh: false)
            }
        }
    }
    
    func callingFeedService(lastPostID:String, isLastTrue:Bool, isRefresh:Bool){
        self.showloadingBar?()
        var parameters = ["action": "page/newsfeed","page_id":self.groupObj?.groupID,"token":SharedManager.shared.userToken()]
        if isLastTrue {
            parameters["starting_point_id"] = lastPostID
        }
        RequestManagerGen.fetchDataGet(Completion: { (response: Result<(FeedModel), Error>) in
            switch response {
            case .failure(let error):
                if error is ErrorModel  {
                    let err = error as! ErrorModel
                    if err.meta?.message == "Newsfeed not found" {
                        self.refreshControl.endRefreshing()
                        self.hideFooterClosure?()
                        self.isNextFeedExist = false
                        self.hideSkeletonClosure?()
                    }else if err.meta?.code == ResponseKey.unAuthorizedResp.rawValue {
                        AppDelegate.shared().loadLoginScreen()
                    }
                    if  self.isNextFeedExist {
                        self.showAlertMessageClosure?((err.meta?.message)!)
                    }
                }else {
                    self.refreshControl.endRefreshing()
                    self.showAlertMessageClosure?(Const.networkProblemMessage)
                }
            case .success(let res):
                self.handleFeedResponse(feedObj: res, isRefresh: isRefresh)
            }
        }, param:parameters as! [String : String])
    }
    
    func handleFeedResponse(feedObj:FeedModel, isRefresh:Bool){
        if let isFeedData = feedObj.data {
            if isFeedData.count == 0 {
                self.isNextFeedExist = false
            }else {
                if isRefresh {
                    self.feedArray.removeAll()
                }
                self.feedArray.append(contentsOf: isFeedData)
            }
        }

        self.refreshControl.endRefreshing()
        self.reloadTableViewClosure?()
    }
    
    func videoPlayerCallbackHandler()   {
        
    }
    @objc func scrollViewDidScroll(_ scrollView: UIScrollView) {
        GroupHandler.shared.tableDidScrollHandler?()
    }
    
    @objc func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if !scrollView.isDecelerating && !scrollView.isDragging {
            
        }
    }
    
    @objc func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            
        }
    }
}

//MARK:UITextViewDelegate...
extension PageViewModel:UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView){
        
    }
    func textView(_ textView: UITextView,
                  shouldChangeTextIn range: NSRange,
                  replacementText text: String) -> Bool{
        return true
    }
}

