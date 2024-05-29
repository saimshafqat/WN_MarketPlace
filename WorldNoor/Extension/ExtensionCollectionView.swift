//
//  ExtensionCollectionView.swift
//  WorldNoor
//
//  Created by Muhammad Asher on 09/05/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit

// MARK: - CollectionView Extension
extension UICollectionView {
    func dequeueReusableCell<T: UICollectionViewCell>(forIndexPath indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withReuseIdentifier: String(describing: T.self), for: indexPath) as? T else {
            fatalError("Unable to dequeue cell with identifier: \(String(describing: T.self))")
        }
        return cell
    }
}

extension UICollectionView {
    
    enum CellClass: String {
        case VideoClipUploadCollectionCell
        case StoryEndCell
        case CreateReelCollectionViewCell
        case FeedFriendSuggestionCollectionCell
        case FeedReelCollectionCell
        case ProfileCompletePictureCell
        case ProfileCompleteDOBCell
        case ProfileCompleteGenderCell
        case ProfileCompleteEmailPhoneCell
        case ProfileCompletePlaceCell
        case ProfileCompleteMaritalStatusCell
        case ProfileEmptyCell
        case ProfileCompleteCongratulationCell
        case EmptyCell
    }
    
    func registerCustomCells(_ identifiers: [String]) {
        for identifier in identifiers {
            register(UINib(nibName: identifier, bundle: nil), forCellWithReuseIdentifier: identifier)
        }
    }
        
    func registerXibCell(_ identifiers: [CellClass]) {
        for identifier in identifiers {
            register(UINib(nibName: identifier.rawValue, bundle: nil), forCellWithReuseIdentifier: identifier.rawValue)
        }
    }

    // register header class
    func register(header: AnyClass) {
        register(UINib(nibName: String(describing: header.self), bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: String(describing: header.self))
    }
    
    func register(foorter: AnyClass) {
        register(UINib(nibName: String(describing: foorter.self), bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: String(describing: foorter.self))
    }
}
