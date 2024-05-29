//
//  Profile Base Cell.swift
//  WorldNoor
//
//  Created by Waseem Shah on 07/04/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//
import UIKit
import SKPhotoBrowser
import FTPopOverMenu
import TLPhotoPicker
import TOCropViewController
import AVFoundation
import AVKit
import Photos


class ProfileCollectionImageHeaderCell  : UICollectionViewCell {
    
    @IBOutlet var imgViewBanner : UIImageView!
    @IBOutlet var imgViewProfile : UIImageView!
    
    @IBOutlet var viewLanguage : UIView!
    @IBOutlet var viewBack : UIView!
    @IBOutlet var viewBanner : UIView!
    @IBOutlet var viewProfile : UIView!
    @IBOutlet weak var uploadingImageLoadingView: UIView!
    
    var otherUserID = ""
    var otherUserSearchObj : SearchUserModel!
    var otherUserObj = UserProfile.init()
    
    let fileName = "myImageToUpload.jpg"
    let fileNameCover = "myImageCoverToUpload.jpg"
    var isCoverPhoto = 1
    
    var feedVideoModel = PostCollectionViewObject.init()
    
    
    
    func reloadData(){
        self.uploadingImageLoadingView.isHidden = true
        self.viewBack.isHidden = false
        self.viewBanner.isHidden = true
        self.viewProfile.isHidden = true
        self.viewLanguage.isHidden = true
        
        if self.otherUserID.count == 0 {
            self.viewBack.isHidden = true
            self.viewBanner.isHidden = false
            self.viewProfile.isHidden = false
            self.viewLanguage.isHidden = false
        }
        
        if self.otherUserSearchObj != nil
        {
            self.imgViewBanner.loadImageWithPH(urlMain:self.otherUserObj.coverImage)
            
            UIApplication.topViewController()!.view.labelRotateCell(viewMain: self.imgViewBanner)
            self.imgViewProfile.loadImageWithPH(urlMain:self.otherUserObj.profileImage)
            UIApplication.topViewController()!.view.labelRotateCell(viewMain: self.imgViewProfile)
        }else {
            if FileBasedManager.shared.fileExist(nameFile: fileNameCover).1 {
                self.imgViewBanner.image = FileBasedManager.shared.loadImage(pathMain: fileNameCover)
            } else {
                if self.otherUserObj.coverImage.isEmpty {
                    if let isUserObj = SharedManager.shared.getProfile() {
                        self.imgViewBanner.imageLoad(with: isUserObj.data.cover_image)
                    }
                } else {
                    self.imgViewBanner.loadImageWithPH(urlMain:self.otherUserObj.coverImage)
                }
            }
            
            if FileBasedManager.shared.fileExist(nameFile: fileName).1 {
                self.imgViewProfile.image = FileBasedManager.shared.loadImage(pathMain: fileName)
            }else {
                if self.otherUserObj.profileImage.isEmpty {
                    if let isUserObj = SharedManager.shared.getProfile() {
                        self.imgViewProfile.imageLoad(with: isUserObj.data.profile_image)
                    }
                } else {
                    self.imgViewProfile.loadImageWithPH(urlMain:self.otherUserObj.profileImage)
                }
            }
            UIApplication.topViewController()!.view.labelRotateCell(viewMain: self.imgViewBanner)
            UIApplication.topViewController()!.view.labelRotateCell(viewMain: self.imgViewProfile)
        }
    }
    
    @IBAction func uploadBannerImage(sender : UIButton){
        var images = [SKPhoto]()
        
        if self.otherUserID.count > 0 {
            
            let photo = SKPhoto.photoWithImageURL(self.otherUserObj.coverImage)// add some UIImage
            photo.shouldCachePhotoURLImage = true
            images.append(photo)
            
            
        }else {
            let photo = SKPhoto.photoWithImageURL(SharedManager.shared.userEditObj.coverImage)// add some UIImage
            photo.shouldCachePhotoURLImage = true
            images.append(photo)
        }
        
        let browser = SKPhotoBrowser(photos: images)
        SKPhotoBrowserOptions.displayAction = false
        
        UIApplication.topViewController()!.present(browser, animated: true, completion: {})
    }
    
    @IBAction func uploadProfileImage(sender : UIButton){
        if (SharedManager.shared.userObj?.data.profile_image!.contains("icon-person"))! || SharedManager.shared.userObj?.data.profile_image!.count == 0 {
            FTPopOverMenu.show(forSender: sender, withMenuArray: [ "Upload".localized()],
                               imageArray: nil,
                               configuration: SharedManager.shared.configWithMenuStyle()) { (selectedIndex) in
                self.uploadAction(sender: UIButton.init())
            } dismiss: {
                
            }
        } else {
            FTPopOverMenu.show(forSender: sender, withMenuArray: ["Delete".localized() , "Upload".localized()], imageArray: nil, configuration: SharedManager.shared.configWithMenuStyle()) { (selectedIndex) in
                
                if selectedIndex == 0 {
                    self.profileDeleteAction(sender: UIButton.init())
                }else {
                    self.uploadAction(sender: UIButton.init())
                }
            } dismiss: {
                
            }
        }
    }
    
    @IBAction func openBannerImage(sender : UIButton){
        
    }
    
    @IBAction func openProfileImage(sender : UIButton){
        
        var images = [SKPhoto]()
        
        if self.otherUserID.count > 0 {
            
            let photo = SKPhoto.photoWithImageURL(self.otherUserObj.profileImage)// add some UIImage
            photo.shouldCachePhotoURLImage = true
            images.append(photo)
            
        }else {
            let photo = SKPhoto.photoWithImageURL(SharedManager.shared.userEditObj.profileImage)// add some UIImage
            photo.shouldCachePhotoURLImage = true
            images.append(photo)
            
        }
        
        let browser = SKPhotoBrowser(photos: images)
        SKPhotoBrowserOptions.displayAction = false
        
        UIApplication.topViewController()!.present(browser, animated: true, completion: {})
        
        
        
    }
    
    @IBAction func searchAction(sender : UIButton){
        let controller = GlobalSearchViewController.instantiate(fromAppStoryboard: .EditProfile)
        UIApplication.topViewController()!.navigationController?.pushViewController(controller, animated: false)
    }
    
    @IBAction func backAction(sender : UIButton){
        UIApplication.topViewController()!.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func languageAction(sender : UIButton){
        
    }
    
    @objc func profileDeleteAction(sender : UIButton) {

        self.imgViewProfile.image = UIImage.init(named: "placeholder.png")
        
        Loader.startLoading()
        let parameters = ["action": "profile/remove_profile_picture","token": SharedManager.shared.userToken()]
        
        RequestManager.fetchDataPost(Completion: { (response) in
            Loader.stopLoading()
            switch response {
            case .failure(let error):
                SwiftMessages.apiServiceError(error: error)
            case .success(let res):
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                }else {
                    FileBasedManager.shared.removeFileFromPath(name: "myImageToUpload.jpg")
                }
                
                if let mainResult = res as? [String : Any] {
                    if let mainfile = mainResult["profile_image"] as? String{
                            SharedManager.shared.userObj!.data.profile_image = mainfile
                            SharedManager.shared.downloadUserImage(imageUrl: mainfile)
                        self.imgViewProfile.loadImageWithPH(urlMain:mainfile)
                            SharedManager.shared.userEditObj.profileImage = mainfile
                    }
                    
                    SocketSharedManager.sharedSocket.updateUserProfile(dictionary: mainResult )
                }
                
                if (res as? [String : Any]) != nil {
                    SocketSharedManager.sharedSocket.updateUserProfile(dictionary: res as! [String : Any])
                }
                
            }
        }, param: parameters)
    }

    @objc func uploadAction(sender : UIButton){
        self.isCoverPhoto = 2
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
        
        UIApplication.topViewController()!.present(viewController, animated: true) {
        }
    }
    
}

extension ProfileCollectionImageHeaderCell : TLPhotosPickerViewControllerDelegate {
    func dismissPhotoPicker(withTLPHAssets: [TLPHAsset]) {
        // use selected order, fullresolution image
        
        
        if isCoverPhoto == 1 { // Cover Image
            for indexObj in withTLPHAssets {
                if indexObj.type == .photo {
                    
                    let imageChoose = self.getImageFromAsset(asset: indexObj.phAsset!)!
                    DispatchQueue.main.async {
//                        self.imageType = "cover_image"
                        self.OpenPhotEdit(imageMain: imageChoose, isCricle: false)
                    }
                }
            }
            self.isCoverPhoto = 0
        }else if isCoverPhoto == 2{ // Profile Image
            for indexObj in withTLPHAssets {
                if indexObj.type == .photo {
                    let imageChoose = self.getImageFromAsset(asset: indexObj.phAsset!)!
                    
                    
                    DispatchQueue.main.async {
                        
//                        self.imageType = "profile_image"
                        self.OpenPhotEdit(imageMain: imageChoose, isCricle: true)
                        
                    }
                }
            }
            
            self.isCoverPhoto = 0
        }
    }
    
    
    func callingServiceToUpload(imageParamName : String ,fileType : String , filePath : String)  {
        
        self.getS3URL(imageParamName: imageParamName, fileType: fileType, filePath: filePath)
        
    }
    
    
    func getS3URL(imageParamName : String ,fileType : String , filePath : String){
        
        
        var arrayFileName = [String]()
        var arrayMemiType = [String]()
        
        
        let indexString = filePath
        let imageNameArray = indexString.components(separatedBy: "/")
        
        self.feedVideoModel.ImageName = imageNameArray.last!
        self.feedVideoModel.isType = .Image
        arrayFileName.append(imageNameArray.last!)
        arrayMemiType.append("image/png")
        
        let parametersUpload =  ["action": "s3url" ,"token":SharedManager.shared.userToken()]
        
        var arrayObject = [[String : AnyObject]]()
        for indexObj in 0..<arrayFileName.count {
            var newDict = [String : AnyObject]()
            newDict["mimeType"] = arrayMemiType[indexObj] as AnyObject
            newDict["fileName"] = arrayFileName[indexObj] as AnyObject
            arrayObject.append(newDict)
        }
        
        var newFileParam = [String : AnyObject]()
        newFileParam["file"] = arrayObject as AnyObject
        
        RequestManagerGen.fetchUploadURLPost(Completion: { (response: Result<(uploadMediaModel), Error>) in
            switch response {
            case .failure(let error):
                Loader.stopLoading()
                if error is ErrorModel  {
                    let err = error as! ErrorModel
                }
                
            case .success(let res):
                
                
                for indexobj in res.data!{
                    
                    self.feedVideoModel.S3ImageURL = indexobj.fileUrl ?? ""
                    self.feedVideoModel.S3ImagePath = indexobj.preSignedUrl ?? ""
                }
                self.uploadMediaOnS3(imageParamName: imageParamName, fileType: fileType, filePath: filePath)
            }
        }, param:newFileParam,dictURL: parametersUpload)
        
    }
    
    
    
    func updateProfile(imageParamName : String ,fileType : String , filePath : String){
        var parameters = ["action": "profile/update",
                          "token": SharedManager.shared.userToken(),
                          "isFromUser" : imageParamName,
                          "fileType": fileType
        ] as! [String : Any]
        
        
        if self.isCoverPhoto == 1 {
            parameters["cover_image_s3"] =  self.feedVideoModel.S3ImageURL
            
        }else {
            parameters["profile_image_s3"] =  self.feedVideoModel.S3ImageURL
        }
        
        Loader.startLoading()
        LogClass.debugLog("parameters ===>")
        LogClass.debugLog(parameters)
        
        
        CreateRequestManager.fetchDataPost(Completion:{ (response) in
            Loader.stopLoading()
            
            switch response {
            case .failure(let error):
                SwiftMessages.apiServiceError(error: error)
            case .success(let respDict):
                LogClass.debugLog("respDict  ==>")
                LogClass.debugLog(respDict)
                
                
                if let mainData = respDict as? [String : Any] {
                    //     if let mainData = mainResult["data"] as? [String : Any] {
                    if let mainfile = mainData["profile_image"] as? String {
                        if self.isCoverPhoto == 1 {
                            SharedManager.shared.userObj!.data.cover_image = mainfile
                            SharedManager.shared.userEditObj.coverImage = mainData["cover_image"] as! String
                        } else {
                            SharedManager.shared.userObj!.data.profile_image = mainfile
                            SharedManager.shared.userEditObj.profileImage = mainfile
                        }
                    }
                    if self.isCoverPhoto != 1 {
                        self.uploadingImageLoadingView.isHidden = true
                    }
                    SocketSharedManager.sharedSocket.updateUserProfile(dictionary: mainData )
                }
            }
        }, param: parameters)
        

    }
    
    
    func uploadMediaOnS3(imageParamName : String ,fileType : String , filePath : String){
        
        
        let userToken:String = SharedManager.shared.userObj!.data.token!
        let parameters = ["api_token": userToken]
        
        self.uploadThumbImage(params: parameters , imageParamName : imageParamName ,fileType : fileType , filePath : filePath)
    }
    
}


extension ProfileCollectionImageHeaderCell : TOCropViewControllerDelegate {
    
    func OpenPhotEdit(imageMain : UIImage , isCricle : Bool){
        if isCricle {
            let cropViewController = TOCropViewController.init(croppingStyle: .circular, image: imageMain)
            
            cropViewController.delegate = self
            UIApplication.topViewController()!.present(cropViewController, animated: true, completion: nil)
        }else {
            let cropViewController = TOCropViewController.init(croppingStyle: .default, image: imageMain)
            cropViewController.aspectRatioPreset = .preset16x9
            cropViewController.delegate = self
            cropViewController.aspectRatioLockEnabled = false
            UIApplication.topViewController()!.present(cropViewController, animated: true, completion: nil)
        }
    }
    
    func cropViewController(_ cropViewController: TOCropViewController, didFinishCancelled cancelled: Bool) {
        cropViewController.dismiss(animated: true) {
            
        }
    }
    
    func cropViewController(_ cropViewController: TOCropViewController, didCropTo image: UIImage, with cropRect: CGRect, angle: Int) {
        
        
        if self.isCoverPhoto == 1 {
            self.imgViewBanner.image = image
            FileBasedManager.shared.saveFileTemporarily(fileObj: image, name: fileNameCover)
            self.feedVideoModel.imageMain = image
            self.callingServiceToUpload(imageParamName: "cover_image",fileType: "image" , filePath: FileBasedManager.shared.getSavedImagePath(name: fileNameCover))
            
        } else {
            FileBasedManager.shared.saveFileTemporarily(fileObj: image, name: fileName)
            self.imgViewProfile.image = image
            self.feedVideoModel.imageMain = image
            self.uploadingImageLoadingView.isHidden = false
            self.callingServiceToUpload(imageParamName: "profile_image", fileType: "image", filePath: FileBasedManager.shared.getSavedImagePath(name: fileName))
        }
        
        cropViewController.dismiss(animated: true) {
        }
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
    
    func uploadThumbImage(params : [String:String] , imageParamName : String ,fileType : String , filePath : String){
        CreateRequestManager.uploadMultipartRequestOnS3(urlMain:feedVideoModel.S3ImagePath , params: params ,fileObjectArray: [feedVideoModel],success: {
            (Response) -> Void in

            LogClass.debugLog("uploadThumbImage ===>")
            LogClass.debugLog(Response)
            self.updateProfile(imageParamName: imageParamName, fileType: fileType, filePath: filePath)
        },failure: {(error) -> Void in
            Loader.stopLoading()
        })
    }
    
}


