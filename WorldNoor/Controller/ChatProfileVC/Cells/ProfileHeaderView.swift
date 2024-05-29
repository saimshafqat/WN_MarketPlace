//
//  ProfileHeaderView.swift
//  WorldNoor
//
//  Created by ogouluser1-mac6 on 03/09/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit
import SDWebImage
class ProfileHeaderView: UIView {
    
    var profileHandler: (()->())?
    var muteHandler: (() -> ())?
    var messageHandler: (() -> ())?
    
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var profView: UIView!
    @IBOutlet weak var profLbl: UILabel!
    @IBOutlet weak var messengerView: UIView!
    @IBOutlet weak var messengerLbl: UILabel!
    @IBOutlet weak var muteView: UIView!
    @IBOutlet weak var muteLbl: UILabel!
    @IBOutlet weak var muteImageView: UIImageView!
    @IBOutlet weak var imgView: UIImageView!{
        didSet {
            imgView.roundTotally()
        }
    }
    @IBOutlet weak var profBgView: UIView!{
        didSet{
            profBgView.roundTotally()
        }
    }
    @IBOutlet weak var muteBgView: UIView!
    {
        didSet{
            muteBgView.roundTotally()
        }
    }
    @IBOutlet weak var messengerBgView: UIView!
    {
        didSet{
            messengerBgView.roundTotally()
        }
    }
    
    func manageData(obj:Chat?){
        guard let obj = obj else { return }
        imgView.sd_setImage(with: URL(string: obj.profile_image), placeholderImage: UIImage(named: "placeholder.png"))
        nameLbl.text = obj.name
    }
    
    func manageMPData(obj:MPChat?){
        guard let obj = obj else { return }
        imgView.sd_setImage(with: URL(string: obj.groupImage), placeholderImage: UIImage(named: "placeholder.png"))
        nameLbl.text = obj.conversationName
    }
    
    @IBAction func handleProfilePressed(_ sender: Any) {
        if let profileHandler = profileHandler {
            profileHandler()
        }
    }
    
    @IBAction func handleMutePressed(_ sender: Any) {
        if let muteHandler = muteHandler {
            muteHandler()
        }
    }
    
    @IBAction func handleMessagePressed(_ sender: Any) {
        if let messageHandler = messageHandler {
            messageHandler()
        }
    }
}
