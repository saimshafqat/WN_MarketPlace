//
//  OnlineUsersCollectionView.swift
//  WorldNoor
//
//  Created by Waseem Shah on 31/08/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import Foundation
import UIKit


extension NewChatListVC : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: 90, height: self.OnlineUserCollection.frame.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if self.arrayOnlineUser.count > 0 {
            self.lblNoOnlineUser.isHidden = true
        }else {
            self.lblNoOnlineUser.isHidden = false
        }
        return self.arrayOnlineUser.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellOnline = collectionView.dequeueReusableCell(withReuseIdentifier: "OnlineUserCell", for: indexPath) as! OnlineUserCell
        
        cellOnline.imgviewUser.loadImageWithPH(urlMain: self.arrayOnlineUser[indexPath.row].profile_image)
        cellOnline.lblUserName.text = self.arrayOnlineUser[indexPath.row].name
        
        return cellOnline
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard self.arrayOnlineUser.count > indexPath.row else { return }
        let dict = self.arrayOnlineUser[indexPath.row]
        
        if(dict.latest_coversation_id != "")
        {
            self.callingGetConversationService(dict: dict)
        }
        else {
            self.openChatDetail(dict: dict)
        }
    }
    
    func callingGetConversationService(dict : FriendChatModel) {
//        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        let userToken = SharedManager.shared.userToken()
        let parameters = ["action": "conversations?fetch_one=1&token=\(userToken)&convo_id=\(dict.latest_coversation_id)", "serviceType":"Node"]
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
                    
                    let newArray = res as! [AnyObject]
                    if(newArray.count > 0) {
                        let convObj = ConversationModel.init(fromDictionary: newArray[0] as! [String : Any])
                        self.cdCoreManager.saveChatData(chatData: [convObj])
                        let objModel = ChatDBManager().getChatFromDb(conversationID: dict.latest_coversation_id) ?? Chat()
                        
                        if let contactGroup = AppStoryboard.PostStoryboard.instance.instantiateViewController(withIdentifier: Const.ChatViewController) as? ChatViewController {
                            contactGroup.conversatonObj = objModel
                            self.navigationController?.pushViewController(contactGroup, animated: true)
                        }
                    }
                    else {
                        self.openChatDetail(dict: dict)
                    }
                    
                }
            }
        }, param:parameters)
    }
    
    func openChatDetail(dict : FriendChatModel) {
        let objModel:Chat?
        
        let moc = CoreDbManager.shared.persistentContainer.viewContext
        if dict.latest_coversation_id != "" {
            if ChatDBManager().checkRecordExists(value: Int(dict.latest_coversation_id)!) {
                objModel = ChatDBManager().getChatFromDb(conversationID: dict.latest_coversation_id)
            }else {
                objModel = Chat(context: moc)
            }
        }else {
            objModel = Chat(context: moc)
        }
        guard objModel != nil else { return }
        objModel!.profile_image = dict.profile_image
        objModel!.member_id = dict.id
        objModel!.name = dict.firstname + " " + dict.lastname
        objModel!.latest_conversation_id = dict.latest_coversation_id
        objModel!.conversation_id = dict.latest_coversation_id
        objModel!.conversation_type = "single"
        
        let contactGroup = AppStoryboard.PostStoryboard.instance.instantiateViewController(withIdentifier: Const.ChatViewController) as! ChatViewController
        contactGroup.conversatonObj = objModel!
        self.navigationController?.pushViewController(contactGroup, animated: true)
    }
}

class OnlineUserCell : UICollectionViewCell {
    @IBOutlet var imgviewUser : UIImageView!
    @IBOutlet var lblUserName : UILabel!
}
