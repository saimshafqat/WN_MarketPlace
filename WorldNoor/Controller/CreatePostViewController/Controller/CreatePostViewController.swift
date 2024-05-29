//
//  CreatePostViewController.swift
//  WorldNoor
//
//  Created by Raza najam on 10/18/19.
//  Copyright © 2019 Raza najam. All rights reserved.
//

import UIKit
import Photos
import TLPhotoPicker
import AVFoundation
import AVKit
//import IQKeyboardManagerSwift
import CommonKeyboard
import MobileCoreServices
import MediaPlayer
import SwiftLinkPreview
import FittedSheets
import FTPopOverMenu

class CreatePostViewController: UIViewController, UIScrollViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    private let slp = SwiftLinkPreview(cache: InMemoryCache())
    var appearFrom:String = ""
    var isValidateView:Bool = false
    var notAudioBrowse:Bool = true
    var isLinkDetected:Bool = false
    var isPostEdit:Bool = false
    var keyboardHeight:CGFloat = 80.0
    var isSelected = -1
    let viewModel = CreatePostViewModel()
    let playerViewController = AVPlayerViewController()
    let keyboardObserver = CommonKeyboardObserver()
    var createPostDismissed : (([PostCollectionViewObject]) -> Void)?
    var selectedOption:Int = -1
    var screenShotImageView: UIImageView?
    var lanaguageModelArray: [LanguageModel] = [LanguageModel]()
    let dropDown = MakeDropDown()
    var dropDownRowHeight: CGFloat = 35
    var selectedLangModel:LanguageModel?
    fileprivate let viewLanguageModel = FeedLanguageViewModel()
    var musicPlayer:MPMediaPickerController?
    var feedObj: FeedData?
    var sheetController = SheetViewController()
    var selectedPrivacyString = "public"
    var selectedPrivacyIDs:[Int:String] = [:]
    var timerAPI = Timer.init()
    var apiResponseTimer: APIResponseTimer?
    var arrCreatePostType = CreatePostType.allCases

    var Arraytags = [[String : Any]]()
    
    var rangeText : NSRange!
    var s3index = -1
    var isCreateBtnTap : Bool = false
    @IBOutlet weak var tblViewTags: UITableView!
    @IBOutlet weak var viewTags: UIView!
    @IBOutlet weak var postCollectionView: UICollectionView!
    @IBOutlet weak var bottomCollectionView: UICollectionView!
    @IBOutlet weak var commentHeightConst: NSLayoutConstraint!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var userImageView: DesignableImageView!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var descriptionView: DesignableView!
    @IBOutlet weak var bottomBarView: UIView!
    @IBOutlet weak var bottomButtonView: UIView!
    @IBOutlet weak var viewImage: UIView!
    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var tblViewOptions: UITableView!
    @IBOutlet weak var lblPrivacyTitle: UILabel!
    @IBOutlet weak var crossBtn: UIButton!
    @IBOutlet weak var progressCustomView: UIView!
    @IBOutlet weak var dropDownBtn: DesignableButton!
    @IBOutlet weak var langDropDownView: UIView!
    @IBOutlet weak var btnSave: UIButton!
    
    
    //LINK DATA
    @IBOutlet weak var customPreviewView: DesignableView!
    @IBOutlet weak var customPreviewHeightConst: NSLayoutConstraint!
    private var result:Response?
    var linkGeneratorObj = LinkGenerator()
    var linkView: CreatePostLink?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tblViewTags.register(UINib.init(nibName: "CommandTableCell", bundle: nil),forCellReuseIdentifier: "CommandTableCell")
        tblViewOptions.delegate = self
        tblViewOptions.dataSource = self
        viewTags.isHidden = true
        self.bottomBarView.isHidden = true
        self.bottomButtonView.isHidden = false
        self.setUpDropDown()
        self.managePresentation()
        self.postCollectionView.dataSource = self
        self.postCollectionView.delegate = self
        if #available(iOS 11.0, *) {
            self.bottomCollectionView.dragInteractionEnabled = true
            self.bottomCollectionView.reorderingCadence = .fast
            self.bottomCollectionView.dropDelegate = viewModel
            self.bottomCollectionView.dragDelegate = viewModel
        }
        self.manageTextView()
        (self.postCollectionView?.collectionViewLayout as? UICollectionViewFlowLayout)?.estimatedItemSize = CGSize(width: 1, height: 1)
        self.userNameLbl.text = SharedManager.shared.getFullName()
        let fileName = "myImageToUpload.jpg"
        self.userImageView.image = FileBasedManager.shared.loadImage(pathMain: fileName)
        self.btnSave.roundButton(cornerRadius: 4)
        self.view.labelRotateCell(viewMain: self.userImageView)
        self.manageKeyboard()
        self.manageViewModelHandler()
        
        self.navigationController?.isNavigationBarHidden = true
        
        self.lblPrivacyTitle.text = SharedManager.shared.PrivacyObj.FuturePostValue.capitalizingFirstLetter()
        
        self.selectedPrivacyString = SharedManager.shared.PrivacyObj.FuturePostValue
        
        if self.selectedPrivacyString == "contacts" {
            self.selectedPrivacyString  = "friends"
        }
        
        self.manageEditPost()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if  SharedManager.shared.createPostSelection == 200 {
            if self.viewModel.selectedAssets.count == 0 && self.notAudioBrowse {

            }
        }
        postCollectionView.collectionViewLayout.invalidateLayout()
        bottomCollectionView.collectionViewLayout.invalidateLayout()
        self.isValidateView = true
        
        self.linkView = Bundle.main.loadNibNamed("CreatePostLink", owner: self, options: nil)?.first as? CreatePostLink
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        SharedManager.shared.createPostSelection = 200
        self.manageHandler()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if(self.isValidateView){
            self.isValidateView = false
            postCollectionView.collectionViewLayout.invalidateLayout()
            bottomCollectionView.collectionViewLayout.invalidateLayout()
        }
    }
    
    @IBAction func managePrivacyOption(){
        self.commentTextView.resignFirstResponder()
        let langController = AppStoryboard.PostStoryboard.instance.instantiateViewController(withIdentifier: "PrivacyOptionController") as! PrivacyOptionController
        langController.delegate = self
        langController.isEditPost = self.isPostEdit
        langController.selectedPrivacyName = self.selectedPrivacyString
        langController.editContactID = self.selectedPrivacyIDs
//        self.sheetController = SheetViewController(controller: langController, sizes: [.fixed(600)])
//        self.sheetController.overlayColor = UIColor.black.withAlphaComponent(0.3)
//        self.sheetController.extendBackgroundBehindHandle = true
//        self.sheetController.topCornersRadius = 20
        self.navigationController?.pushViewController(langController, animated: true)
//        self.present(self.sheetController, animated: false, completion: nil)
    }
    
    func manageEditPost() {
        
        if self.isPostEdit {
            let textBody = self.feedObj?.body
            if textBody!.count > 0 {
                self.commentTextView.text = self.feedObj?.body
                self.commentTextView.textColor = UIColor.black
                self.commentTextView.layoutIfNeeded()
                
                
                let frame = SharedManager.shared.getTextViewSize(textView: self.commentTextView)
                let actualSize = ((self.view.frame.size.height) - self.keyboardHeight)
                if frame.size.height < actualSize   {
                    if frame.size.height < 150 {
                        self.commentTextView.isScrollEnabled = false
                        self.commentHeightConst.constant = frame.size.height
                    } else {
                        self.commentTextView.isScrollEnabled = true
                        self.commentHeightConst.constant = 200
                    }
                }else {
                    self.commentHeightConst.constant = actualSize
                    self.commentTextView.isScrollEnabled = true
                }
            }
            let createPostObj = PostCollectionViewObject.init()
            self.viewModel.selectedAssets = createPostObj.manageEditPost(feedObj: self.feedObj!)
            self.postCollectionView.reloadData()
            self.bottomCollectionView.reloadData()
            
            self.selectedPrivacyString = self.feedObj!.privacyType ?? "public"
            if self.feedObj!.privacyType == "contact_groups" {
                CreatePostHandler.shared.manageVideoProcessingResponse(id:(self.feedObj?.postID)!)
                self.lblPrivacyTitle.text = "Contact Groups".localized()
                CreatePostHandler.shared.singleFeedHandler = { [weak self] (contactGroupIDs) in
                    self!.selectedPrivacyIDs = contactGroupIDs
                }
            } else if self.feedObj!.privacyType == "only_me" {
                self.lblPrivacyTitle.text = "Only Me".localized()
            } else if self.feedObj!.privacyType == "friends" {
                self.lblPrivacyTitle.text = "Contacts".localized()
            } else {
                self.lblPrivacyTitle.text = "Public".localized()
            }
        }
    }
    
    func openMusicAlbum() {
        self.musicPlayer = MPMediaPickerController(mediaTypes: .anyAudio)
        musicPlayer!.delegate = self
        musicPlayer!.allowsPickingMultipleItems = false
        self.present(musicPlayer!, animated: true, completion: nil)
    }
    
    func manageHandler() {
        CreatePostHandler.shared.videoLangChangeHandler = { [weak self] (currentIndex, langID) in
            let createPostObj:PostCollectionViewObject =  (self?.viewModel.selectedAssets[currentIndex.row])!
            createPostObj.langID = langID
            self?.viewModel.selectedAssets[currentIndex.row] = createPostObj
        }
    }
    
    func managePresentation() {
        let someBtn = UIButton()
        someBtn.tag = 101
        
        switch SharedManager.shared.createPostSelection {
        case 0:
            self.manageScreenshot()
            self.ImageUploadAction(sender: someBtn)
        case 1:
            self.manageScreenshot()
            someBtn.tag = 100
            self.ImageUploadAction(sender: someBtn)
        case 2:
            self.manageScreenshot()
            self.commentTextView.becomeFirstResponder()
        case 3:
            self.manageScreenshot()
            self.audioRecordOpen(sender: UIButton())
        case 4:
            self.manageScreenshot()
            someBtn.tag = 200
            self.cameraButtonClicked(someBtn)
        case 6:
            someBtn.tag = 201
            self.manageScreenshot()
            self.cameraButtonClicked(someBtn)
        case 8:
            self.showGifController()
        case 9:
            self.manageScreenshot()
            self.openMusicAlbum()
            
        case 10:
            self.manageScreenshot()
            self.didPressDocumentShare()
        default:
            LogClass.debugLog("presenting normal behaviour.")
        }
    }
    
    func showGifController(){
        let gifObj = AppStoryboard.TabBar.instance.instantiateViewController(withIdentifier: "GifListController") as! GifListController
        gifObj.delegate = self
        gifObj.modalPresentationStyle = .fullScreen
        self.present(gifObj, animated: true, completion: nil)
    }
    
    func manageScreenshot(){
        if let screenShot = SharedManager.shared.createPostScreenShot {
            view.addSubview(screenShot)
            delay(0.4, closure: {
                screenShot.removeFromSuperview()
            })
        }
    }
    
    private func delay(_ delay:Double, closure:@escaping ()->()) {
        let when = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
    }
    
    func manageViewModelHandler(){
        self.viewModel.reloadCreateCollection = { [weak self] in
            self?.postCollectionView.reloadData()
        }
    }
    
    func addCustomProgressView(){
        self.progressCustomView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        self.progressCustomView.tag = -9876
        self.view.addSubview(self.progressCustomView)
    }
    
    func manageKeyboard(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),name: UIResponder.keyboardWillShowNotification,object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            self.keyboardHeight = keyboardRectangle.height + 150
        }
    }

    
    @IBAction func videoAction(sender : UIButton){
        self.commentTextView.resignFirstResponder()
        FTPopOverMenu.show(forSender: sender, withMenuArray: ["Record".localized() , "Upload".localized()], imageArray: nil, configuration: SharedManager.shared.configWithMenuStyle()) { (selectedIndex) in
            let someBtn = UIButton()
            if selectedIndex == 1 {
                someBtn.tag = 100
                self.ImageUploadAction(sender: someBtn)
            }else {
                someBtn.tag = 201
                self.cameraButtonClicked(someBtn)
            }
        } dismiss: {
        }
    }
    
    @IBAction func fileChoose(sender : UIButton){
        self.commentTextView.resignFirstResponder()
        self.didPressDocumentShare()
    }
    
    @IBAction func audioAction(sender : UIButton){
        self.commentTextView.resignFirstResponder()
        FTPopOverMenu.show(forSender: sender, withMenuArray: ["Record".localized() , "Upload".localized()], imageArray: nil, configuration: SharedManager.shared.configWithMenuStyle()) { (selectedIndex) in
            
            let someBtn = UIButton()
            if selectedIndex == 1 {
                self.openMusicAlbum()
            }else {
                someBtn.tag = 201
                self.audioRecordOpen(sender: someBtn)
            }
        } dismiss: {
        }
    }
    
    @IBAction func galleryBtnClicked(sender: UIButton) {
        self.commentTextView.resignFirstResponder()
        FTPopOverMenu.show(forSender: sender, withMenuArray: ["Take a picture".localized() , "Upload".localized()], imageArray: nil, configuration: SharedManager.shared.configWithMenuStyle()) { (selectedIndex) in
            let someBtn = UIButton()
            if selectedIndex == 1 {
                self.ImageUploadAction(sender: someBtn)
            }else {
                someBtn.tag = 200
                self.cameraButtonClicked(someBtn)
            }
        } dismiss: {
        }
    }
    
    @IBAction func ImageUploadAction(sender : UIButton){
        self.commentTextView.resignFirstResponder()
        let viewController = TLPhotosPickerViewController()
        viewController.modalPresentationStyle = .fullScreen
        viewController.configure.allowedVideo = true
        viewController.configure.allowedLivePhotos = false

        viewController.delegate = self
        if sender.tag == 100  {
            viewController.configure.mediaType = .video
            viewController.configure.allowedVideo = true
        }
        var arrayAsset = [TLPHAsset]()
        for indexObj in self.viewModel.selectedAssets {
            if indexObj.isType == PostDataType.Image && indexObj.assetMain != nil {
                arrayAsset.append(indexObj.assetMain)
            }
        }
        viewController.selectedAssets = arrayAsset
        self.present(viewController, animated: true) {
        }
    }
    
    @IBAction func ImageTakeAction(sender : UIButton){
        self.commentTextView.resignFirstResponder()
        self.cameraButtonClicked(sender)
    }
    
    @IBAction func audioMusicButtonClicked(_ sender: Any) {
        self.commentTextView.resignFirstResponder()
        self.openMusicAlbum()
    }
    
    @IBAction func gifBtnClicked(sender: UIButton) {
        self.commentTextView.resignFirstResponder()
        self.showGifController()
    }
    
    @IBAction func cameraButtonClicked(_ sender: Any) {
        self.commentTextView.resignFirstResponder()
        var someMediaTypes: [String] = [(kUTTypeImage as String), (kUTTypeMovie as String)]
        if SharedManager.shared.createPostSelection == 4 {
            someMediaTypes = [(kUTTypeImage as String)]
        } else if SharedManager.shared.createPostSelection == 6 {
            someMediaTypes = [(kUTTypeMovie as String)]
        }
        VideoHelper.startMediaBrowser(delegate: self, sourceType: .camera, someMedia: someMediaTypes)
    }
    
    func manageTextView(){
        self.commentTextView.textColor = UIColor.customgreyColor
        self.commentTextView.text = Const.textCreatePlaceholder.localized()
    }
    
    @IBAction func crossButtonTapped(_ sender: Any) {
        self.commentTextView.resignFirstResponder()
        self.topBarView.isHidden=false
        self.bottomBarView.isHidden=false
        self.bottomButtonView.isHidden = true
        self.bottomCollectionView.isHidden=false
        self.descriptionView.isHidden=false
        self.crossBtn.isHidden=true
    }
    
    @IBAction func createPostBtnClicked(_ sender: Any) {
        self.commentTextView.resignFirstResponder()
        if self.isLinkDetected {
            if self.result == nil  {
                return
            }
        }
        self.isCreateBtnTap = true
        self.commentTextView.resignFirstResponder()
        self.callingCreatePostService()
    }
    
    func manageAlreadyUploadedContent() {
        self.viewModel.newAssets = []
        self.viewModel.oldAssets = []
        for postObj in self.viewModel.selectedAssets {
            if postObj.isEditPost {
                self.viewModel.oldAssets.append(postObj)
            }else {
                self.viewModel.newAssets.append(postObj)
            }
        }
    }

    
    func callingCreatePostService() {
        self.manageAlreadyUploadedContent()
    
        let userToken = SharedManager.shared.userObj!.data.token
        if self.commentTextView.text == "Write what you wish.".localized()   {
            self.commentTextView.text = ""
            if self.viewModel.selectedAssets.count == 0 {
                SharedManager.shared.showAlert(message: "Please enter your message.".localized(), view: self)
                return
            }
        }
//        if (CreatePostHandler.shared.checkIfLanguageSelected(postArray: self.viewModel.selectedAssets)){
//            SharedManager.shared.showAlert(message: Const.languageSelectionAlert.localized(), view: self)
//            return
//        }
        
        
//      self.addCustomProgressView()
        Loader.startLoading()
        
        var strNew = commentTextView.text!.replacingOccurrences(of: " ", with: "")
        strNew = strNew.replacingOccurrences(of: "\n", with: "")
        
        if strNew.count == 0 && self.viewModel.selectedAssets.count == 0 {
             return
        }
        
        
        for indexObj in self.viewModel.selectedAssets {
            LogClass.debugLog("indexObj.isCompress ===>")
            LogClass.debugLog(indexObj.isCompress)
            LogClass.debugLog(indexObj.isCompress)
            if !indexObj.isCompress && indexObj.isType == PostDataType.Video {
               return
            }
        }
               
       

        var bodyPost = ""
        if strNew.count > 0 {
            bodyPost = commentTextView.text!
        }
        
        apiResponseTimer = APIResponseTimer(startTime: .now())
        var parameters = ["action": "post/create","api_token": userToken,"body":bodyPost, "multiple_uploads":"true","type":"create_post"]
        if SharedManager.shared.isGroup == 1 {
            parameters["group_id"] = SharedManager.shared.groupObj?.groupID
        }else if SharedManager.shared.isGroup == 2 {
            parameters["page_id"] = SharedManager.shared.groupObj?.groupID
        }
        if self.result != nil {
            parameters["link"] = self.result?.finalUrl?.absoluteString
            parameters["link_title"] = self.result?.title
            if self.linkView!.linkImageView.image!.size.width > 50 && self.linkView!.linkImageView.image!.size.height > 50 {
                parameters["link_image"] = self.result?.image
            } else {
                parameters["link_image"] = ""
            }
            parameters["link_meta"] = self.result?.description
        }
        if self.isPostEdit {
            parameters["post_id"] = String(self.feedObj!.postID!)
        }
        parameters["post_scope_id"] = "1"
        self.manageAlreadyUploadedContent()

        SharedManager.shared.createPostView = self.progressCustomView
        if(CreatePostHandler.shared.checkIfFileExist(postArray: self.viewModel.newAssets)) {
            self.getS3URL()
        } else {
            Loader.startLoading()
            self.managePostCreateService(resp: [], isFileExist: false)
        }
    }
    
 
    func getS3URL() {
        var arrayFileName = [String]()
        var arrayMemiType = [String]()
        
        for indexObj in self.viewModel.newAssets {

            if indexObj.isType == .Attachment   {
                
                
                let mimeType = indexObj.videoURL.mimeType()
                
                
                
                let indexString = indexObj.videoURL.absoluteString
                arrayFileName.append(indexString.components(separatedBy: "/").last ?? "")
                arrayMemiType.append(mimeType)
                indexObj.ImageName = indexString.components(separatedBy: "/").last ?? ""
                indexObj.videoName = ""
                
            }else if indexObj.isType == .Audio || indexObj.isType == .AudioMusic {
                let indexString = indexObj.videoURL.absoluteString
                arrayFileName.append(indexString.components(separatedBy: "/").last ?? "")
                arrayMemiType.append("audio/wav")
                indexObj.ImageName = indexString.components(separatedBy: "/").last ?? ""
                indexObj.videoName = ""
                
            }else if indexObj.isType == .Image   {
                let indexString = indexObj.photoUrl.absoluteString
//                let indexString = "a1"
                arrayFileName.append(indexString.components(separatedBy: "/").last ?? "")
                arrayMemiType.append("image/png")
                indexObj.ImageName = indexString.components(separatedBy: "/").last ?? ""
                indexObj.videoName = ""
            }else if indexObj.isType == .imageText {
                let indexString = indexObj.photoUrl.absoluteString
                arrayFileName.append(indexString.components(separatedBy: "/").last ?? "")
                arrayMemiType.append("image/png")
                indexObj.ImageName = indexString.components(separatedBy: "/").last ?? ""
                indexObj.videoName = ""
            }else if indexObj.isType == .Video {
                let indexString = indexObj.videoURL.absoluteString
                let indexPath = indexString.components(separatedBy: "/").last ?? ""
                arrayFileName.append(indexPath)
                arrayMemiType.append("video/mp4")
                let imageNameArray = indexPath.components(separatedBy: ".")
                
                var imageName = ""
                
                for indexObj in 0..<(imageNameArray.count - 1) {
                    imageName = imageName + imageNameArray[indexObj]
                }
                imageName = imageName + ".png"
                arrayFileName.append(imageName)
                arrayMemiType.append("image/png")
                
                indexObj.ImageName = imageName
                indexObj.videoName = indexPath
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
        
        RequestManagerGen.fetchUploadURLPost(Completion: { (response: Result<(uploadMediaModel), Error>) in
            switch response {
            case .failure(let error):
                Loader.stopLoading()
                if error is ErrorModel  {
                    let err = error as! ErrorModel
                }
            case .success(let res):

                for indexobj in res.data!{
                    
                    for indexInner in self.viewModel.newAssets {
                        if indexInner.isType == .Attachment {
                            if indexobj.fileName == indexInner.ImageName {
                                indexInner.S3ImageURL = indexobj.fileUrl ?? ""
                                indexInner.S3ImagePath = indexobj.preSignedUrl ?? ""
                            }
                        }else if indexInner.isType == .Video {
                            if indexobj.fileName == indexInner.videoName {
                                indexInner.S3VideoURL = indexobj.fileUrl ?? ""
                                indexInner.S3VideoPath = indexobj.preSignedUrl ?? ""
                            }else if indexobj.fileName == indexInner.ImageName {
                                indexInner.S3ImageURL = indexobj.fileUrl ?? ""
                                indexInner.S3ImagePath = indexobj.preSignedUrl ?? ""
                            }
                        }else if indexInner.isType == .Image || indexInner.isType == .imageText{
                            if indexobj.fileName == indexInner.ImageName {
                                indexInner.S3ImageURL = indexobj.fileUrl ?? ""
                                indexInner.S3ImagePath = indexobj.preSignedUrl ?? ""
                            }
                        }else if indexInner.isType == .Audio || indexInner.isType == .AudioMusic{
                            if indexobj.fileName == indexInner.ImageName {
                                indexInner.S3ImageURL = indexobj.fileUrl ?? ""
                                indexInner.S3ImagePath = indexobj.preSignedUrl ?? ""
                            }
                        }
                    }
                    
                }
                
                
             
                self.s3index = 0
                self.uploadMediaOnS3()
            }
        }, param:newFileParam,dictURL: parametersUpload)
        
        
    }
    
    
    func uploadMediaOnS3(){
        
        
        let userToken:String = SharedManager.shared.userObj!.data.token!
        let parameters = ["api_token": userToken]
        
       if self.s3index < self.viewModel.newAssets.count {
            if self.viewModel.newAssets[self.s3index].isType == PostDataType.Video
            {
                if self.viewModel.newAssets[self.s3index].isThumbUploaded {
                    self.uploadVideo(params: parameters)
                }else {
                    self.uploadThumbImage(params: parameters)
                }
                
            }else if self.viewModel.newAssets[self.s3index].isType == PostDataType.GIFBrowse
            {
                self.s3index = self.s3index + 1
                self.uploadMediaOnS3()
            }else if self.viewModel.newAssets[self.s3index].isType == PostDataType.Image || self.viewModel.newAssets[self.s3index].isType == PostDataType.imageText  {
                   
                self.uploadImage(params: parameters)
            }else if self.viewModel.newAssets[self.s3index].isType == PostDataType.Attachment{
                
                self.uploadImage(params: parameters)
            }else if self.viewModel.newAssets[self.s3index].isType == .Audio || self.viewModel.newAssets[self.s3index].isType == .AudioMusic {
              
                self.uploadAudio(params:parameters)
            }

        }else {
            
            var dataArray = [[String : AnyObject]]()
            
            
            for indexObj in self.viewModel.newAssets {
                
                if indexObj.isType == PostDataType.Image || indexObj.isType == PostDataType.imageText
                {
                    var dataObj = [String : AnyObject]()
                    dataObj["faster_upload"] = "0" as AnyObject
                    dataObj["thumbnail"] = "" as AnyObject
                    dataObj["url"] = indexObj.S3ImageURL as AnyObject
                    dataObj["type"] = indexObj.isType.rawValue as AnyObject
                    dataArray.append(dataObj)
                }else if indexObj.isType == PostDataType.Audio || indexObj.isType == PostDataType.AudioMusic
                {
                    var dataObj = [String : AnyObject]()
                    dataObj["faster_upload"] = "0" as AnyObject
                    dataObj["thumbnail"] = "" as AnyObject
                    dataObj["language_id"] = "1" as AnyObject
                    dataObj["url"] = indexObj.S3ImageURL as AnyObject
                    dataObj["type"] = indexObj.isType.rawValue as AnyObject
                    dataArray.append(dataObj)
                }else if indexObj.isType == PostDataType.Video
                {
                    var dataObj = [String : AnyObject]()
                    dataObj["faster_upload"] = "0" as AnyObject
                    dataObj["thumbnail"] = indexObj.S3ImageURL as AnyObject
                    dataObj["language_id"] = "1" as AnyObject
                    dataObj["url"] = indexObj.S3VideoURL as AnyObject
                    dataObj["type"] = indexObj.isType.rawValue as AnyObject
                    dataArray.append(dataObj)
                }else if indexObj.isType == PostDataType.Attachment
                {
                    var dataObj = [String : AnyObject]()
                    dataObj["faster_upload"] = "0" as AnyObject
                    dataObj["thumbnail"] = "" as AnyObject
                    dataObj["url"] = indexObj.S3ImageURL as AnyObject
                    dataObj["type"] = indexObj.isType.rawValue as AnyObject
                    dataArray.append(dataObj)
                    
                }
            }
            
            
            self.managePostCreateService(resp: dataArray as NSArray)
            
        }
    }
    
    func uploadAudio(params : [String:String]){
        CreateRequestManager.uploadMultipartRequestOnS3(urlMain:self.viewModel.newAssets[self.s3index].S3ImagePath , params: params ,fileObjectArray: [self.viewModel.newAssets[self.s3index]],success: {
            (Response) -> Void in
            
            self.viewModel.newAssets[self.s3index].isUploaded = true
            self.s3index = self.s3index + 1
            self.uploadMediaOnS3()

        },failure: {(error) -> Void in
            Loader.stopLoading()
            SharedManager.shared.createPostView?.willRemoveSubview(self.progressCustomView)
            self.progressCustomView.removeFromSuperview()
        })
    }
    
    func uploadImage(params : [String:String]){
        CreateRequestManager.uploadMultipartRequestOnS3(urlMain:self.viewModel.newAssets[self.s3index].S3ImagePath , params: params ,fileObjectArray: [self.viewModel.newAssets[self.s3index]],success: {
            (Response) -> Void in
            

            self.viewModel.newAssets[self.s3index].isUploaded = true
            self.s3index = self.s3index + 1
            self.uploadMediaOnS3()

        },failure: {(error) -> Void in
            Loader.stopLoading()
            SharedManager.shared.createPostView?.willRemoveSubview(self.progressCustomView)
            self.progressCustomView.removeFromSuperview()
        })
    }
    
    
    func uploadThumbImage(params : [String:String]){
        CreateRequestManager.uploadMultipartRequestOnS3(urlMain:self.viewModel.newAssets[self.s3index].S3ImagePath , params: params ,fileObjectArray: [self.viewModel.newAssets[self.s3index]],success: {
            (Response) -> Void in

            self.viewModel.newAssets[self.s3index].isThumbUploaded = true
            self.uploadMediaOnS3()

        },failure: {(error) -> Void in
            Loader.stopLoading()
            SharedManager.shared.createPostView?.willRemoveSubview(self.progressCustomView)
            self.progressCustomView.removeFromSuperview()
        })
    }
    
    
    func uploadVideo(params : [String:String]){
        CreateRequestManager.uploadMultipartRequestOnS3(urlMain:self.viewModel.newAssets[self.s3index].S3VideoPath , params: params ,fileObjectArray: [self.viewModel.newAssets[self.s3index]],success: {
            (Response) -> Void in
            self.viewModel.newAssets[self.s3index].isUploaded = true
            self.s3index = self.s3index + 1
            self.uploadMediaOnS3()
        },failure: {(error) -> Void in
            Loader.stopLoading()
            SharedManager.shared.createPostView?.willRemoveSubview(self.progressCustomView)
            self.progressCustomView.removeFromSuperview()
        })
    }
    
//    
//    func managePostCreateService()  {
//        let userToken:String = SharedManager.shared.userObj!.data.token!
//        let createPostObj = PostCollectionViewObject.init()
//        var postObj:[PostCollectionViewObject] = [PostCollectionViewObject]()
//        if isFileExist {
//            postObj = createPostObj.getPostData(respArray: resp)
//        }else {
//            postObj = self.viewModel.newAssets
//        }
//        postObj.append(contentsOf: self.viewModel.oldAssets)
//        var parameters = ["action": "post/create","token": userToken,"body":commentTextView.text!, "privacy_option": self.selectedPrivacyString]
//        if self.selectedPrivacyIDs.count > 0 {
//            var counter = 0
//            for (_,v) in self.selectedPrivacyIDs {
//                let key = String(format: "contact_group_ids[%i]", counter)
//                parameters[key] = v
//                counter = counter + 1
//            }
//        }
//        if SharedManager.shared.isGroup == 1 {
//            parameters["group_id"] = SharedManager.shared.groupObj?.groupID
//        }else if SharedManager.shared.isGroup == 2 {
//            parameters["page_id"] = SharedManager.shared.groupObj?.groupID
//        }
//        if self.result != nil {
//            parameters["link"] = self.result?.finalUrl?.absoluteString
//            parameters["link_title"] = self.result?.title
//            
//            if self.linkView!.linkImageView.image!.size.width > 50 && self.linkView!.linkImageView.image!.size.height > 50 {
//                parameters["link_image"] = self.result?.image
//            }else {
//                parameters["link_image"] = ""
//            }
//            parameters["link_meta"] = self.result?.description
//        }
//        if self.isPostEdit {
//            parameters["post_id"] = String(self.feedObj!.postID!)
//        }
//        
//        
//        parameters["post_scope_id"] = "1"
        
//        CreateRequestManager.uploadMultipartCreateRequests(params: parameters as! [String : String],
//                                                           fileObjectArray: postObj,
//                                                           success: { (JSONResponse) -> Void in
//            let respDict = JSONResponse
//            //          SharedManager.shared.hideLoadingHubFromKeyWindow()
//            Loader.stopLoading()
//            SharedManager.shared.removeProgressRing()
//            let meta = respDict["meta"] as! NSDictionary
//            let code = meta["code"] as! Int
//            if code == ResponseKey.successResp.rawValue {
//                if(CreatePostHandler.shared.checkIfVideoExist(postArray: self.viewModel.newAssets)) {
//                    if let dataMain = respDict["data"] as? [String : AnyObject] {
//                        if let stringMain = dataMain["post_id"] as? Int {
//                            self.loadFeed(id: String(stringMain))
//                        }
//                    }
//                    // self.manageProcessFileService(postObj: postObj)
//                } else {
//                    if let dataMain = respDict["data"] as? [String : AnyObject] {
//                        if let stringMain = dataMain["post_id"] as? Int {
//                            self.loadFeed(id: String(stringMain))
//                        }
//                    } else {
//                        SharedManager.shared.isNewPostExist = true
//                        self.dismiss(animated: true, completion: nil)
//                        self.viewModel.selectedAssets.removeAll()
//                        self.postCollectionView.reloadData()
//                        self.bottomCollectionView.reloadData()
//                    }
//                }
//            }
//        },failure: {(error) -> Void in
//            
//        }, isShowProgress: !isFileExist)
//    }

    func managePostCreateService(resp:NSArray, isFileExist:Bool = true)  {
        let userToken:String = SharedManager.shared.userObj?.data.token ?? .emptyString
        let createPostObj = PostCollectionViewObject.init()
        var postObj:[PostCollectionViewObject] = [PostCollectionViewObject]()
        if isFileExist {
            postObj = createPostObj.getPostData(respArray: resp)
        } else {
            postObj = self.viewModel.newAssets
        }
        postObj.append(contentsOf: self.viewModel.oldAssets)
        
        var parameters = ["action": "post/create","token": userToken,"body":commentTextView.text!, "privacy_option": self.selectedPrivacyString]
        if self.selectedPrivacyIDs.count > 0 {
            var counter = 0
            for (_,v) in self.selectedPrivacyIDs {
                let key = String(format: "contact_group_ids[%i]", counter)
                parameters[key] = v
                counter = counter + 1
            }
        }
        if SharedManager.shared.isGroup == 1 {
            parameters["group_id"] = SharedManager.shared.groupObj?.groupID
        } else if SharedManager.shared.isGroup == 2 {
            parameters["page_id"] = SharedManager.shared.groupObj?.groupID
        }
        if self.result != nil {
            parameters["link"] = self.result?.finalUrl?.absoluteString
            parameters["link_title"] = self.result?.title
            
            if self.linkView!.linkImageView.image!.size.width > 50 && self.linkView!.linkImageView.image!.size.height > 50 {
                parameters["link_image"] = self.result?.image
            }else {
                parameters["link_image"] = ""
            }
            parameters["link_meta"] = self.result?.description
        }
        if self.isPostEdit {
            parameters["post_id"] = String(self.feedObj!.postID!)
        }
        
        
        parameters["post_type_id"] = "1"
        
        for i in 0 ..< postObj.count {
            let fileObject = postObj[i]
            if fileObject.hashString.count == 0 {
                fileObject.hashString = (fileObject.videoURL == nil) ? fileObject.photoUrl.absoluteString : fileObject.videoURL.absoluteString
            }
            
            
            if fileObject.isType == PostDataType.Image || fileObject.isType == PostDataType.imageText  || fileObject.isType == PostDataType.Attachment   {
              
                parameters[String(format: "file_urls[%d]", i)] = fileObject.hashString
                
                if let url = URL(string: fileObject.hashString) {
                    let dimension = MediaDimensionsManager.shared.dimensions(forMediaAt: url)
                    if dimension != nil {
                        
                        parameters[String(format: "files_info[%d][videoWidth]", i)] = String(Int(dimension!.width))
                        parameters[String(format: "files_info[%d][videoHeight]", i)] = String(Int(dimension!.height))
                    }
                }
                
            }else if fileObject.isType == PostDataType.Audio || fileObject.isType == PostDataType.AudioMusic    {
                parameters[String(format: "file_urls[%d]", i)] = fileObject.hashString
            }else if fileObject.isType == PostDataType.Video {
                parameters[String(format: "file_urls[%d]", i)] = fileObject.hashString
                parameters[String(format: "files_info[%d][thumbnail_url]", i)] = fileObject.thumbURL
                
                if let url = URL(string: fileObject.hashString) {
                    let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                        
                        if let dimension = MediaDimensionsManager.shared.dimensions(forMediaAt: url) {
                            DispatchQueue.main.async {
                                parameters[String(format: "files_info[%d][videoWidth]", i)] = String(Int(dimension.width))
                                parameters[String(format: "files_info[%d][videoHeight]", i)] = String(Int(dimension.height))
                            }
                        } else {
                            print("Unable to get dimensions for media")
                        }
                    }
                    task.resume()
                }

                if let urlThumb = URL(string: fileObject.thumbURL) {
                    let taskThumb = URLSession.shared.dataTask(with: urlThumb) { (data, response, error) in
                        if let dimension = MediaDimensionsManager.shared.dimensions(forMediaAt: urlThumb) {
                            DispatchQueue.main.async {
                                parameters[String(format: "files_info[%d][thumbnailWidth]", i)] = String(Int(dimension.width))
                                parameters[String(format: "files_info[%d][thumbnailHeight]", i)] = String(Int(dimension.height))
                            }
                        } else {
                            print("Unable to get dimensions for thumbnail")
                        }
                    }
                    taskThumb.resume()
                }



            }else {
                if fileObject.isType == PostDataType.GIFBrowse    {
                    
                    parameters[String(format: "file_urls[%d]", i)] = fileObject.photoUrl.absoluteString
                }
            }
            
            parameters[String(format: "files_info[%d][language_id]", i)] = "1"
            
        }
        
        
        CreateRequestManager.fetchDataPost(Completion:{ (response) in
            let elapsedTime = self.apiResponseTimer?.calculateElapsedTime() ?? .emptyString
            LogClass.debugLog("End Point post/create ==> Response Time = \(elapsedTime)")
            switch response {
            case .failure(let error):
                Loader.stopLoading()
                SwiftMessages.apiServiceError(error: error)
            case .success(let respDict):
                    
                    if(CreatePostHandler.shared.checkIfVideoExist(postArray: self.viewModel.newAssets)) {
                        if let dataMain = respDict as? [String : AnyObject] {
                            if let stringMain = dataMain["post_id"] as? Int {
                                self.loadFeed(id: String(stringMain))
                            }
                        }
                        // self.manageProcessFileService(postObj: postObj)
                    } else {
                        if let dataMain = respDict  as? [String : AnyObject] {
                            if let stringMain = dataMain["post_id"] as? Int {
                                self.loadFeed(id: String(stringMain))
                            }
                        } else {
                            Loader.stopLoading()
                            SharedManager.shared.isNewPostExist = true
                            self.dismiss(animated: true, completion: nil)
                            self.viewModel.selectedAssets.removeAll()
                            self.postCollectionView.reloadData()
                            self.bottomCollectionView.reloadData()
                        }
                    }
                
            }
        }, param: parameters)

    }
        
    func loadFeed(id : String){
        Loader.startLoading()
        let actionString = String(format: "post/get-single-newsfeed-item/%@",id)
        let parameters = ["action": actionString,"token":SharedManager.shared.userToken()]
        
        RequestManagerGen.fetchDataGetNotification(Completion: { (response: Result<(FeedSingleModel), Error>) in
            Loader.stopLoading()
            switch response {
            case .failure(let error):

                if error is ErrorModel  {
                    let err = error as! ErrorModel
                    if err.meta?.code == ResponseKey.unAuthorizedResp.rawValue {
                        AppDelegate.shared().loadLoginScreen()
                    }else {
                        self.ShowAlert(message: "No post found".localized())
                    }
                }else {
                    self.ShowAlert(message: "No post found".localized())
                }
            case .success(let res):
                SharedManager.shared.postCreateTop = res.data!.post!
                SharedManager.shared.isNewPostExist = true
                self.dismiss(animated: true, completion: nil)
                self.viewModel.selectedAssets.removeAll()
                self.postCollectionView.reloadData()
                self.bottomCollectionView.reloadData()
            }
        }, param:parameters)
    }
    

    @objc func dismissMyController()  {
        SharedManager.shared.isNewPostExist = true
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonClicked(_ sender: Any) {
        self.commentTextView.resignFirstResponder()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func audioRecordOpen(sender : UIButton) {
        self.commentTextView.resignFirstResponder()
        
        let audioRecorder = AppStoryboard.Shared.instance.instantiateViewController(withIdentifier: SharedAudioRecorderVC.className) as! SharedAudioRecorderVC
        
        audioRecorder.getAudioUrl = { audioUrl in
            let newObj = PostCollectionViewObject.init()
            newObj.isType = PostDataType.Audio
            newObj.videoURL = audioUrl
            newObj.langID = "1"
            self.viewModel.selectedAssets.append(newObj)
            self.postCollectionView.reloadData()
            self.bottomCollectionView.reloadData()
        }
        
        self.sheetController = SheetViewController(controller: audioRecorder, sizes: [.fixed(280)])
        self.sheetController.overlayColor = UIColor.black.withAlphaComponent(0.3)
        self.sheetController.extendBackgroundBehindHandle = true
        self.sheetController.topCornersRadius = 20
        self.present(self.sheetController, animated: false, completion: nil)
    }
    
    @IBAction func imageTextBgBtnClicked(sender : UIButton){
        self.commentTextView.resignFirstResponder()
        let viewImageText = self.storyboard?.instantiateViewController(withIdentifier: "TextBackgroundController") as! TextBackgroundController
        viewImageText.delegate = self
        self.present(viewImageText, animated: true) {
        }
    }
    
    func getNewCompressURL(_ url: URL, with newObj: PostCollectionViewObject) -> PostCollectionViewObject{
        CompressManager.shared.compressingVideoURLNEw(url: url) { compressedUrl in
            if compressedUrl == nil {
                newObj.isCompress = true
                DispatchQueue.main.async {
                   if self.isCreateBtnTap{
                        self.callingCreatePostService()
                    }

                }
            } else {
                newObj.videoURL = compressedUrl
                newObj.isCompress = true
                DispatchQueue.main.async {
                    if self.isCreateBtnTap{
                        self.callingCreatePostService()
                    }
                }
            }
        }
        return newObj
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var newObj = PostCollectionViewObject.init()
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            let newObj = PostCollectionViewObject.init()
            newObj.isType = PostDataType.Image
            newObj.imageMain = pickedImage.compress(to: 100)
            newObj.photoUrl = pickedImage.saveToTemporaryDirectory()
            self.viewModel.selectedAssets.append(newObj)
            postCollectionView.reloadData()
            bottomCollectionView.reloadData()
            picker.dismiss(animated: true, completion: nil)
        }else if let _ = info[UIImagePickerController.InfoKey.mediaType] as? String,
            // pickedVideo == (kUTTypeMovie as String),
            let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
            newObj.isType = PostDataType.Video
            newObj.videoURL = url
            newObj.isCompress = false
            newObj = getNewCompressURL(url, with: newObj)
            newObj.langID = "1"
            newObj.imageMain = thumbnailForVideoAtURL(url: url as NSURL)?.compress(to: 100)
            self.viewModel.selectedAssets.append(newObj)
            postCollectionView.reloadData()
            bottomCollectionView.reloadData()
            picker.dismiss(animated: true, completion: nil)
        }
    }
    
    
    private func thumbnailForVideoAtURL(url: NSURL) -> UIImage? {
        let asset = AVAsset(url: url as URL)
        let assetImageGenerator = AVAssetImageGenerator(asset: asset)
        
        // Apply preferred track transform to handle orientation
        assetImageGenerator.appliesPreferredTrackTransform = true
        
        var time = asset.duration
        time.value = min(time.value, 2)
        
        do {
            let imageRef = try assetImageGenerator.copyCGImage(at: time, actualTime: nil)
            return UIImage(cgImage: imageRef)
        } catch {
            return nil
        }
    }

    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func removeFileFromDocumentsDirectory(fileUrl: URL) {
        return self.removeFileFromDocumentsDirectory(fileUrl: fileUrl)
    }
}

extension CreatePostViewController: ImageTextBgDelegate {
    func imageTextSaved(img: UIImage)   {
        let newObj = PostCollectionViewObject.init()
        newObj.isType = PostDataType.imageText
        newObj.imageMain = img.compress(to: 100)
        newObj.photoUrl = URL.init(string: "MynewFileImage" + String(self.viewModel.selectedAssets.count + 1) + ".png")
        self.viewModel.selectedAssets.append(newObj)
        self.postCollectionView.reloadData()
        self.bottomCollectionView.reloadData()
    }
}

extension CreatePostViewController: GifImageSelectionDelegate {
    func gifSelected(gifDict:[Int:GifModel], currentIndex: IndexPath) {
        for (key, gifObj) in gifDict {
            let newObj = PostCollectionViewObject.init()
            newObj.isType = PostDataType.GIFBrowse
            newObj.id = gifObj.id
            newObj.photoUrl = URL(string: gifObj.url)
            self.viewModel.selectedAssets.append(newObj)
        }
        self.postCollectionView.reloadData()
        self.bottomCollectionView.reloadData()
    }
}

extension CreatePostViewController : AudioDelegate {
    func audioURL(text: String){
        let newObj = PostCollectionViewObject.init()
        newObj.isType = PostDataType.Audio
        newObj.videoURL = URL.init(string: text)
        newObj.langID = "1"
        self.viewModel.selectedAssets.append(newObj)
        self.postCollectionView.reloadData()
        self.bottomCollectionView.reloadData()
    }
    
    @objc func loadAudio(sender : UIButton){
        isSelected = sender.tag
        let player = AVPlayer(url: self.viewModel.selectedAssets[sender.tag].videoURL)
        self.playerViewController.player = player
        self.present(self.playerViewController, animated: true) {
            self.playerViewController.player!.play()
        }
    }
}

extension CreatePostViewController:UICollectionViewDataSource, UICollectionViewDelegate   {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        var isTextEnter = false
        
        if self.commentTextView.text.count == 0 || self.commentTextView.text == Const.textCreatePlaceholder{
            isTextEnter = true
        }
        
        if self.viewModel.selectedAssets.count == 0 && isTextEnter  {
            self.bottomBarView.isHidden = true
            self.bottomButtonView.isHidden = false
        } else {
            self.bottomBarView.isHidden = false
            self.bottomButtonView.isHidden = true
        }
        
        if self.viewModel.selectedAssets.count > 0 {
            self.customPreviewView.isHidden = true
        } else {
            self.customPreviewView.isHidden = false
        }
        
        return self.viewModel.selectedAssets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView.tag == 500 {
            
            guard let cellBottom = collectionView.dequeueReusableCell(withReuseIdentifier: "BottomCreatePostCell", for: indexPath) as? BottomCreatePostCell else {
               return UICollectionViewCell()
            }
            
            cellBottom.manageBottomCollection(indexValue: indexPath.row)
            let newObj = self.viewModel.selectedAssets[indexPath.row]
            cellBottom.createPostView?.viewButton.isHidden = true
            cellBottom.createPostView?.buttonDelete.tag = indexPath.row
            cellBottom.createPostView?.viewPlayButton.isHidden = true
            cellBottom.createPostView?.myfileImageView.isHidden = true
            cellBottom.createPostView?.myImageView.isHidden = false

            if newObj.isType == PostDataType.Attachment {

                let urlmain = newObj.fileUrl.components(separatedBy: ".")
                if urlmain.last == "pdf" {
                    cellBottom.createPostView?.myImageView.image = UIImage.init(named: "PDFIcon.Spng")
                } else if urlmain.last == "doc" || urlmain.last == "docx" {
                    cellBottom.createPostView?.myImageView.image = UIImage.init(named: "WordFileS.png")
                } else if urlmain.last == "xls" || urlmain.last == "xlsx" {
                    cellBottom.createPostView?.myImageView.image = UIImage.init(named: "ExcelIconS.png")
                } else if  urlmain.last == "zip" {
                    cellBottom.createPostView?.myImageView.image = UIImage.init(named: "ZipIconS.png")
                } else if  urlmain.last == "pptx" {
                    cellBottom.createPostView?.myImageView.image = UIImage.init(named: "pptIconS.png")
                } else {
                    cellBottom.createPostView?.myImageView.image = UIImage.init(named: "PDFIconS.png")
                }
            } else if newObj.isType == PostDataType.Image {
                if newObj.imageMain != nil {
                    cellBottom.createPostView?.myImageView.image = newObj.imageMain
                } else {
                    if newObj.isEditPost {
//                        cellBottom.createPostView?.myImageView.sd_setImage(with:URL(string: newObj.imageUrl), placeholderImage: UIImage(named: "placeholder.png"))
                        
                        cellBottom.createPostView?.myImageView.loadImageWithPH(urlMain:newObj.imageUrl)
                        
                        self.view.labelRotateCell(viewMain: cellBottom.createPostView!)
                    } else {
                        cellBottom.createPostView?.myImageView.image = self.getSelectedItem(asset: newObj.assetMain)
                        self.viewModel.selectedAssets[indexPath.row].imageMain = cellBottom.createPostView?.myImageView.image
                    }
                }
            } else if newObj.isType == PostDataType.GIFBrowse {
                
                cellBottom.createPostView?.myImageView.loadImageWithPH(urlMain:newObj.photoUrl.absoluteString)
                
//                cellBottom.createPostView?.myImageView.sd_setImage(with:newObj.photoUrl, placeholderImage: UIImage(named: "placeholder.png"))
                self.view.labelRotateCell(viewMain: cellBottom.createPostView!)
            } else if newObj.isType == PostDataType.GIF {
                if newObj.imageMain != nil {
                    cellBottom.createPostView?.myImageView.image = newObj.imageMain
                }else {
                    cellBottom.createPostView?.myImageView.image = self.getSelectedItem(asset: newObj.assetMain)
                    self.viewModel.selectedAssets[indexPath.row].imageMain = cellBottom.createPostView?.myImageView.image
                }
            } else if newObj.isType == PostDataType.imageText {
                if newObj.imageMain != nil {
                    cellBottom.createPostView?.myImageView.image = newObj.imageMain
                }
            } else if newObj.isType == PostDataType.Audio {
                cellBottom.createPostView?.viewPlayButton.isHidden = false
                cellBottom.createPostView?.myImageView.image = UIImage(named: "GalleryBgImage.png")
                cellBottom.createPostView?.viewPlayButton.isHidden = false
                cellBottom.createPostView?.buttonPly.tag = indexPath.row
            } else if newObj.isType == PostDataType.AudioMusic {
                cellBottom.createPostView?.viewPlayButton.isHidden = false
                cellBottom.createPostView?.myImageView.image = UIImage(named: "GalleryBgImage.png")
                cellBottom.createPostView?.viewPlayButton.isHidden = false
                cellBottom.createPostView?.buttonPly.tag = indexPath.row
            } else if newObj.isType == PostDataType.Video {
                cellBottom.createPostView?.viewPlayButton.isHidden = false
                cellBottom.createPostView?.buttonPly.tag = indexPath.row
                if newObj.imageMain != nil {
                    cellBottom.createPostView?.myImageView.image = newObj.imageMain
                } else {
                    if newObj.isEditPost {
                        
                        cellBottom.createPostView?.myImageView.loadImageWithPH(urlMain:newObj.thumbURL)

                        
                        self.view.labelRotateCell(viewMain: cellBottom.createPostView!)
                    }else {
                        cellBottom.createPostView?.myImageView.image = self.getSelectedItem(asset: newObj.assetMain)
                        self.viewModel.selectedAssets[indexPath.row].imageMain = cellBottom.createPostView?.myImageView.image
                    }
                }
            }
            cellBottom.createPostView?.viewButton.isHidden = false
            cellBottom.createPostView?.buttonDelete.tag = indexPath.row
            cellBottom.createPostView?.buttonDelete.addTarget(self, action: #selector(self.DeleteImage), for: .touchUpInside)
            return cellBottom
        } else {
            let cell = collectionView
                .dequeueReusableCell(withReuseIdentifier: PostCollectionViewCell.identifier,
                                     for: indexPath) as! PostCollectionViewCell
            cell.createPostView?.viewButton.isHidden = true
            cell.createPostView?.viewPlayButton.isHidden = true
            cell.createPostView?.buttonDelete.tag = indexPath.row
            var showLangBar = false
            let newObj = self.viewModel.selectedAssets[indexPath.row]
            cell.createPostView!.myfileImageView.isHidden = true
            cell.createPostView!.myImageView.isHidden = false
            if newObj.isType == PostDataType.Attachment {
                
                let urlmain = newObj.fileUrl.components(separatedBy: ".")
                
                cell.createPostView!.myfileImageView.isHidden = false
                
                if urlmain.last == "pdf" {
                    cell.createPostView!.myfileImageView.image = UIImage.init(named: "PDFIcon.png")
                }else if urlmain.last == "doc" || urlmain.last == "docx"{
                    cell.createPostView!.myfileImageView.image = UIImage.init(named: "WordFile.png")
                }else if urlmain.last == "xls" || urlmain.last == "xlsx"{
                    cell.createPostView!.myfileImageView.image = UIImage.init(named: "ExcelIcon.png")
                }else if  urlmain.last == "zip"{
                    cell.createPostView!.myfileImageView.image = UIImage.init(named: "ZipIcon.png")
                }else if  urlmain.last == "pptx"{
                    cell.createPostView!.myfileImageView.image = UIImage.init(named: "pptIcon.png")
                }else {
                    cell.createPostView!.myfileImageView.image = UIImage.init(named: "PDFIcon.png")
                }
            }else if newObj.isType == PostDataType.Image {
                if newObj.imageMain != nil {
                    cell.createPostView!.myImageView.image = newObj.imageMain
                }else {
                    if newObj.isEditPost {
                        cell.createPostView?.myImageView.loadImageWithPH(urlMain:newObj.imageUrl)
                        self.view.labelRotateCell(viewMain: cell.createPostView!)
                    }else {
                        cell.createPostView?.myImageView.image = self.getSelectedItem(asset: newObj.assetMain)
                        self.viewModel.selectedAssets[indexPath.row].imageMain = cell.createPostView?.myImageView.image
                    }
                }
            }else if newObj.isType == PostDataType.GIFBrowse {
                cell.createPostView?.myImageView.loadImageWithPH(urlMain:newObj.photoUrl.absoluteString)
                self.view.labelRotateCell(viewMain: cell.createPostView!)
            }else if newObj.isType == PostDataType.GIF {
                if newObj.imageMain != nil {
                    cell.createPostView!.myImageView.image = newObj.imageMain
                }else {
                    cell.createPostView?.myImageView.image = self.getSelectedItem(asset: newObj.assetMain)
                    self.viewModel.selectedAssets[indexPath.row].imageMain = cell.createPostView?.myImageView.image
                }
            }else if newObj.isType == PostDataType.imageText {
                if newObj.imageMain != nil {
                    cell.createPostView?.myImageView.image = newObj.imageMain
                }
            }
            else if newObj.isType == PostDataType.Audio
            {
                showLangBar = true
                cell.createPostView?.viewPlayButton.isHidden = false
                cell.createPostView?.myImageView.image = UIImage(named: "GalleryBgImage.png")
                cell.createPostView?.viewPlayButton.isHidden = false
                cell.createPostView?.buttonPly.removeTarget(self, action: #selector(self.PlayAction), for: .touchUpInside)
                cell.createPostView?.buttonPly.addTarget(self, action: #selector(self.loadAudio), for: .touchUpInside)
                cell.createPostView?.buttonPly.tag = indexPath.row
                if newObj.isEditPost {
                    showLangBar = false
                }
            }else if newObj.isType == PostDataType.AudioMusic
            {
                showLangBar = true
                cell.createPostView?.viewPlayButton.isHidden = false
                cell.createPostView?.myImageView.image = UIImage(named: "GalleryBgImage.png")
                cell.createPostView?.viewPlayButton.isHidden = false
                cell.createPostView?.buttonPly.removeTarget(self, action: #selector(self.PlayAction), for: .touchUpInside)
                cell.createPostView?.buttonPly.addTarget(self, action: #selector(self.loadAudio), for: .touchUpInside)
                cell.createPostView?.buttonPly.tag = indexPath.row
                if newObj.isEditPost {
                    showLangBar = false
                }
            }
            else if newObj.isType == PostDataType.Video {
                showLangBar = true
                cell.createPostView?.viewPlayButton.isHidden = false
                cell.createPostView?.buttonPly.removeTarget(self, action: #selector(self.loadAudio), for: .touchUpInside)
                cell.createPostView?.buttonPly.addTarget(self, action: #selector(self.PlayAction), for: .touchUpInside)
                cell.createPostView?.buttonPly.tag = indexPath.row
                if newObj.imageMain != nil {
                    cell.createPostView?.myImageView.image = newObj.imageMain
                }else {
                    if newObj.isEditPost {
                        cell.createPostView?.myImageView.loadImageWithPH(urlMain:newObj.thumbURL)
                        
                        self.view.labelRotateCell(viewMain: cell.createPostView!)
                        showLangBar = false
                    }else {
                        cell.createPostView?.myImageView.image = self.getSelectedItem(asset: newObj.assetMain)
                        self.viewModel.selectedAssets[indexPath.row].imageMain = cell.createPostView?.myImageView.image
                    }
                }
            }
            cell.manageImageData(indexValue: indexPath.row,cellSize:self.postCollectionView.frame, showLangBar: showLangBar, index: indexPath)
            cell.createPostView?.viewButton.isHidden = true
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.crossBtn.isHidden = true
        var value:Bool = true
        
        if collectionView.tag != 500 {
            if self.bottomBarView.isHidden {
                value = false
            }
            self.hideOrShowAnimated(value: value, btn: self.bottomBarView)
            self.hideOrShowAnimated(value: value, btn: self.topBarView)
            self.hideOrShowAnimated(value: value, btn: self.descriptionView)
            self.hideOrShowAnimated(value: value, btn: self.bottomCollectionView)
            self.hideOrShowAnimated(value: value, btn: self.customPreviewView)
        }
        self.postCollectionView.scrollToItem(at:indexPath, at: .right, animated: false)
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    @objc func PlayAction(sender : UIButton){
        isSelected = sender.tag
        DispatchQueue.main.async {
            self.loadVideo()
        }
    }
    
    @objc func DeleteImage(sender : UIButton){
        self.viewModel.selectedAssets.remove(at: sender.tag)
        self.bottomCollectionView.reloadData()
        self.postCollectionView.reloadData()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
    
    func hideOrShowAnimated(value:Bool, btn:UIView){
        if value {
            btn.fadeOut()
        }else {
            btn.fadeIn()
        }
    }
}

extension CreatePostViewController:TLPhotosPickerViewControllerDelegate {
    func dismissPhotoPicker(withTLPHAssets: [TLPHAsset]) {
        var selectedAsset = [PostCollectionViewObject]()
        for indexObj in self.viewModel.selectedAssets {
            if indexObj.isType == .GIF || indexObj.isType == .Image || indexObj.isType == .Video {
            }else {
                selectedAsset.append(indexObj)
            }
        }
        
        self.viewModel.selectedAssets.removeAll()
        
        for indexObj in selectedAsset {
            self.viewModel.selectedAssets.append(indexObj)
        }
        for indexObj in withTLPHAssets {
            if indexObj.type == .photo {
                let newObj = PostCollectionViewObject.init()
                newObj.isType = PostDataType.Image
                if indexObj.extType() == TLPHAsset.ImageExtType.gif {
                    newObj.isType = PostDataType.GIF
                }
                newObj.assetMain = indexObj
                self.viewModel.selectedAssets.append(newObj)
                ChatManager.shared.getUrlFromPHAsset(asset: indexObj.phAsset!) { (urlString) in
                    if urlString != nil {
                        newObj.photoUrl = urlString
                    }
                }
            }else if indexObj.type == .livePhoto {
                let newObj = PostCollectionViewObject.init()
                newObj.isType = PostDataType.Image
                newObj.assetMain = indexObj
                self.viewModel.selectedAssets.append(newObj)
            }
            else if indexObj.type == .video {
                var newObj = PostCollectionViewObject.init()
                newObj.isType = PostDataType.Video
                newObj.isCompress = false
                newObj.assetMain = indexObj
                let thumbImage:UIImage = SharedManager.shared.getImageFromAsset(asset: indexObj.phAsset!)!
                do {
                    let options: PHVideoRequestOptions = PHVideoRequestOptions()
                    options.version = .original
                    PHImageManager.default().requestAVAsset(forVideo: indexObj.phAsset!, options: options, resultHandler: {(asset, audioMix, info) in
                        if let urlAsset = asset as? AVURLAsset {
                            newObj.videoURL = urlAsset.url
                            newObj = self.getNewCompressURL(urlAsset.url, with: newObj)
                            newObj.imageMain = thumbImage.compress(to: 100)
                        }
                    })
                }
                self.viewModel.selectedAssets.append(newObj)
            }
        }
        self.postCollectionView.reloadData()
        self.bottomCollectionView.reloadData()
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
    
    @objc func loadVideo(){
        if self.isSelected != -1 {
            
            let videoURL = self.viewModel.selectedAssets[isSelected].videoURL!
            let player = AVPlayer(url: videoURL)
            self.playerViewController.player = player
            self.present(self.playerViewController, animated: true) {
                self.playerViewController.player!.play()
            }
        }
    }
}

extension CreatePostViewController:UITextViewDelegate, UITextPasteDelegate   {
    
    override func paste(_ sender: Any?) {
        
        self.bottomBarView.isHidden = false
        self.bottomButtonView.isHidden = true
        
        if UIPasteboard.general.hasImages {
            let objMAin = PostCollectionViewObject.init()
            objMAin.imageMain = UIPasteboard.general.images!.first?.compress(to: 100)
            objMAin.id = "-1"
            objMAin.isType = PostDataType.Image

            self.viewModel.selectedAssets.append(objMAin)
            self.postCollectionView.reloadData()
            self.bottomCollectionView.reloadData()
            
            UIPasteboard.general.images?.removeAll()
            UIPasteboard.general.items.removeAll()
            UIPasteboard.general.string = ""
        
        }else {
            
            if let message = UIPasteboard.general.string {
                self.commentTextView.text = self.commentTextView.text + " " +  message
            }
            
        }
    }
    func textPasteConfigurationSupporting(_ textPasteConfigurationSupporting: UITextPasteConfigurationSupporting, transform item: UITextPasteItem) {
        
        self.bottomBarView.isHidden = false
        self.bottomButtonView.isHidden = true
        
        if UIPasteboard.general.hasImages {

            let objMAin = PostCollectionViewObject.init()
            objMAin.imageMain = UIPasteboard.general.images!.first?.compress(to: 100)
            objMAin.id = "-1"
            objMAin.isType = PostDataType.Image

            self.viewModel.selectedAssets.append(objMAin)
            self.postCollectionView.reloadData()
            self.bottomCollectionView.reloadData()
            
            
            UIPasteboard.general.images?.removeAll()
            UIPasteboard.general.items.removeAll()
            UIPasteboard.general.string = ""
       
            
        }else {
            if let message = UIPasteboard.general.string {
                self.commentTextView.text = self.commentTextView.text + " " +  message
            }
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if self.commentTextView.textColor == UIColor.customgreyColor {
            self.commentTextView.text = nil
            self.commentTextView.textColor = UIColor.black
        }
        let frame = SharedManager.shared.getTextViewSize(textView: textView)
        let actualSize = ((self.view.frame.size.height) - self.keyboardHeight)
        if frame.size.height < actualSize   {
            if frame.size.height < 150 {
                self.commentTextView.isScrollEnabled = false
                self.commentHeightConst.constant = frame.size.height
            } else {
                self.commentTextView.isScrollEnabled = true
                self.commentHeightConst.constant = 200
            }
        }else {
            self.commentHeightConst.constant = actualSize
            self.commentTextView.isScrollEnabled = true
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if self.commentTextView.text.isEmpty {
            self.commentTextView.text = Const.textCreatePlaceholder
            self.commentTextView.textColor = UIColor.customgreyColor
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let fixedWidth = textView.frame.size.width
        self.timerAPI.invalidate()
        textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        var newFrame = textView.frame
        newFrame.size = CGSize(width: max(fixedWidth, fixedWidth), height: newSize.height)
        if newFrame.size.height < ((self.view.frame.size.height) - self.keyboardHeight)   {
            if newFrame.size.height < 200.0 {
                self.commentTextView.isScrollEnabled = false
                self.commentHeightConst.constant = newFrame.size.height
            } else {
                self.commentTextView.isScrollEnabled = true
                self.commentHeightConst.constant = 200
            }
        } else {
            self.commentTextView.isScrollEnabled = true
        }
        self.timerAPI = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.callURL), userInfo: nil, repeats: false)
    }
    
    
    @objc func callURL(){
        self.findURL(text: self.commentTextView.text)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        self.rangeText = range
        self.bottomBarView.isHidden = false
        self.bottomButtonView.isHidden = true
            
        if let paste = UIPasteboard.general.string, text == paste {
            if text.lowercased().contains(".mp4") ||
                text.lowercased().contains(".mov") {
                let asset = TLPHAsset.asset(with: paste)
                
                let objMAin = PostCollectionViewObject.init()
                objMAin.videoURL = URL.init(string: paste)
                objMAin.id = "-1"
                objMAin.assetMain = asset
                objMAin.isType = PostDataType.Video
                objMAin.isCompress = false
                objMAin.imageMain = SharedManager.shared.videoSnapshot(filePathLocal: URL.init(string: paste)!)

                
                self.viewModel.selectedAssets.append(objMAin)
                self.postCollectionView.reloadData()
                self.bottomCollectionView.reloadData()
                UIPasteboard.general.images?.removeAll()
                UIPasteboard.general.items.removeAll()
                UIPasteboard.general.string = ""
                
                
                return false
            }
            
            
            if UIPasteboard.general.hasImages {
                let objMAin = PostCollectionViewObject.init()
                objMAin.imageMain = UIPasteboard.general.images!.first?.compress(to: 100)
                objMAin.id = "-1"
                objMAin.isType = PostDataType.Image

                self.viewModel.selectedAssets.append(objMAin)
                self.postCollectionView.reloadData()
                self.bottomCollectionView.reloadData()
                
                
                UIPasteboard.general.images?.removeAll()
                UIPasteboard.general.items.removeAll()
                UIPasteboard.general.string = ""
            }else {
                if UIPasteboard.general.url != nil{
                    self.commentTextView.text = UIPasteboard.general.url?.absoluteString
                }else if UIPasteboard.general.string != nil{
                    self.commentTextView.text = UIPasteboard.general.string
                }
                self.postCollectionView.reloadData()
                self.bottomCollectionView.reloadData()
                
                
                UIPasteboard.general.images?.removeAll()
                UIPasteboard.general.items.removeAll()
                UIPasteboard.general.string = ""
                
            }
            if !self.isLinkDetected {
                     self.findURL(text: self.commentTextView.text)
             }
            
             return false
        }
        
       if !self.isLinkDetected {
            if text == "\n" {
                self.findURL(text: textView.text)
            }else if text == " " {
                self.findURL(text: textView.text)
            }
        }
        return true
    }
    
    func findURL(text:String)   {
        self.viewTags.isHidden = true
        if let url = self.slp.extractURL(text: text)    {
            self.isLinkDetected = true
            self.linkGeneratorObj.delegate = self
            self.linkGeneratorObj.getLinkData(text: text)
        }

        self.getTagsFromText()
      
    }
    
    
    func getTagsFromText(){
        
        RequestManager.cancelTagRequest()

        let textMain = String(self.commentTextView.text.prefix(self.rangeText.location + 1))
        let arrayLastObject = textMain.components(separatedBy: " ").last
        if arrayLastObject != nil {
            if arrayLastObject!.count > 0 {
                let firstChar = arrayLastObject!.prefix(1)
                if firstChar == "#" {
                    self.getTagsFromAPI(textMain: textMain.getTags().last!)
                }
                
            }
        }

    }
    func getTagsFromAPI(textMain : String){
        self.Arraytags.removeAll()
        let userToken = SharedManager.shared.userObj!.data.token as? String
        var parameters : [String : String] = ["action": "hashtag-suggest","token": userToken! ,"hash_tag_name":textMain]
        
        
        RequestManager.fetchDataGet(Completion: { response in
            switch response {
            case .failure(let error):
                if error is String {
                    
                }
            case .success(let res):
                if let dictArray = res as? [[String:Any]] {
                    self.Arraytags = dictArray
                }
                
                if self.Arraytags.count > 0 {
                    self.viewTags.isHidden = false
                }
                self.tblViewTags.reloadData()
            }
        }, param: parameters)
    }
}

extension CreatePostViewController: LinkGeneratorDelegate {
    
    func linkGeneratedDelegate(result: Response) {
        self.customPreviewView.isHidden = false
        self.customPreviewHeightConst.constant = 63
        if result.url != self.result?.url {
            self.result = result
            self.linkView?.manageData(result: result)
            self.customPreviewView.addSubview(self.linkView!)
            self.linkView!.translatesAutoresizingMaskIntoConstraints = false
            self.linkView!.leadingAnchor.constraint(equalTo: self.customPreviewView.leadingAnchor, constant: 0).isActive = true
            self.linkView!.trailingAnchor.constraint(equalTo: self.customPreviewView.trailingAnchor, constant: 0).isActive = true
            self.linkView!.topAnchor.constraint(equalTo: self.customPreviewView.topAnchor, constant: 0).isActive = true
            self.linkView!.bottomAnchor.constraint(equalTo: self.customPreviewView.bottomAnchor, constant: 0).isActive = true
            self.linkView!.linkCloseBtn.addTarget(self, action: #selector(closeLinkPreview), for: .touchUpInside)
            if self.viewModel.selectedAssets.count > 0 {
                self.customPreviewView.isHidden = true
            }else {
                self.customPreviewView.isHidden = false
            }
        }
    }
    
    func linkGenerateFailedDelegate() {
        self.isLinkDetected = false
    }
    
    @objc func closeLinkPreview (){
        self.linkView!.removeFromSuperview()
        self.customPreviewView.isHidden = true
        self.customPreviewHeightConst.constant = 1
        self.result = nil
    }
}

extension CreatePostViewController: MakeDropDownDataSourceProtocol {
    @IBAction func dropDownBtnClicked(_ sender: Any) {
        self.commentTextView.resignFirstResponder()
        self.dropDown.showDropDown(height: 30 * 10)
    }
    
    func getDataToDropDown(cell: UITableViewCell, indexPos: Int, makeDropDownIdentifier: String) {
        if makeDropDownIdentifier == "DROP_DOWN_NEW"{
            let customCell = cell as! DropDownTableViewCell
            customCell.countryNameLabel.text = self.lanaguageModelArray[indexPos].languageName
        }
    }
    
    func numberOfRows(makeDropDownIdentifier: String) -> Int {
        return self.lanaguageModelArray.count
    }
    
    func selectItemInDropDown(indexPos: Int, makeDropDownIdentifier: String) {
        self.selectedLangModel = self.lanaguageModelArray[indexPos]
        let languageName = self.lanaguageModelArray[indexPos].languageName
        self.dropDownBtn.setTitle(" "+languageName, for: .normal)
        self.dropDown.hideDropDown()
    }
    
    func setUpDropDown(){
        dropDown.makeDropDownIdentifier = "DROP_DOWN_NEW"
        dropDown.cellReusableIdentifier = "dropDownCell"
        dropDown.makeDropDownDataSourceProtocol = self
        var frm = CGRect(x: 0, y: 0, width: 0, height: 0)
        if UIDevice.current.hasNotch {
            frm = CGRect(x: 40 + self.dropDownBtn.frame.origin.x, y: self.langDropDownView.frame.origin.y - 140, width: self.dropDownBtn.frame.size.width, height: self.dropDownBtn.frame.size.height)
        } else {
            frm = CGRect(x: 40 + self.dropDownBtn.frame.origin.x, y: self.langDropDownView.frame.origin.y - 140, width: self.dropDownBtn.frame.size.width, height: self.dropDownBtn.frame.size.height)
        }
        dropDown.setUpDropDown(viewPositionReference: (frm), offset: 0)
        dropDown.nib = UINib(nibName: "DropDownTableViewCell", bundle: nil)
        dropDown.setRowHeight(height: self.dropDownRowHeight)
        self.view.addSubview(dropDown)
        self.populateLangugaeData()
        self.viewLanguageModel.langugageHandlerDetected = { [weak self] (langugageID) in
            self?.selectedLangModel = self?.lanaguageModelArray[(langugageID-1)]
            self?.dropDownBtn.setTitle(" "+(self?.selectedLangModel?.languageName)!, for: .normal)
        }
    }
    
    func populateLangugaeData(){
        self.lanaguageModelArray = SharedManager.shared.populateLangData()
    }
}

extension CreatePostViewController:MPMediaPickerControllerDelegate  {
    
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection)  {
        self.notAudioBrowse = false
        self.musicPlayer!.dismiss(animated: true, completion: {
//            SharedManager.shared.showOnWindow()
            Loader.startLoading()
            let item: MPMediaItem = mediaItemCollection.items[0]
            let pathURL: NSURL? = item.value(forProperty: MPMediaItemPropertyAssetURL) as? NSURL
            if pathURL == nil {
//                SharedManager.shared.hideLoadingHubFromKeyWindow()
                Loader.stopLoading()
                SharedManager.shared.showAlert(message: "Not able to get the audio file.".localized(), view: self)
                return
            }
            let title = item.value(forProperty: MPMediaItemPropertyTitle) as? String ?? "myAudioFile"
            FileBasedManager.shared.saveAudioFileTemporarily(pathURL: pathURL!, name: title)
            FileBasedManager.shared.audioFileSavedInTemp = { fileUrl in
//                SharedManager.shared.hideLoadingHubFromKeyWindow()
                Loader.stopLoading()
                let newObj = PostCollectionViewObject.init()
                newObj.isType = PostDataType.AudioMusic
                newObj.videoURL = fileUrl
                self.viewModel.selectedAssets.append(newObj)
                self.postCollectionView.reloadData()
                self.bottomCollectionView.reloadData()
            }
        })
    }
    
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController)   {
        mediaPicker.dismiss(animated: true, completion: nil)
        self.notAudioBrowse = true
//        SharedManager.shared.hideLoadingHubFromKeyWindow()
        Loader.stopLoading()
    }
}


extension CreatePostViewController: UIDocumentPickerDelegate {
    func didPressDocumentShare() {
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
        self.present(documentPicker, animated: true) {
            
        }
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else {return}

        
        let newObj = PostCollectionViewObject.init()
        newObj.isType = PostDataType.Attachment
        newObj.fileUrl = url.path
        newObj.videoURL = url
        self.viewModel.selectedAssets.append(newObj)
        postCollectionView.reloadData()
        bottomCollectionView.reloadData()
        
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {

    }
}

extension CreatePostViewController:PrivacyOptionDelegate {
    func privacyOptionSelected(type:String, keyPair:String) {
//        self.sheetController.closeSheet()
        self.selectedPrivacyString = keyPair
        self.lblPrivacyTitle.text = type
    }
    
    func privacyOptionCategorySelected(type:String, catID:[Int:String]) {
//        self.sheetController.closeSheet()
        if type.count > 0 {
            self.lblPrivacyTitle.text = "Contact Groups".localized()
            self.selectedPrivacyString = type
            self.selectedPrivacyIDs = catID
        }
    }
}



extension String {
    func getTags() -> [String]{
        var hashtags = [String]()
        let regex = try? NSRegularExpression(pattern: "(#[A-Za-z0-9]*)", options: [])
        if regex == nil {
            return hashtags
        }
        let matches = regex!.matches(in: self, options: [], range: NSMakeRange(0, self.count))
        for match in matches {
            hashtags.append(NSString(string: self).substring(with: NSRange(location:match.range.location + 1, length:match.range.length - 1)))
        }
        
        return hashtags
    }
}


extension CreatePostViewController : UITableViewDelegate , UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tblViewTags {
            return self.Arraytags.count
        }else {
            return self.arrCreatePostType.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == tblViewTags {
            
            let cellTag = tableView.dequeueReusableCell(withIdentifier: "CommandTableCell", for: indexPath) as! CommandTableCell
            
            cellTag.lblTitle.text = "#" + (self.Arraytags[indexPath.row]["name"] as? String)!
            cellTag.lblDes.text = String((self.Arraytags[indexPath.row]["post_count"] as? Int)!) + "post"
            cellTag.lblDes.textColor = UIColor.lightGray
            return cellTag
        }else {
            let cellTag = tableView.dequeueReusableCell(withIdentifier: "CreatePostTypeTableCell", for: indexPath) as! CreatePostTypeTableCell
            cellTag.lblTitle.text = arrCreatePostType[indexPath.row].rawValue
            cellTag.imgView.image = arrCreatePostType[indexPath.row].image
            return cellTag
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView == tblViewTags {
            self.viewTags.isHidden = true
            
            let textMain = String(self.commentTextView.text.prefix(self.rangeText.location + 1))
            
            var textArray = textMain.components(separatedBy: " ")
            textArray[textArray.count - 1] = "#" + (self.Arraytags[indexPath.row]["name"] as? String)!
            
            let valueMain = textArray.joined(separator: " ")
            
            
            self.commentTextView.text = valueMain + self.commentTextView.text!.substring(from: self.rangeText.location + 1, to: self.commentTextView.text!.count - 1)
        }else {
            
            switch arrCreatePostType[indexPath.row] {
            case .photo:
                
                guard let cell = tableView.cellForRow(at: indexPath) as? CreatePostTypeTableCell else { return }
                
                self.commentTextView.resignFirstResponder()
                FTPopOverMenu.show(forSender: cell.lblTitle, withMenuArray: ["Take a picture".localized() , "Upload".localized()], imageArray: nil, configuration: SharedManager.shared.configWithMenuStyle()) { (selectedIndex) in
                    let someBtn = UIButton()
                    if selectedIndex == 1 {
                        self.ImageUploadAction(sender: someBtn)
                    }else {
                        someBtn.tag = 200
                        self.cameraButtonClicked(someBtn)
                    }
                } dismiss: {
                }
                
            case .video:
                
                guard let cell = tableView.cellForRow(at: indexPath) as? CreatePostTypeTableCell else { return }
                
                self.commentTextView.resignFirstResponder()
                FTPopOverMenu.show(forSender: cell.lblTitle, withMenuArray: ["Record".localized() , "Upload".localized()], imageArray: nil, configuration: SharedManager.shared.configWithMenuStyle()) { (selectedIndex) in
                    let someBtn = UIButton()
                    if selectedIndex == 1 {
                        someBtn.tag = 100
                        self.ImageUploadAction(sender: someBtn)
                    }else {
                        someBtn.tag = 201
                        self.cameraButtonClicked(someBtn)
                    }
                } dismiss: {
                }
                
            case .audio:
                
                guard let cell = tableView.cellForRow(at: indexPath) as? CreatePostTypeTableCell else { return }
                
                self.commentTextView.resignFirstResponder()
                FTPopOverMenu.show(forSender: cell.lblTitle, withMenuArray: ["Record".localized() , "Upload".localized()], imageArray: nil, configuration: SharedManager.shared.configWithMenuStyle()) { (selectedIndex) in
                    
                    let someBtn = UIButton()
                    if selectedIndex == 1 {
                        self.openMusicAlbum()
                    }else {
                        someBtn.tag = 201
                        self.audioRecordOpen(sender: someBtn)
                    }
                } dismiss: {
                }
                
            case .file:
                
                self.commentTextView.resignFirstResponder()
                self.didPressDocumentShare()
                
            case .background:
                
                self.commentTextView.resignFirstResponder()
                let viewImageText = self.storyboard?.instantiateViewController(withIdentifier: "TextBackgroundController") as! TextBackgroundController
                viewImageText.delegate = self
                self.present(viewImageText, animated: true) {
                }
                
            }
        }
        
    }
}


extension String {
    func substring(from: Int?, to: Int?) -> String {
        if let start = from {
            guard start < self.count else {
                return ""
            }
        }

        if let end = to {
            guard end >= 0 else {
                return ""
            }
        }

        if let start = from, let end = to {
            guard end - start >= 0 else {
                return ""
            }
        }

        let startIndex: String.Index
        if let start = from, start >= 0 {
            startIndex = self.index(self.startIndex, offsetBy: start)
        } else {
            startIndex = self.startIndex
        }

        let endIndex: String.Index
        if let end = to, end >= 0, end < self.count {
            endIndex = self.index(self.startIndex, offsetBy: end + 1)
        } else {
            endIndex = self.endIndex
        }

        return String(self[startIndex ..< endIndex])
    }

    func substring(from: Int) -> String {
        return self.substring(from: from, to: nil)
    }

    func substring(to: Int) -> String {
        return self.substring(from: nil, to: to)
    }

    func substring(from: Int?, length: Int) -> String {
        guard length > 0 else {
            return ""
        }

        let end: Int
        if let start = from, start > 0 {
            end = start + length - 1
        } else {
            end = length - 1
        }

        return self.substring(from: from, to: end)
    }

    func substring(length: Int, to: Int?) -> String {
        guard let end = to, end > 0, length > 0 else {
            return ""
        }

        let start: Int
        if let end = to, end - length > 0 {
            start = end - length + 1
        } else {
            start = 0
        }

        return self.substring(from: start, to: to)
    }
}
