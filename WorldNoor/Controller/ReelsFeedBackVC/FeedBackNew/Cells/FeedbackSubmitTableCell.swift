//
//  FeedbackSubmitTableCell.swift
//  WorldNoor
//
//  Created by Asher Azeem on 19/04/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit

protocol FeedbackSubmitCellDelegate {
    func submitTapped(sender: UIButton)
}
@objc(FeedbackSubmitTableCell)
class FeedbackSubmitTableCell: SSBaseTableCell {

    // MARK: - Properties
    var feedbackSubmitDelegate: FeedbackSubmitCellDelegate?
    
    // MARK: - IBOutlets -
    @IBOutlet var lblHeading : UILabel!
    @IBOutlet var btnMain : UIButton!
    @IBOutlet var viewBG : UIView!
    @IBOutlet var viewLine : UIView!

    // MARK: - Override
    override func configureCell(_ cell: Any!, atIndex thisIndex: IndexPath!, with object: Any!) {
        lblHeading.text = "Submit".localized()
    }
    
    // MARK: - IBActions -
    @IBAction func onClickSubmit(_ sender: UIButton) {
        feedbackSubmitDelegate?.submitTapped(sender: sender)
    }
}
