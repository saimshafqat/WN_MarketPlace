//
//  ChatFriendController.swift
//  WorldNoor
//
//  Created by Raza najam on 7/31/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import UIKit

protocol ChatFriendDelegate: class {
    func friendSelectedDelegate(friendArray:[FriendChatModel])
    func friendCancelDelegate()

}

class ChatFriendController: UIViewController {
    
    @IBOutlet var tbleViewGroup : UITableView!
    var arrayFriends = [FriendChatModel]()
    weak var delegate: ChatFriendDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tbleViewGroup.register(UINib.init(nibName: "GroupContactSelection", bundle: nil), forCellReuseIdentifier: "GroupContactSelection")
        self.navigationController?.addRightButtonWithTitle(self, selector: #selector(self.saveAction), lblText: "Add".localized(), widthValue: 50.0)
        self.navigationController?.addLeftButtonWithTitle(self, selector: #selector(self.cancelBtn), lblText: "Cancel".localized(), widthValue: 100.0)

        self.getAllFriend()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.title = "Select Contacts".localized()
    }
    
    @objc func saveAction(){
        var selectedFriends = [FriendChatModel]()
        for selectedUser in self.arrayFriends {
            if selectedUser.isSelect {
                selectedFriends.append(selectedUser)
            }
        }
        self.delegate?.friendSelectedDelegate(friendArray: selectedFriends)
    }
    
    @objc func cancelBtn(){
        self.delegate?.friendCancelDelegate()
    }

    func getAllFriend(){
        self.arrayFriends.removeAll()
//        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        let parameters = ["action": "user/friends","token": SharedManager.shared.userToken()]
        RequestManager.fetchDataGet(Completion: { (response) in
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            switch response {
            case .failure(let error):
SwiftMessages.apiServiceError(error: error)            case .success(let res):

                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                } else if let newRes = res as? [[String:Any]] {
                    for indexFriend in newRes{
                        
                        let userid = indexFriend["id"] as! Int
                        if userid != 0 {
                            var found = false
                            for connection in RoomClient.sharedInstance.connections{
                                if(connection.connecteduserid == userid){
                                    found = true
                                }
                            }
                            if(!found){
                                self.arrayFriends.append(FriendChatModel.init(fromDictionary: indexFriend))
                            }
                        }
                        
                    }
                }
                self.tbleViewGroup.reloadData()
            }
        }, param: parameters)
    }
}

extension ChatFriendController:UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayFriends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "GroupContactSelection", for: indexPath) as? GroupContactSelection else {
           return UITableViewCell()
        }
        
        cell.lblUserName.text = self.arrayFriends[indexPath.row].name
        cell.lblUserEmail.text = self.arrayFriends[indexPath.row].email
        
//        let urlString = URL.init(string: self.arrayFriends[indexPath.row].profile_image)
//        cell.imgviewUser.sd_imageIndicator = SDWebImageActivityIndicator.gray
//        cell.imgviewUser.sd_setImage(with:urlString, placeholderImage: UIImage(named: "placeholder.png"))
        
        cell.imgviewUser.loadImageWithPH(urlMain:self.arrayFriends[indexPath.row].profile_image)
        
        self.view.labelRotateCell(viewMain: cell.imgviewUser)
        cell.imgviewSelect.isHidden = true
        cell.viewSelect.backgroundColor = UIColor.white
        if self.arrayFriends[indexPath.row].isSelect {
            cell.imgviewSelect.isHidden = false
            cell.viewSelect.backgroundColor = UIColor.init(red: (235/255), green: (235/255), blue: (235/255), alpha: 1.0)
        }
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.arrayFriends[indexPath.row].isSelect = !self.arrayFriends[indexPath.row].isSelect
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}


