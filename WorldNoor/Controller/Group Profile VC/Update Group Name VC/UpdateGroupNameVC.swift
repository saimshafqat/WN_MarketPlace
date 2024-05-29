//
//  UpdateGroupNameVC.swift
//  WorldNoor
//
//  Created by apple on 9/17/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import UIKit

class UpdateGroupNameVC: UIViewController {
    
    @IBOutlet var txtFieldMain : UITextField!
    
    @IBOutlet var lblHeading : UILabel!
    @IBOutlet var lblTitle : UILabel!
    
    weak var delegate: DelegateReturnData?
    
    var textShow = ""
    var textinTF = ""
    var lblShow = ""
    var convsersationID = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.txtFieldMain.placeholder = textShow
        self.txtFieldMain.text = textinTF
        self.lblHeading.text = lblShow
        self.lblTitle.text = lblShow
        
        self.txtFieldMain.becomeFirstResponder()
    }
    
    
    @IBAction func submitName(sender : UIButton){
        
        if txtFieldMain.text?.count == 0 {
            SharedManager.shared.showAlert(message: "Group name is missing".localized(), view: self)
        }

//        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        let parameters = ["action": "update-group-chat-name/" + convsersationID  ,
                          "token": SharedManager.shared.userToken(),
                          "serviceType": "Node",
                          "conversation_id" : convsersationID,
                          "new_group_chat_name":self.txtFieldMain.text!] as! [String : Any]


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
                } else {
                    
                    let dictMain:NSDictionary = [ "new_group_name": self.txtFieldMain.text! , "conversation_id" : self.convsersationID]
                    
                    SocketSharedManager.sharedSocket.updateGroupConversation(dict: dictMain as NSDictionary) { (pData) in
                    }
                    
                    self.delegate?.delegateReturnFunction(dataMain: self.txtFieldMain.text!)
                    self.view.removeFromSuperview()

                }
            }
        }, param:parameters)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch = touches.first!
        if(touch.view!.tag == 100 ){
            self.view.removeFromSuperview()
        }
    }
    
}
