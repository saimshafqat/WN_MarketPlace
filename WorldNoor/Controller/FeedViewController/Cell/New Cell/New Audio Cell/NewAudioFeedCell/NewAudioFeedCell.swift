//
//  NewAudioFeedCell.swift
//  WorldNoor
//
//  Created by apple on 11/9/21.
//  Copyright © 2021 Raza najam. All rights reserved.
//

import Foundation
import UIKit
//import SwiftLinkPreview

class NewAudioFeedCell : UITableViewCell {
    
    @IBOutlet var tblViewImg : UITableView!
    
    var postObj : FeedData!
    var indexPathMain : IndexPath!
    var isFromProfile: Bool = false
    var cellDelegate : CellDelegate!
    
    var typeRow = [Int]()
//    private let slp = SwiftLinkPreview(cache: InMemoryCache())
    var playerView : NewSingleAudioCell!
    override func awakeFromNib() {
        self.tblViewImg.register(UINib.init(nibName: "NewHeaderFeedCell", bundle: nil), forCellReuseIdentifier: "NewHeaderFeedCell")
        self.tblViewImg.register(UINib.init(nibName: "NewTextHeaderCell", bundle: nil), forCellReuseIdentifier: "NewTextHeaderCell")
        self.tblViewImg.register(UINib.init(nibName: "NewSingleAudioCell", bundle: nil), forCellReuseIdentifier: "NewSingleAudioCell")
        self.tblViewImg.register(UINib.init(nibName: "NewLikeCell", bundle: nil), forCellReuseIdentifier: "NewLikeCell")
        self.tblViewImg.register(UINib.init(nibName: "NewLikeViewCell", bundle: nil), forCellReuseIdentifier: "NewLikeViewCell")
        self.tblViewImg.register(UINib.init(nibName: "NewLinkPreviewCell", bundle: nil), forCellReuseIdentifier: "NewLinkPreviewCell")


    }
    
    
    func stopPlayer()
    {
        if self.playerView != nil {
            self.playerView.stopPlayer()
        }
    }

    func reloadData(){
        self.typeRow.removeAll()
        self.typeRow.append(0)
        self.typeRow.append(1)
        if self.postObj.body != nil {
            
        }
        
        
        self.typeRow.append(2)
        self.typeRow.append(3)
       
        self.tblViewImg.reloadData()
    }
}


extension NewAudioFeedCell : UITableViewDelegate , UITableViewDataSource {
    
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
        }else if self.typeRow[indexPath.row] == 2 {
            return NewSingleAudioCell(tableView: tableView, cellForRowAt: indexPath)
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
        headerCell.isFromProfile = isFromProfile
        headerCell.selectionStyle = .none
        headerCell.cellDelegate = cellDelegate
        return headerCell
    }
    
    func textHeaderCell(tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let headerTextCell = tableView.dequeueReusableCell(withIdentifier: "NewTextHeaderCell", for: indexPath) as! NewTextHeaderCell
        headerTextCell.feedObj = self.postObj
        headerTextCell.reloadHeaderData()
        headerTextCell.layoutIfNeeded()
        headerTextCell.cellDelegate = self
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
    
    
    func NewSingleAudioCell(tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let audioCell = tableView.dequeueReusableCell(withIdentifier: "NewSingleAudioCell", for: indexPath) as! NewSingleAudioCell
        let postFile:PostFile = postObj.post![0]
        playerView = audioCell
        
        audioCell.postObj = self.postObj
        audioCell.manageCellData()
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

extension NewAudioFeedCell : LikeCellDelegate {
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


extension NewAudioFeedCell : ReloadDelegate {
    func reloadRow(){
        self.cellDelegate.reloadRow(indexObj: indexPathMain, feedObj: self.postObj)
    }
}
