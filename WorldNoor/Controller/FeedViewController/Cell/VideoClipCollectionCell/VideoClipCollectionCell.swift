//
//  VideoClipCollectionCell.swift
//  WorldNoor
//
//  Created by Raza najam on 4/10/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import UIKit

class VideoClipCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var lblviewCount: UILabel!
    @IBOutlet weak var viewCount: UIView!
    @IBOutlet weak var progressLbl: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var selectLangBtn: UIButton!
    @IBOutlet weak var opacityView: UIView!
    @IBOutlet weak var videoDeleteBtn: UIButton!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var viewShimmer: ShimmerView!
    var currentIndexPath:IndexPath?
    var requestObj:RequestManagerUploading?
    var feedObj:FeedVideoModel?
    var langSelection:LanguageModel?
//    var viewMain : FeedHeaderView!
    
    public var progress: CGFloat = 0 {
        didSet {
            self.progressLbl.text = "\(Int(progress))%"
            if progress > 100 {
                self.progressLbl.text = "100%"
            }
        }
    }
    
    override func awakeFromNib() {
        self.nameLbl.dynamicSubheadRegular15()
    }
    
    func manageData(feedObj:FeedVideoModel, indexPath:IndexPath){
        self.currentIndexPath = indexPath
        self.feedObj = feedObj
        self.selectLangBtn.tag = indexPath.row
        self.submitBtn.tag = indexPath.row
        self.manageGenericData()
        self.videoDeleteBtn.tag = indexPath.row

//        if feedObj.status == "toUpload" {
//            self.manageToUpload()
//        }else if feedObj.status == "Uploading" {
//            if  FeedCallBManager.shared.cacheVideoClipDict[self.feedObj!.identifierString] != nil  {
//                self.manageUploadinStatus()
//                self.requestObj = FeedCallBManager.shared.cacheVideoClipDict[self.feedObj!.identifierString]
//                self.requestObj?.delegate = self
//            }
//        }else if feedObj.status == "Uploaded" {
//            if  FeedCallBManager.shared.cacheVideoClipDict[self.feedObj!.identifierString] != nil  {
//                FeedCallBManager.shared.cacheVideoClipDict.removeValue(forKey: self.feedObj!.identifierString)
//            }
//            self.manageUploadedStatus()
//        }else if feedObj.status == "CreatingStory" {
//            self.manageCreateStoryStatus()
//        }else if feedObj.status == "processing" {
//            self.manageProcessing()
//        }else {
            if feedObj.internalidentifier == String(SharedManager.shared.getUserID()) {
                self.videoDeleteBtn.isHidden = false
            }
//        }


        self.labelRotateCell(viewMain: self.nameLbl)
        self.labelRotateCell(viewMain: self.lblviewCount)
        self.labelRotateCell(viewMain: self.thumbnailImageView)
        self.nameLbl.rotateForTextAligment()
        self.lblviewCount.rotateForTextAligment()

    }
    
    func manageGenericData(){
        self.progressLbl.isHidden = true
        self.submitBtn.isHidden = true
        self.selectLangBtn.isHidden = true
//        self.opacityView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        self.videoDeleteBtn.isHidden = true
    }
    
//    func manageToUpload(){
//        self.opacityView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
//        self.progressLbl.isHidden = false
//        self.submitBtn.isHidden = true
//        self.selectLangBtn.isHidden = true
//        self.requestObj = RequestManagerUploading.init()
////        self.requestObj?.delegate = self
//        self.requestObj?.callingService(feedObj: self.feedObj!)
//        FeedCallBManager.shared.cacheVideoClipDict[self.feedObj!.identifierString] = self.requestObj
//    }
    
//    func manageUploadinStatus(){
//        self.progressLbl.isHidden = false
//        self.submitBtn.isHidden = true
//        self.selectLangBtn.isHidden = true
//        self.opacityView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
//    }
    
//    func manageCreateStoryStatus(){
//        self.progressLbl.isHidden = true
//        self.submitBtn.isHidden = true
//        self.selectLangBtn.isHidden = true
//        self.opacityView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
//    }
//
//    func manageUploadedStatus(){
//        self.opacityView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
//        self.progressLbl.isHidden = true
//        self.submitBtn.isHidden = false
//        self.selectLangBtn.isHidden = true
//        if let langObj = self.feedObj?.langModel {
//            self.langSelection = langObj
//            self.selectLangBtn.setTitle(self.langSelection?.languageName, for: .normal)
//        }
//    }
    
//    func manageProcessing() {
//        self.progressLbl.isHidden = false
//        self.progressLbl.text = "Processing...".localized()
//        self.submitBtn.isHidden = true
//        self.selectLangBtn.isHidden = true
//        self.opacityView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
//    }
}

//extension VideoClipCollectionCell:RequestManagerUploadingProtocol {
//    func requestManagerUploadingStartedDelegate(uploadTag: Int) {
//        self.feedObj?.status = "Uploading"
//    }
//
//    func requestManagerProgressDelegate(progress: CGFloat , uploadTag: Int) {
//        self.progress = progress
//    }
//
//    func requestManagerResponseUploadedDelegate(res: Any , uploadTag: Int) {
//
//        self.feedObj? = FeedCallBManager.shared.videoClipArray[self.currentIndexPath!.row]
//
//        self.manageUploadedStatus()
//        if  FeedCallBManager.shared.cacheVideoClipDict[self.feedObj!.identifierString] != nil  {
//            FeedCallBManager.shared.cacheVideoClipDict.removeValue(forKey: self.feedObj!.identifierString)
//        }
//
//        let buttonMain = UIButton.init()
//        buttonMain.tag = self.currentIndexPath!.row
//        self.viewMain.submitVideoBtnClicked(sender: buttonMain)
//    }
//
//    func requestManagerResponseFailureDelegate(res: Any , uploadTag: Int) {
//
//    }
//}


class VideoClipUploadCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var btnUpload: UIButton!
    @IBOutlet weak var lblText: UILabel!
    @IBOutlet weak var imgViewUser: UIImageView!
    
    @IBAction func uploadAction(sender : UIButton){

    }
    
    override func awakeFromNib() {
        let fileName = "myImageToUpload.jpg"
        
        self.lblText.dynamicCaption2Bold11()
        self.lblText.numberOfLines = 0
        self.lblText.rotateViewForLanguage()
        self.imgViewUser.image = FileBasedManager.shared.loadImage(pathMain: fileName)
        self.labelRotateCell(viewMain: self.imgViewUser)
    }
}
