//
//  ChatSettingsTVCell.swift
//  WorldNoor
//
//  Created by ogouluser1-mac6 on 29/08/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit

class ChatSettingsTVCell: UITableViewCell {
    
    @IBOutlet weak var titleImageView: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    func manageViewData(name:String, imgNamed:String){
        self.titleLbl.text = name
        self.titleImageView.image = UIImage(named: imgNamed)
    }
}
