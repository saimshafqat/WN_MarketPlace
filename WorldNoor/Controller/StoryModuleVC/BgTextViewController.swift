//
//  BgTextViewController.swift
//  kalam
//
//  Created by Raza najam on 11/15/21.
//  Copyright © 2021 apple. All rights reserved.
//

import UIKit
//import CommonKeyboard
//import IQKeyboardManagerSwift

class BgTextViewController: UIViewController {
    @IBOutlet weak var txtView: UITextView!
    var testButton: UIButton!
    var buttonConstraint: NSLayoutConstraint!
    // here is the new class
    var counter = 0
    var colorArray =  ["#179a63", "#9b9b9b", "#4BE84F", "#43ab9b", "#ff0000","#0000d8","#0eee91", "#98f9b4", "#FDD900", "#3b5998"]
    var keyboardHeightVar = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.txtView.tag = 20
        self.view.backgroundColor = UIColor.init().hexStringToUIColor(hex:self.colorArray[0])
        self.manageSendBtn()
//        IQKeyboardManager.shared.enable = false
//        IQKeyboardManager.shared.enableAutoToolbar = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        txtView.centerVertically()
        self.txtView.text = "Enter your text".localized()
    }
    
    func manageSendBtn(){
        testButton = UIButton(type: .custom)
        testButton.setTitle("", for: .normal)
        testButton.setImage(UIImage.init(named: "sendBtnImg"), for: .normal)
        testButton.backgroundColor = UIColor.clear
        self.view.addSubview(testButton)
        testButton.translatesAutoresizingMaskIntoConstraints = false
        testButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        //testButton.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 40).isActive = true
        testButton.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -10).isActive = true
        buttonConstraint = testButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        buttonConstraint.isActive = true
        testButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        testButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        self.view.layoutIfNeeded()
        subscribeToShowKeyboardNotifications()
    }
    
    @IBAction func changeBg(_ sender: Any) {
        counter = counter + 1
        if counter == colorArray.count {
            counter = 0
        }
        let colorHex = self.colorArray[counter]
        if  colorHex == "#9b9b9b" || colorHex == "#4BE84F" || colorHex == "#0eee91" || colorHex == "#98f9b4" || colorHex == "#FDD900" {
            txtView.textColor = UIColor.black
        }else {
            txtView.textColor = UIColor.white
        }
        self.view.backgroundColor = UIColor.init().hexStringToUIColor(hex:self.colorArray[counter])
    }
    /*
     func manageKeyboard(){
     keyboardObserver.subscribe(events: [.willChangeFrame,.dragDown]) { [weak self] (info) in
     guard let weakSelf = self else { return }
     var bottom = 0.0
     weakSelf.keyboardHeightVar = 0.0
     if info.isShowing {
     bottom = Double(-info.visibleHeight)
     weakSelf.keyboardHeightVar = bottom
     if #available(iOS 11, *) {
     let guide = weakSelf.view.safeAreaInsets
     bottom = bottom + Double(guide.bottom)
     weakSelf.keyboardHeightVar = bottom
     }
     CommonKeyboard.shared.enabled = false
     }
     //            UIView.animate(info, animations: { [weak self] in
     ////              self?.bgImageCollectionBottomConst.constant = CGFloat(-bottom+3)
     //                self?.view.layoutIfNeeded()
     //            })
     }
     }*/
    
    @objc func keyboardWillShow(_ notification: Notification) {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        let keyboardHeight = keyboardSize.cgRectValue.height
        let animationDuration = userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        UIView.animate(withDuration: animationDuration) { [self] in
            buttonConstraint.constant = 30 - keyboardHeight
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        let userInfo = notification.userInfo
        let animationDuration = userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        UIView.animate(withDuration: animationDuration) {
            self.buttonConstraint.constant = -10
            self.view.layoutIfNeeded()
        }
    }
    
    func subscribeToShowKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func buttonAction() {
        txtView.resignFirstResponder()
        if self.txtView.text.isEmpty || self.txtView.text == "Enter your text".localized() {
            return
        }
        self.sendTextualStoryOnServer()
        self.imageTextSaved()
    }
    func imageTextSaved()   {
        let img :UIImage =  self.view.takeScreenshot()
           let imageMain = img.compress(to: 100)
        SharedManager.shared.saveToDocuments(filename: "textImage.png", imageMain: imageMain)
    }
    func sendTextualStoryOnServer() {
        var colorIndex = 0
        if counter == 0 {
            colorIndex = 0
        }else {
            colorIndex = counter
        }
        
        let timeInterval = NSDate().timeIntervalSince1970
        var parameter = [String:Any]()
        let identifier = String(timeInterval) + SharedManager.shared.getIdentifierForMessage()
        parameter["action"] = "stories/create"
        parameter["post_type"] = "text"
        parameter["token"] = SharedManager.shared.userToken()
        let fileUrl: URL  = self.getURLForImage(filename: "textImage.png")
        parameter["file"] = fileUrl.path
        parameter["post_type_color_code"] = colorArray[colorIndex]
        parameter["body"] = self.txtView.text
        callingStoryService(parameters: parameter)
  //      uploadAudioFile(parameter: parameter)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: nil,
                                      message: message,
                                      preferredStyle: UIAlertController.Style.alert)
        
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: {_ in
            
            self.navigationController?.popToViewController(ofClass: FeedViewCollectionController.self)
        })
        
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: {})
    }
    
    func uploadStoryService(parameters:[String:Any], isFileExist:Bool = true)  {
        CreateRequestManager.uploadMultipartVideoClip( params: parameters as! [String : Any],success: {
            (JSONResponse) -> Void in
            let respDict = JSONResponse
            let meta = respDict["meta"] as! NSDictionary
            let code = meta["code"] as! Int
            
            let dataMain = respDict["data"] as? [[String : Any]] ?? []
            let mainDic = dataMain[0]
            if code == ResponseKey.successResp.rawValue {
                 let postTypeId = mainDic["post_type_id"] as? Int
                if postTypeId == 1 {
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
        },failure: {(error) -> Void in
        }, isShowProgress: false)
    }
    func callingStoryService(parameters: [String : Any]){
        Loader.startLoading()
        RequestManager.fetchDataPost(Completion: { response in
            Loader.stopLoading()
            switch response {
            case .failure(let error):
                SwiftMessages.apiServiceError(error: error)
            case .success(let res):
                if res is String {
                    SwiftMessages.showMessagePopup(theme: .error, title: "Alert", body: res as? String ?? .emptyString)
                } else if let resDict = res as? [[String : Any]] {
                    if resDict.count > 0 {
                        SharedManager.shared.createStory = FeedVideoModel.init(dict: resDict[0])
                        SharedManager.shared.isfromStory = true
                        SwiftMessages.showMessagePopup(theme: .success, title: "Congratulations".localized(), body: "Story created successfully".localized())
                        let feedModel = FeedVideoModel(dict: resDict.first ?? [:])
                        if FeedCallBManager.shared.videoClipArray.firstIndex(where: {$0.postID == feedModel.postID}) == nil {
                            FeedCallBManager.shared.videoClipArray.insert(FeedVideoModel.init(dict: resDict[0]), at: 0)
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadTableWithNewdata"), object: nil,userInfo: nil)
                            self.navigationController?.popToViewController(ofClass: FeedViewCollectionController.self)
                        } else {
                            // move to first position
                        }
                    } else {
                        SharedManager.shared.isfromStory = true
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                }
            }
        }, param:parameters)
    }

}

extension BgTextViewController:UITextViewDelegate   {
    func textViewDidChange(_ textView: UITextView) {
        let lines = txtView.numberOfLines(textView: txtView)
        if lines < 7 {
            txtView.centerVertically()
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if self.txtView.tag == 20 {
            self.txtView.text = nil
            self.txtView.textColor = UIColor.white
            self.txtView.tag = 21
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if self.txtView.text.isEmpty {
            self.txtView.text = "Enter your text".localized()
            self.txtView.textColor = UIColor.white
            self.txtView.tag = 20
        }
    }
}
