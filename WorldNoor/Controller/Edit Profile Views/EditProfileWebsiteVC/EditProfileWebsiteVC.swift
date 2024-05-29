//
//  EditProfileWebsiteVC.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 12/12/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit
import Combine

class EditProfileWebsiteVC: UIViewController {
    
    // MARK: - Properties -
    var parentView: ProfileViewController?
    var websiteURL: String?
    var type = -1
    var rowIndex = -1
    var websiteEditModel: WebsiteModel?
    var apiService = APITarget()
    var subscription: Set<AnyCancellable> = []
    var refreshParentView: (()->())?
    
    // MARK: - IBOutlets -
    @IBOutlet weak var lblWebsite: UILabel!
    @IBOutlet weak var lblAddWebsite: UILabel!
    @IBOutlet weak var tfWebsite: URLTextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var viewDelete: UIView!
    
    // MARK: - Life Cycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        lblWebsite.text = "Website".localized()
        apiService.errorMessagePublisher
            .receive(on: DispatchQueue.main)
            .sink { message in
                SwiftMessages.showMessagePopup(theme: .error, title: "Failed", body: message)
            }.store(in: &subscription)
    }
    
    // MARK: - Override -
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewDelete.isHidden = true
        if self.type == 2 {
            lblAddWebsite.text = "Edit a website".localized()
            websiteEditModel = SharedManager.shared.userEditObj.websiteArray[rowIndex]
            tfWebsite.text = websiteEditModel?.link
        } else {
            lblAddWebsite.text = "Add a website".localized()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.type == 2 {
            viewDelete.isHidden = false
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.dismiss(animated: true)
    }
    
    // MARK: - IBActions -
    @IBAction func onClickSubmit(_ sender: UIButton) {
        
        if tfWebsite.text!.count > 0 {
            if tfWebsite.isValidURL(tfWebsite.text!.localized()) {
                callRequestOnSubmit()
            } else {
                SwiftMessages.showMessagePopup(theme: .success, title: "Alert", body: "URL is not correctly formatted.".localized())
            }
        }else {
            SwiftMessages.showMessagePopup(theme: .success, title: "Alert", body: "Provide required URL.".localized())
        }
    }
    
    @IBAction func onClickDelete(_ sender: UIButton) {
        deleteWesbiteRequest()
    }
    
    // MARK: - Method -
    func reloadView(type : Int , rowIndexP : Int ) {
        self.type = type
        self.rowIndex = rowIndexP
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func callRequestOnSubmit() {
        var params: [String: String] = [:]
        if type == 2 {
            params.updateValue("profile/website/edit", forKey: "action")
            params.updateValue(websiteEditModel?.id ?? .emptyString, forKey: "website_id")
            params.updateValue(tfWebsite.text ?? .emptyString, forKey: "link")
        } else {
            params.updateValue("profile/website/save", forKey: "action")
            params.updateValue(tfWebsite.text ?? .emptyString, forKey: "link")
        }
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
                        if self.type == 2 {
                            SharedManager.shared.userEditObj.websiteArray[self.rowIndex] = WebsiteModel(fromDictionary: index)
                        } else {
                            SharedManager.shared.userEditObj.websiteArray.append(WebsiteModel(fromDictionary: index))
                        }
                    }
                    self.dismiss(animated: true) {
                        self.refreshParentView?()
                    }
                }
            }
        }, param:params)
    }
    
    func deleteWesbiteRequest() {
        ShowAlertWithCompletaion(titleMsg: "Delete Website".localized(), message: "Are you sure you want to delete website?".localized()) { success in
            if success {
                self.performWebsiteDeleteRequest()
            }
        }
    }
    
    func performWebsiteDeleteRequest() {
        let params: [String: String] = [
            "website_id": self.websiteEditModel?.id ?? .emptyString,
        ]
        self.apiService.deleteWebsiteRequest(endPoint: .profileWebsiteDelete(params))
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    LogClass.debugLog("Deleted Website")
                case .failure(_):
                    LogClass.debugLog("Failed Delete Website.")
                }
            }, receiveValue: { response in
                LogClass.debugLog("Delete website response ==> \(response)")
                SwiftMessages.showMessagePopup(theme: .success, title: "Congratulations", body: response.meta.message ?? .emptyString)
                SharedManager.shared.userEditObj.websiteArray.remove(at: self.rowIndex)
                self.dismiss(animated: true) {
                    self.refreshParentView?()
                }
            })
            .store(in: &self.subscription)
    }
}
