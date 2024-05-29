//
//  FeedTopBarView.swift
//  WorldNoor
//
//  Created by Raza najam on 9/19/19.
//  Copyright © 2019 Raza najam. All rights reserved.
//

import UIKit

class FeedTopBarView: UIView {
    
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var postTypeDescLbl: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var descriptionLbl: UITextView!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var speakerButton: UIButton!
    @IBOutlet weak var viewBtnSpeakerView: UIView!
    @IBOutlet weak var viewOrignalBtn: UIButton!
    @IBOutlet weak var viewBtnViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var dropDownPostBtn: UIButton!
    @IBOutlet weak var orignallyPostedLbl: UILabel!
    @IBOutlet weak var sharedWidthConsth: NSLayoutConstraint!
    @IBOutlet weak var orignalPostedWidth: NSLayoutConstraint!
    @IBOutlet weak var nameWidthConst: NSLayoutConstraint!
    @IBOutlet weak var linkPreview: NSLayoutConstraint!
    @IBOutlet weak var linkPreviewCustom: UIView!
    @IBOutlet weak var descHeightConst: NSLayoutConstraint!

    var linkViewRef:LinkPreview!
    var feedObj:FeedData? = nil
    var indexValue:IndexPath = IndexPath(row: 0, section: 0)
    var postSelected: ((IndexPath) -> Void)?
    var updateSingleRow:((IndexPath)->())?

    override class func awakeFromNib() {
    }
    
    deinit {
        FeedCallBManager.shared.speakerHandler = nil
    }
    
    func defaultHandling(){
        self.viewOrignalBtn.isSelected = false
    }
    
    func manageHeaderData(feedObj:FeedData) {
        self.feedObj = feedObj
        self.defaultHandling()
        self.speakerButton.isSelected = false
        self.manageSpeakerIcon()
        self.nameLbl.text = feedObj.authorName
//        self.userImageView.sd_setImage(with: URL(string: feedObj.profileImage ?? ""), placeholderImage: UIImage(named: "placeholder"))
        
        self.userImageView.loadImageWithPH(urlMain:feedObj.profileImage ?? "")
        
        self.labelRotateCell(viewMain: self.userImageView)
        self.dateLbl.text = feedObj.postedOn
        self.manageDescTextView()
        self.dateLbl.text = feedObj.postedTime
        self.managePostTitleLabel()
        self.manageLinkPreview()
        
        
        self.labelRotateCell(viewMain: self.nameLbl)
        self.labelRotateCell(viewMain: self.postTypeDescLbl)
        self.labelRotateCell(viewMain: self.dateLbl)
        self.labelRotateCell(viewMain: self.viewOrignalBtn)
        self.labelRotateCell(viewMain: self.descriptionLbl)
        self.viewOrignalBtn.rotateForTextAligment()
        self.labelRotateCell(viewMain: self.userImageView)
        
    }
    
    func manageDescTextView() {
        if SharedManager.shared.isTransCalled {
            self.descriptionLbl.text = self.feedObj?.orignalBody
            self.viewOrignalBtn.isSelected = true
        }else {
            self.descriptionLbl.text = self.feedObj?.body
        }
        let descText = self.descriptionLbl.text.trimmingCharacters(in: .whitespaces)
        if descText != "" {
            if self.descriptionLbl.text != nil {
                let langDirection = SharedManager.shared.detectedLangauge(for: self.descriptionLbl.text!) ?? "left"
                (langDirection == "right") ? (self.descriptionLbl.textAlignment = NSTextAlignment.right): (self.descriptionLbl.textAlignment = NSTextAlignment.left)
            }
            let langCode = SharedManager.shared.detectedLangaugeCode(for: self.descriptionLbl.text!)
            if langCode == "ar" {
                self.descriptionLbl.font = UIFont(name: "BahijTheSansArabicPlain", size: self.descriptionLbl.font!.pointSize)
            }else {
                self.descriptionLbl.font = UIFont.systemFont(ofSize: self.descriptionLbl.font!.pointSize)
            }
            let someHeight = self.descriptionLbl.getHeightFrame(self.descriptionLbl).height
            if someHeight > 200 {
                self.descHeightConst.constant = 200
            }else {
                self.descHeightConst.constant = someHeight
            }
        }else {
            self.descHeightConst.constant = 0
        }
    }
    
    func manageLinkPreview() {
        self.linkPreview.constant = 0
        if self.linkViewRef != nil {
            self.linkViewRef.removeFromSuperview()
        }
        if let linkValue = self.feedObj?.previewLink {
            if linkValue != "" {
                self.linkPreview.constant = 90
                let linkView = Bundle.main.loadNibNamed(Const.klinkPreview, owner: self, options: nil)?.first as! LinkPreview
                self.linkPreviewCustom.addSubview(linkView)
                self.linkViewRef = linkView
                self.linkViewRef.manageData(feedObj: self.feedObj!)
                linkView.translatesAutoresizingMaskIntoConstraints = false
                linkView.leadingAnchor.constraint(equalTo: self.linkPreviewCustom.leadingAnchor, constant: 0).isActive = true
                linkView.trailingAnchor.constraint(equalTo: self.linkPreviewCustom.trailingAnchor, constant: 0).isActive = true
                linkView.topAnchor.constraint(equalTo: self.linkPreviewCustom.topAnchor, constant: 0).isActive = true
                linkView.bottomAnchor.constraint(equalTo: self.linkPreviewCustom.bottomAnchor, constant: 0).isActive = true
                self.linkViewRef.linkPreviewBtn.addTarget(self, action: #selector(openLinkPreview), for: .touchUpInside)
            }
        }
    }
    
    @IBAction func profileBtnClicked(_ sender: Any) {
        
        FeedCallBManager.shared.userProfileHandler?(String(self.feedObj!.authorID!))
        
    }
    @objc func openLinkPreview(){
        FeedCallBManager.shared.linkPreviewUpdateHandler?(self.feedObj?.previewLink ?? "")
    }
    
    func managePostTitleLabel(){
        let screenSize = CGRect.init(x: 0, y: 0, width: 100, height: self.frame.size.height)
 
        
        
        if self.feedObj!.isLive == 1 {
            self.self.postTypeDescLbl.text = "is".localized()
            self.orignallyPostedLbl.text = "Live".localized()
            self.orignalPostedWidth.constant = 50
        }else if self.feedObj!.liveStreamID != nil {
            self.self.postTypeDescLbl.text = "was".localized()
            self.orignallyPostedLbl.text = "Live".localized()
            self.orignalPostedWidth.constant = 50
        }else if self.feedObj!.postType == FeedType.shared.rawValue {
            self.orignalPostedWidth.constant = screenSize.width - CGFloat(230)
            self.nameWidthConst.constant = 116
            self.postTypeDescLbl.text = "shared".localized()
            if SharedManager.shared.getUserID() == self.feedObj?.sharedData?.authorID {
                self.orignallyPostedLbl.text = "his".localized() + " " + self.feedObj!.sharedData!.postType!
            }else {
                self.orignallyPostedLbl.text = "post of".localized() + " " + self.feedObj!.sharedData!.authorName!
            }
        }else {
            self.orignalPostedWidth.constant = 0
            self.nameWidthConst.constant = 200
            
            self.postTypeDescLbl.text = "shared a".localized() + " " + self.feedObj!.postType!.localized()
        }
        
        self.frame.size = CGSize.init(width: UIScreen.main.bounds.width - 20, height: self.frame.size.height)
    }
    
    func manageSpeakerIcon() {
        if self.feedObj?.isSpeakerPlaying == false {
            self.speakerButton.isSelected = false
        }else {
            self.speakerButton.isSelected = true
        }
        self.speakerButton.isHidden = false
        self.viewBtnViewConstraint.constant = 30
        if let someMessage = self.feedObj?.body {
            if someMessage == "" {
                self.viewBtnViewConstraint.constant = 0
                self.speakerButton.isHidden = true
                self.viewOrignalBtn.isHidden = true
            }else {
                let langCode = (SharedManager.shared.userBasicInfo["language_id"] as? Int) ?? -1
                if let contentLangCode = self.feedObj?.language?.codeID {
                    if langCode == contentLangCode {
                        self.viewOrignalBtn.isHidden = true
                    }else {
                        self.viewOrignalBtn.isHidden = false
                    }
                }else {
                    self.viewOrignalBtn.isHidden = true
                }
            }
        }else {
            self.viewBtnViewConstraint.constant = 0
            self.speakerButton.isHidden = true
            self.viewOrignalBtn.isHidden = true
        }
    }
    
    @IBAction func postButtonClicked(_ sender: Any) {
        self.postSelected?(indexValue)
    }
    
    @IBAction func speakerButtonClicked(_ sender: Any) {
//        SpeechManager.shared.isFromChat = false
        if self.speakerButton.isSelected {
            SpeechManager.shared.stopSpeaking()
        }else {
            FeedCallBManager.shared.speakerHandler!(IndexPath(row: 100000, section: 0), false)
            if self.viewOrignalBtn.isSelected {
                if let messageAvailable = self.feedObj?.orignalBody {
                    SpeechManager.shared.textToSpeech(message:messageAvailable)
                }
            }else {
                if let messageAvailable = self.feedObj?.body {
                    SpeechManager.shared.textToSpeech(message:messageAvailable)
                }
            }
            FeedCallBManager.shared.speakerHandler!(indexValue, false)
        }
        self.speakerButton.isSelected = !self.speakerButton.isSelected
    }
    
    @IBAction func viewOrignalButtonClicked(_ sender: Any) {
        self.viewOrignalBtn.isSelected = !self.viewOrignalBtn.isSelected
        if self.viewOrignalBtn.isSelected {
            self.descriptionLbl.text = self.feedObj?.orignalBody
        }else {
            self.descriptionLbl.text = self.feedObj?.body
        }
        if self.descriptionLbl.text != nil {
            let langDirection = SharedManager.shared.detectedLangauge(for: self.descriptionLbl.text!) ?? "left"
            (langDirection == "right") ? (self.descriptionLbl.textAlignment = NSTextAlignment.right): (self.descriptionLbl.textAlignment = NSTextAlignment.left)
            let langCode = SharedManager.shared.detectedLangaugeCode(for: self.descriptionLbl.text!)
            if langCode == "ar" {
                self.descriptionLbl.font = UIFont(name: "BahijTheSansArabicPlain", size: self.descriptionLbl.font!.pointSize)
            }else {
                self.descriptionLbl.font = UIFont.systemFont(ofSize: self.descriptionLbl.font!.pointSize)
            }
            
            
//            if SharedManager.shared.isTransCalled {
//                SharedManager.shared.isTransCalled = false
//            }else {
//                SharedManager.shared.isTransCalled = true
//            }
            self.updateSingleRow?(indexValue)
        }
    }
    
    @IBAction func dropDownPostButtonClicked(_ sender: Any) {
        FeedCallBManager.shared.dropDownFeedHanlder!(indexValue)
    }
}
