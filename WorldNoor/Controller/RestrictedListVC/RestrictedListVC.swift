//
//  RestrictedListVC.swift
//  WorldNoor
//
//  Created by ogouluser1-mac6 on 13/09/2023.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import UIKit

class RestrictedListVC: UIViewController {
    
    var arrayBlockedUser = [BlockedUserModel]()
    
    @IBOutlet var tableView : UITableView!
    
    @IBOutlet var viewEmpty : UIView!
    @IBOutlet var tblHeaderView : UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Restrict accounts".localized()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.viewEmpty.isHidden = true
        self.arrayBlockedUser.removeAll()
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
        contactVC.appearFrom = "Restrict"
        contactVC.titleStr = "Restrict an account"
        self.pushFromBottom(contactVC)
    }
        
    func getAllBlockUser(){
//        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        let parameters = ["action": "user/blocked_users","token": SharedManager.shared.userToken()]
        RequestManager.fetchDataGet(Completion: { (response) in
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            switch response {
            case .failure(let error):
                SwiftMessages.apiServiceError(error: error)
            case .success(let res):
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                }else  if let newRes = res as? [[String:Any]]
                {
                    for indexObj in newRes {
                        self.arrayBlockedUser.append(BlockedUserModel.init(fromDictionary: indexObj))
                    }
                }
                self.viewEmpty.isHidden = false
                self.tblHeaderView.isHidden = true
                if self.arrayBlockedUser.count > 0 {
                    self.viewEmpty.isHidden = true
                    self.tblHeaderView.isHidden = false
                }
                self.tableView.reloadData()
            }
        }, param: parameters)
    }
}

extension RestrictedListVC : UITableViewDataSource , UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayBlockedUser.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cellBlocked  = tableView.dequeueReusableCell(withIdentifier: RestrictedContactCell.className, for: indexPath) as? RestrictedContactCell else {
           return UITableViewCell()
        }
        
        cellBlocked.lblUserName.text = self.arrayBlockedUser[indexPath.row].firstname + " " + self.arrayBlockedUser[indexPath.row].lastname
        cellBlocked.imgViewUser.loadImageWithPH(urlMain:self.arrayBlockedUser[indexPath.row].profile_image)
        self.view.labelRotateCell(viewMain: cellBlocked.imgViewUser)
        cellBlocked.btnUnRestrict.tag = indexPath.row
        cellBlocked.btnUnRestrict.addTarget(self, action: #selector(self.UnBlockUser), for: .touchUpInside)
        cellBlocked.selectionStyle = .none
        return cellBlocked
    }
    
    @objc func UnBlockUser(sender : UIButton){
//        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        let parameters = ["action": "user/unblock_user","token": SharedManager.shared.userToken() , "user_id":self.arrayBlockedUser[sender.tag].user_id]
        
        RequestManager.fetchDataPost(Completion: { (response) in
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            
            switch response {
            case .failure(let error):
                SwiftMessages.apiServiceError(error: error)
            case .success(let res):
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                }else if let newRes = res as? String{
                    SharedManager.shared.ShowsuccessAlert(message: newRes) { status in
                        self.arrayBlockedUser.removeAll()
                        self.getAllBlockUser()
                    }
                }else {
                    self.arrayBlockedUser.remove(at: sender.tag)
                }
                self.tableView.reloadData()
            }
        }, param: parameters)
    }
}

