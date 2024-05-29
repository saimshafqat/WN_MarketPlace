//
//  NewCommentCell.swift
//  WorldNoor
//
//  Created by apple on 8/16/21.
//  Copyright © 2021 Raza najam. All rights reserved.
//

import Foundation
import UIKit
import FTPopOverMenu
import TLPhotoPicker
import Photos

class NewCommentCell : UITableViewCell {
    
    @IBOutlet var txtViewComment : UITextView!
    
    @IBOutlet var viewAudio : UIView!
    @IBOutlet var viewcomment : UIView!
    
    var feedObj : FeedData!
    var indexPathMain : IndexPath!
    var likeDelegate : LikeCellDelegate!
    
    

    
    @IBAction func cameraAction(sender : UIButton){
        
        FTPopOverMenu.show(forSender: sender, withMenuArray: ["Take a picture".localized() , "Upload".localized()], imageArray: nil, configuration: SharedManager.shared.configWithMenuStyle()) { (selectedIndex) in
            
            if selectedIndex == 0 {

                self.openCamera()
            }else {
                self.openCamera()
            }
        } dismiss: {

        }
    }
    
    @IBAction func gifAction(sender : UIButton){
        
                self.gifSelect()
    }
    
    @IBAction func attachmentAction(sender : UIButton){
        self.didPressDocumentShare()
    }
    
   
    @IBAction func sendAction(sender : UIButton){
        self.endEditing(true)
        let myComment = self.txtViewComment.text.trimmingCharacters(in: .whitespaces)

        var comment : CommentFile?
        
        for indexObj in self.feedObj.comments! {
            if indexObj.commentID == 0 {
                comment = indexObj.commentFile?.first
                break
            }
        }
        
        if myComment.count > 0 {
            
            if comment != nil {
                
                if comment!.fileType == FeedType.file.rawValue {
                    self.uploadFile(filePath:comment!.url! , fileType: "attachment", langID: "1", identifier: "", bodyString: self.txtViewComment.text)
                }else if comment!.fileType == FeedType.image.rawValue {
                    self.uploadFile(filePath:comment!.url! , fileType: comment!.fileType!, langID: "1", identifier: "", bodyString: self.txtViewComment.text)
                }else if comment!.fileType == FeedType.video.rawValue {
                    self.uploadFile(filePath:comment!.url! , fileType: comment!.fileType!, langID: "1", identifier: "", bodyString: self.txtViewComment.text)
                }else if comment!.fileType == FeedType.gif.rawValue {
                    self.uploadFile(filePath:comment!.url! , fileType: "GIF", langID: "1", identifier: "", bodyString: self.txtViewComment.text)
                }
                
            }else {
                var parameters : [String : String] = ["action": "comment","token": SharedManager.shared.userToken(), "body": self.txtViewComment.text, "post_id":String(self.feedObj!.postID!), "identifier":SharedManager.shared.getIdentifierForMessage()]
                if SharedManager.shared.isGroup == 1 {
                    parameters["group_id"] = SharedManager.shared.groupObj?.groupID
                }else if SharedManager.shared.isGroup == 2 {
                    parameters["page_id"] = SharedManager.shared.groupObj?.groupID
                }
                self.txtViewComment.text = ""
                self.callingService(parameters: parameters, action: "comment")
                self.commentComit()
            }
            
          
            
        }else {
            if comment != nil {
                if comment!.fileType == FeedType.image.rawValue {
                    self.uploadFile(filePath:comment!.url! , fileType: comment!.fileType!, langID: "1", identifier: "", bodyString: self.txtViewComment.text)
                }else if comment!.fileType == FeedType.video.rawValue {
                    self.uploadFile(filePath:comment!.url! , fileType: comment!.fileType!, langID: "1", identifier: "", bodyString: self.txtViewComment.text)
                    
                }else if comment!.fileType == FeedType.gif.rawValue {
                    self.uploadFile(filePath:comment!.url! , fileType: "GIF", langID: "1", identifier: "", bodyString: self.txtViewComment.text)
                }else if comment!.fileType == FeedType.file.rawValue {
                    self.uploadFile(filePath:comment!.url! , fileType: "attachment", langID: "1", identifier: "", bodyString: self.txtViewComment.text)
                }
                
            }
        }
        
    }
    
    func commentComit(){
        var dicMeta = [String : Any]()
        dicMeta["post_id"] = String(feedObj.postID!)
        
        var dic = [String : Any]()
        dic["group_id"] = String(feedObj.postID!)
        dic["meta"] = dicMeta
        dic["type"] = "new_comment_NOTIFICATION"
        SocketSharedManager.sharedSocket.likeEvent(dict: dic as NSDictionary)
    }
    
    func callingService(parameters:[String:String], action:String)  {
        let fileUrl = ""
        let paramDict = parameters
//        if self.audioRecorderObj?.filename != "" {
//            fileUrl = (self.audioRecorderObj?.fileUrl().absoluteString)!
//            self.audioRecorderObj?.filename = ""
//            paramDict["recording_language_id"] =  self.selectedLangModel?.languageID
//            self.selectedLangModel = nil
//        }
        RequestManager.fetchDataMultipart(Completion: { response in
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            switch response {
            case .failure(let error):
                if error is String {
                    
                }
            case .success(let res):
                if (action == "comment") {
                    if res is String {
                        self.dataCheck(resData: res)
//                        self.commentServiceCallbackHandler?(res as! String)
                    }else {
                        self.dataCheck(resData: res)
//                        self.commentServiceCallbackHandler?(res as! NSDictionary)
                        SocketSharedManager.sharedSocket.emitSomeAction(dict: res as! NSDictionary)
                        NotificationCenter.default.post(name: Notification.Name(Const.KCommentUpdatedNotif), object: nil)
                    }
                }
            }
        }, param:paramDict, fileUrl: fileUrl)
    }
    
    func dataCheck(resData : Any){
         if resData is NSDictionary {
            var commentCount:Int = 0
            if self.feedObj.comments!.count > 0 {
                commentCount = (self.feedObj.comments?.count)! - 1
            }
            let respDict:NSDictionary = resData as! NSDictionary
            let dataDict:NSDictionary = respDict.value(forKey: "data") as! NSDictionary
            let commentObj:Comment = Comment(dict: dataDict)
            self.feedObj.comments![commentCount] = commentObj
            self.feedObj.isPostingNow = true
        }
        
        self.likeDelegate.actionPerformed(feedObj: self.feedObj, typeAction: .reloadTable)

    }
}


// MARK: - API Calling
extension NewCommentCell {
    func uploadFile(filePath:String, fileType:String, langID:String = "", identifier:String = "", bodyString:String = ""){
        var identifierP = ""
        if identifier.count == 0 {
            identifierP = SharedManager.shared.getIdentifierForMessage()
        }else {
            identifierP = identifier
        }
        var parameters = ["action": "comment",
                          "token": SharedManager.shared.userToken(),
                          "body": bodyString,
                          "post_id":String(self.feedObj.postID!),
                          "identifier":identifierP,
                          "fileType":fileType, "fileUrl":filePath]
        if langID != "" {
            if fileType == "audio" {
                parameters["recording_language_id"] = langID
                parameters["file_language_id"] = langID
                
            }else {
                parameters["file_language_id"] = langID
            }
        }
//        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        self.callingServiceToUpload(parameters: parameters, action: "comment")
        
        //// MARK: Socket Event For Comment
        var dicMeta = [String : Any]()
        dicMeta["post_id"] = String(feedObj.postID!)
        
        var dic = [String : Any]()
        dic["group_id"] = String(feedObj.postID!)
        dic["meta"] = dicMeta
        dic["type"] = "new_comment_NOTIFICATION"
        SocketSharedManager.sharedSocket.likeEvent(dict: dic as NSDictionary)
    }
    
    
    func callingServiceToUpload(parameters:[String:String], action:String)  {
        RequestManager.fetchDataMultipart(Completion: { response in
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            switch response {
            case .failure(let error):
                if error is String {
                    self.txtViewComment.text = ""
                }
            case .success(let res):
                self.txtViewComment.text = ""
                if (action == "comment") {
                    if res is String {

                    }else {
                        
                        
                        self.relaodComment(res: res)
                        SocketSharedManager.sharedSocket.emitSomeAction(dict: res as! NSDictionary)
                    }
                }
            }
        }, param:parameters, fileUrl: "")
    }
    
    
    func relaodComment(res : Any){
        if res is NSDictionary {
            let respDict:NSDictionary = res as! NSDictionary
            let dataDict:NSDictionary = respDict.value(forKey: "data") as! NSDictionary
            if dataDict.allKeys.count != 0 {
                let commentObj:Comment = Comment(dict: dataDict)

                self.feedObj.comments?.removeLast()
                self.feedObj.comments?.append(commentObj)
                self.likeDelegate.actionPerformed(feedObj: self.feedObj, typeAction: .reloadTable)

            }else {
                self.feedObj.comments?.removeLast()
                self.likeDelegate.actionPerformed(feedObj: self.feedObj, typeAction: .reloadTable)

            }
        }
        

    }
}


extension NewCommentCell : TLPhotosPickerViewControllerDelegate{
    func openCamera(){
        let viewController = TLPhotosPickerViewController()
        viewController.configure.maxSelectedAssets = 1
        viewController.delegate = self
        
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
                        self?.addImageInComment(urlString: urlString!,phAsset: indexObj.phAsset!)
                    }
                }
            }else if indexObj.type == .livePhoto {
                ChatManager.shared.getUrlFromPHAsset(asset: indexObj.phAsset!) {[weak self] (urlString) in
                    if urlString != nil{
                        self?.addImageInComment(urlString: urlString!,phAsset: indexObj.phAsset!)
                    }
                }
            }else if indexObj.type == .video {
                do {
                    let options: PHVideoRequestOptions = PHVideoRequestOptions()
                    options.version = .original
                    PHImageManager.default().requestAVAsset(forVideo: indexObj.phAsset!, options: options, resultHandler: {[weak self] (asset, audioMix, info) in
                        if let urlAsset = asset as? AVURLAsset {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                FileBasedManager.shared.encodeVideo(videoURL: urlAsset.url as URL) { (newUrl) in
                                    DispatchQueue.main.async {
                                        if newUrl != nil {
                                            self?.addVideoInComment(urlString: newUrl!, phAsset: indexObj.phAsset!)
                                        }
                                    }
                                }
                            }
                        }
                    })
                }
            }
        }
    }
    

    
    func addImageInComment(urlString : URL , phAsset : PHAsset){
        
        
        for indexObj in 0..<self.feedObj.comments!.count {
            if self.feedObj.comments![indexObj].commentID == 0 {
                self.feedObj.comments?.remove(at: indexObj)
            }
        }
        
        let commentfileObj = CommentFile.init(dict: NSDictionary.init())
        commentfileObj.url = urlString.path
        commentfileObj.fileType = FeedType.image.rawValue
        commentfileObj.assetObj = phAsset
        ChatManager.shared.getUrlFromPHAsset(asset: phAsset, completion: { (urlImage) in
            
            commentfileObj.url = urlImage?.path
            let commentObj = Comment.init(dict:NSDictionary.init())
            commentObj.commentFile = [commentfileObj]
            commentObj.commentID = 0
//            self.feedObj.comments?.insert(commentObj, at: 0)
            
            self.feedObj.comments?.append(commentObj)
            self.likeDelegate.actionPerformed(feedObj: self.feedObj, typeAction: ActionType.reloadTable)


        })
    }
    
    func addVideoInComment(urlString : URL , phAsset : PHAsset){
        
        
        for indexObj in 0..<self.feedObj.comments!.count {
            if self.feedObj.comments![indexObj].commentID == 0 {
                self.feedObj.comments?.remove(at: indexObj)
            }
        }
        
        let commentfileObj = CommentFile.init(dict: NSDictionary.init())
        commentfileObj.url = urlString.path
        commentfileObj.fileType = FeedType.video.rawValue
        commentfileObj.assetObj = phAsset
            let commentObj = Comment.init(dict:NSDictionary.init())
            commentObj.commentFile = [commentfileObj]
            commentObj.commentID = 0
//        self.feedObj.comments?.insert(commentObj, at: 0)
        self.feedObj.comments?.append(commentObj)
        self.likeDelegate.actionPerformed(feedObj: self.feedObj, typeAction: ActionType.reloadTable)
        

    }
 
}



//MARK: Gif Action

extension NewCommentCell {
    func gifSelect(){
        let gifObj = AppStoryboard.TabBar.instance.instantiateViewController(withIdentifier: "GifListController") as! GifListController
        gifObj.delegate = self
        gifObj.isMultiple = false
        gifObj.indexPath = indexPathMain
//        gifObj.modalPresentationStyle = .fullScreen
        UIApplication.topViewController()!.present(gifObj, animated: true, completion: nil)
    }
}


extension NewCommentCell:GifImageSelectionDelegate  {
    func gifSelected(gifDict:[Int:GifModel], currentIndex: IndexPath) {
        if gifDict.count > 0 {
            for (_, gifObj) in gifDict {
                
                for indexObj in 0..<self.feedObj.comments!.count {
                    if self.feedObj.comments![indexObj].commentID == 0 {
                        self.feedObj.comments!.remove(at: indexObj)
                        break
                    }
                }
                
                let commentfileObj = CommentFile.init(dict: NSDictionary.init())
                commentfileObj.url = gifObj.url
                commentfileObj.fileType = FeedType.gif.rawValue
                    let commentObj = Comment.init(dict:NSDictionary.init())
                    commentObj.commentFile = [commentfileObj]
                    commentObj.commentID = 0
                    self.feedObj.comments?.append(commentObj)
                self.likeDelegate.actionPerformed(feedObj: self.feedObj, typeAction: ActionType.reloadTable)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    
                    self.likeDelegate.actionPerformed(feedObj: self.feedObj, typeAction: ActionType.reloadTable)
                }
                    
            }
        }
    }
}

//MARK: Audio
extension NewCommentCell {
    //record & pause btn
    @IBAction func audioAction(sender : UIButton){
        
     
        
        FTPopOverMenu.show(forSender: sender, withMenuArray: ["Record".localized() , "Upload".localized()], imageArray: nil, configuration: SharedManager.shared.configWithMenuStyle()) { (selectedIndex) in


            if selectedIndex == 0 {
                self.audioRecord()
            }else {

                self.likeDelegate.actionPerformed(feedObj: self.feedObj, typeAction: ActionType.audioUploadAction)
            }
        } dismiss: {
            
        }

    }
    
    func audioRecord(){
        
        let audioObj = AppStoryboard.Kids.instance.instantiateViewController(withIdentifier: "AudioRecordVC") as! AudioRecordVC
        UIApplication.topViewController()!.present(audioObj, animated: true, completion: nil)
    }
    
}

//MARK: Document Share


extension NewCommentCell: UIDocumentPickerDelegate {
    func didPressDocumentShare() {
//        self.viewLanguageModel.feedArray = self.viewModel.feedArray
        let types = ["public.item"]
        let documentPicker = UIDocumentPickerViewController(documentTypes: types as [String], in: .import)
        documentPicker.delegate = self
        if #available(iOS 11.0, *) {
            documentPicker.allowsMultipleSelection = false
        } else {
            // Fallback on earlier versions
        }
        documentPicker.modalPresentationStyle = .formSheet
        if #available(iOS 13, *) {
            documentPicker.overrideUserInterfaceStyle = .dark
            documentPicker.shouldShowFileExtensions = true
        }
        UIApplication.topViewController()!.present(documentPicker, animated: true, completion: nil)

    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else {return}
        
        for indexObj in 0..<self.feedObj.comments!.count {
            if self.feedObj.comments![indexObj].commentID == 0 {
                self.feedObj.comments!.remove(at: indexObj)
                break
            }
        }
        
        let commentfileObj = CommentFile.init(dict: NSDictionary.init())
        commentfileObj.url = url.path
        commentfileObj.fileType = FeedType.file.rawValue
            let commentObj = Comment.init(dict:NSDictionary.init())
            commentObj.commentFile = [commentfileObj]
            commentObj.commentID = 0
            self.feedObj.comments?.append(commentObj)
        self.likeDelegate.actionPerformed(feedObj: self.feedObj, typeAction: ActionType.reloadTable)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            
            self.likeDelegate.actionPerformed(feedObj: self.feedObj, typeAction: ActionType.reloadTable)
        }
        
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        UIApplication.topViewController()!.dismiss(animated: true) {
            
        }
    }
    
    func downloadAttachment(commentFile:CommentFile){
//        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // your code here
            do {
                let imageData = try Data(contentsOf: URL.init(string: commentFile.orignalUrl!)!)
                let activityViewController = UIActivityViewController(activityItems: [ imageData], applicationActivities: nil)
                activityViewController.excludedActivityTypes = SharedManager.shared.excludingArray
                UIApplication.topViewController()!.present(activityViewController, animated: true) {
//                    SharedManager.shared.hideLoadingHubFromKeyWindow()
                    Loader.stopLoading()
                }
            } catch {

            }
        }
    }
}

