//
//  PostMakeFriendsCell.swift
//  WorldNoor
//
//  Created by Waseem Shah on 22/12/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import Foundation

class PostMakeFriendsCell : ConfigableCollectionCell{
    
    @IBOutlet weak var friendCollectionView: UICollectionView!
    
    @IBOutlet weak var viewLoader: UIView!
    @IBOutlet weak var lblLoading: UILabel!
    @IBOutlet weak var lblHeading: UILabel!
    
    var startingPoint = ""
    var isNextVideoExist = true
    var isAPICall = false
    var starting_point_id = ""
    var friendSuggestion:[FriendSuggestionModel] = [FriendSuggestionModel]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        friendCollectionView.registerXibCell([
            .FeedFriendSuggestionCollectionCell
        ])
    }

    // MARK: - Override -
    override func displayCellContent(data: AnyObject?, parentData: AnyObject?, at indexPath: IndexPath) {
        
    }
    
    func reloadData() {
        self.contentView.rotateViewForLanguage()
        self.labelRotateCell(viewMain: self.lblHeading)
        self.labelRotateCell(viewMain: self.lblLoading)
                        
        if SharedManager.shared.checkLanguageAlignment() {
            self.friendCollectionView.rotateViewForLanguage()
        }
        
        viewLoader.isHidden = true
        if self.friendSuggestion.count == 0 {
            viewLoader.isHidden = false
            self.getUsernfo()
        }
    }
    
    func paggingAPICall(indexPathMain : IndexPath){
        
        if !self.isAPICall {
            if indexPathMain.row == self.friendSuggestion.count - 1 {
                self.getUsernfo()
            }
            
        }
    }
    
    
    func getUsernfo() {
        let userToken = SharedManager.shared.userToken()
        var parameters = ["action": "get-suggested-friends","token": userToken]
        if self.starting_point_id.count > 0 {
            parameters["starting_point_id"] = self.starting_point_id
        }
        RequestManager.fetchDataGet(Completion: { response in
            Loader.stopLoading()
            self.viewLoader.isHidden = true
            switch response {
            case .failure(let error):
                if error is String {
                    // SharedManager.shared.showAlert(message: Const.networkProblemMessage, view: self)
                }
            case .success(let res):
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                } else if let resArray = res as? [[String : Any]] {
//                    for indexObj in resArray {
//                        self.friendSuggestion.append(FriendSuggestionModel.init(fromDictionary: indexObj))
//                    }
                    if resArray.count > 0 {
                        self.starting_point_id = (resArray.last?["id"] as? Int).map({String($0)}) ?? .emptyString
                    }
                    for indexObj in resArray {
                        let friend = FriendSuggestionModel(fromDictionary: indexObj)
                        let userID = SharedManager.shared.userObj?.data.id ?? 0
                        if !self.friendSuggestion.contains(where: { $0.id == friend.id }) && friend.id != "\(userID)" {
                            self.friendSuggestion.append(friend)
                        }
                    }
                }
            }
//            if self.friendSuggestion.count > 0 {
//                self.starting_point_id = self.friendSuggestion.last!.id
//            }
            DispatchQueue.main.async {
                self.friendCollectionView.reloadData()
            }
        }, param:parameters)
    }
}

extension PostMakeFriendsCell:UICollectionViewDataSource, UICollectionViewDelegate , UICollectionViewDelegateFlowLayout
{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //  return CGSize.init(width: (self.friendCollectionView.frame.size.height / 3) * 2, height: self.friendCollectionView.frame.size.height)
        return CGSize.init(width: (self.friendCollectionView.frame.size.width / 1.6), height: self.friendCollectionView.frame.size.height)
        
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.friendSuggestion.count
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeedFriendSuggestionCollectionCell", for: indexPath) as? FeedFriendSuggestionCollectionCell else {
            return UICollectionViewCell()
        }
        
        let indexMain = indexPath.row
        if self.friendSuggestion.count > indexMain {
            let feedObj:FriendSuggestionModel = self.friendSuggestion[indexMain]
            
            cell.imgViewUser.loadImageWithPH(urlMain:feedObj.profile_image)
            cell.lblName.text = feedObj.firstname + " " + feedObj.lastname
            if feedObj.already_sent_friend_req == "1" {
                cell.imgviewStatus.image = UIImage.init(named: "Icon-Request.png")
                cell.lblStatus.text = "Cancel Request".localized()
            }else {
                cell.lblStatus.text = "Add Friend".localized()
                cell.imgviewStatus.image = UIImage.init(named: "Icon-AddFriend.png")
            }
            
            
            
            cell.imgViewMutual1.isHidden = true
            cell.imgViewMutual2.isHidden = true
            cell.imgViewMutual3.isHidden = true
            
            if feedObj.mutualFriendsCount == "0" {
                cell.lblMutualCount.text = "No mutual friends".localized()
            } else {
                cell.lblMutualCount.text = feedObj.mutualFriendsCount + " " + "mutual friends".localized()
            }
            if feedObj.arrayMutual.count > 2 {
                cell.imgViewMutual1.isHidden = false
                cell.imgViewMutual2.isHidden = false
                cell.imgViewMutual3.isHidden = false
                cell.imgViewMutual1.loadImageWithPH(urlMain:feedObj.arrayMutual[0].profile_image)
                cell.imgViewMutual2.loadImageWithPH(urlMain:feedObj.arrayMutual[1].profile_image)
                cell.imgViewMutual3.loadImageWithPH(urlMain:feedObj.arrayMutual[2].profile_image)
                
            }else  if feedObj.arrayMutual.count > 1 {
                cell.imgViewMutual1.isHidden = false
                cell.imgViewMutual2.isHidden = false
                cell.imgViewMutual1.loadImageWithPH(urlMain:feedObj.arrayMutual[0].profile_image)
                cell.imgViewMutual2.loadImageWithPH(urlMain:feedObj.arrayMutual[1].profile_image)
            }else  if feedObj.arrayMutual.count == 1 {
                cell.imgViewMutual2.isHidden = false
                cell.imgViewMutual2.loadImageWithPH(urlMain:feedObj.arrayMutual[0].profile_image)
            }
        }
        cell.btnFriend.tag = indexPath.row
        cell.btnFriend.addTarget(self, action: #selector(self.friendRequest), for: .touchUpInside)
        return cell
    }
    
    @objc func friendRequest(sender : UIButton){
        
        if self.friendSuggestion[sender.tag].already_sent_friend_req == "1" {
            self.cancelFriendAction(sender: sender.tag)
        }else {
            
            self.sendRequest(sender: sender.tag)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.paggingAPICall(indexPathMain: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vcProfile = ProfileViewController.instantiate(fromAppStoryboard: .PostStoryboard)
        vcProfile.otherUserID = self.friendSuggestion[indexPath.row].id
        vcProfile.otherUserisFriend = "0"
        vcProfile.isNavPushAllow = true
        UIApplication.topViewController()?.navigationController?.pushViewController(vcProfile, animated: true)
        
        
    }
    
    
    
    func sendRequest(sender : Int){
        //        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        let parameters = ["action": "user/send_friend_request","token": SharedManager.shared.userToken() , "user_id" : String(self.friendSuggestion[sender].id)]
        
        RequestManager.fetchDataPost(Completion: { (response) in
            Loader.stopLoading()
            switch response {
            case .failure(let error):
                SwiftMessages.apiServiceError(error: error)
            case .success(let res):
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                } else if let newRes = res as? [String:Any] {
                    self.friendSuggestion[sender].already_sent_friend_req = "1"
                    self.reloadCell(sender: sender)
                    
                } else if let newRes = res as? String {
                    SharedManager.shared.showAlert(message: newRes, view: UIApplication.topViewController()!)
                }
            }
        }, param: parameters)
    }
    
    func reloadCell(sender : Int){
        if let cellSuggestion = self.friendCollectionView.cellForItem(at: IndexPath.init(row: sender, section: 0)) as? FeedFriendSuggestionCollectionCell {
            if self.friendSuggestion[sender].already_sent_friend_req == "1" {
                cellSuggestion.imgviewStatus.image = UIImage.init(named: "Icon-Request.png")
                cellSuggestion.lblStatus.text = "Cancel Request".localized()
            }else {
                cellSuggestion.lblStatus.text = "Add Friend".localized()
                cellSuggestion.imgviewStatus.image = UIImage.init(named: "Icon-AddFriend.png")
            }
        }
    }
    
    func cancelFriendAction(sender : Int){
        
        //        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        let parameters = ["action": "user/cancel_friend_request","token": SharedManager.shared.userToken() , "user_id" : String(self.friendSuggestion[sender].id)]
        
        RequestManager.fetchDataPost(Completion: { (response) in
            //            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            switch response {
            case .failure(let error):
                SwiftMessages.apiServiceError(error: error)
            case .success(let res):
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                } else if let newRes = res as? [String:Any] {
                    self.successOfCancelRequest(sender: sender)
                } else if let newRes = res as? String {
                    self.successOfCancelRequest(sender: sender)
                    SharedManager.shared.showAlert(message: newRes, view: UIApplication.topViewController()!)
                }
            }
        }, param: parameters)
    }
    
    func successOfCancelRequest(sender:Int){
        friendSuggestion[sender].already_sent_friend_req = ""
        reloadCell(sender: sender)
    }
}

