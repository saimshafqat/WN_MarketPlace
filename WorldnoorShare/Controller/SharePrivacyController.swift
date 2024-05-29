//
//  SharePrivacyController.swift
//  WorldnoorShare
//
//  Created by Raza najam on 7/7/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import UIKit

protocol PrivacyOptionDelegate {
    func privacyOptionSelected(type:String, keyPair:String)
    func privacyOptionCategorySelected(type:String, catID:[Int:String])
}

class SharePrivacyController: UIViewController {
    @IBOutlet weak var moreTableView: UITableView!
    var contactArray:[AnyObject] = []
    var contactDefaultArray:[String] = []
    var contactValue:[String] = []
    var selecteContactID:[Int:String] = [:]
    var editContactID:[Int:String] = [:]
    var selectedIndex:IndexPath?
    var delegate: PrivacyOptionDelegate?
    var selectedSection = 0
    var isEditPost = false
    var selectedSingleIndex = 0
    var selectedPrivacyName:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Groups"
        self.contactDefaultArray = ["Public", "Contacts","Only Me"]
        self.contactValue = ["public", "friends","only_me"]
        self.callingGetGroupService()
        self.moreTableView.estimatedRowHeight = 40
        self.moreTableView.rowHeight = UITableView.automaticDimension
    }
    
    func manageEditPost() {
        self.selectedSection = 0
        if selectedPrivacyName == "contact_groups" {
            self.selectedSection = 1
            for (_, v) in self.editContactID {
//                let dict = self.contactArray[indexPath.row] as! NSDictionary
//                let contactID = dict["id"] as! Int
                var counter = 0
                for dict in self.contactArray {
                    if let idDict = dict as? NSDictionary {
                        let contactID = idDict["id"] as! Int
                        if v == String(contactID) {
                            self.selecteContactID[counter] = v
                        }
                        counter = counter + 1
                    }
                }
            }
        }else if selectedPrivacyName == "only_me" {
            selectedSingleIndex = 2
        }else if selectedPrivacyName == "friends" {
            selectedSingleIndex = 1
        }else {
            selectedSingleIndex = 0
        }
        self.moreTableView.reloadData()
    }
    
    func callingGetGroupService() {
        let userToken = Shared.instance.userToken()
        let parameters = ["action": "contact_groups", "token":userToken]
        SharedRequestManager.fetchDataGet(Completion: { response in
            switch response {
            case .failure(let error):
                if error is String {
                    Shared.instance.showAlert(message: Const.networkProblemMessage, view: self)
                }
            case .success(let res):
                
                if res is Int {
                }else if res is String {
                    Shared.instance.showAlert(message: res as! String, view: self)
                }else {
                    self.contactArray = res as! [AnyObject]
                    if self.contactArray.count > 0 {
                        self.contactArray.remove(at: 0)
                    }
//                    if self.isEditPost {
//                        self.manageEditPost()
//                    }
                    self.manageEditPost()
//                    self.moreTableView.reloadData()
                }
            }
        }, param:parameters)
    }
    @IBAction func doneBtnClicked(_ sender: Any) {
        if self.selectedSection == 0 {
            
        }else {
            if self.selecteContactID.count > 0 {
                self.delegate?.privacyOptionCategorySelected(type: "contact_groups", catID: self.selecteContactID)
            }else {
                self.delegate?.privacyOptionSelected(type: self.contactDefaultArray[0], keyPair: self.contactValue[0])
            }
        }
    }
}

extension SharePrivacyController:UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 3
        }
        return self.contactArray.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ShareContactCell", for: indexPath) as? ShareContactCell {
            cell.accessoryType = .none
            if indexPath.section == 0 {
                if self.selectedSection == 0 {
                    if indexPath.row == self.selectedSingleIndex {
                        cell.accessoryType = .checkmark
                    }
                }
                cell.itemLbl.text = self.contactDefaultArray[indexPath.row]
            }else {
                if self.selectedSection == 1 {
                   if self.selecteContactID[indexPath.row] != nil {
                        cell.accessoryType = .checkmark
                    }
                }
                let dict = self.contactArray[indexPath.row] as! NSDictionary
                cell.itemLbl.text = (dict["title"] as! String)
            }
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.selectedSection = indexPath.section
        if indexPath.section == 0 {
            self.selecteContactID.removeAll()
            self.delegate?.privacyOptionSelected(type: self.contactDefaultArray[indexPath.row], keyPair: self.contactValue[indexPath.row])
        }else {
            let dict = self.contactArray[indexPath.row] as! NSDictionary
            let contactID = dict["id"] as! Int
            if self.selecteContactID[indexPath.row] != nil {
                self.selecteContactID.removeValue(forKey: indexPath.row)
            }else {
                self.selecteContactID[indexPath.row] = String(contactID)
            }
            self.moreTableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return 30
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 30))
            let label = UILabel(frame: CGRect(x: 10, y: 0, width: view.frame.size.width, height: 30))
            label.font = UIFont.boldSystemFont(ofSize: 19)
            label.text = "Contact Groups"
            view.addSubview(label)
            return view
        }
        return UIView.init()
    }
}

