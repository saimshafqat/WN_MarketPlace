//
//  StoriesBtnView.swift
//  WorldNoor
//
//  Created by apple on 5/26/22.
//  Copyright © 2022 Raza najam. All rights reserved.
//

import Foundation
import UIKit
import FittedSheets


protocol igpreviewCellProtocols {
    func pauseAndPlayProtocol(with progressValue: Double?)
    func didtap(touchLocation : CGPoint)
    func pauseProtocol(completion : ((Double?) -> Void)?)
    func muteSnap(isMute : Bool,completion : ((Bool?) -> Void)?)
    func backButtonProtocol()
    func likeButtonProtocol(feedObj : FeedData!, dismissCompletion: (()->Void)?)
    func commentButtonProtocol(feedObj : FeedData!, dismissCompletion: (()->Void)?)
    func shareButtonProtocol(feedObj : StoryObject!, dismissCompletion: (()->Void)?)
    
}

class StoriesBtnView : UIView, ReactionDelegateResponse {
    @IBOutlet weak var pausePlayBtn: UIButton!
    @IBOutlet weak var muteUnmuteBtn: UIButton!
    
    var parentView : UIViewController!
    func reactionResponse(feedObj: FeedData) {
        self.reloadData(feedObjP: feedObj)
        SharedManager.shared.popover.dismiss()
    }
    let playImage = UIImage(named: "play-white")
       let pauseImage = UIImage(named: "pause-white")
    let unmuteImage = UIImage(systemName: "speaker.fill")
    let muteImage = UIImage(systemName: "speaker.slash.fill")
       // Boolean flag to track the current state
    var isPlaying = true 
    var isMute = true
    var modelObj : StoryObject!
        
    @IBOutlet var imgviewStoryUser : UIImageView!
    @IBOutlet var lblUserName : UILabel!
    @IBOutlet var lblLikes : UILabel!
    @IBOutlet var lblcomments : UILabel!
     
    @IBOutlet weak var reactionBtn: UIButton!
    @IBOutlet var btnUserProfile : UIButton!
    
    var storyIndex :Int!
    var point : CGPoint!
    var progressValue: Double? = 0.0
    var customDelegate : igpreviewCellProtocols?
    var feedObj = FeedData.init(valueDict: [String : Any]())
    override func awakeFromNib()
    {
        super.awakeFromNib()
    }

    @objc func callStatusChanged(notification: NSNotification) {
          let data = notification.object as! FeedData
   
        self.lblcomments.text = self.feedObj.commentCount?.description
       
      }
    
    @IBAction func reactionsBtnTapped(_ sender: Any) {
        LogClass.debugLog("Stories Reaction Tapped")
        self.customDelegate!.pauseProtocol { progress in
            self.progressValue = progress
        }
        let viewReaction = Bundle.main.loadNibNamed("ReactionView", owner: self, options: nil)?.first as! ReactionView
        viewReaction.earlyUpdateReactionCompletion = {[weak self] reactionImg, index in
            guard let self else { return }
            self.reactionBtn.setBackgroundImage(UIImage.init(named: "Img" + reactionImg+".png"), for: .normal)
            SharedManager.shared.popover.dismiss()
        }
        
        self.feedObj.postID = Int(self.modelObj.videoID)
        viewReaction.feedObj = self.feedObj
        viewReaction.isfromStory = true
        if (UIScreen.main.bounds.size.width - 40) < 360 {
                    viewReaction.frame = CGRect.init(x: 0, y: 0, width: (UIScreen.main.bounds.size.width - 40), height: 30)

                }else {
                    viewReaction.frame = CGRect.init(x: 0, y: 0, width: 360, height: 30)

                }
        SharedManager.shared.popover = Popover(options: SharedManager.shared.popoverOptions)
        SharedManager.shared.popover.willShowHandler = {
            LogClass.debugLog("Will show handler")
        }
        SharedManager.shared.popover.didShowHandler = {
            LogClass.debugLog("Did show handler")
        }
        SharedManager.shared.popover.willDismissHandler = {
            LogClass.debugLog("Will dismiss handler")
            self.customDelegate?.pauseAndPlayProtocol(with: self.progressValue)
        }
        SharedManager.shared.popover.didDismissHandler = {
            LogClass.debugLog("Did dismiss handler")
        }
        SharedManager.shared.popover.show(viewReaction, fromView: self.reactionBtn)
        
        viewReaction.delegateReaction = self
    }
    
    func dislikeLike(){
        let userToken = SharedManager.shared.userToken()
        let parameters = ["action": "react", "token":userToken, "type": self.feedObj.isReaction! , "post_id":String(self.feedObj.postID!)]
        DispatchQueue.global(qos: .userInitiated).async {
            RequestManager.fetchDataPost(Completion: { response in
//                SharedManager.shared.hideLoadingHubFromKeyWindow()
                Loader.stopLoading()
                DispatchQueue.main.async {
                    switch response {
                    case .failure(let error):
                        SwiftMessages.apiServiceError(error: error)
                    case .success(let res):
                        if res is Int {
                            AppDelegate.shared().loadLoginScreen()
                        }else if res is String {
                                                        SwiftMessages.showMessagePopup(theme: .error, title: "Alert", body: res as? String ?? .emptyString)
                        }else {
                            if self.feedObj.reationsTypesMobile != nil {
                                if self.feedObj.reationsTypesMobile!.count > 0  {
                                    for obj in 0..<self.feedObj.reationsTypesMobile!.count {
                                        
                                        if self.feedObj.reationsTypesMobile![obj].type == self.feedObj.isReaction {
                                            self.feedObj.reationsTypesMobile![obj].count! = self.feedObj.reationsTypesMobile![obj].count! - 1
                                            if self.feedObj.reationsTypesMobile![obj].count! == 0 {
                                                self.feedObj.reationsTypesMobile!.remove(at: obj)
                                            }
                                            break
                                        }
                                    }
                                }
                            }
                            if self.feedObj.likeCount == nil {
                                self.feedObj.likeCount = 0
                            }else {
                                self.feedObj.likeCount =  self.feedObj.likeCount! - 1
                            }
                            self.feedObj.isReaction = ""
                            self.reloadData(feedObjP: self.feedObj)
                            
                        }
                    }
                }
            }, param:parameters)

        }
    }
    
    @IBAction func shareBtnAction(_ sender: Any) {
        self.customDelegate!.pauseProtocol { progress in
            self.progressValue = progress
        }
        self.customDelegate?.shareButtonProtocol(feedObj: self.modelObj, dismissCompletion: {
            self.customDelegate?.pauseAndPlayProtocol(with: self.progressValue)
        })
    }
    
    
    @IBAction func commentBtnAction(_ sender: Any)
    {
        self.customDelegate!.pauseProtocol { progress in
            self.progressValue = progress
        }
        self.feedObj.postID = Int(self.modelObj.videoID)
        self.feedObj.authorName = self.modelObj.authorName
        self.feedObj.commentCount = Int(self.modelObj.commentCount)
        self.feedObj.liveThumbUrlStr = self.modelObj.authorImage
        self.feedObj.comments = self.modelObj.comments
        self.customDelegate?.commentButtonProtocol(feedObj : feedObj, dismissCompletion: {
            self.customDelegate?.pauseAndPlayProtocol(with: self.progressValue)
        })
    }
    
    @IBAction func likeButtonTapped(_ sender: Any) {
        self.feedObj.postID = Int(self.modelObj.videoID)
        if self.modelObj.reationsTypesMobile != nil {
            self.feedObj.storyReactionMobile = self.modelObj.reationsTypesMobile
        }
        self.customDelegate!.pauseProtocol { progress in
            self.progressValue = progress
        }
        self.customDelegate?.likeButtonProtocol(feedObj : feedObj, dismissCompletion: {
            self.customDelegate?.pauseAndPlayProtocol(with: self.progressValue)
        })
    }
    
    @IBAction func userProfile(sender : UIButton){
        if let topStory = UIApplication.topViewController()! as? VideoConsumptionPageViewController {
            topStory.openUserProfile()
        }
    }
    @IBAction func muteUnmuteBtnTapped(_ sender: Any) {
        
        self.muteUnmuteBtn.isSelected.toggle()
            self.customDelegate?.muteSnap(isMute: isMute, completion: { muteVal in
                self.isMute = muteVal ?? false
            })
    }
    
    @IBAction func backAction(sender : UIButton){
        self.customDelegate?.backButtonProtocol()
    }
    
    @IBAction func playPauseBtnTapped(_ sender: Any) {
        if isPlaying {
            pausePlayBtn.setImage(playImage, for: .normal)
              // Pause logic
              self.customDelegate?.pauseProtocol { progress in
                  self.progressValue = progress
              }
          } else {
              pausePlayBtn.setImage(pauseImage, for: .normal)
              // Resume logic
              self.customDelegate?.pauseAndPlayProtocol(with: self.progressValue)
          }
          
          // Toggle the state
          isPlaying.toggle()
          // Update the button image based on the state
        
      }
    
    @IBAction func moreAction(sender : UIButton){
        LogClass.debugLog("self.parentView  ==>")
        LogClass.debugLog(self.parentView)
        
        pausePlayBtn.setImage(playImage, for: .normal)
          // Pause logic
          self.customDelegate?.pauseProtocol { progress in
              self.progressValue = progress
          }
        
        (self.parentView as? IGStoryPreviewController)!.showReportSheet(feedObj: self.feedObj)
    }

    
    @IBAction func pauseButton(sender : UIButton){
        
        self.customDelegate?.didtap(touchLocation: self.point)
       
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        self.point = point
        return true
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
    }
    func reloadData(){
        self.lblcomments.text = self.modelObj.commentCount
        self.lblLikes.text = self.modelObj.reactionCount
        
        self.lblUserName.text = self.modelObj.authorName
        self.imgviewStoryUser.loadImageWithPH(urlMain: self.modelObj.authorImage)
        if self.modelObj.postType == "image"{
            self.muteUnmuteBtn.isHidden = true
        }
        self.feedObj.postID = Int(self.modelObj.videoID)
        self.feedObj.commentCount = Int(self.modelObj.commentCount)
        self.feedObj.comments = self.modelObj.comments
        self.feedObj.likeCount = Int(self.lblLikes.text!)
        if self.feedObj.isReaction != nil{
            if self.modelObj.isReaction!.count > 0  {
                
                self.reactionBtn.setBackgroundImage(UIImage.init(named: "Img" + self.modelObj.isReaction!+".png"), for: .normal)
            }
            if (self.modelObj.reationsTypesMobile.count == 0)
            {     self.reactionBtn.setBackgroundImage(UIImage(named: "selected_heart"), for: .normal)
            }
        }

    }
    func reloadData(feedObjP : FeedData ){
        self.feedObj = feedObjP
        
        if (self.modelObj.snapIndex < FeedCallBManager.shared.videoClipArray[self.storyIndex].snaps.count)
        {
            FeedCallBManager.shared.videoClipArray[self.storyIndex].snaps[self.modelObj.snapIndex].reationsTypesMobile  = feedObjP.storyReactionMobile
            FeedCallBManager.shared.videoClipArray[self.storyIndex].snaps[self.modelObj.snapIndex].isReaction = feedObjP.isReaction
            FeedCallBManager.shared.videoClipArray[self.storyIndex].snaps[self.modelObj.snapIndex].reactionCount = feedObjP.likeCount!.description
            
            if feedObj.commentCount != nil {
                FeedCallBManager.shared.videoClipArray[self.storyIndex].snaps[self.modelObj.snapIndex].commentCount = feedObj.commentCount!.description
            }

        self.manageCount()
        }
    }
    
    func manageCount(){
        if let likeCounter = self.feedObj.likeCount {
            var counterValue = ""
            if likeCounter == 0 {
                counterValue = "0"
            }else {
                counterValue = String(likeCounter)
            }
            self.lblLikes.text = counterValue
        }
                
        if let commentCount = self.feedObj.commentCount {
            var counterValue = ""
            if commentCount == 0 {
                counterValue = "0"
            }else {
                counterValue = " " + String(commentCount)
            }
            self.lblcomments.text = counterValue
        }
        
        if self.feedObj.isReaction != nil{
            if self.feedObj.isReaction!.count > 0  {
                
                self.reactionBtn.setBackgroundImage(UIImage.init(named: "Img" + self.feedObj.isReaction!+".png"), for: .normal)
            }
            if (self.feedObj.storyReactionMobile.count == 0)
            {                self.reactionBtn.setBackgroundImage(UIImage(named: "selected_heart"), for: .normal)
            }
            
            
        }

    }
}
