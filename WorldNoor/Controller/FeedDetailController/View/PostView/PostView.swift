//
//  PostView.swift
//  WorldNoor
//
//  Created by Raza najam on 10/21/19.
//  Copyright © 2019 Raza najam. All rights reserved.
//
protocol PostViewDelegate: AnyObject {
    func didSelectHashtag(hashtag: String)
}

import UIKit

class PostView: ParentFeedView {
    
    @IBOutlet weak var backBtn: UIButton!{
        didSet{
            backBtn.isHidden = true
        }
    }
    @IBOutlet weak var viewOrginalView: UIView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var btnUserProfile: UIButton!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var descriptionLbl: UITextView!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var viewOrignalBtn: UIButton!
    @IBOutlet weak var postSpeechBtn: UIButton!
    @IBOutlet weak var dropDownPostBtn: UIButton!
    @IBOutlet weak var viewOrignalHeightConst: NSLayoutConstraint!
    @IBOutlet weak var linkPreviewHeightConst: NSLayoutConstraint!
    @IBOutlet weak var linkPreviewCustom: UIView!
    @IBOutlet weak var descHeightConst: NSLayoutConstraint!
    weak var delegate: PostViewDelegate?
    var feedObj: FeedData?
    var linkViewRef: LinkPreview!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.viewOrignalBtn.setTitle("View Original".localized(), for: .selected)
        self.viewOrignalBtn.setTitle("View Translated".localized(), for: .normal)
    }
    
    func formatDateDifference(dateString: String) -> Int? {
        // Formatter for the input date string
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        guard let date = dateFormatter.date(from: dateString) else {
            return nil
        }
        let currentDate = Date()
        
        let daysDifference = Calendar.current.dateComponents([.day], from: date, to: currentDate).day!
            return daysDifference
    }


    func manageHeaderData(feedObj:FeedData) {
        
        self.feedObj = feedObj
        self.nameLbl.text = feedObj.authorName
        self.userImageView.loadImageWithPH(urlMain:feedObj.profileImage ?? "")
        
        self.labelRotateCell(viewMain: self.userImageView)
        let formattedDifference = formatDateDifference(dateString: feedObj.postedOn ?? "") ?? 0
        if formattedDifference < 6 && formattedDifference > 0{
            self.dateLbl.text = "\(formattedDifference)d ago"
        }
        else{
            self.dateLbl.text = feedObj.postedTime
        }
       
        self.descriptionLbl.text = feedObj.body
        self.manageDescTextView()
        self.manageLinkPreview()
        self.checkDescriptionValidation()
        
        
        
        self.rotateViewForLanguage()
        
        
        self.labelRotateCell(viewMain: self.nameLbl)
        nameLbl.rotateViewForLanguage()
        
        
        self.labelRotateCell(viewMain: self.dateLbl)
        dateLbl.rotateViewForLanguage()
        
        self.labelRotateCell(viewMain: self.descriptionLbl)
        descriptionLbl.rotateViewForLanguage()
        
        self.labelRotateCell(viewMain: self.viewOrignalBtn)
        self.viewOrignalBtn.rotateViewForLanguage()
        
    }
    
    func manageDescTextView() {
        
        self.descriptionLbl.text = self.feedObj?.body
        let descText = self.descriptionLbl.text.trimmingCharacters(in: .whitespaces)
        if descText != "" {
            if self.descriptionLbl.text != nil {
                let langDirection = SharedManager.shared.detectedLangauge(for: self.descriptionLbl.text!) ?? "left"
                (langDirection == "right") ? (self.descriptionLbl.textAlignment = NSTextAlignment.right): (self.descriptionLbl.textAlignment = NSTextAlignment.left)
            }
            let langCode = SharedManager.shared.detectedLangaugeCode(for: self.descriptionLbl.text!)
            if langCode == "ar" {
                self.descriptionLbl.font = UIFont(name: "BahijTheSansArabicPlain", size: self.descriptionLbl.font!.pointSize)
            } else {
                self.descriptionLbl.font = UIFont.systemFont(ofSize: self.descriptionLbl.font!.pointSize)
            }
            
            
            let someHeight = self.descriptionLbl.getHeightFrame(self.descriptionLbl).height
            self.descHeightConst.constant = someHeight
        } else {
            self.descHeightConst.constant = 0
        }
        self.descriptionLbl.isEditable = false

        // Set text with Helvetica Neue Regular font, size 20, and color
        let attributedText = NSMutableAttributedString(string: self.descriptionLbl.text)
        
        attributedText.addAttribute(.font, value: UIFont(name: "HelveticaNeue", size: 17) ?? .systemFont(ofSize: 17.0), range: NSRange(location: 0, length: attributedText.length))
        attributedText.addAttribute(.foregroundColor, value: UIColor.black, range: NSRange(location: 0, length: attributedText.length))
        
        let hashtagRegex = try! NSRegularExpression(pattern: "(#[\\p{L}0-9-_]+)", options: [])
        let matches = hashtagRegex.matches(in: attributedText.string, options: [], range: NSRange(location: 0, length: attributedText.length))
        
        for match in matches {
            let hashtagRange = match.range(at: 1)
            let hashtag = (attributedText.string as NSString).substring(with: hashtagRange)
            let hashtagURL = URL(string: "hashtag:\(hashtag)")
            attributedText.addAttribute(.link, value: hashtagURL, range: hashtagRange)
            attributedText.addAttribute(.foregroundColor, value: UIColor.link, range: hashtagRange)
       //     attributedText.addAttribute(.foregroundColor, value: UIColor.link, range: <#T##NSRange#>)

        }
        
        self.descriptionLbl.attributedText = attributedText
    }
    
    func manageLinkPreview() {
        self.linkPreviewHeightConst.constant = 0
        if self.linkViewRef != nil {
            self.linkViewRef.removeFromSuperview()
        }
        if let linkValue = self.feedObj?.previewLink {
            if linkValue != "" {
                self.linkPreviewHeightConst.constant = 90
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
    
    @objc func openLinkPreview(){
        FeedDetailCallbackManager.shared.FeedDetailPreviewLinkHandler?(self.feedObj?.previewLink ?? "")
    }
    
    @IBAction func backBtnAction(_ sender: Any) {
        
    }
    
    @IBAction func viewOrignalTranslationBtnClicked(_ sender: Any) {
        
        if self.feedObj?.orignalBody == nil {
            self.descriptionLbl.text = "Loading..."
            self.getTranslation()
        } else if self.feedObj!.orignalBody?.count == 0 {
            self.descriptionLbl.text = "Loading..."
            self.getTranslation()
        } else {
            if self.viewOrignalBtn.isSelected {
                self.descriptionLbl.text = self.feedObj?.body
            } else {
                self.descriptionLbl.text = self.feedObj?.orignalBody
            }
        }
        
        self.viewOrignalBtn.isSelected = !self.viewOrignalBtn.isSelected
        
        //
        let langDirection = SharedManager.shared.detectedLangauge(for: self.descriptionLbl.text ?? "")
        self.descriptionLbl.textAlignment = NSTextAlignment.left
        if langDirection == "right" {
            self.descriptionLbl.textAlignment = NSTextAlignment.right
        }
        
    }
    
    @IBAction func textToSpeechPostBtnClicked(_ sender: Any) {
        if self.postSpeechBtn.isSelected {
            SpeechManager.shared.stopSpeaking()
        }
        else {
            SpeechManager.shared.textToSpeech(message: (self.descriptionLbl.text)!)
        }
        self.postSpeechBtn.isSelected = !self.postSpeechBtn.isSelected
//        SpeechManager.shared.isAppearFrom = "FeedDetail"
        FeedDetailCallbackManager.shared.speakerHandlerFeedDetail = {[weak self] (indexPath) in
            self?.postSpeechBtn.isSelected = false
        }
    }
    
    func checkDescriptionValidation() {
        if let message = self.feedObj?.body {
            if message == "" {
                self.viewOrignalHeightConst.constant = 0
                self.viewOrginalView.isHidden = true
            }else {
                let langCode = (SharedManager.shared.userBasicInfo["language_id"] as? Int) ?? -1
                if let contentLangCode = self.feedObj?.language?.codeID {
                    if langCode == contentLangCode {
                        self.viewOrignalHeightConst.constant = 34
                        self.viewOrginalView.isHidden = false
                        self.postSpeechBtn.isHidden = false
                        self.viewOrignalBtn.isHidden = true
                    }
                }else {
                    self.viewOrignalHeightConst.constant = 34
                    self.viewOrginalView.isHidden = false
                    self.postSpeechBtn.isHidden = false
                }
            }
        } else {
            self.viewOrignalHeightConst.constant = 0
            self.viewOrginalView.isHidden = true
        }
    }
    
    func getTranslation() {
        
        self.viewOrignalBtn.isHidden = true
        
        guard let postID = self.feedObj?.postID else {
            return
        }
        var parameters = ["action": "post/translation/" + String(postID)]
        
        var langCode = "en"
        
        
        if let strValue = UserDefaults.standard.value(forKey: "LangN") as? String {
            for indexObj in SharedManager.shared.populateLangData() {
                if indexObj.languageName == UserDefaults.standard.value(forKey: "LangN") as! String {
                    langCode = indexObj.languageCode
                    break
                }
            }
        } else {
            if let langID = SharedManager.shared.userBasicInfo["language_id"] as? Int   {
                for indexObj in SharedManager.shared.populateLangData() {
                    if Int(indexObj.languageID) == langID {
                        langCode = indexObj.languageCode
                        UserDefaults.standard.set(indexObj.languageName, forKey: "LangN")
                        UserDefaults.standard.synchronize()
                        break
                    }
                }
            }
        }
        
        parameters["lang_code"] = langCode
        RequestManager.fetchDataGet(Completion: { response in
            
            self.viewOrignalBtn.isHidden = false
            switch response {
            case .failure(let error):
                
                if error is String {
                    //                    SharedManager.shared.showAlert(message: Const.networkProblemMessage.localized(), view: self)
                }
            case .success(let res):
                if res is Int {
                    //                    AppDelegate.shared().loadLoginScreen()
                } else if res is String {
                    //                    SharedManager.shared.showAlert(message: res as! String, view: self)
                } else {
                    if let dataMain = res as? [String : Any] {
                    } else if let dataMain = res as? [[String : Any]] {
                        let mainData = dataMain[0]
                        if let stringValue = mainData["body"] as? String{
                            self.feedObj?.orignalBody = stringValue
                            
                            if self.viewOrignalBtn.isSelected {
                                self.descriptionLbl.text = self.feedObj!.orignalBody
                            } else {
                                self.descriptionLbl.text = self.feedObj!.body
                            }
                            
                            let langDirection = SharedManager.shared.detectedLangauge(for: self.descriptionLbl.text ?? "")
                            self.descriptionLbl.textAlignment = NSTextAlignment.left
                            if langDirection == "right" {
                                self.descriptionLbl.textAlignment = NSTextAlignment.right
                            }
                        }
                    }
                }
            }
        }, param:parameters)
    }
    
}

extension PostView : UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if let urlString = URL.absoluteString.removingPercentEncoding,
           let hashtag = urlString.components(separatedBy: ":#").last?.removingPercentEncoding {
            print("Clicked hashtag: \(hashtag)")
            delegate?.didSelectHashtag(hashtag: hashtag)
            // Handle clicked hashtag
            return false
        }
        return true
    }
}
