//
//  ContactViewController.swift
//  WorldNoor
//
//  Created by Raza najam on 10/31/19.
//  Copyright © 2019 Raza najam. All rights reserved.
//

import UIKit
import Photos
import TLPhotoPicker
import AVFoundation



class ContactViewController: UIViewController {
    @IBOutlet weak var moreTableView: UITableView!
    
    @IBOutlet weak var tfSearchBar: UISearchBar!
    
    @IBOutlet weak var viewFindUsers: UIView!
    
    var groupID:String = ""
    var contactArray:[AnyObject] = []
    var tblArray:[AnyObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = Const.ContactViewTitle.localized()
        
        self.moreTableView.estimatedRowHeight = 40
        self.moreTableView.rowHeight = UITableView.automaticDimension
        self.moreTableView.register(UINib.init(nibName: "ChatOptionCell", bundle: nil), forCellReuseIdentifier: "ChatOptionCell")
        self.moreTableView.register(UINib.init(nibName: "ChatOptionHeaderCell", bundle: nil), forCellReuseIdentifier: "ChatOptionHeaderCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.viewFindUsers.isHidden = true
        self.callingGetGroupService()
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
                }else if res is String {
                    self.viewFindUsers.isHidden = false
                }else {
                    self.contactArray = res as! [AnyObject]
                    self.tblArray = res as! [AnyObject]
                    self.moreTableView.reloadData()
                }
            }
        }, param:parameters)
    }
    
    
    @IBAction func showNewView(sender : UIButton){
        let nearVC = self.GetView(nameVC: "NearByUsersVC", nameSB:"EditProfile" ) as! NearByUsersVC
        self.navigationController?.pushViewController(nearVC, animated: true)
    }
}

extension ContactViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tblArray.count + 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0   {
            let cellOption = tableView.dequeueReusableCell(withIdentifier: "ChatOptionCell", for: indexPath) as! ChatOptionCell
                cellOption.lblName.text = "New Group".localized()
                cellOption.imgViewMain.image = UIImage.init(named: "GroupIcon")
            cellOption.lblName.rotateForTextAligment()
            self.view.labelRotateCell(viewMain: cellOption.lblName)
            cellOption.selectionStyle = .none
            return cellOption
        }else if indexPath.row == 1 {
            let cellOption = tableView.dequeueReusableCell(withIdentifier: "ChatOptionHeaderCell", for: indexPath) as! ChatOptionHeaderCell
            
            cellOption.lblName.rotateForTextAligment()
            self.view.labelRotateCell(viewMain: cellOption.lblName)
            cellOption.selectionStyle = .none
            return cellOption
        }
                
        if let cell = tableView.dequeueReusableCell(withIdentifier: Const.MyContactCell, for: indexPath) as? MyContactCell {
            if let dict = self.tblArray[indexPath.row - 2] as? NSDictionary {
                let indexPathMain = IndexPath.init(row: indexPath.row - 2, section: 0)
                cell.manageContact( dict: dict)
            }
            
            cell.selectionStyle = .none
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
           tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row < 2 {
            if indexPath.row == 0 {
                let viewGroup = self.GetView(nameVC: "GroupContactsVC", nameSB: "Notification") as! GroupContactsVC
                self.navigationController?.pushViewController(viewGroup, animated: true)
            }
        }else {
            let dict = self.tblArray[indexPath.row - 2] as! NSDictionary
            
            let moc = CoreDbManager.shared.persistentContainer.viewContext
            let conversationModel = Chat(context: moc)
            conversationModel.name = self.ReturnValueCheck(value: dict["username"] as Any)
            conversationModel.conversation_id = self.ReturnValueCheck(value: dict["latest_conversation_id"] as Any)
            conversationModel.profile_image = self.ReturnValueCheck(value: dict["profile_image"] as Any)
            conversationModel.member_id = self.ReturnValueCheck(value: dict["id"] as Any)

            let contactGroup = AppStoryboard.PostStoryboard.instance.instantiateViewController(withIdentifier: Const.ChatViewController) as! ChatViewController
            contactGroup.conversatonObj = conversationModel
            self.navigationController?.pushViewController(contactGroup, animated: true)
        }
    }
}


extension ContactViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.tblArray = self.contactArray.filter{
            ((($0["firstname"] as! String) + " " + ($0["lastname"] as! String))).range(of: searchText,
                              options: .caseInsensitive,
                              range: nil,
                              locale: nil) != nil
        }
        
        if searchText.count == 0 {
            self.tblArray = self.contactArray
        }
        self.moreTableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

class ChatOptionCell : UITableViewCell {
    @IBOutlet var imgViewMain : UIImageView!
    @IBOutlet var lblName : UILabel!
    
}


class ChatOptionHeaderCell : UITableViewCell {
    
    @IBOutlet var lblName : UILabel!
    
}
