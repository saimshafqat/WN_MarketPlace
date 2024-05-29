//
//  ChatTableViewController.swift
//  RDT
//
//  Created by Shahriyar Ahmed on 12/9/21.
//

import UIKit
import Alamofire
//import IQKeyboardManagerSwift

class CommentTableViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var tableChat: UITableView!
    @IBOutlet weak var viewChat: UIView!
    @IBOutlet weak var txtChat: UITextField!
    @IBOutlet weak var viewChating: UIView!
    @IBOutlet weak var viewSending: UIView!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lbl_botttom_Const_ChatView: NSLayoutConstraint!
    @IBOutlet weak var viewNavigation: UIView!
    var delegateReaction : ReactionDelegateResponse!
//    private var firstPage = 1
//    private var lastPage = Int()
//    private var totalCount = Int()
    private var isMoreAvailable = false
//    private var isTrue = false
//    private var isLoadingTrue = true
//    private var strChatId = String()
    
    var feedObj : FeedData!
    private var paremsChat = NSMutableDictionary()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Comments".localized()
        viewChating.roundCorners()
        feedObj.comments?.removeAll()
        checkCommentsCount()

        viewSending.roundCorners()
        
        tableChat.delegate = self
        tableChat.dataSource = self
        
        txtChat.delegate = self
        txtChat.font = UIFont.preferredFont(withTextStyle: .body, maxSize: 23.0)
        txtChat.adjustsFontForContentSizeCategory = true
        
        let defualts = UserDefaults.standard
        defualts.synchronize()
        
        var parameter = [String:Any]()
        parameter["action"] = "getComments"
        parameter["post_id"] = feedObj.postID
//        parameter["starting_point_id"] = feedObj.comments?.first?.commentID
        self.callingExtraCommentsApi(parameters: parameter, sender: nil)

//        strChatId = "95306648-a7ce-499b-8be7-46749d5257ee"
      
    }
    
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        txtChat.resignFirstResponder()
//        return true
//    }
    
    @objc private func receiveMessage(notification: Notification){
        let dict = notification.object as! NSDictionary
        let strType = String(format: "%@", dict.value(forKey: "body") as! CVarArg)
        
        let now = Date()
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let dateString = formatter.string(from: now)
        
//        let dictChat = NSMutableDictionary()
////        let userId = String(format: "%@", UserDefaults.standard.value(forKey: API_ID) as! CVarArg)
//        dictChat.setValue(strType, forKey: "message")
//        dictChat.setValue(dateString, forKey: "created_at")
//        dictChat.setValue("admin", forKey: "sender_id")
//
//        self.arrChat.insert(dictChat, at: 0)
        self.scrollToBottom()
    }
    
    @IBAction func btnActionBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnActionSend(_ sender: Any) {
        var strChat = txtChat.text!
        strChat = strChat.trimmingCharacters(in: .whitespacesAndNewlines)
        if(strChat.count != 0){
            var parameter = [String:Any]()
            parameter["action"] = "comment"
            parameter["post_id"] = feedObj.postID
            parameter["body"] = strChat
            self.callingExtraCommentsApi(parameters: parameter, sender: sender)
        }
    }
    
    func callingExtraCommentsApi(parameters: [String : Any], sender: Any?){
        if parameters["action"] as! String == "comment" {
            (sender as? LoaderButton)?.startLoading(color: UIColor().hexStringToUIColor(hex: "#127FA5"))
            (sender as? LoaderButton)?.setImage(nil, for: .normal)
        }
        RequestManager.fetchDataPost(Completion: { response in
            (sender as? LoaderButton)?.stopLoading()
            (sender as? LoaderButton)?.setImage(.sendBtnImg, for: .normal)
            switch response {
            case .failure(let error):
                if error is String {

                }
            case .success(let res):
                if res is String {
                }else {
                    
                    if res is [String : Any]
                    {
                        let comment = Comment.init(dict: res as! NSDictionary)
                        self.feedObj.comments?.removeAll(where: { comm in
                            comm.commentID == comment.commentID
                        })
                        self.feedObj.comments?.append(comment)
                        self.isMoreAvailable = true
                    }
                    else{
                        let respDict = res as! [[String : Any]]
                        for item in respDict {
                            let comment = Comment.init(dict: item as NSDictionary)
                            self.feedObj.comments?.removeAll(where: { comm in
                                comm.commentID == comment.commentID
                            })
                            self.feedObj.comments?.append(comment)
                        }
                        if respDict.count > 0 {
                            self.isMoreAvailable = true
                        }
                    }
                    self.txtChat.text = ""
                    SharedManager.shared.isfromStory = true
                    self.feedObj.commentCount = self.feedObj.comments?.count
//                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "CommentReceive"), object: self.feedObj,userInfo: nil)
                    self.delegateReaction.reactionResponse(feedObj: self.feedObj)
                    self.txtChat.endEditing(true)
                    self.checkCommentsCount()
                    self.tableChat.reloadData()
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
        }, param:parameters)
    }
    func checkCommentsCount(){
        if(self.feedObj.comments?.count == 0){
            tableChat.setEmptyMessage("No comment yet".localized())
        }else{
            tableChat.restore()
        }
    }
    
    func callingServiceFor_Delete_Or_Edit(type:String,parameters:[String:Any],index:Int){
        RequestManager.fetchDataPost(Completion: { response in
            switch response {
            case .failure(let error):
                SwiftMessages.apiServiceError(error: error)
            case .success(let res):
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                } else if res is String {
                    if type == "delete"{
                        self.feedObj.comments?.remove(at: index)
                        self.feedObj.commentCount = self.feedObj.comments?.count
                        self.delegateReaction.reactionResponse(feedObj: self.feedObj)
                        self.checkCommentsCount()
                        self.tableChat.reloadData()
                    }
                }else if res is [String : Any]{
                     if type == "edit"{
                        let cell = self.tableChat.cellForRow(at: IndexPath(row: index, section: 0)) as! CommentTableViewCell
                        cell.editablebgV.isHidden = true
                        self.feedObj.comments?[index].body = cell.editTextView.text!
                        cell.layoutIfNeeded()
                         self.tableChat.reloadData()
                    }
                }

            }
        }, param:parameters)
    }
}

extension CommentTableViewController: UITableViewDelegate, UITableViewDataSource,ReelsCommentDelegate{
    func didPressEditBtn(_ sender: UIButton) {
        let cell = tableChat.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as! CommentTableViewCell
        cell.editablebgV.isHidden = false
        cell.editTextView.becomeFirstResponder()
    }
    
    func didPressDeleteBtn(_ sender: UIButton) {
        presentAlert(title: "Delete Comment".localized(), message: "Are you sure you want to permanentaly remove this comment from \(Const.AppName)?".localized(), options: "Cancel".localized(), "Delete".localized()) { index, field in
            if index == 1 {
                let parameters = ["action": "comment", "token": SharedManager.shared.userToken(), "comment_id":String(self.feedObj.comments?[sender.tag].commentID ?? 0), "_method":"DELETE"]
                self.callingServiceFor_Delete_Or_Edit(type:"delete",parameters:parameters,index: sender.tag)
            }
        }
    }
    
    func didPressCancelBtn(_ sender: UIButton) {
        let cell = tableChat.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as! CommentTableViewCell
        cell.editablebgV.isHidden = true
    }
    
    func didPressUpdateBtn(_ sender: UIButton) {
        let cell = tableChat.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as! CommentTableViewCell
        cell.editablebgV.isHidden = true
        if !cell.editTextView.text.isEmpty{
            let parameters = ["action": "comment","token": SharedManager.shared.userToken(), "body": cell.editTextView.text!, "post_id":String(self.feedObj!.postID!), "identifier":"", "comment_id":String(feedObj.comments?[sender.tag].commentID ?? 0)]
            callingServiceFor_Delete_Or_Edit(type:"edit",parameters:parameters,index: sender.tag)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedObj.comments!.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if feedObj.comments!.count > 0 {
            if indexPath.row == self.feedObj.comments!.count - 1 {
                if self.isMoreAvailable {
                    var parameter = [String:Any]()
                    parameter["action"] = "getComments"
                    parameter["post_id"] = feedObj.postID
                    parameter["starting_point_id"] = feedObj.comments?.last?.commentID
                    self.callingExtraCommentsApi(parameters: parameter, sender: nil)
                    self.isMoreAvailable = false
                }
                
            }
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = CommentTableViewCell()
        
        let comment = feedObj.comments![indexPath.row]
        


        cell = tableView.dequeueReusableCell(withIdentifier: "ReceiveCell") as! CommentTableViewCell
        cell.delegate = self
        cell.editBtn.tag = indexPath.row
        cell.deleteBtn.tag = indexPath.row
        cell.cancelEditBtn.tag = indexPath.row
        cell.updateCommentBtn.tag = indexPath.row


        
        cell.comment = comment
        cell.layoutIfNeeded()
        return cell
    
    }
    
    @objc private func keyboardWillShow(_ notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            var bottomConstraintValue = keyboardHeight
            
            let userDefualts = UserDefaults.standard
            userDefualts.synchronize()
            let value = String(format: "%@", userDefualts.value(forKey: "Keyboard") as! CVarArg)
            let messageLoad = String(format: "%@", userDefualts.value(forKey: "messageLoad") as! CVarArg)
            
            let height = UIScreen.main.bounds.size.height
            let height1 = 0.02790178571 * height           //25pixcel
            let height2 = 0.02232142857 * height           //20pixcel
            let height3 = 0.08136094675 * height           //50pixcel
            let height4 = 0.1499250375 * height
            
            if(value == "true"){
                bottomConstraintValue = keyboardHeight - viewChat.frame.size.height
                self.perform(#selector(adddelayInChangeValue), with: nil, afterDelay: 1)
            }else{
                
                bottomConstraintValue = keyboardHeight + viewChat.frame.size.height
            }
            
            
            if(height <= 840){

                if(value == "true"){
                    bottomConstraintValue = keyboardHeight - viewChat.frame.size.height - height3
                    if(messageLoad == "true"){
                        self.perform(#selector(adddelayInChangeValue), with: nil, afterDelay: 1)
                    }else{
                        userDefualts.setValue("false", forKey: "Keyboard")
                    }
                }
                else{
                    bottomConstraintValue = keyboardHeight + viewChat.frame.size.height - height3
                }
            }
            else{

                if(value == "true"){
                    bottomConstraintValue = keyboardHeight - viewChat.frame.size.height - height2
                    if(messageLoad == "true"){
                        self.perform(#selector(adddelayInChangeValue), with: nil, afterDelay: 1)
                    }else{
                        userDefualts.setValue("false", forKey: "Keyboard")
                    }
                }else{
                    bottomConstraintValue = keyboardHeight + viewChat.frame.size.height - height1
                }
            }
            
            let ScreenHeight = UIScreen.main.bounds.height
            
            var navigatiohHeader = 0
            if let header = self.navigationController?.navigationBar {
                navigatiohHeader = Int(CGFloat((self.navigationController?.navigationBar.frame.size.height)!))
            }
            
            let tableHeight = ScreenHeight - (bottomConstraintValue + CGFloat(navigatiohHeader))
            self.moveViewTextingBox(yAxis: bottomConstraintValue, tableHeight: tableHeight)
        }
    }
    
    @objc private func keyboardWillHide(_ notification: NSNotification) {
        self.moveViewTextingBox(yAxis: 0, tableHeight: CGFloat())
        self.perform(#selector(scrollToBottom), with: nil, afterDelay: 0.05)
    }
    
    @objc private func breakChatBoxConstraints() {
        self.tableChat.translatesAutoresizingMaskIntoConstraints = false
        self.tableChat.autoresizesSubviews = false
    }
    
    @objc private func moveViewTextingBox(yAxis: CGFloat, tableHeight: CGFloat) {
        

        
        UIView.transition(with: self.viewChat, duration: 0.3, options: .beginFromCurrentState, animations: {
            self.lbl_botttom_Const_ChatView.constant = yAxis
            
            self.tableChat.frame = CGRect.init(x: self.tableChat.frame.origin.x, y: self.tableChat.frame.origin.y, width: self.tableChat.frame.size.width, height: tableHeight)
            
            self.scrollToBottom()
            
        }, completion: nil)
        
    }
    
    @objc private func adddelayInChangeValue(){
        let userDefualts = UserDefaults.standard
        userDefualts.synchronize()
        userDefualts.setValue("false", forKey: "Keyboard")
        userDefualts.setValue("false", forKey: "messageLoad")
    }
    
    @objc private func scrollToBottom() {
        
        self.tableChat.reloadData()
        if(feedObj.comments!.count != 0){
            DispatchQueue.main.async {
                let index = IndexPath(row: self.feedObj.comments!.count-1, section: 0)
                self.tableChat.scrollToRow(at: index, at: .bottom, animated: false)
            }
        }
    }
}

