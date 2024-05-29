//
//  MyContactCell.swift
//  WorldNoor
//
//  Created by Raza najam on 10/30/19.
//  Copyright © 2019 Raza najam. All rights reserved.
//

import UIKit

class MyContactCell: UITableViewCell {
    @IBOutlet weak var itemLbl: UILabel!
    @IBOutlet weak var lastMessageLbl: UILabel!
    @IBOutlet weak var lblMessageCount: UILabel!
    @IBOutlet weak var viewMessageCount: UIView!
    @IBOutlet weak var lblMessageTime: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var btnUserProfile: UIButton!
    @IBOutlet weak var messageBtn: UIButton!
    @IBOutlet weak var lblMessageHeading: UILabel!
    
    @IBOutlet var imgViewMute : UIView!

    
    @IBOutlet weak var viewOnline: UIView!
        
    func manageCellDataMore( value:String, imgName:String){
        self.itemLbl.text = value
        self.userImageView.image = UIImage(named:imgName)
        if value == "Logout" {
            self.userImageView.image = UIImage(named: imgName)
        }
    }
    
    func manageCellContact( dict:NSDictionary){
        self.itemLbl.text = (dict["title"] as! String).localized()
        self.itemLbl.rotateForTextAligment()
        self.labelRotateCell(viewMain: self.itemLbl)
    }
    
    func reloadLabel(){
        
        self.itemLbl.dynamicSubheadRegular15()
//        self.itemLbl.dynamicHeadlineSemiBold17()
        self.lastMessageLbl.dynamicSubheadRegular15()
        self.lblMessageTime.dynamicFootnoteRegular13()

    }
    
    func manageContact( dict:NSDictionary){
        self.itemLbl.text = (dict["firstname"] as! String)+" "+(dict["lastname"] as! String)
        self.userImageView.image = UIImage(named: "placeholder.png")
        if !(dict.value(forKey: "profile_image") is NSNull) {
            let profileImag = dict["profile_image"] as! String
            
            self.userImageView.loadImageWithPH(urlMain:profileImag)
            
            self.labelRotateCell(viewMain: self.userImageView)
        }
        
        self.itemLbl.rotateForTextAligment()
        self.labelRotateCell(viewMain: self.itemLbl)
        self.itemLbl.dynamicBodyRegular17()
    }
    
    func manageContactList(dict:Chat){

        self.itemLbl.text = dict.nickname.count > 0 ? dict.nickname : dict.name
        self.lblMessageTime.text = ""
        
        if dict.latest_message_time.count > 0  {
            self.lblMessageTime.text = dict.latest_message_time.customDateFormat(time: dict.latest_message_time, format:Const.dateFormat1)
        }
        
        self.lastMessageLbl.text = ""
        if dict.latest_message.count > 0 {
            self.lastMessageLbl.text = dict.latest_message
        }
        
        var profileImag = ""
        if dict.conversation_type == "group" {
            if dict.group_image.count > 0 {
                profileImag = dict.group_image
            }
        }else {
            if dict.profile_image.count > 0{
                profileImag = dict.profile_image
            }
        }
        
        if dict.is_online == "1" {
            self.viewOnline.isHidden = false
        }else if dict.is_online == "0" {
            self.viewOnline.isHidden = true
        }
        
        SharedManager.shared.setTextandFont(viewText: self.lastMessageLbl as Any)
        
                
        self.userImageView.loadImageWithPH(urlMain:profileImag)
        self.labelRotateCell(viewMain: self.userImageView)
        
        self.labelRotateCell(viewMain: self.lblMessageTime)
        self.labelRotateCell(viewMain: self.itemLbl)
        self.labelRotateCell(viewMain: self.lastMessageLbl)
        
        self.lblMessageTime.rotateForTextAligment()
        self.itemLbl.rotateForTextAligment()
        self.lastMessageLbl.rotateForTextAligment()
        self.viewMessageCount.isHidden = true
        lblMessageCount.isHidden = true
        if dict.is_unread == "1" {
            self.itemLbl.dynamicHeadlineSemiBold17()
//            self.viewMessageCount.isHidden = false
//            lblMessageCount.isHidden = false
//            lblMessageCount.text = dict.unread_messages_count
        }else {
//            lblMessageCount.text = ""
            self.itemLbl.dynamicSubheadRegular15()
        }
        
        self.imgViewMute.isHidden = true
        if dict.is_mute == "1" {
            self.imgViewMute.isHidden = false
        }
        
    }
    
     func manageForwardList( dict:NSMutableDictionary){

        self.itemLbl.text = (dict.value(forKey: "name") as! String)
            self.lblMessageTime.text = ""

            
            var profileImag = ""
            if (dict.value(forKey: "conversation_type") as! String) == "group" {
                if !(dict.value(forKey: "group_image") is NSNull) {
                    profileImag = dict["group_image"] as! String
                }
            }else {
                if !(dict.value(forKey: "profile_image") is NSNull) {
                    profileImag = dict["profile_image"] as! String
                }
            }
            
            
            SharedManager.shared.setTextandFont(viewText: self.lastMessageLbl)
            
         
         self.userImageView.loadImageWithPH(urlMain:profileImag)
        self.labelRotateCell(viewMain: self.userImageView)
        }
}
