//
//  HiddenContactDetailVC.swift
//  WorldNoor
//
//  Created by ogouluser1-mac6 on 14/09/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit

class HiddenContactDetailVC: UIViewController {
    var contactDict:[String:AnyObject]?
    weak var delegate:ContactBlockedSheetDelegate?
    var titleArr:[String]?
    var descArr:[String]?
    var personName = ""

    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var imgView: UIImageView!{
        didSet {
            imgView.roundWithClearColor()
        }
    }
    @IBOutlet weak var hideContactBtn: UIButton!{
        didSet {
            hideContactBtn.roundButton(cornerRadius: 5.0)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        manageUI()
        titleArr = ["See less of ".localized() + personName, "They won't be notified".localized(), "Unhide them at any time".localized()]
        descArr = ["You won't see ".localized() + personName + " suggested with your other contacts.".localized(), "You can still chat with ".localized() + personName + " and they won't know that they've been hidden.".localized(), "Go to your Privacy settings and tap Hidden contacts.".localized()]
    }
    
    
    @IBAction func hideContactBtnClicked(sender : UIButton) {
        
//        if let val = contactDict?["id"] {
//            let userID = SharedManager.shared.ReturnValueAsString(value: val)
//            self.hideUser(userID: userID)
//        }
    }
    
    func manageUI() {
        if let dict = contactDict {
            if let firstName = dict["firstname"] as? String {
                personName = firstName+" "+(dict["lastname"] as! String)
                self.nameLbl.text = "Hide ".localized() + personName + " from your WorldNoor contacts".localized()
            }
            self.imgView.image = UIImage(named: "placeholder.png")
            if let profileImg = dict["profile_image"] as? String {
                self.imgView.loadImageWithPH(urlMain:profileImg)
            }
        }
    }

}

extension HiddenContactDetailVC : UITableViewDataSource , UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.titleArr!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let hideCell  = tableView.dequeueReusableCell(withIdentifier: HiddenContactDetailCell.className, for: indexPath) as? HiddenContactDetailCell else {
           return UITableViewCell()
        }
        hideCell.titleLbl.text = titleArr![indexPath.row]
        hideCell.descLbl.text = descArr![indexPath.row]
        hideCell.selectionStyle = .none
        return hideCell
    }
    
    func hideUser(){
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
