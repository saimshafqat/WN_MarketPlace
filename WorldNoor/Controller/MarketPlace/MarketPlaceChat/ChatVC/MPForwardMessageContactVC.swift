//
//  MPForwardMessageContactVC.swift
//  WorldNoor
//
//  Created by Awais on 17/04/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit
import Alamofire

class MPForwardMessageContactVC: UIViewController {

    @IBOutlet var tbleViewGroup : UITableView!
    
    var selectedIndex = [Int]()
    var sendingMessageArray = [MPMessage]()
    var tbleArray:[AnyObject] = []
    var delegateRefresh : DelegateRefresh!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.addRightButton(self, selector: #selector(self.forwardAction), image: UIImage.init(named: "ChatForwardNew.png")!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
        self.title = "Select contacts".localized()
        self.getAllFriend()
        self.callRequestForMPGroups()
    }
    
    @objc func forwardAction(){
        
        var selectedFriends = [Any]()
        
        for index in self.selectedIndex {
            selectedFriends.append(self.tbleArray[index])
        }
        
        for indexFirend in selectedFriends {
            
            let conversationID = self.ReturnValueCheck(value: (indexFirend as! [String : Any])["conversation_id"] as Any)
            
            for indexMessage in self.sendingMessageArray {
                
                let url = indexMessage.toMessageFile?.count ?? 0 > 0 ? (indexMessage.toMessageFile?.first as! MPMessageFile).url : ""
                let thumbnailUrl = indexMessage.toMessageFile?.count ?? 0 > 0 ? (indexMessage.toMessageFile?.first as! MPMessageFile).thumbnailUrl : ""
                
                if indexMessage.messageLabel == FeedType.image.rawValue {
                    self.copyimageSend(fileType: indexMessage.messageLabel, URLImage: url, URLVideo:"" ,messagText: indexMessage.content , conversationObj : conversationID )
                }else if indexMessage.messageLabel == FeedType.video.rawValue {
                    self.copyimageSend(fileType: indexMessage.messageLabel, URLImage: thumbnailUrl, URLVideo:url,messagText: indexMessage.content, conversationObj : conversationID )
                }else if indexMessage.messageLabel == FeedType.file.rawValue {
                    self.copyimageSend(fileType: indexMessage.messageLabel, URLImage: url, URLVideo:"",messagText: indexMessage.content, conversationObj : conversationID )
                }else if indexMessage.messageLabel == FeedType.post.rawValue {
                    let myComment = ChatManager.shared.validateTextMessage(comment: indexMessage.content)
                    let idString = SharedManager.shared.getCurrentDateString()
                    
                    self.uploadAudioOnSockt(text: myComment, audio_msg_url: url, identiferString: idString, conversationObj: conversationID)
                }
            }
        }
        
        if selectedFriends.count == 0 {
            SharedManager.shared.showAlert(message: "Select minimum 1 friend.".localized(), view: self)
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//            self.delegateRefresh.delegateRefresh()
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func getAllFriend() {
//        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        
        let userToken = SharedManager.shared.userToken()
        let parameters = ["action": "conversations", "token":userToken, "serviceType":"Node"]
        
        RequestManager.fetchDataPost(Completion: { response in
            
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            switch response {
            case .failure(let error):
                SwiftMessages.apiServiceError(error: error)                
            case .success(let res):
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                } else if res is String {
                    SwiftMessages.showMessagePopup(theme: .error, title: "Failed", body: res as? String ?? .emptyString)
                } else {
                    
                    self.tbleArray.removeAll()
                    
                    let newArray = res as! [AnyObject]
                    for indexObj in newArray {
                        self.tbleArray.append(indexObj.mutableCopy() as! NSMutableDictionary)
                    }
                    self.tbleViewGroup.reloadData()
                }
            }
        }, param:parameters)
    }
    
    func callRequestForMPGroups() {
        
        MPRequestManager.shared.request(endpoint: "conversations/buying") { response in
            switch response {
            case .success(let data):
                LogClass.debugLog("success")
                if let jsonData = data as? Data {
                    do {
                        let decoder = JSONDecoder()
                        
                    } catch {
                        LogClass.debugLog("Error decoding JSON: \(error)")
                    }
                }
                else {
                    LogClass.debugLog("not getting good response")
                }
                
            case .failure(let error):
                LogClass.debugLog(error.localizedDescription)
            }
        }
    }
}

extension MPForwardMessageContactVC:UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tbleArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: Const.MyContactCell, for: indexPath) as? MyContactCell {
            let dict = self.tbleArray[indexPath.row] as! NSMutableDictionary
            cell.manageForwardList(dict: dict)
            cell.accessoryType = .none
            if self.selectedIndex.contains(indexPath.row) {
                cell.accessoryType = .checkmark
                
            }
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if self.selectedIndex.contains(indexPath.row) {
            self.selectedIndex.remove(at: self.selectedIndex.firstIndex(of: indexPath.row)!)
        }else {
            self.selectedIndex.append(indexPath.row)
        }
        
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}


extension MPForwardMessageContactVC {
    
    func copyimageSend(fileType : String , URLImage : String , URLVideo : String , messagText : String , conversationObj : String){
        let newTime = SharedManager.shared.getCurrentDateString()
        
        DispatchQueue.main.async {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
            
            if fileType == "attachment" {
                DispatchQueue.main.async {
                    self.UploadImageOnSocket(mainURL: URLImage ,newTime: newTime , fileType:"attachment" , thumbnailURL: "" ,messagText: messagText , conversationObj : conversationObj)
                }
                
            }else if fileType == "video" {
                
                DispatchQueue.main.async {
                    self.UploadImageOnSocket(mainURL: URLVideo ,newTime: newTime , fileType:"video" , thumbnailURL: URLImage,messagText: messagText, conversationObj : conversationObj)
                }
                
            }else {
                DispatchQueue.main.async {
                    self.UploadImageOnSocket(mainURL: URLImage ,newTime: newTime , fileType:"image" , thumbnailURL: "",messagText: messagText, conversationObj : conversationObj)
                }
                
            }
            
        }
    }
    
    func UploadImageOnSocket(mainURL : String , newTime : String , fileType:String, thumbnailURL : String , messagText : String , conversationObj : String){
        
        var urlSendArray = [[String : Any]]()
        var  urlSend = [String : Any]()
        urlSend["url"] = mainURL
        urlSend["original_url"] = mainURL
        urlSend["thumbnail_url"] = thumbnailURL
        
        if fileType == "video" {
            urlSend["type"] = "video/mov"
        }else if fileType == "attachment" {
            urlSend["type"] = "attachment"
        }else {
            urlSend["type"] = "image/png"
        }
        
        urlSendArray.append(urlSend)
        
        var newTimeP = newTime
        if newTime.count == 0 {
            newTimeP = SharedManager.shared.getCurrentDateString()
        }
        
        let dict:NSDictionary = [ "body" : messagText ,"author_id":SharedManager.shared.getUserID(), "uploads":urlSendArray, "conversation_id":conversationObj, "identifierString":newTimeP, "message_files":[], "audio_file":""]
        
        SocketSharedManager.sharedSocket.emitChatText(dict: dict)
        
    }
    
    func uploadAudioOnSockt(text : String ,audio_msg_url : String , identiferString : String  , conversationObj : String){
        let dict:NSDictionary = ["body":text,"author_id":SharedManager.shared.getUserID(), "audio_msg_url":audio_msg_url, "uploads":[], "conversation_id":conversationObj, "identifierString":identiferString, "message_files":[], "audio_file":""]
        SocketSharedManager.sharedSocket.emitChatText(dict: dict)
    }
}
