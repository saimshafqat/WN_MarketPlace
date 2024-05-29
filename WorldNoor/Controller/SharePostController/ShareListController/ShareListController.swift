//
//  ShareListController.swift
//  WorldNoor
//
//  Created by Raza najam on 5/14/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import UIKit

protocol ShareListDelegate : class {
    func shareListValueSelected(text: String , id : String, selectedIndex:Int)
}

class ShareListController: UIViewController {
    @IBOutlet weak var shareTableView: UITableView!
    @IBOutlet var searchView : UISearchBar!
    
    @IBOutlet var lblEmpty : UILabel!
    
    var arrayMain = [ShareSearchObject]()
    var arrayMtbleView = [ShareSearchObject]()
    var selectedValue:Int = 0
    var delegate : ShareListDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.manageData()
        self.lblEmpty.isHidden = true
    }
    
    func manageData(){
        var param:[String:String] = [:]
        switch selectedValue {
        case 1:
            param = ["action": "contacts", "token": SharedManager.shared.userToken(), "user_id":String(SharedManager.shared.getUserID())]
            self.callingGetService(action: 1, param: param)
            self.lblEmpty.text = "No contact found"
        case 2:
            param = ["action": "group/my_groups", "token": SharedManager.shared.userToken(), "user_id":String(SharedManager.shared.getUserID())]
            self.callingGetService(action: 1, param: param)
            self.lblEmpty.text = "No group found"
        case 3:
            param = ["action": "page/my_pages", "token": SharedManager.shared.userToken(), "user_id":String(SharedManager.shared.getUserID())]
            self.callingGetService(action: 1, param: param)
            self.lblEmpty.text = "No page found"
        default:
             LogClass.debugLog("No value found.")
        }
    }
    
    func callingGetService(action:Int, param:[String:String]){
        RequestManager.fetchDataGet(Completion: { response in
            switch response {
            case .failure(let error):

                if error is String {
                }
            case .success(let res):
                self.shareTableView.isHidden = false
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                }else  if res is String {
                    self.lblEmpty.isHidden = false
                    self.shareTableView.isHidden = true
                }else {
                    self.arrayMtbleView = ShareSearchObject.manageShareObjectData(arr: res as! [[String:Any]], selectedIndex: self.selectedValue)
                    self.arrayMain = self.arrayMtbleView
                    self.shareTableView.reloadData()
                }
            }
        }, param:param)
    }
}

extension ShareListController:UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayMtbleView.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "SharingListCell", for: indexPath) as? SharingListCell {
            let shareObj:ShareSearchObject = self.arrayMtbleView[indexPath.row]
            cell.descLbl.text = shareObj.name
            
            cell.imgView.loadImageWithPH(urlMain:shareObj.profileUrlString)
            
            self.view.labelRotateCell(viewMain: cell.imgView)
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let searchObj:ShareSearchObject = self.arrayMtbleView[indexPath.row]
        self.delegate.shareListValueSelected(text: searchObj.name , id : searchObj.id, selectedIndex: self.selectedValue)
        self.navigationController?.popViewController(animated: true)
    }
}

class SharingListCell: UITableViewCell {
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var descLbl: UILabel!
}


extension ShareListController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.arrayMtbleView =  self.arrayMain.filter({(item: ShareSearchObject) -> Bool in
            let stringMatch = item.name.lowercased().range(of: searchText.lowercased())
            return stringMatch != nil ? true : false
        })
        if searchText.count == 0 {
            self.arrayMtbleView = self.arrayMain
        }
        self.shareTableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func filter(array : [[String : String]], byString filterString : String) -> [[String : String]] {
        return array.filter{
            dictionary in
            return dictionary["name"] == filterString
        }
    }
    
}


struct ShareSearchObject  {
    var id:String = ""
    var name: String = ""
    var profileUrlString = ""
    init(dict:[String:Any], selectedValue:Int){
        switch selectedValue {
        case 1:
            let firstName = dict["firstname"] as! String
            let lastName = dict["lastname"] as! String
            self.name = firstName + " " + lastName
            self.id = String(dict["id"] as! Int)
            if let profileImage = dict["profile_image"] as? String {
                self.profileUrlString = profileImage
            }
        case 2:
            self.name = dict["name"] as? String ?? ""
            self.id = String(dict["id"] as! Int)
            if let profileImage = dict["cover_photo_path"] as? String {
                self.profileUrlString = profileImage
            }
        case 3:
            self.name = dict["title"] as? String ?? ""
            self.id = String(dict["id"] as! Int)
            if let profileImage = dict["cover_file_path"] as? String {
                self.profileUrlString = profileImage
            }
        default:
             LogClass.debugLog("No value found")
        }
    }
    
    static func manageShareObjectData(arr:[[String:Any]], selectedIndex:Int) ->[ShareSearchObject]    {
        var shareArr:[ShareSearchObject] = []
        for dict in arr {
            let shareObj = ShareSearchObject.init(dict: dict, selectedValue: selectedIndex)
            shareArr.append(shareObj)
        }
        return shareArr
    }
}
