//
//  ReportingViewController.swift
//  WorldNoor
//
//  Created by Raza najam on 2/26/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import UIKit

@objc protocol DismissReportSheetDelegate {
    @objc optional func dimissReportSheetClicked(type:String, currentIndex:IndexPath)
    @objc optional func dimissReportSheetForCommentsClicked(type:String, currentIndex:IndexPath, isReply:Bool)
    @objc optional func dismissReportWithMessage(message:String)
    @objc optional func dismissUnSavedWith(msg: String, indexPath: IndexPath)
}

class ReportingViewController: UIViewController {
    
    var reportType:String = .emptyString
    var feedObj:FeedData?
    var commentObj:Comment?
    var reportArray:[String] = [String]()
    var reportDescArray = [String]()
    var reportImageDict:[String:String] = [:]
    var delegate: DismissReportSheetDelegate?
    var feedsDelegate: FeedsDelegate?
    
    var currentIndex:IndexPath = IndexPath(row: 0, section: 0)
    var isPartOf = ""
    var isReply:Bool = false
    
    @IBOutlet weak var reportTableView: UITableView!
    @IBOutlet weak var reportTableViewGroup: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.reportTableView.isHidden = false
        self.reportTableViewGroup.isHidden = true
        self.reportTableView.register(UINib.init(nibName: "PostMenuHeadingCell", bundle: nil), forCellReuseIdentifier: "PostMenuHeadingCell")
        self.reportTableViewGroup.register(UINib.init(nibName: "PostMenuHeadingCell", bundle: nil), forCellReuseIdentifier: "PostMenuHeadingCell")
        self.managArrayDataBasedOnType()
        self.reportTableView.estimatedRowHeight = 70
        self.reportTableView.rowHeight = UITableView.automaticDimension
        
        self.reportTableViewGroup.estimatedRowHeight = 70
        self.reportTableViewGroup.rowHeight = UITableView.automaticDimension
    }
    
    func managArrayDataBasedOnType() {
        let myUserID = SharedManager.shared.userObj?.data.id
        
        
        LogClass.debugLog("reportType ===>")
        LogClass.debugLog(reportType)
        
        
        if reportType == "Story" {
            self.reportArray = ["Copy Link".localized(),  "Rate your video playback experience".localized(), "Report Video".localized()]
            self.reportImageDict = ["Copy Link".localized():"ChatCopyN",
                                    "Rate your video playback experience".localized() : "PostReport" ,
                                    "Report Video".localized():"PostReport",
            ]
            self.reportDescArray = ["I want to share story.".localized(), "Copy story link to share with friends.".localized(),"I am concerned about this story.".localized()]
        }else if reportType == "Saved Reel" {
            self.reportArray = ["Un-save this reel".localized(), "Copy Link".localized(), "Report Video".localized()]
            self.reportImageDict = ["Un-save this reel".localized(): "PostSave",
                                    "Copy Link".localized():"ChatCopyN",
                                    "Report Video".localized():"PostReport",
            ]
            self.reportDescArray = ["I want to un-save video.".localized(), "Copy video link to share with friends.".localized(),"I am concerned about this video.".localized()]
        } else if reportType == "Reel" {
            if feedObj?.isSaved ?? false {
                self.reportArray = ["Un-save this reel".localized(), "Copy Link".localized(), "Report Video".localized()]
                self.reportImageDict = ["Un-save this reel".localized(): "PostSave",
                                        "Copy Link".localized():"ChatCopyN",
                                        "Report Video".localized():"PostReport",
                ]
                self.reportDescArray = ["I want to un-save video.".localized(), "Copy video link to share with friends.".localized(),"I am concerned about this video.".localized()]
            } else {
                self.reportArray = ["Save this reel".localized(),"View saved reels".localized(), "Copy Link".localized(), "Rate your video playback experience".localized(), "Report Video".localized()]
                
                self.reportImageDict = [ "Save this reel".localized():"PostSave",
                                         "View saved reels".localized():"hideAllIcon",
                                         "Copy Link".localized():"ChatCopyN",
                                         "Rate your video playback experience".localized():"PostReport",
                                         "Report Video".localized():"PostReport"
                ]
                self.reportDescArray = ["I want to save video.".localized(), "All your saved reels".localized(), "Copy video link to share with friends.".localized(),"For issues like frozen or blurry video".localized(),"I am concerned about this video.".localized()]
            }
            
        } else if reportType == "Post" {
            self.reportTableView.isHidden = true
              self.reportTableViewGroup.isHidden = false
              
              let authorID = self.feedObj?.authorID
              if myUserID == authorID {
                  self.reportArray = ["Edit".localized(), "Delete".localized(), "Save Post".localized()]
                  self.reportImageDict = [
                      "Edit".localized():"NT_Edit",
                      "Delete".localized():"NT_Delete",
                  ]
                  
                  if feedObj?.isSaved == true{
                      reportImageDict["UnSave".localized()] = "NT_Unsave"
                  } else {
                      reportImageDict["Save Post".localized()] = "PostSave"
                  }
                  
                  self.reportDescArray = ["Edit your post.".localized(), "Delete your post.".localized(), "Save this post to view later.".localized()]
              } else {
                  self.reportArray = ["Report".localized(), "Hide".localized(), String(format: "Hide all from".localized() + " %@", (self.feedObj?.authorName)!), String(format: "Block".localized() + " %@", (self.feedObj?.authorName)!)]
                  self.reportImageDict = [
                      "Report".localized():"PostReport",
                      "Hide".localized():"unhidePostIcon",
                      self.reportArray[2].localized():"PostHide",
                      self.reportArray[3].localized():"PostBlock",
                  ]
                  
                  
                  if self.feedObj?.postType == FeedType.video.rawValue {
                      self.reportDescArray = ["I am concerned about this video.".localized(), "I don't want to see this video.".localized(), "I don't want to see any video from this author.".localized(), "Block the autor of this video.".localized()]
                  }else {
                      self.reportDescArray = ["I am concerned about this post.".localized(), "I don't want to see this post.".localized(), "I don't want to see any post from this author.".localized(), "Block the autor of this post.".localized()]
                  }
                  
                  if feedObj?.isSaved == true{
                      reportImageDict["UnSave".localized()] = "NT_Unsave"
                      reportArray.append("UnSave".localized())
                      if self.feedObj?.postType == FeedType.video.rawValue {
                          reportDescArray.append("UnSave this video.".localized())
                      }else {
                          reportDescArray.append("UnSave this post.".localized())
                      }
                      
                  } else {
                      if self.feedObj?.postType == FeedType.video.rawValue {
                          reportImageDict["Save video".localized()] = "PostSave"
                          reportArray.append("Save video".localized())
                          reportDescArray.append("Save this video to view later.".localized())
                      }else {
                          reportImageDict["Save Post".localized()] = "PostSave"
                          reportArray.append("Save Post".localized())
                          reportDescArray.append("Save this post to view later.".localized())
                      }
                      
                  }
              }
        } else  if reportType == "Saved" {
            self.reportTableView.isHidden = true
            self.reportTableViewGroup.isHidden = false
            
            let authorID = self.feedObj?.authorID
            if myUserID == authorID {
                self.reportArray = ["UnSave".localized(), "Delete".localized()]
                self.reportImageDict = [
                    "UnSave".localized():"NT_Unsave",
                    "Delete".localized():"NT_Delete"
                ]
                self.reportDescArray = ["UnSave your saved post.".localized(), "Delete your post.".localized()]
            }else {
                self.reportArray = ["UnSave".localized(), "Report".localized(), "Hide".localized(), String(format: "Hide all from".localized() + " %@", (self.feedObj?.authorName)!), String(format: "Block".localized() + " %@", (self.feedObj?.authorName)!)]
                self.reportImageDict = [
                    "UnSave".localized():"NT_Unsave",
                    "Report".localized():"PostReport",
                    "Hide".localized():"PostHide",
                    self.reportArray[3]:"PostHide",
                    self.reportArray[4]:"PostBlock"
                ]
                self.reportDescArray = ["UnSave this post.".localized(), "I am concerned about this post.".localized(), "I don't want to see this post.".localized(), "I don't want to see any post from this author.".localized(), "Block the author of this post.".localized()]
            }
        } else  if reportType == "Memory" {
            let authorID = self.feedObj?.authorID
            if myUserID == authorID {
                self.reportArray = ["Delete".localized()]
                self.reportImageDict = [
                    "Delete".localized():"NT_Delete"
                ]
                self.reportDescArray = ["Delete your post.".localized()]
            }
        } else if reportType == "UnHidePost" {
            self.reportArray = ["UnHide".localized(), String(format: "UnHide all from".localized() + " %@", (self.feedObj?.authorName)!)]
            self.reportImageDict = [
                "UnHide".localized():"hideIcon",
                self.reportArray[1]:"hideAllIcon"
            ]
            self.reportDescArray = ["Unhide this post.".localized(), "UnHide all the posts of this author.".localized()]
        } else if reportType == "BlockUser" {
            self.reportArray = ["Report This User".localized(), "Hide".localized(), "Unblock".localized() ]
            self.reportImageDict = [
                "Report This User".localized():"PostReport",
                "Hide".localized():"hideIcon",
                "Unblock".localized():"blockUserIcon"
            ]
            self.reportDescArray = ["I am concerned about this User.".localized(), "I don't want to see any post from this author.".localized(), "Unblock this user to see all post.".localized()]
        } else if reportType == "User" {
            self.reportArray = ["Report This User".localized(), "Hide".localized(), "Block".localized() ]
            self.reportImageDict = [
                "Report This User".localized():"PostReport",
                "Hide".localized():"hideIcon",
                "Block".localized():"blockUserIcon"
            ]
            self.reportDescArray = ["I am concerned about this User.".localized(), "I don't want to see any post from this author.".localized(), "Block all post from this author.".localized()]
        } else if reportType == "Live" {
            self.reportArray = ["Save".localized(), "Don't Save".localized()]
            self.reportImageDict = [
                "Save".localized():"PostSave",
                "Don't Save".localized():"hideIcon"]
            self.reportDescArray = ["I want to save live stream video.".localized(), "I don't want to save live stream video.".localized()]
        } else {
            let postOwner = self.feedObj?.authorID
            if postOwner == myUserID {
                let authorID = self.commentObj?.author?.authorID
                if myUserID == authorID {
                    if self.isPartOf == "Feed" {
                        self.reportArray = ["Delete".localized()]
                        self.reportImageDict = ["Delete".localized():"NT_Delete"]
                        self.reportDescArray = ["Delete your comment.".localized()]
                    } else {
                        self.reportArray = ["Edit".localized(), "Delete".localized()]
                        self.reportImageDict = ["Edit".localized():"NT_Edit", "Delete".localized():"NT_Delete"]
                        self.reportDescArray = ["Edit your comment.".localized(), "Delete your comment.".localized()]
                    }
                } else {
                    self.reportArray = ["Report".localized(), "Delete".localized(), "Hide".localized()]
                    self.reportImageDict = ["Report".localized():"PostReport", "Delete".localized():"NT_Delete","Hide".localized():"hideIcon"]
                    self.reportDescArray = ["I am concerned about this comment.".localized(), "Delete your comment.".localized(), "I don't want to see this comment.".localized()]
                }
            } else {
                let authorID = self.commentObj?.author?.authorID
                if myUserID == authorID {
                    if self.isPartOf == "Feed" {
                        self.reportArray = ["Delete".localized()]
                        self.reportImageDict = ["Delete".localized():"NT_Delete"]
                        self.reportDescArray = ["Delete your comment.".localized()]
                    } else {
                        self.reportArray = ["Edit".localized(), "Delete".localized()]
                        self.reportImageDict = ["Edit".localized():"NT_Edit", "Delete".localized():"NT_Delete"]
                        self.reportDescArray = ["Edit your comment.".localized(), "Delete your comment.".localized()]
                    }
                } else {
                    self.reportArray = ["Report".localized(), "Hide".localized()]
                    self.reportImageDict = ["Report".localized():"PostReport", "Hide".localized():"hideIcon"]
                    self.reportDescArray = ["I am concerned about this comment.".localized(), "I don't want to see this comment.".localized()]
                }
            }
        }
    }
}

extension ReportingViewController:UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.reportTableViewGroup.isHidden {
         return 1
        }
        
        if self.reportType == "Post" {
            return 2
        }
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.reportTableView.isHidden {
            if section == 0 {
                return 1
            }else {
                return self.reportArray.count
            }
        }
        
        return self.reportArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.reportTableView.isHidden  {
            if indexPath.row == 0 && indexPath.section == 0 {
                if let cell = tableView.dequeueReusableCell(withIdentifier: "PostMenuHeadingCell", for: indexPath) as? PostMenuHeadingCell {
                    
                    if self.feedObj?.postType == FeedType.video.rawValue {
                        cell.lblHeading.text = "Why I am seeing this video?".localized()

                    }
                    
                    return cell
                }
            }
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: "FeedStatCell", for: indexPath) as? FeedStatCell {
                cell.userNameLbl.text = self.reportArray[indexPath.row]
                cell.userImage.image = UIImage.init(named: self.reportImageDict[cell.userNameLbl.text!] ?? "")
                cell.descLbl.text = self.reportDescArray[indexPath.row]
                return cell
            }
            
        }
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "FeedStatCell", for: indexPath) as? FeedStatCell {
            cell.userNameLbl.text = self.reportArray[indexPath.row]
            cell.userImage.image = UIImage.init(named: self.reportImageDict[cell.userNameLbl.text!] ?? "")
            cell.descLbl.text = self.reportDescArray[indexPath.row]
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        let reportSelectionType = self.reportArray[indexPath.row]
        var authorName = ""
        if self.feedObj != nil {
            authorName = (self.feedObj?.authorName)!
        }
        
        
        
        print("<==== indexPath  ===>")
        print(indexPath)
        let hideAllCheck = "Hide all from".localized() + " " + authorName
        let unhideAllCheck = "UnHide all from".localized() + " " + authorName
        
        if self.reportType == "Story" {
            if indexPath.row == 0 {
                
                if self.feedObj != nil {
                    if let fileID = self.feedObj?.postID {
                        let urlString = "https://worldnoor.com/stories?story=" + String(fileID)
                        UIPasteboard.general.string = urlString
                    }
                }
                self.dismiss(animated: true) {
                    self.delegate?.dimissReportSheetForCommentsClicked?(type:"", currentIndex: self.currentIndex, isReply: self.isReply)
                }
                
            
            }else if indexPath.row == 1 {
                self.dismiss(animated: true) {
                    self.delegate?.dimissReportSheetForCommentsClicked?(type:"Rate", currentIndex: self.currentIndex, isReply: self.isReply)
                }
            }else if indexPath.row == 2 {
                self.dismiss(animated: true) {
                    self.delegate?.dimissReportSheetForCommentsClicked?(type:"Report", currentIndex: self.currentIndex, isReply: self.isReply)
                }

            }
            
        }
        
        if self.reportType == "Post" {
            
            if indexPath.row == 0 && indexPath.section == 0 {
                return
            }
        }
        
        
        if reportType == "Saved Reel" {
            if reportSelectionType == "Un-save this reel".localized() {
                let parameters = ["action": "saved/unsave",
                                  "token": SharedManager.shared.userToken(),
                                  "post_id": String(self.feedObj!.postID!),
                                  "type" : "reels",
                                  "file_id" : String((self.feedObj!.post?[0].fileID)!)]
                self.callingService(type:reportSelectionType, parameters:parameters)
                
            } else if reportSelectionType == "Copy Link".localized() {
                if self.feedObj != nil {
                    if let fileID = self.feedObj?.post?[0].fileID {
                        let urlString = "https://worldnoor.com/reel/" + String(fileID)
                        UIPasteboard.general.string = urlString
                    }
                }
                self.dismiss(animated: true) {
                    self.delegate?.dimissReportSheetForCommentsClicked?(type:"", currentIndex: self.currentIndex, isReply: self.isReply)
                }
            } else if reportSelectionType == "Report Video".localized() {
                self.dismiss(animated: true) {
                    self.delegate?.dimissReportSheetForCommentsClicked?(type:"Report", currentIndex: self.currentIndex, isReply: self.isReply)
                }
            }
        } else if reportType == "Reel" {
            if feedObj?.isSaved ?? false && reportSelectionType == "Un-save this reel" {
                if reportSelectionType == "Un-save this reel".localized() {
                    let parameters = ["action": "saved/unsave",
                                      "token": SharedManager.shared.userToken(),
                                      "post_id": String(self.feedObj!.postID!),
                                      "type" : "reels",
                                      "file_id" : String((self.feedObj!.post?[0].fileID)!)]
                    self.callingService(type:reportSelectionType, parameters:parameters)
                    
                } else if reportSelectionType == "Copy Link".localized() {
                    if self.feedObj != nil {
                        if let fileID = self.feedObj?.post?[0].fileID {
                            let urlString = "https://worldnoor.com/reel/" + String(fileID)
                            UIPasteboard.general.string = urlString
                        }
                    }
                    self.dismiss(animated: true) {
                        self.delegate?.dimissReportSheetForCommentsClicked?(type:"", currentIndex: self.currentIndex, isReply: self.isReply)
                    }
                } else if reportSelectionType == "Report Video".localized() {
                    self.dismiss(animated: true) {
                        self.delegate?.dimissReportSheetForCommentsClicked?(type:"Report", currentIndex: self.currentIndex, isReply: self.isReply)
                    }
                }
            } else {
                if reportSelectionType == "View saved reels".localized() {
                    self.dismiss(animated: true) {
                        self.delegate?.dimissReportSheetForCommentsClicked?(type:"saved", currentIndex: self.currentIndex, isReply: self.isReply)
                    }
                } else if reportSelectionType == "Save this reel".localized() {
                    let parameters = ["action" : "saved/unsave",
                                      "token" : SharedManager.shared.userToken(),
                                      "post_id" : String(self.feedObj!.postID!),
                                      "type" : "reels",
                                      "file_id" : String((self.feedObj!.post?[0].fileID)!)]
                    self.callingService(type:reportSelectionType, parameters:parameters)
                } else if reportSelectionType == "Copy Link".localized() {
                    if self.feedObj != nil {
                        if let fileID = self.feedObj?.post?[0].fileID {
                            let urlString = "https://worldnoor.com/reel/" + String(fileID)
                            UIPasteboard.general.string = urlString
                        }
                    }
                    self.dismiss(animated: true) {
                        self.delegate?.dimissReportSheetForCommentsClicked?(type:"Copy", currentIndex: self.currentIndex, isReply: self.isReply)
                    }
                    
                }else if reportSelectionType == "Report Video".localized() {
                    self.dismiss(animated: true) {
                        self.delegate?.dimissReportSheetForCommentsClicked?(type:"Report", currentIndex: self.currentIndex, isReply: self.isReply)
                    }
                }else if reportSelectionType == "Rate your video playback experience".localized() {
                    self.dismiss(animated: true) {
                        self.delegate?.dimissReportSheetForCommentsClicked?(type:"Rate", currentIndex: self.currentIndex, isReply: self.isReply)
                    }
                }
            }
        } else if reportType == "BlockUser" {
            if reportSelectionType == "Hide".localized() {
                self.dismiss(animated: true) {
                    self.delegate?.dismissReportWithMessage?(message: "-1")
                }
            }else if reportSelectionType == "Report This User".localized() {
                self.dismiss(animated: true) {
                    self.delegate?.dismissReportWithMessage?(message: "-2")
                }
            }else if reportSelectionType == "Unblock".localized() {
                self.dismiss(animated: true) {
                    self.delegate?.dismissReportWithMessage?(message: "-4")
                }
            }
            
        } else if reportType == "User" {
            if reportSelectionType == "Hide".localized() {
                self.dismiss(animated: true) {
                    self.delegate?.dismissReportWithMessage?(message: "-1")
                }
            } else if reportSelectionType == "Report This User".localized() {
                self.dismiss(animated: true) {
                    self.delegate?.dismissReportWithMessage?(message: "-2")
                }
            } else if reportSelectionType == "Block".localized() {
                self.dismiss(animated: true) {
                    self.delegate?.dismissReportWithMessage?(message: "-3")
                }
            }
        } else if reportType == "Post" || reportType == "Saved" || reportType == "UnHidePost" || reportType == "Live" {
            if reportSelectionType == "Report".localized() {
                self.dismiss(animated: true) {
                    self.delegate?.dimissReportSheetClicked?(type: self.reportArray[indexPath.row] , currentIndex: self.currentIndex)
                }
            } else if reportSelectionType == "Delete".localized() {
                self.ShowAlertWithCompletaionText(message: "Are you sure to remove this Post?".localized(), noButtonText: "No".localized(), yesButtonText: "Yes".localized()) { (pStatus) in
                    if pStatus {
                        
                        let parameters = ["action": "post", "token": SharedManager.shared.userToken(), "post_id":String(self.feedObj!.postID!), "_method":"DELETE"]
                        self.callingService(type:reportSelectionType, parameters:parameters)
                    }
                }
                
            } else if reportSelectionType == "Hide".localized() {
                
                let parameters = ["action": "post/hide",
                                  "token": SharedManager.shared.userToken(),
                                  "post_id":String(self.feedObj!.postID!)]
                self.callingService(type: reportSelectionType, parameters: parameters)
                
            } else if reportSelectionType == hideAllCheck {
                let parameters = ["action": "post/hide_of_author",
                                  "token": SharedManager.shared.userToken(),
                                  "user_id": String(self.feedObj!.authorID!)]
                self.callingService(type:reportSelectionType, parameters:parameters)
            } else if reportSelectionType.contains("Block") {
                let parameters = ["action": "user/block_user", "token": SharedManager.shared.userToken(), "user_id":String(self.feedObj!.authorID!)]
                self.callingService(type:"Block", parameters:parameters)
            } else if reportSelectionType == "Save Post".localized() {
                let parameters = ["action": "post/save", "token": SharedManager.shared.userToken(),"post_id":String(self.feedObj!.postID!)]
                self.callingService(type:reportSelectionType, parameters:parameters)
            } else if reportSelectionType == "UnHide".localized() {
                let parameters = ["action": "post/unhide", "token": SharedManager.shared.userToken(),"post_id":String(self.feedObj!.postID!)]
                self.callingService(type:reportSelectionType, parameters:parameters)
            } else if reportSelectionType == unhideAllCheck{
                let parameters = ["action": "post/unhide_of_author", "token": SharedManager.shared.userToken(), "user_id":String(self.feedObj!.authorID!)]
                self.callingService(type:"UnHideAll", parameters:parameters)
            } else if reportSelectionType == "Edit".localized() {
                self.dismiss(animated: true) {
                    self.delegate?.dimissReportSheetClicked?(type: "Edit", currentIndex: self.currentIndex)
                }
            } else if reportSelectionType == "UnSave".localized() {
                let parameters = ["action": "saved/unsave", "token": SharedManager.shared.userToken(),"post_id":String(self.feedObj!.postID!)]
                self.callingService(type:reportSelectionType, parameters:parameters)
            } else if reportType == "Live" {
                if indexPath.row == 1 {
                    if self.feedObj?.postID != nil {
                        let parameters = ["action": "post", "token": SharedManager.shared.userToken(), "post_id":String(self.feedObj!.postID!), "_method":"DELETE"]
                        self.callingService(type:reportSelectionType, parameters:parameters)
                    }
                    
                }
                self.delegate?.dismissReportWithMessage?(message: reportSelectionType)
            }
        } else {
            if reportSelectionType == "Report".localized() {
                self.dismiss(animated: true) {
                    self.delegate?.dimissReportSheetForCommentsClicked?(type:"Report", currentIndex: self.currentIndex, isReply: self.isReply)
                }
            } else if reportSelectionType == "Delete".localized() {
                
                self.ShowAlertWithCompletaionText(message: "Are you sure to remove this Comment?".localized(), noButtonText: "No".localized(), yesButtonText: "Yes".localized()) { (pStatus) in
                    
                    if pStatus {
                        let parameters = ["action": "comment", "token": SharedManager.shared.userToken(), "comment_id":String(self.commentObj!.commentID!), "_method":"DELETE"]
                        self.callingService(type:reportSelectionType, parameters:parameters, isPost: false)
                    }
                }
            } else if reportSelectionType == "Edit".localized() {
                self.dismiss(animated: true) {
                    self.delegate?.dimissReportSheetForCommentsClicked?(type:"Edit", currentIndex: self.currentIndex, isReply: self.isReply)
                }
            } else if reportSelectionType == "Hide".localized() {
                let parameters = ["action": "comment/hide", "token": SharedManager.shared.userToken(), "comment_id":String(self.commentObj!.commentID!)]
                self.callingService(type:reportSelectionType, parameters:parameters, isPost: false)
            }
        }
    }
    
    func callingService(type:String, parameters: [String:Any], isPost:Bool = true){
        Loader.startLoading()
        RequestManager.fetchDataPost(Completion: { response in
            Loader.stopLoading()
            switch response {
            case .failure(let error):
                SwiftMessages.apiServiceError(error: error)
            case .success(let res):
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                } else if res is String {
                    LogClass.debugLog("type ===>")
                    LogClass.debugLog(type)
                    LogClass.debugLog(self.reportType)
                    if (type == "Save Post".localized()) && (res as! String == "Saved successfully") {
                        NotificationCenter.default.post(name: .SavedPost, object: nil, userInfo: nil)
                    }
                    
                    self.dismiss(animated: true) {
                        let msg = res as? String ?? .emptyString
                        self.delegate?.dismissReportWithMessage?(message: msg.capitalized)
                        self.delegate?.dismissUnSavedWith?(msg: res as? String ?? .emptyString, indexPath: self.currentIndex)
                        
                        if type == "Delete".localized() && self.reportType == "Post" {
                            // remove post from list
                            let postID = parameters["post_id"] as! String
                            self.feedsDelegate?.deletePost(postID: Int(postID) ?? 0, currentIndex: self.currentIndex)
                            self.delegate?.dimissReportSheetClicked?(type: type, currentIndex: self.currentIndex)
                        }
                        
                        if (parameters["action"] as? String ) == "post/hide" {
                            let postID = parameters["post_id"] as! String
                            self.feedsDelegate?.deletePost(postID: Int(postID) ?? 0, currentIndex: self.currentIndex)
                        }
                        
                        if (parameters["action"] as? String ) == "post/hide_of_author" {
                            let userID = parameters["user_id"] as! String
                            self.feedsDelegate?.deleteAllPostsFromAuther(autherID: Int(userID) ?? 0, currentIndex: self.currentIndex)
                        }
                    }
                    
                    if (self.reportType == "Post") && (type == "Save Post".localized()) {
                        self.feedObj?.isSaved = true
                    }
                    if (self.reportType == "Post") && (type == "UnSave".localized()) {
                        self.feedObj?.isSaved = false
                    }
                    if  self.reportType == "Reel" && (type == "Save this reel".localized()) {
                        self.feedObj?.isSaved = true
                    }
                    if (self.reportType == "Reel") && (type == "Un-save this reel".localized()) {
                        self.feedObj?.isSaved = false
                    }
                    if (type == "Delete".localized()) || (type == "Hide".localized()) && (self.reportType == "Comment") {
                        self.delegate?.dimissReportSheetClicked?(type: type, currentIndex: self.currentIndex)
                        self.delegate?.dimissReportSheetForCommentsClicked?(type: "Delete", currentIndex: self.currentIndex, isReply: self.isReply)
                    }
                } else {
                    let someDict = res as! NSDictionary
                    LogClass.debugLog("someDict ===>")
                    LogClass.debugLog(someDict)
                    if isPost {
                        self.dismiss(animated: true) {
                            self.delegate?.dimissReportSheetClicked?(type: type, currentIndex: self.currentIndex)
                        }
                    } else {
                        self.dismiss(animated: true) {
                            self.delegate?.dimissReportSheetForCommentsClicked?(type: type, currentIndex: self.currentIndex, isReply: self.isReply)
                        }
                    }
                }
            }
        }, param:parameters)
    }
}
