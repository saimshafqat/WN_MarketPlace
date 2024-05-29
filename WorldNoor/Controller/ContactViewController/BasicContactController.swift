//
//  BasicContactController.swift
//  WorldNoor
//
//  Created by Raza najam on 10/31/19.
//  Copyright © 2019 Raza najam. All rights reserved.
//

import UIKit
import Photos
import TLPhotoPicker
import AVFoundation



class BasicContactController: UIViewController {
    @IBOutlet weak var moreTableView: UITableView!
    @IBOutlet weak var tfSearchBar: UISearchBar!
    
    var groupID:String = ""
    var contactArray:[AnyObject] = []
    var tblArray:[AnyObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = Const.ContactViewTitle.localized()
        self.callingGetGroupService()
        self.moreTableView.estimatedRowHeight = 40
        self.moreTableView.rowHeight = UITableView.automaticDimension
        self.moreTableView.register(UINib.init(nibName: "ChatOptionCell", bundle: nil), forCellReuseIdentifier: "ChatOptionCell")
        self.moreTableView.register(UINib.init(nibName: "ChatOptionHeaderCell", bundle: nil), forCellReuseIdentifier: "ChatOptionHeaderCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.moreTableView.rotateViewForLanguage()
    }
    func callingGetGroupService() {
        let userToken = SharedManager.shared.userToken()
        var parameters = ["action": "contacts", "token":userToken, "contact_group_id": self.groupID]
        if self.groupID == "-1" {
            parameters.removeValue(forKey: "contact_group_id")
        }
//        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        RequestManager.fetchDataGet(Completion: { response in
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            switch response {
            case .failure(let error):
SwiftMessages.apiServiceError(error: error)            case .success(let res):
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                } else if res is String {
                    SharedManager.shared.showAlert(message: res as! String, view: self)
                } else {
                    self.contactArray = res as! [AnyObject]
                    self.tblArray = res as! [AnyObject]
                    self.moreTableView.reloadData()
                }
            }
        }, param:parameters)
    }
}

extension BasicContactController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tblArray.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
//            let cellOption = tableView.dequeueReusableCell(withIdentifier: "ChatOptionHeaderCell", for: indexPath) as! ChatOptionHeaderCell
            
            guard let cellOption = tableView.dequeueReusableCell(withIdentifier: "ChatOptionHeaderCell", for: indexPath) as? ChatOptionHeaderCell else {
                      return UITableViewCell()
                   }
            
            cellOption.lblName.rotateViewForLanguage()
            self.view.labelRotateCell(viewMain: cellOption.lblName)
            
            cellOption.selectionStyle = .none
            return cellOption
        }
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: Const.MyContactCell, for: indexPath) as? MyContactCell {
            if let dict = self.tblArray[indexPath.row - 1] as? NSDictionary {
                let indexPathMain = IndexPath.init(row: indexPath.row - 1, section: 0)
                cell.manageContact( dict: dict)
                cell.messageBtn.tag = indexPath.row - 1
                cell.messageBtn.addTarget(self, action: #selector(self.messageBtnClicked), for: .touchUpInside)
                cell.messageBtn.rotateViewForLanguage()
            }
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row > 0 {
            
            let dict = self.tblArray[indexPath.row - 1] as! NSDictionary
            

            let contactGroup = AppStoryboard.PostStoryboard.instance.instantiateViewController(withIdentifier: Const.ChatViewController) as! ChatViewController
            let moc = CoreDbManager.shared.persistentContainer.viewContext
            let conversationObj = Chat(context: moc)
            conversationObj.member_id = self.ReturnValueCheck(value: dict["id"] ?? "")
            conversationObj.conversation_id = self.ReturnValueCheck(value: dict["latest_conversation_id"] ?? "")
            conversationObj.name = self.ReturnValueCheck(value: dict["username"] ?? "")
            conversationObj.conversation_type = "single"

            contactGroup.conversatonObj = conversationObj
            self.navigationController?.pushViewController(contactGroup, animated: true)
            
      
        }
    }
    
    @objc func messageBtnClicked(sender:UIButton) {
        let dict = self.tblArray[sender.tag] as! NSDictionary
        
        
        let contactGroup = AppStoryboard.PostStoryboard.instance.instantiateViewController(withIdentifier: Const.ChatViewController) as! ChatViewController
        let moc = CoreDbManager.shared.persistentContainer.viewContext
        let conversationObj = Chat(context: moc)
        conversationObj.member_id = self.ReturnValueCheck(value: dict["id"] ?? "")
        conversationObj.conversation_id = self.ReturnValueCheck(value: dict["latest_conversation_id"] ?? "")
        conversationObj.name = self.ReturnValueCheck(value: dict["username"] ?? "")
        conversationObj.conversation_type = "single"

        contactGroup.conversatonObj = conversationObj
        self.navigationController?.pushViewController(contactGroup, animated: true)
        

    }
}

extension BasicContactController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.tblArray = self.contactArray.filter{
            ((($0["firstname"] as! String) + " " + ($0["lastname"] as! String))).range(of: searchText,options: .caseInsensitive,range: nil, locale: nil) != nil
        }
        if searchText.count == 0 {
            self.tblArray = self.contactArray
        }
        self.moreTableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        self.tfSearchBar.text = ""
        self.tblArray = self.contactArray
        self.moreTableView.reloadData()
    }
}
