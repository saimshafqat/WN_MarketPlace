//
//  MPProductDetailMeetupMapCell.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 06/03/24.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit


protocol MPProductDetailInfoDelegate {
    func alertTapped(sender: UIButton, image: UIImageView)
    func shareTapped(sender: UIButton)
    func saveTapped(sender: UIButton, image: UIImageView)
    func messageTapped(sender: UIButton)
}

@objc(MPProductDetailInfoCell)
class MPProductDetailInfoCell: SSBaseCollectionCell {
    
    // MARK: - IBOutlets -
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var alertImageView: UIImageView!
    @IBOutlet weak var savedImageView: UIImageView!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var btnAlert: UIButton!
    @IBOutlet weak var sellerSMSImageView: UIImageView!
    
    // MARK: - Properties -
    var mpProductDetailInfoDelegate: MPProductDetailInfoDelegate?
    
    // MARK: - Override -
    override func configureCell(_ cell: Any!, atIndex thisIndex: IndexPath!, with object: Any!) {
        if let obj = object as? MarketPlaceForYouItem {
            headingLabel.text = obj.name
            priceLabel.text = obj.price
            setAlertBtn(obj)
            setAlertBtn(obj)
        }
    }
    
    // MARK: - IBActions -
    @IBAction func onClickSend(_ sender: UIButton) {
        
    }
    
    @IBAction func onClickAlertBtn(_ sender: UIButton) {
        mpProductDetailInfoDelegate?.alertTapped(sender: sender, image: alertImageView)
    }
    
    @IBAction func onClickMessageBtn(_ sender: UIButton) {
        mpProductDetailInfoDelegate?.messageTapped(sender: sender)
    }
    
    @IBAction func onClickShareBtn(_ sender: UIButton) {
        mpProductDetailInfoDelegate?.shareTapped(sender: sender)
    }
    
    @IBAction func onClickSaveBtn(_ sender: UIButton) {
        mpProductDetailInfoDelegate?.saveTapped(sender: sender, image: savedImageView)
    }
    
    // MARK: - Methods -
    func setAlertBtn(_ obj: MarketPlaceForYouItem) {
        btnSave.isSelected = obj.is_saved ?? false
        savedImageView.image = obj.is_saved ?? false ? .mpSaved : .mpUnsaved
    }
    
    func setSaveBtn(_ obj: MarketPlaceForYouItem) {
        btnAlert.isSelected = obj.is_alert_created ?? false
        alertImageView.image = obj.is_alert_created ?? false ? .mpAlertActive : .mpAlertDeactive
    }
}
