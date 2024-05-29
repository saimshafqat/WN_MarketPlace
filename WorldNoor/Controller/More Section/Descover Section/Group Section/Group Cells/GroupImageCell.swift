//
//  GroupImageCell.swift
//  WorldNoor
//
//  Created by Waseem Shah on 19/03/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import Foundation
import UIKit
import TLPhotoPicker
import Photos
import FTPopOverMenu

class GroupImageCell : UICollectionViewCell {
    @IBOutlet var imageGroup : UIImageView!
    @IBOutlet var viewUploadImage : UIView!
    @IBOutlet var btnUploadImage : UIButton!
    
    var groupObj:GroupValue!
    
    func reloadData(){

        self.imageGroup.loadImage(urlMain: self.groupObj.groupImage)
        
        self.viewUploadImage.isHidden = true
        
        if self.groupObj.isAdmin {
            self.viewUploadImage.isHidden = false
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
        self.openCamera()
    }
}



extension GroupImageCell : TLPhotosPickerViewControllerDelegate{
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
                        self!.imageGroup.image = indexObj.fullResolutionImage
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
        Loader.startLoading()
        self.callingServiceToUpload(parameters: parameters, action: "page/update_cover")
    }
    
    
    func callingServiceToUpload(parameters:[String:String], action:String)  {
        RequestManager.fetchDataMultipartWithName(Completion: { response in
            Loader.stopLoading()

            
        }, param:parameters)
    }
}


