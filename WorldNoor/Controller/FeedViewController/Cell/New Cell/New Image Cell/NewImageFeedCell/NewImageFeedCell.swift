//
//  NewImageFeedCell.swift
//  WorldNoor
//
//  Created by apple on 8/13/21.
//  Copyright © 2021 Raza najam. All rights reserved.
//

import Foundation
import UIKit
import SDWebImageWebPCoder

class NewImageFeedCell : UITableViewCell {
    
    @IBOutlet var tblViewImg : UITableView!
    
    var postObj : FeedData!
    var indexPathMain : IndexPath!
    
    var cellDelegate : CellDelegate!
    
    var typeRow = [Int]()
    var isFromProfile: Bool = false
    
    override func awakeFromNib() {
        self.tblViewImg.register(UINib.init(nibName: "NewHeaderFeedCell", bundle: nil), forCellReuseIdentifier: "NewHeaderFeedCell")
        self.tblViewImg.register(UINib.init(nibName: "NewTextHeaderCell", bundle: nil), forCellReuseIdentifier: "NewTextHeaderCell")
        self.tblViewImg.register(UINib.init(nibName: "NewSingleImageCell", bundle: nil), forCellReuseIdentifier: "NewSingleImageCell")
        self.tblViewImg.register(UINib.init(nibName: "NewLikeCell", bundle: nil), forCellReuseIdentifier: "NewLikeCell")
        self.tblViewImg.register(UINib.init(nibName: "NewLikeViewCell", bundle: nil), forCellReuseIdentifier: "NewLikeViewCell")
        self.tblViewImg.register(UINib.init(nibName: "NewLinkPreviewCell", bundle: nil), forCellReuseIdentifier: "NewLinkPreviewCell")
        
    }
    
    func reloadData() {
        self.typeRow.removeAll()
        self.typeRow.append(0)
        self.typeRow.append(1)
        self.typeRow.append(2)
        self.typeRow.append(3)
        self.tblViewImg.reloadData()
    }
}

extension NewImageFeedCell : UITableViewDelegate , UITableViewDataSource {
    
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
            return ImageCell(tableView: tableView, cellForRowAt: indexPath)
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
        headerCell.reloadHeaderData()
        headerCell.layoutIfNeeded()        
        headerCell.selectionStyle = .none
        headerCell.cellDelegate = cellDelegate
        headerCell.isFromProfile = isFromProfile
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
                cellHeader.reloadLine(numberofLine: 3)
            }else {
                cellHeader.lblShowMore.text = "Show Less".localized()
                cellHeader.reloadLine(numberofLine: 0)
            }
        }
        
        self.cellDelegate.reloadRow(indexObj: indexPathMain, feedObj: self.postObj)
    }
    
    
    func ImageCell(tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let imgCell = tableView.dequeueReusableCell(withIdentifier: "NewSingleImageCell", for: indexPath) as! NewSingleImageCell
        
        if postObj.post != nil {
            if postObj.post!.count > 0 {
                let postFile:PostFile = postObj.post![0]
                let filepath = postFile.filePath?.split(separator: ".")
                if filepath!.count > 0 {
                    if filepath!.last == "webp" {
                        let webPCoder = SDImageWebPCoder.shared
                        SDImageCodersManager.shared.addCoder(webPCoder)
                        let webpURL = URL(string:  postFile.filePath!)
                        DispatchQueue.main.async {
                            imgCell.imgViewMain.sd_setImage(with: webpURL)
                        }
                    }else {
                        imgCell.imgViewMain.loadImageWithPH(urlMain: postFile.filePath!)
                    }
                    imgCell.postObj = self.postObj
                }else {
                    imgCell.imgViewMain.loadImageWithPH(urlMain: postFile.filePath!)
                    imgCell.postObj = self.postObj
                }
            }
        }
        imgCell.selectionStyle = .none
        return imgCell
    }
    //    func NCBFileCell(tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    //        let fileCell = tableView.dequeueReusableCell(withIdentifier: "NCBFileCell", for: indexPath) as! NCBFileCell
    ////        let postFile:PostFile = postObj.post![0]
    //
    //        fileCell.postObj = self.postObj
    //        if self.postObj.comments!.last!.commentID == 0 {
    //            if self.postObj.comments!.count > 1 {
    //                fileCell.commentObj = self.postObj.comments![self.postObj.comments!.count - 2]
    //            }
    //        }else {
    //            fileCell.commentObj = self.postObj.comments!.last
    //        }
    //
    //        fileCell.reloadComment()
    //        fileCell.selectionStyle = .none
    //        return fileCell
    //    }
    
    
    
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
        LikeCell.selectionStyle = .none
        return LikeCell
    }
    
    
    //    func commentCell(tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    //        let commentCell = tableView.dequeueReusableCell(withIdentifier: "NewCommentCell", for: indexPath) as! NewCommentCell
    //        commentCell.likeDelegate = self
    //        commentCell.feedObj = self.postObj
    //        commentCell.indexPathMain = self.indexPathMain
    //        commentCell.selectionStyle = .none
    //        return commentCell
    //    }
    
    //    func commentTextCell(tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    //        let commentCell = tableView.dequeueReusableCell(withIdentifier: "NCBTextCell", for: indexPath) as! NCBTextCell
    //
    //        if self.postObj.comments!.last!.commentID == 0 {
    //            if self.postObj.comments!.count > 1 {
    //                commentCell.commentObj = self.postObj.comments![self.postObj.comments!.count - 2]
    //            }
    //
    //        }else {
    //            commentCell.commentObj = self.postObj.comments!.last
    //        }
    //
    //        commentCell.reloadComment()
    //        commentCell.postObj = self.postObj
    //        commentCell.selectionStyle = .none
    //        commentCell.layoutIfNeeded()
    //        return commentCell
    //    }
    
    //    func NewCommentBottomImageCell(tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    //        let commentCell = tableView.dequeueReusableCell(withIdentifier: "NewCommentBottomImageCell", for: indexPath) as! NewCommentBottomImageCell
    //
    //        if self.postObj.comments!.last!.commentID == 0 {
    //            if self.postObj.comments!.count > 1 {
    //                commentCell.commentObj = self.postObj.comments![self.postObj.comments!.count - 2]
    //            }
    //        }else {
    //            commentCell.commentObj = self.postObj.comments!.last
    //        }
    //
    //        commentCell.reloadComment()
    ////        commentCell.likeDelegate = self
    ////        commentCell.feedObj = self.postObj
    ////        commentCell.indexPathMain = self.indexPathMain
    //        commentCell.selectionStyle = .none
    //        commentCell.layoutIfNeeded()
    //        return commentCell
    //    }
    
    
    //    func NewPreviewCell(tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    //        let preViewCell = tableView.dequeueReusableCell(withIdentifier: "NewPreviewCell", for: indexPath) as! NewPreviewCell
    //        preViewCell.reloadPreviewCell(feedObjP: self.postObj)
    //        preViewCell.selectionStyle = .none
    //        preViewCell.delegate = self
    //        return preViewCell
    //    }
}

extension NewImageFeedCell : LikeCellDelegate {
    
    func actionPerformed(feedObj: FeedData, typeAction: ActionType) {
        if typeAction == ActionType.reloadTable {
            self.reloadData()
            self.cellDelegate.commentActions(indexObj: self.indexPathMain, feedObj: self.postObj, typeAction: typeAction)
            //        }else if typeAction == ActionType.shareAction {
            //            self.sharePost()
        }else if typeAction == ActionType.downloadAction {
            self.cellDelegate.downloadPostAction(indexObj: indexPathMain, feedObj: postObj)
            //        }else if typeAction == ActionType.cameraAction ||
            //                    typeAction == ActionType.gifUploadAction ||
            //                    typeAction == ActionType.gifBrowseAction ||
            //                    typeAction == ActionType.cameraUploadAction ||
            //                    typeAction == ActionType.attachmentAction ||
            //                    typeAction == ActionType.audioUploadAction ||
            //                    typeAction == ActionType.sendAction ||
            //                    typeAction == ActionType.audioRecordAction {
            //            self.cellDelegate.commentActions(indexObj: self.indexPathMain, feedObj: self.postObj, typeAction: typeAction)
        }
        
    }
    
    func actionPerformed(feedObj: FeedData) {
        self.postObj = feedObj
    }
}

class NestedTableView: UITableView {
    override var intrinsicContentSize: CGSize {
        self.layoutIfNeeded()
        return self.contentSize
    }
    
    override var contentSize: CGSize {
        didSet{
            self.invalidateIntrinsicContentSize()
        }
    }
}


extension NewImageFeedCell : ReloadDelegate {
    func reloadRow(){
        self.cellDelegate.reloadRow(indexObj: indexPathMain, feedObj: self.postObj)
    }
}
