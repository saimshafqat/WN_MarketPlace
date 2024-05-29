//
//  InviteFriendsVC.swift
//  WorldNoor
//
//  Created by apple on 12/14/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import Foundation
import UIKit
import FBSDKShareKit
import GoogleSignIn
import Alamofire


class InviteFriendsVC : UIViewController {
    
    @IBOutlet weak var inviteTableView: UITableView!
    
    var arrayEmail = [ShareTypeCell]()
    var arraySocial = [ShareTypeCell]()
    var arraySMS = [ShareTypeCell]()
    
    var selectedGmail = [[String : String]]()
    private var accessToken: String?
    
    override func viewDidLoad() {
        self.title = "Invite Friends".localized()
        
        self.arrayEmail.removeAll()
        self.arraySMS.removeAll()
        self.arraySocial.removeAll()
        
        //        self.textShare = self.textShare + SharedManager.shared.userObj!.data.username!
        let gmailObj = ShareTypeCell.init(imageName: "G-mailIcon", textMain: "Gmail", type:ShareType.init().GMail)
        self.arrayEmail.append(gmailObj)
        
        let fbObj = ShareTypeCell.init(imageName: "FacebookIcon", textMain: "Facebook", type:ShareType.init().FB)
        let twitterObj = ShareTypeCell.init(imageName: "TwitterIcon", textMain: "Twitter", type:ShareType.init().Twitter)
        _ = ShareTypeCell.init(imageName: "Instagram", textMain: "Instagram", type:ShareType.init().Instagram)
        
        self.arraySocial.append(fbObj)
        self.arraySocial.append(twitterObj)
        
        let smsObj = ShareTypeCell.init(imageName: "SMSIcon", textMain: "SMS", type:ShareType.init().SMS)
        let whatsappObj = ShareTypeCell.init(imageName: "WhatsappIcon", textMain: "Whatsapp", type:ShareType.init().WhatsApp)
        let fbsmsObj = ShareTypeCell.init(imageName: "FB-MessengerIcon", textMain: "FB messenger", type:ShareType.init().FBSMS)
        
        self.arraySMS.append(smsObj)
        self.arraySMS.append(whatsappObj)
        self.arraySMS.append(fbsmsObj)
    }
}

extension InviteFriendsVC:UITableViewDelegate, UITableViewDataSource , shareDelegate {
    
    func fbPost() {
        let content = ShareLinkContent()
        let url = URL(string: InvitationPlatform.textShare)
        content.contentURL = url!
        let dialog = ShareDialog(fromViewController: self, content: content, delegate: self as? SharingDelegate)
        dialog.show()
    }
    
    func gmailPost() {
        GoogleSignInManager.signIn(controller: self) { result in
            self.fetchOtherContacts(token: result?.user.accessToken.tokenString ?? .emptyString)
        } errorCompletion: { error in
            var errorString = error.localizedDescription
            if error.localizedDescription == "access_denied" {
                errorString = error.localizedDescription.replacingOccurrences(of: "_", with: " ").capitalized
            }
            self.ShowAlert(message: errorString)
        }
    }
    
    func shareDelegateAction(type: String) {
        switch type {
        case ShareType.init().WhatsApp:
            InvitationPlatform.openApp(of: .whatsapp)
        case ShareType.init().SMS:
            InvitationPlatform.openApp(of: .sms)
        case ShareType.init().FBSMS:
            InvitationPlatform.openApp(of: .messanger)
        case ShareType.init().FB:
            fbPost()
        case ShareType.init().Twitter:
            InvitationPlatform.openApp(of: .twitter)
        case ShareType.init().GMail:
            gmailPost()
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "InviteSectionCell", for: indexPath) as? InviteSectionCell {
            
            var arrayImage = [ShareTypeCell]()
            cell.delegateType = self
            if indexPath.row == 0 {
                cell.lblHeading.text = "Invite by Email"
                cell.imgViewBG.image = UIImage.init(named: "EmailBg.png")
                
                for indexObj in self.arrayEmail {
                    arrayImage.append(indexObj)
                }
                
            } else if indexPath.row == 1 {
                cell.lblHeading.text = "Invite by Social Media"
                cell.imgViewBG.image = UIImage.init(named: "MessegesBg.png")
                
                for indexObj in self.arraySocial {
                    arrayImage.append(indexObj)
                }
            } else if indexPath.row == 2 {
                cell.lblHeading.text = "Invite by Message"
                cell.imgViewBG.image = UIImage.init(named: "SocialBg.png")
                
                for indexObj in self.arraySMS {
                    arrayImage.append(indexObj)
                }
            }
            
            cell.manageCategoryData(catArray: arrayImage, currentSection: indexPath)
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension InviteFriendsVC {
    
    func fetchOtherContacts(token: String) {
//        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        self.selectedGmail.removeAll()
        let urlString = "https://people.googleapis.com/v1/otherContacts"
        let params: [String : Any] = ["readMask": "emailAddresses,names"]
        let headers: [String: String] = ["Authorization" : "Bearer \(token)"]
        LogClass.debugLog("Header ==> \(headers)")
        Alamofire.request(urlString, method: .get, parameters: params, headers: headers).responseJSON { responseData in
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            switch responseData.result {
            case .success(_):
                var connectionData: [String: String] = [:]
                let welcome : Welcome = try! JSONDecoder().decode(Welcome.self, from: responseData.data!)
                let otherContacts = welcome.otherContacts ?? []
                for otherContact in otherContacts {
                    let emailAddresses = otherContact.emailAddresses ?? []
                    let names = otherContact.names ?? []
                    for emailAddress in emailAddresses {
                        connectionData["email"] = emailAddress.value ?? .emptyString
                    }
                    for name in names {
                        connectionData["name"] = name.displayName ?? .emptyString
                    }
                    if !connectionData.isEmpty {
                        self.selectedGmail.append(connectionData)
                    }
                }
                if !(self.selectedGmail.isEmpty) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.shwoPickerforMail()
                    }
                } else {
                    self.ShowAlert(message: "Contacts are not found.")
                }
            case .failure(let err):
                self.ShowAlert(message: err.localizedDescription)
            }
        }
    }
    
    
    func shwoPickerforMail(){
        let cuntryPicker = self.GetView(nameVC: "Pickerview", nameSB: "EditProfile") as? Pickerview
        cuntryPicker!.isMultipleItem = true
        cuntryPicker!.pickerDelegate = self
        var arrayData = [String]()
        for indexObj in self.selectedGmail {
            if let stringEmail = indexObj["email"] {
                if self.EmailValidationOnstring(strEmail: stringEmail) {
                    arrayData.append(stringEmail)
                }
            }
        }
        cuntryPicker!.arrayMain = arrayData
        self.present(cuntryPicker!, animated: true)
    }
}

extension InviteFriendsVC : PickerviewDelegate {
    func pickerChooseMultiView(text: [String] , type : Int) {
        LogClass.debugLog(text)
        var parameters = [String : Any]()
        parameters["action"] = "referral-email/send"
        parameters["emails"] = text.map({["email": $0]})
        RequestManager.fetchDataPost(Completion: { response in
            switch response {
            case .failure(let err):
                DispatchQueue.main.async {
                    self.ShowAlert(message: err.localizedDescription)
                }
            case .success(_):
                DispatchQueue.main.async {
                    self.ShowAlert(title: "Succeed", message: "Email sent successfully".localized())
                }
            }
        }, param:parameters)
    }
    
    func pickerChooseView(text: String , type : Int) {
        // 
    }
}

struct ShareTypeCell {
    var imageShare : String?
    var textShare : String?
    var typeShare : String?
    
    init(imageName : String , textMain : String , type : String) {
        imageShare = imageName
        textShare = textMain
        typeShare = type
    }
}
