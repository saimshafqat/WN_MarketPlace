//
//  SavedReelMoreViewController.swift
//  WorldNoor
//
//  Created by Asher Azeem on 02/05/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit

protocol SavedReelMoreDelegate {
    func copyLinkTapped(at indexPath: IndexPath, feedData: FeedData)
    func unSavedTapped(at indexPath: IndexPath, feedData: FeedData, sender: LoadingButton?)
}

class SavedReelMoreViewController: UIViewController {
    
    // MARK: - Properties -
    var indexPath: IndexPath?
    var feedData: FeedData?
    var savedReelMoreDelegate: SavedReelMoreDelegate?
    var loadingButton: LoadingButton?
    
    // MARK: - IBActions -
    @IBAction func onClickCopyLink(_ sender: UIButton) {
        self.dismiss(animated: true) {
            if let index = self.indexPath, let Obj = self.feedData {
                self.savedReelMoreDelegate?.copyLinkTapped(at: index, feedData: Obj)
            }
        }
    }
    
    @IBAction func onClickUnsaved(_ sender: UIButton) {
        self.dismiss(animated: true) {
            if let index = self.indexPath, let Obj = self.feedData {
                self.savedReelMoreDelegate?.unSavedTapped(at: index, feedData: Obj, sender: self.loadingButton)
            }
        }
    }
}
