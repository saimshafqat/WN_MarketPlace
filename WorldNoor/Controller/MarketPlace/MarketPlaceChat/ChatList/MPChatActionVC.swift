//
//  MPChatActionVC.swift
//  WorldNoor
//
//  Created by Awais on 24/03/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit

class MPChatActionVC: UIViewController {

    @IBOutlet var tblView : UITableView!
    
    @IBOutlet var lblUserName : UILabel!
    var chatActionDelegate : MPChatActionDelegate!
    var indexPath : IndexPath!
    var chatObj : MPChat!
    var isArchiveScreen : Bool = false
    
    var chatActionsArr : [MPChatActionModel] = []
    
    override func viewDidLoad() {
        self.tblView.register(UINib.init(nibName: "ChatSettingCell", bundle: nil), forCellReuseIdentifier: "ChatSettingCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.lblUserName.text = self.chatObj.conversationName
        
        let markasRead = self.chatObj.isRead
        let mutenotification = self.chatObj.mutedAt.count == 0
        
        if self.chatObj.deletedAt.count > 0 {
            chatActionsArr = [
                isArchiveScreen ? MPChatActionModel(id: .Unarchive, name: MPChatActions.Unarchive.rawValue, imageName: "Chat_Archive") : MPChatActionModel(id: .Archive, name: MPChatActions.Archive.rawValue, imageName: "Chat_Archive"),
                MPChatActionModel(id: .Delete, name: MPChatActions.Delete.rawValue, imageName: "Chat_Delete"),
                MPChatActionModel(id: .Wrong, name: MPChatActions.Wrong.rawValue, imageName: "Chat_Wrong")
            ]
        }
        else {
            chatActionsArr = [
                markasRead ? MPChatActionModel(id: .MarkRead, name: MPChatActions.MarkRead.rawValue, imageName: "Chat_Unread") : MPChatActionModel(id: .MarkasRead, name: MPChatActions.MarkasRead.rawValue, imageName: "Chat_Unread"),
                mutenotification ? MPChatActionModel(id: .Mutenotification, name: MPChatActions.Mutenotification.rawValue, imageName: "Chat_MuteNotification") : MPChatActionModel(id: .UnMutenotification, name: MPChatActions.UnMutenotification.rawValue, imageName: "Chat_MuteNotification"),
                isArchiveScreen ? MPChatActionModel(id: .Unarchive, name: MPChatActions.Unarchive.rawValue, imageName: "Chat_Archive") : MPChatActionModel(id: .Archive, name: MPChatActions.Archive.rawValue, imageName: "Chat_Archive"),
                MPChatActionModel(id: .Delete, name: MPChatActions.Delete.rawValue, imageName: "Chat_Delete"),
                MPChatActionModel(id: .Leave, name: MPChatActions.Leave.rawValue, imageName: "BlackCross")
            ]
        }
        
        tblView.reloadData()
    }
    
    
}

extension MPChatActionVC : UITableViewDelegate ,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatActionsArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellSetting = tableView.dequeueReusableCell(withIdentifier: "ChatSettingCell", for: indexPath) as! ChatSettingCell
        
        cellSetting.imgViewMain.image = UIImage.init(named: self.chatActionsArr[indexPath.row].imageName)
        cellSetting.lblMain.text = self.chatActionsArr[indexPath.row].name
        cellSetting.selectionStyle = .none
        return cellSetting
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.chatActionDelegate.chatActionChoose(action: chatActionsArr[indexPath.row], indexPath: self.indexPath)
    }
}

enum MPChatActions : String,CaseIterable {
    case Profile = "View Profile"
    case MarkRead = "Mark as Unread"
    case MarkasRead = "Mark as Read"
    case Mutenotification = "Mute Notification"
    case UnMutenotification = "Un-Mute Notification"
    case Archive = "Archive Thread"
    case Unarchive = "Unarchive Thread"
    case Delete = "Delete"
    case Block = "Block"
    case Unblock = "Unblock"
    case Wrong = "Something's Wrong"
    case Leave = "Leave Group"
}

struct MPChatActionModel {
    let id: MPChatActions
    let name: String
    let imageName: String
}

protocol MPChatActionDelegate {
    func chatActionChoose(action: MPChatActionModel, indexPath: IndexPath)
}
