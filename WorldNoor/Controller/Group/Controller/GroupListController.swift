//
//  GroupListController.swift
//  WorldNoor
//
//  Created by Raza najam on 3/27/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import UIKit

class GroupListController: UIViewController, CreateGroupDelegate {
    
    @IBOutlet weak var groupTableView: UITableView!
    
    var cellCount = 0
    var catArray:NSArray = NSArray.init()
    var otherArray:NSMutableArray = NSMutableArray()
    var groupDict:NSDictionary = NSDictionary.init()
    var allOtherGroupArray:NSMutableArray = NSMutableArray()
    var catNameArray:NSMutableArray = NSMutableArray()
    var createObj:CreateGroupController = CreateGroupController.init()
    var defaultKey:[String] = []
    var defaultValue:[String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Groups".localized()
        self.defaultKey = ["suggested_groups","my_groups", "joined_groups"]
        self.defaultValue = ["Friends Groups".localized(),"My Groups".localized(),"Joined Groups".localized()]
//        self.callingGroupListService()
        self.callbackHandler()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        if SharedManager.shared.isGrouplistUpdate {
//           SharedManager.shared.isGrouplistUpdate = false
            self.callingGroupListService()
//        }
    }
    
    func callbackHandler() {
        GroupHandler.shared.groupCategoryCallBackHandler = { [weak self] (groupObj) in
            let groupView = AppStoryboard.Group.instance.instantiateViewController(withIdentifier: "GCategoryListController") as! GCategoryListController
            groupView.groupObj = groupObj
            self!.navigationController?.pushViewController(groupView, animated: true)
        }
        GroupHandler.shared.groupCallBackHandler = { [weak self] (groupObj) in
            
            
            
            
            let groupView = AppStoryboard.Kids.instance.instantiateViewController(withIdentifier: "GroupPostController1") as! GroupPostController1
            groupView.groupObj = groupObj
            self!.navigationController?.pushViewController(groupView, animated: true)
            
            
//            let groupView = AppStoryboard.Kids.instance.instantiateViewController(withIdentifier: "NewGroupDetailVC") as! NewGroupDetailVC
//            groupView.groupObj = groupObj
//            self!.navigationController?.pushViewController(groupView, animated: true)
        }
    }
    
    @IBAction func createGroupBtnClicked(_ sender: Any) {
        self.createObj = self.GetView(nameVC: "CreateGroupController", nameSB: "Group") as! CreateGroupController
        self.createObj.delegate = self
        UIApplication.shared.keyWindow!.addSubview((self as GroupListController).createObj.view)
    }
    
    func callingGroupListService(){
        
        let parameters = ["action": "group/list", "token": SharedManager.shared.userToken()]
        Loader.startLoading()
        RequestManager.fetchDataGet(Completion: { response in
            Loader.stopLoading()
            switch response {
            case .failure(let error):
                if error is String {
                }
            case .success(let res):
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                }else if res is String {
                    //  SharedManager.shared.showAlert(message: res as! String, view: self)
                }else {
                    self.allOtherGroupArray.removeAllObjects()
                    self.catNameArray.removeAllObjects()
                    self.groupDict = res as! NSDictionary
                    self.cellCount = self.groupDict.count
                    self.catArray = self.groupDict.value(forKey: "categories") as! NSArray
                    let editDict:NSMutableDictionary = self.groupDict.mutableCopy() as! NSMutableDictionary
                    editDict.removeObject(forKey: "categories")
                    self.groupDict = editDict as NSDictionary
                    self.groupTableView.reloadData()
                }
            }
        }, param:parameters)
    }
    
    func groupCreatedSuccessfullyDelegate() {
        self.callingGroupListService()
    }
}

extension GroupListController:UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cellCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 && self.catArray.count > 0 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "GroupCatTableCell", for: indexPath) as? GroupCatTableCell {
                cell.manageCategoryData(catArray: self.catArray as! [[String : Any]])
                return cell
            }
        }else {
            let key = self.defaultKey[indexPath.row - 1]
            let value = self.defaultValue[indexPath.row - 1]
            if self.groupDict.count == 0 {
                if let cell = tableView.dequeueReusableCell(withIdentifier: "EmptyGroupCell", for: indexPath) as? EmptyGroupCell {
                    return cell
                }
            }else {
                if let cell = tableView.dequeueReusableCell(withIdentifier: "GroupOtherTableCell", for: indexPath) as? GroupOtherTableCell {
                    cell.descLbl.text = value
                    let pageArray = self.groupDict[key] as! NSArray
                    cell.manageCategoryData(catArray: pageArray)
                    return cell
                }
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
