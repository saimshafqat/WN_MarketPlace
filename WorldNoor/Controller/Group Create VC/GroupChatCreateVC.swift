//
//  GroupCreateVC.swift
//  WorldNoor
//
//  Created by apple on 5/15/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import TLPhotoPicker


class GroupChatCreateVC: UIViewController {
    
    @IBOutlet var tfGroupName : UITextField!
    
    @IBOutlet var imgViewGroup : UIImageView!
    
    @IBOutlet var collectionViewUser : UICollectionView!
    
    var arrayFriends = [FriendChatModel]()
    
    var filePath = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "New Group".localized()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.collectionViewUser.reloadData()
    }
    
    @IBAction func createGroup(sender : UIButton){
//        if self.arrayFriends.count > 1 {
            if self.tfGroupName.text!.count == 0 {
                self.ShowAlert(message: "Enter Group Title".localized())
            }else {
                if self.filePath.count == 0 {
                    var memberID = [String]()
                    for indexObj in self.arrayFriends {
                        memberID.append(indexObj.id)
                    }
                    let parameters:NSDictionary = ["action": "conversation/create", "token":SharedManager.shared.userToken(), "serviceType":"Node", "conversation_type":"group","member_ids": memberID , "conversation_name" : self.tfGroupName.text! , "group_chat_image" : ""]
                    self.callingService(parameters: parameters as! [String : Any])
                }else {
                    self.uploadFile()
                }
//                SharedManager.shared.showOnWindow()
                Loader.startLoading()
            }
    }
    
    
    func uploadFile(){
        
        let parameters = ["action": "update-group-chat-image"  ,
                          "token": SharedManager.shared.userToken(),
                          "serviceType": "Node",
                          "fileType":"image", "fileUrl":self.filePath] as! [String : Any]
        
        let newTime = SharedManager.shared.getCurrentDateString()
        LogClass.debugLog("parameters")
        LogClass.debugLog(parameters)
        self.callingServiceToUpload(parameters: parameters, newTime: newTime , fileType:"image")
    }
    
    
    func callingServiceToUpload(parameters:[String:Any] , newTime: String, fileType:String)  {
        RequestManager.fetchDataMultiparts(Completion: { response in
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            switch response {
            case .failure(let error):

//                if error is String {
//                }else {
                    self.ShowAlert(message: Const.networkProblemMessage.localized())
//                }
            case .success(let res):
                LogClass.debugLog("res")
                LogClass.debugLog(res)
                
                
                if let mainResult = res as? [String : Any] {
                    if let mainData = mainResult["data"] as? [String : Any] {
                            if let mainURL = mainData["group_image"] as? String {

                                DispatchQueue.main.async {
                                    var memberID = [String]()
                                    for indexObj in self.arrayFriends {
                                        memberID.append(indexObj.id)
                                    }
                                    let parameters:NSDictionary = ["action": "conversation/create", "token":SharedManager.shared.userToken(), "serviceType":"Node", "conversation_type":"group","member_ids": memberID , "conversation_name" : self.tfGroupName.text! , "group_chat_image" : mainURL]
                                    self.callingService(parameters: parameters as! [String : Any])
                                }
                            }
                    }
                }
            }
        }, param:parameters, fileUrl: "")
    }
    
    
    
    @IBAction func chooseImage(sender : UIButton){
        self.openPhotoPicker(maxValue: 1)
    }
    
    
    func openPhotoPicker(maxValue : Int = 10){
        let viewController = TLPhotosPickerViewController()
        viewController.delegate = self
        
        var configure = TLPhotosPickerConfigure()
        configure.maxSelectedAssets = maxValue
        configure.numberOfColumn = 3
        configure.allowedVideo = false
        configure.allowedLivePhotos = false
        viewController.configure = configure
        
       self.present(viewController, animated: true) {
        }
    }
    
    func callingService(parameters:[String:Any]) {
        
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
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
        }, param:parameters)
    }
}


extension GroupChatCreateVC : TLPhotosPickerViewControllerDelegate {
    func dismissPhotoPicker(withTLPHAssets: [TLPHAsset]) {
        // use selected order, fullresolution image
        
        for indexObj in withTLPHAssets {
            if indexObj.type == .photo {
                
                let imageChoose = self.getImageFromAsset(asset: indexObj.phAsset!)!
                self.imgViewGroup.image = imageChoose
                
                ChatManager.shared.getUrlFromPHAsset(asset: indexObj.phAsset!) {[weak self] (urlString) in
                    if urlString != nil{
                        self!.filePath = urlString!.path
                    }
                }
            }
        }
    }
    
    
    func dismissPhotoPicker(withPHAssets: [PHAsset]) {
        
    }
    
    func photoPickerDidCancel() {
        // cancel
    }
    
    func dismissComplete() {
        // picker viewcontroller dismiss completion
    }
    
    func canSelectAsset(phAsset: PHAsset) -> Bool {
        //Custom Rules & Display
        //You can decide in which case the selection of the cell could be forbidden.
        return true
    }
    
    func didExceedMaximumNumberOfSelection(picker: TLPhotosPickerViewController) {
        // exceed max selection
    }
    
    func handleNoAlbumPermissions(picker: TLPhotosPickerViewController) {
        // handle denied albums permissions case
    }
    
    func handleNoCameraPermissions(picker: TLPhotosPickerViewController) {
        // handle denied camera permissions case
    }
    
    func getImageFromAsset(asset: PHAsset) -> UIImage? {
        var img: UIImage?
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.version = .original
        options.isSynchronous = true
        manager.requestImageData(for: asset, options: options) { data, _, _, _ in
            if let data = data {
                img = UIImage(data: data)
            }
        }
        return img
    }
    
    func getSelectedItem(asset:TLPHAsset)->UIImage {
        if asset.type == .video {
            
            let manager = PHImageManager.default()
            let option = PHImageRequestOptions()
            var thumbnail = UIImage()
            option.isSynchronous = true
            manager.requestImage(for: asset.phAsset!, targetSize: CGSize(width: 138, height: 138), contentMode: .aspectFit, options: option,  resultHandler: {(result, info)->Void in
                
                thumbnail = result!
                
            })
            return thumbnail
            
        }
        if let image = asset.fullResolutionImage {
            return image
        }
        return UIImage()
    }
}



extension GroupChatCreateVC : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: collectionView.frame.size.width / 4 , height: 150)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrayFriends.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cellUser = collectionView.dequeueReusableCell(withReuseIdentifier: "GroupchatUserCell", for: indexPath) as? GroupchatUserCell else {
           return UICollectionViewCell()
        }
        
        cellUser.imgViewUser.loadImageWithPH(urlMain:self.arrayFriends[indexPath.row].profile_image)
        self.view.labelRotateCell(viewMain: cellUser.imgViewUser)
        cellUser.lblName.text = self.arrayFriends[indexPath.row].name
        
        
        cellUser.btnDelete.tag = indexPath.row
        cellUser.btnDelete.addTarget(self, action: #selector(self.deleteAction), for: .touchUpInside)
        
        return cellUser
    }
    
    
    @objc func deleteAction(sender : UIButton){
        
        
        if self.arrayFriends.count > 2 {
            self.arrayFriends.remove(at: sender.tag)
            self.collectionViewUser.reloadData()
        }else {
            self.ShowAlertWithCompletaion(message: "After remove this contact you cannot able to create Group. Are you sure to proceed?".localized()) { (statusP) in
                if statusP {
                    self.arrayFriends.remove(at: sender.tag)
                    self.collectionViewUser.reloadData()
                    self.navigationController?.removeRighttButton(self)
                }
            }
        }
        
    }
}


class GroupchatUserCell : UICollectionViewCell {
    @IBOutlet var lblName  : UILabel!
    @IBOutlet var imgViewUser  : UIImageView!
    
    @IBOutlet var btnDelete : UIButton!
    @IBOutlet var viewRemove  : UIView!
}
