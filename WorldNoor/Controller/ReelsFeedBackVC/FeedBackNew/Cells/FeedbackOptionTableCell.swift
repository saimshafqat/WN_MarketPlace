//
//  FeedbackOptionTableCell.swift
//  WorldNoor
//
//  Created by Asher Azeem on 19/04/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit

protocol FeedbackOptionCellDelegate {
    func didChooseOptionTapped(with sender: UIButton, at indexPath: IndexPath, isAdded: Bool)
}

@objc(FeedbackOptionTableCell)
class FeedbackOptionTableCell: FeedBackBaseTableCell {

    // MARK: - Properties -
    var feedbackOptionCellDelegate: FeedbackOptionCellDelegate?
    
    // MARK: - IBoutlets -
    @IBOutlet weak var imgViewTick: UIImageView?

    // MARK: - Override
    override func configureCell(_ cell: Any!, atIndex thisIndex: IndexPath!, with object: Any!) {
        super.configureCell(cell, atIndex: thisIndex, with: object)
    }
    
    // MARK: - IBActions -
    @IBAction func onClickChooseOption(_ sender: UIButton) {
        if let imgViewTick {
            feedbackOptionCellDelegate?.didChooseOptionTapped(with: sender, at: self.indexPath ?? IndexPath(), isAdded: imgViewTick.isHidden)
            imgViewTick.isHidden = !imgViewTick.isHidden
        }
    }
}
