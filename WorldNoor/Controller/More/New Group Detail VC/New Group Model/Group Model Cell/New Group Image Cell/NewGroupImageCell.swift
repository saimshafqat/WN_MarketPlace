//
//  NewGroupImageCell.swift
//  WorldNoor
//
//  Created by apple on 11/17/21.
//  Copyright © 2021 Raza najam. All rights reserved.
//

import Foundation
import UIKit
import TLPhotoPicker
import Photos
import FTPopOverMenu

class NewGroupImageCell : UITableViewCell {
    @IBOutlet var imgviewHeader : UIImageView!
//    @IBOutlet var imgviewProfile : UIImageView!
    
    @IBOutlet var viewHeader : UIView!
//    @IBOutlet var viewProfile : UIView!
    
//    @IBOutlet var btnProfile : UIButton!
    @IBOutlet var btnHeader : UIButton!
    
    var groupObj:GroupValue!
//    var isFromProfile = false
    

    func reloadData(){

        self.imgviewHeader.loadImage(urlMain: self.groupObj.groupImage)
        
        self.viewHeader.isHidden = true

        if self.groupObj.isAdmin {
            self.viewHeader.isHidden = false
        }
    }

    @IBAction func showHeader(sender : UIButton){
        let fullScreen = AppStoryboard.PostStoryboard.instance.instantiateViewController(withIdentifier: Const.FullGalleryScreenController) as! FullGalleryViewController
        var dictMain = [String : Any]()
        var feeddata = FeedData.init(valueDict: dictMain)
        feeddata.postType = FeedType.image.rawValue
        var post = [PostFile]()
        
            let newPostfile = PostFile.init()
            newPostfile.fileType = FeedType.image.rawValue
            newPostfile.filePath = self.groupObj.groupImage
        newPostfile.postID = Int(self.groupObj.groupID)

            post.append( newPostfile)
        fullScreen.isInfoViewShow = true
        feeddata.post = post
        fullScreen.collectionArray = feeddata.post!
        fullScreen.feedObj = feeddata
        fullScreen.movedIndexpath = 0
        fullScreen.modalTransitionStyle = .crossDissolve
        UIApplication.topViewController()!.present(fullScreen, animated: false, completion: nil)
        
    }
    
    

    @IBAction func changeCoverImage(sender : UIButton){
//        self.isFromProfile = false
        FTPopOverMenu.show(forSender: sender, withMenuArray: ["Take a picture".localized() , "Upload".localized()], imageArray: nil, configuration: SharedManager.shared.configWithMenuStyle()) { (selectedIndex) in

            
            if selectedIndex == 0 {
                self.openCamera()
            }else {
                self.openCamera()
            }
        } dismiss: { 

        }
    }
    
    
}




extension NewGroupImageCell : TLPhotosPickerViewControllerDelegate{
    func openCamera(){
        let viewController = TLPhotosPickerViewController()
        viewController.configure.maxSelectedAssets = 1
        viewController.delegate = self
        viewController.configure.allowedVideo = false
        viewController.configure.allowedLivePhotos = false
        viewController.configure.allowedVideoRecording = false
        
        UIApplication.topViewController()!.present(viewController, animated: true) {
//            viewController.albumPopView.show(viewController.albumPopView.isHidden, duration: 0.1)
        }
    }
    
    
    func dismissPhotoPicker(withTLPHAssets: [TLPHAsset]) {
        // use selected order, fullresolution image
        for indexObj in withTLPHAssets {
            if indexObj.type == .photo {
                
                ChatManager.shared.getUrlFromPHAsset(asset: indexObj.phAsset!) {[weak self] (urlString) in
                    if urlString != nil{
                        
//                        if self!.isFromProfile {
//                            self!.imgviewProfile.image = indexObj.fullResolutionImage
//                        }else {
                            self!.imgviewHeader.image = indexObj.fullResolutionImage
//                        }
                        self?.uploadFile(filePath: urlString!.path, fileType: "image")
                    }
                }
            }
        }
    }
    
    
    func uploadFile(filePath:String, fileType:String){
        var parameters = [
                          "token": SharedManager.shared.userToken(),
                          "group_id":String(self.groupObj.groupID),
                          "fileType":fileType]
        
        
            parameters["cover_photo"] = filePath
            parameters["action"] = "group/update_cover"
//        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        self.callingServiceToUpload(parameters: parameters, action: "page/update_cover")
    }
    
    
    func callingServiceToUpload(parameters:[String:String], action:String)  {
        RequestManager.fetchDataMultipartWithName(Completion: { response in
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
//            switch response {
//            case .failure(let error):
//                if error is String {

//                }
//            case .success(let res):
//                LogClass.debugLog("callingServiceToUpload res ===> ")

//            }
            
        }, param:parameters)
    }
}

