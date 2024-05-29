//
//  RestrictionDetailVC.swift
//  WorldNoor
//
//  Created by ogouluser1-mac6 on 14/09/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit

class RestrictionDetailVC: UIViewController {
    var contactDict:[String:AnyObject]?
    weak var delegate:ContactBlockedSheetDelegate?
    var titleArr:[String]?
    var descArr:[String]?

    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var imgView: UIImageView!{
        didSet {
            imgView.roundWithClearColor()
        }
    }
    @IBOutlet weak var restrictBtn: UIButton!{
        didSet {
            restrictBtn.roundButton(cornerRadius: 5.0)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        titleArr = ["Move the chat out of sight".localized(), "Hide your activity".localized(), "Unrestrict at any time".localized()]
        descArr = ["Removes the conversation from your Chats list, so you won't get message notification".localized(), "The person won't see you when you've read messages or your Active Status.".localized(), "The person won't be notified that you restricted them. Unrestrict from privacy settings.".localized()]
        manageUI()
    }
    
    
    @IBAction func restrictBtnClicked(sender : UIButton) {
        
//        if let val = contactDict?["id"] {
//            let userID = SharedManager.shared.ReturnValueAsString(value: val)
//            self.blockUser(userID: userID)
//        }
    }
    
    func manageUI() {
        if let dict = contactDict {
            if let firstName = dict["firstname"] as? String {
                let name = firstName+" "+(dict["lastname"] as! String)
                self.nameLbl.text = "See less of ".localized() + name + " without blocking them".localized()
            }
            self.imgView.image = UIImage(named: "placeholder.png")
            if let profileImg = dict["profile_image"] as? String {
                self.imgView.loadImageWithPH(urlMain:profileImg)
            }
        }
    }

}

extension RestrictionDetailVC : UITableViewDataSource , UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.titleArr!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let restrictCell  = tableView.dequeueReusableCell(withIdentifier: RestrictionDetailCell.className, for: indexPath) as? RestrictionDetailCell else {
           return UITableViewCell()
        }
        restrictCell.titleLbl.text = titleArr![indexPath.row]
        restrictCell.descLbl.text = descArr![indexPath.row]
        restrictCell.selectionStyle = .none
        return restrictCell
    }
    
    func restrictUser(){
//        SharedManager.shared.showOnWindow()
//        let parameters = ["action": "user/unblock_user","token": SharedManager.shared.userToken() , "user_id":self.arrayBlockedUser[sender.tag].user_id]
//
//        RequestManager.fetchDataPost(Completion: { (response) in
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
//
//            switch response {
//            case .failure(let error):
//                if error is String {
//                    SharedManager.shared.showAlert(message: Const.networkProblemMessage.localized(), view: self)
//                }
//            case .success(let res):
//                if res is Int {
//                    AppDelegate.shared().loadLoginScreen()
//                }else if let newRes = res as? String{
//                    SharedManager.shared.ShowsuccessAlert(message: newRes) { status in
//                        self.arrayBlockedUser.removeAll()
//                        self.getAllBlockUser()
//                    }
//                }else {
//                    self.arrayBlockedUser.remove(at: sender.tag)
//                }
//                self.tableView.reloadData()
//            }
//        }, param: parameters)
    }
}
