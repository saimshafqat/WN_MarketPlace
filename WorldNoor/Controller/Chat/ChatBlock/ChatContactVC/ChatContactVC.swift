//
//  ChatContactVC.swift
//  WorldNoor
//
//  Created by ogouluser1-mac6 on 13/09/2023.
//  Copyright © 2019 Raza najam. All rights reserved.
//

import UIKit
import Photos
import TLPhotoPicker
import AVFoundation
import FittedSheets

class ChatContactVC: UIViewController {
    
    @IBOutlet weak var moreTableView: UITableView!
    @IBOutlet weak var tfSearchBar: UISearchBar!{
        didSet{
            tfSearchBar.searchBarStyle = .minimal
        }
    }
    
    var groupID:String = ""
    var contactArray:[AnyObject] = []
    var tblArray:[AnyObject] = []
    var titleStr = "Contact"
    var appearFrom = ""
    var sheetController = SheetViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = titleStr.localized()
        self.callingGetGroupService()
        self.moreTableView.estimatedRowHeight = 40
        self.moreTableView.rowHeight = UITableView.automaticDimension
        self.moreTableView.register(UINib.init(nibName: "ChatOptionCell", bundle: nil), forCellReuseIdentifier: "ChatOptionCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.moreTableView.rotateViewForLanguage()
    }
    
    func manageUI(){
        
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
                SwiftMessages.apiServiceError(error: error)
            case .success(let res):
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                } else if res is String {
                    self.tblArray.removeAll()
                    self.moreTableView.reloadData()
                    SwiftMessages.showMessagePopup(theme: .error, title: "Failed", body: res as? String ?? .emptyString)
                } else {
                    self.contactArray = res as! [AnyObject]
                    self.tblArray = res as! [AnyObject]
                    self.moreTableView.reloadData()
                }
            }
        }, param:parameters)
    }
}

extension ChatContactVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tblArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: Const.MyContactCell, for: indexPath) as? MyContactCell {
            if let dict = self.tblArray[indexPath.row] as? NSDictionary {
                cell.manageContact( dict: dict)
            }
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dict = self.tblArray[indexPath.row] as! NSDictionary
        tableView.deselectRow(at: indexPath, animated: true)
        if appearFrom == "Restrict" {
            let restrictVC = AppStoryboard.Chat.instance.instantiateViewController(withIdentifier: RestrictionDetailVC.className) as! RestrictionDetailVC
            restrictVC.contactDict = dict as? [String : AnyObject]
            if let navigationController = self.navigationController {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
                    navigationController.viewControllers.remove(at: navigationController.viewControllers.count - 2)
                }
                self.pushFromBottom(restrictVC)
            }
        }else if appearFrom == "HideContact" {
            let hideContactVC = AppStoryboard.Chat.instance.instantiateViewController(withIdentifier: HiddenContactDetailVC.className) as! HiddenContactDetailVC
            hideContactVC.contactDict = dict as? [String : AnyObject]
            if let navigationController = self.navigationController {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
                    navigationController.viewControllers.remove(at: navigationController.viewControllers.count - 2)
                }
                self.pushFromBottom(hideContactVC)
            }
        }else {
            let blockSheet = AppStoryboard.Chat.instance.instantiateViewController(withIdentifier: ChatBlockSheetVC.className) as! ChatBlockSheetVC
            blockSheet.delegate = self
            blockSheet.contactDict = dict as? [String : AnyObject]
            self.sheetController = SheetViewController(controller: blockSheet, sizes: [.fixed(380)])
            self.sheetController.overlayColor = UIColor.black.withAlphaComponent(0.3)
            self.sheetController.extendBackgroundBehindHandle = true
            self.sheetController.topCornersRadius = 20
            self.present(self.sheetController, animated: false, completion: nil)
        }
    }
    
}

extension ChatContactVC: UISearchBarDelegate {
    
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

extension ChatContactVC:ContactBlockedSheetDelegate {
    func contactBlockedSheetDelegate() {
        self.sheetController.closeSheet()
        self.callingGetGroupService()
    }
}
