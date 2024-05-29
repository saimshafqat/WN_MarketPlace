//
//  NearUserCell.swift
//  WorldNoor
//
//  Created by Omnia Samy on 02/01/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import Foundation
import UIKit

class NearUserCell : UITableViewCell {
    
    // MARK: - IBOutlets -
    @IBOutlet private weak var imgViewUSer : UIImageView!
    @IBOutlet private weak var lblUserName : UILabel!
    @IBOutlet private weak var lblDisctance : UILabel!
    @IBOutlet private weak var lblFriendStatus : UILabel!
    @IBOutlet private weak var btnMessage : UIButton!
    @IBOutlet private weak var viewBG : UIView!
    @IBOutlet private weak var categoriesCollectionView: UICollectionView? {
        didSet {
            categoriesCollectionView?.dataSource = self
            categoriesCollectionView?.delegate = self
            categoriesCollectionView?.registerCustomCells([NearByCategoryCollectionViewCell.className])
        }
    }
    @IBOutlet private weak var interestCollectionViewHeight: NSLayoutConstraint!
    
    // MARK: - Properties -
    private var nearUserModel: NearByUserModel?
    private weak var delegate: NearByUsersProtocol?
    private var friendStatus: FriendStatus?
    
    // MARK: - Methods -
    func bind(nearUserModel: NearByUserModel, delegate: NearByUsersProtocol) {
        self.nearUserModel = nearUserModel
        self.delegate = delegate
        let fullName = nearUserModel.firstname + " " + nearUserModel.lastname
        self.lblUserName.text = fullName
        self.lblDisctance.text = nearUserModel.distanceInKm + " " + "Away".localized()
        self.imgViewUSer.loadImageWithPH(urlMain: nearUserModel.profileImage)
        friendStatus = FriendStatus(friendStatusString: nearUserModel.friendStatus)
        self.lblFriendStatus.text = friendStatus?.localizedText
        self.viewBG.backgroundColor = friendStatus?.backgroundColor
        
        self.viewBG.isHidden = true
        if nearUserModel.canISendFr {
            self.viewBG.isHidden = false
        }
        
        contentView.labelRotateCell(viewMain: self.imgViewUSer)
        categoriesCollectionView?.reloadData()
        interestCollectionViewHeight.constant = self.nearUserModel?.interests.isEmpty ?? false ? 0 : 50
    }
    
    @IBAction func messageButtonTapped(_ sender: UIButton) {
        guard let nearUserModel = nearUserModel else { return }
        delegate?.messageTapped(nearUserModel: nearUserModel)
    }
}

// MARK: - UICollectionViewDataSource -
extension NearUserCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return nearUserModel?.interests.count ?? 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView
            .dequeueReusableCell(withReuseIdentifier: NearByCategoryCollectionViewCell.className,
                                 for: indexPath) as? NearByCategoryCollectionViewCell else {
            return UICollectionViewCell()
        }
        guard let interest = self.nearUserModel?.interests[indexPath.row] else {
            return UICollectionViewCell()
        }
        cell.bind(interests: interest)
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout -
extension NearUserCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let categoryName = self.nearUserModel?.interests[indexPath.row].name ?? .emptyString
        let font = UIFont.systemFont(ofSize: 15, weight: .regular)
        let width = categoryName.width(font: font, height: 50)
        return CGSize(width: width + 30, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
}
