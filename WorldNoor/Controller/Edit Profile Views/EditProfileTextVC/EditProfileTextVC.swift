//
//  EditProfileTextVC.swift
//  WorldNoor
//
//  Created by apple on 1/10/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import UIKit

class EditProfileTextVC: UIViewController , UITextFieldDelegate {

    @IBOutlet var txtFieldFirstName : UITextField!
    @IBOutlet var txtFieldLastName : UITextField!
    @IBOutlet var lblHeading : UILabel!
    
    @IBOutlet var txtFieldDesignation : UITextField!
    
    var refreshParentView: (()->())?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
                   
        self.txtFieldFirstName.text = SharedManager.shared.userEditObj.firstname
        self.txtFieldLastName.text = SharedManager.shared.userEditObj.lastname
        self.txtFieldDesignation.text = SharedManager.shared.userEditObj.email
    }
    
    
    @IBAction func submitAction(sender : UIButton){
        self.view.endEditing(true)
        if self.txtFieldFirstName.text!.count == 0 {
            SharedManager.shared.showAlert(message: "First name is missing".localized(), view: self)
            return
        }else if self.txtFieldLastName.text!.count == 0 {
            SharedManager.shared.showAlert(message: "Last name is missing".localized(), view: self)
            return
        }
                
        let userToken = SharedManager.shared.userToken()
        let firstName = self.txtFieldFirstName.text!
        let lastName = self.txtFieldLastName.text!
        
                   
        let parameters = ["action": "profile/update","token": userToken , "firstname" : firstName  , "lastname" : lastName]

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
                    SwiftMessages.showMessagePopup(theme: .error, title: "Failed", body: res as? String ?? .emptyString)
                } else if res is [String : Any] {
                    
                    SharedManager.shared.userEditObj.firstname = self.txtFieldFirstName.text!
                    SharedManager.shared.userEditObj.lastname = self.txtFieldLastName.text!
                    SharedManager.shared.userEditObj.email = self.txtFieldDesignation.text!
                    
                    SharedManager.shared.userObj!.data.lastname! = self.txtFieldLastName.text!
                    SharedManager.shared.userObj!.data.firstname! = self.txtFieldFirstName.text!
                    self.refreshParentView?()
                    self.view.removeFromSuperview()
                }
            }
            
        }, param:parameters)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch = touches.first!
        if(touch.view!.tag == 100 ){
            self.view.removeFromSuperview()
        }
    }
}


extension UIViewController {
    
    func ShowAlertWithCompletaionText(message: String , noButtonText : String , yesButtonText : String , completion: ((_ status: Bool) -> Void)? = nil) {
        
        let alert = UIAlertController(title: "" , message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: noButtonText.localized(), style: .default) { action in
            alert.dismiss(animated: true, completion: nil)
            completion!(false)
        })
        alert.addAction(UIAlertAction(title: yesButtonText.localized(), style: .default) { action in
            alert.dismiss(animated: true, completion: nil)
            completion!(true)
        })
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func ShowAlertWithCompletaion(titleMsg: String = .emptyString, message: String, completion: ((_ status: Bool) -> Void)? = nil) {
           
           let alert = UIAlertController(title: titleMsg , message: message, preferredStyle: .alert)
           alert.addAction(UIAlertAction(title: "No".localized(), style: .default) { action in
               alert.dismiss(animated: true, completion: nil)
               completion!(false)
           })
           alert.addAction(UIAlertAction(title: "Yes".localized(), style: .default) { action in
               alert.dismiss(animated: true, completion: nil)
               completion!(true)
           })
           self.present(alert, animated: true, completion: nil)
       }
    
    
    func ShowAlertWithPop(message: String) {
              
              let alert = UIAlertController(title: "" , message: message, preferredStyle: .alert)
              alert.addAction(UIAlertAction(title: "Ok".localized(), style: .default) { action in
                  alert.dismiss(animated: true, completion: nil)
                self.navigationController?.popViewController(animated: true)
              })
              self.present(alert, animated: true, completion: nil)
          }
    
    
    func ShowAlert(title: String = "Error", message: String) {
              let alert = UIAlertController(title: title , message: message, preferredStyle: .alert)
              alert.addAction(UIAlertAction(title: "Ok".localized(), style: .default) { action in
                  alert.dismiss(animated: true, completion: nil)
//                self.navigationController?.popViewController(animated: true)
              })
              self.present(alert, animated: true, completion: nil)
          }
}
