//
//  PostReelsCell.swift
//  WorldNoor
//
//  Created by Waseem Shah on 27/12/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import Foundation
import UIKit

class PostReelsCell : ConfigableCollectionCell{
    
  
    @IBOutlet weak var videoCollectionView: UICollectionView!
    
    @IBOutlet weak var viewLoader: UIView!
    @IBOutlet weak var lblMore: UILabel!
    @IBOutlet weak var lblHeading: UILabel!
    @IBOutlet weak var btnShowMore: UIButton!
    
    
    var pageNumber:Int = 1
    
    var startingPoint = ""
    var isNextVideoExist = true
    var isAPICall = false
    
    var videoClipModelArray:[VideoClipModel] = [VideoClipModel]()
    
    var watchArray:[FeedData] = [FeedData]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        videoCollectionView.registerXibCell([
            .FeedReelCollectionCell,
            .StoryEndCell
        ])
    }
    
    // MARK: - Override -
    override func displayCellContent(data: AnyObject?, parentData: AnyObject?, at indexPath: IndexPath) {

    }
    
    
    func reloadData(){
        
        self.contentView.rotateViewForLanguage()
        self.labelRotateCell(viewMain: self.lblMore)
        self.labelRotateCell(viewMain: self.lblHeading)
        self.labelRotateCell(viewMain: self.viewLoader)
        
        if SharedManager.shared.checkLanguageAlignment() {
            self.videoCollectionView.rotateViewForLanguage()
        }
        
        viewLoader.isHidden = true
        if self.watchArray.count == 0 {
            viewLoader.isHidden = false
            self.watchArray.removeAll()
            self.pageNumber = 1
            callingFeedService(lastPostID: "", isLastTrue: false, isRefresh: true)
        }
    }
    
    func callingFeedService(lastPostID:String, isLastTrue:Bool, isRefresh:Bool){
        var parameters = ["action": "getReels" ,"token":SharedManager.shared.userToken()]
        self.isAPICall = true
        parameters["page"] = String(self.pageNumber)
        RequestManagerGen.fetchDataGet(Completion: { (response: Result<(FeedModel), Error>) in
            self.isAPICall = false
            Loader.stopLoading()
            switch response {
            case .failure(let error):
                if error is ErrorModel  {
                    let err = error as! ErrorModel
                    if err.meta?.message == "Newsfeed not found" {
                    }else if err.meta?.code == ResponseKey.unAuthorizedResp.rawValue {
                        AppDelegate.shared().loadLoginScreen()
                    }
                }
            case .success(let res):
                self.handleFeedResponse(feedObj: res, isRefresh: isRefresh)
            }
        }, param:parameters)
    }
    
    func handleFeedResponse(feedObj:FeedModel, isRefresh:Bool){
        
        viewLoader.isHidden = true
        
        if let isFeedData = feedObj.data {
            watchArray.append(contentsOf: isFeedData)
        }
        self.videoCollectionView.reloadData()
    }
    
    @IBAction func showMoreAction(sender : UIButton) {
        let controller = ReelViewController.instantiate(fromAppStoryboard: .Reel)
        controller.items = self.watchArray
        controller.currentIndex = 0
        controller.hidesBottomBarWhenPushed = true
        UIApplication.topViewController()?.navigationController?.pushViewController(controller, animated: true)

    }
    
}



extension PostReelsCell:UICollectionViewDataSource, UICollectionViewDelegate , UICollectionViewDelegateFlowLayout
{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: (self.videoCollectionView.frame.size.height / 3) * 2, height: self.videoCollectionView.frame.size.height)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        if self.watchArray.count > 0 {
            return self.watchArray.count + 1
        }
        return self.watchArray.count
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        if self.watchArray.count == indexPath.row {
            guard let cellLoadMore = collectionView.dequeueReusableCell(withReuseIdentifier: "StoryEndCell", for: indexPath) as? StoryEndCell else {
                return UICollectionViewCell()
                
            }
            
            cellLoadMore.lblTextMore.text = "See More Reels".localized()
            
            return cellLoadMore
        }
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeedReelCollectionCell", for: indexPath) as? FeedReelCollectionCell else {
            return UICollectionViewCell()
        }
        
        let indexMain = indexPath.row
        if self.watchArray.count > indexMain {
            let feedObj:FeedData = self.watchArray[indexMain]
            
            cell.imgViewThumb?.isHidden = false
            if feedObj.post != nil {
                if feedObj.post?.count ?? 0 > 0 {
                    cell.imgViewThumb?.loadImageWithPH(urlMain:feedObj.post![0].thumbnail!)
                }
            }
            if let value = feedObj.video_post_views {
                cell.lblCount?.text = String(value)
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if self.watchArray.count == indexPath.row {
            self.showMoreAction(sender: UIButton.init())
        }else {
            let controller = ReelViewController.instantiate(fromAppStoryboard: .Reel)
            controller.items = self.watchArray
            controller.currentIndex = indexPath.row
            controller.hidesBottomBarWhenPushed = true
            UIApplication.topViewController()?.navigationController?.pushViewController(controller, animated: true)
        }
    }
}

