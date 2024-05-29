//
//  SharePostController.swift
//  WorldNoor
//
//  Created by Raza najam on 5/14/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import UIKit
import SDWebImage

class SharePostController: UIViewController {
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var sharingTitleLbl: UILabel!
    @IBOutlet weak var txtView: UITextView!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var shareTableView: UITableView!
    
    var selectedCatID = ""
    var selectedIndex = 0
    var optionArray:[String] = []
    var postID:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.manageUI()
        self.txtView.text = "Write what you wish.".localized()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    @IBAction func shareBtnClicked(_ sender: Any) {
        
        var bodyString = self.txtView.text
        if self.txtView.text == Const.textCreatePlaceholder   {
            bodyString = ""
        }
        var param = ["action": "post/share_post",
                     "token": SharedManager.shared.userToken(),
                     "user_id": String(SharedManager.shared.getUserID()),
                     "shared_post_id": self.postID,
                     "privacy_option": "public",
                     "body": bodyString]
        
        if self.selectedIndex == 1 {
            param["contact_id"] = self.selectedCatID
        } else if self.selectedIndex == 2 {
            param["group_id"] = self.selectedCatID
        } else if self.selectedIndex == 3 {
            param["page_id"] = self.selectedCatID
        }
        
        self.callingShareService(action: "sharing", param: param as! [String : String])
        
        var dicMeta = [String : Any]()
        dicMeta["post_id"] = postID
        
        var dic = [String : Any]()
        dic["group_id"] = postID
        dic["meta"] = dicMeta
        dic["type"] = "new_post_share_NOTIFICATION"
        SocketSharedManager.sharedSocket.likeEvent(dict: dic as NSDictionary)
    }
    
    func manageUI() {
        self.nameLbl.text = SharedManager.shared.getFullName()
        self.optionArray = ["Share on your timeline".localized(), "Share on your friend's timeline".localized(), "Share in a group".localized(), "Share to a page".localized()]
        self.userImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        let fileName = "myImageToUpload.jpg"
        self.userImageView.image = FileBasedManager.shared.loadImage(pathMain: fileName)
        self.view.labelRotateCell(viewMain: self.userImageView)
        self.txtView.textColor = UIColor.lightGray
        self.txtView.text = Const.textCreatePlaceholder
    }
    
    func callingShareService(action: String, param: [String:String]) {
        
//        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        RequestManager.fetchDataPost(Completion: { response in
            
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            switch response {
            case .failure(let error):
              
                if error is String {
                }
            case .success(let res):
                
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                } else if res is String {
                    
                } else {
                    SharedManager.shared.isNewPostExist = true
                    // show sucess alert
                    self.showSucessAlert(title: "Worldnoor", message: "Post shared Successfully".localized())
                }
            }
        }, param:param)
    }
    
    func showSucessAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: UIAlertController.Style.alert)
        
        let okAction = UIAlertAction(title: "OK".localized(), style: .cancel, handler: {_ in
            self.dismiss(animated: true, completion: nil)
        })
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
}

extension SharePostController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.optionArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "SharingTableCell", for: indexPath) as? SharingTableCell {
            cell.descLbl.text = self.optionArray[indexPath.row]
            cell.accessoryType = .none
            if self.selectedIndex == indexPath.row {
                cell.accessoryType = .checkmark
            }
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedIndex = indexPath.row
        if indexPath.row == 0 {
            //            self.selectedIndex = 0
            self.sharingTitleLbl.text = "NewsFeed".localized()
        }else {
            let shareList = AppStoryboard.TabBar.instance.instantiateViewController(withIdentifier: "ShareListController") as! ShareListController
            shareList.selectedValue = indexPath.row
            shareList.delegate = self
            self.navigationController?.pushViewController(shareList, animated: true)
        }
        self.shareTableView.reloadData()
    }
}

extension SharePostController:UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if self.txtView.textColor == UIColor.lightGray {
            self.txtView.text = nil
            self.txtView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if self.txtView.text.isEmpty {
            self.txtView.text = Const.textCreatePlaceholder
            self.txtView.textColor = UIColor.lightGray
        }
    }
}

extension SharePostController:ShareListDelegate {
    
    func shareListValueSelected(text: String, id: String, selectedIndex: Int) {
        self.selectedIndex = selectedIndex
        self.selectedCatID = id
        self.sharingTitleLbl.text = text
        self.shareTableView.reloadData()
    }
}

class SharingTableCell: UITableViewCell {
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var descLbl: UILabel!
}
