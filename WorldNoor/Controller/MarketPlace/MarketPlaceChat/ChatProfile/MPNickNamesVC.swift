//
//  MPNickNamesVC.swift
//  WorldNoor
//
//  Created by Awais on 23/04/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit

class MPNickNamesVC: UIViewController {
    
    @IBOutlet var tableView : UITableView!
    var chatConversationObj:MPChat?
    var otherMember: MPMember?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Nicknames".localized()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
        self.tableView.rotateViewForLanguage()
        
        self.tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
}

extension MPNickNamesVC : UITableViewDelegate , UITableViewDataSource  {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 74
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NickNamesTVCell", for: indexPath) as? NickNamesTVCell else {
            return UITableViewCell()
        }
        
        let membersArr = self.chatConversationObj?.toMember?.allObjects as? [MPMember] ?? []
        otherMember = membersArr.filter ({ $0.id != String(SharedManager.shared.getMPUserID()) }).first
        cell.manageMPOtherUserData(obj: otherMember)
        cell.userNameLbl.rotateViewForLanguage()
        cell.userNameLbl.rotateForTextAligment()
        cell.nickNameLbl.rotateViewForLanguage()
        cell.nickNameLbl.rotateForTextAligment()
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        showAlertView(firstName: otherMember?.firstname ?? "", fullName: otherMember?.name ?? "", isOtherUser: true)
    }
    
    func showAlertView(firstName: String, fullName: String, isOtherUser: Bool) {
        let alert = UIAlertController(title: "Edit nickname".localized(), message: "\(firstName) " + "will only see this in this conversation.".localized(), preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = fullName
        }
        
        let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .destructive)
        alert.addAction(cancelAction)
        
        let saveAction = UIAlertAction(title: "Save".localized(), style: .default) { (_) -> Void in
            self.callforUpdateName(nickName: alert.textFields!.first!.text!)
        }
        alert.addAction(saveAction)
        
        self.present(alert, animated: true)
    }
    
    func callforUpdateName(nickName : String){
        
        var dic = [String:Any]()
        dic["conversationId"] = self.chatConversationObj?.conversationId
        dic["userId"] = otherMember?.id
        dic["nickname"] = nickName

        MPSocketSharedManager.sharedSocket.updateNickname(dictionary: dic) { returnValue in
            if let dataDict = returnValue as? [[String : Any]] {
                if dataDict.count > 0 {
                    if let statusCode =  dataDict[0]["status"] as? Int {
                        if statusCode == 200 {
                            self.otherMember?.nickname = nickName
                            CoreDbManager.shared.saveContext()
                            SwiftMessages.showMessagePopup(theme: .success, title: "Congratulations", body: "Nickname updated successfully")
                        }
                        else {
                            SwiftMessages.showMessagePopup(theme: .warning, title: "Alert", body: "Nickname not updated")
                        }
                    }
                }
            }
        }
    }
}
