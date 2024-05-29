//
//  SavedReelCollectionCell.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 01/05/24.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit


protocol SavedReelDelegate {
    func unSavedTapped(at indexPath: IndexPath, sender: LoadingButton?)
    func dotTapped(at indexPath: IndexPath, sender: LoadingButton?)
}


@objc(SavedReelCollectionCell)
class SavedReelCollectionCell: SSBaseCollectionCell {
    
    @IBOutlet weak var nameLabel: UILabel?
    @IBOutlet weak var typeLabel: UILabel?
    @IBOutlet weak var dateLabel: UILabel?
    @IBOutlet weak var thumbnailImageView: UIImageView?
    @IBOutlet weak var unSaveButton: LoadingButton?
    
    var indexPath: IndexPath?
    var feedData: FeedData?
    var savedReelDelegate: SavedReelDelegate?
    
    override func configureCell(_ cell: Any!, atIndex thisIndex: IndexPath!, with object: Any!) {
        super.configureCell(cell, atIndex: thisIndex, with: object)
        self.indexPath = thisIndex
        unSavedBtnVisibility(isHide: true)
        if let obj = object as? FeedData {
            initialSetup(obj)
        }
    }
    
    @IBAction func onClickUnsaved(_ sender: LoadingButton) {
        if let indexPath {
            savedReelDelegate?.unSavedTapped(at: indexPath, sender: sender)
        }
    }
    
    @IBAction func onClickDots(_ sender: LoadingButton) {
        if let indexPath {
            savedReelDelegate?.dotTapped(at: indexPath, sender: unSaveButton)
        }
    }
    
    func initialSetup(_ obj: FeedData) {
        let authorName = obj.authorName ?? .emptyString
        let saveTime = obj.saveTime ?? .emptyString
        nameLabel?.text = authorName + "'s" + " video"
        typeLabel?.text = "Reel"
        dateLabel?.text = "Saved" + " " + (saveTime.timeAgoString() ?? .emptyString)
        thumbnailImageView?.imageLoad(with: obj.post?.first?.thumbnail ?? .emptyString)
        
        // language orientation handling
        languageOritentation()
    }
    
    
    func languageOritentation() {
        nameLabel?.rotateForTextAligment()
        typeLabel?.rotateForTextAligment()
        dateLabel?.rotateForTextAligment()
    }
    
    func unSavedBtnVisibility(isHide: Bool) {
        unSaveButton?.isHidden = isHide
    }
}
