//
//  CreateLifeEventCell.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 28/12/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit

protocol CreateLifeEventDelegate: LifeEventImageVideoDelegate {
    
}

class CreateLifeEventCell: UICollectionViewCell {
    
    // MARK: - Properties -
    var indexPath: IndexPath?
    var createLifeEventdelegate: CreateLifeEventDelegate?
    
    // MARK: - IBOutlets -
    @IBOutlet weak var createLifeEventView: LifeEventImageVideoView? {
        didSet {
            createLifeEventView?.eventImageVideoDelegate = self
        }
    }
    
    // MARK: - Methods -
    func configureCell(object: Any?, indexPath: IndexPath) {
        createLifeEventView?.displayViewContent(object, at: indexPath)
    }
}

// MARK: - LifeEventImageVideoDelegate -
extension CreateLifeEventCell: LifeEventImageVideoDelegate {
    func deleteImageVideo(at indexPath: IndexPath) {
        LogClass.debugLog(indexPath)
        createLifeEventdelegate?.deleteImageVideo(at: indexPath)
    }
    
    func playVideo(at indexPath: IndexPath?, obj: CreateLifeEventImageVideoModel?) {
        createLifeEventdelegate?.playVideo(at: indexPath, obj: obj)
    }
}
