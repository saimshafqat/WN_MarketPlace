//
//  PageBaseImageCell.swift
//  WorldNoor
//
//  Created by Waseem Shah on 26/03/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import Foundation
import UIKit
import TLPhotoPicker
import Photos
import FTPopOverMenu
import FittedSheets

class PageBaseImageCell : UICollectionViewCell {
    @IBOutlet var imgviewHeader : UIImageView!
    @IBOutlet var imgviewProfile : UIImageView!
    
    @IBOutlet var viewHeader : UIView!
    @IBOutlet var viewProfile : UIView!
    
    @IBOutlet var btnProfile : UIButton!
    @IBOutlet var btnHeader : UIButton!
    
    var groupObj: GroupValue!
    var isFromProfile = false
    var sheetController = SheetViewController()
    
    var delegate: newPageDetailDelegate?
    
    func reloadData(){
        self.imgviewProfile.loadImage(urlMain: self.groupObj.profilePicture)
        self.imgviewHeader.loadImage(urlMain: self.groupObj.groupImage)
        
        self.viewHeader.isHidden = true
        self.viewProfile.isHidden = true
        if self.groupObj.isAdmin {
            self.viewHeader.isHidden = false
            self.viewProfile.isHidden = false
        }
    }
    
    @IBAction func showProfile(sender : UIButton){
        let fullScreen = AppStoryboard.PostStoryboard.instance.instantiateViewController(withIdentifier: Const.FullGalleryScreenController) as! FullGalleryViewController
        let dictMain = [String : Any]()
        let feeddata = FeedData.init(valueDict: dictMain)
        feeddata.postType = FeedType.image.rawValue
        var post = [PostFile]()
        
        let newPostfile = PostFile.init()
        newPostfile.fileType = FeedType.image.rawValue
        newPostfile.filePath = self.groupObj.profilePicture
        newPostfile.postID = Int(self.groupObj.groupID)
        
        post.append( newPostfile)
        feeddata.post = post
        fullScreen.isInfoViewShow = true
        fullScreen.collectionArray = feeddata.post!
        fullScreen.feedObj = feeddata
        fullScreen.movedIndexpath = 0
        fullScreen.modalTransitionStyle = .crossDissolve
        UIApplication.topViewController()!.present(fullScreen, animated: false, completion: nil)
    }
    
    
    @IBAction func moreAction(sender : UIButton){
        if self.groupObj!.isAdmin {
            FTPopOverMenu.show(forSender: sender, withMenuArray: ["Report Page".localized(),
                                                                  "Invite Friends".localized(),
                                                                  "Edit Page".localized(),
                                                                  "Delete Page".localized()],
                               imageArray: nil, configuration: SharedManager.shared.configWithMenuStyle()) { (selectedIndex) in
                
                if selectedIndex == 0 {
                    self.reportGroup()
                } else if selectedIndex == 1 {
                    self.inviteFriends()
                } else if selectedIndex == 2 {
                    self.editPage()
                } else {
                    self.deletePage()
                }
            } dismiss: {
                
            }
        } else if self.groupObj!.isMember {
            FTPopOverMenu.show(forSender: sender, withMenuArray: ["Report Page".localized() , "Invite Friends".localized()   ], imageArray: nil, configuration: SharedManager.shared.configWithMenuStyle()) { (selectedIndex) in
                
                if selectedIndex == 0 {
                    self.reportGroup()
                } else {
                    self.inviteFriends()
                }
            } dismiss: {
                
            }
        } else {
            FTPopOverMenu.show(forSender: sender, withMenuArray: ["Report Page".localized() ], imageArray: nil, configuration: SharedManager.shared.configWithMenuStyle()) { (selectedIndex) in
                self.reportGroup()
            } dismiss: {
            
            }
        }
    }
    
    func inviteFriends(){
        let viewGroup = UIApplication.topViewController()!.GetView(nameVC: "NewPageInviteUserVC", nameSB: "Notification") as! NewPageInviteUserVC
        viewGroup.groupObj = self.groupObj
        UIApplication.topViewController()!.navigationController?.pushViewController(viewGroup, animated: true)
    }
    
    func deletePage() {
        var parameters = [ "token": SharedManager.shared.userToken()]
//        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        parameters["page_id"] = self.groupObj.groupID
        parameters["action"] = "page/delete"

        
        RequestManager.fetchDataPost(Completion: { response in
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            switch response {
            case .failure(let error):
                LogClass.debugLog(error.localizedDescription)
            case .success(let res):
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                } else if res is String {
                    SwiftMessages.showMessagePopup(theme: .error, title: "Failed", body: res as? String ?? .emptyString)
                } else {
                    (UIApplication.topViewController()! as! NewPageDetailVC).navigationController?.popViewController(animated: true)
                }
            }
        }, param:parameters)
    }
    
    func editPage() {
        if let groupID = Int(self.groupObj.groupID) {
            self.delegate?.editPage(pageID: groupID)
        }
    }
    
    func GetView(nameVC : String , nameSB : String) -> UIViewController {
        let storyboard = UIStoryboard(name: nameSB, bundle: nil)
        let viewObj = (storyboard.instantiateViewController(withIdentifier: nameVC)) as UIViewController
        return viewObj
    }
    
    func reportGroup() {
        let reportDetail = AppStoryboard.TabBar.instance.instantiateViewController(withIdentifier: "ReportDetailController") as! ReportDetailController
        reportDetail.groupObj = self.groupObj
        reportDetail.isfromPage = true
        reportDetail.delegate = self
        self.sheetController = SheetViewController(controller: reportDetail, sizes: [.fullScreen])
        self.sheetController.overlayColor = UIColor.black.withAlphaComponent(0.3)
        self.sheetController.extendBackgroundBehindHandle = true
        self.sheetController.topCornersRadius = 20
        
        
        UIApplication.topViewController()!.present(self.sheetController, animated: true, completion: nil)
    }
    
    @IBAction func showHeader(sender : UIButton){
        let fullScreen = AppStoryboard.PostStoryboard.instance.instantiateViewController(withIdentifier: Const.FullGalleryScreenController) as! FullGalleryViewController
        let dictMain = [String : Any]()
        let feeddata = FeedData.init(valueDict: dictMain)
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
    
    @IBAction func changeProfileImage(sender : UIButton){
        self.isFromProfile = true
        FTPopOverMenu.show(forSender: sender, withMenuArray: ["Take a picture".localized() , "Upload".localized()], imageArray: nil, configuration: SharedManager.shared.configWithMenuStyle()) { (selectedIndex) in
            
            if selectedIndex == 0 {
                self.openCamera()
            }else {
                self.openCamera()
            }
        } dismiss: {

        }
    }
    
    @IBAction func changeCoverImage(sender : UIButton){
        self.isFromProfile = false
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




extension PageBaseImageCell : TLPhotosPickerViewControllerDelegate{
    func openCamera(){
        let viewController = TLPhotosPickerViewController()
        viewController.configure.maxSelectedAssets = 1
        viewController.delegate = self
        viewController.configure.allowedVideo = false
        viewController.configure.allowedLivePhotos = false
        viewController.configure.allowedVideoRecording = false
        
        UIApplication.topViewController()!.present(viewController, animated: true) {
        }
    }
    
    
    func dismissPhotoPicker(withTLPHAssets: [TLPHAsset]) {
        // use selected order, fullresolution image
        for indexObj in withTLPHAssets {
            if indexObj.type == .photo {
                
                ChatManager.shared.getUrlFromPHAsset(asset: indexObj.phAsset!) {[weak self] (urlString) in
                    if urlString != nil{
                        
                        if self!.isFromProfile {
                            self!.imgviewProfile.image = indexObj.fullResolutionImage
                        }else {
                            self!.imgviewHeader.image = indexObj.fullResolutionImage
                        }
                        self?.uploadFile(filePath: urlString!.path, fileType: "image")
                    }
                }
            }
        }
    }

    
    func uploadFile(filePath:String, fileType:String){
        
        var parameters = [
            "token": SharedManager.shared.userToken(),
            "page_id":String(self.groupObj.groupID),
            "fileType":fileType]
        
        
        if self.isFromProfile {
            parameters["fileUrl"] = filePath
            parameters["action"] = "page/update_picture"
        }else {
            parameters["fileUrl2"] = filePath
            parameters["action"] = "page/update_cover"
        }
        
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
//            case .success(let res):
//            }
            
        }, param:parameters)
    }
}

extension PageBaseImageCell:DismissReportDetailSheetDelegate   {
    func dismissReport(message:String) {
        self.sheetController.closeSheet()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            SharedManager.shared.showAlert(message: message, view: UIApplication.topViewController()!)
        }
    }
}
