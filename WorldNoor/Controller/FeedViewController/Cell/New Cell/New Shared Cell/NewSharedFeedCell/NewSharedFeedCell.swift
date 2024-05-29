//
//  NewSharedFeedCell.swift
//  WorldNoor
//
//  Created by apple on 11/15/21.
//  Copyright © 2021 Raza najam. All rights reserved.
//

import Foundation
import UIKit
//import SwiftLinkPreview

class NewSharedFeedCell : UITableViewCell {
    
    @IBOutlet var tblViewImg : UITableView!
    
    var postObj : FeedData!
    var indexPathMain : IndexPath!
    
    var cellDelegate : CellDelegate!
    var isFromProfile = false
    var typeRow = [Int]()
//    private let slp = SwiftLinkPreview(cache: InMemoryCache())
    
    override func awakeFromNib() {
        self.tblViewImg.register(UINib.init(nibName: "NewHeaderFeedCell", bundle: nil), forCellReuseIdentifier: "NewHeaderFeedCell")
        self.tblViewImg.register(UINib.init(nibName: "NewTextHeaderCell", bundle: nil), forCellReuseIdentifier: "NewTextHeaderCell")
        self.tblViewImg.register(UINib.init(nibName: "NewTextSharedCell", bundle: nil), forCellReuseIdentifier: "NewTextSharedCell")
        
        self.tblViewImg.register(UINib.init(nibName: "NewSingleAttachmentCell", bundle: nil), forCellReuseIdentifier: "NewSingleAttachmentCell")
        self.tblViewImg.register(UINib.init(nibName: "NewLikeCell", bundle: nil), forCellReuseIdentifier: "NewLikeCell")
        self.tblViewImg.register(UINib.init(nibName: "NewLikeViewCell", bundle: nil), forCellReuseIdentifier: "NewLikeViewCell")
        
        self.tblViewImg.register(UINib.init(nibName: "NewSingleImageCell", bundle: nil), forCellReuseIdentifier: "NewSingleImageCell")
        self.tblViewImg.register(UINib.init(nibName: "NewSingleVideoCell", bundle: nil), forCellReuseIdentifier: "NewSingleVideoCell")
        self.tblViewImg.register(UINib.init(nibName: "NewSingleAudioCell", bundle: nil), forCellReuseIdentifier: "NewSingleAudioCell")
        self.tblViewImg.register(UINib.init(nibName: "NewSingleGalleryCell", bundle: nil), forCellReuseIdentifier: "NewSingleGalleryCell")
        self.tblViewImg.register(UINib.init(nibName: "NewLinkPreviewCell", bundle: nil), forCellReuseIdentifier: "NewLinkPreviewCell")

        
    }

    func reloadData(){
        self.typeRow.removeAll()
        self.typeRow.append(0)
        self.typeRow.append(1)
        

        if self.postObj != nil {
            if self.postObj.sharedData != nil {
                if self.postObj.sharedData?.body != nil {
                    if self.postObj.sharedData!.body!.count > 0 {
                        self.typeRow.append(6)
                    }
                }
            }
        }
        
        if self.postObj.sharedData!.postType != FeedType.post.rawValue {
            if self.postObj.sharedData!.postType != FeedType.shared.rawValue {
                self.typeRow.append(2)
            }
            
        }
        
        
        if self.postObj.body != nil {
            if self.postObj.linkImage != nil && self.postObj.linkTitle != nil{
                if self.postObj.linkImage!.count > 0 {
                self.typeRow.append(5)
                }
            }
                
        }

        self.typeRow.append(3)
        
        self.tblViewImg.reloadData()
    }
}


extension NewSharedFeedCell : UITableViewDelegate , UITableViewDataSource {
    
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
        }else if self.typeRow[indexPath.row] == 3 {
            return LikeCell(tableView: tableView, cellForRowAt: indexPath)
        }else if self.typeRow[indexPath.row] == 6 {
            return TextSharedCell(tableView: tableView, cellForRowAt: indexPath)
        }else if self.typeRow[indexPath.row] == 4 {
            return NewTextSharedCell(tableView: tableView, cellForRowAt: indexPath)
        }else if self.typeRow[indexPath.row] == 2 {
            if self.postObj.sharedData?.postType == FeedType.file.rawValue {
                return NewSingleAttachmentCell(tableView: tableView, cellForRowAt: indexPath)
            }else if self.postObj.sharedData?.postType == FeedType.image.rawValue ||
                        self.postObj.sharedData?.postType == FeedType.gif.rawValue {
                return ImageCell(tableView: tableView, cellForRowAt: indexPath)
            }else if self.postObj.sharedData?.postType == FeedType.video.rawValue {
                return VideoCell(tableView: tableView, cellForRowAt: indexPath)
            }else if self.postObj.sharedData?.postType == FeedType.audio.rawValue {
                return NewSingleAudioCell(tableView: tableView, cellForRowAt: indexPath)
            }else if self.postObj.sharedData?.postType == FeedType.gallery.rawValue {
                return NewSingleGalleryCell(tableView: tableView, cellForRowAt: indexPath)
            }else {
                return TextSharedCell(tableView: tableView, cellForRowAt: indexPath)
                
            }
            
            
        }else if self.typeRow[indexPath.row] == 5 {
            return NewLinkPreviewCell(tableView: tableView, cellForRowAt: indexPath)
            
        }
        
        
        return textHeaderCell(tableView: tableView, cellForRowAt: indexPath)
        
    }
    
    
    
    func headerCell(tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let headerCell = tableView.dequeueReusableCell(withIdentifier: "NewHeaderFeedCell", for: indexPath) as! NewHeaderFeedCell
        
     
        headerCell.feedObj = self.postObj
        headerCell.indexObjMain = indexPathMain
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
        headerTextCell.reloadHeaderData()
        headerTextCell.cellDelegate = self
        headerTextCell.layoutIfNeeded()
        headerTextCell.btnShowMore.tag = indexPath.row
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
                cellHeader.lblMain.dynamicFootnoteRegular13()
                cellHeader.reloadLine(numberofLine: 3)
            }else {
                cellHeader.lblShowMore.text = "Show Less".localized()
                cellHeader.reloadLine(numberofLine: 0)
                
            }
            
        }

        self.cellDelegate.reloadRow(indexObj: indexPathMain, feedObj: self.postObj)
    }
    func NewTextSharedCell(tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let headerTextCell = tableView.dequeueReusableCell(withIdentifier: "NewTextSharedCell", for: indexPath) as! NewTextSharedCell
        
        
     
        headerTextCell.feedObj = self.postObj.sharedData!
        
        
        headerTextCell.reloadHeaderData()
        headerTextCell.layoutIfNeeded()
        headerTextCell.selectionStyle = .none
        return headerTextCell
    }
    
    func TextSharedCell(tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let headerTextCell = tableView.dequeueReusableCell(withIdentifier: "NewTextSharedCell", for: indexPath) as! NewTextSharedCell
        
        headerTextCell.feedObj = self.postObj.sharedData!
        
        
        headerTextCell.reloadHeaderData()
        headerTextCell.layoutIfNeeded()
        headerTextCell.selectionStyle = .none
        return headerTextCell
    }
    
    func NewSingleGalleryCell(tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let audioCell = tableView.dequeueReusableCell(withIdentifier: "NewSingleGalleryCell", for: indexPath) as! NewSingleGalleryCell
//        let postFile:PostFile = self.postObj!.sharedData!.post![0]
        
        
        audioCell.mainIndexPath = self.indexPathMain
        audioCell.feedDataObj = self.postObj.sharedData!
        audioCell.manageCellData(feedObj:self.postObj.sharedData!)
        audioCell.selectionStyle = .none
        return audioCell
    }
    
    func NewSingleAudioCell(tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let audioCell = tableView.dequeueReusableCell(withIdentifier: "NewSingleAudioCell", for: indexPath) as! NewSingleAudioCell
        
        
        
        audioCell.postObj = self.postObj.sharedData!
        audioCell.manageCellData()
        audioCell.selectionStyle = .none
        return audioCell
    }
    
    func VideoCell(tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let videoCell = tableView.dequeueReusableCell(withIdentifier: "NewSingleVideoCell", for: indexPath) as! NewSingleVideoCell
        
        
        if (postObj.isLive != nil) {
            if (postObj.isLive! == 1) {
                videoCell.imgViewMain.loadImageWithPH(urlMain: postObj.liveThumbUrlStr!)
            }else {
                
                if self.postObj!.sharedData!.post!.count > 0 {
                    let postFile:PostFile = self.postObj!.sharedData!.post![0]
                    
                    videoCell.imgViewMain.loadImageWithPH(urlMain: postFile.thumbnail!)
                }
                
            }
            
        }else {
            let postFile:PostFile = self.postObj!.sharedData!.post![0]
            
            videoCell.imgViewMain.loadImageWithPH(urlMain: postFile.thumbnail!)
        }
        
        videoCell.postObj = self.postObj.sharedData!
        
        videoCell.selectionStyle = .none
        return videoCell
    }
    
    func ImageCell(tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let imgCell = tableView.dequeueReusableCell(withIdentifier: "NewSingleImageCell", for: indexPath) as! NewSingleImageCell
        let postFile:PostFile = self.postObj!.sharedData!.post![0]
        
        imgCell.imgViewMain.loadImageWithPH(urlMain: postFile.filePath!)
        imgCell.postObj = self.postObj.sharedData!
        
        imgCell.selectionStyle = .none
        return imgCell
    }
    
    func NewSingleAttachmentCell(tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let audioCell = tableView.dequeueReusableCell(withIdentifier: "NewSingleAttachmentCell", for: indexPath) as! NewSingleAttachmentCell
        
//        let postFile:PostFile = self.postObj!.sharedData!.post![0]
        
        
        audioCell.feedObj = self.postObj.sharedData!
        audioCell.manageCellData(feedObj: self.postObj)
        audioCell.selectionStyle = .none
        return audioCell
    }

    func LikeCell(tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let LikeCell = tableView.dequeueReusableCell(withIdentifier: "NewLikeViewCell", for: indexPath) as! NewLikeViewCell
        LikeCell.reloadData(feedObjP: self.postObj)
        LikeCell.selectionStyle = .none
        return LikeCell
    }

    func NewLinkPreviewCell(tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let LikeCell = tableView.dequeueReusableCell(withIdentifier: "NewLinkPreviewCell", for: indexPath) as! NewLinkPreviewCell
        LikeCell.feedObj = self.postObj
        LikeCell.reloadHeaderData()
        LikeCell.selectionStyle = .none
        return LikeCell
    }
}

extension NewSharedFeedCell : LikeCellDelegate {
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



extension NewSharedFeedCell : ReloadDelegate {
    func reloadRow(){
        self.cellDelegate.reloadRow(indexObj: indexPathMain, feedObj: self.postObj)
    }
}
