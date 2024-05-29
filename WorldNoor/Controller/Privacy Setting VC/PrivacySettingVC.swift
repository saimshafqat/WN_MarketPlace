//
//  PrivacySettingVC.swift
//  WorldNoor
//
//  Created by apple on 9/3/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import UIKit
import FittedSheets

class PrivacySettingVC: UIViewController {
    
    @IBOutlet var lbl_FuturePost : UILabel!
    @IBOutlet var lbl_SendFriendRequest : UILabel!
    @IBOutlet var lbl_FriendList : UILabel!
    @IBOutlet var lbl_EmailProvided : UILabel!
    @IBOutlet var lbl_PhoneNumber : UILabel!
    
    
    @IBOutlet var lbl_FuturePost_heading : UILabel!
    @IBOutlet var lbl_SendFriendRequest_heading : UILabel!
    @IBOutlet var lbl_FriendList_heading : UILabel!
    @IBOutlet var lbl_EmailProvided_heading : UILabel!
    @IBOutlet var lbl_PhoneNumber_heading : UILabel!
    
    @IBOutlet var view_FuturePost : UIView!
    @IBOutlet var view_SendFriendRequest : UIView!
    @IBOutlet var view_FriendList : UIView!
    @IBOutlet var view_EmailProvided : UIView!
    @IBOutlet var view_PhoneNumber : UIView!
    
    @IBOutlet var view_FuturePost_Edit : UIView!
    @IBOutlet var view_SendFriendRequest_Edit : UIView!
    @IBOutlet var view_FriendList_Edit : UIView!
    @IBOutlet var view_EmailProvided_Edit : UIView!
    @IBOutlet var view_PhoneNumber_Edit : UIView!
    
    // MARK: - Properties -
    var selectedPrivacyIDs:[Int:String] = [:]
    var selectedOptions = ""
    
    var valueSelected = -1
    var objmain = PrivacyModel.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view_FuturePost.rotateViewForLanguage()
        self.view_SendFriendRequest.rotateViewForLanguage()
        self.view_FriendList.rotateViewForLanguage()
        self.view_EmailProvided.rotateViewForLanguage()
        self.view_PhoneNumber.rotateViewForLanguage()
        
        
        
        self.lbl_FuturePost_heading.rotateViewForLanguage()
        self.lbl_SendFriendRequest_heading.rotateViewForLanguage()
        self.lbl_FriendList_heading.rotateViewForLanguage()
        self.lbl_EmailProvided_heading.rotateViewForLanguage()
        self.lbl_PhoneNumber_heading.rotateViewForLanguage()
        
        
        self.lbl_FuturePost_heading.rotateViewForInner()
        self.lbl_SendFriendRequest_heading.rotateViewForInner()
        self.lbl_FriendList_heading.rotateViewForInner()
        self.lbl_EmailProvided_heading.rotateViewForInner()
        self.lbl_PhoneNumber_heading.rotateViewForInner()
        
        
        self.lbl_FuturePost_heading.rotateForTextAligment()
        self.lbl_SendFriendRequest_heading.rotateForTextAligment()
        self.lbl_FriendList_heading.rotateForTextAligment()
        self.lbl_EmailProvided_heading.rotateForTextAligment()
        self.lbl_PhoneNumber_heading.rotateForTextAligment()
        
        
        
        //////
        
        
        self.lbl_FuturePost.rotateViewForLanguage()
        self.lbl_SendFriendRequest.rotateViewForLanguage()
        self.lbl_FriendList.rotateViewForLanguage()
        self.lbl_EmailProvided.rotateViewForLanguage()
        self.lbl_PhoneNumber.rotateViewForLanguage()
        
        
        self.lbl_FuturePost.rotateViewForInner()
        self.lbl_SendFriendRequest.rotateViewForInner()
        self.lbl_FriendList.rotateViewForInner()
        self.lbl_EmailProvided.rotateViewForInner()
        self.lbl_PhoneNumber.rotateViewForInner()
        
        
        self.lbl_FuturePost.rotateForTextAligment()
        self.lbl_SendFriendRequest.rotateForTextAligment()
        self.lbl_FriendList.rotateForTextAligment()
        self.lbl_EmailProvided.rotateForTextAligment()
        self.lbl_PhoneNumber.rotateForTextAligment()
        
        
        
        ///////
        self.view_FuturePost_Edit.rotateViewForLanguage()
        self.view_SendFriendRequest_Edit.rotateViewForLanguage()
        self.view_FriendList_Edit.rotateViewForLanguage()
        self.view_EmailProvided_Edit.rotateViewForLanguage()
        self.view_PhoneNumber_Edit.rotateViewForLanguage()
        
        
        self.view_FuturePost_Edit.rotateViewForInner()
        self.view_SendFriendRequest_Edit.rotateViewForInner()
        self.view_FriendList_Edit.rotateViewForInner()
        self.view_EmailProvided_Edit.rotateViewForInner()
        self.view_PhoneNumber_Edit.rotateViewForInner()
        
        
        self.lbl_FriendList.text = ""
        self.lbl_FuturePost.text = ""
        self.lbl_PhoneNumber.text = ""
        self.lbl_EmailProvided.text = ""
        self.lbl_SendFriendRequest.text = ""
        
        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.lbl_FriendList.text = SharedManager.shared.PrivacyObj.FriendListValue.capitalizingFirstLetter().localized()
        self.lbl_FuturePost.text = SharedManager.shared.PrivacyObj.FuturePostValue.capitalizingFirstLetter().localized()
        self.lbl_PhoneNumber.text = SharedManager.shared.PrivacyObj.PhoneNumberValue.capitalizingFirstLetter().localized()
        self.lbl_EmailProvided.text = SharedManager.shared.PrivacyObj.EmailAddressValue.capitalizingFirstLetter().localized()
        self.lbl_SendFriendRequest.text = SharedManager.shared.PrivacyObj.FriendRequestValue.capitalizingFirstLetter().localized()
    }
    
    
    @IBAction func changeFuturePost(sender : UIButton){
        valueSelected = 1
        let defaultValue = SharedManager.shared.PrivacyObj.FuturePostSettingValue
        self.navigateToPrivacyOptionVC(lbl_FuturePost.text ?? .emptyString, defaultValue: defaultValue)
    }
    
    @IBAction func changeFriendPost(sender : UIButton){
        valueSelected = 2
        let defaultValue = SharedManager.shared.PrivacyObj.FriendRequestSettingValue
        self.navigateToPrivacyOptionVC(lbl_SendFriendRequest.text ?? .emptyString, defaultValue: defaultValue)
    }
    
    @IBAction func changeFriendList(sender : UIButton){
        valueSelected = 3
        let defaultValue = SharedManager.shared.PrivacyObj.FriendListSettingValue
        self.navigateToPrivacyOptionVC(lbl_FriendList.text ?? .emptyString, defaultValue: defaultValue)
    }
    
    @IBAction func changeEmailAddress(sender : UIButton){
        valueSelected = 4
        let defaultValue = SharedManager.shared.PrivacyObj.EmailAddressSettingValue
        self.navigateToPrivacyOptionVC(lbl_EmailProvided.text ?? .emptyString, defaultValue: defaultValue)
    }
    
    @IBAction func changePhoneNumber(sender : UIButton){
        valueSelected = 5
        let defaultValue = SharedManager.shared.PrivacyObj.PhoneNumberSettingValue
        self.navigateToPrivacyOptionVC(lbl_PhoneNumber.text ?? .emptyString, defaultValue: defaultValue)
    }
    
    func navigateToPrivacyOptionVC(_ currentValue: String = .emptyString, defaultValue: String){
        self.selectedPrivacyIDs.removeAll()
        self.selectedOptions = ""
        let privacyController = PrivacyOptionController.instantiate(fromAppStoryboard: .PostStoryboard)
        privacyController.isEditPost = true
        privacyController.isPredefineValue = true
        privacyController.currentTitleName = currentValue
        privacyController.isFromPrivacyScreen = true
        privacyController.selectedPrivacyName = defaultValue
        switch self.valueSelected {
            
        case 1:
            privacyController.contactDefaultArray = [._public, ._contacts, ._onlyme]
            privacyController.contactValue = ["public", "contacts","only_me"]
            
        case 2:
            privacyController.contactDefaultArray = [._everyone, ._friendsoffriends]
            privacyController.contactValue = ["everyone", "friends_of_friends"]
            privacyController.isGroupShow = false
            
        case 3:
            privacyController.contactDefaultArray = [._public, ._contacts, ._onlyme]
            privacyController.contactValue = ["public", "contacts", "only_me"]
            
        case 4:
            privacyController.contactDefaultArray = [._public, ._contacts, ._onlyme]
            privacyController.contactValue = ["public", "contacts","only_me"]
            
        case 5:
            privacyController.contactDefaultArray = [._public, ._contacts, ._onlyme]
            privacyController.contactValue = ["public", "contacts","only_me"]
        default:
            break
        }
        privacyController.delegate = self
        pushVC(privacyController)
        //openBottomSheet(privacyController, sheetSize: [.fixed(600)], animated: false)
    }
}


extension PrivacySettingVC : PrivacyOptionDelegate {
    func privacyOptionSelected(type:String, keyPair:String) {
        selectedOptions = keyPair
        updateSetting(keyPair)
    }
    
    func privacyOptionCategorySelected(type:String, catID:[Int:String]){
        if type.count > 0 {
            self.selectedPrivacyIDs = catID
            self.updateSetting()
        }
    }
    
    func updateSetting(_ keyPair: String = .emptyString){
        Loader.startLoading()
        var parameters : [String : Any] = ["action": "privacy/update_setting","token": SharedManager.shared.userToken() ]
        var arrayValue = [String]()
        switch self.valueSelected {
        case 1:
            parameters["setting_type"] = "future_posts"
        case 2:
            parameters["setting_type"] = "friend_requests"
        case 3:
            parameters["setting_type"] = "friends_list"
        case 4:
            parameters["setting_type"] = "search_from_email"
        case 5:
            parameters["setting_type"] = "search_from_phone"
        default:
            break
        }
        
        if self.selectedPrivacyIDs.count > 0 {
            parameters["setting_value_type"] = "contact_group"
            for indexObj in self.selectedPrivacyIDs.keys {
                arrayValue.append(self.selectedPrivacyIDs[indexObj]!)
            }
        }else {
            arrayValue.append(self.selectedOptions)
        }
        
        
        parameters["setting_values"] = arrayValue
        
        RequestManager.fetchDataPost(Completion: { (response) in
            //            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            switch response {
            case .failure(let error):
                SwiftMessages.apiServiceError(error: error)            
            case .success(let res):
                
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                } else if let newRes = res as? String {
                    SwiftMessages.showMessagePopup(theme: .success, title: "Congratulations", body: newRes)
                    var value = self.selectedOptions.capitalizingFirstLetter()
                    if value == "Only_me" {
                        value = "Only Me".localized()
                    } else if value == "Friends_of_friends" {
                        value = "Friends of friends".localized()
                    } else if value == "Everyone" {
                        value = "Everyone".localized()
                    } else if value == "Contacts" {
                        value = "Contacts".localized()
                    } else if value == "Public" {
                        value = "Public".localized()
                    } else if value == "Family" {
                        value = "Family".localized()
                    } else if value == "Friends" {
                        value = "Friends".localized()
                    } else if value == "Colleague" {
                        value = "Colleague".localized()
                    } else if value == "Favourite" {
                        value = "Favourite".localized()
                    } else {
                        value = "Custom".localized()
                    }
                    switch self.valueSelected {
                    case 1:
                        self.lbl_FuturePost.text = value
                        SharedManager.shared.PrivacyObj.FuturePostValue = value
                    case 2:
                        self.lbl_SendFriendRequest.text = value
                        SharedManager.shared.PrivacyObj.FriendRequestValue = value
                    case 3:
                        self.lbl_FriendList.text = value
                        SharedManager.shared.PrivacyObj.FriendListValue = value
                    case 4:
                        self.lbl_EmailProvided.text = value
                        SharedManager.shared.PrivacyObj.EmailAddressValue = value
                    case 5:
                        self.lbl_PhoneNumber.text = value
                        SharedManager.shared.PrivacyObj.PhoneNumberValue = value
                    default:
                        break
                    }
                } else {
                    var value = self.selectedOptions.capitalizingFirstLetter()
                    if value == "Only_me" {
                        value = "Only Me".localized()
                    } else if value == "Friends_of_friends"{
                        value = "Friends of friends".localized()
                    } else {
                        value = "Custom".localized()
                    }
                    switch self.valueSelected {
                    case 1:
                        self.lbl_FuturePost.text = value
                        SharedManager.shared.PrivacyObj.FuturePostValue = value
                    case 2:
                        self.lbl_SendFriendRequest.text = value
                        SharedManager.shared.PrivacyObj.FriendRequestValue = value
                    case 3:
                        self.lbl_FriendList.text = value
                        SharedManager.shared.PrivacyObj.FriendListValue = value
                    case 4:
                        self.lbl_EmailProvided.text = value
                        SharedManager.shared.PrivacyObj.EmailAddressValue = value
                    case 5:
                        self.lbl_PhoneNumber.text = value
                        SharedManager.shared.PrivacyObj.PhoneNumberValue = value
                    default:
                        break
                    }
                }
            }
        }, param: parameters)
    }
}
