//
//  NewVideoFeedCell.swift
//  WorldNoor
//
//  Created by apple on 11/8/21.
//  Copyright © 2021 Raza najam. All rights reserved.
//

import Foundation
import UIKit
//import SwiftLinkPreview

class NewVideoFeedCell : UITableViewCell {
    
    @IBOutlet var tblViewImg : UITableView!
    
    var postObj : FeedData!
    var indexPathMain : IndexPath!
    
    var cellDelegate : CellDelegate!
    var isForWatch : Bool = false
    var isFromProfile: Bool = false
    var typeRow = [Int]()
    var isPlayVideo : Bool = false
    var parentView : UIViewController!
    
    @IBOutlet var parentTblView : UITableView!
    
    var playerSoundValue : Bool = true
    
    
    var videoCell : NewVideoPlayerLayerCell?
    override func awakeFromNib() {
        
        self.tblViewImg.register(UINib.init(nibName: "NewVideoPlayerLayerCell", bundle: nil), forCellReuseIdentifier: "NewVideoPlayerLayerCell")
        self.tblViewImg.register(UINib.init(nibName: "NewVideoPlayCell", bundle: nil), forCellReuseIdentifier: "NewVideoPlayCell")
        self.tblViewImg.register(UINib.init(nibName: "NewHeaderFeedCell", bundle: nil), forCellReuseIdentifier: "NewHeaderFeedCell")
        self.tblViewImg.register(UINib.init(nibName: "NewTextHeaderCell", bundle: nil), forCellReuseIdentifier: "NewTextHeaderCell")
        self.tblViewImg.register(UINib.init(nibName: "NewSingleVideoCell", bundle: nil), forCellReuseIdentifier: "NewSingleVideoCell")
        self.tblViewImg.register(UINib.init(nibName: "NewLikeCell", bundle: nil), forCellReuseIdentifier: "NewLikeCell")
        self.tblViewImg.register(UINib.init(nibName: "NewLikeViewCell", bundle: nil), forCellReuseIdentifier: "NewLikeViewCell")
        self.tblViewImg.register(UINib.init(nibName: "NewLinkPreviewCell", bundle: nil), forCellReuseIdentifier: "NewLinkPreviewCell")
    }
    
    func stopPlayer(){
        
        isPlayVideo = false
        if videoCell != nil {
            videoCell!.pauseAudio(sender: UIButton.init())
        }        
    }
    
    
    func playPlayer(){
        
        if videoCell != nil {
            videoCell!.playerSoundValue = self.playerSoundValue
            videoCell!.playAudio(sender: UIButton.init())
            
        }
        
    }
    
    

    func reloadData(){
        self.typeRow.removeAll()
        self.typeRow.append(0)
        self.typeRow.append(1)
                
        self.typeRow.append(2)
        self.typeRow.append(3)
       
        self.tblViewImg.reloadData()
        
        
    }
}


extension NewVideoFeedCell : UITableViewDelegate , UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == 1 {
            if self.postObj.body == nil {
                return 0
            }else if self.postObj.body!.count == 0 {
                return 0
            }
        }
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.typeRow.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if self.typeRow[indexPath.row] == 0 {
            return headerCell(tableView: tableView, cellForRowAt: indexPath)
        }else if self.typeRow[indexPath.row] == 2 {
            
//            if postObj.postType == FeedType.video.rawValue && self.isForWatch {
            if postObj.postType == FeedType.video.rawValue {
                return NewVideoPlayCell(tableView: tableView, cellForRowAt: indexPath)
            }else {
                return ImageCell(tableView: tableView, cellForRowAt: indexPath)
            }
            
        }else if self.typeRow[indexPath.row] == 3 {
            return LikeCell(tableView: tableView, cellForRowAt: indexPath)
        }else if self.typeRow[indexPath.row] == 4 {
            return NewLinkPreviewCell(tableView: tableView, cellForRowAt: indexPath)
        }
        
        return textHeaderCell(tableView: tableView, cellForRowAt: indexPath)
    }
    
    
    
    func headerCell(tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let headerCell = tableView.dequeueReusableCell(withIdentifier: "NewHeaderFeedCell", for: indexPath) as! NewHeaderFeedCell
        headerCell.feedObj = self.postObj
        headerCell.indexObjMain = indexPathMain
        headerCell.isFromWatch = true
        headerCell.reloadHeaderData()
        headerCell.layoutIfNeeded()
        headerCell.isFromProfile = isFromProfile
        headerCell.selectionStyle = .none
        headerCell.cellDelegate = cellDelegate
        return headerCell
    }
    
    func textHeaderCell(tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let headerTextCell = tableView.dequeueReusableCell(withIdentifier: "NewTextHeaderCell", for: indexPath) as! NewTextHeaderCell
        headerTextCell.feedObj = self.postObj
        headerTextCell.isFromWatch = true
        headerTextCell.reloadHeaderData()
        headerTextCell.layoutIfNeeded()
        headerTextCell.btnShowMore.tag = indexPath.row
        headerTextCell.cellDelegate = self
        headerTextCell.btnShowMore.addTarget(self, action: #selector(self.showMoreAction), for: .touchUpInside)
        headerTextCell.selectionStyle = .none
        return headerTextCell
    }
    
    @objc func showMoreAction(sender : UIButton){
        self.postObj.isExpand = !self.postObj.isExpand
        
        if let cellHeader = self.tblViewImg.cellForRow(at: IndexPath.init(row: sender.tag, section: 0)) as? NewTextHeaderCell {
            cellHeader.feedObj = self.postObj
            
            if self.postObj.isExpand {
                cellHeader.lblShowMore.text = "Show More".localized()
                
                cellHeader.reloadLine(numberofLine: 3)
            }else {
                cellHeader.lblShowMore.text = "Show Less".localized()
                cellHeader.reloadLine(numberofLine: 0)
                
            }
            
        }

        self.cellDelegate.reloadRow(indexObj: indexPathMain, feedObj: self.postObj)
    }
    
    
    func NewVideoPlayCell(tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let imgCell = tableView.dequeueReusableCell(withIdentifier: "NewVideoPlayerLayerCell", for: indexPath) as! NewVideoPlayerLayerCell
        
        imgCell.playerSoundValue = self.playerSoundValue
        imgCell.tblViewMain = self.parentTblView
        if postObj.postType == FeedType.video.rawValue {
            imgCell.resetVideo(feedObjp: self.postObj)
        }

        self.videoCell = imgCell
        imgCell.indexPathMain = self.indexPathMain
        imgCell.parentView = self

        
        imgCell.selectionStyle = .none
        return imgCell

    }
    
    func ImageCell(tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let imgCell = tableView.dequeueReusableCell(withIdentifier: "NewSingleVideoCell", for: indexPath) as! NewSingleVideoCell
        
        imgCell.lblMain.isHidden = true
        imgCell.lblMain.text = "livestream has ended".localized()
        imgCell.imgPlay.isHidden = false
        imgCell.btnImgView.isHidden = false
        if (postObj.isLive != nil) {
            if (postObj.isLive! == 1) {
                imgCell.imgViewMain.loadImageWithPH(urlMain: postObj.liveThumbUrlStr!)
            }else {

                if postObj.postType == FeedType.liveStream.rawValue {
                    
                    if postObj.post?.count == 0 && postObj.isLive! == 0{
                        imgCell.lblMain.isHidden = false
                        imgCell.imgPlay.isHidden = true
                        imgCell.btnImgView.isHidden = true
                    }
                    imgCell.imgViewMain.loadImageWithPH(urlMain: postObj.liveThumbUrlStr!)
                    
                }else {
                    
                    
                    let postFile:PostFile = postObj.post![0]
                    if postFile.processingStatus != "done" {
                        imgCell.lblMain.text = "Video in processing."
                        imgCell.lblMain.isHidden = false
                        imgCell.imgPlay.isHidden = true
                        imgCell.btnImgView.isHidden = true
                    }
                    
                    if postFile.thumbnail != nil {
                        imgCell.imgViewMain.loadImageWithPH(urlMain: postFile.thumbnail!)
                    }
                }
            }
        }else {
            let postFile:PostFile = postObj.post![0]
            
            imgCell.imgViewMain.loadImageWithPH(urlMain: postFile.thumbnail!)
        }
        
//        imgCell.imgViewMain.rotateViewForLanguage()
        imgCell.postObj = self.postObj
        
        imgCell.selectionStyle = .none
        return imgCell
    }

    func NewLinkPreviewCell(tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let LikeCell = tableView.dequeueReusableCell(withIdentifier: "NewLinkPreviewCell", for: indexPath) as! NewLinkPreviewCell
        LikeCell.feedObj = self.postObj
        LikeCell.reloadHeaderData()
        LikeCell.selectionStyle = .none
        return LikeCell
    }
    
    func LikeCell(tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let LikeCell = tableView.dequeueReusableCell(withIdentifier: "NewLikeViewCell", for: indexPath) as! NewLikeViewCell
        LikeCell.reloadData(feedObjP: self.postObj)
        LikeCell.isFromWatch = false
        LikeCell.selectionStyle = .none
        return LikeCell
    }
}

extension NewVideoFeedCell : LikeCellDelegate {
    func actionPerformed(feedObj: FeedData, typeAction: ActionType) {
        if typeAction == ActionType.reloadTable {
            self.reloadData()
            self.cellDelegate.commentActions(indexObj: self.indexPathMain, feedObj: self.postObj, typeAction: typeAction)
        }else if typeAction == ActionType.downloadAction {
            self.cellDelegate.downloadPostAction(indexObj: indexPathMain, feedObj: postObj)
        }
    }
    
    func actionPerformed(feedObj: FeedData) {
        self.postObj = feedObj
    }
}


extension NewVideoFeedCell : ReloadDelegate {
    func reloadRow(){
        self.cellDelegate.reloadRow(indexObj: indexPathMain, feedObj: self.postObj)
    }
}
