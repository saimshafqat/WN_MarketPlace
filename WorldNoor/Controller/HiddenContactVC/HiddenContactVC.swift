//
//  HiddenContactVC.swift
//  WorldNoor
//
//  Created by ogouluser1-mac6 on 14/09/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit

class HiddenContactVC: UIViewController {
    
    var arrayHideUser = [BlockedUserModel]()
    
    @IBOutlet var tableView : UITableView!
    
    @IBOutlet var viewEmpty : UIView!
    @IBOutlet var tblHeaderView : UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Hidden contacts".localized()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.viewEmpty.isHidden = true
        self.arrayHideUser.removeAll()
        self.getAllBlockUser()
        self.manageUI()
    }
    
    func manageUI(){
        let addBtn = UIBarButtonItem(image: UIImage(systemName: "person.fill.badge.plus"), style: .plain, target: self, action: #selector(self.addContactBtn))
        addBtn.tintColor = .black
        self.navigationItem.rightBarButtonItem = addBtn
    }
    
    @objc func addContactBtn(){
        let contactVC = AppStoryboard.Chat.instance.instantiateViewController(withIdentifier: ChatContactVC.className) as! ChatContactVC
        contactVC.groupID = "-1"
        contactVC.appearFrom = "HideContact"
        contactVC.titleStr = "Hide an account"
        self.pushFromBottom(contactVC)
    }
        
    func getAllBlockUser() {
        
//        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        let parameters = ["action": "user/blocked_users", "token": SharedManager.shared.userToken()]
        
        RequestManager.fetchDataGet(Completion: { (response) in
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            switch response {
            case .failure(let error):
SwiftMessages.apiServiceError(error: error)            case .success(let res):
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                } else  if let newRes = res as? [[String:Any]] {
                    for indexObj in newRes {
                        self.arrayHideUser.append(BlockedUserModel.init(fromDictionary: indexObj))
                    }
                }
                self.viewEmpty.isHidden = false
                self.tblHeaderView.isHidden = true
                if self.arrayHideUser.count > 0 {
                    self.viewEmpty.isHidden = true
                    self.tblHeaderView.isHidden = false
                }
                self.tableView.reloadData()
            }
        }, param: parameters)
    }
}

extension HiddenContactVC : UITableViewDataSource , UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayHideUser.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cellHideContact  = tableView.dequeueReusableCell(withIdentifier: HiddenContactCell.className, for: indexPath) as? HiddenContactCell else {
           return UITableViewCell()
        }
        
        cellHideContact.lblUserName.text = self.arrayHideUser[indexPath.row].firstname + " " + self.arrayHideUser[indexPath.row].lastname
        cellHideContact.imgViewUser.loadImageWithPH(urlMain:self.arrayHideUser[indexPath.row].profile_image)
        self.view.labelRotateCell(viewMain: cellHideContact.imgViewUser)
        cellHideContact.btnUnhide.tag = indexPath.row
        cellHideContact.btnUnhide.addTarget(self, action: #selector(self.UnBlockUser), for: .touchUpInside)
        cellHideContact.selectionStyle = .none
        return cellHideContact
    }
    
    @objc func UnBlockUser(sender : UIButton) {
        
//        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        let parameters = ["action": "user/unblock_user","token": SharedManager.shared.userToken() , "user_id":self.arrayHideUser[sender.tag].user_id]
        
        RequestManager.fetchDataPost(Completion: { (response) in
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            
            switch response {
            case .failure(let error):
SwiftMessages.apiServiceError(error: error)
            case .success(let res):
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                } else if let newRes = res as? String{
                    SharedManager.shared.ShowsuccessAlert(message: newRes) { status in
                        self.arrayHideUser.removeAll()
                        self.getAllBlockUser()
                    }
                } else {
                    self.arrayHideUser.remove(at: sender.tag)
                }
                self.tableView.reloadData()
            }
        }, param: parameters)
    }
}
