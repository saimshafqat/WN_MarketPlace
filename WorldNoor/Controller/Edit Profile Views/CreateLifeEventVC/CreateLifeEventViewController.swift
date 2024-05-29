//
//  CreateLifeEventViewController.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 27/12/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit
import TLPhotoPicker
import Photos
import AVKit
import Combine

class CreateLifeEventViewController: UIViewController {
    
    // MARK: - Properties -
    var lifeEventCategoryModel: LifeEventCategoryModel?
    var lifeEventSubCategoryModel: LifeEventSubCategoryModel?
    var isFromMainCategory: Bool = false
    var lifeEventType: LifeEventUIConfiguration? = nil
    let viewModel = CreatePostViewModel()
    var createLifeImgVideoList: [CreateLifeEventImageVideoModel] = []
    var userFriendList: [FriendModel] = []
    var apiService = APITarget()
    var subscription: Set<AnyCancellable> = []
    var selectedPatnerList = [FriendModel]()
    
    // MARK: - IBOutlets -
    @IBOutlet weak var schoolTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var schoolHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var schoolTypeTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var schoolTypeHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var locationTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var locationHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var partnerTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var partnerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var workSpaceTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var workspaceHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageVideoHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageVideoTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var imageVideoView: DesignableView!
    @IBOutlet weak var tfSchool: FloatingLabelTextField!
    @IBOutlet weak var tfEventTitle: FloatingLabelTextField!
    @IBOutlet weak var partnerView: DesignableView!
    @IBOutlet weak var tfPartner: UITextField!
    @IBOutlet weak var tfWorkspace: FloatingLabelTextField!
    @IBOutlet weak var tfLocation: FloatingLabelTextField!
    @IBOutlet weak var tvDescription: UITextView!
    @IBOutlet weak var tfdatePicker: DatePickerTextField!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var schoolTypeDropDown: SchoolTypeDropDown! {
        didSet {
            schoolTypeDropDown.dataSource = ["College", "High School"]
            schoolTypeDropDown.selectionHandler = { index, item in
                let itemStr = item as? String
                self.schoolTypeDropDown?.text = itemStr?.localized()
            }
        }
    }
    @IBOutlet weak var privacyDropDown: LifeEventPrivacyDropDown? {
        didSet {
            privacyDropDown?.dataSource = DDDataConfig.dataList
            privacyDropDown?.selectionHandler = { index, item in
                let itemStr = item as? String
                self.privacyDropDown?.text = itemStr?.localized()
            }
        }
    }
    
    // MARK: - Life Cycle -
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !isFromMainCategory {
            tfEventTitle.text = lifeEventSubCategoryModel?.description
        }
        lifeEventType = LifeEventUIConfiguration(rawValue: lifeEventCategoryModel?.name ?? .emptyString) ?? .unknown
        if let lifeEventType {
            updateUI(with: lifeEventType.configuration)
        }
        self.visibilityImageVideoView(isVisible: createLifeImgVideoList.count > 0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if lifeEventType == .relatinship {
            if SharedManager.shared.currentUserFriendList.count == 0 {
                getUserFriendList()
            } else {
                userFriendList = SharedManager.shared.currentUserFriendList
            }
        }
    }
    
    // MARK: - IBActions -
    @IBAction func onClickBack(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func onClickPicker(_ sender: UIButton) {
        presentUploadOptions()
    }
    
    @IBAction func onClickDone(_ sender: UIButton) {
        print(createLifeImgVideoList)
    }
    
    @IBAction func onClickPartnerCancel(_ sender: UIButton) {
        if tfPartner.text != .emptyString {
            tfPartner.text = .emptyString
        }
    }
    
    @IBAction func onClickPartner(_ sender: UIButton) {
        if self.userFriendList.count > 0 {
            self.showRelationPicker(Type: 2)
            return
        } else {
            Loader.startLoading()
        }
    }
    
    func presentUploadOptions() {
        let alertController = UIAlertController(title: nil, message: "Choose an option", preferredStyle: .actionSheet)
        let imageAction = UIAlertAction(title: "Upload Image", style: .default) { [weak self] _ in
            self?.presentImagePicker(mediaType: "public.image")
        }
        let videoAction = UIAlertAction(title: "Upload Video", style: .default) { [weak self] _ in
            self?.presentImagePicker(mediaType: "public.movie")
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(imageAction)
        alertController.addAction(videoAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
    
    private func presentImagePicker(mediaType: String = .emptyString) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = false
        picker.mediaTypes = [mediaType]
        present(picker, animated: true)
    }
    
    // MARK: - Methods -
    private func updateUI(with config: LifeEventUIConfiguration.UIConfiguration) {
        // top margin
        schoolTopConstraint.constant = config.schoolTopConstraint
        schoolTypeTopConstraint.constant = config.schoolTypeTopConstraint
        locationTopConstraint.constant = config.locationTopConstraint
        partnerTopConstraint.constant = config.partnerTopConstraint
        workSpaceTopConstraint.constant = config.workSpaceTopConstraint
        // constraint
        schoolHeightConstraint.constant = config.schoolHeightConstraint
        schoolTypeHeightConstraint.constant = config.schoolTypeHeightConstraint
        locationHeightConstraint.constant = config.locationHeightConstraint
        partnerHeightConstraint.constant = config.partnerHeightConstraint
        workspaceHeightConstraint.constant = config.workspaceHeightConstraint
        // hidden
        tfSchool.isHidden = config.isSchoolHidden
        schoolTypeDropDown.isHidden = config.isSchoolTypeDropDownHidden
        tfLocation.isHidden = config.isLocationHidden
        partnerView.isHidden = config.isPartnerHidden
        tfWorkspace.isHidden = config.isWorkspaceHidden
    }
    
    func visibilityImageVideoView(isVisible: Bool) {
        let animator = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut) {
            self.imageVideoTopConstraint.constant = isVisible ? 16 : 0
            self.imageVideoHeightConstraint.constant = isVisible ? 110 : 0
            self.imageVideoView.isHidden = !isVisible
            self.view.layoutIfNeeded()
        }
        animator.startAnimation()
    }
    
    func getUserFriendList() {
        let params: [String : String] = [:]
        Loader.startLoading()
        apiService.getUserFriendsRequest(endPoint: .getUserFriend(params))
            .sink(receiveCompletion: { completion in
                Loader.stopLoading()
                switch completion {
                case .finished:
                    LogClass.debugLog("Successfully Family RelationshipList")
                    Loader.stopLoading()
                case .failure(let error):
                    LogClass.debugLog("Unable RelationshipList.\(error.localizedDescription)")
                    Loader.stopLoading()
                }
            }, receiveValue: { response in
                Loader.stopLoading()
                LogClass.debugLog("Family RelationshipList Token Response ==> \(response)")
                self.userFriendList.removeAll()
                for index in response.data {
                    self.userFriendList.append(index)
                }
                SharedManager.shared.currentUserFriendList = response.data
            })
            .store(in: &subscription)
    }
    
    func showRelationPicker(Type : Int) {
        let controller = Pickerview.instantiate(fromAppStoryboard: .EditProfile)
        controller.isMultipleItem = false
        controller.isFromRelationship = true
        controller.type = Type
        controller.relationshipCompletion = { value, type in
            self.selectedPatnerList.removeAll()
            LogClass.debugLog("Value ==> \(value) and type ==> \(type)")
            let textarray = value.components(separatedBy: ",")
            for indexObj in textarray {
                for indexInner in self.userFriendList {
                    let name = (indexInner.firstname ?? .emptyString) + " " + ((indexInner.lastname ?? .emptyString))
                    if indexObj == name {
                        self.selectedPatnerList.append(indexInner)
                        self.tfPartner.text = name
                    }
                }
            }
        }
        controller.type = Type
        var arrayData = [String]()
        for indexObj in self.userFriendList {
            arrayData.append((indexObj.firstname ?? .emptyString) + " " + (indexObj.lastname ?? .emptyString))
        }
        var selectedRealtion = [String]()
        //        if type == 2 {
        //            let firstName = relationEditStatus?.user?.firstname ?? .emptyString
        //            let lastName = relationEditStatus?.user?.lastname ?? .emptyString
        //            let fullName = firstName + " " + lastName
        //            selectedRealtion.append(fullName)
        //        } else {
        //        }
        var arr: [String] = userFriendList.map({$0.username ?? .emptyString})
        arr.removeAll()
        userFriendList.forEach { freind in
            arr.append((freind.firstname ?? .emptyString) + " " + (freind.lastname ?? .emptyString))
        }
        controller.arrayMain = arr
        controller.selectedItems = selectedRealtion
        present(controller, animated: true)
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource -
extension CreateLifeEventViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return createLifeImgVideoList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellBottom = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: CreateLifeEventCell.self), for: indexPath) as! CreateLifeEventCell
        cellBottom.createLifeEventdelegate = self
        cellBottom.configureCell(object: createLifeImgVideoList[indexPath.item], indexPath: indexPath)
        return cellBottom
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Return the size as per your dynamic calculation
        return CGSize(width: 90, height: 90)
    }
}

extension CreateLifeEventViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Handle the selected image or video
        // var newObj = PostCollectionViewObject.init()
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            // let newObj = PostCollectionViewObject.init()
            // newObj.isType = PostDataType.Image
            // newObj.imageMain = pickedImage.compress(to: 100)
            // self.viewModel.selectedAssets.append(newObj)
            createLifeImgVideoList.insert(CreateLifeEventImageVideoModel(postType: .Image, image: pickedImage), at: 0)
            collectionView.insertItems(at: [IndexPath(item: 0, section: 0)])
            self.visibilityImageVideoView(isVisible: createLifeImgVideoList.count > 0)
            picker.dismiss(animated: true, completion: nil)
        } else if let _ = info[UIImagePickerController.InfoKey.mediaType] as? String,
                  // pickedVideo == (kUTTypeMovie as String),
                  let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
            //  newObj.isType = PostDataType.Video
            //  newObj.videoURL = url
            //  newObj = getNewCompressURL(url, with: newObj)
            //  newObj.langID = "1"
            //  newObj.imageMain = thumbnailForVideoAtURL(url: url as NSURL)?.compress(to: 100)
            //  self.viewModel.selectedAssets.append(newObj)
            let newImgVideObj = CreateLifeEventImageVideoModel(postType: .Video)
            newImgVideObj.videoURL = url
            CompressManager.shared.compressingVideoURLNEw(url: url) { compressURL in
                newImgVideObj.compressURL = compressURL
            }
            newImgVideObj.image = thumbnailForVideoAtURL(url: url as NSURL)
            createLifeImgVideoList.insert(newImgVideObj, at: 0)
            collectionView.insertItems(at: [IndexPath(item: 0, section: 0)])
            self.visibilityImageVideoView(isVisible: createLifeImgVideoList.count > 0)
            picker.dismiss(animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    private func thumbnailForVideoAtURL(url: NSURL) -> UIImage? {
        let asset = AVAsset(url: url as URL)
        let assetImageGenerator = AVAssetImageGenerator(asset: asset)
        var time = asset.duration
        time.value = min(time.value, 2)
        do {
            let imageRef = try assetImageGenerator.copyCGImage(at: time, actualTime: nil)
            return UIImage(cgImage: imageRef)
        } catch {
            return nil
        }
    }
}

// MARK: - CreateLifeEventDelegate -
extension CreateLifeEventViewController: CreateLifeEventDelegate {
    
    func deleteImageVideo(at indexPath: IndexPath) {
        self.createLifeImgVideoList.remove(at: indexPath.item)
        self.collectionView.reloadData()
        self.visibilityImageVideoView(isVisible: createLifeImgVideoList.count > 0)
    }
    
    func playVideo(at indexPath: IndexPath?, obj: CreateLifeEventImageVideoModel?) {
        if let indexPath {
            if obj?.postType == .Video {
                if let url = obj?.videoURL {
                    playVideo(from: url)
                }
            }
        }
    }
    
    // Function to play video from a given URL
    func playVideo(from url: URL) {
        let player = AVPlayer(url: url)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        self.present(playerViewController, animated: true) {
            playerViewController.player?.play()
        }
    }
}
