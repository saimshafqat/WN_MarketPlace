//
//  ContactListViewController.swift
//  WorldNoor
//
//  Created by Waseem Shah on 11/09/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import Foundation
import UIKit


class ContactListViewController: UIViewController {
    
    @IBOutlet weak var moreTableView: UITableView!
    
    @IBOutlet weak var collectionViewUsers: UICollectionView!
    
    @IBOutlet weak var tfSearchBar: UISearchBar!
    
    @IBOutlet weak var viewFindUsers: UIView!
    
    @IBOutlet weak var viewChatBtn: UIView!
    
    @IBOutlet weak var viewGroupUsers: UIView!
    @IBOutlet weak var cstTableTop: NSLayoutConstraint!
    @IBOutlet weak var cstTableBottom: NSLayoutConstraint!
    
    var groupID:String = ""
    var contactArray:[FriendChatModel] = []
    
    var arrayCollection:[FriendChatModel] = []
    var tblArray:[FriendChatModel] = []
    
    var selectedArray:[FriendChatModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionViewUsers.register(UINib(nibName: "UserSelectCell", bundle: nil), forCellWithReuseIdentifier: "UserSelectCell")
        self.title = Const.ContactViewTitle.localized()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if self.tblArray.count == 0 {
            self.viewFindUsers.isHidden = true
            self.callingGetGroupService()
            self.moreTableView.rotateViewForLanguage()
        }
    }
    
    func callingGetGroupService() {
        self.contactArray.removeAll()
        self.tblArray.removeAll()
        self.selectedArray.removeAll()
        self.collectionViewUsers.reloadData()
        
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
                    self.viewFindUsers.isHidden = false
                } else {
                    
                    if let newRes = res as? [[String : AnyObject]] {
                        for indexFriend in newRes{
                            let friendObjMain = FriendChatModel.init(fromDictionary: indexFriend)
                            
                            self.contactArray.append(friendObjMain)
                            self.tblArray.append(friendObjMain)
                        }
                    }
                    self.moreTableView.reloadData()
                }
            }
        }, param:parameters)
    }
    
    
    @IBAction func showNewView(sender : UIButton) {
        let nearVC = self.GetView(nameVC: "NearByUsersVC", nameSB:"EditProfile" ) as! NearByUsersVC
        self.navigationController?.pushViewController(nearVC, animated: true)
    }
}

extension ContactListViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tblArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ContactChatOptionCell", for: indexPath) as? ContactChatOptionCell {
            let indexPathMain = IndexPath.init(row: indexPath.row , section: 0)
            cell.manageContact( dict: self.tblArray[indexPath.row])
            cell.viewSelection.isHidden = false
            cell.imgviewSelection.isHidden = true
            cell.viewSelection.backgroundColor = UIColor.white
            if self.selectedArray.contains(where: { $0.id == self.tblArray[indexPath.row].id}) {
                
                cell.viewSelection.backgroundColor = UIColor.blueColor
                cell.imgviewSelection.isHidden = false
            }
            
            cell.selectionStyle = .none
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let dict = self.tblArray[indexPath.row]
        var isFind : Bool = false
        for indexObj in 0..<self.selectedArray.count {
            if self.ReturnValueCheck(value: self.selectedArray[indexObj].id) == self.ReturnValueCheck(value: dict.id) {
                self.selectedArray.remove(at: indexObj)
                self.arrayCollection.remove(at: indexObj)
                isFind = true
                break
            }
        }
        if !isFind {
            self.selectedArray.append(dict)
            self.arrayCollection.append(dict)
        }
        if self.selectedArray.count > 0 {
            self.cstTableTop.constant = 130
            self.cstTableBottom.constant = 75
            self.viewGroupUsers.isHidden = false
            self.viewChatBtn.isHidden = false
            self.view.layoutIfNeeded()
            
        } else {
            self.cstTableTop.constant = 00
            self.cstTableBottom.constant = 0
            self.viewGroupUsers.isHidden = true
            self.viewChatBtn.isHidden = true
            self.view.layoutIfNeeded()
            
        }
        
        self.moreTableView.reloadData()
        self.collectionViewUsers.reloadData()
    }
    
    @IBAction func goChat(sender : UIButton){
        if self.selectedArray.count == 1 {
            var dict = FriendChatModel() //[String : Any]()
            for iundexInner in self.contactArray {
                for indexObj in 0..<self.selectedArray.count {
                    if self.ReturnValueCheck(value: self.selectedArray[indexObj].id) == self.ReturnValueCheck(value: iundexInner.id) {
                        dict = iundexInner
                        break
                    }
                }
            }
            let conversationModel:Chat?
            
            let moc = CoreDbManager.shared.persistentContainer.viewContext
            if dict.latest_coversation_id != "" {
                if ChatDBManager().checkRecordExists(value: Int(dict.latest_coversation_id)!) {
                    conversationModel = ChatDBManager().getChatFromDb(conversationID: dict.latest_coversation_id)
                }else {
                    conversationModel = Chat(context: moc)
                }
            }else {
                conversationModel = Chat(context: moc)
            }
            guard conversationModel != nil else { return }
            conversationModel!.name = self.ReturnValueCheck(value: dict.firstname) + " " + self.ReturnValueCheck(value: dict.lastname as Any)
            conversationModel!.conversation_id = self.ReturnValueCheck(value: dict.latest_coversation_id)
            conversationModel!.profile_image = self.ReturnValueCheck(value: dict.profile_image)
            conversationModel!.member_id = self.ReturnValueCheck(value: dict.id)
            
            let contactGroup = AppStoryboard.PostStoryboard.instance.instantiateViewController(withIdentifier: Const.ChatViewController) as! ChatViewController
            contactGroup.conversatonObj = conversationModel!
            self.navigationController?.pushViewController(contactGroup, animated: true)
        }else {
            let viewMain = self.GetView(nameVC: "GroupChatCreateVC", nameSB: "Notification") as! GroupChatCreateVC
            viewMain.arrayFriends = self.arrayCollection
            self.navigationController?.pushViewController(viewMain, animated: true)
        }
    }
}


extension ContactListViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.tblArray = self.contactArray.filter{
            (($0.firstname) + " " + ($0.lastname)).range(of: searchText,
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
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        self.tblArray = self.contactArray
        self.moreTableView.reloadData()
    }
}

class ContactChatOptionCell : UITableViewCell {
    
    @IBOutlet var imgViewMain : UIImageView!
    @IBOutlet var lblName : UILabel!
    @IBOutlet var viewSelection : UIView!
    @IBOutlet var imgviewSelection : UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func manageContact( dict:FriendChatModel){
        self.lblName.text = dict.firstname + " " + dict.lastname
        self.imgViewMain.image = UIImage(named: "placeholder.png")
        if dict.profile_image.count > 0  {
            let profileImag = dict.profile_image
            
            self.imgViewMain.loadImageWithPH(urlMain:profileImag)
            
            self.labelRotateCell(viewMain: self.imgViewMain)
        }
        
        self.lblName.rotateForTextAligment()
        self.labelRotateCell(viewMain: self.lblName)
        self.lblName.dynamicBodyRegular17()
    }
}

extension ContactListViewController : UICollectionViewDelegate , UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: self.collectionViewUsers.frame.size.height, height: self.collectionViewUsers.frame.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrayCollection.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let userCell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserSelectCell", for: indexPath) as! UserSelectCell
        
        let dict = self.arrayCollection[indexPath.row]
        userCell.lblUser.text = dict.firstname + " " + dict.lastname
        userCell.imgviewUser.image = UIImage(named: "placeholder.png")
        //        if !(dict.value(forKey: "profile_image") is NSNull) {
        if dict.profile_image.count > 0 {
            let profileImag = dict.profile_image
            
            userCell.imgviewUser.loadImageWithPH(urlMain:profileImag)
        }
        
        userCell.indexPath = indexPath
        userCell.onRemoveUser = { [weak self](indexPath) in
            self?.arrayCollection.remove(at: indexPath.row)
            self?.selectedArray.remove(at: indexPath.row)
            self?.collectionViewUsers.reloadData()
            self?.moreTableView.reloadData()
            
            if (self?.selectedArray.count)! > 0 {
                self?.cstTableTop.constant = 130
                self?.cstTableBottom.constant = 75
                self?.viewGroupUsers.isHidden = false
                self?.viewChatBtn.isHidden = false
                self?.view.layoutIfNeeded()
                
            } else {
                self?.cstTableTop.constant = 00
                self?.cstTableBottom.constant = 0
                self?.viewGroupUsers.isHidden = true
                self?.viewChatBtn.isHidden = true
                self?.view.layoutIfNeeded()
                
            }
        }
        return userCell
    }
}


class UserSelectCell : UICollectionViewCell {
    @IBOutlet var imgviewUser: UIImageView!
    @IBOutlet var lblUser: UILabel!
    @IBOutlet var btnRemove: UIButton!
    
    var indexPath : IndexPath!
    var onRemoveUser : ((IndexPath) -> Void)? = nil
    
    
    @IBAction func removeUser(sender : UIButton){
        self.onRemoveUser?(self.indexPath)
    }
}
