//
//  RelationshipBaseVC.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 20/12/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit
import Combine

class RelationshipBaseVC: UIViewController {
    
    // MARK: - Property -
    var apiService = APITarget()
    var type = -1
    var rowIndex = -1
    var subscription: Set<AnyCancellable> = []
    var userFriendList: [FriendModel] = []
    var refreshParentView: (()->())?
    var relationshipArray: [RelationshipStatus] = []
    var selectedPatnerList = [FriendModel]()
    var relationshipStatus: RelationshipStatus?
    var relationEditStatus: RelationshipModel?
    var otherUserObj = UserProfile.init()
    var parentView: ProfileViewController?
    var otherUserID: String = ""
    var isPartnerChange: Bool = false
    var isDateChange: Bool = false
    var isRelationChange: Bool = false
    
    // MARK: - IBOutlets -
    @IBOutlet weak var lblHeading: UILabel! {
        didSet {
            lblHeading.text = screenTitle()
        }
    }
    
    @IBOutlet weak var viewDelete: UIView!
    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var btnPartner: UIButton!
    @IBOutlet weak var btnCross: UIButton!
    @IBOutlet weak var partnerFieldHeightConstraint: NSLayoutConstraint! // 80
    @IBOutlet weak var submitBtnTopConstraint: NSLayoutConstraint! // 50
    @IBOutlet weak var partnerTextField: UITextField!
    @IBOutlet weak var privacyDropDown: PrivacyDropDownField! {
        didSet {
            privacyDropDown.isUserInteractionEnabled = true
            privacyDropDown.dataSource = DDDataConfig.dataList
            privacyDropDown.selectionHandler = { index, item in
                let itemStr = item as? String
                self.privacyDropDown?.text = itemStr?.localized()
            }
        }
    }
    
    @IBOutlet weak var videoDropDown: RelationshipDropdownTextField? {
        didSet {
            videoDropDown?.dataSource = relationshipArray
            videoDropDown?.selectionHandler = { index, item in
                let itemData = (item as? RelationshipStatus)
                self.relationshipStatus = itemData
                self.videoDropDown?.text = itemData?.status.localized()
                self.isRelationChange = true
                self.performRelationChangeDD()
            }
        }
    }
    
    // MARK: - Life Cycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        apiService.errorMessagePublisher
            .receive(on: DispatchQueue.main)
            .sink { message in
                SwiftMessages.showMessagePopup(theme: .error, title: "Failed", body: message)
            }.store(in: &subscription)
    }
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewDelete.isHidden = true
        if self.type == 2 {
            relationEditStatus = editRelationshipObj()
            videoDropDown?.text = relationEditStatus?.statusDescription
            privacyDropDown.text = relationEditStatus?.privacy_status
            let index = videoDropDown?.dataSource.firstIndex(where: {String(($0 as? RelationshipStatus)?.id ?? 0) == relationEditStatus?.statusId}) ?? 0
            let indexPrivacy = privacyDropDown.dataSource.firstIndex(where: {$0 as? String == relationEditStatus?.privacy_status}) ?? 0
            videoDropDown?.dropDown.selectRow(index)
            videoDropDown?.dropDown.selectRow(indexPrivacy)
            let fullName = (relationEditStatus?.user?.firstname ?? .emptyString) + " " + (relationEditStatus?.user?.lastname ?? .emptyString)
            partnerTextField.text = fullName
        }
        performOnAppear(with: self.type)
    }
    
    func performOnAppear(with type: Int) {
        // override me
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getUserFriendList()
        if self.type == 2 {
            viewDelete.isHidden = false
        }
    }
    
    func editRelationshipObj() -> RelationshipModel? {
        return nil
    }
    
    // MARK: - Override -
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.dismiss(animated: true)
    }
    
    // MARK: - IBActions -
    @IBAction func onClickPartner(_ sender: UIButton) {
        LogClass.debugLog("Go to partner screen")
        if self.userFriendList.count > 0 {
            self.showRelationPicker(Type: 2)
            return
        } else {
            Loader.startLoading()
//        }else {
//            SharedManager.shared.showOnWindow()
//            Loader.startLoading()
        }
    }
    
    @IBAction func onClickDelete(_ sender: UIButton) {
        deleteRelationshipRequest()
    }
    
    @IBAction func onClickCross(_ sender: UIButton) {
        if partnerTextField.text != .emptyString {
            partnerTextField.text = .emptyString
        }
    }
    
    @IBAction func onClickSubmit(_ sender: UIButton) {
        callRequestOnSubmit()
    }
    
    // MARK: - Method -
    public func performRelationChangeDD() {
        // override me to perform
    }
    
    func screenTitle() -> String {
        return .emptyString
    }
    
    func reloadView(type : Int , rowIndexP : Int ) {
        self.type = type
        self.rowIndex = rowIndexP
    }
    
    func showRelationPicker(Type : Int) {
        let controller = Pickerview.instantiate(fromAppStoryboard: .EditProfile)
        controller.isMultipleItem = false
        controller.isFromRelationship = true
        controller.type = Type
        controller.relationshipCompletion = { value, type in
            self.selectedPatnerList.removeAll()
            LogClass.debugLog("Value ==> \(value) and type ==> \(type)")
            let textarray = value.components(separatedBy: ",")
            for indexObj in textarray {
                for indexInner in self.userFriendList {
                    let name = (indexInner.firstname ?? .emptyString) + " " + ((indexInner.lastname ?? .emptyString))
                    if indexObj == name {
                        self.selectedPatnerList.append(indexInner)
                        self.partnerTextField.text = name
                        self.isPartnerChange = true
                    }
                }
            }
        }
        controller.type = Type
        var arrayData = [String]()
        for indexObj in self.userFriendList {
            arrayData.append((indexObj.firstname ?? .emptyString) + " " + (indexObj.lastname ?? .emptyString))
        }
        var selectedRealtion = [String]()
        if type == 2 {
            let firstName = relationEditStatus?.user?.firstname ?? .emptyString
            let lastName = relationEditStatus?.user?.lastname ?? .emptyString
            let fullName = firstName + " " + lastName
            selectedRealtion.append(fullName)
        } else {
        }
        var arr: [String] = userFriendList.map({$0.username ?? .emptyString})
        arr.removeAll()
        userFriendList.forEach { freind in
            arr.append((freind.firstname ?? .emptyString) + " " + (freind.lastname ?? .emptyString))
        }
        controller.arrayMain = arr
        controller.selectedItems = selectedRealtion
        present(controller, animated: true)
    }
    
    func deleteRelationshipRequest() {
        ShowAlertWithCompletaion(titleMsg: "Delete Relationship".localized(), message: "Are you sure you want to delete relationship?".localized()) { success in
            if success {
                self.performRelationshipDeleteRequest()
            }
        }
    }
    
    func performRelationshipDeleteRequest() {
        // override me
    }
    
    func submitBtnValidation() -> String {
        // override me
        return .emptyString
    }
    
    func submitRequestParams() -> [String: String] {
        return [:]
    }
    
    func submitResponseSuccess(index: [String : Any]) {
        // override me
    }
    // MARK: - API Services -
    func getUserFriendList() {
        let params: [String : String] = [:]
        apiService.getUserFriendsRequest(endPoint: .getUserFriend(params))
            .sink(receiveCompletion: { completion in
                Loader.stopLoading()
                switch completion {
                case .finished:
                    LogClass.debugLog("Finished")
                case .failure(let error):
                    LogClass.debugLog("Unable to get friendlist.\(error.localizedDescription)")
                }
            }, receiveValue: { response in
                LogClass.debugLog("Friend list response ==> \(response)")
                self.userFriendList.removeAll()
                for index in response.data {
                    self.userFriendList.append(index)
                }
            })
            .store(in: &subscription)
    }
    
    func callRequestOnSubmit() {
        // check validation
        let validationString = submitBtnValidation().localized()
        if validationString != .emptyString {
            SwiftMessages.showMessagePopup(theme: .success, title: "Alert", body: validationString)
            return
        }
        // params request
        var params = submitRequestParams()
        params.updateValue(privacyDropDown.text ?? "Public".localized(), forKey: "privacy_status")
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
                } else if res is String {
                    SwiftMessages.showMessagePopup(theme: .error, title: "Failed", body: res as? String ?? .emptyString)
                } else if res is [[String : Any]] {
                    for index in res as? [[String: Any]] ?? [] {
                        self.submitResponseSuccess(index: index)
                    }
                    self.dismiss(animated: true) {
                        self.refreshParentView?()
                    }
                }
            }
        }, param:params)
    }
}
