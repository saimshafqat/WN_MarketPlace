//
//  ContactGroupController.swift
//  WorldNoor
//
//  Created by Raza najam on 10/30/19.
//  Copyright © 2019 Raza najam. All rights reserved.
//

import UIKit

class ContactGroupController: UIViewController {
    
    var contactArray:[AnyObject] = []
    @IBOutlet weak var moreTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Groups".localized()
        self.callingGetGroupService()
        self.moreTableView.estimatedRowHeight = 40
        self.moreTableView.rowHeight = UITableView.automaticDimension
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.moreTableView.rotateViewForLanguage()
    }
    
    func callingGetGroupService() {
        
        let userToken = SharedManager.shared.userToken()
        let parameters = ["action": "contact_groups", "token":userToken]
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
                    SharedManager.shared.showAlert(message: res as! String, view: self)
                }else {
                    self.contactArray = res as! [AnyObject]
                    self.moreTableView.reloadData()
                }
            }
        }, param:parameters)
    }
    
    func callingDeleteService(type:String, parameters:[String:Any]){
//        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        RequestManager.fetchDataPost(Completion: { response in
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            switch response {
            case .failure(let error):
SwiftMessages.apiServiceError(error: error)            case .success(let res):
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                }else if res is String {

                    
                }else {
                    let someDict = res as! NSDictionary
                }
            }
        }, param:parameters)
    }
}

extension ContactGroupController:UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.contactArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: Const.MyContactCell, for: indexPath) as? MyContactCell {
            let dict = self.contactArray[indexPath.row] as! NSDictionary
            cell.manageCellContact( dict: dict)
            
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let dict = self.contactArray[indexPath.row] as! NSDictionary
        let contactGroup = AppStoryboard.TabBar.instance.instantiateViewController(withIdentifier: Const.BasicContactIdentifier) as! BasicContactController
        if(indexPath.row == 0){
            contactGroup.groupID = "-1"
        }else {
            let valueKey = dict["id"] as! NSNumber
            contactGroup.groupID = valueKey.stringValue
        }
        self.navigationController?.pushViewController(contactGroup, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.manageDeleteRequest(indexpath: indexPath)
            self.contactArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool{
        let myID = SharedManager.shared.getUserID()
        let dict = self.contactArray[indexPath.row] as! NSDictionary
        if let createrID = dict["creator_id"] as? Int {
            if myID == createrID {
                return true
            }
        }
        return false
    }
    
    func manageDeleteRequest(indexpath:IndexPath){
        let dict = self.contactArray[indexpath.row] as! NSDictionary
        let grpID = String(dict["id"] as! Int)
        let action = "contact_groups/" + grpID
        let param = ["action":action,"token":SharedManager.shared.userToken(),"_method":"Delete"]
        self.callingDeleteService(type: "delete", parameters: param)
    }
}
