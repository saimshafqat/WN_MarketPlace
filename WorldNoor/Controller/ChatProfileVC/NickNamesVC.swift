//
//  NickNamesVC.swift
//  WorldNoor
//
//  Created by ogouluser1-mac6 on 05/09/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit

class NickNamesVC: UIViewController {
    
    @IBOutlet var tableView : UITableView!
    var chatConversationObj:Chat?
    
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

extension NickNamesVC : UITableViewDelegate , UITableViewDataSource  {
    
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
        
        cell.manageOtherUserData(obj: chatConversationObj)
        cell.userNameLbl.rotateViewForLanguage()
        cell.userNameLbl.rotateForTextAligment()
        cell.nickNameLbl.rotateViewForLanguage()
        cell.nickNameLbl.rotateForTextAligment()
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        showAlertView(firstName: chatConversationObj?.name ?? "", fullName: chatConversationObj?.name ?? "", isOtherUser: true)
    }
    
    func showAlertView(firstName: String, fullName: String, isOtherUser: Bool) {
        let alert = UIAlertController(title: "Edit nickname".localized(), message: "\(firstName) " + "will only see this in this conversation.".localized(), preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = fullName
        }
        
        let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .destructive)
        alert.addAction(cancelAction)
        
        let saveAction = UIAlertAction(title: "Save".localized(), style: .default) { (_) -> Void in
            self.apiCallforUpdateName(nickName: alert.textFields!.first!.text!)
        }
        alert.addAction(saveAction)
        
        self.present(alert, animated: true)
    }
    
    func apiCallforUpdateName(nickName : String){
//        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        let userToken = SharedManager.shared.userToken()
        let parameters = ["action": "conversation/updateNickname","token": userToken,"conversationId" : self.chatConversationObj!.conversation_id , "userId" : self.chatConversationObj!.member_id , "nickname" : nickName, "serviceType":"Node"]
        
        RequestManager.fetchDataPost(Completion: { (response) in
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            switch response {
            case .failure(let error):
                
SwiftMessages.apiServiceError(error: error)                
            case .success(let res):
                
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                }else if res is [[String : Any]] {
                    self.chatConversationObj?.nickname = nickName
                    CoreDbManager.shared.saveContext()
                }else if res is [String : Any] {
                    self.chatConversationObj?.nickname = nickName
                    CoreDbManager.shared.saveContext()
                }
            }
        }, param: parameters)
    }
}
