//
//  ProfileSectionTableViewCell.swift
//  WorldNoor
//
//  Created by Omnia Samy on 13/11/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit

enum ProfileSection: String {
    
    case timeline = "TimeLine"
    case myProfile = "My Profile"
    case photos = "Photos"
    case videos = "Videos"
    case contacts = "Contacts"
    case myReels = "My Reels"
    case savedReels = "Saved Reels"
}

class ProfileSectionTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var profileSectionCollectionView: UICollectionView!
    
    private weak var delegate: ProfileTabSelectionDelegate?
    private var profileSectionList: [ProfileSection]?
    private var isItMyProfile: Bool?
    
    var selectedTab: ProfileSection = .timeline
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        setUpDesign()
        makeSectionList()
    }
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    func bind(delegate: ProfileTabSelectionDelegate, isItMyProfile: Bool) {
        self.delegate = delegate
        self.isItMyProfile = isItMyProfile
        
        makeSectionList()
    }
}

extension ProfileSectionTableViewCell {
    
    private func setUpDesign() {
        profileSectionCollectionView.register(UINib(nibName: ProfileSectionCollectionViewCell.className,
                                                    bundle: nil), forCellWithReuseIdentifier: ProfileSectionCollectionViewCell.className)
        profileSectionCollectionView.dataSource = self
        profileSectionCollectionView.delegate = self
    }
    
    private func makeSectionList() {
        
        let timeLine = ProfileSection.timeline
        let myProfile = ProfileSection.myProfile
        let photos = ProfileSection.photos
        let videos = ProfileSection.videos
        let contacts = ProfileSection.contacts
        let myReels = ProfileSection.myReels
        let savedReels = ProfileSection.savedReels
        
        self.profileSectionList = [timeLine, myProfile, photos, videos, contacts]
        
        if isItMyProfile ?? false {
            self.profileSectionList?.append(contentsOf: [myReels, savedReels])
        }
        
        profileSectionCollectionView.reloadData()
        if selectedTab == .timeline {
            profileSectionCollectionView.scrollToItem(at: IndexPath(row: 0, section: 0),
                                                      at: .right,
                                                      animated: true)
        }
    }
}

extension ProfileSectionTableViewCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.profileSectionList?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView
            .dequeueReusableCell(withReuseIdentifier: ProfileSectionCollectionViewCell.className,
                                 for: indexPath) as? ProfileSectionCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        guard let sectionItem = profileSectionList?[indexPath.row] else {
            return UICollectionViewCell()
        }
        cell.bind(sectionItem: sectionItem, selectedTab: self.selectedTab)
        return cell
    }
}

extension ProfileSectionTableViewCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        guard let sectionItem = profileSectionList?[indexPath.row] else {
            return .zero
        }
        let sectionName = (sectionItem.rawValue).localized()
        let font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        let width = sectionName.width(font: font, height: 60)
        
        return CGSize(width: width + 10, height: 60)
    }
    
//    func collectionView(_ collectionView: UICollectionView,
//                        layout collectionViewLayout: UICollectionViewLayout,
//                        insetForSectionAt section: Int) -> UIEdgeInsets {
//
//        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
//    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let sectionItem = profileSectionList?[indexPath.row] else {
            return
        }
        self.selectedTab = sectionItem
        self.profileSectionCollectionView.reloadData()
        
        switch sectionItem {
            
        case .timeline:
            self.delegate?.profileTabSelection(tabValue: 1)
            
        case .myProfile:
            self.delegate?.profileTabSelection(tabValue: 2)
            
        case .photos:
            self.delegate?.profileTabSelection(tabValue: 3)
            
        case .videos:
            self.delegate?.profileTabSelection(tabValue: 4)
            
        case .contacts:
            self.delegate?.profileTabSelection(tabValue: 5)
            
        case .myReels:
            self.delegate?.profileTabSelection(tabValue: 6)
            
        case .savedReels:
            self.delegate?.profileTabSelection(tabValue: 7)
        }
    }
}
