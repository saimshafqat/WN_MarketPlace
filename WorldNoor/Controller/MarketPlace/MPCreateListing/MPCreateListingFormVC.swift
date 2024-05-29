//
//  MPCreateListingFormVC.swift
//  WorldNoor
//
//  Created by Awais on 03/05/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit

class MPCreateListingFormVC: UIViewController {

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    
    @IBOutlet weak var tfTitle: FloatingLabelTextField!
    @IBOutlet weak var tfPrice: FloatingLabelTextField!
    @IBOutlet weak var tfCategory: FloatingLabelTextField!
    @IBOutlet weak var tfCondition: FloatingLabelTextField!
    @IBOutlet weak var tfDescription: UITextView!
    @IBOutlet weak var tfTags: FloatingLabelTextField!
    @IBOutlet weak var tfSKU: FloatingLabelTextField!
    @IBOutlet weak var tfAvailability: FloatingLabelTextField!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var vwAdditionalListing: UIStackView!
    @IBOutlet weak var btnAdditionalListing: UIButton!
    @IBOutlet weak var switchOfferDelivery: UISwitch!
    @IBOutlet weak var btnPublicMeetup: UIButton!
    @IBOutlet weak var btnDoorPickup: UIButton!
    @IBOutlet weak var btnDoorDropoff: UIButton!
    @IBOutlet weak var vwAdditionalListingOptions: UIView!
    @IBOutlet weak var vwOfferDelivery: UIView!
    @IBOutlet weak var vwPublicMeetup: UIView!
    @IBOutlet weak var vwDoorPickup: UIView!
    @IBOutlet weak var vwDoorDropoff: UIView!
    
    @IBOutlet weak var collectionView: UICollectionView!
        
    var selectedPhotos: [UIImage] = []
    var selectedAvailabilityItem: RadioButtonItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupTapGestures()
    }
    
    private func setupUI() {
        userImageView.roundTotally()
        userImageView.loadImageWithPH(urlMain: SharedManager.shared.mpUserObj?.profile_image ?? "")
        lblUserName.text = SharedManager.shared.mpUserObj?.name
        
        tfCategory.setOptionView(imageName: "mp_arrow_down")
        tfCondition.setOptionView(imageName: "mp_arrow_down")
        tfAvailability.setOptionView(imageName: "mp_arrow_down")
        
        tfDescription.addBorder()
        tfDescription.setBorderColorWhileEditing()
        tfDescription.addPlaceholder("Description")
        tfDescription.delegate = self
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.reloadData()
    }
    
    private func setupTapGestures() {
        
        vwAdditionalListingOptions.addTapGestureRecognizer { [weak self] in
            guard let self = self else { return }
            UIView.animate(withDuration: 0.5) {
                self.btnAdditionalListing.isSelected.toggle()
                self.vwAdditionalListing.isHidden.toggle()
            }
        }
        
        vwOfferDelivery.addTapGestureRecognizer { [weak self] in
            guard let self = self else { return }
            UIView.animate(withDuration: 0.5) {
                self.switchOfferDelivery.isOn.toggle()
            }
        }
        
        vwPublicMeetup.addTapGestureRecognizer { [weak self] in
            guard let self = self else { return }
            self.btnPublicMeetup.isSelected.toggle()
        }
        
        vwDoorPickup.addTapGestureRecognizer { [weak self] in
            guard let self = self else { return }
            self.btnDoorPickup.isSelected.toggle()
        }
        
        vwDoorDropoff.addTapGestureRecognizer { [weak self] in
            guard let self = self else { return }
            self.btnDoorDropoff.isSelected.toggle()
        }
    }
}

extension MPCreateListingFormVC {
    
    @IBAction func onClickCancelBtn(_ sender: UIButton) {
        dismissVC(completion: nil)
    }
    
    @IBAction func onClickPunlishBtn(_ sender: UIButton) {
        
    }
    
    @IBAction func onClickCategoryBtn(_ sender: UIButton) {
        
        let controller = MPCategoryListViewController.instantiate(fromAppStoryboard: .Marketplace)
        controller.isFromCreateListing = true
        
        controller.selectedCategory = { [weak self] category in
            guard let self = self else { return }
            self.tfCategory.text = category.name
        }
        
        openBottomSheet(controller, sheetSize: [.fixed(UIScreen.main.bounds.height * 0.7)], animated: false)
        
    }
    
    @IBAction func onClickConditionBtn(_ sender: UIButton) {
        
    }
    
    @IBAction func onClickLocationBtn(_ sender: UIButton) {
        
    }
    
    @IBAction func onClickAvailabilityBtn(_ sender: UIButton) {
        
        let controller = MPBottomAvailabilityVC.instantiate(fromAppStoryboard: .Marketplace)
        controller.selectedOptionId = selectedAvailabilityItem?.radioId ?? "1"
        controller.selectedOption = { [weak self] item in
            guard let self = self else { return }
            self.selectedAvailabilityItem = item
            self.tfAvailability.text = item.radioTitle
        }
        
        openBottomSheet(controller, sheetSize: [.fixed(270)], animated: false)
        
    }
    
}

extension MPCreateListingFormVC: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        textView.updatePlaceholder()
    }
}

extension MPCreateListingFormVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return min(selectedPhotos.count + 1, 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item < selectedPhotos.count {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MPSelectedPhotoCell", for: indexPath) as? MPSelectedPhotoCell {
                cell.photoImageView.image = selectedPhotos[indexPath.item]
                return cell
            }
        } else {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MPAddPhotoCell", for: indexPath) as? MPAddPhotoCell {
                
                return cell
            }
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = collectionView.frame.width
        let cvHeight = collectionView.frame.height
        let availableWidth = selectedPhotos.isEmpty ? screenWidth : (screenWidth / 3 - 10)
        
        return CGSize(width: availableWidth, height: cvHeight)
    }
}
