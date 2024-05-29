//
//  ProfileCompletePictureCell.swift
//  WorldNoor
//
//  Created by Waseem Shah on 22/01/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import Foundation
import UIKit
import TLPhotoPicker
import Photos

class ProfileCompletePictureCell : UICollectionViewCell {
    
    @IBOutlet var lblHeading : UILabel!
    
    weak var delegate: ProfileWizardDelegate?
    
    var isCoverPhoto : Int = 0
    var imageType = ""
    
    
    let fileName = "myImageToUpload.jpg"
    let fileNameCover = "myImageCoverToUpload.jpg"
    
    override class func awakeFromNib() {
        
    }
    
    @IBAction func closeTapped(_ sender: Any) {
            
        self.delegate?.closeTapped(isSkipped: true)
    }
    
    func bindData(dataType : Int) {
        
        self.isCoverPhoto = dataType
        if dataType == 0 {
            self.lblHeading.text = "Add your Profile picture".localized()
        }else {
            self.lblHeading.text = "Add your cover picture".localized()
        }
    }
    
    @IBAction func showPicker(sender : UIButton){
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
    
    @IBAction func skipAction(sender : UIButton){
        self.delegate?.closeTapped(isSkipped: true)
    }
}

extension ProfileCompletePictureCell : TLPhotosPickerViewControllerDelegate {
    
    func dismissPhotoPicker(withTLPHAssets: [TLPHAsset]) {
        
        if isCoverPhoto == 1 { // Cover Image
            for indexObj in withTLPHAssets {
                if indexObj.type == .photo {
                    let imageChoose = self.getImageFromAsset(asset: indexObj.phAsset!)!
                    DispatchQueue.main.async {
                        self.imageType = "cover_image"
                        FileBasedManager.shared.saveFileTemporarily(fileObj: imageChoose, name: self.fileNameCover)
                        self.callingServiceToUpload(imageParamName: self.imageType,fileType: "image" , filePath: FileBasedManager.shared.getSavedImagePath(name: self.fileNameCover))
                    }
                }
            }
        } else if isCoverPhoto == 0 { // Profile Image
            for indexObj in withTLPHAssets {
                if indexObj.type == .photo {
                    let imageChoose = self.getImageFromAsset(asset: indexObj.phAsset!)!
                    DispatchQueue.main.async {
                        self.imageType = "profile_image"
                        FileBasedManager.shared.saveFileTemporarily(fileObj: imageChoose, name: self.fileName)
                        self.callingServiceToUpload(imageParamName: self.imageType, fileType: "image", filePath: FileBasedManager.shared.getSavedImagePath(name: self.fileName))   
                    }
                }
            }
        }
    }
    
    
    func callingServiceToUpload(imageParamName : String ,fileType : String , filePath : String)  {
        let parameters = ["action": "profile/update",
                          "token": SharedManager.shared.userToken(),
                          "isFromUser" : imageParamName,
                          "fileType": fileType,
                          "fileUrl": filePath] as! [String : Any]
        LogClass.debugLog("Parameters \(parameters)")
        Loader.startLoading()
        RequestManager.fetchDataMultiparts(Completion: { response in
            Loader.stopLoading()
            switch response {
            case .failure(let error):
                LogClass.debugLog(error)
            case .success(let res):
                
                if let mainResult = res as? [String : Any] {
                    if let mainData = mainResult["data"] as? [String : Any] {
                        if let mainfile = mainData["profile_image"] as? String {
                            if self.imageType == "cover_image" {
                                SharedManager.shared.userObj?.data.cover_image = mainfile
                                SharedManager.shared.userEditObj.coverImage = mainData["cover_image"] as? String ?? .emptyString
                            } else {
                                SharedManager.shared.userObj?.data.profile_image = mainfile
                                SharedManager.shared.userEditObj.profileImage = mainfile
                            }
                        }

                        SharedManager.shared.saveProfile(userObj: SharedManager.shared.userObj)
                        SocketSharedManager.sharedSocket.updateUserProfile(dictionary: mainData )
                        
                        self.delegate?.closeTapped(isSkipped: false)
                    }
                }
            }
        }, param:parameters, fileUrl: "")
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


