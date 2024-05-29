//
//  ShareViewController.swift
//  WorldnoorShare
//
//  Created by Raza najam on 7/6/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import UIKit
import Social
import Photos
import AVFoundation
import AVKit
import MobileCoreServices
import MediaPlayer
import SDWebImage

class ShareViewController: UIViewController, UIScrollViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate {
    var appearFrom:String = ""
    var isValidateView:Bool = true
    var notAudioBrowse:Bool = true
    var isLinkDetected:Bool = false
    var isPostEdit:Bool = false
    var keyboardHeight:CGFloat = 80.0
    var isSelected = -1
    let viewModel = SharePostViewModel()
    let playerViewController = AVPlayerViewController()
    var createPostDismissed : (([ShareCollectionViewObject]) -> Void)?
    var selectedOption:Int = -1
    var screenShotImageView: UIImageView?
    var lanaguageModelArray: [LanguageModel] = [LanguageModel]()
    var selectedLangModel:LanguageModel?
    let viewLanguageModel = ShareLanguageViewModel()
    var musicPlayer:MPMediaPickerController?
    var selectedPrivacyString = "public"
    var selectedPrivacyIDs:[Int:String] = [:]
    var langController:SharePrivacyController? = nil
    var langSelectionController:ShareLanguageController? = nil
    
    var destinationPath = URL(fileURLWithPath: NSTemporaryDirectory())
    let audioSettings = [
        AVFormatIDKey: kAudioFormatMPEG4AAC,
        AVNumberOfChannelsKey: 2,
        AVSampleRateKey: 44100,
        AVEncoderBitRateKey: 128000
    ]
    @IBOutlet weak var privacyBtn: UIButton!
    @IBOutlet weak var postCollectionView: UICollectionView!
    @IBOutlet weak var bottomCollectionView: UICollectionView!
    @IBOutlet weak var commentHeightConst: NSLayoutConstraint!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var userImageView: DesignableImageView!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var descriptionView: DesignableView!
    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var crossBtn: UIButton!
    @IBOutlet weak var progressCustomView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let isUserObj:User = Shared.instance.getProfile() {
            Shared.instance.userObj = isUserObj
            self.manageData()
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
            self.userNameLbl.text = Shared.instance.getFullName()
            self.userImageView.sd_setImage(with: URL(string: Shared.instance.getProfileImage() ), placeholderImage: UIImage(named: "placeholder.png"))
//            self.labelRotateCell(viewMain: self.userImageView)
            self.manageKeyboard()
            self.manageViewModelHandler()
            self.manageHandler()
            self.navigationController?.isNavigationBarHidden = true
        }else {
            
            
            let alert = UIAlertController(title: Const.AppName, message: "Please login to share image/video in WorldNoor", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: Const.accept, style: .default, handler: { action in
                
                self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)

            }))
            self.present(alert, animated: true, completion: nil)

        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //        postCollectionView.collectionViewLayout.invalidateLayout()
        //        bottomCollectionView.collectionViewLayout.invalidateLayout()
        //        self.isValidateView = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if(self.isValidateView){
            self.isValidateView = false
            postCollectionView.collectionViewLayout.invalidateLayout()
            bottomCollectionView.collectionViewLayout.invalidateLayout()
        }
    }
    
    func manageData() {
        //Data Types
        

        
        
        self.showIndicator(message: "Loading...")
        let typeImage = kUTTypeImage as String
        let typeText = kUTTypeText as String
        let typeUrl = kUTTypeURL as String
        let typeMPEG = kUTTypeMPEG as String
        let typeMPEG2 = kUTTypeMPEG2Video as String
        let typeMPEG4 = kUTTypeMPEG4 as String
        let typeMovie = kUTTypeMovie as String
        let typeGalleryVideo = kUTTypeVideo as String
        let typePdf = kUTTypePDF as String
        
        for item in extensionContext!.inputItems {
            guard let item = item as? NSExtensionItem else {
                continue
            }
            for itemProvider in item.attachments ?? [] {
                let newObject = ShareCollectionViewObject()
                if itemProvider.hasItemConformingToTypeIdentifier(typeMPEG4) {

                    itemProvider.loadItem(
                        forTypeIdentifier: typeMPEG4,
                        options: nil,
                        completionHandler: { url, error in
                            if let url = url as? URL {

                                newObject.isType = PostDataType.Video
                                newObject.videoURL = url
                                newObject.imageMain = Shared.instance.videoSnapshot(filePathLocal: url)
                                self.viewModel.selectedAssets.append(newObject)
//                                self.compressingVideo(url: url)

                            }
                        })
                } else if itemProvider.hasItemConformingToTypeIdentifier(typeImage) {
                    //                    DispatchQueue.main.asyncAfter(deadline: .now()) {
                    itemProvider.loadItem(forTypeIdentifier: typeImage, options: nil) { (data, error) in
                        if let image = data as? UIImage {

                            guard let compressedImage = self.viewModel.compressImage(image) else {return}
                            let imgUrl = self.viewModel.saveFileToDocumentDirectory(image: compressedImage)
                            newObject.isType = PostDataType.Image
                            newObject.imageMain = compressedImage
                            newObject.imageUrl = imgUrl?.path ?? ""
                            self.viewModel.selectedAssets.append(newObject)
                        } else {
                            if error == nil, let url = data as? URL {
                                do {
                                    let rawData = try Data(contentsOf: url)
                                    let rawImage = UIImage(data: rawData)
                                    guard let compressedImage = self.viewModel.compressImage(rawImage) else {return}
                                    newObject.isType = PostDataType.Image
                                    newObject.imageMain = compressedImage
                                    //                                        newObject.imageUrl = url
                                    self.viewModel.selectedAssets.append(newObject)

                                } catch let exp {
                                }
                            } else {
                                Shared.instance.showAlert(message: "Error loading Image.", view: self)
                            }
                        }
                    }
                    //                    }
                } else if itemProvider.hasItemConformingToTypeIdentifier(typeText) {
                    itemProvider.loadItem(forTypeIdentifier: typeText, options: nil) { (data, error) in
                        if error == nil, let text = data as? String {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                self.commentTextView.text = text
                                self.commentTextView.textColor = UIColor.black
                            }
                        }
                    }
                } else if itemProvider.hasItemConformingToTypeIdentifier(typePdf) {
                    itemProvider.loadItem(forTypeIdentifier: kUTTypePDF as String, options: nil) { (data, error) in
                        if error == nil, let url = data as? URL {
                            newObject.isType = PostDataType.Attachment
                            newObject.fileUrl = url.path
                            newObject.videoURL = url
                            self.viewModel.selectedAssets.append(newObject)
                        }
                    }
                }else if itemProvider.hasItemConformingToTypeIdentifier(typeUrl) {
                    itemProvider.loadItem(forTypeIdentifier: typeUrl, options: nil) { (data, error) in
                        if error == nil, let url = data as? URL {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                self.commentTextView.text = String(format: "%@",url.absoluteString)
                                self.commentTextView.textColor = UIColor.black
                            }
                        }
                    }
                } else if itemProvider.hasItemConformingToTypeIdentifier(typeMPEG) {
                    itemProvider.loadItem(forTypeIdentifier: typeMPEG, options: nil) { (data, error) in
                        if error == nil, let url = data as? URL {
                            self.compressingVideo(url: url)

                        }
                    }
                } else if itemProvider.hasItemConformingToTypeIdentifier(typeMPEG2) {
                    itemProvider.loadItem(forTypeIdentifier: typeMPEG2, options: nil) { (data, error) in
                        if error == nil, let url = data as? URL {
                            self.compressingVideo(url: url)

                        }
                    }
                } else if itemProvider.hasItemConformingToTypeIdentifier(typeMovie) {
                    DispatchQueue.main.asyncAfter(deadline: .now()) {
                        itemProvider.loadItem(forTypeIdentifier: typeMovie, options: nil) { (data, error) in
                            if error == nil, let url = data as? URL {
                                let asset = AVAsset(url: url)
                                self.destinationPath = self.destinationPath.appendingPathComponent(String(format:"%@compressed.mp4", Shared.instance.getIdentifierForMessage()))


                                self.compressingVideo(url: url)

                            }
                        }
                    }
                } else if itemProvider.hasItemConformingToTypeIdentifier(typeGalleryVideo) {
                    itemProvider.loadItem(forTypeIdentifier: typeGalleryVideo, options: nil) { (data, error) in
                        if error == nil, let url = data as? URL {
                           
                        }
                    }
                }
                
            }
        }
        self.reloadCollectionData()
    }
    
    func reloadCollectionData(){
     
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.bottomCollectionView.reloadData()
            self.postCollectionView.reloadData()
            self.hideLoader()
        }
    }
    
    @IBAction func managePrivacyOption(){
        langController = AppStoryboard.MainInterface.instance.instantiateViewController(withIdentifier: "SharePrivacyController") as? SharePrivacyController
        langController!.delegate = self
        langController!.selectedPrivacyName = self.selectedPrivacyString
        langController!.editContactID = self.selectedPrivacyIDs
        self.present(langController!, animated: false, completion: nil)
    }
    
    func manageHandler(){
        
        SharePostHandler.shared.showLangSelectionHandler = { [weak self] (currentIndex) in
            self?.langSelectionController = AppStoryboard.MainInterface.instance.instantiateViewController(withIdentifier: "ShareLanguageController") as? ShareLanguageController
            self?.langSelectionController?.currentIndex = currentIndex
            self?.langSelectionController!.delegate = self
            self?.present((self?.langSelectionController!)!, animated: false, completion: nil)
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
    
    func manageKeyboard(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),name: UIResponder.keyboardWillShowNotification,object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            self.keyboardHeight = keyboardRectangle.height + 150
        }
    }
    
    func manageTextView(){
        self.commentTextView.textColor = UIColor.lightGray
        self.commentTextView.text = Const.textCreatePlaceholder
    }
    
    @IBAction func crossButtonTapped(_ sender: Any) {
        self.commentTextView.resignFirstResponder()
        self.topBarView.isHidden=false
        self.bottomCollectionView.isHidden=false
        self.descriptionView.isHidden=false
        self.crossBtn.isHidden=true
    }
    
    @IBAction func createPostBtnClicked(_ sender: Any) {
        self.commentTextView.resignFirstResponder()
        self.callingCreatePostService()
    }
    
    @objc func LoadAudio(sender : UIButton){
        isSelected = sender.tag
        let player = AVPlayer(url: self.viewModel.selectedAssets[sender.tag].videoURL)
        self.playerViewController.player = player
        self.present(self.playerViewController, animated: true) {
            self.playerViewController.player!.play()
        }
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
    
    func manageAlreadyUploadedContent() {
        self.viewModel.newAssets = []
        self.viewModel.oldAssets = []
        for postObj in self.viewModel.selectedAssets {
            self.viewModel.newAssets.append(postObj)
            
        }
    }
    
    func showIndicator(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        if #available(iOSApplicationExtension 13.0, *) {
            loadingIndicator.style = UIActivityIndicatorView.Style.medium
        }
        loadingIndicator.startAnimating()
        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
    }
    
    func hideLoader() {
        dismiss(animated: true, completion: nil)
    }
    
    func callingCreatePostService()
    {
        let userToken = Shared.instance.userObj!.data.token
        if self.commentTextView.text == "Write what you wish."   {
            self.commentTextView.text = ""
            if self.viewModel.selectedAssets.count == 0 {
                Shared.instance.showAlert(message: "Please enter your message.", view: self)
                return
            }
        }
        if (SharePostHandler.shared.checkIfLanguageSelected(postArray: self.viewModel.selectedAssets)){
            Shared.instance.showAlert(message: Const.languageSelectionAlert, view: self)
            return
        }
        var parameters = ["action": "post/create","api_token": userToken,"body":commentTextView.text!, "multiple_uploads":"true","type":"create_post"]
        self.showIndicator(message: "Sending...")
        self.manageAlreadyUploadedContent()
        if(SharePostHandler.shared.checkIfFileExist(postArray: self.viewModel.newAssets)) {
            parameters["action"] = "upload"
            parameters["serviceType"] = "Media"
            SharedRequestManager.uploadMultipartRequest( params: parameters as! [String : String],fileObjectArray: self.viewModel.newAssets,success: {
                (JSONResponse) -> Void in
                let respDict = JSONResponse
                if let dict = respDict["meta"] as? NSDictionary {
                    let meta = dict
                    let code = meta["code"] as! Int
                    if code == ResponseKey.successResp.rawValue {
                        self.managePostCreateService(resp: respDict["data"] as! NSArray)
                    }
                }
            },failure: {(error) -> Void in
                self.hideLoader()
               
            })
        }else {
            self.managePostCreateService(resp: [], isFileExist: false)
        }
    }
    
    func managePostCreateService(resp:NSArray, isFileExist:Bool = true)  {
        let userToken:String = Shared.instance.userObj!.data.token!
        let createPostObj = ShareCollectionViewObject.init()
        var postObj:[ShareCollectionViewObject] = [ShareCollectionViewObject]()
        if isFileExist {
            postObj = createPostObj.getPostData(respArray: resp)
        }else {
            postObj = self.viewModel.newAssets
        }
        postObj.append(contentsOf: self.viewModel.oldAssets)
        var parameters = ["action": "post/create","token": userToken,"body":commentTextView.text!, "privacy_option":self.selectedPrivacyString]
        if self.selectedPrivacyIDs.count > 0 {
            var counter = 0
            for (_,v) in self.selectedPrivacyIDs {
                let key = String(format: "contact_group_ids[%i]", counter)
                parameters[key] = v
                counter = counter + 1
            }
        }

        SharedRequestManager.uploadMultipartCreateRequests( params: parameters ,fileObjectArray: postObj,success: {
            (JSONResponse) -> Void in
            let respDict = JSONResponse
            let meta = respDict["meta"] as! NSDictionary
            let code = meta["code"] as! Int
            if code == ResponseKey.successResp.rawValue {
                FileBasedManager.shared.clearTmpDirectory()
                if(SharePostHandler.shared.checkIfVideoExist(postArray: self.viewModel.newAssets)){
                    self.manageProcessFileService(postObj: postObj)
                }else {
                    self.hideLoader()
                    self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
                    
                }
            }
        },failure: {(error) -> Void in
            self.hideLoader()
        }, isShowProgress: !isFileExist)
    }
    
    func manageProcessFileService(postObj:[ShareCollectionViewObject])  {
        self.perform(#selector(dismissMyController), with: nil, afterDelay: 3)
        let userToken = Shared.instance.userObj!.data.token
        let parameters = ["action": "process-file","api_token": userToken, "serviceType":"Media", "processVideoAsWell":"true"]
        SharedRequestManager.uploadMultipartProcessFileRequests( params: parameters as! [String : String],fileObjectArray: postObj,success: {
            (JSONResponse) -> Void in
            let respDict = JSONResponse
        },failure: {(error) -> Void in
          
        })
    }
    
    @objc func dismissMyController()  {
        self.dismiss(animated: true, completion: nil)
        self.hideLoader()
        self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
        
    }
    
    @IBAction func cancelButtonClicked(_ sender: Any) {
        //        self.removeAllfiles()
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}

extension ShareViewController:UICollectionViewDataSource, UICollectionViewDelegate   {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel.selectedAssets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView.tag == 500 {
            let cellBottom = collectionView.dequeueReusableCell(withReuseIdentifier: "BottomCreatePostCell", for: indexPath) as! BottomCreatePostCell
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
                }else if urlmain.last == "doc" || urlmain.last == "docx"{
                    cellBottom.createPostView?.myImageView.image = UIImage.init(named: "WordFileS.png")
                }else if urlmain.last == "xls" || urlmain.last == "xlsx"{
                    cellBottom.createPostView?.myImageView.image = UIImage.init(named: "ExcelIconS.png")
                }else if  urlmain.last == "zip"{
                    cellBottom.createPostView?.myImageView.image = UIImage.init(named: "ZipIconS.png")
                }else if  urlmain.last == "pptx"{
                    cellBottom.createPostView?.myImageView.image = UIImage.init(named: "pptIconS.png")
                }else {
                    cellBottom.createPostView?.myImageView.image = UIImage.init(named: "PDFIconS.png")
                }
            }else if newObj.isType == PostDataType.Image {
                if newObj.imageMain != nil {
                    cellBottom.createPostView?.myImageView.image = newObj.imageMain
                }else {
                    
                    //                        cellBottom.createPostView?.myImageView.image = self.getSelectedItem(asset: newObj.assetMain)
                    self.viewModel.selectedAssets[indexPath.row].imageMain = cellBottom.createPostView?.myImageView.image
                    
                }
            }else if newObj.isType == PostDataType.GIFBrowse {
                cellBottom.createPostView?.myImageView.sd_setImage(with:newObj.photoUrl, placeholderImage: UIImage(named: "placeholder.png"))
//                self.labelRotateCell(viewMain: cellBottom.createPostView?.myImageView)
            }else if newObj.isType == PostDataType.GIF {
                if newObj.imageMain != nil {
                    cellBottom.createPostView?.myImageView.image = newObj.imageMain
                }else {
                    //                    cellBottom.createPostView?.myImageView.image = self.getSelectedItem(asset: newObj.assetMain)
                    self.viewModel.selectedAssets[indexPath.row].imageMain = cellBottom.createPostView?.myImageView.image
                }
            }
            else if newObj.isType == PostDataType.imageText {
                if newObj.imageMain != nil {
                    cellBottom.createPostView?.myImageView.image = newObj.imageMain
                }
            }
            else if newObj.isType == PostDataType.Audio
            {
                cellBottom.createPostView?.viewPlayButton.isHidden = false
                cellBottom.createPostView?.myImageView.image = UIImage(named: "GalleryBgImage.png")
                cellBottom.createPostView?.viewPlayButton.isHidden = false
                cellBottom.createPostView?.buttonPly.tag = indexPath.row
            }else if newObj.isType == PostDataType.AudioMusic
            {
                cellBottom.createPostView?.viewPlayButton.isHidden = false
                cellBottom.createPostView?.myImageView.image = UIImage(named: "GalleryBgImage.png")
                cellBottom.createPostView?.viewPlayButton.isHidden = false
                cellBottom.createPostView?.buttonPly.tag = indexPath.row
            }
            else if newObj.isType == PostDataType.Video {
                cellBottom.createPostView?.viewPlayButton.isHidden = false
                cellBottom.createPostView?.buttonPly.tag = indexPath.row
                if newObj.imageMain != nil {
                    cellBottom.createPostView?.myImageView.image = newObj.imageMain
                }else {
                    
                    // cellBottom.createPostView?.myImageView.image = self.getSelectedItem(asset: newObj.assetMain)
                    self.viewModel.selectedAssets[indexPath.row].imageMain = cellBottom.createPostView?.myImageView.image
                }
            }
            cellBottom.createPostView?.viewButton.isHidden = false
            cellBottom.createPostView?.buttonDelete.tag = indexPath.row
            cellBottom.createPostView?.buttonDelete.addTarget(self, action: #selector(self.DeleteImage), for: .touchUpInside)
            return cellBottom
        }
        else {
            let cell = collectionView
                .dequeueReusableCell(withReuseIdentifier: ShareCollectionViewCell.identifier, for: indexPath) as! ShareCollectionViewCell
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
                }
            }else if newObj.isType == PostDataType.GIFBrowse {
                cell.createPostView?.myImageView.sd_setImage(with:newObj.photoUrl, placeholderImage: UIImage(named: "placeholder.png"))
//                self.labelRotateCell(viewMain: cell.createPostView?.myImageView)
            }else if newObj.isType == PostDataType.GIF {
                if newObj.imageMain != nil {
                    cell.createPostView!.myImageView.image = newObj.imageMain
                }else {
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
                cell.createPostView?.buttonPly.addTarget(self, action: #selector(self.LoadAudio), for: .touchUpInside)
                cell.createPostView?.buttonPly.tag = indexPath.row
                
            }else if newObj.isType == PostDataType.AudioMusic
            {
                showLangBar = true
                cell.createPostView?.viewPlayButton.isHidden = false
                cell.createPostView?.myImageView.image = UIImage(named: "GalleryBgImage.png")
                cell.createPostView?.viewPlayButton.isHidden = false
                cell.createPostView?.buttonPly.removeTarget(self, action: #selector(self.PlayAction), for: .touchUpInside)
                cell.createPostView?.buttonPly.addTarget(self, action: #selector(self.LoadAudio), for: .touchUpInside)
                cell.createPostView?.buttonPly.tag = indexPath.row
                
            }
            else if newObj.isType == PostDataType.Video {
                showLangBar = true
                cell.createPostView?.viewPlayButton.isHidden = false
                cell.createPostView?.buttonPly.removeTarget(self, action: #selector(self.LoadAudio), for: .touchUpInside)
                cell.createPostView?.buttonPly.addTarget(self, action: #selector(self.PlayAction), for: .touchUpInside)
                cell.createPostView?.buttonPly.tag = indexPath.row
                if newObj.imageMain != nil {
                    cell.createPostView?.myImageView.image = newObj.imageMain
                }else {
                    self.viewModel.selectedAssets[indexPath.row].imageMain = cell.createPostView?.myImageView.image
                }
            }
            cell.manageImageData(indexValue: indexPath.row,cellSize:self.postCollectionView.frame, showLangBar: showLangBar, index: indexPath, newObj:newObj)
            cell.createPostView?.viewButton.isHidden = true
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.crossBtn.isHidden=true
        var value:Bool = true
        self.commentTextView.resignFirstResponder()
        if collectionView.tag != 500
        {
            if self.topBarView.isHidden {
                value = false
            }
            self.hideOrShowAnimated(value: value, btn: self.topBarView)
            self.hideOrShowAnimated(value: value, btn: self.descriptionView)
            self.hideOrShowAnimated(value: value, btn: self.bottomCollectionView)
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
        if self.viewModel.selectedAssets.count == 0 {
            self.commentHeightConst.constant = 40
        }
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

extension ShareViewController:UITextViewDelegate   {
    
    func giveCommentTextViewHeight(){
        let frame = Shared.instance.getTextViewSize(textView: self.commentTextView)
        let actualSize = ((self.view.frame.size.height) - self.keyboardHeight)
        if frame.size.height < actualSize   {
            self.commentTextView.isScrollEnabled = false
            self.commentHeightConst.constant = frame.size.height
        }else {
            self.commentHeightConst.constant = actualSize
            self.commentTextView.isScrollEnabled = true
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if self.commentTextView.textColor == UIColor.lightGray {
            self.commentTextView.text = nil
            self.commentTextView.textColor = UIColor.black
        }
        let frame = Shared.instance.getTextViewSize(textView: textView)
        let actualSize = ((self.view.frame.size.height) - self.keyboardHeight)
        if frame.size.height < actualSize   {
            self.commentTextView.isScrollEnabled = false
            self.commentHeightConst.constant = frame.size.height
        }else {
            self.commentHeightConst.constant = actualSize
            self.commentTextView.isScrollEnabled = true
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if self.commentTextView.text.isEmpty {
            self.commentTextView.text = Const.textCreatePlaceholder
            self.commentTextView.textColor = UIColor.lightGray
        }
        if self.viewModel.selectedAssets.count > 0 {
            self.commentHeightConst.constant = 40
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let fixedWidth = textView.frame.size.width
        textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        var newFrame = textView.frame
        newFrame.size = CGSize(width: max(fixedWidth, fixedWidth), height: newSize.height)
        if newFrame.size.height < ((self.view.frame.size.height) - self.keyboardHeight)   {
            self.commentTextView.isScrollEnabled = false
            self.commentHeightConst.constant = newFrame.size.height
        }else {
            self.commentTextView.isScrollEnabled = true
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return true
    }
}

extension ShareViewController:PrivacyOptionDelegate {
    func privacyOptionSelected(type:String, keyPair:String) {
        self.langController?.dismiss(animated: true, completion: nil)
        self.selectedPrivacyString = keyPair
        self.privacyBtn.setTitle(type, for: .normal)
    }
    
    func privacyOptionCategorySelected(type:String, catID:[Int:String]) {
        self.langController?.dismiss(animated: true, completion: nil)
        self.privacyBtn.setTitle("Contact Groups", for: .normal)
        self.selectedPrivacyString = type
        self.selectedPrivacyIDs = catID
    }
}

extension ShareViewController:ShareLanguageSelectionDelegate {
    func lanaguageSelected(langObj: LanguageModel, indexPath: IndexPath) {
        self.langSelectionController?.dismiss(animated: true, completion: nil)
        let createPostObj:ShareCollectionViewObject =  (self.viewModel.selectedAssets[indexPath.row])
        createPostObj.langID = langObj.languageID
        createPostObj.langName = langObj.languageName
        self.viewModel.selectedAssets[indexPath.row] = createPostObj
        let cell = self.postCollectionView.cellForItem(at: indexPath) as! ShareCollectionViewCell
        cell.manageLanguage(langName: langObj.languageName)
    }
    
    func compressingVideo(url:URL){
        let newObject = ShareCollectionViewObject()
        let destinationPath = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("compressed" + UUID().uuidString + ".mp4")

        let videoCompressor = LightCompressor()
        let _: Compression = videoCompressor.compressVideo(
            source: url,
            destination: destinationPath as URL,
            quality: .low,
            isMinBitRateEnabled: false,
            keepOriginalResolution: false,
            progressQueue: .main,
            progressHandler: { progress in
                // progress
            },
            completion: {[weak self] result in
                guard self != nil else { return }
                
                switch result {
                case .onSuccess(let path):
                    newObject.imageMain = Shared.instance.videoSnapshot(filePathLocal: url)
                    newObject.isType = PostDataType.Video
                    newObject.videoURL = path
                    self?.viewModel.selectedAssets.append(newObject)
                    guard let data = try? Data(contentsOf: path) else {
                        return
                    }
                    self?.reloadCollectionData()
                    break
                // success
                
                case .onStart: break
                // when compression starts
                
                case .onFailure(let error):
                    break
                // failure error
                
                case .onCancelled: break
                // if cancelled
                }
            }
        )
    }
    
}
