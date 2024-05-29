//
//  ChatLongPressSettingVC.swift
//  WorldNoor
//
//  Created by Waseem Shah on 05/09/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import Foundation
import UIKit


class ChatLongPressSettingVC : UIViewController {
    
    @IBOutlet var tblViewSetting : UITableView!
    
    @IBOutlet var lblUserName : UILabel!
    var chatDelegat : ChatSettingDelegate!
    var indexPath : IndexPath!
    var userObj : Chat!
    var isArchiveScreen : Bool = false
    
    var chatSettingsArr : [ChatSettingModel] = []
    
    override func viewDidLoad() {
        self.tblViewSetting.register(UINib.init(nibName: "ChatSettingCell", bundle: nil), forCellReuseIdentifier: "ChatSettingCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.lblUserName.text = self.userObj.name
        
        
        var markasRead = true
        var mutenotification = true
        let isBlock = self.userObj.is_blocked == "1"
        if self.userObj.is_unread == "1" {
            markasRead = false
        }
        //        
        if self.userObj.is_mute == "1" {
            mutenotification = false
        }
        
        if self.userObj.is_leave == "1" {
            chatSettingsArr = [
                isArchiveScreen ? ChatSettingModel(id: .Unarchive, name: ChatSetting.Unarchive.rawValue, imageName: "Chat_Archive") : ChatSettingModel(id: .Archive, name: ChatSetting.Archive.rawValue, imageName: "Chat_Archive"),
                ChatSettingModel(id: .Delete, name: ChatSetting.Delete.rawValue, imageName: "Chat_Delete"),
                ChatSettingModel(id: .Wrong, name: ChatSetting.Wrong.rawValue, imageName: "Chat_Wrong")
            ]
        }
        else {
            chatSettingsArr = [
                ChatSettingModel(id: .Profile, name: ChatSetting.Profile.rawValue, imageName: "Chat_user"),
                markasRead ? ChatSettingModel(id: .MarkRead, name: ChatSetting.MarkRead.rawValue, imageName: "Chat_Unread") : ChatSettingModel(id: .MarkasRead, name: ChatSetting.MarkasRead.rawValue, imageName: "Chat_Unread"),
                mutenotification ? ChatSettingModel(id: .Mutenotification, name: ChatSetting.Mutenotification.rawValue, imageName: "Chat_MuteNotification") : ChatSettingModel(id: .UnMutenotification, name: ChatSetting.UnMutenotification.rawValue, imageName: "Chat_MuteNotification"),
                isArchiveScreen ? ChatSettingModel(id: .Unarchive, name: ChatSetting.Unarchive.rawValue, imageName: "Chat_Archive") : ChatSettingModel(id: .Archive, name: ChatSetting.Archive.rawValue, imageName: "Chat_Archive"),
                ChatSettingModel(id: .Delete, name: ChatSetting.Delete.rawValue, imageName: "Chat_Delete"),
                isBlock ? ChatSettingModel(id: .Unblock, name: ChatSetting.Unblock.rawValue, imageName: "Chat_Block") : ChatSettingModel(id: .Block, name: ChatSetting.Block.rawValue, imageName: "Chat_Block"),
                ChatSettingModel(id: .Wrong, name: ChatSetting.Wrong.rawValue, imageName: "Chat_Wrong")
            ]
        }
        
        tblViewSetting.reloadData()
    }
    
    
}

extension ChatLongPressSettingVC : UITableViewDelegate ,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatSettingsArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellSetting = tableView.dequeueReusableCell(withIdentifier: "ChatSettingCell", for: indexPath) as! ChatSettingCell
        
        cellSetting.imgViewMain.image = UIImage.init(named: self.chatSettingsArr[indexPath.row].imageName)
        cellSetting.lblMain.text = self.chatSettingsArr[indexPath.row].name
        cellSetting.selectionStyle = .none
        return cellSetting
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.chatDelegat.settingOptionsChoose(chatSetting: chatSettingsArr[indexPath.row], indexPath: self.indexPath)
    }
}



class ChatSettingCell : UITableViewCell {
    @IBOutlet var lblMain : UILabel!
    @IBOutlet var imgViewMain : UIImageView!
    
    
    override class func awakeFromNib() {
        
        
    }
    
    
}

enum ChatSetting : String,CaseIterable {
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
}

struct ChatSettingModel {
    let id: ChatSetting
    let name: String
    let imageName: String
}

protocol ChatSettingDelegate {
    func settingOptionsChoose(chatSetting : ChatSettingModel , indexPath : IndexPath)
}
