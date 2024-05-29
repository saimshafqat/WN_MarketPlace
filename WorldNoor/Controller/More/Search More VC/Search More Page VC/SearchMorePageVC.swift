//
//  SearchMorePageVC.swift
//  WorldNoor
//
//  Created by apple on 11/1/21.
//  Copyright © 2021 Raza najam. All rights reserved.
//

import Foundation
import UIKit

class SearchMorePageVC : UIViewController {
    
    
    var searchString = ""
    var screenTitle: String = .emptyString
    var isPage = false
    @IBOutlet var tblViewUser : UITableView!
    var isLoadMoreRequire: Bool = true
    
    var isAPICall = false
    var arrayPage = [GroupValue]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tblViewUser.register(UINib.init(nibName: "SearchUserCell", bundle: nil), forCellReuseIdentifier: "SearchUserCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = screenTitle
        self.apiCall()
    }
    
    
    func isFeedReachEnd(indexPath:IndexPath){
        if !isAPICall {
            let feedCurrentCount = self.arrayPage.count
            if indexPath.row == feedCurrentCount-1 {
                self.apiCall()
            }
        }
    }
    
    func apiCall(){
        self.isAPICall = true
        Loader.startLoading()
        var parameters = ["action": "search/pages","token": SharedManager.shared.userToken() , "query" : self.searchString , "per_page" : "20"]
        if self.isPage {
            parameters["action"] = "search/pages"
        }else {
            parameters["action"] =  "search/groups"
        }
        if self.arrayPage.count > 0 {
            let lastindex = self.arrayPage.count - 1
            let postObj = self.arrayPage[lastindex]
            parameters["starting_point_id"] = postObj.groupID
        }
        RequestManager.fetchDataGet(Completion: { (response) in
            Loader.stopLoading()
            switch response {
            
            case .failure(let error):
                self.isLoadMoreRequire = false
                self.isAPICall = false
SwiftMessages.apiServiceError(error: error)            case .success(let res):
                if res is Int {
                    self.isAPICall = false
                    AppDelegate.shared().loadLoginScreen()
                } else  if let newRes = res as? [[String:Any]] {
                    for indexContact in newRes {
                        if self.isPage {
                            self.arrayPage.append(GroupValue.init(fromDictionary: indexContact))
                        } else {
                            if newRes.count == 0 {
                                self.isAPICall = false
                            }
                            let groupValue = GroupValue.init(fromDictionaryGroup: indexContact)
                            if !(self.arrayPage.contains(where: {$0.groupID == groupValue.groupID})) {
                                self.arrayPage.append(groupValue)
                            } else {
                                self.isAPICall = false
                            }
                        }
                    }
                    self.isAPICall = false
                }
                DispatchQueue.main.async {
                    self.tblViewUser.reloadData()
                }
            }
        }, param: parameters)
    }
}

extension SearchMorePageVC : UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayPage.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cellUSer = tableView.dequeueReusableCell(withIdentifier: "SearchUserCell", for: indexPath) as? SearchUserCell else {
            return UITableViewCell()
        }
        
        
        if self.isPage {
//            let urlString = URL(string:self.arrayPage[indexPath.row].groupImage)
//            cellUSer.imgViewUser.sd_imageIndicator = SDWebImageActivityIndicator.gray
//            cellUSer.imgViewUser.sd_setImage(with:urlString, placeholderImage: UIImage(named: "placeholder.png"))
            
            cellUSer.imgViewUser.loadImageWithPH(urlMain:self.arrayPage[indexPath.row].groupImage)
            
            cellUSer.lblUserName.text = self.arrayPage[indexPath.row].groupName
        }else {
//            let urlString = URL(string:self.arrayPage[indexPath.row].groupImage)
            
            cellUSer.imgViewUser.loadImageWithPH(urlMain:self.arrayPage[indexPath.row].groupImage)
//            cellUSer.imgViewUser.sd_imageIndicator = SDWebImageActivityIndicator.gray
//            cellUSer.imgViewUser.sd_setImage(with:urlString, placeholderImage: UIImage(named: "placeholder.png"))
            cellUSer.lblUserName.text = self.arrayPage[indexPath.row].groupName

        }
        self.view.labelRotateCell(viewMain: cellUSer.imgViewUser)
        cellUSer.lblUserAddress.text = ""
 
        cellUSer.viewStatus.isHidden = true
        self.isFeedReachEnd(indexPath: indexPath)
        
        cellUSer.selectionStyle = .none
        return cellUSer
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.isPage{
            let pageView = AppStoryboard.Kids.instance.instantiateViewController(withIdentifier: "PagePostController") as! PagePostController
            pageView.groupObj = self.arrayPage[indexPath.row]
            self.navigationController?.pushViewController(pageView, animated: true)
        }else {
//            let groupView = AppStoryboard.Kids.instance.instantiateViewController(withIdentifier: "NewGroupDetailVC") as! NewGroupDetailVC
//            groupView.groupObj = self.arrayPage[indexPath.row]
//            self.navigationController?.pushViewController(groupView, animated: true)
            
            let groupView = AppStoryboard.Kids.instance.instantiateViewController(withIdentifier: "GroupPostController1") as! GroupPostController1
            groupView.groupObj = self.arrayPage[indexPath.row]
            self.navigationController?.pushViewController(groupView, animated: true)
        }
    }
}

