//
//  StoryModuleVC.swift
//  WorldNoor
//
//  Created by apple on 6/29/22.
//  Copyright © 2022 Raza najam. All rights reserved.
//

import Foundation
import UIKit
import TLPhotoPicker
import Photos

class StoryModuleVC : UIViewController, TLPhotosPickerViewControllerDelegate {
    
    var feedModel = FeedVideoModel.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.title = "Add Your Story".localized()
        super.viewWillAppear(animated)
    }
    
    @IBAction func textStoryAction(sender : UIButton) {
        
        self.PushViewWithStoryBoard(name: "BgTextViewController", StoryBoard: "StoryModule")
    }
    
    @IBAction func imageStoryAction(sender : UIButton) {
        
        let viewController = TLPhotosPickerViewController()
        viewController.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
        viewController.delegate = self
        viewController.configure.mediaType = .image
        viewController.configure.maxSelectedAssets = 1
        self.present(viewController, animated: true) {
        }
    }
    
    @IBAction func videoStoryAction(sender : UIButton) {
        
        let viewController = TLPhotosPickerViewController()
        viewController.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
        viewController.delegate = self
        viewController.configure.mediaType = .video
        viewController.configure.maxSelectedAssets = 1
        self.present(viewController, animated: true) {
        }
    }
    
    @IBAction func browseBtnClicked(_ sender: Any) {
        let viewController = TLPhotosPickerViewController()
        viewController.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
        viewController.delegate = self
        viewController.configure.mediaType = .video
        viewController.configure.maxSelectedAssets = 1
        self.present(viewController, animated: true) {
        }
    }
    
    private func resolutionForLocalVideo(url: URL) -> CGSize? {
        guard let track = AVURLAsset(url: url).tracks(withMediaType: AVMediaType.video).first else { return nil }
        let size = track.naturalSize.applying(track.preferredTransform)
        return CGSize(width: abs(size.width), height: abs(size.height))
    }
    
    func dismissPhotoPicker(withTLPHAssets: [TLPHAsset]) {
        // use selected order, fullresolution image
        
        for indexObj in withTLPHAssets {
            if indexObj.type == .video {
                do {
                    let options: PHVideoRequestOptions = PHVideoRequestOptions()
                    options.version = .original
                    PHImageManager.default().requestAVAsset(forVideo: indexObj.phAsset!, options: options, resultHandler: {[weak self] (asset, audioMix, info) in
                        if let urlAsset = asset as? AVURLAsset {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                let thumbImage:UIImage = SharedManager.shared.getImageFromAsset(asset: indexObj.phAsset!)!
                                let dict:[String:Any] = ["path":urlAsset.url.path, "storedImage":thumbImage]
                                self?.feedModel = (self?.feedModel.getVideoObj(dict: dict))!
                                var destinationPath = URL(fileURLWithPath: NSTemporaryDirectory())
                                destinationPath = destinationPath.appendingPathComponent(String(format:"%@compressed.mp4", Shared.instance.getIdentifierForMessage()))
                                let screenSize = self!.view.frame
                                let screenWidth = screenSize.width
                                let screenHeight = screenSize.height
                                var size:CGSize = (self?.resolutionForLocalVideo(url: URL(fileURLWithPath: (self?.feedModel.videoUrl)!)))!
                                
                                //                                SharedManager.shared.showOnWindow()
                                if size.height > size.width {
                                    size = CGSize(width: screenWidth + 80, height: screenHeight + 80)
                                }else {
                                    size = CGSize(width: screenHeight + 80, height: screenWidth + 80)
                                }
                                Loader.startLoading()
                                
                                
                                var newObj = PostCollectionViewObject.init()
                                newObj.isType = PostDataType.Video
                                newObj.assetMain = indexObj
                                do {
                                    let options: PHVideoRequestOptions = PHVideoRequestOptions()
                                    options.version = .original
                                    PHImageManager.default().requestAVAsset(forVideo: indexObj.phAsset!, options: options, resultHandler: {(asset, audioMix, info) in
                                        if let urlAsset = asset as? AVURLAsset {
                                            self?.feedModel.videoUrl = urlAsset.url.absoluteString
                                            self!.getNewCompressURL(urlAsset.url)
                                            newObj.imageMain = thumbImage.compress(to: 100)
                                        }
                                    })
                                }

                            }
                        }
                    })
                }
            } else if indexObj.type == .photo {
                
                ChatManager.shared.getUrlFromPHAsset(asset: indexObj.phAsset!) {[weak self] (urlString) in
                    if urlString != nil{
                        let image =  SharedManager.shared.getImageFromAsset(asset: indexObj.phAsset!)!
                        let fileName = SharedManager.shared.getIdentifierForMessage()
                        let fileNameExt = fileName + ".jpg"
                        FileBasedManager.shared.saveFileTemporarily(fileObj: (image as! UIImage), name:fileNameExt)
                        self?.feedModel.videoUrl = FileBasedManager.shared.getSavedImagePath(name: fileNameExt) ?? ""
                        self?.feedModel.langModel = LanguageModel.init(name: "English", id: "1")
                        self?.feedModel.postType = "image"
                        
                        let parameters : [String : String] = ["action": "stories/create",
                                          "token": SharedManager.shared.userToken(),
                                          "file" : self!.feedModel.videoUrl,
                                          "post_type" : "image"]
                        self!.uploadStoryService(parameters: parameters)
                        self?.feedModel.status = "CreatingStory"
                    }
                }
            }
        }
    }
    
    func getNewCompressURL(_ url: URL){
        CompressManager.shared.compressingVideoURLNEw(url: url) { compressedUrl in
            if compressedUrl == nil {
                self.feedModel.postType = "video"
                self.feedModel.langModel = LanguageModel.init(name: "English", id: "1")
                DispatchQueue.main.async {
                    Loader.stopLoading()
                    let parameters = ["action": "stories/create",
                                      "token": SharedManager.shared.userToken(),
                                      "file" : self.feedModel.videoUrl,
                                      "thumbnail" : self.feedModel.videoThumbnail,
                                      "post_type" : "video"]
                    self.uploadStoryService(parameters: parameters)
                }

            } else {
                self.feedModel.videoUrl = compressedUrl!.absoluteString
                DispatchQueue.main.async {
                    
                    self.feedModel.postType = "video"
                    self.feedModel.langModel = LanguageModel.init(name: "English", id: "1")
                    
                    DispatchQueue.main.async {
                        Loader.stopLoading()
                        let parameters = ["action": "stories/create",
                                          "token": SharedManager.shared.userToken(),
                                          "file" : self.feedModel.videoUrl,
                                          "thumbnail" : self.feedModel.videoThumbnail,
                                          "post_type" : "video"]
                        self.uploadStoryService(parameters: parameters)
                    }
                }
            }
        }
    }
    
    func uploadStoryService(parameters: [String: String], isFileExist:Bool = true) {
        
        
        if parameters["post_type"] == "image" {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                Loader.startLoading()
            }
            
            let dataObj : PostDataType = .Image
            self.getS3URL(forMedia: [dataObj], parameters: parameters)
        }else if parameters["post_type"] == "video" {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                Loader.startLoading()
            }
            
            let dataObj : PostDataType = .Video
            self.getS3URL(forMedia: [dataObj], parameters: parameters)
            
        }

    }
    
    
    func createStoryPost(parameters : [String : Any] ) {
        CreateRequestManager.fetchDataPost(Completion:{ (response) in
            Loader.stopLoading()
            switch response {
            case .failure(let error):
                SwiftMessages.apiServiceError(error: error)
            case .success(let respDict):
                Loader.stopLoading()
                if let resDict = respDict as? [[String : Any]] {
                    SharedManager.shared.createStory = FeedVideoModel.init(dict: resDict[0])
                    SharedManager.shared.isfromStory = true
                    SwiftMessages.showMessagePopup(theme: .success, title: "Congratulations".localized(), body: "Story created successfully".localized())
                    let feedModel = FeedVideoModel(dict: resDict.first ?? [:])
                    if FeedCallBManager.shared.videoClipArray.firstIndex(where: {$0.postID == feedModel.postID}) == nil {
                        FeedCallBManager.shared.videoClipArray.insert(FeedVideoModel.init(dict: resDict[0]), at: 0)
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadTableWithNewdata"), object: nil,userInfo: nil)
                        self.navigationController?.popToViewController(ofClass: FeedViewCollectionController.self)
                    } else {
                        // move to first position
                    }
                }
            }
        }, param: parameters)

    }
    
    func getS3URL(forMedia : [PostDataType] , parameters: [String: String]){
        
        var paramNew = parameters
        var arrayFileName = [String]()
        var arrayMemiType = [String]()
        
        var newAssets = [PostCollectionViewObject]()
        
        let newElement = PostCollectionViewObject.init()
        
        for indexObj in forMedia {
            
            if indexObj == .Image   {
                
                let indexString = parameters["file"]
                arrayFileName.append(indexString!.components(separatedBy: "/").last ?? "")
                arrayMemiType.append("image/png")
                newElement.isType = .Image
                newElement.ImageName = indexString!.components(separatedBy: "/").last ?? ""
            }else if indexObj == .Video {
                newElement.isType = .Video
                let indexString = parameters["file"]
                let indexPath = indexString!.components(separatedBy: "/").last ?? ""
                arrayFileName.append(indexPath)
                arrayMemiType.append("video/mp4")

                var imageName = parameters["thumbnail"]
                let indexImagePath = imageName!.components(separatedBy: "/").last ?? ""
                newElement.ImageName = indexImagePath
                
                
                arrayFileName.append(indexImagePath)
                arrayMemiType.append("image/png")
                
            }
        }
        
        
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
        
        LogClass.debugLog("newFileParam ===>")
        LogClass.debugLog(newFileParam)
        RequestManagerGen.fetchUploadURLPost(Completion: { (response: Result<(uploadMediaModel), Error>) in
            switch response {
            case .failure(let error):
                Loader.stopLoading()
                if error is ErrorModel  {
                    let err = error as! ErrorModel
                }
                
            case .success(let res):
                for indexobj in res.data!{
                    for indexObjInner in forMedia {
                    
                        if indexObjInner == .Image   {
                            paramNew["S3ImagePath"] = indexobj.preSignedUrl ?? ""
                            paramNew["S3ImageURL"] = indexobj.fileUrl ?? ""
                            
                            newElement.S3ImageURL = indexobj.fileUrl ?? ""
                            newElement.S3ImagePath = indexobj.preSignedUrl ?? ""
                            
                        }else if indexObjInner == .Video {
                            
                            let indexString = parameters["file"]
                            let indexPath = indexString!.components(separatedBy: "/").last ?? ""
                            

                            if indexobj.fileName == indexPath {
                                paramNew["S3VideoPath"] = indexobj.preSignedUrl ?? ""
                                paramNew["S3VideoURL"] = indexobj.fileUrl ?? ""
                                
                                newElement.S3VideoURL = indexobj.fileUrl ?? ""
                                newElement.S3VideoPath = indexobj.preSignedUrl ?? ""
                                
                                newElement.videoURL = URL.init(string: self.feedModel.videoUrl)
                                
                            }else {
                                paramNew["S3ImagePath"] = indexobj.preSignedUrl ?? ""
                                paramNew["S3ImageURL"] = indexobj.fileUrl ?? ""
                                
                                newElement.S3ImageURL = indexobj.fileUrl ?? ""
                                newElement.S3ImagePath = indexobj.preSignedUrl ?? ""
                            }
                        }
                    }
                }
                
                
                newAssets.append(newElement)
                self.uploadMediaOnS3(parameters: paramNew,asset: newAssets)
                
                
    
            }
        }, param:newFileParam,dictURL: parametersUpload)
        
        
    }
    
    func uploadMediaOnS3(parameters: [String: String] , asset : [PostCollectionViewObject] ){
        
    


            asset[0].imageMain = FileBasedManager.shared.loadImage(pathMain: asset[0].ImageName)
            CreateRequestManager.uploadMultipartRequestOnS3(urlMain:parameters["S3ImagePath"]! , params: parameters ,fileObjectArray: asset,success: {
                (Response) -> Void in
                

                
                if parameters["post_type"] == "video" {
                    
                    asset[0].isThumbUploaded = true
                    CreateRequestManager.uploadMultipartRequestOnS3(urlMain:parameters["S3VideoPath"]! , params: parameters ,fileObjectArray: asset,success: {
                        (Response) -> Void in

                        
                        let newParameters : [String : Any] = ["action": "stories/create/v2",
                                                              "token": SharedManager.shared.userToken(),
                                                              "post_type" :parameters["post_type"]!,
                                                              "file_url" : parameters["S3VideoURL"]!,
                                                              "thumbnail_url" : parameters["S3ImageURL"]!
                        ]
                        self.createStoryPost(parameters: newParameters)
                        
                    },failure: {(error) -> Void in
                        Loader.stopLoading()
                    })
                    
                }else {
                    
                    let newParameters : [String : Any] = ["action": "stories/create/v2",
                                                          "token": SharedManager.shared.userToken(),
                                                          "post_type" :parameters["post_type"]!,
                                                          "file_url" : parameters["S3ImageURL"]!,
                                                          "thumbnail_url" : parameters["S3ImageURL"]!
                    ]
                    self.createStoryPost(parameters: newParameters)
                    
                }
                
            },failure: {(error) -> Void in
                Loader.stopLoading()
            })

    }
}

