//
//  PrivacyTableCell.swift
//  WorldNoor
//
//  Created by Niks on 5/7/24.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit

class PrivacyTableCell: UITableViewCell {

    @IBOutlet weak var imgViewSelectRadio: UIImageView!
    @IBOutlet weak var imgViewNavigate: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    
    //MARK: - Properties define.
    static let identifier = "PrivacyTableCell"
    static let nib = UINib(nibName: "PrivacyTableCell", bundle: nil)

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func manageCellContact( dict:NSDictionary){
        self.lblTitle.text = (dict["title"] as! String).localized()
        self.lblTitle.rotateForTextAligment()
        self.labelRotateCell(viewMain: self.lblTitle)
        
        self.lblDesc.text = (dict["title"] as! String).localized()
        self.lblTitle.rotateForTextAligment()
        self.labelRotateCell(viewMain: self.lblTitle)
    }
}
