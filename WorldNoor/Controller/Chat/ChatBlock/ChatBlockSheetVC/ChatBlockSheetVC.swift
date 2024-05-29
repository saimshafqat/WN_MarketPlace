//
//  ChatBlockSheetVC.swift
//  WorldNoor
//
//  Created by ogouluser1-mac6 on 13/09/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit

protocol ContactBlockedSheetDelegate:AnyObject {
    func contactBlockedSheetDelegate()
}

class ChatBlockSheetVC: UIViewController {
    
    var contactDict:[String:AnyObject]?
    weak var delegate:ContactBlockedSheetDelegate?
    
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var imgView: UIImageView!{
        didSet {
            imgView.roundWithClearColor()
        }
    }
    @IBOutlet weak var blockBtn: UIButton!{
        didSet {
            blockBtn.roundButton(cornerRadius: 5.0)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.manageUI()
    }
    
    @IBAction func blockBtnClicked(sender : UIButton) {
        
        if let val = contactDict?["id"] {
            let userID = SharedManager.shared.ReturnValueAsString(value: val)
            self.blockUser(userID: userID)
        }
    }
    
    func manageUI() {
        if let dict = contactDict {
            if let firstName = dict["firstname"] as? String {
                self.nameLbl.text = firstName+" "+(dict["lastname"] as! String)
            }
            
            self.imgView.image = UIImage(named: "placeholder.png")
            if let profileImg = dict["profile_image"] as? String {
                self.imgView.loadImageWithPH(urlMain:profileImg)
            }
        }
    }
    
    func blockUser(userID:String) {
        
        let parameters = ["action": "user/block_user", "token": SharedManager.shared.userToken(), "user_id":userID]
//        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        RequestManager.fetchDataPost(Completion: { response in
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            switch response {
                
            case .failure(let error):
                SwiftMessages.apiServiceError(error: error)
            case .success(let res):
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                } else if res is String {
                    SwiftMessages.showMessagePopup(theme: .error, title: "Alert", body: res as? String ?? .emptyString)
                } else {
                    let someDict = res as! NSDictionary
                    self.showToast(with: "User blocked successfully".localized())
                }
                self.delegate?.contactBlockedSheetDelegate()
            }
        }, param:parameters)
    }
}
