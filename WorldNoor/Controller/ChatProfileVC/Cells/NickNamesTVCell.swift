//
//  NickNamesTVCell.swift
//  WorldNoor
//
//  Created by ogouluser1-mac6 on 05/09/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit

class NickNamesTVCell: UITableViewCell {
    
    @IBOutlet weak var imgView: UIImageView! {
        didSet {
            imgView.roundTotally()
        }
    }
    
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var nickNameLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func manageOtherUserData(obj:Chat?){
        guard let obj = obj else { return }
        imgView.sd_setImage(with: URL(string: obj.profile_image), placeholderImage: UIImage(named: "placeholder.png"))
        userNameLbl.text = obj.name
        nickNameLbl.text = "Set nickname".localized()
    }
    
    func manageLoggedinUserData(){
        imgView.sd_setImage(with: URL(string: SharedManager.shared.getProfileImage()), placeholderImage: UIImage(named: "placeholder.png"))
        userNameLbl.text = SharedManager.shared.getFullName()
        nickNameLbl.text = "Set nickname".localized()
    }
    
    func manageMPOtherUserData(obj:MPMember?){
        guard let obj = obj else { return }
        imgView.sd_setImage(with: URL(string: obj.profileImage ?? ""), placeholderImage: UIImage(named: "placeholder.png"))
        userNameLbl.text = obj.name
        nickNameLbl.text = "Set nickname".localized()
    }
}
