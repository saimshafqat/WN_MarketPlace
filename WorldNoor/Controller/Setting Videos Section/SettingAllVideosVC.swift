//
//  SettingAllVideosVC.swift
//  WorldNoor
//
//  Created by apple on 4/1/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import FittedSheets

protocol VideoChooseDelegate{
    func VideoChooseDelegate(videoIndex : Int , arrayIndex : Int)
    func LanguageChoose(videoIndex : Int )
    func TransciptChoose(videoIndex : Int , collectionIndex : Int )
}


class SettingAllVideosVC: UIViewController {
    
    @IBOutlet var tbleviewVideos  : UITableView!
    var arrayContactVideo = [SettingVideoModel]()
    var arrayNearByVideo = [SettingVideoModel]()
    var arrayPopularInRegionVideo = [SettingVideoModel]()
    var arraySuggestedVideo = [SettingVideoModel]()
    var arrayTaggedVideo = [SettingVideoModel]()
    
    
    
    var pageContactVideo = 1
    var pageNearByVideo = 1
    var pagePopularInRegionVideo = 1
    var pageSuggestedVideo = 1
    var pageTaggedVideo = 1
    
    
    
    var sheetController = SheetViewController()
    
    
    var isRefresh = true
    var isReload = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tbleviewVideos.register(UINib.init(nibName: "AdCell", bundle: nil), forCellReuseIdentifier: "AdCell")
        self.tbleviewVideos.register(UINib.init(nibName: "SettingVideosSectionCell", bundle: nil), forCellReuseIdentifier: "SettingVideosSectionCell")
        self.title = "Videos".localized()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if self.isRefresh {
            self.getAllvideos()
        }
        
        self.isRefresh = true
    }
    
    
    func getAllvideos(){
//        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        let parameters = ["action": "videos/by_sections","token": SharedManager.shared.userToken()]
        
        RequestManager.fetchDataGet(Completion: { (response) in
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            switch response {
            case .failure(let error):
                SwiftMessages.apiServiceError(error: error)
            case .success(let res):
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                } else if let newRes = res as? [String:Any] {
                    if let contact_videos = newRes["contact_videos"] as? [[String : Any]]
                    {
                        for indexContact in contact_videos{
                            self.arrayContactVideo.append(SettingVideoModel.init(fromDictionary: indexContact))
                        }
                        
                    }
                    
                    for indexObj in 0..<self.arrayContactVideo.count {
                        DispatchQueue.main.async {
                            if self.arrayContactVideo[indexObj].file_translation_link.count > 0 {
                                self.GettingConvertedVideoURL(postfileID: String(self.arrayContactVideo[indexObj].id),URLHIT:self.arrayContactVideo[indexObj].file_translation_link,rowReload: indexObj)
                            }
                            
                        }
                    }
                    
                    
                    if let nearby_videos = newRes["nearby_videos"] as? [[String : Any]]
                    {
                        for indexContact in nearby_videos{
                            self.arrayNearByVideo.append(SettingVideoModel.init(fromDictionary: indexContact))
                        }
                        
                    }
                    
                    for indexObj in 0..<self.arrayNearByVideo.count {
                        DispatchQueue.main.async {
                            
                            if self.arrayNearByVideo[indexObj].file_translation_link.count > 0 {
                                self.GettingConvertedVideoURL(postfileID: String(self.arrayNearByVideo[indexObj].id),URLHIT:self.arrayNearByVideo[indexObj].file_translation_link,rowReload: indexObj)
                            }
                            
                        }
                    }
                    
                    if let popular_in_region_videos = newRes["popular_in_region"] as? [[String : Any]]
                    {
                        for indexContact in popular_in_region_videos{
                            self.arrayPopularInRegionVideo.append(SettingVideoModel.init(fromDictionary: indexContact))
                        }
                        
                    }
                    
                    
                    for indexObj in 0..<self.arrayPopularInRegionVideo.count {
                        DispatchQueue.main.async {
                            if self.arrayPopularInRegionVideo[indexObj].file_translation_link.count > 0 {
                                self.GettingConvertedVideoURL(postfileID: String(self.arrayPopularInRegionVideo[indexObj].id),URLHIT:self.arrayPopularInRegionVideo[indexObj].file_translation_link,rowReload: indexObj)
                        
                            }
                        }
                    }
                    
                    if let suggested_videos = newRes["suggested_videos"] as? [[String : Any]]
                    {
                        for indexContact in suggested_videos{
                            self.arraySuggestedVideo.append(SettingVideoModel.init(fromDictionary: indexContact))
                        }
                        
                    }
                    
                    for indexObj in 0..<self.arraySuggestedVideo.count {
                        DispatchQueue.main.async {
                            if self.arraySuggestedVideo[indexObj].file_translation_link.count > 0 {
                                self.GettingConvertedVideoURL(postfileID: String(self.arraySuggestedVideo[indexObj].id),URLHIT:self.arraySuggestedVideo[indexObj].file_translation_link,rowReload: indexObj)
                            }
                            
                        }
                    }
                    
                    if let tagged_videos = newRes["tagged_videos"] as? [[String : Any]]
                    {
                        for indexContact in tagged_videos{
                            self.arrayTaggedVideo.append(SettingVideoModel.init(fromDictionary: indexContact))
                        }
                        
                    }
                    
                    for indexObj in 0..<self.arrayTaggedVideo.count {
                        DispatchQueue.main.async {
                            if self.arrayTaggedVideo[indexObj].file_translation_link.count > 0 {
                                self.GettingConvertedVideoURL(postfileID: String(self.arrayTaggedVideo[indexObj].id),URLHIT:self.arrayTaggedVideo[indexObj].file_translation_link,rowReload: indexObj       )
                            }
                            
                        }
                    }
                }
                
                
                self.isReload = true
                self.tbleviewVideos.reloadData()
            }
        }, param: parameters)
    }
    
    
    func GettingConvertedVideoURL(postfileID : String , URLHIT : String , rowReload : Int){
        RequestManager.fetchDataPostWithURL(MainURL: URLHIT) { response in
            switch response {
            case .failure( _):
                LogClass.debugLog("failure failure")
            case .success(let res):
                switch rowReload {
                case 0:
                    for indexObj in self.arrayTaggedVideo {
                        if postfileID == indexObj.id {
                            indexObj.translationLink = res as! String
                            break
                        }
                    }
                    
                case 1:
                    
                    for indexObj in self.arrayContactVideo {
                        if postfileID == indexObj.id {
                            indexObj.translationLink = res as! String
                            break
                        }
                    }
                    
                    
                case 2:
                    for indexObj in self.arraySuggestedVideo {
                        if postfileID == indexObj.id {
                            indexObj.translationLink = res as! String
                            break
                        }
                    }
                    
                case 3:
                    for indexObj in self.arrayPopularInRegionVideo {
                        if postfileID == indexObj.id {
                            indexObj.translationLink = res as! String
                            break
                        }
                    }
                case 4:
                    for indexObj in self.arrayNearByVideo {
                        if postfileID == indexObj.id {
                            indexObj.translationLink = res as! String
                            break
                        }
                    }
                default:                    
                    LogClass.debugLog("")
                }
                
                
            }
        }
    }
}


extension SettingAllVideosVC : UITableViewDelegate , UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        var sizeMain : CGFloat = 0.0
        if indexPath.row == 0{
            sizeMain = CGFloat((self.arrayTaggedVideo.count / 2) * 185)
            if self.arrayTaggedVideo.count == 0 {
                return 105
            }
            return CGFloat(95 + sizeMain)
        }else if indexPath.row == 1{
            return UITableView.automaticDimension
        }else if indexPath.row == 2{
            sizeMain = CGFloat((self.arrayContactVideo.count / 2) * 185)
            if self.arrayContactVideo.count == 0 {
                return 105
            }
            return CGFloat(95 + sizeMain)
        }else if indexPath.row == 3{
            return 0
//            sizeMain = CGFloat((self.arraySuggestedVideo.count / 2) * 185)
//            if self.arraySuggestedVideo.count == 0 {
//                return 105
//            }
//            return CGFloat(95 + sizeMain)
        }else if indexPath.row == 4{
            sizeMain = CGFloat((self.arrayPopularInRegionVideo.count / 2) * 185)
            if self.arrayPopularInRegionVideo.count == 0 {
                return 105
            }
            return CGFloat(95 + sizeMain)
        }else if indexPath.row == 5{
            sizeMain = CGFloat((self.arrayNearByVideo.count / 2) * 185)
            if self.arrayNearByVideo.count == 0 {
                return 105
            }
            return CGFloat(95 + sizeMain)
        }
        
        return UITableView.automaticDimension
        
    }
  
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cellVideo = tableView.dequeueReusableCell(withIdentifier: "SettingVideosSectionCell", for: indexPath) as! SettingVideosSectionCell
        
        guard let cellVideo = tableView.dequeueReusableCell(withIdentifier: "SettingVideosSectionCell", for: indexPath) as? SettingVideosSectionCell else {
           return UITableViewCell()
        }
        
        cellVideo.viewLoadMore.isHidden = true
        switch indexPath.row {
        case 0:
            cellVideo.lblVideosHeading.text = "My videos".localized()
            cellVideo.arrayVideos = self.arrayTaggedVideo
            if self.arrayTaggedVideo.count > 0 {
                cellVideo.viewLoadMore.isHidden = false
            }
            cellVideo.collectionViewVideos.tag = 0
            
        case 1:
//            let cellAd = tableView.dequeueReusableCell(withIdentifier: "AdCell", for: indexPath) as! AdCell
            
            guard let cellAd = tableView.dequeueReusableCell(withIdentifier: "AdCell", for: indexPath) as? AdCell else {
               return UITableViewCell()
            }
            cellAd.bannerView.rootViewController = self
            return cellAd
        case 2:
            cellVideo.lblVideosHeading.text = "Videos by my contact".localized()
            cellVideo.arrayVideos = self.arrayContactVideo
            if self.arrayContactVideo.count > 0 {
                cellVideo.viewLoadMore.isHidden = false
            }
            cellVideo.collectionViewVideos.tag = 1
            
        case 3:
            cellVideo.lblVideosHeading.text = "Suggested videos".localized()
            cellVideo.arrayVideos = self.arraySuggestedVideo
            if self.arraySuggestedVideo.count > 0 {
                cellVideo.viewLoadMore.isHidden = false
            }
            
            cellVideo.collectionViewVideos.tag = 2
        case 4:
            cellVideo.lblVideosHeading.text = "Popular In Region".localized()
            cellVideo.arrayVideos = self.arrayPopularInRegionVideo
            if self.arrayPopularInRegionVideo.count > 0 {
                cellVideo.viewLoadMore.isHidden = false
            }
            cellVideo.collectionViewVideos.tag = 3
        case 5:
            cellVideo.lblVideosHeading.text = "Nearby videos".localized()
            cellVideo.arrayVideos = self.arrayNearByVideo
            if self.arrayNearByVideo.count > 0 {
                cellVideo.viewLoadMore.isHidden = false
            }
            cellVideo.collectionViewVideos.tag = 4
            
        default:
            cellVideo.lblVideosHeading.text = "Your videos".localized()
            cellVideo.collectionViewVideos.tag = 5
        }
        
        cellVideo.btnLoadMore.tag = indexPath.row
        cellVideo.btnLoadMore.addTarget(self, action: #selector(self.LoadMoreAction), for: .touchUpInside)
        cellVideo.delegateVideo = self
        cellVideo.collectionViewVideos.reloadData()
        cellVideo.selectionStyle = .none
        return cellVideo
    }
    
    
    @objc func LoadMoreAction(sender : UIButton){
        
        var loadMoreSection = ""
        var pageNumber = 1
        if sender.tag == 0 {
            loadMoreSection = "tagged_videos"
            pageTaggedVideo = pageTaggedVideo + 1
            pageNumber = pageTaggedVideo
        }else if sender.tag == 2 {
            loadMoreSection = "contact_videos"
            pageContactVideo = pageContactVideo + 1
            pageNumber = pageContactVideo
        }else if sender.tag == 3 {
            loadMoreSection = "suggested_videos"
            pageSuggestedVideo = pageSuggestedVideo + 1
            pageNumber = pageSuggestedVideo
        }else if sender.tag == 4 {
            loadMoreSection = "popular_in_region"
            pagePopularInRegionVideo = pagePopularInRegionVideo + 1
            pageNumber = pagePopularInRegionVideo
        }else if sender.tag == 5 {
            loadMoreSection = "nearby_videos"
            pageNearByVideo = pageNearByVideo + 1
            pageNumber = pageNearByVideo
        }
        
        let parameters = [
            "action": "videos/by_sections",
            "token": SharedManager.shared.userToken(),
            "type" : loadMoreSection,
            "page" : String(pageNumber) ,
            "load_more" : "true"
        ]
        
        
//        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        RequestManager.fetchDataGet(Completion: { response in
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            switch response {
            case .failure(let error):
                SwiftMessages.apiServiceError(error: error)
            case .success(let res):
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                }else if let newRes = res as? [String:Any]
                {
                    if let contact_videos = newRes["contact_videos"] as? [[String : Any]]
                    {
                        for indexContact in contact_videos{
                            self.arrayContactVideo.append(SettingVideoModel.init(fromDictionary: indexContact))
                        }
                        
                    }
                    
                    for indexObj in 0..<self.arrayContactVideo.count {
                        DispatchQueue.main.async {
                            if self.arrayContactVideo[indexObj].file_translation_link.count > 0 {
                                self.GettingConvertedVideoURL(postfileID: String(self.arrayContactVideo[indexObj].id),URLHIT:self.arrayContactVideo[indexObj].file_translation_link,rowReload: indexObj)
                            }
                            
                        }
                    }
                    
                    
                    if let nearby_videos = newRes["nearby_videos"] as? [[String : Any]]
                    {
                        for indexContact in nearby_videos{
                            self.arrayNearByVideo.append(SettingVideoModel.init(fromDictionary: indexContact))
                        }
                        
                    }
                    
                    for indexObj in 0..<self.arrayNearByVideo.count {
                        DispatchQueue.main.async {
                            
                            if self.arrayNearByVideo[indexObj].file_translation_link.count > 0 {
                                self.GettingConvertedVideoURL(postfileID: String(self.arrayNearByVideo[indexObj].id),URLHIT:self.arrayNearByVideo[indexObj].file_translation_link,rowReload: indexObj)
                            }
                            
                        }
                    }
                    
                    if let popular_in_region_videos = newRes["popular_in_region"] as? [[String : Any]]
                    {
                        for indexContact in popular_in_region_videos{
                            self.arrayPopularInRegionVideo.append(SettingVideoModel.init(fromDictionary: indexContact))
                        }
                        
                    }
                    
                    
                    for indexObj in 0..<self.arrayPopularInRegionVideo.count {
                        DispatchQueue.main.async {
                            if self.arrayPopularInRegionVideo[indexObj].file_translation_link.count > 0 {
                                self.GettingConvertedVideoURL(postfileID: String(self.arrayPopularInRegionVideo[indexObj].id),URLHIT:self.arrayPopularInRegionVideo[indexObj].file_translation_link,rowReload: indexObj)
                        
                            }
                        }
                    }
                    
                    if let suggested_videos = newRes["suggested_videos"] as? [[String : Any]]
                    {
                        for indexContact in suggested_videos{
                            self.arraySuggestedVideo.append(SettingVideoModel.init(fromDictionary: indexContact))
                        }
                        
                    }
                    
                    for indexObj in 0..<self.arraySuggestedVideo.count {
                        DispatchQueue.main.async {
                            if self.arraySuggestedVideo[indexObj].file_translation_link.count > 0 {
                                self.GettingConvertedVideoURL(postfileID: String(self.arraySuggestedVideo[indexObj].id),URLHIT:self.arraySuggestedVideo[indexObj].file_translation_link,rowReload: indexObj)
                            }
                            
                        }
                    }
                    
                    if let tagged_videos = newRes["tagged_videos"] as? [[String : Any]]
                    {
                        for indexContact in tagged_videos{
                            self.arrayTaggedVideo.append(SettingVideoModel.init(fromDictionary: indexContact))
                        }
                        
                    }
                    
                    for indexObj in 0..<self.arrayTaggedVideo.count {
                        DispatchQueue.main.async {
                            if self.arrayTaggedVideo[indexObj].file_translation_link.count > 0 {
                                self.GettingConvertedVideoURL(postfileID: String(self.arrayTaggedVideo[indexObj].id),URLHIT:self.arrayTaggedVideo[indexObj].file_translation_link,rowReload: indexObj       )
                            }
                            
                        }
                    }
                }
                
                
                self.isReload = true
                self.tbleviewVideos.reloadData()
            }
        }, param: parameters)
    }
    
    
}

extension SettingAllVideosVC : VideoChooseDelegate {
    func LanguageChoose(videoIndex : Int ) {
        
        
    }
    
    func TransciptChoose(videoIndex : Int , collectionIndex : Int ){
        
//        var IDFile = ""
//        switch collectionIndex {
//        case 0:
//            IDFile = self.arrayTaggedVideo[videoIndex].id
//        case 1:
//            IDFile = self.arrayContactVideo[videoIndex].id
//        case 2:
//            IDFile = self.arraySuggestedVideo[videoIndex].id
//        case 3:
//            IDFile = self.arrayPopularInRegionVideo[videoIndex].id
//        case 4:
//            IDFile = self.arrayNearByVideo[videoIndex].id
//        default:
//            IDFile = ""
//        }
//        
//        
//        SharedManager.shared.showLoadingHub(view: self.view)
//        let parameters = ["action": "post_file/transcript","token": SharedManager.shared.userToken() , "file_id" : IDFile]
//        
//        RequestManager.fetchDataGet(Completion: { (response) in
//            SharedManager.shared.hideLoadingHub(view: self.view)
//            
//            switch response {
//            case .failure(let error):
//                if error is String {
//                    SharedManager.shared.showAlert(message: Const.networkProblemMessage.localized(), view: self)
//                }
//            case .success(let res):
//                if res is Int {
//                    AppDelegate.shared().loadLoginScreen()
//                }else if let newRes = res as? [String:Any]
//                {
//                    
//                    let videoTranscript = AppStoryboard.TabBar.instance.instantiateViewController(withIdentifier: "VideoTranscriptController") as! VideoTranscriptController
//                    videoTranscript.transcriptDict = newRes
//                    videoTranscript.isReloadCall = false
//                    self.sheetController = SheetViewController(controller: videoTranscript, sizes: [.fullScreen])
//                    self.sheetController.overlayColor = UIColor.black.withAlphaComponent(0.3)
//                    self.sheetController.extendBackgroundBehindHandle = true
//                    self.sheetController.topCornersRadius = 20
//                    self.present(self.sheetController, animated: false, completion: nil)
//                }
//                
//            }
//        }, param: parameters)
        
    }
    
    func VideoChooseDelegate(videoIndex : Int , arrayIndex : Int) {
        var videoURLString = ""
        var videoIndexP = 0
        var arrayDummy = [SettingVideoModel]()
        switch arrayIndex {
        case 0:
            if videoIndex > 999 {
                videoURLString = self.arrayTaggedVideo[videoIndex - 1000].file_path
                arrayDummy = self.arrayTaggedVideo
                videoIndexP = videoIndex - 1000
            }else {
                videoURLString = self.arrayTaggedVideo[videoIndex].file_path
                arrayDummy = self.arrayTaggedVideo
                videoIndexP = videoIndex
            }
            
        case 1:
            arrayDummy = self.arrayContactVideo
            if videoIndex > 999 {
                videoURLString = self.arrayContactVideo[videoIndex - 1000].translationLink
                videoIndexP = videoIndex - 1000
            }else {
                videoURLString = self.arrayContactVideo[videoIndex].file_path
                videoIndexP = videoIndex
            }
            
        case 2:
            arrayDummy = self.arraySuggestedVideo
            if videoIndex > 999 {
                videoURLString = self.arraySuggestedVideo[videoIndex - 1000].translationLink
                videoIndexP = videoIndex - 1000
            }else {
                videoURLString = self.arraySuggestedVideo[videoIndex].file_path
                videoIndexP = videoIndex
            }
            
        case 3:
            arrayDummy = self.arrayPopularInRegionVideo
            if videoIndex > 999 {
                videoURLString = self.arrayPopularInRegionVideo[videoIndex - 1000].translationLink
                videoIndexP = videoIndex - 1000
            }else {
                videoURLString = self.arrayPopularInRegionVideo[videoIndex].file_path
                videoIndexP = videoIndex
            }
        case 4:
            arrayDummy = self.arrayNearByVideo
            if videoIndex > 999 {
                videoURLString = self.arrayNearByVideo[videoIndex - 1000].translationLink
                videoIndexP = videoIndex - 1000
            }else {
                videoURLString = self.arrayNearByVideo[videoIndex].file_path
                videoIndexP = videoIndex
            }
        default:
            videoURLString = ""
        }
        
       
        
        var valueempty = [String : Any]()
        var feedObj = FeedData.init(valueDict: valueempty)

        feedObj.postType = FeedType.video.rawValue

        var postFiles = [PostFile]()
        for indexObj in arrayDummy  {
                var postObj = PostFile.init()
                postObj.fileType = FeedType.video.rawValue
                postObj.filePath = indexObj.file_path
                postFiles.append(postObj)
        }

        feedObj.post = postFiles
        
        
        let fullScreen = AppStoryboard.PostStoryboard.instance.instantiateViewController(withIdentifier: Const.FullGalleryScreenController) as! FullGalleryViewController

        fullScreen.isInfoViewShow = true
        fullScreen.collectionArray = feedObj.post!
        fullScreen.feedObj = feedObj
        fullScreen.movedIndexpath = videoIndexP
        
        fullScreen.modalTransitionStyle = .crossDissolve
        UIApplication.topViewController()!.present(fullScreen, animated: false, completion: nil)
        
        
//        self.showdetail(feedObj: feedObj, currentIndex: videoIndexP)
//        if videoURLString.count > 0 {
//            self.isRefresh = false
//            let videoURL = URL.init(string: videoURLString)
//            let player = AVPlayer(url: videoURL! as URL)
//            let playerViewController = AVPlayerViewController()
//            playerViewController.player = player
//            self.present(playerViewController, animated: true) {
//                playerViewController.player!.play()
//            }
//        }
    }
}



