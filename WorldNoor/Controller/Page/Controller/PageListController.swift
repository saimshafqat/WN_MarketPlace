//
//  PageListController.swift
//  WorldNoor
//
//  Created by Raza najam on 4/1/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import UIKit

class PageListController: UIViewController, CreatePageDelegate {
    
    @IBOutlet weak var pageTableView: UITableView!
    var pageMainDict:[String:Any] = [String:Any]()
    var pageArray:[Any] = [Any]()
    var pageObj:PageCreateController = PageCreateController.init()
    var pageCatName:[String] = [String]()
    
    var defaultKey:[String] = []
    var defaultValue:[String] = []


    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Pages"
        self.defaultKey = ["my_pages","liked_pages", "suggested_pages"]
        self.defaultValue = ["Your Pages".localized(),"Liked Pages".localized(),"Suggested Pages".localized()]
      
    }
    
    override func viewWillAppear(_ animated: Bool) {
          super.viewWillAppear(animated)
          if SharedManager.shared.isGrouplistUpdate {
             SharedManager.shared.isGrouplistUpdate = false
//              self.callingPageListService()
          }
        
        

        self.callingPageListService()
      }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.callbackHandler()
    }
      
    func callbackHandler(){
        GroupHandler.shared.groupCallBackHandler = { [weak self] (groupObj) in
            
             
            
            
            let pageView = AppStoryboard.Kids.instance.instantiateViewController(withIdentifier: "PagePostController") as! PagePostController
            pageView.groupObj = groupObj
            self!.navigationController?.pushViewController(pageView, animated: true)
            
//            let pageView = AppStoryboard.Kids.instance.instantiateViewController(withIdentifier: "NewPageDetailVC") as! NewPageDetailVC
//            pageView.groupObj = groupObj
//            self!.navigationController?.pushViewController(pageView, animated: true)
        }
    }
    
    @IBAction func createNewPageClicked(_ sender: Any) {
        self.pageObj = self.GetView(nameVC: "PageCreateController", nameSB: "Group") as! PageCreateController
        self.pageObj.delegate = self
        UIApplication.shared.keyWindow!.addSubview((self as PageListController).pageObj.view)
    }
    
    func callingPageListService(){
        let parameters = ["action": "page/list", "token": SharedManager.shared.userToken()]
//        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        RequestManager.fetchDataGet(Completion: { response in
            
            switch response {
            case .failure(let error):
//                SharedManager.shared.hideLoadingHubFromKeyWindow()
                Loader.stopLoading()
                if error is String {
                }
            case .success(let res):
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                }else if res is String {
                    //  SharedManager.shared.showAlert(message: res as! String, view: self)
                }else {
                    self.pageMainDict = res as! [String:Any]
                    if let categoryDict = self.pageMainDict["categories"] as? [[String:Any]] {
                        self.pageMainDict.removeValue(forKey: "categories")
                    }
                    for (k, name) in self.pageMainDict {
                        self.pageCatName.append(k)
                        self.pageArray.append(self.pageMainDict[k] as! [Any])
                    }
//                    SharedManager.shared.hideLoadingHubFromKeyWindow()
                    Loader.stopLoading()
                    self.pageTableView.reloadData()
                }
            }
        }, param:parameters)
    }
    
    func pageCreatedSuccessfullyDelegate() {
        self.callingPageListService()
    }
}

extension PageListController:UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.pageMainDict.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let arr = self.pageMainDict
        if arr.count == 0 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "EmptyGroupCell", for: indexPath) as? EmptyGroupCell {
                return cell
            }
        }else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "PageCell", for: indexPath) as? PageCell {
                let key = self.defaultKey[indexPath.row]
                let value = self.defaultValue[indexPath.row]
                let pageArray = self.pageMainDict[key] as! NSArray
                cell.descLbl.text = value
                cell.manageCategoryData(catArray: pageArray)
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
