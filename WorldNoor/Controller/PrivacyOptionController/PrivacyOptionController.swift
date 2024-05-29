//
//  PrivacyOptionController.swift
//  WorldNoor
//
//  Created by Raza najam on 6/23/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import UIKit

protocol PrivacyOptionDelegate {
    func privacyOptionSelected(type:String, keyPair:String)
    func privacyOptionCategorySelected(type:String, catID:[Int:String])
}

class PrivacyOptionController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var tblViewPrivacyOptions: UITableView!
    @IBOutlet weak var tblViewPrivacyOptionsHT: NSLayoutConstraint!
    @IBOutlet weak var btnSeeMore: UIButton!
    @IBOutlet weak var btnDone: UIButton!
    @IBOutlet weak var vwTop: UIView!
    @IBOutlet weak var vwSeeMoreSeperator: UIView!
    @IBOutlet weak var vwSeeMore: UIView!
    
    // MARK: - Properties
    var contactArray:[AnyObject] = []
    var contactDefaultArray:[PrivacyOptionTypes] = []
    var contactValue:[String] = []
    var selecteContactID:[Int:String] = [:]
    var editContactID:[Int:String] = [:]
    var selectedIndex:IndexPath?
    var delegate: PrivacyOptionDelegate?
    var selectedSection = 0
    var isEditPost = false
    var isPredefineValue = false
    var isGroupShow = true
    var selectedSingleIndex = 0
    var selectedPrivacyName:String = ""
    var isAppearFrom = ""
    var currentTitleName = ""
    var isFromPrivacyScreen: Bool = false
    var isShowContactGroup = false
    
    // MARK: - Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        vwTop.isHidden = isFromPrivacyScreen
        
        if !self.isPredefineValue {
            if self.isAppearFrom == "GoLive" {
                self.contactDefaultArray = [PrivacyOptionTypes._contacts, PrivacyOptionTypes._onlyme]
                self.contactValue = ["friends","only_me"]
            }else {
                self.contactDefaultArray = [PrivacyOptionTypes._public, PrivacyOptionTypes._contacts, PrivacyOptionTypes._onlyme]
                self.contactValue = ["public", "friends","only_me"]
            }
        }
        
        manageEditPost()
        setUpTableView()
        selectedPrivacyName == "contact_groups" ? callingGetGroupService() : ()
    }
    
    
    // MARK: -  Actions & Other Methods
    @IBAction func btnBackAction(_ sender: UIButton) {
        popVC()
    }
    
    @IBAction func btnSeeMoreAction(_ sender: UIButton) {
        self.callingGetGroupService()
    }
    
    @IBAction func btnDoneAction(_ sender: UIButton) {
        
        if self.selectedSection == 0 {
                self.popVC()
                self.delegate?.privacyOptionSelected(type: self.contactDefaultArray[selectedSingleIndex].defaultValue, keyPair: self.contactValue[selectedSingleIndex])
        }else {
            if self.selecteContactID.count > 0 {
                self.popVC()
//                self.dismissVC {
                    self.delegate?.privacyOptionCategorySelected(type: "contact_groups", catID: self.selecteContactID)
//                }
            }else {
                self.popVC()
//                self.dismissVC {
                    self.delegate?.privacyOptionSelected(type: self.contactDefaultArray[0].defaultValue, keyPair: self.contactValue[0])
//                }
            }
        }
    }
    
    func manageEditPost() {
        self.selectedSection = 0
        if selectedPrivacyName == "contact_groups" {
            self.selectedSection = 1
            for (_, v) in self.editContactID {
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
        }else if selectedPrivacyName == "friends" || selectedPrivacyName == "contacts" || selectedPrivacyName == "friends_of_friends" {
            selectedSingleIndex = 1
        }else {
            selectedSingleIndex = 0
        }
        if contactArray.count > 0 {
            tblViewPrivacyOptionsHT.constant = CGFloat(71*contactDefaultArray.count)+CGFloat(71*contactArray.count)+60
        }
        self.tblViewPrivacyOptions.reloadData()
    }
    
    func callingGetGroupService() {
        let userToken = SharedManager.shared.userToken()
        let parameters = ["action": "contact_groups", "token":userToken]
        RequestManager.fetchDataGet(Completion: { [self] response in
            switch response {
            case .failure(let error):
                SwiftMessages.apiServiceError(error: error)
            case .success(let res):
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                } else  if res is String {
                    SwiftMessages.showMessagePopup(theme: .error, title: "Failed", body: res as? String ?? .emptyString)
                } else {
                    self.contactArray = res as! [AnyObject]
                    if contactArray.count > 0 {
                        contactArray.remove(at: 0)
                    }
                    
                    isShowContactGroup = true
                    vwSeeMore.isHidden = true
                    self.manageEditPost()
                }
            }
        }, param:parameters)
    }
}

extension PrivacyOptionController:UITableViewDelegate, UITableViewDataSource {
    
    func setUpTableView() {
        tblViewPrivacyOptions.dataSource = self
        tblViewPrivacyOptions.delegate = self
        tblViewPrivacyOptionsHT.constant = CGFloat(71*contactDefaultArray.count)+30
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.contactDefaultArray.count
        }
        return self.contactArray.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.isGroupShow && isShowContactGroup {
            return 2
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: PrivacyTableCell.identifier, for: indexPath) as? PrivacyTableCell {
            cell.imgViewSelectRadio.image = UIImage.radioUnCheck
            if indexPath.section == 0 {
                
                if self.selectedSection == 0 {
                    if indexPath.row == self.selectedSingleIndex {
//                        if !isFromPrivacyScreen {
                            cell.imgViewSelectRadio.image = UIImage.radioCheck
//                        }
                    }
                }
                
                cell.lblTitle.text = self.contactDefaultArray[indexPath.row].defaultValue
                cell.lblDesc.text = self.contactDefaultArray[indexPath.row].desc
                cell.imgViewNavigate.image = self.contactDefaultArray[indexPath.row].image
                cell.lblDesc.isHidden = false
                cell.imgViewNavigate.isHidden = false
                
            } else {
                
                if self.selectedSection == 1 {
                    if self.selecteContactID[indexPath.row] != nil {
//                        if !isFromPrivacyScreen {
                            cell.imgViewSelectRadio.image = UIImage.radioCheck
//                        }
                    }
                }
                
                let dict = self.contactArray[indexPath.row] as! NSDictionary
                cell.manageCellContact( dict: dict)
                cell.lblDesc.isHidden = true
                cell.imgViewNavigate.isHidden = true
            }
            cell.lblTitle.rotateForTextAligment()
            self.view.labelRotateCell(viewMain: cell.lblTitle)
            cell.lblDesc.rotateForTextAligment()
            self.view.labelRotateCell(viewMain: cell.lblDesc)
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.selectedSection = indexPath.section
        
        if isFromPrivacyScreen {
            self.selecteContactID.removeAll()
            if indexPath.section == 0 {
//                self.dismissVC {
//                    self.delegate?.privacyOptionSelected(type: self.contactDefaultArray[indexPath.row].defaultValue, keyPair: self.contactValue[indexPath.row])
//                }
                
                selectedSingleIndex = indexPath.row
                
            } else {
                let dict = self.contactArray[indexPath.row] as? [String: Any]
                let contactID = dict?["id"] as? Int ?? 0
                let contactName = dict?["title"] as? String ?? .emptyString
                if self.selecteContactID[indexPath.row] != nil {
                    self.selecteContactID.removeValue(forKey: indexPath.row)
                } else {
                    self.selecteContactID[indexPath.row] = String(contactID)
                }
//                self.dismissVC {
//                    self.delegate?.privacyOptionCategorySelected(type: "contact_groups", catID: self.selecteContactID)
//                }
            }
        } else {
            if indexPath.section == 0 {
                self.selecteContactID.removeAll()
//                self.dismissVC {
//                    self.delegate?.privacyOptionSelected(type: self.contactDefaultArray[indexPath.row].defaultValue, keyPair: self.contactValue[indexPath.row])
//                }
                
                selectedSingleIndex = indexPath.row
                
            } else {
                let dict = self.contactArray[indexPath.row] as! NSDictionary
                let contactID = dict["id"] as! Int
                if self.selecteContactID[indexPath.row] != nil {
                    self.selecteContactID.removeValue(forKey: indexPath.row)
                } else {
                    self.selecteContactID[indexPath.row] = String(contactID)
                }
            }
        }
        
        self.tblViewPrivacyOptions.reloadData()
    }
    
        func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            return 30
        }

        func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
            if section == 1 {
                let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 30))
                let label = UILabel(frame: CGRect(x: 10, y: 0, width: view.frame.size.width, height: 30))
                label.font = UIFont.systemFont(ofSize: 16)
                label.text = "Contact Groups".localized()
                view.addSubview(label)
                return view
                
            }else {
                
                let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 30))
                let label = UILabel(frame: CGRect(x: 10, y: 0, width: view.frame.size.width, height: 30))
                label.font = UIFont.systemFont(ofSize: 16)
                label.text = "Choose Default Audience".localized()
                view.addSubview(label)
                return view
            }
        }
}

