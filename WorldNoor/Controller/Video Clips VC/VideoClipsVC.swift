//
//  VideoClipsVC.swift
//  WorldNoor
//
//  Created by apple on 4/3/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import SDWebImage
import Photos
import TLPhotoPicker
import FittedSheets

class VideoClipsVC: UIViewController  {
    
    @IBOutlet var tbleviewVideos  : UITableView!
    
    var arrayCollectionView = [VideoClipModel]()
    
    var sheetController = SheetViewController()
    
    var arrayYourVideo = [VideoClipModel]()
    var arrayAllVideo = [VideoClipModel]()
    var arrayContactsVideo = [VideoClipModel]()
    
    var imageMain = UIImage.init()
    
    var timerVideoUpload = Timer.init()
    var isRefresh = true
    
    var selectedTag = -1
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Video Clips".localized()
        self.tbleviewVideos.register(UINib.init(nibName: "SettingVideosCell", bundle: nil), forCellReuseIdentifier: "SettingVideosCell")
        self.navigationController?.addRightButtonWithTitle(self, selector: #selector(addNewAction), lblText: "Add New".localized(), widthValue: 75.0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if self.isRefresh {
            self.getAllvideos()
        }
        
        SharedManager.shared.selectedTabController = self
        SocketSharedManager.sharedSocket.commentDelegate = self
        SocketSharedManager.sharedSocket.newsFeedProcessingHandler()
        SocketSharedManager.sharedSocket.newsFeedProcessingHandlerGlobal()

        self.isRefresh = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.timerVideoUpload.invalidate()
    }
    
    @objc func addNewAction(sender : Any){
        self.openPhotoPicker()
    }
    
    func openPhotoPicker(maxValue : Int = 1){
        let viewController = TLPhotosPickerViewController()
        viewController.delegate = self
        
        var configure = TLPhotosPickerConfigure()
        configure.maxSelectedAssets = maxValue
        configure.numberOfColumn = 3
        configure.allowedVideo = true
        configure.allowedLivePhotos = false
        configure.mediaType = .video
        viewController.configure = configure
        
        self.present(viewController, animated: true) {

        }
    }
    
    func getAllvideos(){
        self.arrayYourVideo.removeAll()
        self.arrayAllVideo.removeAll()
        self.arrayContactsVideo.removeAll()
        self.arrayCollectionView.removeAll()
//        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        let parameters = ["action": "stories/by_sections","token": SharedManager.shared.userToken()]
        
        RequestManager.fetchDataGet(Completion: { (response) in
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            
            switch response {
            case .failure(let error):
                SwiftMessages.apiServiceError(error: error)
            case .success(let res):
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                } else  if let newRes = res as? [String:Any] {
                    
                    if let contact_videos = newRes["all_stories"] as? [[String : Any]]
                    {
                        for indexContact in contact_videos{
                            self.arrayAllVideo.append(VideoClipModel.init(fromDictionary: indexContact))
                        }
                    }
                    if let nearby_videos = newRes["contact_stories"] as? [[String : Any]]
                    {
                        for indexContact in nearby_videos{
                            self.arrayContactsVideo.append(VideoClipModel.init(fromDictionary: indexContact))
                        }
                    }
                    
                    if let popular_in_region_videos = newRes["my_stories"] as? [[String : Any]]
                    {
                        for indexContact in popular_in_region_videos{
                            self.arrayYourVideo.append(VideoClipModel.init(fromDictionary: indexContact))
                        }
                    }
                }
                self.tbleviewVideos.reloadData()
            }
        }, param: parameters)
    }
}


extension VideoClipsVC : UITableViewDelegate , UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cellVideo = tableView.dequeueReusableCell(withIdentifier: "SettingVideosCell", for: indexPath) as? SettingVideosCell else {
           return UITableViewCell()
        }
        
        switch indexPath.row {
        case 0:
            cellVideo.lblVideosHeading.text = "Your Video Clips".localized()
            cellVideo.arrayVideos = self.arrayYourVideo
            cellVideo.collectionViewVideos.tag = 0
            
        case 1:
            cellVideo.lblVideosHeading.text = "Video Clips By Your Contacts".localized()
            cellVideo.arrayVideos = self.arrayContactsVideo
            cellVideo.collectionViewVideos.tag = 1
        case 2:
            cellVideo.lblVideosHeading.text = "All Video Clips".localized()
            cellVideo.arrayVideos = self.arrayAllVideo
            cellVideo.collectionViewVideos.tag = 2
            
        default:
            cellVideo.lblVideosHeading.text = "Your Video Clips".localized()
            cellVideo.arrayVideos = self.arrayYourVideo
            cellVideo.collectionViewVideos.tag = 0
        }
        cellVideo.delegateVideo = self
        cellVideo.collectionViewVideos.reloadData()
        cellVideo.selectionStyle = .none
        return cellVideo
    }
}

extension VideoClipsVC : VideoChooseDelegate {
    
    func LanguageChoose(videoIndex : Int ) {
        if videoIndex > -1 {
            self.createStory(idMain: videoIndex)
        }else {
            SharedManager.shared.showAlert(message: "Please choose language first.".localized(), view: self)
        }
    }
    
    func TransciptChoose(videoIndex : Int , collectionIndex : Int ){
        
    }
    
    
    func createStory(idMain: Int) {
        
        self.arrayYourVideo[idMain].isProcessing = true
        
        self.tbleviewVideos.reloadData()
        let userToken = SharedManager.shared.userObj!.data.token
        let parameters = ["action": "post/create",
                          "token": userToken! ,
                          "post_scope_id" : "2" ,
                          "file_urls[0]" : self.arrayYourVideo[idMain].hashURL ,
                          "files_info[0][thumbnail_url]" : self.arrayYourVideo[idMain].thumbnail ] as [String : Any]
        
        CreateRequestManager.uploadMultipartVideoClip(params: parameters,
                                                      success: { (JSONResponse) -> Void in
            let respDict = JSONResponse
            let meta = respDict["meta"] as! NSDictionary
            let code = meta["code"] as! Int
            let dataMain = respDict["data"] as! [String : Any]
            if code == ResponseKey.successResp.rawValue {
                //self.processAPI(hashFile: self.arrayYourVideo[idMain].hashURL ,arrayIndex: idMain)
                self.arrayYourVideo[idMain].postID = SharedManager.shared.ReturnValueAsString(value: dataMain["post_id"] as Any)
                // added this line
                self.arrayYourVideo[idMain].isProcessing = false
                self.tbleviewVideos.reloadData()
            }
        },failure: {(error) -> Void in

        }, isShowProgress: false)
    }
    
//    func processAPI(hashFile: String, arrayIndex: Int ) {
//
//        let userToken = SharedManager.shared.userObj!.data.token
//
//        let parameters = ["action": "process-file",
//                          "api_token": userToken,
//                          "serviceType":"Media",
//                          "processVideoAsWell":"true",
//                          "hashes[0]": hashFile,
//                          "post_scope_id": "2"]
//        CreateRequestManager.uploadMultipartVideoClip(params: parameters as! [String : String],
//                                                      success: { (JSONResponse) -> Void in
////            let respDict = JSONResponse
//            self.arrayYourVideo[arrayIndex].isProcessing = false
//            self.tbleviewVideos.reloadData()
//
//        },failure: {(error) -> Void in
//
//        },isShowProgress: false)
//    }
    
    func VideoChooseDelegate(videoIndex : Int , arrayIndex : Int) {
        
        if videoIndex > -1 {
            self.arrayCollectionView.removeAll()
            switch arrayIndex {
            case 0:
                self.arrayCollectionView = self.arrayYourVideo
            case 1:
                self.arrayCollectionView = self.arrayContactsVideo
            case 2:
                self.arrayCollectionView = self.arrayAllVideo
                
            default:
                self.arrayCollectionView.removeAll()
            }
            
            let fullScreen = AppStoryboard.PostStoryboard.instance.instantiateViewController(withIdentifier: Const.FullGalleryScreenController) as! FullGalleryViewController
            let valueDict = [String : Any]()
            
            let feedObj = FeedData.init(valueDict: valueDict)
            
            
            feedObj.postType = FeedType.video.rawValue
            
            var post = [PostFile]()
            
            for indexObj in  self.arrayCollectionView {
                let newPostfile = PostFile.init()
                newPostfile.fileType = FeedType.video.rawValue
                newPostfile.filePath = indexObj.path
                newPostfile.postID = Int(indexObj.id)
                post.append( newPostfile)
            }
            fullScreen.isInfoViewShow = true
            feedObj.post = post
            fullScreen.collectionArray = feedObj.post!
            fullScreen.feedObj = feedObj
            fullScreen.movedIndexpath = videoIndex
            fullScreen.isFromStories = false
            fullScreen.startingPoint = ""
            fullScreen.modalTransitionStyle = .crossDissolve
            fullScreen.currentIndex = IndexPath.init(row: videoIndex, section: 0)
            self.present(fullScreen, animated: false, completion: nil)

        }else {
            
            self.selectedTag = (videoIndex * -1) - 1
            let langController = AppStoryboard.TabBar.instance.instantiateViewController(withIdentifier: "LanguageSelectionController") as! LanguageSelectionController
            langController.delegate = self
            self.sheetController = SheetViewController(controller: langController, sizes: [.fixed(500)])
            self.sheetController.overlayColor = UIColor.black.withAlphaComponent(0.3)
            self.sheetController.extendBackgroundBehindHandle = true
            self.sheetController.topCornersRadius = 20
            self.present(self.sheetController, animated: false, completion: nil)
        }
    }
}

extension VideoClipsVC : LanguageSelectionDelegate {
    
    func lanaguageSelected(langObj: LanguageModel, indexPath: IndexPath) {
        
    }
    func lanaguageSelected(langObj:LanguageModel){
        self.arrayYourVideo[self.selectedTag].languageName = langObj.languageName
        self.arrayYourVideo[self.selectedTag].languageID = langObj.languageID
        self.tbleviewVideos.reloadData()
        self.sheetController.closeSheet()
    }
}

extension VideoClipsVC {
    
    func encodeVideo(videoURL: URL,completion : @escaping ((_ newURL : URL?) -> Void))  {
        let avAsset = AVURLAsset(url: videoURL, options: nil)
        var exportSession : AVAssetExportSession?
        let startDate = NSDate()
        
        //Create Export session
        exportSession = AVAssetExportSession(asset: avAsset, presetName: AVAssetExportPresetLowQuality)
        
        // exportSession = AVAssetExportSession(asset: composition, presetName: mp4Quality)
        //Creating temp path to save the converted video
        
        let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let myDocumentPath = NSURL(fileURLWithPath: documentsDirectory).appendingPathComponent("temp.mp4")?.absoluteString
        _ = URL.init(string: myDocumentPath!)
        
        let documentsDirectory2 = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as NSURL
        
        let filePath = documentsDirectory2.appendingPathComponent("rendered-Video.mp4")
        self.deleteFile(filePath: filePath!)
        if FileManager.default.fileExists(atPath: myDocumentPath!) {
            do {
                try FileManager.default.removeItem(atPath: myDocumentPath!)
            }
            catch let error {
                
            }
        }
        
        exportSession!.outputURL = filePath
        exportSession!.outputFileType = AVFileType.mp4
        exportSession!.shouldOptimizeForNetworkUse = true
        let start = CMTimeMakeWithSeconds(0.0, preferredTimescale: 0)
        let range = CMTimeRangeMake(start: start, duration: avAsset.duration)
        exportSession!.timeRange = range
        
        exportSession!.exportAsynchronously(completionHandler: {() -> Void in
            switch exportSession?.status {
            case .failed:
                completion(nil)
            case .cancelled:
                completion(nil)
            case .completed:
                completion(exportSession?.outputURL)
            default:
                break
            }
        })
    }
    
    func deleteFile(filePath: URL) {
        guard FileManager.default.fileExists(atPath: filePath.path) else {
            return
        }
        
        do {
            try FileManager.default.removeItem(atPath: filePath.path)
        }catch{
            fatalError("Unable to delete file: \(error) : \(#function).")
        }
    }
}


extension VideoClipsVC : TLPhotosPickerViewControllerDelegate {
    
    func dismissPhotoPicker(withTLPHAssets: [TLPHAsset]) {
        // use selected order, fullresolution image
        
        for indexObj in withTLPHAssets {
            
            if indexObj.type == .video {
                self.exportVideo(asset: indexObj)
            }
        }
    }
    
    func uploadFile(filePath:String, fileType:String , imageMAin : UIImage = UIImage.init()){
        
        
        let requestUpload = RequestManagerUploading.init()
        requestUpload.delegate = self
        
        
    
        let newTime = SharedManager.shared.getCurrentDateString()
        let testFromDefaults = UserDefaults.standard.object([String: String].self, with: "VideoUpload")
        if (testFromDefaults != nil) {
            
        }else {
            
            var newObj = UserDefaults.standard.object([String: String].self, with: "VideoUpload")
            if newObj == nil {
                newObj = [String : String]()
            }
            newObj![String(self.arrayYourVideo.count)] = "0"
            requestUpload.uploadTag = self.arrayYourVideo.count
            UserDefaults.standard.set(object: newObj, forKey: "VideoUpload")
            UserDefaults.standard.synchronize()
        }
        DispatchQueue.main.async {
            self.timerVideoUpload.invalidate()
            self.timerVideoUpload = Timer.scheduledTimer(timeInterval: 0.9, target: self, selector: #selector(self.timerHandler), userInfo: nil, repeats: true)
            let newDict = [String : Any]()
            let newObj = VideoClipModel.init(fromDictionary: newDict)
            newObj.authorObj.username = SharedManager.shared.userEditObj.firstname + " " + SharedManager.shared.userEditObj.lastname
            newObj.id = String(self.arrayYourVideo.count)
            newObj.localImage = imageMAin
            newObj.localVideoURL = filePath
            newObj.videoUploadprogress = 0
            self.arrayYourVideo.insert(newObj, at: 0)
            self.tbleviewVideos.reloadData()
        }
        
        
        requestUpload.callingServiceForVideoClip(videoURL: filePath, imgThumb: imageMAin)
    }
    
    @objc func timerHandler(){

        let testFromDefaults = UserDefaults.standard.object([String: String].self, with: "VideoUpload")
        for indexObj in testFromDefaults!.keys {
            for indexObjMain in self.arrayYourVideo {
                if indexObjMain.id == indexObj {
                    indexObjMain.processing_status = testFromDefaults![indexObj]!
                }
            }
        }
        self.tbleviewVideos.reloadData()
    }
    
    func callingServiceToUpload(parameters:[String:Any] , newTime: String, fileType:String)  {
        RequestManager.fetchDataMultiparts(Completion: { response in
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            switch response {
            case .failure(let error):
                if error is String {
                }
            case .success(let res):
                if let mainResult = res as? [String : Any] {
                    if let mainData = mainResult["data"] as? [String : Any] {
                        if let mainfile = mainData["file_url"] as? String {
                            if let thumbnail_url = mainData["thumbnail_url"] as? String {
                                DispatchQueue.main.async {
                                    let index = Int(parameters["DBKey"] as! String)!
                                    self.arrayYourVideo[index].thumbnail = thumbnail_url
                                    self.arrayYourVideo[index].path = mainfile
                                }
                            }else {
                                DispatchQueue.main.async {
                                    let index = Int(parameters["DBKey"] as! String)!
                                    self.arrayYourVideo[index].thumbnail = ""
                                    self.arrayYourVideo[index].path = mainfile
                                }
                            }
                        }
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
    
    func exportVideo(asset  : TLPHAsset) {
        asset.exportVideoFile(progressBlock: { (progress) in
            
        }) { (url, mimeType) in
            self.videoSave(urlMain : url)
        }
    }
    
    func videoSave(urlMain : URL){
        let asset = AVURLAsset(url: urlMain, options: nil)
        let imgGenerator = AVAssetImageGenerator(asset: asset)
        var cgImage : CGImage
        cgImage = try! imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
        self.uploadFile(filePath: urlMain.path, fileType: "video" ,imageMAin: UIImage(cgImage: cgImage))
    }
}

extension VideoClipsVC : RequestManagerUploadingProtocol {
    
    //}
    
    
    //protocol RequestManagerUploadingProtocol {
    func requestManagerUploadingStartedDelegate(uploadTag: Int)
    {
        
    }
    func requestManagerProgressDelegate(progress:CGFloat , uploadTag: Int)
    {
        
        
        var testFromDefaults = UserDefaults.standard.object([String: String].self, with: "VideoUpload")
        if (testFromDefaults != nil)  {
            let value = String(uploadTag)
            //                var str = String(progress)
            var str = progress.description
            str = str.addDecimalPoints(decimalPoint: "2")
            testFromDefaults![value] = str.addDecimalPoints(decimalPoint: "2")
            UserDefaults.standard.set(object: testFromDefaults, forKey: "VideoUpload")
            UserDefaults.standard.synchronize()
            
        }
    }
    func requestManagerResponseUploadedDelegate(res:Any , uploadTag: Int)
    {
        if let Newdata = res as? [[String : Any]] {
            if Newdata.count > 0 {
                let firstObj = Newdata.first as! [String : AnyObject]
                
                
                for indexObj in self.arrayYourVideo {
                    if indexObj.id == String(uploadTag) {
                        indexObj.hashURL = firstObj["url"] as! String
                        indexObj.thumbnail = (firstObj["thumbnail"] as! [String : AnyObject])["url"] as! String
                    }
                }
            }
        }
    }
    
    func requestManagerResponseFailureDelegate(res:Any , uploadTag: Int)
    {
        
    }
}




extension VideoClipsVC : feedCommentDelegate {
    
    func videoProcessingSocketResponse(res:NSArray) {
        if res.count > 0 {
            let dict = res[0] as! [String:Any]
            if dict["additional_data"] != nil {
                let additionalDict = dict["additional_data"] as! [String:Any]
                let postDict = additionalDict["post"] as! [String:Any]
                if let postScope = postDict["post_id"] as? Int {
                    
                    for indexObj in self.arrayYourVideo {
                        if indexObj.postID == SharedManager.shared.ReturnValueAsString(value: postScope as Any) {
                            indexObj.isProcessing = false
                            indexObj.localVideoURL = ""
                        }
                    }
                    
                    self.tbleviewVideos.reloadData()
                    
                }else {
                }
            }
        }
    }
}

