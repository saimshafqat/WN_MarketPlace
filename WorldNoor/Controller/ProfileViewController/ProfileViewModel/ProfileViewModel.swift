//
//  ProfileViewModel.swift
//  WorldNoor
//
//  Created by Raza najam on 11/25/19.
//  Copyright © 2019 Raza najam. All rights reserved.
//

import Foundation
import UIKit
import SwiftDate
import Photos
import TLPhotoPicker
import AVFoundation
import AVKit
import SKPhotoBrowser
import Photos
import FittedSheets
import TOCropViewController
import GoogleMobileAds
import SDWebImage
import Combine
import FTPopOverMenu

class ProfileViewModel: NSObject, PickerviewDelegate {
    
    var reloadTableViewClosure: (()->())?
    var feedScrollHandler: (()->())?
    var hideSkeletonClosure: (()->())?
    var didSelectTableClosure:((IndexPath)->())?
    var reloadTableViewWithNoneClosure: (()->())?
    var hideFooterClosure: (()->())?
    var showAlertMessageClosure:((String)->())?
    var showloadingBar:(()->())?
    var showShareOption:((Int)->())?
    var reloadSpecificRow:((IndexPath)->())?
    var cellHeightDictionary: NSMutableDictionary
    var presentImageFullScreenClosure:((Int, Bool)->())?
    var feedArray: [FeedData] = []
    var currentlyPlayingIndexPath : IndexPath? = nil
    var isNextFeedExist:Bool = true
    var refreshControl = UIRefreshControl()
    var postID:Int?
    var arrayInterest = [InterestModel]()
    var arrayRelationStatus = [RelationshipStatus]()
    var arrayWebsite = [WebsiteModel]()
    var arrayFamilyRelationStatus = [RelationshipStatus]()
    
    var arraySports = [LikePageModel]()
    var arrayTv = [LikePageModel]()
    var arrayBook = [LikePageModel]()
    var arrayMovie = [LikePageModel]()
    var arrayGames = [LikePageModel]()
    
    var websiteURLCompletion: ((Int, Int?)->Void)?
    var relationshipCompletion: ((Int, Int?) -> Void)?
    var familyRelationshipCompletion: ((Int, Int?) -> Void)?
    var currencyCompletion: ((Int, Int?) -> Void)?
    var groupCompletion: ((GroupValue, String?) -> Void)?
    var lifeEventsCompletion: ((Int, Int?) -> Void)?
    var lifeEventsDeleteCompletion: ((Int, Int?) -> Void)?
    var lifeEventDetailCompletion: ((Int, Int?) -> Void)?
    var categoryLikePagesCompletion: ((String, String, [LikePageModel]) -> Void)?
    var groupSeeAllCompletion: ((String, String, [GroupValue]) -> Void)?
    var backTappedCompletion:((UIButton) ->Void)?
    
    var openLikePage: ((LikePageModel, String?) -> Void)?
    public var arrayLanguage: [LanguageModel] {
        return SharedManager.shared.populateLangData()
    }
    var arrayContactGroupSearch = [ContactModel]()
    var contactGroupProfileCompletion: (( ContactModel)-> Void)?
    var arrayContactGroup = [ContactModel]()
    var feedtble = UITableView.init()
    var parentView : ProfileViewController!
    var arrayBottom = [[String : String]]()
    var selectedTab = selectedUserTab.timeline
    var indexImage = 1
    var texttoshow = ""
    var arrayImage = [FeedData]()
    var arrayVideo = [FeedData]()
    
    var arrayImageLocal = [UIImage]()
    var arrayVideoLocal = [URL]()
    
    var arrayVideoforTable = [Any]()
    var videoforTable = [Any]()
    
    var timerSearch : Timer!
    var imageType = ""
    var isCoverPhoto = 0
    var viewLanguage : LanguagePopUpVC!
    let fileName = "myImageToUpload.jpg"
    let fileNameCover = "myImageCoverToUpload.jpg"
    
    var isFeedAPICall = true
    // reel
    var myReelsList: [FeedData] = []
    var savedReelsList: [FeedData] = []
    var reelPageNumber = 1
    var isNextVideoExist = true
    var isAPICall = false
    var apiService = APITarget()
    
    var feedVideoModel = PostCollectionViewObject.init()
    
    private var subscription: Set<AnyCancellable> = []
    
    override init() {
        
        cellHeightDictionary = NSMutableDictionary()
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.languageChangeNotification),name: NSNotification.Name(Const.KLangChangeNotif),object: nil)
        self.feedArray.removeAll()
        
        
        NotificationCenter.default.addObserver(self,selector:#selector(self.newReactionRecived),name: NSNotification.Name(rawValue: "reactions_count_updated"), object: nil)
        
        
    }
    
    @objc func newReactionRecived(_ notification: Notification) {
        
        if let userInfo = notification.userInfo as? [String : Any] {
            
            let postID = (userInfo["post_id"] as? Int)
            let likesCount = (userInfo["likesCount"] as? Int)
            let isReaction = (userInfo["isReaction"] as? String)
            for indexObj in self.feedArray {
                if indexObj.postID == postID {
                    indexObj.isReaction = isReaction
                    indexObj.likeCount = likesCount
                }
            }
        }
        
        if let feedParent = self.parentView {
            self.parentView.profileTableView.reloadRows(at: self.parentView.profileTableView.indexPathsForVisibleRows ?? [] , with: .automatic)
        }
    }
    
    @objc func languageChangeNotification() {
        self.callingFeedService(lastPostID: "", isLastTrue: false, isRefresh: true)
    }
    
    @objc open func refresh(sender:AnyObject) {
        self.isNextFeedExist = true
        //        SDImageCache.shared.clearMemory()
        //        SDImageCache.shared.clearDisk()
        self.callingFeedService(lastPostID: "", isLastTrue: false, isRefresh: true)
    }
    
    func getUserImages() {
        
        //        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        let userToken = SharedManager.shared.userToken()
        var parameters = ["action": "profile/photos","token": userToken]
        
        if self.parentView.otherUserID.count > 0 {
            parameters["user_id"] = self.parentView.otherUserID
        }
        
        RequestManagerGen.fetchDataGet(Completion: { (response: Result<(FeedModel), Error>) in
            //            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            switch response {
                
            case .failure( _):
                self.parentView.profileTableView.reloadData()
            case .success(let res):
                self.handleImageFeedResponse(feedObj: res)
            }
        }, param:parameters)
    }
    
    
    func getUserVideo() {
        
        //        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        let userToken = SharedManager.shared.userToken()
        var parameters = ["action": "profile/videos","token": userToken]
        
        if self.parentView.otherUserID.count > 0 {
            parameters["user_id"] = self.parentView.otherUserID
        }
        
        RequestManagerGen.fetchDataGet(Completion: { (response: Result<(FeedModel), Error>) in
            //            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            switch response {
                
            case .failure( _):
                self.parentView.profileTableView.reloadData()
            case .success(let res):
                self.handleImageFeedResponse(feedObj: res)
            }
        }, param:parameters)
    }
    
    func handleImageFeedResponse(feedObj:FeedModel) {
        
        if selectedTab == .photos {
            if let isFeedData = feedObj.data {
                self.arrayImage.append(contentsOf: isFeedData)
            }
            self.arrayBottom.append(["Type" : "3" , "Des" : "Heading" , "Text" : "Interest".localized(), "isExpand" : "0", "id" : "9"])
        } else {
            if let isFeedData = feedObj.data {
                self.arrayVideo.append(contentsOf: isFeedData)
            }
            
            for indexObj in self.arrayVideo {
                for indexInner in indexObj.post! {
                    
                    if indexInner.thumbnail != nil {
                        self.arrayVideoforTable.append(indexInner.thumbnail!)
                    }else {
                        self.arrayVideoforTable.append(indexInner.filePath!)
                    }
                    
                    self.videoforTable.append(indexInner.filePath!)
                }
            }
            
            self.arrayBottom.append(["Type" : "3" , "Des" : "Heading" , "Text" : "Interest".localized(), "isExpand" : "0", "id" : "9"])
        }
        
        self.parentView.profileTableView.reloadData()
    }
    
    func getLanguages() {
        if self.arrayLanguage.count > 0 {
            self.showLanguagePicker(Type: 2)
            return
        }
    }
    
    func getInterestes() {
        if self.arrayInterest.count > 0 {
            self.showcountryPicker(Type: 2)
            return
        }
        self.arrayInterest.removeAll()
        //        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        let userToken = SharedManager.shared.userToken()
        let parameters = ["action": "meta/interests","token": userToken]
        RequestManager.fetchDataGet(Completion: { (response) in
            //            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            switch response {
            case .failure(let error):
                SwiftMessages.apiServiceError(error: error)            case .success(let res):
                
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                } else if res is [[String : Any]] {
                    let array = res as! [[String : Any]]
                    
                    for indexObj in array {
                        self.arrayInterest.append(InterestModel.init(fromDictionary: indexObj))
                    }
                    self.showcountryPicker(Type: 2)
                }
            }
        }, param: parameters)
    }
    
    func getRelationships() {
        apiService.relationStatusListRequest(endPoint: .relationStatusList([:]))
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    LogClass.debugLog("Successfully stored relationshipList")
                case .failure(let error):
                    LogClass.debugLog("Unable to store relationshipList.")
                    SwiftMessages.showMessagePopup(theme: .error, title: "Failed", body: error.localizedDescription)                }
            }, receiveValue: { response in
                LogClass.debugLog("RelationshipList  Response ==> \(response)")
                self.arrayRelationStatus.removeAll()
                for relationStatus in response.data {
                    self.arrayRelationStatus.append(relationStatus)
                }
                print("Total Relationship Items \(self.arrayRelationStatus)")
            })
            .store(in: &subscription)
    }
    
    func getFamilyRelationships() {
        apiService.familyRelationStatusListRequest(endPoint: .familyRelationStatusList([:]))
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    LogClass.debugLog("Successfully Family RelationshipList")
                case .failure(let error):
                    LogClass.debugLog("Failure")
                    SwiftMessages.showMessagePopup(theme: .error, title: "Failed", body: error.localizedDescription)                }
            }, receiveValue: { response in
                LogClass.debugLog("Family RelationshipList Token Response ==> \(response)")
                self.arrayFamilyRelationStatus.removeAll()
                for relationStatus in response.data {
                    self.arrayFamilyRelationStatus.append(relationStatus)
                }
            })
            .store(in: &subscription)
    }
    
    func pickerChooseMultiView(text: [String], type: Int) {
        var selectedInterests = [InterestModel]()
        // let textarray = text.components(separatedBy: ",")
        for indexObj in text {
            for indexInner in self.arrayInterest {
                if indexObj == indexInner.name {
                    selectedInterests.append(indexInner)
                }
            }
        }
        self.updateInterest(selectedInterests: selectedInterests)
    }
    
    func showcountryPicker(Type : Int) {
        let cuntryPicker = self.parentView.GetView(nameVC: "Pickerview", nameSB: "EditProfile") as! Pickerview
        cuntryPicker.isMultipleItem = true
        cuntryPicker.pickerDelegate = self
        cuntryPicker.type = Type
        var arrayData = [String]()
        for indexObj in self.arrayInterest {
            arrayData.append(indexObj.name)
        }
        var selectedInterest = [String]()
        if self.parentView.otherUserID.count > 0 {
            for indexObj in 0..<self.parentView.otherUserObj.InterestArray.count {
                selectedInterest.append(self.parentView.otherUserObj.InterestArray[indexObj].name)
            }
        } else {
            for indexObj in 0..<SharedManager.shared.userEditObj.InterestArray.count {
                selectedInterest.append(SharedManager.shared.userEditObj.InterestArray[indexObj].name)
            }
        }
        cuntryPicker.arrayMain = arrayData
        cuntryPicker.selectedItems = selectedInterest
        self.parentView.present(cuntryPicker, animated: true)
    }
    
    func showLanguagePicker(Type : Int) {
        let cuntryPicker = self.parentView.GetView(nameVC: "Pickerview", nameSB: "EditProfile") as! Pickerview
        cuntryPicker.isMultipleItem = true
        // cuntryPicker.pickerDelegate = self
        cuntryPicker.isFromLanguage = true
        cuntryPicker.type = Type
        cuntryPicker.languageCompletion = { [weak self] text, type in
            guard let self else { return }
            var selectedLanguages = [LanguageModel]()
            for indexObj in text {
                for indexInner in arrayLanguage {
                    if indexObj == indexInner.languageName {
                        if !(selectedLanguages.contains(where: {$0.languageName == indexObj})) {
                            selectedLanguages.append(indexInner)
                        }
                    }
                }
            }
            self.updateLanguages(selectedLanguages : selectedLanguages)
        }
        var arrayData = [String]()
        for indexObj in arrayLanguage {
            if !(arrayData.contains(where: {$0 == indexObj.languageName})) {
                arrayData.append(indexObj.languageName)
            }
        }
        var selectedLanguage = [String]()
        if self.parentView.otherUserID.count > 0 {
            for indexObj in 0..<self.parentView.otherUserObj.languayeArray.count {
                selectedLanguage.append(self.parentView.otherUserObj.languayeArray[indexObj].languageName)
            }
        } else {
            for indexObj in 0..<SharedManager.shared.userEditObj.languayeArray.count {
                selectedLanguage.append(SharedManager.shared.userEditObj.languayeArray[indexObj].languageName)
            }
        }
        cuntryPicker.arrayMain = arrayData
        cuntryPicker.selectedItems = selectedLanguage
        self.parentView.present(cuntryPicker, animated: true)
    }
    
    func pickerChooseView(text: String, type: Int) {
        var selectedInterests = [InterestModel]()
        let textarray = text.components(separatedBy: ",")
        for indexObj in textarray {
            for indexInner in self.arrayInterest {
                if indexObj == indexInner.name {
                    selectedInterests.append(indexInner)
                }
            }
        }
        self.updateInterest(selectedInterests: selectedInterests)
    }
    
    func updateInterest(selectedInterests : [InterestModel]) {
        if selectedInterests.count == 0 {
            SwiftMessages.showMessagePopup(theme: .success, title: "Alert", body: "Please select atleast one interest".localized())
        } else {
            let userToken = SharedManager.shared.userToken()
            var action = ""
            var InterestsID = [String]()
            action = "user/interests/update"
            for indexObj in selectedInterests {
                InterestsID.append(indexObj.id)
            }
            let parameters = ["action": action,"token": userToken , "interest_id" : InterestsID ] as [String : Any]
            //            SharedManager.shared.showOnWindow()
            Loader.startLoading()
            RequestManager.fetchDataPost(Completion: { response in
                //                SharedManager.shared.hideLoadingHubFromKeyWindow()
                Loader.stopLoading()
                switch response {
                case .failure(let error):
                    SwiftMessages.apiServiceError(error: error)
                case .success(let res):
                    if res is Int {
                        AppDelegate.shared().loadLoginScreen()
                    } else if res is String {
                        SharedManager.shared.showAlert(message: res as! String, view: self.parentView)
                    } else  {
                        SharedManager.shared.userEditObj.InterestArray = selectedInterests
                        self.profileRefreshTabSelection(tabValue: selectedUserTab.aboutMe.rawValue, refreshValue: 9)
                    }
                }
            }, param:parameters)
        }
    }
    
    func updateLanguages(selectedLanguages : [LanguageModel]) {
        if selectedLanguages.count == 0 {
            SwiftMessages.showMessagePopup(theme: .success, title: "Alert", body: "Please select atleast one language".localized())
        } else {
            let userToken = SharedManager.shared.userToken()
            var action = ""
            var languageId = [String]()
            action = "user/languages/update"
            for indexObj in selectedLanguages {
                languageId.append(indexObj.languageID)
            }
            let parameters = ["action": action, "token": userToken, "language_id" : languageId] as [String : Any]
            //            SharedManager.shared.showOnWindow()
            Loader.startLoading()
            RequestManager.fetchDataPost(Completion: { response in
                //                SharedManager.shared.hideLoadingHubFromKeyWindow()
                Loader.stopLoading()
                switch response {
                case .failure(let error):
                    SwiftMessages.apiServiceError(error: error)
                case .success(let res):
                    if res is Int {
                        AppDelegate.shared().loadLoginScreen()
                    } else if res is String {
                        SharedManager.shared.showAlert(message: res as? String ?? .emptyString, view: self.parentView)
                    } else  {
                        SharedManager.shared.userEditObj.languayeArray = selectedLanguages
                        self.profileRefreshTabSelection(tabValue: selectedUserTab.aboutMe.rawValue, refreshValue: 25)
                    }
                }
            }, param:parameters)
        }
    }
    
}

extension ProfileViewModel : TOCropViewControllerDelegate {
    
    func OpenPhotEdit(imageMain : UIImage , isCricle : Bool){
        if isCricle {
            let cropViewController = TOCropViewController.init(croppingStyle: .circular, image: imageMain)
            
            cropViewController.delegate = self
            self.parentView.present(cropViewController, animated: true, completion: nil)
        }else {
            let cropViewController = TOCropViewController.init(croppingStyle: .default, image: imageMain)
            cropViewController.aspectRatioPreset = .preset16x9
            cropViewController.delegate = self
            cropViewController.aspectRatioLockEnabled = false
            self.parentView.present(cropViewController, animated: true, completion: nil)
        }
    }
    
    func cropViewController(_ cropViewController: TOCropViewController, didFinishCancelled cancelled: Bool) {
        cropViewController.dismiss(animated: true) {
            
        }
    }
    
    func cropViewController(_ cropViewController: TOCropViewController, didCropTo image: UIImage, with cropRect: CGRect, angle: Int) {
        
        let cellMain = self.parentView.profileTableView.cellForRow(at: IndexPath.init(row: 0, section: 0)) as! ProfileNewImageHeaderCell
        
        if self.imageType == "cover_image" {
            cellMain.imgViewBanner.image = image
            FileBasedManager.shared.saveFileTemporarily(fileObj: image, name: fileNameCover)
            self.feedVideoModel.imageMain = image
            self.callingServiceToUpload(imageParamName: self.imageType,fileType: "image" , filePath: FileBasedManager.shared.getSavedImagePath(name: fileNameCover))
            
        } else {
            FileBasedManager.shared.saveFileTemporarily(fileObj: image, name: fileName)
            cellMain.imgViewProfile.image = image
            self.feedVideoModel.imageMain = image
            cellMain.uploadingImageLoadingView.isHidden = false
            self.callingServiceToUpload(imageParamName: self.imageType, fileType: "image", filePath: FileBasedManager.shared.getSavedImagePath(name: fileName))
        }
        
        cropViewController.dismiss(animated: true) {
        }
    }
}

extension ProfileViewModel: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.section == 1 {
            
            if self.feedArray.count > 0 {
                if indexPath.row > self.feedArray.count-1 {
                    return
                }
                let feedObj:FeedData = self.feedArray[indexPath.row] as FeedData
                switch feedObj.postType! {
                case FeedType.video.rawValue, FeedType.liveStream.rawValue:
                    
                    if cell is NewVideoFeedCell {
                        
                        let cell = cell as! NewVideoFeedCell
                        if cell.videoCell != nil {
                            if cell.videoCell!.isPlaying {
                                cell.stopPlayer()
                                LogClass.debugLog("Release player 6")
                                MediaManager.sharedInstance.player?.pause()
                                MediaManager.sharedInstance.releasePlayer()
                            }
                        }
                    }
                case FeedType.audio.rawValue:
                    
                    if cell is NewAudioFeedCell {
                        let cell = cell as! NewAudioFeedCell
                        cell.stopPlayer()
                    }
                case FeedType.post.rawValue:
                    if cell is PostCell {
                        let cell = cell as! PostCell
                        if  let xqPlayer = cell.commentViewRef.xqAudioPlayer {
                            xqPlayer.resetXQPlayer()
                        }
                        cell.commentViewRef.audioRecorderObj?.doResetRecording()
                    }
                case FeedType.file.rawValue:
                    if cell is AttachmentCell {
                        let cell = cell as! AttachmentCell
                        if  let xqPlayer = cell.commentViewRef.xqAudioPlayer {
                            xqPlayer.resetXQPlayer()
                        }
                        cell.commentViewRef.audioRecorderObj?.doResetRecording()
                    }
                case FeedType.gallery.rawValue:
                    if cell is NewGalleryFeedCell {
                        let cell = cell as! NewGalleryFeedCell
                        cell.stopPlayer()
                    }
                case FeedType.image.rawValue:
                    if cell is ImageCellSingle {
                        let cell = cell as! ImageCellSingle
                        
                    }
                case FeedType.shared.rawValue:
                    if cell is SharedCell {
                        let cell = cell as! SharedCell
                        if  let xqPlayer = cell.commentViewRef.xqAudioPlayer {
                            xqPlayer.resetXQPlayer()
                        }
                        cell.resetSharedElements()
                        cell.commentViewRef.audioRecorderObj?.doResetRecording()
                    }
                default:
                    LogClass.debugLog("Case not deailing.")
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if self.parentView.otherUserID.count > 0 {
                return 5
            }
            return 4
        }
        if self.selectedTab == .friends {
            return self.arrayContactGroupSearch.count + 1
        }
        if self.selectedTab == .timeline {
            if self.feedArray.count == 0 {
                
                if self.isFeedAPICall {
                    return 3
                }else {
                    return 1
                }
                
            }
            
            
            if self.feedArray.count > 0 {
                return self.feedArray.count
            }
            
            
            
            return 1
        } else if self.selectedTab == .photos || self.selectedTab == .videos ||
                    self.selectedTab == .myReels || self.selectedTab == .savedReels {
            return 1
        }
        return self.arrayBottom.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            if indexPath.row == 0 {
                return self.ProfileImageHeaderCell(tableView: tableView, cellForRowAt: indexPath)
            } else  if indexPath.row == 1 {
                return self.ProfileUserNameCell(tableView: tableView, cellForRowAt: indexPath)
            } else  if indexPath.row == 2 {
                if self.parentView.otherUserID.count > 0 {
                    return self.ProfileFriendStatusCell(tableView: tableView, cellForRowAt: indexPath)
                } else {
                    return self.ProfileUserTabCell(tableView: tableView, cellForRowAt: indexPath)
                }
            } else {
                if self.parentView.otherUserID.count > 0 && indexPath.row == 3 {
                    return self.ProfileUserTabCell(tableView: tableView, cellForRowAt: indexPath)
                }
                guard let cell = tableView.dequeueReusableCell(withIdentifier: AdCell.identifier, for: indexPath) as? AdCell else {
                    return UITableViewCell()
                }
                
                cell.bannerView.rootViewController = self.parentView
                return cell
            }
        }
        
        if selectedTab == .friends {
            if self.arrayContactGroup.count == 0 {
                return self.NoRecordFound(tableView: tableView, cellForRowAt: indexPath)
            } else if indexPath.row == 0 {
                return ProfileSearchContactsCell(tableView: tableView, cellForRowAt: indexPath)
            } else {
                return ProfileContactCell(tableView: tableView, cellForRowAt: indexPath)
            }
            
        } else if selectedTab == .videos {
            if self.arrayVideo.count == 0 {
                return self.NoRecordFound(tableView: tableView, cellForRowAt: indexPath)
            }else {
                return ProfileImageCell(tableView: tableView, cellForRowAt: indexPath)
            }
        } else if selectedTab == .photos {
            if self.arrayImage.count == 0 {
                return self.NoRecordFound(tableView: tableView, cellForRowAt: indexPath)
            } else {
                return ProfileImageCell(tableView: tableView, cellForRowAt: indexPath)
            }
        } else if selectedTab == .myReels {
            if self.myReelsList.count == 0 {
                return self.NoRecordFound(tableView: tableView, cellForRowAt: indexPath)
            } else {
                return getReelTabCell(tableView: tableView, cellForRowAt: indexPath)
            }
        } else if selectedTab == .savedReels {
            if self.savedReelsList.count == 0 {
                return self.NoRecordFound(tableView: tableView, cellForRowAt: indexPath)
            } else {
                return getReelTabCell(tableView: tableView, cellForRowAt: indexPath)
            }
        } else if self.selectedTab == .aboutMe {
            let type = self.arrayBottom[indexPath.row]["Type"]
            if type == "2" {
                return self.ProfileUserBasicinfoCell(tableView: tableView, cellForRowAt: indexPath)
            } else if type == "602" { // relationship
                return self.RelationshipDetailInfoCell(tableView: tableView, cellForRowAt: indexPath)
            } else if type == "603" { // family relationship
                return self.FamilyRelationshipDetailInfoCell(tableView: tableView, cellForRowAt: indexPath)
            } else if type == "604" { // Website
                return self.WebsiteDetailInfoCell(tableView: tableView, cellForRowAt: indexPath)
            } else if type == "605" { // Currency
                return self.CurrencyDetailInfoCell(tableView: tableView, cellForRowAt: indexPath)
            } else if type == "606" { // Life Event
                return self.LifeEventCell(tableView: tableView, cellForRowAt: indexPath)
            }
            else if type == "3" {
                return self.ProfileUserHeadingCell(tableView: tableView, cellForRowAt: indexPath)
            } else if type == "100" {
                return self.ProfileDetailInfoCell(tableView: tableView, cellForRowAt: indexPath)
            }else if type == "601" {
                return self.WorkDetailInfoCell(tableView: tableView, cellForRowAt: indexPath)
            }else if type == "1001" {
                return self.EduDetailInfoCell(tableView: tableView, cellForRowAt: indexPath)
            }else if type == "701" {
                return self.PlaceDetailInfoCell(tableView: tableView, cellForRowAt: indexPath)
            }else if type == "101" {
                return self.ProfileDetailAddInfoCell(tableView: tableView, cellForRowAt: indexPath)
            }else if type == "501" {
                return self.PlaceDetailInfoOverviewCell(tableView: tableView, cellForRowAt: indexPath)
            }else if type == "901" {
                return self.ProfileUserinfoInterestCell(tableView: tableView, cellForRowAt: indexPath)
            } else if type == "1100" {
                return self.CategoryLikeCell(tableView: tableView, cellForRowAt: indexPath)
            } else if type == "1200" {
                return self.ProfileGroupCell(tableView: tableView, cellForRowAt: indexPath)
            }
            return self.ProfileUserinfoCell(tableView: tableView, cellForRowAt: indexPath)
        }
        
        if self.feedArray.count == 0 && !isFeedAPICall {
            let cellinfo = tableView.dequeueReusableCell(withIdentifier: "ProfileInfoTextCell", for: indexPath) as! ProfileInfoTextCell
            cellinfo.lblInfo.text = "No post found".localized()
            return cellinfo
        } else if self.feedArray.count == 0 {
            let cellShimmerAd = tableView.dequeueReusableCell(withIdentifier: "ShimmerPostCell", for: indexPath) as! ShimmerPostCell
            cellShimmerAd.startShimmer()
            cellShimmerAd.selectionStyle = .none
            return cellShimmerAd
        }
        if self.feedArray.count > 0 {
            let feedObj:FeedData = self.feedArray[indexPath.row] as FeedData
            var feedCell:FeedParentCell? = nil
            
            switch feedObj.postType! {
                
            case FeedType.Ad.rawValue:
                if let cell = tableView.dequeueReusableCell(withIdentifier: AdCell.identifier, for: indexPath) as? AdCell {
                    
                    DispatchQueue.main.async {
                        cell.bannerView.rootViewController = self.parentView
                    }
                    
                    cell.lblLoading.rotateViewForLanguage()
                    cell.reloadData(parentview: self.parentView ,indexMain: indexPath)
                    
                    return cell
                }
                
            case FeedType.post.rawValue:
                if let cellText = tableView.dequeueReusableCell(withIdentifier: "NewTextFeedCell", for: indexPath) as? NewTextFeedCell {
                    cellText.postObj = feedObj
                    cellText.indexPathMain = indexPath
                    cellText.reloadData()
                    cellText.tblViewImg.invalidateIntrinsicContentSize()
                    cellText.cellDelegate = self
                    cellText.rotateViewForLanguage()
                    cellText.isFromProfile = true
                    self.isFeedReachEnd(indexPath: indexPath)
                    return cellText
                }
                
            case FeedType.audio.rawValue:
                if let cellVideo = tableView.dequeueReusableCell(withIdentifier: "NewAudioFeedCell", for: indexPath) as? NewAudioFeedCell {
                    cellVideo.postObj = feedObj
                    cellVideo.indexPathMain = indexPath
                    cellVideo.reloadData()
                    cellVideo.tblViewImg.invalidateIntrinsicContentSize()
                    cellVideo.cellDelegate = self
                    cellVideo.rotateViewForLanguage()
                    cellVideo.isFromProfile = true
                    self.isFeedReachEnd(indexPath: indexPath)
                    return cellVideo
                }
                
            case FeedType.video.rawValue , FeedType.liveStream.rawValue :
                if let cellVideo = tableView.dequeueReusableCell(withIdentifier: "NewVideoFeedCell", for: indexPath) as? NewVideoFeedCell {
                    cellVideo.postObj = feedObj
                    cellVideo.parentTblView = tableView
                    cellVideo.indexPathMain = indexPath
                    cellVideo.reloadData()
                    cellVideo.tblViewImg.invalidateIntrinsicContentSize()
                    cellVideo.cellDelegate = self
                    cellVideo.rotateViewForLanguage()
                    self.isFeedReachEnd(indexPath: indexPath)
                    cellVideo.isFromProfile = true
                    return cellVideo
                }
            case FeedType.image.rawValue:
                if let cellImage = tableView.dequeueReusableCell(withIdentifier: "NewImageFeedCell", for: indexPath) as? NewImageFeedCell {
                    cellImage.postObj = feedObj
                    cellImage.indexPathMain = indexPath
                    cellImage.reloadData()
                    cellImage.tblViewImg.invalidateIntrinsicContentSize()
                    cellImage.cellDelegate = self
                    cellImage.rotateViewForLanguage()
                    cellImage.isFromProfile = true
                    self.isFeedReachEnd(indexPath: indexPath)
                    return cellImage
                }
                
            case FeedType.file.rawValue:
                if let cellAttachment = tableView.dequeueReusableCell(withIdentifier: "NewAttachmentFeedCell", for: indexPath) as? NewAttachmentFeedCell {
                    cellAttachment.postObj = feedObj
                    cellAttachment.indexPathMain = indexPath
                    cellAttachment.reloadData()
                    cellAttachment.tblViewImg.invalidateIntrinsicContentSize()
                    cellAttachment.cellDelegate = self
                    cellAttachment.rotateViewForLanguage()
                    cellAttachment.isFromProfile = true
                    self.isFeedReachEnd(indexPath: indexPath)
                    return cellAttachment
                }
                
            case FeedType.gallery.rawValue:
                
                if let cellGallery = tableView.dequeueReusableCell(withIdentifier: "NewGalleryFeedCell", for: indexPath) as? NewGalleryFeedCell {
                    cellGallery.postObj = feedObj
                    cellGallery.indexPathMain = indexPath
                    cellGallery.reloadData()
                    cellGallery.tblViewImg.invalidateIntrinsicContentSize()
                    cellGallery.cellDelegate = self
                    cellGallery.isFromProfile = true
                    cellGallery.rotateViewForLanguage()
                    self.isFeedReachEnd(indexPath: indexPath)
                    return cellGallery
                }
                
            case FeedType.shared.rawValue:
                
                if let cellShared = tableView.dequeueReusableCell(withIdentifier: "NewSharedFeedCell", for: indexPath) as? NewSharedFeedCell {
                    cellShared.postObj = feedObj
                    cellShared.indexPathMain = indexPath
                    cellShared.reloadData()
                    cellShared.isFromProfile = true
                    cellShared.tblViewImg.invalidateIntrinsicContentSize()
                    cellShared.cellDelegate = self
                    cellShared.rotateViewForLanguage()
                    self.isFeedReachEnd(indexPath: indexPath)
                    return cellShared
                }
                
            default:
                LogClass.debugLog("Feed type missing.")
            }
            
            self.isFeedReachEnd(indexPath: indexPath)
            if feedCell != nil {
                return feedCell!
            }
        } else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: SkeletonCell.identifier, for: indexPath) as? SkeletonCell{
                return cell
            }
        }
        return UITableViewCell()
    }
    
    @objc func openUSerProfileAction(sender : UIButton){
        let vcProfile = AppStoryboard.PostStoryboard.instance.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        vcProfile.otherUserID = String(sender.tag)
        vcProfile.otherUserisFriend = "1"
        vcProfile.isNavPushAllow = true
        self.parentView.navigationController!.pushViewController(vcProfile, animated: true)
    }
    
    @objc func DownloadImage(sender : UIButton){
        let postFile:PostFile = self.feedArray[sender.tag].post![0]
        self.parentView.downloadFile(filePath: postFile.filePath!, isImage: true, isShare: true , FeedObj: self.feedArray[sender.tag])
    }
    
    @objc func DownloadVideo(sender : UIButton){
        let postFile:PostFile = self.feedArray[sender.tag].post![0]
        self.parentView.downloadFile(filePath: postFile.filePath!, isImage: false, isShare: true , FeedObj: self.feedArray[sender.tag])
    }
    
    func PlaceDetailInfoOverviewCell(tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cellDetail = tableView.dequeueReusableCell(withIdentifier: "ProfilePlaceDetailInfoCell", for: indexPath) as? ProfilePlaceDetailInfoCell else {
            return UITableViewCell()
        }
        cellDetail.lblCompanyName.text = self.arrayBottom[indexPath.row]["Text"]!
        cellDetail.lblDesignation.text = self.arrayBottom[indexPath.row]["Heading"]!
        
        self.parentView.view.labelRotateCell(viewMain: cellDetail.lblDesignation)
        cellDetail.lblDesignation.rotateForTextAligment()
        
        self.parentView.view.labelRotateCell(viewMain: cellDetail.lblCompanyName)
        cellDetail.lblCompanyName.rotateForTextAligment()
        
        cellDetail.viewEdit.isHidden = true
        cellDetail.selectionStyle = .none
        return cellDetail
    }
    
    func showShareOption(valueIndex : Int) {
        
        let feedObj = self.feedArray[valueIndex] as FeedData
        
        //        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // your code here
            
            do {
                let imageData = try Data(contentsOf: URL.init(string: (feedObj.post?.first!.filePath)!)!)
                
                let activityViewController = UIActivityViewController(activityItems: [ imageData], applicationActivities: nil)
                activityViewController.excludedActivityTypes = SharedManager.shared.excludingArray
                self.parentView.present(activityViewController, animated: true) {
                    //                    SharedManager.shared.hideLoadingHubFromKeyWindow()
                    Loader.stopLoading()
                }
                
            } catch {
                
            }
        }
    }
    
    @objc func openMessage(sender: UIButton) {
        Loader.startLoading()
        let userToken = SharedManager.shared.userToken()
        let ObjUser = self.parentView.otherUserID
        let memberID:[String] = [ObjUser]
        let parameters: NSDictionary = ["action": "conversation/create",
                                        "token":userToken,
                                        "serviceType":"Node",
                                        "conversation_type":"single",
                                        "member_ids": memberID]
        RequestManager.fetchDataPost(Completion: { response in
            //            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            switch response {
            case .failure(let error):
                SwiftMessages.apiServiceError(error: error)
            case .success(let res):
                
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                } else if res is String {
                    SharedManager.shared.showAlert(message: res as! String, view: self.parentView)
                } else {
                    if res is NSDictionary {
                        let dict = res as! NSDictionary
                        let conversationID = self.parentView.ReturnValueCheck(value: dict["conversation_id"] as Any)
                        
                        let moc = CoreDbManager.shared.persistentContainer.viewContext
                        let objModel = Chat(context: moc)
                        objModel.profile_image = self.parentView.otherUserObj.profileImage
                        objModel.member_id = self.parentView.otherUserObj.id
                        objModel.name = self.parentView.otherUserObj.firstname
                        objModel.latest_conversation_id = conversationID
                        objModel.conversation_id = conversationID
                        objModel.conversation_type = "single"
                        
                        let contactGroup = AppStoryboard.PostStoryboard.instance.instantiateViewController(withIdentifier: Const.ChatViewController) as! ChatViewController
                        contactGroup.conversatonObj = objModel
                        self.parentView.navigationController?.pushViewController(contactGroup, animated: true)
                        
                    }
                }
            }
        }, param:parameters as! [String : Any])
    }
    
    @objc func friendAction(sender : UIButton){
        
        if  self.parentView.otherUserObj.is_friend == "1" {
            DeleteUserAction()
        }else {
            
            if self.parentView.otherUserObj.is_friend != nil {
                if self.parentView.otherUserObj.has_sent_req == "1" {
                    //                    SharedManager.shared.showAlert(message: "Request already sent".localized(), view: self.parentView)
                    
                    SharedManager.shared.ShowAlertWithCompletaion(message: "Your Request is Pending. Do you want to cancel it?".localized(), isError: false,DismissButton: "OK".localized(),AcceptButton: "Cancel Request".localized()) { status in
                        print("status ===>")
                        print(status)
                        if status {
                            self.cancelFriendAction()
                        }
                    }
                    return
                    
                    
                } else if self.parentView.otherUserObj.is_friend == "1" {
                    DeleteUserAction()
                } else if self.parentView.otherUserObj.is_friend == "1" {
                    //                    SharedManager.shared.showAlert(message: "Request already sent".localized(), view: self.parentView)
                    
                    SharedManager.shared.ShowAlertWithCompletaion(message: "Your Request is Pending. Do you want to cancel it?".localized(), isError: false,DismissButton: "OK".localized(),AcceptButton: "Cancel Request".localized()) { status in
                        print("status ===>")
                        print(status)
                        if status {
                            self.cancelFriendAction()
                        }
                    }
                    return
                    
                    
                } else {
                    sendRequest()
                }
            }
        }
    }
    
    func cancelFriendAction(){
        
        Loader.startLoading()
        let parameters = ["action": "user/cancel_friend_request","token": SharedManager.shared.userToken() , "user_id" : String(self.parentView.otherUserObj.id)]
        
        RequestManager.fetchDataPost(Completion: { (response) in
            Loader.stopLoading()
            switch response {
            case .failure(let error):
                SwiftMessages.apiServiceError(error: error)
            case .success(let res):
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                } else {
                    
                    self.parentView.otherUserisFriend = ""
                    self.parentView.otherUserObj.has_sent_req = ""
                    self.parentView.profileTableView.reloadData()
                    //                } else if let newRes = res as? String {
                    //                    SharedManager.shared.showAlert(message: newRes, view: self.parentView)
                }
            }
        }, param: parameters)
    }
    
    
    func sendRequest() {
        
        //        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        let parameters = ["action": "user/send_friend_request",
                          "token": SharedManager.shared.userToken() ,
                          "user_id" : self.parentView.otherUserID]
        
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
                    
                    self.parentView.otherUserisFriend = ""
                    self.parentView.otherUserObj.has_sent_req = "1"
                    SharedManager.shared.showAlert(message: "Friend Request Sent".localized(), view: self.parentView)
                    self.parentView.profileTableView.reloadData()
                } else if let newRes = res as? String {
                    SharedManager.shared.showAlert(message: newRes, view: self.parentView)
                }
            }
        }, param: parameters)
        //        }
    }
    
    func DeleteUserAction() {
        self.parentView.ShowAlertWithCompletaion(message: "Are you sure to remove this contact from your contacts list?".localized()) { (status) in
            if status {
                
                let userToken = SharedManager.shared.userToken()
                let parameters = ["action": "contacts/remove_contact","token": userToken , "friend_id" : self.parentView.otherUserID]
                //                SharedManager.shared.showOnWindow()
                Loader.startLoading()
                RequestManager.fetchDataPost(Completion: { response in
                    //                    SharedManager.shared.hideLoadingHubFromKeyWindow()
                    Loader.stopLoading()
                    switch response {
                    case .failure(let error):
                        SwiftMessages.apiServiceError(error: error)
                    case .success(let res):
                        if res is Int {
                            AppDelegate.shared().loadLoginScreen()
                        }else if res is String {
                            
                        } else {
                            
                            self.parentView.otherUserObj.is_friend = ""
                            self.parentView.otherUserisFriend = ""
                            self.parentView.profileTableView.reloadData()
                        }
                    }
                }, param:parameters)
            }
        }
    }
    
    @objc func searchBtnClicked(sender: Any) {
        let controller = GlobalSearchViewController.instantiate(fromAppStoryboard: .EditProfile)
        self.parentView.navigationController?.pushViewController(controller, animated: false)
    }
    
    @objc func languageAction(sender : UIButton){
        if viewLanguage == nil {
            self.viewLanguage = Bundle.main.loadNibNamed("LanguagePopUpVC", owner: self, options: nil)?.first as? LanguagePopUpVC
        }
        
        viewLanguage.frame = self.parentView.view.frame
        viewLanguage.resetHandler()
        viewLanguage.parentView = self.parentView
        let window = UIApplication.shared.keyWindow
        window?.addSubview(self.viewLanguage)
        self.viewLanguage.center = self.parentView.view.center
    }
    
    @objc func backAction(sender : UIButton){
        backTappedCompletion?(sender)
    }
    
    func ProfileImageHeaderCell(tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cellHeader = tableView.dequeueReusableCell(withIdentifier: "ProfileNewImageHeaderCell", for: indexPath) as? ProfileNewImageHeaderCell else {
            return UITableViewCell()
        }
        
        cellHeader.viewAddMessage.isHidden = true
        cellHeader.viewAddUSer.isHidden = true
        
        cellHeader.btnAddMessage.addTarget(self, action: #selector(self.openMessage), for: .touchUpInside)
        cellHeader.btnAddUSer.addTarget(self, action: #selector(self.friendAction), for: .touchUpInside)
        cellHeader.viewlanguage.isHidden = false
        if self.parentView.otherUserID.count > 0 {
            cellHeader.cstwidth.constant = 50.0
            cellHeader.cstBackwidth.constant = 50.0
            cellHeader.viewlanguage.isHidden = true
            cellHeader.viewMore.isHidden = false
            cellHeader.viewBack.isHidden = false
            cellHeader.viewBanner.isHidden = true
            cellHeader.viewProfile.isHidden = true
            cellHeader.viewDelete.isHidden = true
            
            if self.parentView.otherUserSearchObj != nil {
                if self.parentView.otherUserSearchObj.is_my_friend == "1" {
                    cellHeader.imgViewAddUSer.image = UIImage.init(named: "ProfileAddedNew.png")
                    cellHeader.viewAddUSer.isHidden = false
                    cellHeader.viewAddMessage.isHidden = false
                }else if self.parentView.otherUserSearchObj.already_sent_friend_req == "1" {
                    cellHeader.imgViewAddUSer.image = UIImage.init(named: "ProfileAddNew.png")
                    cellHeader.viewAddUSer.isHidden = false
                }else {
                    cellHeader.imgViewAddUSer.image = UIImage.init(named: "ProfileAddNew.png")
                    cellHeader.viewAddUSer.isHidden = false
                }
            }else{
                if self.parentView.otherUserID.count > 0 {
                    
                    if self.parentView.otherUserObj.has_sent_req == "1" {
                        cellHeader.imgViewAddUSer.image = UIImage.init(named: "ProfileAddedNew.png")
                        cellHeader.viewAddMessage.isHidden = true
                    }else if self.parentView.otherUserisFriend == "1" {
                        cellHeader.imgViewAddUSer.image = UIImage.init(named: "ProfileAddedNew.png")
                        cellHeader.viewAddUSer.isHidden = false
                        cellHeader.viewAddMessage.isHidden = false
                    }else {
                        cellHeader.imgViewAddUSer.image = UIImage.init(named: "ProfileAddNew.png")
                        cellHeader.viewAddUSer.isHidden = false
                    }
                }else {
                    cellHeader.imgViewAddUSer.image = UIImage.init(named: "ProfileAddNew.png")
                    cellHeader.viewAddUSer.isHidden = false
                }
            }
            
            
            cellHeader.imgViewBanner.loadImageWithPH(urlMain:self.parentView.otherUserObj.coverImage)
            
            self.parentView.view.labelRotateCell(viewMain: cellHeader.imgViewBanner)
            cellHeader.imgViewProfile.loadImageWithPH(urlMain:self.parentView.otherUserObj.profileImage)
            
            self.parentView.view.labelRotateCell(viewMain: cellHeader.imgViewProfile)
            
        } else {
            // cellHeader.viewBack.isHidden = true
            cellHeader.viewMore.isHidden = true
            cellHeader.cstwidth.constant = 0.0
            cellHeader.viewBanner.isHidden = false
            cellHeader.viewProfile.isHidden = false
            cellHeader.viewDelete.isHidden = false
            
            if FileBasedManager.shared.fileExist(nameFile: fileNameCover).1 {
                cellHeader.imgViewBanner.image = FileBasedManager.shared.loadImage(pathMain: fileNameCover)
            } else {
                if self.parentView.otherUserObj.coverImage.isEmpty {
                    if let isUserObj = SharedManager.shared.getProfile() {
                        cellHeader.imgViewBanner.imageLoad(with: isUserObj.data.cover_image)
                    }
                } else {
                    cellHeader.imgViewBanner.loadImageWithPH(urlMain:self.parentView.otherUserObj.coverImage)
                }
            }
            
            
            if FileBasedManager.shared.fileExist(nameFile: fileName).1 {
                cellHeader.imgViewProfile.image = FileBasedManager.shared.loadImage(pathMain: fileName)
            }else {
                if self.parentView.otherUserObj.profileImage.isEmpty {
                    if let isUserObj = SharedManager.shared.getProfile() {
                        cellHeader.imgViewProfile.imageLoad(with: isUserObj.data.profile_image)
                    }
                } else {
                    cellHeader.imgViewProfile.loadImageWithPH(urlMain:self.parentView.otherUserObj.profileImage)
                }
            }
            
            
            self.parentView.view.labelRotateCell(viewMain: cellHeader.imgViewBanner)
            self.parentView.view.labelRotateCell(viewMain: cellHeader.imgViewProfile)
        }
        
        cellHeader.viewDelete.isHidden = true
        cellHeader.btnSearch.addTarget(self, action: #selector(self.searchBtnClicked), for: .touchUpInside)
        cellHeader.btnBack.addTarget(self, action: #selector(self.backAction), for: .touchUpInside)
        cellHeader.btnViewLanguage.addTarget(self, action: #selector(self.languageAction), for: .touchUpInside)
        
        cellHeader.btnMore.addTarget(self, action: #selector(self.moreOptionShow), for: .touchUpInside)
        cellHeader.btnViewCoverPhoto.addTarget(self, action: #selector(self.viewCoverPhoto), for: .touchUpInside)
        cellHeader.btnViewProfilePhoto.addTarget(self, action: #selector(self.viewProfilePhoto), for: .touchUpInside)
        
        cellHeader.btnCoverPhoto.addTarget(self, action: #selector(self.CoverAction), for: .touchUpInside)
        cellHeader.btnProfilePhoto.addTarget(self, action: #selector(self.ProfileAction), for: .touchUpInside)
        cellHeader.btnDelete.addTarget(self, action: #selector(self.profileDeleteAction), for: .touchUpInside)
        
        cellHeader.btnUpload.addTarget(self, action: #selector(self.uploadAction), for: .touchUpInside)
        
        self.parentView.view.labelRotateCell(viewMain: cellHeader.imgViewLogo)
        
        
        cellHeader.viewAddUSer.isHidden = true
        if self.parentView.otherUserObj.can_i_send_fr.count > 0 {
            if self.parentView.otherUserObj.can_i_send_fr == "1" {
                cellHeader.viewAddUSer.isHidden = false
            }
        }
        
        
        //        if (self.parentView.navigationController?.viewControllers.count ?? 0) < 2 {
        //            cellHeader.viewBack.isHidden = true
        //        }
        
        
        if self.parentView.isNavigationEnable {
            cellHeader.viewBack.isHidden = false
        }else if self.parentView.otherUserID == nil || self.parentView.otherUserID.count == 0 {
            cellHeader.viewBack.isHidden = true
        }
        cellHeader.selectionStyle = .none
        return cellHeader
    }
    
    
    func hideDeletePopup() {
        let cellMain = self.parentView.profileTableView.cellForRow(at: IndexPath.init(row: 0, section: 0)) as! ProfileNewImageHeaderCell
        cellMain.viewDelete.isHidden = true
        
    }
    
    @objc func uploadAction(sender : UIButton){
        self.hideDeletePopup()
        self.isCoverPhoto = 2
        self.openPhotoPicker(maxValue: 1)
    }
    
    @objc func profileDeleteAction(sender : UIButton) {
        self.hideDeletePopup()
        //        SDImageCache.shared.clearMemory()
        //        SDImageCache.shared.clearDisk()
        
        let cellMain = self.parentView.profileTableView.cellForRow(at: IndexPath.init(row: 0, section: 0)) as! ProfileNewImageHeaderCell
        cellMain.imgViewProfile.image = UIImage.init(named: "placeholder.png")
        
        //        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        let parameters = ["action": "profile/remove_profile_picture","token": SharedManager.shared.userToken()]
        
        RequestManager.fetchDataPost(Completion: { (response) in
            //            SharedManager.shared.hideLoadingHubFromKeyWindow()
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
                
                //
                if let mainResult = res as? [String : Any] {
                    
                    //  if let mainData = mainResult["data"] as? [String : Any] {
                    
                    
                    if let mainfile = mainResult["profile_image"] as? String{
                        if self.imageType == "cover_image" {
                            SharedManager.shared.userObj!.data.cover_image = mainfile
                            SharedManager.shared.userEditObj.coverImage = mainfile
                        }else {
                            SharedManager.shared.userObj!.data.profile_image = mainfile
                            SharedManager.shared.downloadUserImage(imageUrl: mainfile)
                            let cellMain = self.parentView.profileTableView.cellForRow(at: IndexPath.init(row: 0, section: 0)) as! ProfileNewImageHeaderCell
                            //                                cellMain.imgViewProfile.sd_setImage(with: URL(string: mainfile), placeholderImage: UIImage(named: "placeholder.png"))
                            
                            cellMain.imgViewProfile.loadImageWithPH(urlMain:mainfile)
                            
                            SharedManager.shared.userEditObj.profileImage = mainfile
                        }
                    }
                    
                    self.imageType = ""
                    SocketSharedManager.sharedSocket.updateUserProfile(dictionary: mainResult )
                }
                
                if (res as? [String : Any]) != nil {
                    SocketSharedManager.sharedSocket.updateUserProfile(dictionary: res as! [String : Any])
                }
                
            }
        }, param: parameters)
    }
    
    @objc func moreOptionShow(sender : UIButton){
        let reportController = AppStoryboard.TabBar.instance.instantiateViewController(withIdentifier: "ReportingViewController") as! ReportingViewController
        reportController.delegate = self.parentView
        if self.parentView.otherUserObj.is_blocked_by_me == "1" {
            reportController.reportType = "BlockUser"
        }else {
            reportController.reportType = "User"
        }
        
        self.parentView.sheetController = SheetViewController(controller: reportController, sizes: [.fixed(300)])
        self.parentView.sheetController.overlayColor = UIColor.black.withAlphaComponent(0.3)
        self.parentView.sheetController.extendBackgroundBehindHandle = true
        self.parentView.sheetController.topCornersRadius = 20
        self.parentView.present(self.parentView.sheetController, animated: false, completion: nil)
    }
    
    @objc func viewCoverPhoto() {
        self.hideDeletePopup()
        var images = [SKPhoto]()
        
        if self.parentView.otherUserID.count > 0 {
            
            let photo = SKPhoto.photoWithImageURL(self.parentView.otherUserObj.coverImage)// add some UIImage
            photo.shouldCachePhotoURLImage = true
            images.append(photo)
            
            
        }else {
            let photo = SKPhoto.photoWithImageURL(SharedManager.shared.userEditObj.coverImage)// add some UIImage
            photo.shouldCachePhotoURLImage = true
            images.append(photo)
        }
        
        let browser = SKPhotoBrowser(photos: images)
        SKPhotoBrowserOptions.displayAction = false
        
        self.parentView.present(browser, animated: true, completion: {})
    }
    
    @objc func viewProfilePhoto(){
        var images = [SKPhoto]()
        self.hideDeletePopup()
        
        if self.parentView.otherUserID.count > 0 {
            
            let photo = SKPhoto.photoWithImageURL(self.parentView.otherUserObj.profileImage)// add some UIImage
            photo.shouldCachePhotoURLImage = true
            images.append(photo)
            
        }else {
            let photo = SKPhoto.photoWithImageURL(SharedManager.shared.userEditObj.profileImage)// add some UIImage
            photo.shouldCachePhotoURLImage = true
            images.append(photo)
        }
        
        let browser = SKPhotoBrowser(photos: images)
        SKPhotoBrowserOptions.displayAction = false
        
        self.parentView.present(browser, animated: true, completion: {})
    }
    
    @objc func CoverAction() {
        self.hideDeletePopup()
        self.isCoverPhoto = 1
        self.openPhotoPicker(maxValue: 1)
    }
    
    @objc func ProfileAction(sender : UIButton) {
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
    
    func ProfileFriendStatusCell(tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cellUserName = tableView.dequeueReusableCell(withIdentifier: "ProfileFriendStatusCell", for: indexPath) as? ProfileFriendStatusCell else {
            return UITableViewCell()
        }
        cellUserName.viewMessage.isHidden = true
        if self.parentView.otherUserSearchObj != nil {
            if self.parentView.otherUserSearchObj.is_my_friend == "1" {
                cellUserName.viewMessage.isHidden = false
                cellUserName.imgViewRequest.image = UIImage.init(named: "Icon-Accept.png")
            }else if self.parentView.otherUserSearchObj.already_sent_friend_req == "1" {
                cellUserName.imgViewRequest.image = UIImage.init(named: "Icon-Request.png")
            }else {
                cellUserName.imgViewRequest.image = UIImage.init(named: "Icon-AddFriend.png")
            }
        } else {
            if self.parentView.otherUserID.count > 0 {
                
                if self.parentView.otherUserObj.has_sent_req == "1" {
                    cellUserName.imgViewRequest.image = UIImage.init(named: "Icon-Request.png")
                }else if self.parentView.otherUserisFriend == "1" {
                    cellUserName.imgViewRequest.image = UIImage.init(named: "Icon-Accept.png")
                    cellUserName.viewMessage.isHidden = false
                }else {
                    cellUserName.imgViewRequest.image = UIImage.init(named: "Icon-AddFriend.png")
                    
                }
            }else {
                cellUserName.viewMessage.isHidden = true
                cellUserName.viewMore.isHidden = true
                cellUserName.viewRequest.isHidden = true
            }
        }
        
        cellUserName.btnMore.addTarget(self, action: #selector(self.moreOptionShow), for: .touchUpInside)
        
        cellUserName.btnMessage.addTarget(self, action: #selector(self.openMessage), for: .touchUpInside)
        cellUserName.btnRequest.addTarget(self, action: #selector(self.friendAction), for: .touchUpInside)
        
        self.parentView.view.labelRotateCell(viewMain: cellUserName.viewMessage)
        self.parentView.view.labelRotateCell(viewMain: cellUserName.viewRequest)
        
        return cellUserName
    }
    
    func ProfileUserNameCell(tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cellUserName = tableView.dequeueReusableCell(withIdentifier: "ProfileUserNameCell", for: indexPath) as? ProfileUserNameCell else {
            return UITableViewCell()
        }
        cellUserName.btnName.tag = indexPath.row
        if self.parentView.otherUserID.count > 0 {
            cellUserName.lblName.text = self.parentView.otherUserObj.firstname + " " + self.parentView.otherUserObj.lastname
        } else {
            cellUserName.lblName.text = SharedManager.shared.userEditObj.firstname + " " + SharedManager.shared.userEditObj.lastname
            cellUserName.btnName.addTarget(self, action: #selector(self.nameChangeAction), for: .touchUpInside)
        }
        
        self.parentView.view.labelRotateCell(viewMain: cellUserName.lblName)
        
        cellUserName.selectionStyle = .none
        return cellUserName
    }
    
    
    func NoRecordFound(tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cellUserName = tableView.dequeueReusableCell(withIdentifier: "AllCompetitionHeadingCell", for: indexPath) as? AllCompetitionHeadingCell else {
            return UITableViewCell()
        }
        
        cellUserName.lblInfo.text = "No post found".localized()
        cellUserName.lblInfo.textAlignment = .center
        self.parentView.view.labelRotateCell(viewMain: cellUserName.lblInfo)
        cellUserName.viewBG.backgroundColor = UIColor.clear
        
        cellUserName.selectionStyle = .none
        return cellUserName
    }
    
    
    @objc func nameChangeAction(sender : UIButton){
        self.showEditBasicInfo()
    }
    
    @objc func showEditLocaiton(sender : UIButton){
        if self.parentView.otherUserID.count > 0 {
            
        }else {
            (self.parentView as ProfileViewController).editProfileLocationVc.reloadView(type: Int(self.arrayBottom[sender.tag]["id"]!)!)
            (self.parentView as ProfileViewController).isNavPushAllow = false
            UIApplication.shared.keyWindow!.addSubview((self.parentView as ProfileViewController).editProfileLocationVc.view)
        }
    }
    
    @objc func showEditBasicInfo() {
        (self.parentView as ProfileViewController).isNavPushAllow = false
        UIApplication.shared.keyWindow!.addSubview((self.parentView as ProfileViewController).editProfileVc.view)
    }
    
    @objc func designationChangeAction(sender : UIButton){
        self.showEditBasicInfo()
    }
    
    func ProfileUserTabCell(tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cellUserTab = tableView.dequeueReusableCell(withIdentifier: "ProfileSectionTableViewCell", for: indexPath) as? ProfileSectionTableViewCell else {
            return UITableViewCell()
        }
        
        if self.selectedTab == .timeline {
            cellUserTab.selectedTab = .timeline
        }
        
        if parentView.otherUserID.count > 0 {
            cellUserTab.bind(delegate: self, isItMyProfile: false) // not my profile
        } else {
            cellUserTab.bind(delegate: self, isItMyProfile: true)
        }
        //        paggingAPICall(indexPathMain: indexPath)
        
        // old code
        //        cellUserTab.selectOverView(value: self.selectedTab.rawValue)
        
        //        self.parentView.view.labelRotateCell(viewMain: cellUserTab.lblNews)
        //        cellUserTab.lblNews.rotateForTextAligment()
        
        //        self.parentView.view.labelRotateCell(viewMain: cellUserTab.lblPhotos)
        //        cellUserTab.lblPhotos.rotateForTextAligment()
        
        //        self.parentView.view.labelRotateCell(viewMain: cellUserTab.lblVideos)
        //        cellUserTab.lblVideos.rotateForTextAligment()
        
        //        self.parentView.view.labelRotateCell(viewMain: cellUserTab.lblReviews)
        //        cellUserTab.lblReviews.rotateForTextAligment()
        
        //        self.parentView.view.labelRotateCell(viewMain: cellUserTab.lblOverview)
        //        cellUserTab.lblOverview.rotateForTextAligment()
        
        //        cellUserTab.selectionStyle = .none
        return cellUserTab
    }
    
    
    func ProfileUserinfoCell(tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //        let cellUserTab = tableView.dequeueReusableCell(withIdentifier: "ProfileUserinfoCell", for: indexPath) as! ProfileUserinfoCell
        
        guard let cellUserTab = tableView.dequeueReusableCell(withIdentifier: "ProfileUserinfoCell", for: indexPath) as? ProfileUserinfoCell else {
            return UITableViewCell()
        }
        
        
        if self.parentView.otherUserID.count > 0 {
            cellUserTab.lblInfo.text = self.parentView.otherUserObj.aboutme
        } else {
            cellUserTab.btnAboutMe.isHidden = false
            cellUserTab.btnAboutMe.addTarget(self, action: #selector(self.aboutMeAction), for: .touchUpInside)
            
            cellUserTab.lblInfo.text = SharedManager.shared.userEditObj.aboutme
        }
        cellUserTab.lblInfo.textColor = UIColor.lightGray
        if cellUserTab.lblInfo.text == nil {
            cellUserTab.lblInfo.text = "About me .....".localized()
        }else if cellUserTab.lblInfo.text!.count == 0 {
            cellUserTab.lblInfo.text = "About me .....".localized()
        }
        self.parentView.view.labelRotateCell(viewMain: cellUserTab.lblInfo)
        cellUserTab.lblInfo.rotateForTextAligment()
        
        cellUserTab.selectionStyle = .none
        return cellUserTab
    }
    
    func LifeEventCell(tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellDetail = tableView.dequeueReusableCell(withIdentifier: "ProfileLifeEventCell", for: indexPath) as! ProfileLifeEventCell
        let index = Int(self.arrayBottom[indexPath.row]["indexObj"]!)
        if self.parentView.otherUserID.count > 0 {
            cellDetail.deleteBtn?.isHidden = true
            cellDetail.btnEventTitle?.setTitle(self.parentView.otherUserObj.userLifeEventsArray[index!].lifeEventTitle, for: .normal)
            cellDetail.eventDescriptionLabel?.text = self.parentView.otherUserObj.userLifeEventsArray[index!].lifeEventVenue
            cellDetail.dateLabel?.text = self.parentView.otherUserObj.userLifeEventsArray[index!].creationDate.suffix(4).map{String($0)}.joined()
        } else {
            cellDetail.deleteBtn?.isHidden = false
            cellDetail.deleteBtn?.tag = indexPath.row
            cellDetail.btnEventTitle?.tag = indexPath.row
            cellDetail.btnEventTitle?.setTitle(SharedManager.shared.userEditObj.userLifeEventsArray[index!].lifeEventTitle, for: .normal)
            cellDetail.eventDescriptionLabel?.text = SharedManager.shared.userEditObj.userLifeEventsArray[index!].lifeEventVenue
            cellDetail.dateLabel?.text = SharedManager.shared.userEditObj.userLifeEventsArray[index!].creationDate.suffix(4).map{String($0)}.joined()
            cellDetail.deleteBtn?.addTarget(self, action: #selector(deleteLifeEventAction), for: .touchUpInside)
            cellDetail.btnEventTitle?.addTarget(self, action: #selector(lifeEventDetailAction), for: .touchUpInside)
        }
        return cellDetail
    }
    
    @objc func lifeEventDetailAction(sender: UIButton) {
        let index = Int(self.arrayBottom[sender.tag]["indexObj"]!)
        lifeEventDetailCompletion?(2, index)
    }
    
    @objc func deleteLifeEventAction(sender: UIButton) {
        let index = Int(self.arrayBottom[sender.tag]["indexObj"]!)
        lifeEventsDeleteCompletion?(2, index)
    }
    
    func WebsiteDetailInfoCell(tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellDetail = tableView.dequeueReusableCell(withIdentifier: "ProfileWebsiteCell", for: indexPath) as! ProfileWebsiteCell
        let index = Int(self.arrayBottom[indexPath.row]["indexObj"]!)
        if self.parentView.otherUserID.count > 0 {
            cellDetail.viewEdit.isHidden = true
            cellDetail.txtLink.text = self.parentView.otherUserObj.websiteArray[index!].link
        } else {
            cellDetail.viewEdit.isHidden = false
            cellDetail.txtLink.text = SharedManager.shared.userEditObj.websiteArray[index!].link
            cellDetail.editBtn.tag = indexPath.row
            cellDetail.editBtn.addTarget(self, action: #selector(self.editAction), for: .touchUpInside)
        }
        return cellDetail
    }
    
    func RelationshipDetailInfoCell(tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellDetail = tableView.dequeueReusableCell(withIdentifier: "ProfileRelationViewCell", for: indexPath) as! ProfileRelationViewCell
        let index = Int(self.arrayBottom[indexPath.row]["indexObj"]!)
        if self.parentView.otherUserID.count > 0 {
            cellDetail.viewEdit.isHidden = true
            let firstName = self.parentView.otherUserObj.relationshipArray[index!].user?.firstname ?? .emptyString
            let lastName = self.parentView.otherUserObj.relationshipArray[index!].user?.lastname ?? .emptyString
            let fullName =  firstName + " " + lastName
            let relationStatus = self.parentView.otherUserObj.relationshipArray[index!].statusDescription
            let userName = self.parentView.otherUserObj.firstname + " " + self.parentView.otherUserObj.lastname
            let relationDate = self.parentView.otherUserObj.relationshipArray[index!].relationshipCreationDate
            cellDetail.lblName.text = relationStatus == "Single" ? userName : fullName
            let statusDetail = relationStatus != "Single" ? "\(relationStatus) with \(userName) since \(relationDate)" : relationStatus
            cellDetail.lblRelationDetail.text = statusDetail
            let isApproval = self.parentView.otherUserObj.relationshipArray[index!].statusApproval == "0"
            let isStatusAvailable = isApproval && (relationStatus != "Single")
            cellDetail.lblStatusState.isHidden = !isStatusAvailable
            cellDetail.lblStatusState.text = isStatusAvailable ? "Pending" : ""
            let profileImage = self.parentView.otherUserObj.relationshipArray[index!].user?.profileImage
            let personalProfileImage = self.parentView.otherUserObj.profileImage
            cellDetail.partnerImageView.imageLoad(with: relationStatus == "Single" ? personalProfileImage : profileImage, isPlaceHolder: true)
        } else {
            cellDetail.viewEdit.isHidden = false
            let firstName = SharedManager.shared.userEditObj.relationshipArray[index!].user?.firstname ?? .emptyString
            let lastName = SharedManager.shared.userEditObj.relationshipArray[index!].user?.lastname ?? .emptyString
            let fullName =  firstName + " " + lastName
            let relationStatus = SharedManager.shared.userEditObj.relationshipArray[index!].statusDescription
            let userName = SharedManager.shared.userEditObj.firstname + " " + SharedManager.shared.userEditObj.lastname
            let relationDate = SharedManager.shared.userEditObj.relationshipArray[index!].relationshipCreationDate
            let statusDetail = relationStatus != "Single" ? "\(relationStatus) with \(userName) since \(relationDate)" : relationStatus
            cellDetail.lblName.text = relationStatus == "Single" ? userName : fullName
            cellDetail.lblRelationDetail.text = statusDetail
            let isApproval = SharedManager.shared.userEditObj.relationshipArray[index!].statusApproval == "0"
            let isStatusAvailable = isApproval && (relationStatus != "Single")
            cellDetail.lblStatusState.isHidden = !isStatusAvailable
            cellDetail.lblStatusState.text = isStatusAvailable ? "Pending" : ""
            let profileImage = SharedManager.shared.userEditObj.relationshipArray[index!].user?.profileImage
            let personalProfileImage = SharedManager.shared.userEditObj.profileImage
            cellDetail.partnerImageView.imageLoad(with: relationStatus == "Single" ? personalProfileImage : profileImage, isPlaceHolder: true)
            cellDetail.editBtn.tag = indexPath.row
            cellDetail.editBtn.addTarget(self, action: #selector(self.editAction), for: .touchUpInside)
        }
        return cellDetail
    }
    
    func FamilyRelationshipDetailInfoCell(tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellDetail = tableView.dequeueReusableCell(withIdentifier: "ProfileFamilyRelationCell", for: indexPath) as! ProfileFamilyRelationCell
        let index = Int(self.arrayBottom[indexPath.row]["indexObj"]!)
        if self.parentView.otherUserID.count > 0 {
            cellDetail.viewEdit.isHidden = true
            let fullName = (self.parentView.otherUserObj.familyRelationshipArray[index!].user?.firstname ?? .emptyString) + " " + (self.parentView.otherUserObj.familyRelationshipArray[index!].user?.lastname ?? .emptyString)
            cellDetail.lblName.text = fullName
            cellDetail.lblRelationDetail.text  = self.parentView.otherUserObj.familyRelationshipArray[index!].statusDescription
            let isApproval = self.parentView.otherUserObj.familyRelationshipArray[index!].statusApproval == "0"
            cellDetail.lblStatusState.text = isApproval ? "Pending" : ""
            cellDetail.partnerImageView.imageLoad(with: self.parentView.otherUserObj.familyRelationshipArray[index!].user?.profileImage, isPlaceHolder: true)
        } else {
            cellDetail.viewEdit.isHidden = false
            let fullName = (SharedManager.shared.userEditObj.familyRelationshipArray[index!].user?.firstname ?? .emptyString) + " " + (SharedManager.shared.userEditObj.familyRelationshipArray[index!].user?.lastname ?? .emptyString)
            cellDetail.lblName.text = fullName
            cellDetail.partnerImageView.imageLoad(with: SharedManager.shared.userEditObj.familyRelationshipArray[index!].user?.profileImage, isPlaceHolder: true)
            cellDetail.lblRelationDetail.text = SharedManager.shared.userEditObj.familyRelationshipArray[index!].statusDescription
            let isApproval = SharedManager.shared.userEditObj.familyRelationshipArray[index!].statusApproval == "0"
            cellDetail.lblStatusState.text = isApproval ? "Pending" : ""
            cellDetail.editBtn.tag = indexPath.row
            cellDetail.editBtn.addTarget(self, action: #selector(self.editAction), for: .touchUpInside)
        }
        return cellDetail
    }
    
    func CurrencyDetailInfoCell(tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // let cellDetail = tableView.dequeueReusableCell(withIdentifier: "ProfileCurrencyCell", for: indexPath) as! ProfileCurrencyCell
        // let index = Int(self.arrayBottom[indexPath.row]["indexObj"]!)
        // if self.parentView.otherUserID.count > 0 {
        //     cellDetail.viewEdit.isHidden = true
        //     cellDetail.lblCurrency.text = "Asher Azeem"
        // } else {
        //     cellDetail.viewEdit.isHidden = false
        //     cellDetail.lblCurrency.text = "Asher Azeem"
        //     cellDetail.editBtn.tag = indexPath.row
        //     cellDetail.editBtn.addTarget(self, action: #selector(self.editAction), for: .touchUpInside)
        // }
        // return cellDetail
        let cellUserTab = tableView.dequeueReusableCell(withIdentifier: "ProfileUserinfoCell", for: indexPath) as! ProfileUserinfoCell
        cellUserTab.lblInfo.text = self.arrayBottom[indexPath.row]["indexObj"]!
        cellUserTab.lblInfo.textColor = UIColor.black
        cellUserTab.btnAboutMe.isHidden = true
        self.parentView.view.labelRotateCell(viewMain: cellUserTab.lblInfo)
        cellUserTab.lblInfo.rotateForTextAligment()
        cellUserTab.selectionStyle = .none
        return cellUserTab
    }
    
    func ProfileUserinfoInterestCell(tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // let cellUserTab = tableView.dequeueReusableCell(withIdentifier: "ProfileUserinfoCell", for: indexPath) as! ProfileUserinfoCell
        guard let cellUserTab = tableView.dequeueReusableCell(withIdentifier: "ProfileUserinfoCell", for: indexPath) as? ProfileUserinfoCell else {
            return UITableViewCell()
        }
        
        cellUserTab.lblInfo.text = self.arrayBottom[indexPath.row]["indexObj"]!
        
        cellUserTab.lblInfo.textColor = UIColor.black
        cellUserTab.btnAboutMe.isHidden = true
        
        self.parentView.view.labelRotateCell(viewMain: cellUserTab.lblInfo)
        cellUserTab.lblInfo.rotateForTextAligment()
        
        cellUserTab.selectionStyle = .none
        return cellUserTab
    }
    
    
    func ProfileDetailInfoCell(tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //        let cellDetail = tableView.dequeueReusableCell(withIdentifier: "ProfileDetailInfoCell", for: indexPath) as! ProfileDetailInfoCell
        guard let cellDetail = tableView.dequeueReusableCell(withIdentifier: "ProfileDetailInfoCell", for: indexPath) as? ProfileDetailInfoCell else {
            return UITableViewCell()
        }
        
        self.parentView.view.labelRotateCell(viewMain: cellDetail.lblinfo)
        cellDetail.lblinfo.rotateForTextAligment()
        
        self.parentView.view.labelRotateCell(viewMain: cellDetail.lblHeading)
        cellDetail.lblHeading.rotateForTextAligment()
        
        
        self.parentView.view.labelRotateCell(viewMain: cellDetail.lblEdit)
        cellDetail.lblEdit.rotateForTextAligment()
        
        
        cellDetail.selectionStyle = .none
        return cellDetail
    }
    
    
    func WorkDetailInfoCell(tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        //        let cellDetail = tableView.dequeueReusableCell(withIdentifier: "ProfileWorkDetailInfoCell", for: indexPath) as! ProfileWorkDetailInfoCell
        
        
        guard let cellDetail = tableView.dequeueReusableCell(withIdentifier: "ProfileWorkDetailInfoCell", for: indexPath) as? ProfileWorkDetailInfoCell else {
            return UITableViewCell()
        }
        let index = Int(self.arrayBottom[indexPath.row]["indexObj"]!)
        
        if self.parentView.otherUserID.count > 0 {
            cellDetail.viewEdit.isHidden = true
            cellDetail.lblCompanyName.text = self.parentView.otherUserObj.workExperiences[index!].company
            cellDetail.lblDesignation.text = self.parentView.otherUserObj.workExperiences[index!].title
            let startDate = self.parentView.otherUserObj.workExperiences[index!].start_date.toDate()
            let endDate = self.parentView.otherUserObj.workExperiences[index!].end_date.toDate()
            cellDetail.lblTime.text = ""
            if startDate != nil && endDate != nil {
                cellDetail.lblTime.text = (startDate?.toFormat("YYYY-MM-dd"))! + " To " + (endDate?.toFormat("YYYY-MM-dd"))!
            }
        }else {
            cellDetail.viewEdit.isHidden = false
            cellDetail.lblCompanyName.text = SharedManager.shared.userEditObj.workExperiences[index!].company
            cellDetail.lblDesignation.text = SharedManager.shared.userEditObj.workExperiences[index!].title
            let startDate = SharedManager.shared.userEditObj.workExperiences[index!].start_date.toDate()
            let endDate = SharedManager.shared.userEditObj.workExperiences[index!].end_date.toDate()
            cellDetail.lblTime.text = ""
            if startDate != nil && endDate != nil {
                cellDetail.lblTime.text = (startDate?.toFormat("YYYY-MM-dd"))! + " To " + (endDate?.toFormat("YYYY-MM-dd"))!
            }
            
            cellDetail.btnEdit.tag = indexPath.row
            cellDetail.btnEdit.addTarget(self, action: #selector(self.editAction), for: .touchUpInside)
        }
        
        self.parentView.view.labelRotateCell(viewMain: cellDetail.lblEdit)
        cellDetail.lblEdit.rotateForTextAligment()
        
        self.parentView.view.labelRotateCell(viewMain: cellDetail.lblTime)
        cellDetail.lblTime.rotateForTextAligment()
        
        self.parentView.view.labelRotateCell(viewMain: cellDetail.lblCompanyName)
        cellDetail.lblCompanyName.rotateForTextAligment()
        
        self.parentView.view.labelRotateCell(viewMain: cellDetail.lblDesignation)
        cellDetail.lblDesignation.rotateForTextAligment()
        
        cellDetail.selectionStyle = .none
        return cellDetail
    }
    
    func ProfileGroupCell(tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileGroupCell", for: indexPath) as! ProfileGroupCell
        if let id = self.arrayBottom[indexPath.row]["id"], let index = Int(self.arrayBottom[indexPath.row]["indexObj"] ?? "-1"), index >= 0 {
            if id == "1504" {
                cell.configureCell(obj: (parentView.otherUserID.count > 0) ? parentView.otherUserObj.groupArray[index] : SharedManager.shared.userEditObj.groupArray[index], index: index, pageTab: "group")
            }
        }
        cell.profileGroupDelegate = self
        cell.selectionStyle = .none
        return cell
    }
    
    
    func CategoryLikeCell(tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryLikeCell", for: indexPath) as! CategoryLikeCell
        if let id = self.arrayBottom[indexPath.row]["id"], let index = Int(self.arrayBottom[indexPath.row]["indexObj"] ?? "-1"), index >= 0 {
            // cell.isFromProfile = true
            if id == "1101" { // Sports
                cell.configureCell(obj: (parentView.otherUserID.count > 0) ? parentView.otherUserObj.sportArray[index] : SharedManager.shared.userEditObj.sportArray[index], index: index, pageTab: "sport")
            } else if id == "1102" { // movie
                cell.configureCell(obj: (parentView.otherUserID.count > 0) ? parentView.otherUserObj.movieArray[index] : SharedManager.shared.userEditObj.movieArray[index], index: index, pageTab: "movie")
            } else if id == "1103" { //tv
                cell.configureCell(obj: (parentView.otherUserID.count > 0) ? parentView.otherUserObj.tvShowArray[index] : SharedManager.shared.userEditObj.tvShowArray[index], index: index, pageTab: "tv")
            } else if id == "1104" { //book
                cell.configureCell(obj: (parentView.otherUserID.count > 0) ? parentView.otherUserObj.bookArray[index] : SharedManager.shared.userEditObj.bookArray[index], index: index, pageTab: "book")
            } else if id == "1105" { // games
                cell.configureCell(obj: (parentView.otherUserID.count > 0) ? parentView.otherUserObj.gameArray[index] : SharedManager.shared.userEditObj.gameArray[index], index: index, pageTab: "game")
            } else if id == "1106" { // athlete
                cell.configureCell(obj: (parentView.otherUserID.count > 0) ? parentView.otherUserObj.athleteArray[index] : SharedManager.shared.userEditObj.athleteArray[index], index: index, pageTab: "athlete")
            } else if id == "1107" { // music
                cell.configureCell(obj: (parentView.otherUserID.count > 0) ? parentView.otherUserObj.musicArray[index] : SharedManager.shared.userEditObj.musicArray[index], index: index, pageTab: "music")
            }
        }
        cell.categoryLikeDelegate = self
        cell.selectionStyle = .none
        return cell
    }
    
    @objc func editAction(sender : UIButton){
        let index = Int(self.arrayBottom[sender.tag]["indexObj"]!)
        if self.arrayBottom[sender.tag]["id"] == "600" {
            let workEdit = SharedManager.shared.userEditObj.workExperiences[index!]
            (self.parentView as ProfileViewController).editProfileWork.parentview = self.parentView
            (self.parentView as ProfileViewController).editProfileWork.editWork = workEdit
            (self.parentView as ProfileViewController).editProfileWork.reloadView(type: 2, rowIndexP: index!)
            (self.parentView as ProfileViewController).isNavPushAllow = false
            UIApplication.shared.keyWindow!.addSubview((self.parentView as ProfileViewController).editProfileWork.view)
        } else if self.arrayBottom[sender.tag]["id"] == "1000" {
            let educationEdit = SharedManager.shared.userEditObj.institutes[index!]
            (self.parentView as ProfileViewController).editProfileEducation.parentview = self.parentView
            (self.parentView as ProfileViewController).editProfileEducation.editEducation = educationEdit
            (self.parentView as ProfileViewController).editProfileEducation.reloadView(type: 2, rowIndexP: index!)
            (self.parentView as ProfileViewController).isNavPushAllow = false
            UIApplication.shared.keyWindow!.addSubview((self.parentView as ProfileViewController).editProfileEducation.view)
        } else if self.arrayBottom[sender.tag]["id"] == "1500" { // website
            websiteURLCompletion?(2, index)
        } else if self.arrayBottom[sender.tag]["id"] == "1501" { // relationship
            relationshipCompletion?(2, index)
        } else if self.arrayBottom[sender.tag]["id"] == "1502" { // family relationshiop
            familyRelationshipCompletion?(2, index)
        } else if self.arrayBottom[sender.tag]["id"] == "1505" { // life events
            lifeEventsCompletion?(2, index)
        }
    }
    
    func EduDetailInfoCell(tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cellDetail = tableView.dequeueReusableCell(withIdentifier: "ProfileWorkDetailInfoCell", for: indexPath) as? ProfileWorkDetailInfoCell else {
            return UITableViewCell()
        }
        let index = Int(self.arrayBottom[indexPath.row]["indexObj"]!)
        
        if self.parentView.otherUserID.count > 0 {
            cellDetail.viewEdit.isHidden = true
            cellDetail.lblCompanyName.text = self.parentView.otherUserObj.institutes[index!].degree_title
            cellDetail.lblDesignation.text = self.parentView.otherUserObj.institutes[index!].name
            
            cellDetail.lblTime.text = self.parentView.otherUserObj.institutes[index!].address
        }else {
            cellDetail.viewEdit.isHidden = false
            cellDetail.lblCompanyName.text = SharedManager.shared.userEditObj.institutes[index!].degree_title
            cellDetail.lblDesignation.text = SharedManager.shared.userEditObj.institutes[index!].name
            
            cellDetail.lblTime.text = SharedManager.shared.userEditObj.institutes[index!].address
        }
        
        
        self.parentView.view.labelRotateCell(viewMain: cellDetail.lblEdit)
        cellDetail.lblEdit.rotateForTextAligment()
        
        
        cellDetail.btnEdit.tag = indexPath.row
        cellDetail.btnEdit.addTarget(self, action: #selector(self.editAction), for: .touchUpInside)
        
        self.parentView.view.labelRotateCell(viewMain: cellDetail.lblTime)
        cellDetail.lblTime.rotateForTextAligment()
        
        self.parentView.view.labelRotateCell(viewMain: cellDetail.lblCompanyName)
        cellDetail.lblCompanyName.rotateForTextAligment()
        
        self.parentView.view.labelRotateCell(viewMain: cellDetail.lblDesignation)
        cellDetail.lblDesignation.rotateForTextAligment()
        
        cellDetail.selectionStyle = .none
        return cellDetail
    }
    
    @objc func EducationEdit(sender : UIButton){
        let index = Int(self.arrayBottom[sender.tag]["indexObj"]!)
        let educationEdit = SharedManager.shared.userEditObj.institutes[index!]
        (self.parentView as ProfileViewController).editProfileEducation.parentview = self.parentView
        (self.parentView as ProfileViewController).editProfileEducation.editEducation = educationEdit
        (self.parentView as ProfileViewController).editProfileEducation.reloadView(type: 2, rowIndexP: index!)
        (self.parentView as ProfileViewController).isNavPushAllow = false
        UIApplication.shared.keyWindow!.addSubview((self.parentView as ProfileViewController).editProfileEducation.view)
    }
    
    func PlaceDetailInfoCell(tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //        let cellDetail = tableView.dequeueReusableCell(withIdentifier: "ProfilePlaceDetailInfoCell", for: indexPath) as! ProfilePlaceDetailInfoCell
        
        guard let cellDetail = tableView.dequeueReusableCell(withIdentifier: "ProfilePlaceDetailInfoCell", for: indexPath) as? ProfilePlaceDetailInfoCell else {
            return UITableViewCell()
        }
        let index = Int(self.arrayBottom[indexPath.row]["indexObj"]!)
        if self.parentView.otherUserID.count > 0 {
            cellDetail.viewEdit.isHidden = true
            cellDetail.lblCompanyName.text = self.parentView.otherUserObj.places[index!].place
            cellDetail.lblDesignation.text = self.parentView.otherUserObj.places[index!].address
        }else {
            cellDetail.viewEdit.isHidden = false
            cellDetail.lblCompanyName.text = SharedManager.shared.userEditObj.places[index!].place
            cellDetail.lblDesignation.text = SharedManager.shared.userEditObj.places[index!].address
        }
        
        cellDetail.btnEdit.tag = indexPath.row
        cellDetail.btnEdit.addTarget(self, action: #selector(self.editPlaceAction), for: .touchUpInside)
        
        
        self.parentView.view.labelRotateCell(viewMain: cellDetail.lblDesignation)
        cellDetail.lblDesignation.rotateForTextAligment()
        
        self.parentView.view.labelRotateCell(viewMain: cellDetail.lblCompanyName)
        cellDetail.lblCompanyName.rotateForTextAligment()
        
        self.parentView.view.labelRotateCell(viewMain: cellDetail.lblEdit)
        cellDetail.lblEdit.rotateForTextAligment()
        
        
        cellDetail.selectionStyle = .none
        return cellDetail
    }
    
    
    func ProfileDetailAddInfoCell(tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // let cellDetail = tableView.dequeueReusableCell(withIdentifier: "ProfileDetailAddInfoCell", for: indexPath) as! ProfileDetailAddInfoCell
        guard let cellDetail = tableView.dequeueReusableCell(withIdentifier: "ProfileDetailAddInfoCell", for: indexPath) as? ProfileDetailAddInfoCell else {
            return UITableViewCell()
        }
        cellDetail.lblHeading.text = self.arrayBottom[indexPath.row]["Text"]
        cellDetail.imgViewMain.image = UIImage.init(named: self.arrayBottom[indexPath.row]["Image"]!)
        cellDetail.btnAdd.tag = indexPath.row
        cellDetail.btnAdd.addTarget(self, action: #selector(self.AddNewAction), for: .touchUpInside)
        
        self.parentView.view.labelRotateCell(viewMain: cellDetail.lblHeading)
        cellDetail.lblHeading.rotateForTextAligment()
        
        cellDetail.selectionStyle = .none
        
        return cellDetail
    }
    
    func ProfileUserHeadingCell(tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cellUserTab = tableView.dequeueReusableCell(withIdentifier: "ProfileUserHeadingCell", for: indexPath) as? ProfileUserHeadingCell else {
            return UITableViewCell()
        }
        cellUserTab.lblHeading.text = self.arrayBottom[indexPath.row]["Text"]
        cellUserTab.viewEdit.isHidden = true
        cellUserTab.viewSeeAll.isHidden = true
        cellUserTab.imgViewExpand.image = UIImage.init(named: "ClosedIcon")
        if self.arrayBottom[indexPath.row]["isExpand"] == "1" {
            cellUserTab.imgViewExpand.image = UIImage.init(named: "OpenIcon")
            if self.arrayBottom[indexPath.row]["id"] == "5" {
                cellUserTab.viewEdit.isHidden = false
            }else if self.arrayBottom[indexPath.row]["id"] == "9" {
                cellUserTab.viewEdit.isHidden = false
            } else if self.arrayBottom[indexPath.row]["id"] == "20" {
                cellUserTab.viewEdit.isHidden = false
            } else if self.arrayBottom[indexPath.row]["id"] == "36" {
                cellUserTab.viewEdit.isHidden = false
            } else if self.arrayBottom[indexPath.row]["id"] == "37" { // group
                cellUserTab.viewSeeAll.isHidden = false
                cellUserTab.viewSeeAll.isHidden = SharedManager.shared.userEditObj.groupArray.count == 0
            } else if self.arrayBottom[indexPath.row]["id"] == "39" { // Sport
                cellUserTab.viewSeeAll.isHidden = false
                cellUserTab.viewSeeAll.isHidden = SharedManager.shared.userEditObj.sportArray.count == 0
            } else if self.arrayBottom[indexPath.row]["id"] == "40" { // Movie
                cellUserTab.viewSeeAll.isHidden = false
                cellUserTab.viewSeeAll.isHidden = SharedManager.shared.userEditObj.movieArray.count == 0
            } else if self.arrayBottom[indexPath.row]["id"] == "41" { // TV
                cellUserTab.viewSeeAll.isHidden = false
                cellUserTab.viewSeeAll.isHidden = SharedManager.shared.userEditObj.tvShowArray.count == 0
            } else if self.arrayBottom[indexPath.row]["id"] == "42" { // Book
                cellUserTab.viewSeeAll.isHidden = false
                cellUserTab.viewSeeAll.isHidden = SharedManager.shared.userEditObj.bookArray.count == 0
            } else if self.arrayBottom[indexPath.row]["id"] == "43" { // game
                cellUserTab.viewSeeAll.isHidden = false
                cellUserTab.viewSeeAll.isHidden = SharedManager.shared.userEditObj.gameArray.count == 0
            } else if self.arrayBottom[indexPath.row]["id"] == "44" { // athlete
                cellUserTab.viewSeeAll.isHidden = false
                cellUserTab.viewSeeAll.isHidden = SharedManager.shared.userEditObj.athleteArray.count == 0
            } else if self.arrayBottom[indexPath.row]["id"] == "45" { // music
                cellUserTab.viewSeeAll.isHidden = false
                cellUserTab.viewSeeAll.isHidden = SharedManager.shared.userEditObj.musicArray.count == 0
            }
        }
        
        if self.parentView.otherUserID.count > 0 {
            cellUserTab.viewEdit.isHidden = true
        }
        cellUserTab.btnExpand.addTarget(self, action: #selector(self.ExpnadView), for: .touchUpInside)
        cellUserTab.btnExpand.tag = indexPath.row
        
        cellUserTab.btnEdit.addTarget(self, action: #selector(self.editInfoOverview), for: .touchUpInside)
        cellUserTab.btnEdit.tag = indexPath.row
        
        cellUserTab.btnSeeAll.addTarget(self, action: #selector(self.editInfoOverview), for: .touchUpInside)
        cellUserTab.btnSeeAll.tag = indexPath.row
        
        self.parentView.view.labelRotateCell(viewMain: cellUserTab.lblHeading)
        cellUserTab.lblHeading.rotateForTextAligment()
        
        self.parentView.view.labelRotateCell(viewMain: cellUserTab.lblEdit)
        cellUserTab.lblEdit.rotateForTextAligment()
        
        cellUserTab.selectionStyle = .none
        return cellUserTab
    }
    
    @objc func editInfoOverview(sender : UIButton) {
        if self.arrayBottom[sender.tag]["id"] == "5" {
            (self.parentView as ProfileViewController).editProfileOverview.parentview = self.parentView
            (self.parentView as ProfileViewController).editProfileOverview.otherUserObj = SharedManager.shared.userEditObj
            (self.parentView as ProfileViewController).isNavPushAllow = false
            UIApplication.shared.keyWindow!.addSubview((self.parentView as ProfileViewController).editProfileOverview.view)
        } else if self.arrayBottom[sender.tag]["id"] == "9" {
            self.getInterestes()
        } else if self.arrayBottom[sender.tag]["id"] == "15" {
            LogClass.debugLog("Total Language \(arrayLanguage.count)")
        } else if self.arrayBottom[sender.tag]["id"] == "20" {
            self.getLanguages()
        } else if self.arrayBottom[sender.tag]["id"] == "36" {
            currencyCompletion?(2, 0)
        } else if self.arrayBottom[sender.tag]["id"] == "37" {
            groupSeeAllCompletion?("Games", "game", SharedManager.shared.userEditObj.groupArray)
        } else if self.arrayBottom[sender.tag]["id"] == "39" {
            categoryLikePagesCompletion?("Sports", "sport", SharedManager.shared.userEditObj.sportArray)
        } else if self.arrayBottom[sender.tag]["id"] == "40" {
            categoryLikePagesCompletion?("Movie","movie" ,SharedManager.shared.userEditObj.movieArray)
        } else if self.arrayBottom[sender.tag]["id"] == "41" {
            categoryLikePagesCompletion?("TV", "tv", SharedManager.shared.userEditObj.tvShowArray)
        } else if self.arrayBottom[sender.tag]["id"] == "42" {
            categoryLikePagesCompletion?("Book", "book", SharedManager.shared.userEditObj.bookArray)
        } else if self.arrayBottom[sender.tag]["id"] == "43" {
            categoryLikePagesCompletion?("Games", "game", SharedManager.shared.userEditObj.gameArray)
        } else if self.arrayBottom[sender.tag]["id"] == "44" {
            categoryLikePagesCompletion?("Athlete", "athlete", SharedManager.shared.userEditObj.athleteArray)
        } else if self.arrayBottom[sender.tag]["id"] == "45" {
            categoryLikePagesCompletion?("Music", "music", SharedManager.shared.userEditObj.musicArray)
        }
    }
    
    @objc func AddNewAction(sender : UIButton){
        if self.arrayBottom[sender.tag]["id"] == "600" { // Work
            (self.parentView as ProfileViewController).editProfileWork.parentview = self.parentView
            (self.parentView as ProfileViewController).editProfileWork.reloadView(type: -1, rowIndexP: sender.tag)
            (self.parentView as ProfileViewController).isNavPushAllow = false
            UIApplication.shared.keyWindow!.addSubview((self.parentView as ProfileViewController).editProfileWork.view)
        }else if self.arrayBottom[sender.tag]["id"] == "700" { // Visited Location
            (self.parentView as ProfileViewController).editProfileVisitedLocationVc.parentview = self.parentView
            (self.parentView as ProfileViewController).editProfileVisitedLocationVc.reloadView(type: -1, rowIndexP: sender.tag)
            UIApplication.shared.keyWindow!.addSubview((self.parentView as ProfileViewController).editProfileVisitedLocationVc.view)
        }else if self.arrayBottom[sender.tag]["id"] == "1000" {  // Education
            (self.parentView as ProfileViewController).editProfileEducation.parentview = self.parentView
            (self.parentView as ProfileViewController).editProfileEducation.reloadView(type: -1, rowIndexP: sender.tag)
            (self.parentView as ProfileViewController).isNavPushAllow = false
            UIApplication.shared.keyWindow!.addSubview((self.parentView as ProfileViewController).editProfileEducation.view)
        } else if self.arrayBottom[sender.tag]["id"] == "1500" { // Website
            websiteURLCompletion?(-1, sender.tag)
        } else if self.arrayBottom[sender.tag]["id"] == "1501" { // relationship
            relationshipCompletion?(-1, sender.tag)
        } else if self.arrayBottom[sender.tag]["id"] == "1502" { // family relationship
            familyRelationshipCompletion?(-1, sender.tag)
        } else if self.arrayBottom[sender.tag]["id"] == "1505" { // life events
            lifeEventsCompletion?(-1, sender.tag)
        }
    }
    
    func ProfileSearchContactsCell(tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.arrayContactGroup.count == 0 {
            guard let cellSearch = tableView.dequeueReusableCell(withIdentifier: "LoginSessionHeaderCell", for: indexPath) as? LoginSessionHeaderCell else {
                return UITableViewCell()
            }
            if self.parentView.otherUserObj.id.count > 0 {
                cellSearch.lblName.text = "Contact's list private by ".localized() + self.parentView.otherUserObj.firstname
            }else {
                cellSearch.lblName.text = "Contact's list is empty".localized()
            }
            cellSearch.selectionStyle = .none
            return cellSearch
        }
        guard let cellSearch = tableView.dequeueReusableCell(withIdentifier: "ProfileSearchContactsCell", for: indexPath) as? ProfileSearchContactsCell else {
            return UITableViewCell()
        }
        self.parentView.view.labelRotateCell(viewMain: cellSearch.txtFieldSearch)
        cellSearch.txtFieldSearch.rotateForLanguage()
        cellSearch.txtFieldSearch.delegate = self
        cellSearch.txtFieldSearch.tag = 100
        
        if self.texttoshow == "1"{
            cellSearch.txtFieldSearch.text = ""
            self.texttoshow = ""
        }
        cellSearch.txtFieldSearch.returnKeyType = .search
        cellSearch.selectionStyle = .none
        return cellSearch
    }
    
    
    func ProfileContactCell(tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard  let cellContact = tableView.dequeueReusableCell(withIdentifier: "ProfileContactCell", for: indexPath) as? ProfileContactCell else {
            return UITableViewCell()
        }
        cellContact.lblName.text = self.arrayContactGroupSearch[indexPath.row-1].firstname + " "  + self.arrayContactGroupSearch[indexPath.row-1].lastname
        
        var groupText = ""
        for indexObj in self.arrayContactGroupSearch[indexPath.row-1].contactGroup {
            if groupText.count == 0 {
                groupText = indexObj.title
            }else {
                groupText = groupText + "," + indexObj.title
            }
        }
        
        if self.parentView.otherUserID.count > 0 {
            cellContact.viewDelete.isHidden = true
        }
        //        cellContact.imgViewUser.sd_imageIndicator = SDWebImageActivityIndicator.gray
        cellContact.imgViewUser.loadImageWithPH(urlMain:self.arrayContactGroupSearch[indexPath.row-1].profile_image)
        //        cellContact.imgViewUser.sd_setImage(with: URL(string: self.arrayContactGroup[indexPath.row-1].profile_image ), placeholderImage: UIImage(named: "placeholder.png"))
        
        self.parentView.view.labelRotateCell(viewMain: cellContact.imgViewUser)
        cellContact.lblGroups.text = groupText
        cellContact.btnDelete.tag = indexPath.row-1
        cellContact.btnDelete.addTarget(self, action: #selector(self.contactDeleteAction), for: .touchUpInside)
        
        
        self.parentView.view.labelRotateCell(viewMain: cellContact.lblName)
        cellContact.lblName.rotateForTextAligment()
        
        self.parentView.view.labelRotateCell(viewMain: cellContact.lblGroups)
        cellContact.lblGroups.rotateForTextAligment()
        
        
        //
        //        self.parentView.view.labelRotateCell(viewMain: cellContact.lblName)
        //        cellContact.lblName.rotateForTextAligment()
        //
        //        self.parentView.view.labelRotateCell(viewMain: cellContact.lblGroups)
        //        cellContact.lblGroups.rotateForTextAligment()
        
        cellContact.selectionStyle = .none
        return cellContact
    }
    
    @objc func contactDeleteAction(sender : UIButton){
        self.parentView.ShowAlertWithCompletaion(message: "Are you sure to remove this contact from your contacts list?".localized()) { (status) in
            if status {
                
                let userToken = SharedManager.shared.userToken()
                let parameters = ["action": "contacts/remove_contact","token": userToken , "friend_id" : self.arrayContactGroupSearch[sender.tag].id]
                
                //                SharedManager.shared.showOnWindow()
                Loader.startLoading()
                RequestManager.fetchDataPost(Completion: { response in
                    //                    SharedManager.shared.hideLoadingHubFromKeyWindow()
                    Loader.stopLoading()
                    switch response {
                    case .failure(let error):
                        SwiftMessages.apiServiceError(error: error)
                    case .success(let res):
                        if res is Int {
                            AppDelegate.shared().loadLoginScreen()
                            //                        }else if res is String {
                            
                        } else {
                            self.texttoshow = "1"
                            self.arrayContactGroupSearch.removeAll()
                            self.arrayContactGroup.removeAll()
                            self.getContact()
                            //                            self.arrayContactGroupSearch.remove(at: sender.tag)
                            //                            self.parentView.profileTableView.reloadData()
                        }
                    }
                }, param:parameters)
            }
        }
    }
    
    func ProfileImageCell(tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cellTab = tableView.dequeueReusableCell(withIdentifier: "ProfileImageCell", for: indexPath) as? ProfileImageCell else {
            return UITableViewCell()
        }
        cellTab.arrayImages.removeAll()
        
        if self.selectedTab == .photos {
            cellTab.isImage = true
            
            for indexInner in self.arrayImageLocal {
                cellTab.arrayImages.append(indexInner)
            }
            
            for indexObj in self.arrayImage {
                for indexObjInner in indexObj.post! {
                    cellTab.arrayImages.append((indexObjInner).filePath!)
                }
            }
        } else {
            cellTab.isImage = false
            
            for indexInner in self.arrayVideoforTable {
                cellTab.arrayImages.append(indexInner)
            }
            
            cellTab.isImage = false
        }
        
        cellTab.delegate = self
        cellTab.viewWidth = self.parentView.view.frame.size.width
        cellTab.reloadView()
        
        cellTab.selectionStyle = .none
        return cellTab
    }
    
    func getReelTabCell(tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cellTab = tableView.dequeueReusableCell(withIdentifier: "ReelTabTableViewCell",
                                                          for: indexPath) as? ReelTabTableViewCell else {
            return UITableViewCell()
        }
        
        if selectedTab == .myReels {
            cellTab.bind(delegate: self, ReelsList: self.myReelsList)
        } else if selectedTab == .savedReels {
            cellTab.bind(delegate: self, ReelsList: self.savedReelsList)
        }
        cellTab.viewWidth = self.parentView.view.frame.size.width
        return cellTab
    }
    
    @objc func editPlaceAction(sender : UIButton){
        let index = Int(self.arrayBottom[sender.tag]["indexObj"]!)
        let placeEdit = SharedManager.shared.userEditObj.places[index!]
        (self.parentView as ProfileViewController).editProfileVisitedLocationVc.parentview = self.parentView
        (self.parentView as ProfileViewController).editProfileVisitedLocationVc.editPlace = placeEdit
        (self.parentView as ProfileViewController).editProfileVisitedLocationVc.reloadView(type: 2, rowIndexP: index!)
        (self.parentView as ProfileViewController).isNavPushAllow = false
        UIApplication.shared.keyWindow!.addSubview((self.parentView as ProfileViewController).editProfileVisitedLocationVc.view)
    }
    
    @objc func ExpnadView(sender : UIButton){
        let cellheader = self.feedtble.cellForRow(at: IndexPath.init(row: sender.tag, section: 1)) as! ProfileUserHeadingCell
        
        var isExpand = self.arrayBottom[sender.tag]["isExpand"] == "1" ? false : true
        self.arrayBottom[sender.tag]["isExpand"] = isExpand ? "1" : "0"
        cellheader.imgViewExpand.image = UIImage(named: isExpand ? "OpenIcon" : "ClosedIcon")
        
        var idCheck = ""
        var headerValue = ""
        var headerICon = ""
        if self.arrayBottom[sender.tag]["id"] == "5" {
            idCheck = "500"
        }else if self.arrayBottom[sender.tag]["id"] == "6" {
            idCheck = "600"
            headerValue = "Add Work".localized()
            headerICon = "AddEducationIcon"
        } else if self.arrayBottom[sender.tag]["id"] == "33" { // website
            idCheck = "1500"
            headerValue = "Add Webiste".localized()
            headerICon = "WebIcon"
        } else if self.arrayBottom[sender.tag]["id"] == "34" { // relationship
            idCheck = "1501"
            headerValue = "Add Relationship"
            headerICon = "RelationIcon"
        } else if self.arrayBottom[sender.tag]["id"] == "35" { // family relationship
            idCheck = "1502"
            headerValue = "Add Family Relationship"
            headerICon = "FamilyIcon"
        }  else if self.arrayBottom[sender.tag]["id"] == "36" { // Currency
            idCheck = "1503"
        }
        else if self.arrayBottom[sender.tag]["id"] == "37" { // Add Group
            idCheck = "1504"
        } else if self.arrayBottom[sender.tag]["id"] == "38" { // Add Life Events
            idCheck = "1505"
            headerValue = "Add Life Events".localized()
            headerICon = "AddEducationIcon"
        }else if self.arrayBottom[sender.tag]["id"] == "10" {
            idCheck = "1000"
            headerValue = "Add Education".localized()
            headerICon = "AddEducationIcon"
        } else if self.arrayBottom[sender.tag]["id"] == "7" {
            idCheck = "700"
            headerValue = "Add City".localized()
            headerICon = "AddCityIcon"
        } else if self.arrayBottom[sender.tag]["id"] == "8" {
            idCheck = "800"
        } else if self.arrayBottom[sender.tag]["id"] == "9" {
            idCheck = "900"
        } else if self.arrayBottom[sender.tag]["id"] == "20" { // language
            idCheck = "1200"
        }else if self.arrayBottom[sender.tag]["id"] == "39" { // sports
            idCheck = "1101"
        }else if self.arrayBottom[sender.tag]["id"] == "40" { // movie
            idCheck = "1102"
        }else if self.arrayBottom[sender.tag]["id"] == "41" { // tv
            idCheck = "1103"
        } else if self.arrayBottom[sender.tag]["id"] == "42" { // books
            idCheck = "1104"
        } else if self.arrayBottom[sender.tag]["id"] == "43" { // games
            idCheck = "1105"
        } else if self.arrayBottom[sender.tag]["id"] == "44" { // Athlete
            idCheck = "1106"
        } else if self.arrayBottom[sender.tag]["id"] == "45" { // Music
            idCheck = "1107"
        }
        
        var arrayIndex = [IndexPath]()
        
        
        LogClass.debugLog("sender.tag  =====> Main Expnad")
        LogClass.debugLog(sender.tag)
        var senderTag = sender.tag + 1
        
        if isExpand {
            
            if headerValue.count > 0 {
                arrayIndex.append(IndexPath.init(row: senderTag, section: 1))
                self.arrayBottom.insert(["Type" : "101" , "Des" : "About Me" , "id" : idCheck , "Text" : headerValue , "Image" : headerICon], at: senderTag)
                senderTag = senderTag + 1
            }
            
            if idCheck == "500" {
                
                var dobMain = SharedManager.shared.userEditObj.dob
                if self.parentView.otherUserID.count > 0 {
                    dobMain = self.parentView.otherUserObj.dob
                }
                
                arrayIndex.append(IndexPath.init(row: senderTag, section: 1))
                self.arrayBottom.insert(["Type" : "501" , "Des" : "501" , "id" : idCheck , "Heading" : "Date Of Birth".localized() , "Text" : dobMain.changeDateString(inputformat: "yyyy-MM-dd", outputformat: "EEE dd, yyyy")], at: senderTag)
                senderTag = senderTag + 1
                
                
                var gender = SharedManager.shared.userEditObj.gender
                
                
                //                if gender.count == 0 {
                //                    gender = SharedManager.shared.userEditObj.pronoun + "(" + SharedManager.shared.userEditObj.custom_gender + ")"
                //                }
                
                if self.parentView.otherUserID.count > 0 {
                    gender = self.parentView.otherUserObj.gender
                }
                
                arrayIndex.append(IndexPath.init(row: senderTag, section: 1))
                self.arrayBottom.insert(["Type" : "501" , "Des" : "500" , "id" : idCheck , "Heading" : "Gender".localized() , "Text" : gender], at: senderTag)
                senderTag = senderTag + 1
                
                
                var genderPronounc = SharedManager.shared.userEditObj.genderPronounc
                if self.parentView.otherUserID.count > 0 {
                    genderPronounc = self.parentView.otherUserObj.genderPronounc
                }
                
                
                if genderPronounc.count > 0 {
                    arrayIndex.append(IndexPath.init(row: senderTag, section: 1))
                    self.arrayBottom.insert(["Type" : "501" , "Des" : "500" , "id" : idCheck , "Heading" : "Your pronoun".localized() , "Text" : genderPronounc], at: senderTag)
                    senderTag = senderTag + 1
                }
                
                
                
                var email = SharedManager.shared.userEditObj.email
                if self.parentView.otherUserID.count > 0 {
                    email = self.parentView.otherUserObj.email
                }
                
                
                arrayIndex.append(IndexPath.init(row: senderTag, section: 1))
                
                self.arrayBottom.insert(["Type" : "501" , "Des" : "500" , "id" : idCheck , "Heading" : "Email".localized() , "Text" : email], at: senderTag)
                senderTag = senderTag + 1
                
                
                var phone =  "("  + SharedManager.shared.userEditObj.countryCode + ")"  + SharedManager.shared.userEditObj.phone
                if self.parentView.otherUserID.count > 0 {
                    phone = "("  + self.parentView.otherUserObj.countryCode + ")"  + self.parentView.otherUserObj.phone
                }
                
                arrayIndex.append(IndexPath.init(row: senderTag, section: 1))
                
                self.arrayBottom.insert(["Type" : "501" , "Des" : "500" , "id" : idCheck , "Heading" : "Phone".localized() , "Text" : phone], at: senderTag)
                senderTag = senderTag + 1
                
                var address = SharedManager.shared.userEditObj.address
                if self.parentView.otherUserID.count > 0 {
                    address = self.parentView.otherUserObj.address
                }
                
                
                arrayIndex.append(IndexPath.init(row: senderTag, section: 1))
                
                self.arrayBottom.insert(["Type" : "501" , "Des" : "500" , "id" : idCheck , "Heading" : "Address".localized() , "Text" : address], at: senderTag)
                senderTag = senderTag + 1
                
                
                var city = SharedManager.shared.userEditObj.city
                if self.parentView.otherUserID.count > 0 {
                    city = self.parentView.otherUserObj.city
                }
                
                
                arrayIndex.append(IndexPath.init(row: senderTag, section: 1))
                
                self.arrayBottom.insert(["Type" : "501" , "Des" : "500" , "id" : idCheck , "Heading" : "City".localized() , "Text" : city], at: senderTag)
                senderTag = senderTag + 1
                
                
                var country = SharedManager.shared.userEditObj.country
                if self.parentView.otherUserID.count > 0 {
                    country = self.parentView.otherUserObj.country
                }
                
                arrayIndex.append(IndexPath.init(row: senderTag, section: 1))
                self.arrayBottom.insert(["Type" : "501" , "Des" : "500" , "id" : idCheck , "Heading" : "Country".localized() , "Text" : country], at: senderTag)
                senderTag = senderTag + 1
                var state = SharedManager.shared.userEditObj.state
                if self.parentView.otherUserID.count > 0 {
                    state = self.parentView.otherUserObj.state
                }
                arrayIndex.append(IndexPath.init(row: senderTag, section: 1))
                self.arrayBottom.insert(["Type" : "501" , "Des" : "500" , "id" : idCheck , "Heading" : "State/Province".localized() , "Text" : state], at: senderTag)
                senderTag = senderTag + 1
            } else if idCheck == "600" {
                if self.parentView.otherUserID.count > 0 {
                    for indexObj in 0..<self.parentView.otherUserObj.workExperiences.count {
                        arrayIndex.append(IndexPath.init(row: senderTag, section: 1))
                        self.arrayBottom.insert(["Type" : "601" , "Des" : "600" , "id" : idCheck , "indexObj" : String(indexObj)], at: senderTag)
                        senderTag = senderTag + 1
                    }
                }else {
                    for indexObj in 0..<SharedManager.shared.userEditObj.workExperiences.count {
                        arrayIndex.append(IndexPath.init(row: senderTag, section: 1))
                        self.arrayBottom.insert(["Type" : "601" , "Des" : "600" , "id" : idCheck , "indexObj" : String(indexObj)], at: senderTag)
                        senderTag = senderTag + 1
                    }
                }
            } else if idCheck == "1500" {// website
                if self.parentView.otherUserID.count > 0 {
                    for indexObj in 0..<self.parentView.otherUserObj.websiteArray.count {
                        arrayIndex.append(IndexPath.init(row: senderTag, section: 1))
                        self.arrayBottom.insert(["Type" : "604" , "Des" : "600" , "id" : idCheck , "indexObj" : String(indexObj)], at: senderTag)
                        senderTag = senderTag + 1
                    }
                }else {
                    for indexObj in 0..<SharedManager.shared.userEditObj.websiteArray.count {
                        arrayIndex.append(IndexPath.init(row: senderTag, section: 1))
                        self.arrayBottom.insert(["Type" : "604" , "Des" : "600" , "id" : idCheck , "indexObj" : String(indexObj)], at: senderTag)
                        senderTag = senderTag + 1
                    }
                }
            } else if idCheck == "1501" {// relationship
                if self.parentView.otherUserID.count > 0 {
                    for indexObj in 0..<self.parentView.otherUserObj.relationshipArray.count {
                        arrayIndex.append(IndexPath.init(row: senderTag, section: 1))
                        self.arrayBottom.insert(["Type" : "602" , "Des" : "600" , "id" : idCheck , "indexObj" : String(indexObj)], at: senderTag)
                        senderTag = senderTag + 1
                    }
                } else {
                    for indexObj in 0..<SharedManager.shared.userEditObj.relationshipArray.count {
                        arrayIndex.append(IndexPath.init(row: senderTag, section: 1))
                        self.arrayBottom.insert(["Type" : "602" , "Des" : "600" , "id" : idCheck , "indexObj" : String(indexObj)], at: senderTag)
                        senderTag = senderTag + 1
                    }
                }
            }
            else if idCheck == "1502" { // family relationship
                if self.parentView.otherUserID.count > 0 {
                    for indexObj in 0..<self.parentView.otherUserObj.familyRelationshipArray.count {
                        arrayIndex.append(IndexPath.init(row: senderTag, section: 1))
                        self.arrayBottom.insert(["Type" : "603" , "Des" : "600" , "id" : idCheck , "indexObj" : String(indexObj)], at: senderTag)
                        senderTag = senderTag + 1
                    }
                }else {
                    for indexObj in 0..<SharedManager.shared.userEditObj.familyRelationshipArray.count {
                        arrayIndex.append(IndexPath.init(row: senderTag, section: 1))
                        self.arrayBottom.insert(["Type" : "603" , "Des" : "600" , "id" : idCheck , "indexObj" : String(indexObj)], at: senderTag)
                        senderTag = senderTag + 1
                    }
                }
            } else if idCheck == "1503" { // currency
                if self.parentView.otherUserID.count > 0 {
                    let currencyName = self.parentView.otherUserObj.currency?.name ?? .emptyString
                    let currencySymbol = self.parentView.otherUserObj.currency?.symbol ?? .emptyString
                    let currencyFullName = currencyName + " - " + currencySymbol
                    arrayIndex.append(IndexPath.init(row: senderTag, section: 1))
                    self.arrayBottom.insert(["Type" : "901" , "Des" : "900" , "id" : idCheck , "indexObj" : currencyFullName], at: senderTag)
                    senderTag = senderTag + 1
                }else {
                    let currencyName = SharedManager.shared.userEditObj.currency?.name ?? .emptyString
                    let currencySymbol = SharedManager.shared.userEditObj.currency?.symbol ?? .emptyString
                    let currencyFullName = currencyName + " - " + currencySymbol
                    arrayIndex.append(IndexPath.init(row: senderTag, section: 1))
                    self.arrayBottom.insert(["Type" : "901" , "Des" : "900" , "id" : idCheck , "indexObj" : currencyFullName], at: senderTag)
                    senderTag = senderTag + 1
                }
            } else if idCheck == "1504" { // group
                if self.parentView.otherUserID.count > 0 {
                    for indexObj in 0..<self.parentView.otherUserObj.groupArray.count {
                        arrayIndex.append(IndexPath.init(row: senderTag, section: 1))
                        self.arrayBottom.insert(["Type" : "1200" , "Des" : "900" , "id" : idCheck , "indexObj" : String(indexObj)], at: senderTag)
                        senderTag = senderTag + 1
                    }
                } else {
                    for indexObj in 0..<SharedManager.shared.userEditObj.groupArray.count {
                        arrayIndex.append(IndexPath.init(row: senderTag, section: 1))
                        self.arrayBottom.insert(["Type" : "1200" , "Des" : "900" , "id" : idCheck , "indexObj" : String(indexObj)], at: senderTag)
                        senderTag = senderTag + 1
                    }
                }
            }
            
            else if idCheck == "1505" {// Life Category Event
                if self.parentView.otherUserID.count > 0 {
                    for indexObj in 0..<self.parentView.otherUserObj.userLifeEventsArray.count {
                        arrayIndex.append(IndexPath.init(row: senderTag, section: 1))
                        self.arrayBottom.insert(["Type" : "606" , "Des" : "600" , "id" : idCheck , "indexObj" : String(indexObj)], at: senderTag)
                        senderTag = senderTag + 1
                    }
                }else {
                    for indexObj in 0..<SharedManager.shared.userEditObj.userLifeEventsArray.count {
                        arrayIndex.append(IndexPath.init(row: senderTag, section: 1))
                        self.arrayBottom.insert(["Type" : "606" , "Des" : "600" , "id" : idCheck , "indexObj" : String(indexObj)], at: senderTag)
                        senderTag = senderTag + 1
                    }
                }
            }
            else  if idCheck == "1000" {
                if self.parentView.otherUserID.count > 0 {
                    for indexObj in 0..<self.parentView.otherUserObj.institutes.count {
                        arrayIndex.append(IndexPath.init(row: senderTag, section: 1))
                        self.arrayBottom.insert(["Type" : "1001" , "Des" : "1000" , "id" : idCheck , "indexObj" : String(indexObj)], at: senderTag)
                        senderTag = senderTag + 1
                    }
                }else {
                    for indexObj in 0..<SharedManager.shared.userEditObj.institutes.count {
                        arrayIndex.append(IndexPath.init(row: senderTag, section: 1))
                        self.arrayBottom.insert(["Type" : "1001" , "Des" : "1000" , "id" : idCheck , "indexObj" : String(indexObj)], at: senderTag)
                        senderTag = senderTag + 1
                    }
                }
            }else  if idCheck == "700" {
                if self.parentView.otherUserID.count > 0 {
                    for indexObj in 0..<self.parentView.otherUserObj.places.count {
                        arrayIndex.append(IndexPath.init(row: senderTag, section: 1))
                        self.arrayBottom.insert(["Type" : "701" , "Des" : "700" , "id" : idCheck , "indexObj" : String(indexObj)], at: senderTag)
                        senderTag = senderTag + 1
                    }
                }else {
                    for indexObj in 0..<SharedManager.shared.userEditObj.places.count {
                        arrayIndex.append(IndexPath.init(row: senderTag, section: 1))
                        self.arrayBottom.insert(["Type" : "701" , "Des" : "700" , "id" : idCheck , "indexObj" : String(indexObj)], at: senderTag)
                        senderTag = senderTag + 1
                    }
                }
            } else  if idCheck == "900" {
                if self.parentView.otherUserID.count > 0 {
                    var interestValue = ""
                    for indexObj in 0..<self.parentView.otherUserObj.InterestArray.count {
                        if interestValue.count > 0 {
                            interestValue = interestValue + ", " + self.parentView.otherUserObj.InterestArray[indexObj].name
                        }else {
                            interestValue = self.parentView.otherUserObj.InterestArray[indexObj].name
                        }
                    }
                    if self.parentView.otherUserObj.InterestArray.count > 0 {
                        arrayIndex.append(IndexPath.init(row: senderTag, section: 1))
                        self.arrayBottom.insert(["Type" : "901" , "Des" : "900" , "id" : idCheck , "indexObj" : interestValue], at: senderTag)
                        senderTag = senderTag + 1
                    }
                }else {
                    var interestValue = ""
                    for indexObj in 0..<SharedManager.shared.userEditObj.InterestArray.count {
                        if interestValue.count > 0 {
                            interestValue = interestValue + ", " + SharedManager.shared.userEditObj.InterestArray[indexObj].name
                        }else {
                            interestValue = SharedManager.shared.userEditObj.InterestArray[indexObj].name
                        }
                    }
                    arrayIndex.append(IndexPath.init(row: senderTag, section: 1))
                    self.arrayBottom.insert(["Type" : "901" , "Des" : "900" , "id" : idCheck , "indexObj" : interestValue], at: senderTag)
                    senderTag = senderTag + 1
                }
            } else  if idCheck == "1200" { // languages
                if self.parentView.otherUserID.count > 0 {
                    var languageValue = ""
                    for indexObj in 0..<self.parentView.otherUserObj.languayeArray.count {
                        if languageValue.count > 0 {
                            languageValue = languageValue + ", " + self.arrayLanguage[indexObj].languageName
                        } else {
                            languageValue = self.parentView.otherUserObj.languayeArray[indexObj].languageName
                        }
                    }
                    if self.parentView.otherUserObj.languayeArray.count > 0 {
                        arrayIndex.append(IndexPath.init(row: senderTag, section: 1))
                        self.arrayBottom.insert(["Type" : "901" , "Des" : "900" , "id" : idCheck , "indexObj" : languageValue], at: senderTag)
                        senderTag = senderTag + 1
                    }
                }else {
                    var languageValue = ""
                    for indexObj in 0..<SharedManager.shared.userEditObj.languayeArray.count {
                        if languageValue.count > 0 {
                            languageValue = languageValue + ", " + SharedManager.shared.userEditObj.languayeArray[indexObj].languageName
                        }else {
                            languageValue = SharedManager.shared.userEditObj.languayeArray[indexObj].languageName
                        }
                    }
                    arrayIndex.append(IndexPath.init(row: senderTag, section: 1))
                    self.arrayBottom.insert(["Type" : "901" , "Des" : "900" , "id" : idCheck , "indexObj" : languageValue], at: senderTag)
                    senderTag = senderTag + 1
                }
            }
            else  if idCheck == "1101" { //sports
                if self.parentView.otherUserID.count > 0 {
                    for indexObj in 0..<self.parentView.otherUserObj.sportArray.count {
                        arrayIndex.append(IndexPath.init(row: senderTag, section: 1))
                        self.arrayBottom.insert(["Type" : "1100" , "Des" : "900" , "id" : idCheck , "indexObj" : String(indexObj)], at: senderTag)
                        senderTag = senderTag + 1
                    }
                } else {
                    for indexObj in 0..<SharedManager.shared.userEditObj.sportArray.count {
                        arrayIndex.append(IndexPath.init(row: senderTag, section: 1))
                        self.arrayBottom.insert(["Type" : "1100" , "Des" : "900" , "id" : idCheck , "indexObj" : String(indexObj)], at: senderTag)
                        senderTag = senderTag + 1
                    }
                }
            }
            else  if idCheck == "1102" { //movie
                if self.parentView.otherUserID.count > 0 {
                    for indexObj in 0..<self.parentView.otherUserObj.movieArray.count {
                        arrayIndex.append(IndexPath.init(row: senderTag, section: 1))
                        self.arrayBottom.insert(["Type" : "1100" , "Des" : "900" , "id" : idCheck , "indexObj" : String(indexObj)], at: senderTag)
                        senderTag = senderTag + 1
                    }
                } else {
                    for indexObj in 0..<SharedManager.shared.userEditObj.movieArray.count {
                        arrayIndex.append(IndexPath.init(row: senderTag, section: 1))
                        self.arrayBottom.insert(["Type" : "1100" , "Des" : "900" , "id" : idCheck , "indexObj" : String(indexObj)], at: senderTag)
                        senderTag = senderTag + 1
                    }
                }
            } else if idCheck == "1103" { //tv
                if self.parentView.otherUserID.count > 0 {
                    for indexObj in 0..<self.parentView.otherUserObj.tvShowArray.count {
                        arrayIndex.append(IndexPath.init(row: senderTag, section: 1))
                        self.arrayBottom.insert(["Type" : "1100" , "Des" : "900" , "id" : idCheck , "indexObj" : String(indexObj)], at: senderTag)
                        senderTag = senderTag + 1
                    }
                } else {
                    for indexObj in 0..<SharedManager.shared.userEditObj.tvShowArray.count {
                        arrayIndex.append(IndexPath.init(row: senderTag, section: 1))
                        self.arrayBottom.insert(["Type" : "1100" , "Des" : "900" , "id" : idCheck , "indexObj" : String(indexObj)], at: senderTag)
                        senderTag = senderTag + 1
                    }
                }
            } else  if idCheck == "1104" { // books
                if self.parentView.otherUserID.count > 0 {
                    for indexObj in 0..<self.parentView.otherUserObj.bookArray.count {
                        arrayIndex.append(IndexPath.init(row: senderTag, section: 1))
                        self.arrayBottom.insert(["Type" : "1100" , "Des" : "900" , "id" : idCheck , "indexObj" : String(indexObj)], at: senderTag)
                        senderTag = senderTag + 1
                    }
                } else {
                    for indexObj in 0..<SharedManager.shared.userEditObj.bookArray.count {
                        arrayIndex.append(IndexPath.init(row: senderTag, section: 1))
                        self.arrayBottom.insert(["Type" : "1100" , "Des" : "900" , "id" : idCheck , "indexObj" : String(indexObj)], at: senderTag)
                        senderTag = senderTag + 1
                    }
                }
            }  else if idCheck == "1105" { // games
                if self.parentView.otherUserID.count > 0 {
                    for indexObj in 0..<self.parentView.otherUserObj.gameArray.count {
                        arrayIndex.append(IndexPath.init(row: senderTag, section: 1))
                        self.arrayBottom.insert(["Type" : "1100" , "Des" : "900" , "id" : idCheck , "indexObj" : String(indexObj)], at: senderTag)
                        senderTag = senderTag + 1
                    }
                } else {
                    for indexObj in 0..<SharedManager.shared.userEditObj.gameArray.count {
                        arrayIndex.append(IndexPath.init(row: senderTag, section: 1))
                        self.arrayBottom.insert(["Type" : "1100" , "Des" : "900" , "id" : idCheck , "indexObj" : String(indexObj)], at: senderTag)
                        senderTag = senderTag + 1
                    }
                }
            }   else if idCheck == "1106" { // athlete
                if self.parentView.otherUserID.count > 0 {
                    for indexObj in 0..<self.parentView.otherUserObj.athleteArray.count {
                        arrayIndex.append(IndexPath.init(row: senderTag, section: 1))
                        self.arrayBottom.insert(["Type" : "1100" , "Des" : "900" , "id" : idCheck , "indexObj" : String(indexObj)], at: senderTag)
                        senderTag = senderTag + 1
                    }
                } else {
                    for indexObj in 0..<SharedManager.shared.userEditObj.athleteArray.count {
                        arrayIndex.append(IndexPath.init(row: senderTag, section: 1))
                        self.arrayBottom.insert(["Type" : "1100" , "Des" : "900" , "id" : idCheck , "indexObj" : String(indexObj)], at: senderTag)
                        senderTag = senderTag + 1
                    }
                }
            }   else if idCheck == "1107" { // music
                if self.parentView.otherUserID.count > 0 {
                    for indexObj in 0..<self.parentView.otherUserObj.musicArray.count {
                        arrayIndex.append(IndexPath.init(row: senderTag, section: 1))
                        self.arrayBottom.insert(["Type" : "1100" , "Des" : "900" , "id" : idCheck , "indexObj" : String(indexObj)], at: senderTag)
                        senderTag = senderTag + 1
                    }
                } else {
                    for indexObj in 0..<SharedManager.shared.userEditObj.musicArray.count {
                        arrayIndex.append(IndexPath.init(row: senderTag, section: 1))
                        self.arrayBottom.insert(["Type" : "1100" , "Des" : "900" , "id" : idCheck , "indexObj" : String(indexObj)], at: senderTag)
                        senderTag = senderTag + 1
                    }
                }
            } else {
                self.arrayBottom.insert(["Type" : "100" , "Des" : "About Me" , "id" : idCheck], at: senderTag)
                arrayIndex.append(IndexPath.init(row: senderTag, section: 1))
                senderTag = senderTag + 1
            }
            self.feedtble.beginUpdates()
            self.feedtble.insertRows(at: arrayIndex, with: .automatic)
            self.feedtble.endUpdates()
        } else {
            var arrayBottomCopy = [[String : String]]()
            for indexObj in 0..<self.arrayBottom.count {
                if self.arrayBottom[indexObj]["id"] == idCheck {
                    arrayIndex.append(IndexPath.init(row: indexObj, section: 1))
                } else {
                    arrayBottomCopy.append(self.arrayBottom[indexObj])
                }
            }
            self.arrayBottom = arrayBottomCopy
            self.feedtble.beginUpdates()
            self.feedtble.deleteRows(at: arrayIndex, with: .none)
            self.feedtble.endUpdates()
        }
        
        UIView.setAnimationsEnabled(false)
        self.feedtble.beginUpdates()
        self.feedtble.reloadData()
        self.feedtble.endUpdates()
        UIView.setAnimationsEnabled(true)
    }
    
    func ProfileUserBasicinfoCell(tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //        let cellUserTab = tableView.dequeueReusableCell(withIdentifier: "ProfileUserBasicinfoCell", for: indexPath) as! ProfileUserBasicinfoCell
        
        guard let cellUserTab = tableView.dequeueReusableCell(withIdentifier: "ProfileUserBasicinfoCell", for: indexPath) as? ProfileUserBasicinfoCell else {
            return UITableViewCell()
        }
        if self.arrayBottom[indexPath.row]["id"] == "1" {
            
            cellUserTab.lblInfo.text = "Lives in".localized()
            
            var userMain : UserProfile!
            
            if self.parentView.otherUserID.count > 0 {
                userMain = self.parentView.otherUserObj
                
                
            }else {
                userMain = SharedManager.shared.userEditObj
                //                cellUserTab.lblDetailInfo.text = SharedManager.shared.userEditObj.state + ", " + SharedManager.shared.userEditObj.country
            }
            
            if userMain.state.count == 0 {
                if userMain.country.count == 0 {
                    cellUserTab.lblDetailInfo.text = ""
                }else {
                    cellUserTab.lblDetailInfo.text =  userMain.country
                }
                
            }else {
                if userMain.country.count == 0 {
                    cellUserTab.lblDetailInfo.text = userMain.state
                }else {
                    cellUserTab.lblDetailInfo.text = userMain.state + ", " + userMain.country
                }
            }
            
            cellUserTab.imgViewMain.image = UIImage.init(named: "LiveIcon")
        }else if self.arrayBottom[indexPath.row]["id"] == "2" {
            cellUserTab.lblInfo.text = "Work in"
            if self.parentView.otherUserID.count > 0 {
                cellUserTab.lblDetailInfo.text =  self.parentView.otherUserObj.city + ", " + self.parentView.otherUserObj.country
            }else {
                cellUserTab.lblDetailInfo.text =  SharedManager.shared.userEditObj.city + ", " + SharedManager.shared.userEditObj.country
            }
            
            cellUserTab.imgViewMain.image = UIImage.init(named: "WorkIcon")
        } else if self.arrayBottom[indexPath.row]["id"] == "3" {
            cellUserTab.lblInfo.text = "Form"
            if self.parentView.otherUserID.count > 0 {
                cellUserTab.lblDetailInfo.text =  self.parentView.otherUserObj.city + ", " + self.parentView.otherUserObj.country
            }else {
                cellUserTab.lblDetailInfo.text =  SharedManager.shared.userEditObj.city + ", " + SharedManager.shared.userEditObj.country
            }
            
            cellUserTab.imgViewMain.image = UIImage.init(named: "LocationIcon")
        } else if self.arrayBottom[indexPath.row]["id"] == "4" {
            cellUserTab.lblInfo.text = ""
            cellUserTab.lblDetailInfo.text = SharedManager.shared.userEditObj.gender
            cellUserTab.imgViewMain.image = UIImage.init(named: "MarriedIcon")
        }
        if self.parentView.otherUserID.count > 0 {
            
        }else {
            
        }
        
        self.parentView.view.labelRotateCell(viewMain: cellUserTab.lblInfo)
        cellUserTab.lblInfo.rotateForTextAligment()
        
        self.parentView.view.labelRotateCell(viewMain: cellUserTab.lblDetailInfo)
        cellUserTab.lblDetailInfo.rotateForTextAligment()
        
        
        cellUserTab.btnEdit.tag = indexPath.row
        cellUserTab.btnEdit.addTarget(self, action: #selector(self.showEditLocaiton), for: .touchUpInside)
        cellUserTab.selectionStyle = .none
        
        return cellUserTab
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if self.arrayBottom.count <= indexPath.row {
            return
        }
        LogClass.debugLog(self.arrayBottom[indexPath.row])
        if selectedTab == .friends {
            if self.arrayContactGroupSearch.count - 1  < indexPath.row-1 {
                let valueUser = self.arrayContactGroupSearch[indexPath.row-1]
                contactGroupProfileCompletion?(valueUser)
            }
            
        }
        if self.arrayBottom[indexPath.row]["Type"] == "1100"
        {
            if let id = self.arrayBottom[indexPath.row]["id"], let index = Int(self.arrayBottom[indexPath.row]["indexObj"] ?? "-1"), index >= 0
            {
                var obj : LikePageModel?
                var categoryType: String?
                if id == "1101" { //sports
                    //                    obj = self.arraySports[index]
                    obj = SharedManager.shared.userEditObj.sportArray[index]
                    categoryType = "sport"
                }
                else if id == "1102" { //movie
                    obj = SharedManager.shared.userEditObj.movieArray[index]
                    categoryType = "movie"
                }
                else if id == "1103" { //tv
                    obj = SharedManager.shared.userEditObj.tvShowArray[index]
                    categoryType = "tv"
                }
                else if id == "1104" { //book
                    obj = SharedManager.shared.userEditObj.bookArray[index]
                    categoryType = "book"
                } else if id == "1105" { // games
                    obj = SharedManager.shared.userEditObj.gameArray[index]
                    categoryType = "game"
                } else if id == "1106" { // athlete
                    obj = SharedManager.shared.userEditObj.athleteArray[index]
                    categoryType = "athlete"
                } else if id == "1107" { // music
                    obj = SharedManager.shared.userEditObj.musicArray[index]
                    categoryType = "music"
                }
                if let pageData = obj {
                    _ = self.arrayBottom[indexPath.row]["id"]
                    self.openLikePage?(pageData, categoryType)
                }
            }
        } else if self.arrayBottom[indexPath.row]["Type"] == "1200" {
            if let id = self.arrayBottom[indexPath.row]["id"], let index = Int(self.arrayBottom[indexPath.row]["indexObj"] ?? "-1"), index >= 0 {
                self.groupCompletion?(SharedManager.shared.userEditObj.groupArray[index], "group")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.selectedTab == .aboutMe {
            if self.arrayBottom[indexPath.row]["Type"] == "101" {
                if self.parentView.otherUserID.count > 0 {
                    return 0.0
                }
            }
        }
        
        if indexPath.section == 0 {
            if indexPath.row == 3 {
                return 100.0
            }
            return UITableView.automaticDimension
        }
        
        if self.selectedTab == .timeline {
            if self.feedArray.count > indexPath.row {
                if self.feedArray[indexPath.row].postType == FeedType.Ad.rawValue {
                    return 150.0
                }
            }
        } else {
            if self.feedArray.count > indexPath.row {
                if self.feedArray[indexPath.row].postType == FeedType.Ad.rawValue {
                    return 150.0
                }
            }
        }
        
        if self.selectedTab != .timeline {
            return UITableView.automaticDimension
        }
        
        if self.feedArray.count > 0 {
            let feedObj: FeedData = self.feedArray[indexPath.row] as FeedData
            let cellHeight = feedObj.isExpand ? feedObj.cellHeightExpand ?? 0 : feedObj.cellHeight ?? 0
            switch feedObj.postType {
            case FeedType.post.rawValue, FeedType.audio.rawValue, FeedType.gallery.rawValue, FeedType.video.rawValue, FeedType.liveStream.rawValue, FeedType.image.rawValue, FeedType.shared.rawValue, FeedType.file.rawValue:
                return UITableView.automaticDimension
            case FeedType.Ad.rawValue:
                return 150.0
            default:
                return 0
            }
        }
        return UITableView.automaticDimension
        
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0 {
            
            if indexPath.row == 3 {
                return 100.0
            }
            
            return UITableView.automaticDimension
        }
        
        if self.selectedTab == .timeline {
            if self.feedArray.count > indexPath.row {
                if self.feedArray[indexPath.row].postType == FeedType.Ad.rawValue {
                    return 150.0
                }
            }
            
        }
        
        
        if self.selectedTab != .timeline {
            return UITableView.automaticDimension
        }
        
        if self.feedArray.count > 0 {
            let feedObj:FeedData = self.feedArray[indexPath.row] as FeedData
            switch feedObj.postType! {
            case FeedType.post.rawValue, FeedType.audio.rawValue, FeedType.gallery.rawValue, FeedType.video.rawValue, FeedType.image.rawValue, FeedType.liveStream.rawValue, FeedType.shared.rawValue, FeedType.file.rawValue:
                return UITableView.automaticDimension
            case FeedType.Ad.rawValue:
                return 150.0
            default:
                return 0
            }
        }
        return UITableView.automaticDimension
    }
    
    // Begin and update
    func beginAndEndUpdate(tableView:UITableView){
        DispatchQueue.main.async {
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
    
    //Manage pagging
    func isFeedReachEnd(indexPath:IndexPath){
        if  self.isNextFeedExist {
            let feedCurrentCount = self.feedArray.count
            if indexPath.row == feedCurrentCount-1 {
                let postObj:FeedData = self.feedArray[indexPath.row] as FeedData
                self.callingFeedService(lastPostID: String(postObj.postID!), isLastTrue: true, isRefresh: false)
            }
        }
    }
    
    func callingFeedService(lastPostID: String, isLastTrue: Bool, isRefresh: Bool) {
        
        
        
        let userToken = SharedManager.shared.userToken()
        self.showloadingBar?()
        var parameters = ["action": "profile/newsfeed", "token": userToken]
        if isLastTrue {
            parameters["starting_point_id"] = lastPostID
        }
        
        if self.parentView != nil {
            if self.parentView.otherUserID.count > 0 {
                parameters["user_id"] = self.parentView.otherUserID
            }
        }
        
        RequestManagerGen.fetchDataGet(Completion: { (response: Result<(FeedModel), Error>) in
            
            //            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            
            self.isFeedAPICall = false
            switch response {
            case .failure(let error):
                if error is ErrorModel  {
                    let err = error as! ErrorModel
                    if err.meta?.message == "Newsfeed not found" {
                        self.hideFooterClosure?()
                        self.isNextFeedExist = false
                        self.hideSkeletonClosure?()
                    }
                    if  self.isNextFeedExist {
                        self.showAlertMessageClosure?((err.meta?.message)!)
                    }
                } else {
                    self.showAlertMessageClosure?(Const.networkProblemMessage)
                }
            case .success(let res):
                self.handleFeedResponse(feedObj: res, isRefresh: isRefresh)
            }
        }, param:parameters)
    }
    
    func handleFeedResponse(feedObj: FeedModel, isRefresh: Bool) {
        
        if let isFeedData = feedObj.data {
            if isFeedData.count == 0 {
                self.isNextFeedExist = false
            } else {
                if isRefresh {
                    self.feedArray.removeAll()
                }
                
                var newArray = [FeedData]()
                
                for indexObj in self.feedArray {
                    if indexObj.postType != FeedType.Ad.rawValue {
                        newArray.append(indexObj)
                    }
                }
                
                for objectmain in isFeedData {
                    
                    var textHeight = 140.0 + 75
                    var textHeightExpand = 140.0 + 75
                    
                    
                    var heightText = 0.0
                    var heightTextExpand = 0.0
                    
                    
                    if objectmain.body != nil {
                        
                        if objectmain.body!.count > 0 {
                            let heightBody = objectmain.body!.heightString(withConstrainedWidth: UIScreen.main.bounds.size.width - 15, font: UIFont.systemFont(ofSize: 20.0))
                            
                            if heightBody < 25 {
                                heightText = 65 + heightBody
                                heightTextExpand = 65 + heightBody
                            }else {
                                
                                if heightBody < 60 {
                                    heightText = 55 + heightBody
                                }else {
                                    heightText = 55 + 60
                                }
                                
                                
                                heightTextExpand = 55 + heightBody
                            }
                        }
                    }
                    
                    if objectmain.postType == FeedType.video.rawValue ||
                        objectmain.postType == FeedType.gif.rawValue ||
                        objectmain.postType == FeedType.liveStream.rawValue {
                        textHeight = 480 + heightText
                        textHeightExpand = 480 + heightTextExpand
                    } else if objectmain.postType == FeedType.file.rawValue{
                        textHeight = 250 + heightText
                        textHeightExpand = 250 + heightTextExpand
                        
                    } else if objectmain.postType == FeedType.post.rawValue{
                        textHeight = 150 + heightText
                        textHeightExpand = 150 + heightTextExpand
                        //                        if objectmain.linkImage != nil {
                        //                            if objectmain.linkImage!.count > 0 {
                        //                                textHeight = textHeight + 250.0
                        //                            }
                        //                        }
                        
                        if objectmain.linkImage != nil {
                            if objectmain.linkImage!.count > 0 {
                                textHeight = textHeight + 250.0
                                textHeightExpand = 250 + heightTextExpand
                            }else if objectmain.linkTitle!.count > 0 {
                                textHeight = textHeight + 100.0
                                textHeightExpand = 100.0 + heightTextExpand
                            }
                        }else if objectmain.linkTitle != nil  {
                            if objectmain.linkTitle!.count > 0 {
                                textHeight = textHeight + 100.0
                                textHeightExpand = 100.0 + heightTextExpand
                            }
                        }
                        
                    }else if objectmain.postType == FeedType.image.rawValue{
                        textHeight = 480 + heightText
                        textHeightExpand = 480 + heightTextExpand
                        
                    }else if objectmain.postType == FeedType.audio.rawValue{
                        textHeight = 210 + heightText
                        textHeightExpand = 210 + heightTextExpand
                        
                    }else if objectmain.postType == FeedType.gallery.rawValue{
                        textHeight = 450 + heightText
                        textHeightExpand = 450 + heightTextExpand
                        //                    }else if objectmain.linkImage != nil {
                        //                        if objectmain.linkImage!.count > 0 {
                        //                            textHeight = textHeight + 250.0
                        //                            textHeightExpand = 250 + heightTextExpand
                        //                        }
                    }else if objectmain.linkImage != nil {
                        if objectmain.linkImage!.count > 0 {
                            textHeight = textHeight + 250.0
                            textHeightExpand = 250 + heightTextExpand
                        }else if objectmain.linkTitle!.count > 0 {
                            textHeight = textHeight + 100.0
                            textHeightExpand = 100.0 + heightTextExpand
                        }
                    }else if objectmain.linkTitle != nil  {
                        if objectmain.linkTitle!.count > 0 {
                            textHeight = textHeight + 100.0
                            textHeightExpand = 100.0 + heightTextExpand
                        }
                    }
                    objectmain.cellHeight =  textHeight
                    objectmain.cellHeightExpand =  textHeightExpand
                    
                }
                newArray.append(contentsOf: isFeedData)
                self.feedArray.removeAll()
                for indexObj in 0..<newArray.count {
                    let objectmain = newArray[indexObj]
                    if indexObj % 10 == 0 && indexObj > 0 {
                        if (self.parentView as? ProfileViewController) != nil  {
                            let mainData = [String : Any]()
                            let newFeed = FeedData.init(valueDict: mainData)
                            newFeed.postType = FeedType.Ad.rawValue
                            newFeed.cellHeight = 150.0
                            self.feedArray.append(newFeed)
                        }
                    }
                    self.feedArray.append(objectmain)
                }
            }
        }
        
        self.refreshControl.endRefreshing()
        self.reloadTableViewClosure?()
    }
    
    func videoPlayerCallbackHandler()   {
    }
}

extension ProfileViewModel : ProfileTabSelectionDelegate {
    
    func profileTabSelection(tabValue : Int) {
        
        self.arrayImage.removeAll()
        self.arrayImageLocal.removeAll()
        self.arrayVideoLocal.removeAll()
        self.arrayVideo.removeAll()
        self.arrayVideoforTable.removeAll()
        self.videoforTable.removeAll()
        // reel
        self.myReelsList.removeAll()
        self.savedReelsList.removeAll()
        //
        self.arrayBottom.removeAll()
        if tabValue == 1 {
            selectedTab = .timeline
        } else if tabValue == 2 {
            self.arrayBottom.append(["Type" : "1" , "Des" : "About Me".localized()])
            self.arrayBottom.append(["Type" : "2" , "Des" : "Live".localized() , "id" : "1"])
            self.arrayBottom.append(["Type" : "3" , "Des" : "Heading" , "Text" : "Overview".localized() , "isExpand" : "0", "id" : "5"])
            self.arrayBottom.append(["Type" : "3" , "Des" : "Heading" , "Text" : "Work".localized(), "isExpand" : "0", "id" : "6"])
            self.arrayBottom.append(["Type" : "3" , "Des" : "Heading" , "Text" : "Education".localized(), "isExpand" : "0", "id" : "10"])
            self.arrayBottom.append(["Type" : "3" , "Des" : "Heading" , "Text" : "Places you've lived".localized(), "isExpand" : "0", "id" : "7"])
            self.arrayBottom.append(["Type" : "3" , "Des" : "Heading" , "Text" : "Interest".localized(), "isExpand" : "0", "id" : "9"])
            self.arrayBottom.append(["Type" : "3" , "Des" : "Heading" , "Text" : "Website".localized(), "isExpand" : "0", "id" : "33"])
            self.arrayBottom.append(["Type" : "3" , "Des" : "Heading" , "Text" : "Relationship".localized(), "isExpand" : "0", "id" : "34"])
            self.arrayBottom.append(["Type" : "3" , "Des" : "Heading" , "Text" : "Family Relationship".localized(), "isExpand" : "0", "id" : "35"])
            self.arrayBottom.append(["Type" : "3" , "Des" : "Heading" , "Text" : "Language".localized(), "isExpand" : "0", "id" : "20"])
            self.arrayBottom.append(["Type" : "3" , "Des" : "Heading" , "Text" : "Currency".localized(), "isExpand" : "0", "id" : "36"])
            self.arrayBottom.append(["Type" : "3" , "Des" : "Heading" , "Text" : "Groups".localized(), "isExpand" : "0", "id" : "37"]) // pending
            // self.arrayBottom.append(["Type" : "3" , "Des" : "Heading" , "Text" : "Life Events".localized(), "isExpand" : "0", "id" : "38"]) // pending
            self.arrayBottom.append(["Type" : "3" , "Des" : "Heading" , "Text" : "Sports".localized(), "isExpand" : "0", "id" : "39"]) // sport
            self.arrayBottom.append(["Type" : "3" , "Des" : "Heading" , "Text" : "Movie".localized(), "isExpand" : "0", "id" : "40"]) // movie
            self.arrayBottom.append(["Type" : "3" , "Des" : "Heading" , "Text" : "TV".localized(), "isExpand" : "0", "id" : "41"]) // tv
            self.arrayBottom.append(["Type" : "3" , "Des" : "Heading" , "Text" : "Books".localized(), "isExpand" : "0", "id" : "42"]) // book
            self.arrayBottom.append(["Type" : "3" , "Des" : "Heading" , "Text" : "Games".localized(), "isExpand" : "0", "id" : "43"]) // game
            self.arrayBottom.append(["Type" : "3" , "Des" : "Heading" , "Text" : "Athlete".localized(), "isExpand" : "0", "id" : "44"]) // Athlete
            self.arrayBottom.append(["Type" : "3" , "Des" : "Heading" , "Text" : "Music".localized(), "isExpand" : "0", "id" : "45"]) // Music
            
            
            selectedTab = .aboutMe
        } else if tabValue == 3 {
            selectedTab = .photos
            self.arrayImage.removeAll()
            self.arrayImageLocal.removeAll()
            self.getUserImages()
        } else if tabValue == 4 {
            selectedTab = .videos
            self.arrayVideoLocal.removeAll()
            self.arrayVideo.removeAll()
            self.arrayVideoforTable.removeAll()
            self.videoforTable.removeAll()
            self.getUserVideo()
        } else if tabValue == 5 {
            selectedTab = .friends
            //            self.texttoshow = "1"
            self.getContact()
            
        } else if tabValue == 6 {
            selectedTab = .myReels
            self.reelPageNumber =  1
            self.isNextVideoExist = true
            self.getMyReels()
            
        } else if tabValue == 7 {
            selectedTab = .savedReels
            self.reelPageNumber =  1
            self.isNextVideoExist = true
            self.getSavedReels()
        }
        
        self.reloadTableViewWithNoneClosure?()
    }
    
    func profileRefreshTabSelection(tabValue : Int , refreshValue : Int) {
        
        LogClass.debugLog("profileRefreshTabSelection  ====>")
        
        if refreshValue == 9 {
            var rowIndex = 0
            var NewarrayBottom = [[String : String]]()
            for indexObj in 0..<self.arrayBottom.count {
                if self.arrayBottom[indexObj]["Type"] == "901" {
                } else {
                    if self.arrayBottom[indexObj]["id"] == "9" {
                        rowIndex = indexObj
                    }
                    NewarrayBottom.append(self.arrayBottom[indexObj])
                }
            }
            var idCheck = ""
            self.arrayBottom = NewarrayBottom
            idCheck = "900"
            var arrayIndex = [IndexPath]()
            var senderTag = rowIndex + 1
            if self.parentView.otherUserID.count > 0 {
                var interestValue = ""
                for indexObj in 0..<self.parentView.otherUserObj.InterestArray.count {
                    if interestValue.count > 0 {
                        interestValue = interestValue + ", " + self.parentView.otherUserObj.InterestArray[indexObj].name
                    }else {
                        interestValue = self.parentView.otherUserObj.InterestArray[indexObj].name
                    }
                }
                if self.parentView.otherUserObj.InterestArray.count > 0 {
                    arrayIndex.append(IndexPath.init(row: senderTag, section: 1))
                    self.arrayBottom.insert(["Type" : "901" , "Des" : "900" , "id" : idCheck , "indexObj" : interestValue], at: senderTag)
                    senderTag = senderTag + 1
                }
            } else {
                var interestValue = ""
                for indexObj in 0..<SharedManager.shared.userEditObj.InterestArray.count {
                    if interestValue.count > 0 {
                        interestValue = interestValue + ", " + SharedManager.shared.userEditObj.InterestArray[indexObj].name
                    }else {
                        interestValue = SharedManager.shared.userEditObj.InterestArray[indexObj].name
                    }
                    
                }
                // for indexObj in 0..<SharedManager.shared.userEditObj.InterestArray.count {
                arrayIndex.append(IndexPath.init(row: senderTag, section: 1))
                self.arrayBottom.insert(["Type" : "901" , "Des" : "700" , "id" : idCheck , "indexObj" : interestValue], at: senderTag)
                senderTag = senderTag + 1
                //                }
            }
        } else if refreshValue == 25 { // it is for language
            var rowIndex = 0
            var NewarrayBottom = [[String : String]]()
            for indexObj in 0..<self.arrayBottom.count {
                if self.arrayBottom[indexObj]["Type"] == "901" {
                } else {
                    if self.arrayBottom[indexObj]["id"] == "20" {
                        rowIndex = indexObj
                    }
                    NewarrayBottom.append(self.arrayBottom[indexObj])
                }
            }
            var idCheck = ""
            self.arrayBottom = NewarrayBottom
            idCheck = "1200"
            var arrayIndex = [IndexPath]()
            var senderTag = rowIndex + 1
            if self.parentView.otherUserID.count > 0 {
                var languageValue = ""
                for indexObj in 0..<self.parentView.otherUserObj.languayeArray.count {
                    if languageValue.count > 0 {
                        languageValue = languageValue + ", " + self.parentView.otherUserObj.languayeArray[indexObj].languageName
                    }else {
                        languageValue = self.parentView.otherUserObj.languayeArray[indexObj].languageName
                    }
                }
                if self.parentView.otherUserObj.languayeArray.count > 0 {
                    arrayIndex.append(IndexPath.init(row: senderTag, section: 1))
                    // self.arrayBottom.insert(["Type" : "901" , "Des" : "900" , "id" : idCheck , "indexObj" : languageValue], at: senderTag)
                    self.arrayBottom.append(["Type" : "901" , "Des" : "900" , "id" : idCheck , "indexObj" : languageValue])
                    senderTag = senderTag + 1
                }
            } else {
                var languageValue = ""
                for indexObj in 0..<SharedManager.shared.userEditObj.languayeArray.count {
                    if languageValue.count > 0 {
                        languageValue = languageValue + ", " + SharedManager.shared.userEditObj.languayeArray[indexObj].languageName
                    } else {
                        languageValue = SharedManager.shared.userEditObj.languayeArray[indexObj].languageName
                    }
                }
                //                arrayIndex.append(IndexPath.init(row: senderTag, section: 1))
                //                self.arrayBottom.insert(["Type" : "901" , "Des" : "700" , "id" : idCheck , "indexObj" : languageValue], at: senderTag)
                self.arrayBottom.append(["Type" : "901" , "Des" : "900" , "id" : idCheck , "indexObj" : languageValue])
                senderTag = senderTag + 1
            }
        } else if refreshValue == 5 {
            var rowIndex = 0
            var NewarrayBottom = [[String : String]]()
            for indexObj in 0..<self.arrayBottom.count {
                if self.arrayBottom[indexObj]["Type"] == "501" {
                }else {
                    if self.arrayBottom[indexObj]["id"] == "5" {
                        rowIndex = indexObj
                    }
                    NewarrayBottom.append(self.arrayBottom[indexObj])
                }
            }
            var idCheck = ""
            
            self.arrayBottom = NewarrayBottom
            
            idCheck = "500"
            var arrayIndex = [IndexPath]()
            
            var senderTag = rowIndex + 1
            
            
            arrayIndex.append(IndexPath.init(row: senderTag, section: 1))
            
            var dob = SharedManager.shared.userEditObj.dob
            if self.parentView.otherUserID.count > 0 {
                dob = self.parentView.otherUserObj.dob
            }
            self.arrayBottom.insert(["Type" : "501" , "Des" : "501" , "id" : idCheck , "Heading" : "Date Of Birth".localized() , "Text" : dob.changeDateString(inputformat: "yyyy-MM-dd", outputformat: "EEE dd, yyyy")], at: senderTag)
            senderTag = senderTag + 1
            
            
            var gender = SharedManager.shared.userEditObj.gender
            if self.parentView.otherUserID.count > 0 {
                gender = self.parentView.otherUserObj.gender
            }
            
            arrayIndex.append(IndexPath.init(row: senderTag, section: 1))
            self.arrayBottom.insert(["Type" : "501" , "Des" : "500" , "id" : idCheck , "Heading" : "Gender".localized() , "Text" : gender], at: senderTag)
            senderTag = senderTag + 1
            
            var email = SharedManager.shared.userEditObj.email
            if self.parentView.otherUserID.count > 0 {
                email = self.parentView.otherUserObj.email
            }
            
            arrayIndex.append(IndexPath.init(row: senderTag, section: 1))
            self.arrayBottom.insert(["Type" : "501" , "Des" : "500" , "id" : idCheck , "Heading" : "Email".localized() , "Text" : email], at: senderTag)
            senderTag = senderTag + 1
            
            
            var phone = "(" + SharedManager.shared.userEditObj.countryCode + ")"  + SharedManager.shared.userEditObj.phone
            if self.parentView.otherUserID.count > 0 {
                phone = "(" + self.parentView.otherUserObj.countryCode + ")" + self.parentView.otherUserObj.phone
            }
            
            arrayIndex.append(IndexPath.init(row: senderTag, section: 1))
            self.arrayBottom.insert(["Type" : "501" , "Des" : "500" , "id" : idCheck , "Heading" : "Phone".localized() , "Text" : phone], at: senderTag)
            senderTag = senderTag + 1
            
            
            var address = SharedManager.shared.userEditObj.address
            if self.parentView.otherUserID.count > 0 {
                address = self.parentView.otherUserObj.address
            }
            
            arrayIndex.append(IndexPath.init(row: senderTag, section: 1))
            self.arrayBottom.insert(["Type" : "501" , "Des" : "500" , "id" : idCheck , "Heading" : "Address".localized() , "Text" : address], at: senderTag)
            senderTag = senderTag + 1
            var city = SharedManager.shared.userEditObj.city
            if self.parentView.otherUserID.count > 0 {
                city = self.parentView.otherUserObj.city
            }
            
            arrayIndex.append(IndexPath.init(row: senderTag, section: 1))
            self.arrayBottom.insert(["Type" : "501" , "Des" : "500" , "id" : idCheck , "Heading" : "City".localized() , "Text" : city], at: senderTag)
            senderTag = senderTag + 1
            var country = SharedManager.shared.userEditObj.country
            if self.parentView.otherUserID.count > 0 {
                country = self.parentView.otherUserObj.country
            }
            arrayIndex.append(IndexPath.init(row: senderTag, section: 1))
            self.arrayBottom.insert(["Type" : "501" , "Des" : "500" , "id" : idCheck , "Heading" : "Country".localized() , "Text" : country], at: senderTag)
            senderTag = senderTag + 1
            var state = SharedManager.shared.userEditObj.state
            if self.parentView.otherUserID.count > 0 {
                state = self.parentView.otherUserObj.state
            }
            arrayIndex.append(IndexPath.init(row: senderTag, section: 1))
            self.arrayBottom.insert(["Type" : "501" , "Des" : "500" , "id" : idCheck , "Heading" : "State/Province".localized() , "Text" : state], at: senderTag)
            senderTag = senderTag + 1
        } else if refreshValue == 6 {
            var rowIndex = 0
            var NewarrayBottom = [[String : String]]()
            for indexObj in 0..<self.arrayBottom.count {
                if self.arrayBottom[indexObj]["Type"] == "601" {
                }else {
                    if self.arrayBottom[indexObj]["id"] == "600" {
                        rowIndex = indexObj
                    }
                    NewarrayBottom.append(self.arrayBottom[indexObj])
                }
            }
            var idCheck = ""
            self.arrayBottom = NewarrayBottom
            idCheck = "600"
            var arrayIndex = [IndexPath]()
            var senderTag = rowIndex + 1
            if self.parentView.otherUserID.count > 0 {
                for indexObj in 0..<self.parentView.otherUserObj.workExperiences.count {
                    arrayIndex.append(IndexPath.init(row: senderTag, section: 1))
                    self.arrayBottom.insert(["Type" : "601" , "Des" : "600" , "id" : idCheck , "indexObj" : String(indexObj)], at: senderTag)
                    senderTag = senderTag + 1
                }
            }else {
                for indexObj in 0..<SharedManager.shared.userEditObj.workExperiences.count {
                    arrayIndex.append(IndexPath.init(row: senderTag, section: 1))
                    self.arrayBottom.insert(["Type" : "601" , "Des" : "600" , "id" : idCheck , "indexObj" : String(indexObj)], at: senderTag)
                    senderTag = senderTag + 1
                }
            }
            
        } else if refreshValue == 7 {
            var rowIndex = 0
            var NewarrayBottom = [[String : String]]()
            for indexObj in 0..<self.arrayBottom.count {
                if self.arrayBottom[indexObj]["Type"] == "701" {
                }else {
                    if self.arrayBottom[indexObj]["id"] == "700" {
                        rowIndex = indexObj
                    }
                    NewarrayBottom.append(self.arrayBottom[indexObj])
                }
            }
            var idCheck = ""
            self.arrayBottom = NewarrayBottom
            idCheck = "700"
            var arrayIndex = [IndexPath]()
            var senderTag = rowIndex + 1
            if self.parentView.otherUserID.count > 0 {
                for indexObj in 0..<self.parentView.otherUserObj.places.count {
                    
                    arrayIndex.append(IndexPath.init(row: senderTag, section: 1))
                    self.arrayBottom.insert(["Type" : "701" , "Des" : "700" , "id" : idCheck , "indexObj" : String(indexObj)], at: senderTag)
                    senderTag = senderTag + 1
                }
            }else {
                for indexObj in 0..<SharedManager.shared.userEditObj.places.count {
                    
                    arrayIndex.append(IndexPath.init(row: senderTag, section: 1))
                    self.arrayBottom.insert(["Type" : "701" , "Des" : "700" , "id" : idCheck , "indexObj" : String(indexObj)], at: senderTag)
                    senderTag = senderTag + 1
                }
            }
        } else  if refreshValue == 10 {
            var rowIndex = 0
            var NewarrayBottom = [[String : String]]()
            for indexObj in 0..<self.arrayBottom.count {
                if self.arrayBottom[indexObj]["Type"] == "1001" {
                    
                    
                }else {
                    if self.arrayBottom[indexObj]["id"] == "1000" {
                        rowIndex = indexObj
                    }
                    NewarrayBottom.append(self.arrayBottom[indexObj])
                }
            }
            
            var idCheck = ""
            
            self.arrayBottom = NewarrayBottom
            idCheck = "1000"
            var arrayIndex = [IndexPath]()
            var senderTag = rowIndex + 1
            
            if self.parentView.otherUserID.count > 0 {
                for indexObj in 0..<self.parentView.otherUserObj.institutes.count {
                    arrayIndex.append(IndexPath.init(row: senderTag, section: 1))
                    self.arrayBottom.insert(["Type" : "1001" , "Des" : "700" , "id" : idCheck , "indexObj" : String(indexObj)], at: senderTag)
                    senderTag = senderTag + 1
                }
            }else {
                for indexObj in 0..<SharedManager.shared.userEditObj.institutes.count {
                    arrayIndex.append(IndexPath.init(row: senderTag, section: 1))
                    self.arrayBottom.insert(["Type" : "1001" , "Des" : "700" , "id" : idCheck , "indexObj" : String(indexObj)], at: senderTag)
                    senderTag = senderTag + 1
                }
            }
        } else if refreshValue == 55 { // refresh relationship
            var rowIndex = 0
            var NewarrayBottom = [[String : String]]()
            for indexObj in 0..<self.arrayBottom.count {
                if self.arrayBottom[indexObj]["Type"] == "602" {
                }else {
                    if self.arrayBottom[indexObj]["id"] == "34" {
                        rowIndex = indexObj
                    }
                    NewarrayBottom.append(self.arrayBottom[indexObj])
                }
            }
            var idCheck = ""
            self.arrayBottom = NewarrayBottom
            idCheck = "1501"
            var arrayIndex = [IndexPath]()
            var senderTag = rowIndex + 1
            if self.parentView.otherUserID.count > 0 {
                for indexObj in 0..<self.parentView.otherUserObj.relationshipArray.count {
                    senderTag = senderTag + 1
                    arrayIndex.append(IndexPath.init(row: senderTag, section: 1))
                    self.arrayBottom.insert(["Type" : "602" , "Des" : "600" , "id" : idCheck , "indexObj" : String(indexObj)], at: senderTag)
                }
            }else {
                for indexObj in 0..<SharedManager.shared.userEditObj.relationshipArray.count {
                    senderTag = senderTag + 1
                    arrayIndex.append(IndexPath.init(row: senderTag, section: 1))
                    self.arrayBottom.insert(["Type" : "602" , "Des" : "600" , "id" : idCheck , "indexObj" : String(indexObj)], at: senderTag)
                }
            }
        } else if refreshValue == 56 { // family relationship
            var rowIndex = 0
            var NewarrayBottom = [[String : String]]()
            for indexObj in 0..<self.arrayBottom.count {
                if self.arrayBottom[indexObj]["Type"] == "603" {
                }else {
                    if self.arrayBottom[indexObj]["id"] == "35" {
                        rowIndex = indexObj
                    }
                    NewarrayBottom.append(self.arrayBottom[indexObj])
                }
            }
            var idCheck = ""
            self.arrayBottom = NewarrayBottom
            idCheck = "1502"
            var arrayIndex = [IndexPath]()
            var senderTag = rowIndex + 1
            if self.parentView.otherUserID.count > 0 {
                for indexObj in 0..<self.parentView.otherUserObj.familyRelationshipArray.count {
                    senderTag = senderTag + 1
                    arrayIndex.append(IndexPath.init(row: senderTag, section: 1))
                    self.arrayBottom.insert(["Type" : "603" , "Des" : "600" , "id" : idCheck , "indexObj" : String(indexObj)], at: senderTag)
                }
            } else {
                for indexObj in 0..<SharedManager.shared.userEditObj.familyRelationshipArray.count {
                    senderTag = senderTag + 1
                    arrayIndex.append(IndexPath.init(row: senderTag, section: 1))
                    self.arrayBottom.insert(["Type" : "603" , "Des" : "600" , "id" : idCheck , "indexObj" : String(indexObj)], at: senderTag)
                }
            }
        } else if refreshValue == 57 { // Website
            var rowIndex = 0
            var NewarrayBottom = [[String : String]]()
            for indexObj in 0..<self.arrayBottom.count {
                if self.arrayBottom[indexObj]["Type"] == "604" {
                }else {
                    if self.arrayBottom[indexObj]["id"] == "33" {
                        rowIndex = indexObj
                    }
                    NewarrayBottom.append(self.arrayBottom[indexObj])
                }
            }
            var idCheck = ""
            self.arrayBottom = NewarrayBottom
            idCheck = "1500"
            var arrayIndex = [IndexPath]()
            var senderTag = rowIndex + 1
            if self.parentView.otherUserID.count > 0 {
                for indexObj in 0..<self.parentView.otherUserObj.websiteArray.count {
                    senderTag = senderTag + 1
                    arrayIndex.append(IndexPath.init(row: senderTag, section: 1))
                    self.arrayBottom.insert(["Type" : "604" , "Des" : "600" , "id" : idCheck , "indexObj" : String(indexObj)], at: senderTag)
                }
            } else {
                for indexObj in 0..<SharedManager.shared.userEditObj.websiteArray.count {
                    senderTag = senderTag + 1
                    arrayIndex.append(IndexPath.init(row: senderTag, section: 1))
                    self.arrayBottom.insert(["Type" : "604" , "Des" : "600" , "id" : idCheck , "indexObj" : String(indexObj)], at: senderTag)
                }
            }
        } else if refreshValue == 58 { // Currency
            var rowIndex = 0
            var NewarrayBottom = [[String : String]]()
            for indexObj in 0..<self.arrayBottom.count {
                if self.arrayBottom[indexObj]["Type"] == "605" {
                }else {
                    if self.arrayBottom[indexObj]["id"] == "36" {
                        rowIndex = indexObj
                    }
                    NewarrayBottom.append(self.arrayBottom[indexObj])
                }
            }
            var idCheck = ""
            self.arrayBottom = NewarrayBottom
            idCheck = "1503"
            var arrayIndex = [IndexPath]()
            var senderTag = rowIndex + 1
            if self.parentView.otherUserID.count > 0 {
                let currencyName = self.parentView.otherUserObj.currency?.name ?? .emptyString
                let currencySymbol = self.parentView.otherUserObj.currency?.symbol ?? .emptyString
                let currencyFullName = currencyName + " - " + currencySymbol
                arrayIndex.append(IndexPath.init(row: senderTag, section: 1))
                self.arrayBottom = self.arrayBottom.filter({$0["id"] != "1503"}) // it will remove all array 1503 (against currency id)
                self.arrayBottom.insert(["Type" : "901" , "Des" : "900" , "id" : idCheck , "indexObj" : currencyFullName], at: senderTag)
                senderTag = senderTag + 1
            }  else {
                let currencyName = SharedManager.shared.userEditObj.currency?.name ?? .emptyString
                let currencySymbol = SharedManager.shared.userEditObj.currency?.symbol ?? .emptyString
                let currencyFullName = currencyName + " - " + currencySymbol
                arrayIndex.append(IndexPath.init(row: senderTag, section: 1))
                self.arrayBottom = self.arrayBottom.filter({$0["id"] != "1503"}) // it will remove all array 1503 (against currency id)
                self.arrayBottom.insert(["Type" : "901" , "Des" : "900" , "id" : idCheck , "indexObj" : currencyFullName], at: senderTag)
                senderTag = senderTag + 1
            }
        }
        
        else if refreshValue == 59 { // Life Category Events
            var rowIndex = 0
            var NewarrayBottom = [[String : String]]()
            for indexObj in 0..<self.arrayBottom.count {
                if self.arrayBottom[indexObj]["Type"] == "606" {
                }else {
                    if self.arrayBottom[indexObj]["id"] == "38" {
                        rowIndex = indexObj
                    }
                    NewarrayBottom.append(self.arrayBottom[indexObj])
                }
            }
            var idCheck = ""
            self.arrayBottom = NewarrayBottom
            idCheck = "1505"
            var arrayIndex = [IndexPath]()
            var senderTag = rowIndex + 1
            if self.parentView.otherUserID.count > 0 {
                for indexObj in 0..<self.parentView.otherUserObj.userLifeEventsArray.count {
                    senderTag = senderTag + 1
                    arrayIndex.append(IndexPath.init(row: senderTag, section: 1))
                    self.arrayBottom.insert(["Type" : "606" , "Des" : "600" , "id" : idCheck , "indexObj" : String(indexObj)], at: senderTag)
                }
            } else {
                for indexObj in 0..<SharedManager.shared.userEditObj.userLifeEventsArray.count {
                    senderTag = senderTag + 1
                    arrayIndex.append(IndexPath.init(row: senderTag, section: 1))
                    self.arrayBottom.insert(["Type" : "606" , "Des" : "600" , "id" : idCheck , "indexObj" : String(indexObj)], at: senderTag)
                }
            }
        } else if refreshValue == 60 { // Sport
            var rowIndex = 0
            var NewarrayBottom = [[String : String]]()
            for indexObj in 0..<self.arrayBottom.count {
                LogClass.debugLog("self.arrayBottom[indexObj] ===")
                LogClass.debugLog(self.arrayBottom[indexObj])
                if self.arrayBottom[indexObj]["Type"] == "1100" {
                }else {
                    if self.arrayBottom[indexObj]["id"] == "39" {
                        rowIndex = indexObj
                    }
                    NewarrayBottom.append(self.arrayBottom[indexObj])
                }
            }
            var idCheck = ""
            self.arrayBottom = NewarrayBottom
            idCheck = "1101"
            var arrayIndex = [IndexPath]()
            var senderTag = rowIndex + 1
            
            if self.parentView.otherUserID.count > 0 {
                for indexObj in 0..<self.parentView.otherUserObj.sportArray.count {
                    arrayIndex.append(IndexPath.init(row: senderTag, section: 1))
                    self.arrayBottom.insert(["Type" : "1100" , "Des" : "900" , "id" : idCheck , "indexObj" : String(indexObj)], at: senderTag)
                    senderTag = senderTag + 1
                }
            } else {
                for indexObj in 0..<SharedManager.shared.userEditObj.sportArray.count {
                    arrayIndex.append(IndexPath.init(row: senderTag, section: 1))
                    self.arrayBottom.insert(["Type" : "1100" , "Des" : "900" , "id" : idCheck , "indexObj" : String(indexObj)], at: senderTag)
                    senderTag = senderTag + 1
                }
            }
        } else if refreshValue == 61 { // movies
            var rowIndex = 0
            var NewarrayBottom = [[String : String]]()
            for indexObj in 0..<self.arrayBottom.count {
                if self.arrayBottom[indexObj]["Type"] == "1100" {
                } else {
                    if self.arrayBottom[indexObj]["id"] == "40" {
                        rowIndex = indexObj
                    }
                    NewarrayBottom.append(self.arrayBottom[indexObj])
                }
            }
            var idCheck = ""
            self.arrayBottom = NewarrayBottom
            idCheck = "1102"
            var arrayIndex = [IndexPath]()
            var senderTag = rowIndex + 1
            if self.parentView.otherUserID.count > 0 {
                for indexObj in 0..<self.parentView.otherUserObj.movieArray.count {
                    
                    arrayIndex.append(IndexPath.init(row: senderTag, section: 1))
                    self.arrayBottom.insert(["Type" : "1100" , "Des" : "900" , "id" : idCheck , "indexObj" : String(indexObj)], at: senderTag)
                    senderTag = senderTag + 1
                }
            } else {
                for indexObj in 0..<SharedManager.shared.userEditObj.movieArray.count {
                    
                    arrayIndex.append(IndexPath.init(row: senderTag, section: 1))
                    self.arrayBottom.insert(["Type" : "1100" , "Des" : "900" , "id" : idCheck , "indexObj" : String(indexObj)], at: senderTag)
                    senderTag = senderTag + 1
                }
            }
        } else if refreshValue == 62 { // tv
            var rowIndex = 0
            var NewarrayBottom = [[String : String]]()
            for indexObj in 0..<self.arrayBottom.count {
                if self.arrayBottom[indexObj]["Type"] == "1100" {
                } else {
                    if self.arrayBottom[indexObj]["id"] == "41" {
                        rowIndex = indexObj
                    }
                    NewarrayBottom.append(self.arrayBottom[indexObj])
                }
            }
            var idCheck = ""
            self.arrayBottom = NewarrayBottom
            idCheck = "1103"
            var arrayIndex = [IndexPath]()
            var senderTag = rowIndex + 1
            if self.parentView.otherUserID.count > 0 {
                for indexObj in 0..<self.parentView.otherUserObj.tvShowArray.count {
                    
                    arrayIndex.append(IndexPath.init(row: senderTag, section: 1))
                    self.arrayBottom.insert(["Type" : "1100" , "Des" : "900" , "id" : idCheck , "indexObj" : String(indexObj)], at: senderTag)
                    senderTag = senderTag + 1
                }
            } else {
                for indexObj in 0..<SharedManager.shared.userEditObj.tvShowArray.count {
                    
                    arrayIndex.append(IndexPath.init(row: senderTag, section: 1))
                    self.arrayBottom.insert(["Type" : "1100" , "Des" : "900" , "id" : idCheck , "indexObj" : String(indexObj)], at: senderTag)
                    senderTag = senderTag + 1
                }
            }
        }  else if refreshValue == 64 { // book
            var rowIndex = 0
            var NewarrayBottom = [[String : String]]()
            for indexObj in 0..<self.arrayBottom.count {
                if self.arrayBottom[indexObj]["Type"] == "1100" {
                }else {
                    if self.arrayBottom[indexObj]["id"] == "42" {
                        rowIndex = indexObj
                    }
                    NewarrayBottom.append(self.arrayBottom[indexObj])
                }
            }
            var idCheck = ""
            self.arrayBottom = NewarrayBottom
            idCheck = "1104"
            var arrayIndex = [IndexPath]()
            var senderTag = rowIndex + 1
            
            if self.parentView.otherUserID.count > 0 {
                for indexObj in 0..<self.parentView.otherUserObj.bookArray.count {
                    arrayIndex.append(IndexPath.init(row: senderTag, section: 1))
                    self.arrayBottom.insert(["Type" : "1100" , "Des" : "900" , "id" : idCheck , "indexObj" : String(indexObj)], at: senderTag)
                    senderTag = senderTag + 1
                }
            } else {
                for indexObj in 0..<SharedManager.shared.userEditObj.bookArray.count {
                    arrayIndex.append(IndexPath.init(row: senderTag, section: 1))
                    self.arrayBottom.insert(["Type" : "1100" , "Des" : "900" , "id" : idCheck , "indexObj" : String(indexObj)], at: senderTag)
                    senderTag = senderTag + 1
                }
            }
        } else if refreshValue == 63 { // games
            var rowIndex = 0
            var NewarrayBottom = [[String : String]]()
            for indexObj in 0..<self.arrayBottom.count {
                if self.arrayBottom[indexObj]["Type"] == "1100" {
                }else {
                    if self.arrayBottom[indexObj]["id"] == "43" {
                        rowIndex = indexObj
                    }
                    NewarrayBottom.append(self.arrayBottom[indexObj])
                }
            }
            var idCheck = ""
            self.arrayBottom = NewarrayBottom
            idCheck = "1105"
            var arrayIndex = [IndexPath]()
            var senderTag = rowIndex + 1
            if self.parentView.otherUserID.count > 0 {
                for indexObj in 0..<self.parentView.otherUserObj.gameArray.count {
                    arrayIndex.append(IndexPath.init(row: senderTag, section: 1))
                    self.arrayBottom.insert(["Type" : "1100" , "Des" : "900" , "id" : idCheck , "indexObj" : String(indexObj)], at: senderTag)
                    senderTag = senderTag + 1
                }
            } else {
                for indexObj in 0..<SharedManager.shared.userEditObj.gameArray.count {
                    arrayIndex.append(IndexPath.init(row: senderTag, section: 1))
                    self.arrayBottom.insert(["Type" : "1100" , "Des" : "900" , "id" : idCheck , "indexObj" : String(indexObj)], at: senderTag)
                    senderTag = senderTag + 1
                }
            }
        } else if refreshValue == 64 { // athlete
            var rowIndex = 0
            var NewarrayBottom = [[String : String]]()
            for indexObj in 0..<self.arrayBottom.count {
                if self.arrayBottom[indexObj]["Type"] == "1100" {
                }else {
                    if self.arrayBottom[indexObj]["id"] == "44" {
                        rowIndex = indexObj
                    }
                    NewarrayBottom.append(self.arrayBottom[indexObj])
                }
            }
            var idCheck = ""
            self.arrayBottom = NewarrayBottom
            idCheck = "1106"
            var arrayIndex = [IndexPath]()
            var senderTag = rowIndex + 1
            if self.parentView.otherUserID.count > 0 {
                for indexObj in 0..<self.parentView.otherUserObj.athleteArray.count {
                    arrayIndex.append(IndexPath.init(row: senderTag, section: 1))
                    self.arrayBottom.insert(["Type" : "1100" , "Des" : "900" , "id" : idCheck , "indexObj" : String(indexObj)], at: senderTag)
                    senderTag = senderTag + 1
                }
            } else {
                for indexObj in 0..<SharedManager.shared.userEditObj.athleteArray.count {
                    arrayIndex.append(IndexPath.init(row: senderTag, section: 1))
                    self.arrayBottom.insert(["Type" : "1100" , "Des" : "900" , "id" : idCheck , "indexObj" : String(indexObj)], at: senderTag)
                    senderTag = senderTag + 1
                }
            }
        } else if refreshValue == 65 { // music
            var rowIndex = 0
            var NewarrayBottom = [[String : String]]()
            for indexObj in 0..<self.arrayBottom.count {
                if self.arrayBottom[indexObj]["Type"] == "1100" {
                }else {
                    if self.arrayBottom[indexObj]["id"] == "45" {
                        rowIndex = indexObj
                    }
                    NewarrayBottom.append(self.arrayBottom[indexObj])
                }
            }
            var idCheck = ""
            self.arrayBottom = NewarrayBottom
            idCheck = "1107"
            var arrayIndex = [IndexPath]()
            var senderTag = rowIndex + 1
            if self.parentView.otherUserID.count > 0 {
                for indexObj in 0..<self.parentView.otherUserObj.musicArray.count {
                    arrayIndex.append(IndexPath.init(row: senderTag, section: 1))
                    self.arrayBottom.insert(["Type" : "1100" , "Des" : "900" , "id" : idCheck , "indexObj" : String(indexObj)], at: senderTag)
                    senderTag = senderTag + 1
                }
            } else {
                for indexObj in 0..<SharedManager.shared.userEditObj.musicArray.count {
                    arrayIndex.append(IndexPath.init(row: senderTag, section: 1))
                    self.arrayBottom.insert(["Type" : "1100" , "Des" : "900" , "id" : idCheck , "indexObj" : String(indexObj)], at: senderTag)
                    senderTag = senderTag + 1
                }
            }
        } else if refreshValue == 66 { // group
            var rowIndex = 0
            var NewarrayBottom = [[String : String]]()
            for indexObj in 0..<self.arrayBottom.count {
                if self.arrayBottom[indexObj]["Type"] == "1200" {
                }else {
                    if self.arrayBottom[indexObj]["id"] == "37" {
                        rowIndex = indexObj
                    }
                    NewarrayBottom.append(self.arrayBottom[indexObj])
                }
            }
            var idCheck = ""
            self.arrayBottom = NewarrayBottom
            idCheck = "1504"
            var arrayIndex = [IndexPath]()
            var senderTag = rowIndex + 1
            if self.parentView.otherUserID.count > 0 {
                for indexObj in 0..<self.parentView.otherUserObj.groupArray.count {
                    arrayIndex.append(IndexPath.init(row: senderTag, section: 1))
                    self.arrayBottom.insert(["Type" : "1200" , "Des" : "900" , "id" : idCheck , "indexObj" : String(indexObj)], at: senderTag)
                    senderTag = senderTag + 1
                }
            } else {
                for indexObj in 0..<SharedManager.shared.userEditObj.groupArray.count {
                    arrayIndex.append(IndexPath.init(row: senderTag, section: 1))
                    self.arrayBottom.insert(["Type" : "1200" , "Des" : "900" , "id" : idCheck , "indexObj" : String(indexObj)], at: senderTag)
                    senderTag = senderTag + 1
                }
            }
        }
        self.parentView.profileTableView.reloadData()
    }
}

//MARK:UITextViewDelegate...
extension ProfileViewModel:UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView){
        
    }
    func textView(_ textView: UITextView,
                  shouldChangeTextIn range: NSRange,
                  replacementText text: String) -> Bool{
        return true
    }
    
    @objc func aboutMeAction(){
        (self.parentView as ProfileViewController).isNavPushAllow = false
        UIApplication.shared.keyWindow!.addSubview((self.parentView as ProfileViewController).editProfileAboutMeVc.view)
    }
}



extension ProfileViewModel : ProfileImageSelectionDelegate {
    
    func ReloadNewPage() {
        
        let userToken = SharedManager.shared.userToken()
        
        var parameters = ["token": userToken]
        if selectedTab == .videos {
            parameters["action"] = "profile/videos"
        } else {
            parameters["action"] = "profile/photos"
        }
        
        //        var parameters = ["action": "profile/photos","token": userToken]
        
        if selectedTab == .videos {
            if self.arrayVideo.count > 0 {
                parameters["starting_point_id"] = String(self.arrayVideo.last!.postID!)
            }else {
                return
            }
        } else {
            if self.arrayImage.count > 0 {
                parameters["starting_point_id"] = String(self.arrayImage.last!.postID!)
            } else {
                return
            }
        }
        
        if self.parentView.otherUserID.count > 0 {
            parameters["user_id"] = self.parentView.otherUserID
        }
        
        RequestManagerGen.fetchDataGet(Completion: { (response: Result<(FeedModel), Error>) in
            //            SharedManager.shared.hide gingHubFromKeyWindow()
            Loader.stopLoading()
            switch response {
                
            case .failure(let _): break
            case .success(let res):
                self.handleImageFeedResponse(feedObj: res)
            }
        }, param:parameters)
    }
    
    func viewTranscript(tabValue : Int) {
        
        self.viewTranscript(fileID: String((self.arrayVideo[tabValue].post!.first!.fileID!)))
    }
    
    func profileImageSelection(tabValue : Int , isImage : Bool) {
        let fullScreen = AppStoryboard.PostStoryboard.instance.instantiateViewController(withIdentifier: Const.FullGalleryScreenController) as! FullGalleryViewController
        var valueempty = [String : Any]()
        var feedObj = FeedData.init(valueDict: valueempty)
        if isImage {
            feedObj.postType = FeedType.image.rawValue
            var postFiles = [PostFile]()
            for indexObj in self.arrayImage {
                for indexObjInner in indexObj.post! {
                    var postObj = PostFile.init()
                    postObj.fileType = FeedType.image.rawValue
                    postObj.filePath = indexObjInner.filePath!
                    postFiles.append(postObj)
                }
            }
            feedObj.post = postFiles
            fullScreen.collectionArray = postFiles
        }else {
            feedObj.postType = FeedType.video.rawValue
            
            var postFiles = [PostFile]()
            for indexObj in self.videoforTable {
                let postObj = PostFile.init()
                postObj.fileType = FeedType.video.rawValue
                postObj.filePath = (indexObj as! String)
                postFiles.append(postObj)
            }
            
            feedObj.post = postFiles
            fullScreen.collectionArray = postFiles
        }
        
        fullScreen.isInfoViewShow = true
        fullScreen.feedObj = feedObj
        fullScreen.movedIndexpath = tabValue
        fullScreen.modalTransitionStyle = .crossDissolve
        self.parentView.present(fullScreen, animated: false, completion: nil)
    }
    
    
    
    func viewTranscript(fileID : String) {
        
        //  SharedManager.shared.showOnWindow()
        //        let parameters = ["action": "post_file/transcript","token": SharedManager.shared.userToken() , "file_id" : fileID]
        //        RequestManager.fetchDataGet(Completion: { (response) in
        //            SharedManager.shared.hideLoadingHubFromKeyWindow()
        //            switch response {
        //            case .failure(let error):
        //                if error is String {
        //                }
        //            case .success(let res):
        //                if res is Int {
        //                    AppDelegate.shared().loadLoginScreen()
        //                }else if let newRes = res as? [String : Any] {
        //
        //                    let videoTranscript = AppStoryboard.TabBar.instance.instantiateViewController(withIdentifier: "VideoTranscriptController") as! VideoTranscriptController
        //                    videoTranscript.transcriptDict = newRes
        //
        //                    videoTranscript.isReloadCall = false
        //                    videoTranscript.isHideBtn = false
        
        //                    if (newRes["translated_transcript"] as! String) == (newRes["transcript"] as! String) {
        //                        videoTranscript.isHideBtn = true
        //                    }
        
        //                    self.parentView.sheetController = SheetViewController(controller: videoTranscript, sizes: [.fullScreen])
        //                    self.parentView.sheetController.overlayColor = UIColor.black.withAlphaComponent(0.3)
        //                    self.parentView.sheetController.extendBackgroundBehindHandle = true
        //                    self.parentView.sheetController.topCornersRadius = 20
        //                    self.parentView.present(self.parentView.sheetController, animated: false, completion: nil)
        //                }
        //            }
        //        }, param: parameters)
    }
    
    func openPhotoPicker(maxValue : Int = 10){
        self.parentView.isReload = false
        let viewController = TLPhotosPickerViewController()
        viewController.delegate = self
        
        var configure = TLPhotosPickerConfigure()
        configure.maxSelectedAssets = maxValue
        configure.numberOfColumn = 3
        configure.allowedVideo = false
        configure.allowedLivePhotos = false
        viewController.configure = configure
        
        self.parentView.present(viewController, animated: true) {
            //            viewController.albumPopView.show(viewController.albumPopView.isHidden, duration: 0.1)
        }
    }
}


extension ProfileViewModel : TLPhotosPickerViewControllerDelegate {
    func dismissPhotoPicker(withTLPHAssets: [TLPHAsset]) {
        // use selected order, fullresolution image
        
        
        if isCoverPhoto == 1 { // Cover Image
            for indexObj in withTLPHAssets {
                if indexObj.type == .photo {
                    
                    let imageChoose = self.getImageFromAsset(asset: indexObj.phAsset!)!
                    
                    
                    
                    DispatchQueue.main.async {
                        
                        
                        self.imageType = "cover_image"
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
                        
                        self.imageType = "profile_image"
                        self.OpenPhotEdit(imageMain: imageChoose, isCricle: true)
                        
                    }
                }
            }
            
            self.isCoverPhoto = 0
        }
    }
    
    
    func callingServiceToUpload(imageParamName : String ,fileType : String , filePath : String)  {
        
        self.getS3URL(imageParamName: imageParamName, fileType: fileType, filePath: filePath)
        //        let parameters = ["action": "profile/update",
        //                          "token": SharedManager.shared.userToken(),
        //                          "isFromUser" : imageParamName,
        //                          "fileType": fileType,
        //                          "fileUrl": filePath] as! [String : Any]
        //
        //        //        SharedManager.shared.showOnWindow()
        //        Loader.startLoading()
        //        LogClass.debugLog("parameters ===>")
        //        LogClass.debugLog(parameters)
        //        RequestManager.fetchDataMultiparts(Completion: { response in
        //            Loader.stopLoading()
        //            switch response {
        //            case .failure(let error):
        //                LogClass.debugLog(error)
        //            case .success(let res):
        //                LogClass.debugLog("res ===>")
        //                LogClass.debugLog(res)
        //                if let mainResult = res as? [String : Any] {
        //                    if let mainData = mainResult["data"] as? [String : Any] {
        //                        if let mainfile = mainData["profile_image"] as? String {
        //                            if self.imageType == "cover_image" {
        //                                SharedManager.shared.userObj!.data.cover_image = mainfile
        //                                SharedManager.shared.userEditObj.coverImage = mainData["cover_image"] as! String
        //                            } else {
        //                                SharedManager.shared.userObj!.data.profile_image = mainfile
        //                                SharedManager.shared.userEditObj.profileImage = mainfile
        //                            }
        //                        }
        //                        // for updating data
        //                        if self.imageType != "cover_image" {
        //                            self.callingFeedService(lastPostID: "", isLastTrue: false, isRefresh: true)
        //                            let cellMain = self.parentView.profileTableView.cellForRow(at: IndexPath.init(row: 0, section: 0)) as! ProfileNewImageHeaderCell
        //                            cellMain.uploadingImageLoadingView.isHidden = true
        //                        }
        //                        //----
        //                        self.imageType = ""
        //                        SocketSharedManager.sharedSocket.updateUserProfile(dictionary: mainData )
        //                        self.feedtble.reloadData()
        //                    }
        //                }
        //            }
        //        }, param:parameters, fileUrl: "")
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
        
        
        if self.imageType == "cover_image" {
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
                        if self.imageType == "cover_image" {
                            SharedManager.shared.userObj!.data.cover_image = mainfile
                            SharedManager.shared.userEditObj.coverImage = mainData["cover_image"] as! String
                        } else {
                            SharedManager.shared.userObj!.data.profile_image = mainfile
                            SharedManager.shared.userEditObj.profileImage = mainfile
                        }
                    }
                    // for updating data
                    if self.imageType != "cover_image" {
                        self.callingFeedService(lastPostID: "", isLastTrue: false, isRefresh: true)
                        let cellMain = self.parentView.profileTableView.cellForRow(at: IndexPath.init(row: 0, section: 0)) as! ProfileNewImageHeaderCell
                        cellMain.uploadingImageLoadingView.isHidden = true
                    }
                    //----
                    self.imageType = ""
                    SocketSharedManager.sharedSocket.updateUserProfile(dictionary: mainData )
                    self.feedtble.reloadData()
                    //  }
                }
            }
        }, param: parameters)
        
        
        //
        //        RequestManager.fetchDataMultiparts(Completion: { response in
        //            Loader.stopLoading()
        //            switch response {
        //            case .failure(let error):
        //                LogClass.debugLog(error)
        //            case .success(let res):
        //                LogClass.debugLog("res ===>")
        //                LogClass.debugLog(res)
        //                if let mainResult = res as? [String : Any] {
        //                    if let mainData = mainResult["data"] as? [String : Any] {
        //                        if let mainfile = mainData["profile_image"] as? String {
        //                            if self.imageType == "cover_image" {
        //                                SharedManager.shared.userObj!.data.cover_image = mainfile
        //                                SharedManager.shared.userEditObj.coverImage = mainData["cover_image"] as! String
        //                            } else {
        //                                SharedManager.shared.userObj!.data.profile_image = mainfile
        //                                SharedManager.shared.userEditObj.profileImage = mainfile
        //                            }
        //                        }
        //                        // for updating data
        //                        if self.imageType != "cover_image" {
        //                            self.callingFeedService(lastPostID: "", isLastTrue: false, isRefresh: true)
        //                            let cellMain = self.parentView.profileTableView.cellForRow(at: IndexPath.init(row: 0, section: 0)) as! ProfileNewImageHeaderCell
        //                            cellMain.uploadingImageLoadingView.isHidden = true
        //                        }
        //                        //----
        //                        self.imageType = ""
        //                        SocketSharedManager.sharedSocket.updateUserProfile(dictionary: mainData )
        //                        self.feedtble.reloadData()
        //                    }
        //                }
        //            }
        //        }, param:parameters, fileUrl: "")
    }
    
    
    func uploadMediaOnS3(imageParamName : String ,fileType : String , filePath : String){
        
        
        let userToken:String = SharedManager.shared.userObj!.data.token!
        let parameters = ["api_token": userToken]
        
        self.uploadThumbImage(params: parameters , imageParamName : imageParamName ,fileType : fileType , filePath : filePath)
    }
    
    //
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
    
    
    func uploadimage(imageMain : UIImage) {
        
        let newObj = PostCollectionViewObject.init()
        newObj.isType = PostDataType.Image
        newObj.imageMain = imageMain
        
        DispatchQueue.main.async {
            self.arrayImageLocal.append(imageMain)
            self.parentView.profileTableView.reloadData()
        }
        
        let userToken = SharedManager.shared.userObj!.data.token
        let parameters = ["action": "post/create","token": userToken,"body":"" ,"post_scope_id" : "1"]
        
        RequestManager.uploadMultipartRequests( params: parameters as! [String : String],
                                                fileObjectArray: [newObj],
                                                success: { (JSONResponse) -> Void in
            let respDict = JSONResponse
            let meta = respDict["meta"] as! NSDictionary
            let code = meta["code"] as! Int
            if code == ResponseKey.successResp.rawValue {
                
            }
        },failure: {(error) -> Void in
            
        })
    }
    
    func uploadVideo(urlVideo : URL){
        let newObj = PostCollectionViewObject.init()
        newObj.isType = PostDataType.Video
        newObj.videoURL = urlVideo
        
        DispatchQueue.main.async {
            self.arrayVideoLocal.append(urlVideo)
            
            self.arrayVideoforTable.append(urlVideo)
            self.videoforTable.append(urlVideo)
            self.parentView.profileTableView.reloadData()
            
        }
        
        let userToken = SharedManager.shared.userObj!.data.token
        let parameters = ["action": "post/create","token": userToken,"body":"" , "post_scope_id" : "1"]
        RequestManager.uploadMultipartRequests( params: parameters as! [String : String],fileObjectArray: [newObj],success: {
            (JSONResponse) -> Void in
            let respDict = JSONResponse
            
            let meta = respDict["meta"] as! NSDictionary
            let code = meta["code"] as! Int
            if code == ResponseKey.successResp.rawValue{
                
            }
        },failure: {(error) -> Void in
            
        })
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


extension ProfileViewModel {
    
    func getContact() {
        if self.arrayContactGroupSearch.count > 0 {
            self.arrayBottom.append(["1" : "1"])
            for _ in self.arrayContactGroupSearch {
                self.arrayBottom.append(["1" : "1"])
            }
            return
        }
        //        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        let userToken = SharedManager.shared.userToken()
        var parameters = ["action": "contacts","token": userToken , "as_per_privacy": "1"]
        
        if self.parentView.otherUserID.count > 0 {
            parameters["user_id"] = self.parentView.otherUserID
        }
        
        RequestManager.fetchDataGet(Completion: { (response) in
            //            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            switch response {
            case .failure(let error):
                SwiftMessages.apiServiceError(error: error)
            case .success(let res):
                
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                }else if res is [[String : Any]] {
                    let array = res as! [[String : Any]]
                    for indexObj in array {
                        self.arrayContactGroupSearch.append(ContactModel.init(fromDictionary: indexObj))
                        self.arrayContactGroup.append(ContactModel.init(fromDictionary: indexObj))
                    }
                }
                self.arrayBottom.append(["1" : "1"])
                for _ in self.arrayContactGroupSearch {
                    self.arrayBottom.append(["1" : "1"])
                }
                self.parentView.profileTableView.reloadData()
            }
        }, param: parameters)
    }
}

enum selectedUserTab : Int {
    case nothing = 0
    case timeline = 1
    case aboutMe = 2
    case photos = 3
    case videos = 4
    case friends = 5
    case myReels = 6
    case savedReels = 7
}

extension ProfileViewModel:UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if !scrollView.isDecelerating && !scrollView.isDragging {
            
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        //        if !decelerate {
        self.playVideo()
        //        }
    }
    
    
    func playVideo() {
        
        if let parentVC = self.parentView as? ProfileViewController  {
            
            let indexPath = parentVC.profileTableView.indexPathForRow(at: parentVC.profileTableView.bounds.center)
            
            if indexPath == nil {
                return
            }
            
            LogClass.debugLog("parentVC.profileTableView.cellForRow(at:indexPath!) ==>")
            LogClass.debugLog(parentVC.profileTableView.cellForRow(at:indexPath!))
            
            if let cellVideo = parentVC.profileTableView.cellForRow(at:indexPath!) as? NewVideoFeedCell {
                
                if MediaManager.sharedInstance.player != nil {
                    if (MediaManager.sharedInstance.player?.isPlaying != nil) {
                        if (MediaManager.sharedInstance.player!.isPlaying)  {
                            
                        }else {
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.0) {
                                cellVideo.isPlayVideo = true
                                cellVideo.playPlayer()
                            }
                        }
                    }else {
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.0) {
                            cellVideo.isPlayVideo = true
                            cellVideo.playPlayer()
                        }
                    }
                } else {
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.0) {
                        cellVideo.isPlayVideo = true
                        cellVideo.playPlayer()
                    }
                }
                
            } else if let cellVideo = parentVC.profileTableView.cellForRow(at:indexPath!) as? NewGalleryFeedCell {
                cellVideo.playGalleryVideo()
            } else{
                LogClass.debugLog("parentVC.profileTableView.cellForRow(at:indexPath!) ==>")
                LogClass.debugLog(parentVC.profileTableView.cellForRow(at:indexPath!))
                if (MediaManager.sharedInstance.player?.isPlaying != nil) {
                    if (MediaManager.sharedInstance.player!.isPlaying)  {
                        MediaManager.sharedInstance.player?.stop()
                    }
                }
            }
        }
    }
    
    @objc func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollViewHeight = scrollView.frame.size.height
        let scrollContentSizeHeight = scrollView.contentSize.height
        let scrollOffset = scrollView.contentOffset.y
        if (scrollOffset == 0) {
            // then we are at the top
            LogClass.debugLog("then we are at the top")
        } else if (scrollOffset + scrollViewHeight > scrollContentSizeHeight - 75) {
            self.ReloadNewPage()
        }
        
        self.feedScrollHandler?()
    }
}

extension ProfileViewModel : CellDelegate {
    
    func reloadTableDataFriendShipStatus(feedObj: FeedData) {
        self.feedArray.forEach { feed in
            if feed.authorID == feedObj.authorID {
                feed.isAuthorFriendOfViewer = feedObj.isAuthorFriendOfViewer
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            self.reloadTableViewClosure?()
        })
    }
    
    func reloadRow(indexObj : IndexPath , feedObj : FeedData) {
        //        self.reloadSpecificRow?(indexObj)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
            self.reloadTableViewClosure?()
            self.reloadSpecificRow?(indexObj)
        }
    }
    
    func moreAction(indexObj: IndexPath, feedObj: FeedData) {
        let reportController = AppStoryboard.TabBar.instance.instantiateViewController(withIdentifier: "ReportingViewController") as! ReportingViewController
        reportController.reportType = "Post"
        reportController.currentIndex = indexObj
        reportController.feedObj = feedObj
        if let parentVC = self.parentView as? FeedViewController {
            reportController.delegate = parentVC
            // parentVC.sheetController = SheetViewController(controller: reportController, sizes: [.fixed(350)])
            parentVC.sheetController = SheetViewController(controller: reportController, sizes: [.fullScreen])
            parentVC.sheetController.overlayColor = UIColor.black.withAlphaComponent(0.3)
            parentVC.sheetController.extendBackgroundBehindHandle = true
            parentVC.sheetController.topCornersRadius = 20
            parentVC.present(parentVC.sheetController, animated: false, completion: nil)
        }
    }
    
    func userProfileAction(indexObj : IndexPath , feedObj : FeedData) {
        let userID = String(feedObj.authorID!)
        if let parentVC = self.parentView as? FeedViewController {
            if Int(userID) == SharedManager.shared.getUserID() {
                parentVC.tabBarController?.selectedIndex = 3
            }else {
                let vcProfile = AppStoryboard.PostStoryboard.instance.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
                vcProfile.otherUserID = userID
                vcProfile.otherUserisFriend = "1"
                vcProfile.isNavPushAllow = true
                parentVC.navigationController?.pushViewController(vcProfile, animated: true)
            }
        }
    }
    
    func sharePostAction(indexObj : IndexPath , feedObj : FeedData){
        let shareController = AppStoryboard.TabBar.instance.instantiateViewController(withIdentifier: "SharePostController") as! SharePostController
        shareController.postID = String(feedObj.postID!)
        let navigationObj = UINavigationController.init(rootViewController: shareController)
        if let parentVC = self.parentView as? FeedViewController {
            parentVC.sheetController = SheetViewController(controller: navigationObj, sizes: [.fixed(550), .fullScreen])
            parentVC.sheetController.overlayColor = UIColor.black.withAlphaComponent(0.3)
            parentVC.sheetController.extendBackgroundBehindHandle = true
            parentVC.sheetController.topCornersRadius = 20
            SharedManager.shared.feedRef!.present(parentVC.sheetController, animated: true, completion: nil)
        }
    }
    
    func downloadPostAction(indexObj : IndexPath , feedObj : FeedData){
        
        var urlString:String?
        var isImage : Bool?
        if feedObj.post!.count > 0 {
            var postFile:PostFile?
            
            isImage = feedObj.postType == FeedType.image.rawValue ? true : false
            if feedObj.postType == FeedType.image.rawValue ||
                feedObj.postType == FeedType.video.rawValue {
                postFile = feedObj.post![0]
                if postFile!.processingStatus == "done" {
                    urlString = postFile!.filePath
                    
                }
            }
            
            if urlString != nil {
                self.parentView.downloadFile(filePath: urlString!, isImage: isImage!, isShare: false , FeedObj:  feedObj)
            }
        }
    }
    
    func imgShowAction(indexObj : IndexPath , feedObj : FeedData) {
        if let parentVC = self.parentView as? FeedViewController {
            let fullScreen = AppStoryboard.PostStoryboard.instance.instantiateViewController(withIdentifier: Const.FullGalleryScreenController) as! FullGalleryViewController
            var feeddata:FeedData?
            feeddata = feedObj
            fullScreen.isInfoViewShow = false
            fullScreen.collectionArray = feeddata!.post!
            fullScreen.feedObj = feedObj
            fullScreen.movedIndexpath = 0
            fullScreen.modalTransitionStyle = .crossDissolve
            fullScreen.currentIndex = IndexPath.init(row: indexObj.row, section: 0)
            FeedCallBManager.shared.manageMovingToDetailFeedScreen(tableCellArr: parentVC.feedTableView.visibleCells)
            parentVC.present(fullScreen, animated: false, completion: nil)
        }
    }
    
    func commentActions(indexObj : IndexPath , feedObj : FeedData , typeAction: ActionType){
        
    }
}

extension ProfileViewModel : UITextFieldDelegate {
    @objc func reloadDataforSearch() {
        if let cellSearch = self.feedtble.cellForRow(at: IndexPath.init(row: 0, section: 1)) as? ProfileSearchContactsCell {
            
            if cellSearch.txtFieldSearch.text!.count > 0 {
                self.arrayContactGroupSearch = self.arrayContactGroup.filter{
                    ($0.firstname + " " + $0.lastname).range(of: cellSearch.txtFieldSearch.text!,
                                                             options: .caseInsensitive,
                                                             range: nil,
                                                             locale: nil) != nil
                }
                
            }else {
                self.arrayContactGroupSearch = self.arrayContactGroup
            }
            if self.arrayContactGroupSearch.count > 0 {
                self.arrayBottom.append(["1" : "1"])
                for _ in self.arrayContactGroupSearch {
                    self.arrayBottom.append(["1" : "1"])
                }
            }
            self.feedtble.reloadData()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.reloadDataforSearch()
        return true
    }
}

extension ProfileViewModel {
    
    func getMyReels() {
        
        //        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        var parameters = ["action": "user/reels",
                          "token":SharedManager.shared.userToken()]
        self.isAPICall = true
        parameters["page"] = String(self.reelPageNumber)
        
        RequestManagerGen.fetchDataGet(Completion: { (response: Result<(FeedModel), Error>) in
            self.isAPICall = false
            //            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            switch response {
            case .failure(let error):
                
                if error is ErrorModel  {
                    let err = error as! ErrorModel
                    
                    if err.meta?.message == "Reels not found" {
                        self.isNextVideoExist = false
                    } else if err.meta?.code == ResponseKey.unAuthorizedResp.rawValue {
                        AppDelegate.shared().loadLoginScreen()
                    }
                }
            case .success(let res):
                if let isFeedData = res.data {
                    for indexObj in isFeedData {
                        self.myReelsList.append(indexObj)
                    }
                }
                self.parentView.profileTableView.reloadData()
            }
        }, param:parameters)
    }
    
    func getSavedReels() {
        //        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        var parameters = ["action": "saved/user/reels", "token":SharedManager.shared.userToken()]
        self.isAPICall = true
        parameters["page"] = String(self.reelPageNumber)
        
        RequestManagerGen.fetchDataGet(Completion: { (response: Result<(FeedModel), Error>) in
            self.isAPICall = false
            //            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            switch response {
            case .failure(let error):
                
                if error is ErrorModel  {
                    let err = error as! ErrorModel
                    
                    if err.meta?.message == "Reels not found" {
                        self.isNextVideoExist = false
                    } else if err.meta?.code == ResponseKey.unAuthorizedResp.rawValue {
                        AppDelegate.shared().loadLoginScreen()
                    }
                }
            case .success(let res):
                
                if let isFeedData = res.data {
                    for indexObj in isFeedData {
                        self.savedReelsList.append(indexObj)
                    }
                }
                self.parentView.profileTableView.reloadData()
            }
        }, param:parameters)
    }
}

extension ProfileViewModel: ReelDelegate {
    
    func reeltapped(reel: FeedData) {
        
        var reelList: [FeedData] = []
        if selectedTab == .myReels {
            reelList = self.myReelsList
        } else if selectedTab == .savedReels {
            reelList = self.savedReelsList
        }
        
        let row = reelList.firstIndex(where: { $0.postID == reel.postID}).map({Int($0)})
        let controller = ReelViewController.instantiate(fromAppStoryboard: .Reel)
        controller.items = reelList
        controller.currentIndex = row ?? 0
        controller.isFromSavedReel = true
        controller.hidesBottomBarWhenPushed = true
        UIApplication.topViewController()?.navigationController?.pushViewController(controller, animated: true)
        
    }
    
    func loadMoreReels(indexPath: IndexPath) {
        var reels: [FeedData] = []
        if selectedTab == .myReels {
            reels = self.myReelsList
        } else if selectedTab == .savedReels  {
            reels = self.savedReelsList
        }
        if self.isNextVideoExist {
            if !self.isAPICall {
                if indexPath.row == reels.count - 1 {
                    self.reelPageNumber = self.reelPageNumber + 1
                    
                    if selectedTab == .myReels {
                        self.getMyReels()
                    } else if selectedTab == .savedReels  {
                        self.getSavedReels()
                    }
                }
            }
        }
    }
}

// MARK: - CategoryLikeDelegate -
extension ProfileViewModel: CategoryLikeDelegate {
    func deleteCategory(obj: LikePageModel?, at index: Int?, pageTab: String) {
        LogClass.debugLog(pageTab)
        let pageTitle = obj?.title ?? .emptyString
        let pageCategoryName = pageTab
        let pageId = obj?.pageId ?? .emptyString
        SharedManager.shared.ShowAlertWithCompletaion(title: pageCategoryName.capitalized, message: "Do you really want to delete this category \(pageTitle)?", isError: true) {[weak self] status in
            guard let self else { return }
            if status {
                // call api service
                // sport, tv, movie, game, athlete, music
                let params = [
                    "tab" : pageCategoryName,
                    "page_id" : pageId
                ]
                self.apiService.categoryDeleteRequest(endPoint: .categoryDeleteRequest(params))
                    .sink { completion in
                        switch completion {
                        case .finished:
                            LogClass.debugLog("Finished")
                        case .failure(let error):
                            SwiftMessages.showMessagePopup(theme: .error, title: "Failed", body: error.localizedDescription)                        }
                    } receiveValue: { response in
                        let itemsObj = response.data[pageCategoryName]
                        guard itemsObj?.count ?? 0 > 0 else { return }
                        if let index = itemsObj?.firstIndex(where: {"\($0.pageId)" == obj?.pageId}) {
                            LogClass.debugLog("Deleted Item ==> \(index)")
                            if let obj {
                                let categoryLikePageItem = CategoryLikePageModel(tabName: pageCategoryName, item: obj)
                                LogClass.debugLog("Deleted Item ==> One")
                                NotificationCenter.default.post(name: .CategoryLikePages, object: categoryLikePageItem)
                            }
                        }
                    }.store(in: &subscription)
            }
        }
    }
}


extension ProfileViewModel: ProfileGroupDelegate {
    func deleteProfileGroup(obj: GroupValue?, at index: Int?, pageTab: String) {
        LogClass.debugLog(pageTab)
        let pageTitle = obj?.title ?? .emptyString
        let pageCategoryName = pageTab
        let groupID = obj?.groupID ?? .emptyString
        SharedManager.shared.ShowAlertWithCompletaion(title: pageCategoryName.capitalized, message: "Do you really want to delete this Group \(pageTitle)?", isError: true) {[weak self] status in
            guard let self else { return }
            if status {
                let params = [
                    "group_id" : groupID,
                    "user_id": "\(SharedManager.shared.userObj?.data.id ?? 0)",
                    "token": SharedManager.shared.userToken()
                ]
                self.apiService.leaveGroupMemberRequest(endPoint: .groupMemberLeave(params))
                    .sink { completion in
                        switch completion {
                        case .finished:
                            LogClass.debugLog("Finished")
                        case .failure(let error):
                            SwiftMessages.showMessagePopup(theme: .error, title: "Failed", body: error.localizedDescription)                        }
                    } receiveValue: { response in
                        if response.data.status {
                            if let obj {
                                let profileGroupModel = ProfileGroupPageModel(tabName: pageTab, item: obj)
                                NotificationCenter.default.post(name: .CategoryLikePages, object: profileGroupModel)
                                LogClass.debugLog("Deleted Item ==> One")
                            }
                        }
                    }.store(in: &subscription)
            }
        }
    }
}

