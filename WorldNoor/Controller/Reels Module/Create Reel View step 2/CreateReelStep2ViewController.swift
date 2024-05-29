//
//  CreateReelStep2ViewController.swift
//  WorldNoor
//
//  Created by Omnia Samy on 06/11/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit
import CommonKeyboard

class CreateReelStep2ViewController: UIViewController {
    
    @IBOutlet private weak var descriptionTextView: UITextView!
    @IBOutlet private weak var lblPrivacy: UILabel!
    @IBOutlet private weak var imgviewPrivacy: UIImageView!
    var feedVideoModel = PostCollectionViewObject.init()
    
    let vcPrivacy = ReelsPrivacyVC.instantiate(fromAppStoryboard: .Shared)
    var privacyOption = "public"
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.title = "Create Reel".localized()
        setUpScreenDesign()
        self.imgviewPrivacy.image = UIImage.init(named: "Privacy_Public")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        CommonKeyboard.shared.enabled = true
        
        if UserDefaults.standard.value(forKey: "memory") != nil {
            let valuemain = UserDefaults.standard.value(forKey: "memory")
            self.chooseOption(privacyOption: valuemain as! String)
        }
    }
}

extension CreateReelStep2ViewController {
    
    @IBAction func publishReelTapped(_ sender: Any) {
        self.view.endEditing(true)
        if descriptionTextView.textColor == UIColor.black {
            
            let description = descriptionTextView.text.trimmingCharacters(in: .whitespaces)
            if description.isEmpty {
                SwiftMessages.showMessagePopup(theme: .success, title: "Alert", body: "Please add description".localized())
            } else {
                Loader.startLoading()
                getS3URL()

            }
        } else {
            SwiftMessages.showMessagePopup(theme: .success, title: "Alert", body: "Please add description".localized())
        }
    }
    

    
    func getS3URL(){
        
        
        var arrayFileName = [String]()
        var arrayMemiType = [String]()
        
      
        let indexString = feedVideoModel.videoURL.absoluteString
                let indexPath = indexString.components(separatedBy: "/").last ?? ""
                arrayFileName.append(indexPath)
                arrayMemiType.append("video/mp4")
                let imageNameArray = indexPath.components(separatedBy: ".")
            self.feedVideoModel.videoName = indexPath
                
                var imageName = ""
                
                
                for indexObj in 0..<(imageNameArray.count - 1) {
                    imageName = imageName + imageNameArray[indexObj]
                }
                imageName = imageName + ".png"
                arrayFileName.append(imageName)
                arrayMemiType.append("image/png")
        self.feedVideoModel.ImageName = imageName
        
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

                    if indexobj.fileName == self.feedVideoModel.videoName {
                        self.feedVideoModel.S3VideoURL = indexobj.fileUrl ?? ""
                        self.feedVideoModel.S3VideoPath = indexobj.preSignedUrl ?? ""

                    }else if indexobj.fileName == self.feedVideoModel.ImageName {
                        self.feedVideoModel.S3ImageURL = indexobj.fileUrl ?? ""
                        self.feedVideoModel.S3ImagePath = indexobj.preSignedUrl ?? ""
                        
                    }
                }
                self.uploadMediaOnS3()
            }
        }, param:newFileParam,dictURL: parametersUpload)
        
        
    }
    
    
    
    
    func uploadMediaOnS3(){
        
        
        let userToken:String = SharedManager.shared.userObj!.data.token!
        let parameters = ["api_token": userToken]
        
        self.uploadThumbImage(params: parameters)
    }
    
    
    func uploadThumbImage(params : [String:String]){
        CreateRequestManager.uploadMultipartRequestOnS3(urlMain:feedVideoModel.S3ImagePath , params: params ,fileObjectArray: [feedVideoModel],success: {
            (Response) -> Void in

            self.feedVideoModel.isThumbUploaded = true
            self.uploadVideo(params: params)

        },failure: {(error) -> Void in
            Loader.stopLoading()
        })
    }
    
    
    func uploadVideo(params : [String:String]){
        CreateRequestManager.uploadMultipartRequestOnS3(urlMain:feedVideoModel.S3VideoPath , params: params ,fileObjectArray: [feedVideoModel],success: {
            (Response) -> Void in
            self.feedVideoModel.isUploaded = true
            self.managePostCreateService()

        },failure: {(error) -> Void in
            Loader.stopLoading()
        })
    }
        
    func managePostCreateService()  {

        var dataArray = [[String : AnyObject]]()
        
        
      
                var dataObj = [String : AnyObject]()
                dataObj["faster_upload"] = "0" as AnyObject
                dataObj["thumbnail"] = feedVideoModel.S3ImageURL as AnyObject
                dataObj["language_id"] = "1" as AnyObject
                dataObj["url"] = feedVideoModel.S3VideoURL as AnyObject
                dataObj["type"] = feedVideoModel.isType.rawValue as AnyObject
                
                dataArray.append(dataObj)
            
        
        
        let userToken:String = SharedManager.shared.userObj!.data.token!
        let createPostObj = PostCollectionViewObject.init()
       
        
        var parameters = ["action": "post/reel-create","token": userToken,"body":self.descriptionTextView.text!, "privacy_option": self.privacyOption]
        parameters["post_type_id"] = "1"
        parameters[String(format: "file_urls[0]")] = feedVideoModel.S3VideoURL
        parameters[String(format: "files_info[0][thumbnail_url]")] = feedVideoModel.S3ImageURL
        parameters[String(format: "files_info[0][language_id]")] = feedVideoModel.langID
         
        LogClass.debugLog("parameters   =========>")
        LogClass.debugLog(parameters)
        CreateRequestManager.fetchDataPost(Completion:{ (response) in
           
            switch response {
            case .failure(let error):
                Loader.stopLoading()
                SwiftMessages.apiServiceError(error: error)
            case .success(let respDict):
                LogClass.debugLog("respDict  ==>")
                LogClass.debugLog(respDict)
                var postObj:[PostCollectionViewObject] = [PostCollectionViewObject]()
                
                var newObj = [String : Any]()
                newObj["faster_upload"] = 0
                newObj["language_id"] = 0
                newObj["url"] = self.feedVideoModel.S3VideoURL
                
                var newThumbObj = [String : Any]()
                newThumbObj["url"] = self.feedVideoModel.S3ImageURL
                newThumbObj["faster_upload"] = 0
                
                newObj["thumbnail"] = newThumbObj
                postObj = self.getPostData(respArray: NSArray.init(object: newObj))
                
                
                
                
                if let mainDict = respDict as? [String : Any] {
                    self.saveReelAtFirstIndex(reelID: mainDict["post_id"] as! Int)
                    self.manageProcessFileService(postObj: postObj)
                }else {
                    Loader.stopLoading()
                }
                
                  
                
            }
        }, param: parameters)

    }
    func saveReelAtFirstIndex(reelID : Int){
       
        let feedDataInstance = FeedData(valueDict: [:]) 
        var posts = [PostFile]()

        let post = PostFile()
        post.thumbnail = feedVideoModel.S3ImageURL
        post.filePath = feedVideoModel.S3VideoURL
        feedDataInstance.body = self.descriptionTextView.text
        feedDataInstance.authorName = (SharedManager.shared.userObj?.data.firstname)! + " " + (SharedManager.shared.userObj?.data.lastname)!
        feedDataInstance.profileImage = SharedManager.shared.userObj?.data.profile_image
        posts.append(post)

        // Assuming feedDataInstance.post is also an array of PostFile
        feedDataInstance.post = posts
        feedDataInstance.authorID = SharedManager.shared.getUserID()
        feedDataInstance.postID = reelID
                SharedManager.shared.createReel = feedDataInstance
                SharedManager.shared.isfromReel = true
                FeedCallBManager.shared.watchArray.insert(feedDataInstance, at: 0)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadTableWithNewdata"), object: nil,userInfo: nil)
                
                self.navigationController?.popToRootViewController(animated: true)
            }
    func manageProcessFileService(postObj: [PostCollectionViewObject])  {
        
        self.perform(#selector(dismissMyController), with: nil, afterDelay: 2)
        let userToken = SharedManager.shared.userObj!.data.token
        let parameters = ["action": "process-reel-file",
                          "api_token": userToken,
                          "serviceType": "Media",
                          "processVideoAsWell": "true"]
        
        CreateRequestManager.uploadMultipartProcessFileRequests(params: parameters as! [String : String],
                                                                fileObjectArray: postObj,
                                                                success: { (JSONResponse) -> Void in
        },failure: {(error) -> Void in
            LogClass.debugLog(error)
        })
    }
    
    @IBAction func showPrivacyOption() {
        self.view.endEditing(true)
        vcPrivacy.delegatePrivacy = self
        vcPrivacy.valueChoose = self.privacyOption
        self.view.addSubview(vcPrivacy.view)
    }
    
    @objc func dismissMyController()  {
        
        //        SharedManager.shared.hideLoadingHubFromKeyWindow()
        Loader.stopLoading()
        SharedManager.shared.removeProgressRing()
        
        self.showAlert(message: "Reel Created successfully".localized())
    }
    
    func getPostData(respArray: NSArray) -> [PostCollectionViewObject] {
        var postArray:[PostCollectionViewObject] = [PostCollectionViewObject]()
        for data in respArray {
            postArray.append(PostCollectionViewObject.init(dict: data as! NSDictionary))
        }
        return postArray
    }
}

extension CreateReelStep2ViewController : ReelPrivacyDelegate {
    func chooseOption(privacyOption : String) {
        
        self.lblPrivacy.text = privacyOption
        
        if privacyOption == "Public"{
            self.privacyOption = "public"
            self.imgviewPrivacy.image = UIImage.init(named: "Privacy_Public")
            
        }else if privacyOption == "Friends"{
            self.privacyOption = "friends"
            self.imgviewPrivacy.image = UIImage.init(named: "Privacy_Friends")
        }else {
            self.privacyOption = "only_me"
            self.imgviewPrivacy.image = UIImage.init(named: "Privacy_Only Me")
            
        }
        
    }
}

extension CreateReelStep2ViewController {
    
    private func setUpScreenDesign() {
        descriptionTextView.delegate = self
        descriptionTextView.text = "Describe your reel".localized()
        descriptionTextView.textColor = UIColor.lightGray
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: nil,
                                      message: message,
                                      preferredStyle: UIAlertController.Style.alert)
        
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: {_ in
            self.navigationController?.popToViewController(ofClass: FeedViewCollectionController.self) //FeedViewController.self) old feed
        })
        
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: {})
    }
}

extension CreateReelStep2ViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Describe your reel".localized()
            textView.textColor = UIColor.lightGray
        }
    }
}
