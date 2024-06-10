//
//  MPProductDetailViewController.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 06/03/24.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit
import Alamofire
import CoreLocation

protocol MPProductDetailDelegate {
    func updateSaved(product: MarketPlaceForYouItem?)
}

class MPProductDetailViewController: UIViewController {
    
    // MARK: - Properties -
    var marketProduct: MarketPlaceForYouItem?
    var productDetailModel:  MPProductDetailModel?
    var viewHelper = MarketPlaceProductDetailViewHelper()
    var mpProductDetailDelegate: MPProductDetailDelegate?
    var mpSellerDetailDelegate: MPSellerDetailDelegate?
    lazy var dataSource: SSSectionedDataSource? = {
        let ds = SSSectionedDataSource(sections: [])
        return ds
    }()
    
    @IBOutlet weak var collectionView: UICollectionView?
    
    // MARK: - Life Cycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        updateSection()
        configureView()
        callRequestForProductDetail()
    }
    
    // MARK: - IBActions -
    @IBAction func onClickBack(_ sender: UIButton) {
        mpProductDetailDelegate?.updateSaved(product: marketProduct)
        popTransition(withAnimationType: .fade, animated: true)
    }
    
    func setupCollectionView() {
        collectionView?.register(header: MPProductDetailHeaderView.self)
        collectionView?.delegate = self
        viewHelper.dataSource = self.dataSource
        collectionView?.collectionViewLayout = viewHelper.compositionalLayout()
    }
    
    func configureView() {
        dataSource?.cellCreationBlock = { object, parentView, index in
            let currentSection = self.dataSource?.section(at: index?.section ?? 0)
            var clazzInstance: SSBaseCollectionCell.Type
            let currentValue = currentSection?.sectionIdentifier as? String
            if currentValue == SectionIdentifier.images.type {
                clazzInstance = MPProductImageCollectionCell.self
            } else if currentValue == SectionIdentifier.productInfo.type {
                clazzInstance = MPProductDetailInfoCell.self
            } else if currentValue == SectionIdentifier.sellerInformation.type {
                clazzInstance = MPProductDetailSellerInfoCell.self
            } else if currentValue == SectionIdentifier.produceDescription.type {
                clazzInstance = MPProductDetailDesctiptionCell.self
            } else if currentValue == SectionIdentifier.productDetailCondition.type {
                clazzInstance = MPProductDetailConditionCell.self
            } else if currentValue == SectionIdentifier.productMapMeet.type {
                clazzInstance = MPProductDetailMeetupMapCell.self
            } else if currentValue == SectionIdentifier.similarProduct.type {
                clazzInstance = MPProductDetailSimilarProductCell.self
            } else if currentValue == SectionIdentifier.productGroup.type {
                clazzInstance = MPProductDetailGroupCell.self
            } else {
                clazzInstance = MPProductDetailRelatedProductCell.self
            }
            return clazzInstance.init(for: parentView as? UICollectionView, indexPath: index)
        }
        dataSource?.cellConfigureBlock = { cell, object, _, indexPath in
            (cell as? SSBaseCollectionCell)?.configureCell(nil, atIndex: indexPath, with: object)
            (cell as? SSBaseCollectionCell)?.layoutIfNeeded()
            if cell is MPProductDetailInfoCell {
                (cell as? MPProductDetailInfoCell)?.mpProductDetailInfoDelegate = self
            }
        }
        dataSource?.cellConfigureBlock = { cell, object, _, indexPath in
            (cell as? SSBaseCollectionCell)?.configureCell(nil, atIndex: indexPath, with: object)
            (cell as? SSBaseCollectionCell)?.layoutIfNeeded()
            if cell is MPProductDetailSellerInfoCell {
                (cell as? MPProductDetailSellerInfoCell)?.mpSellerDetailDelegate = self
            }
        }
        dataSource?.collectionViewSupplementaryElementClass = MPProductDetailHeaderView.self
        dataSource?.collectionSupplementaryConfigureBlock = { view, kind, cv, indexPath in
            let section = self.dataSource?.section(at: indexPath?.section ?? 0) as? SectionInfo
            (view as? MPProductDetailHeaderView)?.configureView(obj: section, parentObj:  nil, indexPath: indexPath ?? IndexPath())
        }
        dataSource?.rowAnimation = .automatic
        dataSource?.collectionView = collectionView
    }
    
    func updateSection() {
        if marketProduct?.images.count ?? 0 > 0 {
            let item = marketProduct?.images as? [AnyObject]
            configureSection(.images, object: item, sortOrder: 0)
        }
        if !(marketProduct?.name.isEmpty ?? true) || !(marketProduct?.price.isEmpty ?? true) {
            let item = [marketProduct] as? [AnyObject]
            configureSection(.productInfo, object: item, sortOrder: 1)
        }
        if !(productDetailModel?.data.product.description.isEmpty ?? true) {
            let item = [productDetailModel?.data] as? [AnyObject]
            configureSection(.produceDescription, object: item, sortOrder: 2)
        }
        if productDetailModel?.data.product.user != nil {
            let item = [productDetailModel?.data.product] as? [AnyObject]
            configureSection(.sellerInformation, object: item, sortOrder: 3)
        }
        if productDetailModel?.data.product.condition != nil || !(productDetailModel?.data.product.condition.isEmpty ?? true) {
            let item = [productDetailModel?.data.product] as? [AnyObject]
            configureSection(.productDetailCondition, object: item, sortOrder: 4)
        }
        if !(productDetailModel?.data.product.lat.isEmpty ?? true) && !(productDetailModel?.data.product.lng.isEmpty ?? true) {
            let item = [productDetailModel?.data.product] as? [AnyObject]
            configureSection(.productMapMeet, object: item, sortOrder: 5)
        }
        if productDetailModel?.data.product.similarProducts?.count ?? 0 > 0 {
            configureSection(.similarProduct, object: productDetailModel?.data.product.similarProducts as? [AnyObject], sortOrder: 6)
        }
        if productDetailModel?.data.product.groups?.count ?? 0 > 0 {
            configureSection(.productGroup, object: productDetailModel?.data.product.groups as? [AnyObject], sortOrder: 7)
        }
        if productDetailModel?.data.product.relatedProducts?.count ?? 0 > 0 {
            configureSection(.relatedProduct, object: productDetailModel?.data.product.relatedProducts as? [AnyObject], sortOrder: 8)
        }
    }
    
    func configureSection(_ identifier: SectionIdentifier, object: [AnyObject]?, sortOrder: Int) {
        var section = dataSource?.section(withIdentifier: identifier.type)
        if section == nil {
            section = customSection(object, identifier: identifier, sortOrder: sortOrder)
            dataSource?.appendSection(section)
            sortingSection()
        }
    }
    
    func customSection(_ item: [AnyObject]?, identifier: SectionIdentifier, sortOrder: Int = 0) -> SSSection? {
        return SectionInfo.section(withItems: item, header: nil, identifier: identifier.type, sortId: sortOrder)
    }
    
    // will sort section after update
    func sortingSection() {
        let sections = self.dataSource?.sections as? [SectionInfo]
        guard sections?.count ?? 0 > 1 else { return }
        if let sections {
            let sortedList = sections.sorted(by: {$0.sortId < $1.sortId})
            for (newIndex, item) in sortedList.enumerated() {
                print(newIndex, item)
                let oldIndex = sections.firstIndex(where: {$0 === item})
                if oldIndex != nil && oldIndex != newIndex {
                    self.dataSource?.moveSection(at: oldIndex ?? 0, to: newIndex)
                    if compare(sortedList, sections) {
                        break
                    }
                }
            }
        }
    }
    
    // it will compare section if both list will be same it will return true otherwise will return false and then we don't need to continue process
    func compare(_ sorted: [SectionInfo], _ unsorted: [SectionInfo]) -> Bool {
        return unsorted.count == sorted.count && sorted == unsorted.sorted(by: {$0.sortId < $1.sortId})
    }
    
    func callRequestForProductDetail() {
        
        let productId = marketProduct?.id ?? 0
        let params: [String : Any] = ["id": "\(productId)", "user_id": 9]
        
        MPRequestManager.shared.request(endpoint: "product_detail", method: .post, params: params) { response in
            switch response {
            case .success(let data):
                LogClass.debugLog("success")
                if let jsonData = data as? Data {
                    do {
                        let decoder = JSONDecoder()
                        let categoryResult = try decoder.decode(MPProductDetailModel.self, from: jsonData)
                        // Now you have your Swift model
                        LogClass.debugLog(categoryResult)
                        self.productDetailModel = categoryResult
                        self.updateSection()
                    } catch {
                        LogClass.debugLog("Error decoding JSON: \(error)")
                    }
                }
                else {
                    LogClass.debugLog("not getting good response")
                }
                
            case .failure(let error):
                LogClass.debugLog(error.localizedDescription)
            }
        }
    }
    
    func callRequestToSavedUnsavedProduct(shouldUnsaved: Bool = false, sender: UIButton, image: UIImageView) {
        
        let productId = marketProduct?.id ?? 0
        let params: [String : Any] = ["item_id": "\(productId)"]
        
        MPRequestManager.shared.request(endpoint: "\(!(shouldUnsaved) ? "saved_items" : "un_saved_item")", method: .post, params: params) { response in
            switch response {
            case .success(let data):
                LogClass.debugLog("success")
                if let jsonData = data as? Data {
                    do {
                        let decoder = JSONDecoder()
                        let mpProductSaveModel = try decoder.decode(MPProductSaveModel.self, from: jsonData)
                        // Now you have your Swift model
                        LogClass.debugLog(mpProductSaveModel.data.item_id)
                        self.animateButton(button: sender, image: image, selectedImage: .mpSaved, unSelectedImage: .mpUnsaved)
                        self.marketProduct?.is_saved = !(shouldUnsaved) ? true : false
                    } catch {
                        LogClass.debugLog("Error decoding JSON: \(error)")
                    }
                }
                else {
                    LogClass.debugLog("not getting good response")
                }
                
            case .failure(let error):
                LogClass.debugLog(error.localizedDescription)
            }
        }
    }
}

// MARK: - UICollectionViewDelegate -
extension MPProductDetailViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let lat = CLLocationDegrees(productDetailModel?.data.product.lat ?? .emptyString)
        let lng = CLLocationDegrees(productDetailModel?.data.product.lng ?? .emptyString)
        OpenMaps.presentActionSheetwithMapOption(coordinate: .init(latitude: lat ?? 0.0, longitude: lng ?? 0.0), currentController: self)
    }
}

// MARK: - MPProductDetailInfoDelegate
extension MPProductDetailViewController: MPProductDetailInfoDelegate {
    
    func alertTapped(sender: UIButton, image: UIImageView) {
        LogClass.debugLog("Alert Button Tapped")
        animateButton(button: sender, image: image, selectedImage: .mpAlertActive, unSelectedImage: .mpAlertDeactive)
    }
    
    func shareTapped(sender: UIButton) {
        LogClass.debugLog("Share Button Tapped")
    }
    
    func saveTapped(sender: UIButton, image: UIImageView) {
        LogClass.debugLog("Save Button Tapped")
        // animateButton(button: sender, image: image, selectedImage: .mpSaved, unSelectedImage: .mpUnsaved)
        callRequestToSavedUnsavedProduct(shouldUnsaved: sender.isSelected, sender: sender, image: image)
    }
    
    func messageTapped(sender: UIButton) {
        LogClass.debugLog("Message Button Tapped")
    }
    
    func animateButton(button: UIButton, image: UIImageView, selectedImage: UIImage, unSelectedImage: UIImage) {
        UIView.animate(withDuration: 0.2, animations: {
            image.transform = CGAffineTransform(scaleX: 1.12, y: 1.12)
            button.isSelected.toggle()
        }) { _ in
            UIView.animate(withDuration: 0.2) {
                image.image = button.isSelected ? selectedImage : unSelectedImage
                image.transform = .identity
            }
        }
    }
}
// MARK: - MPSellerDetailInfoDelegate
extension MPProductDetailViewController: MPSellerDetailDelegate {
    func viewSellerDetailTapped(sender: UIButton, sellerId: Int) {
        LogClass.debugLog("seller View Button Tapped \(sellerId)" )
        let vcProfile = MPProfileViewController.instantiate(fromAppStoryboard: .Marketplace)
        vcProfile.viewModel = MPProfileViewModel(sellerId: sellerId, userType: .otheruser)
        navigationController?.pushViewController(vcProfile, animated: true)
    }
    
}
