//
//  NewGroupAboutCell.swift
//  WorldNoor
//
//  Created by apple on 11/19/21.
//  Copyright © 2021 Raza najam. All rights reserved.
//


import Foundation
import UIKit

class NewGroupAboutCell : UITableViewCell {
    @IBOutlet var lblAbout : UILabel!
    @IBOutlet var lblCat : UILabel!
    @IBOutlet var lblVisibility : UILabel!
    @IBOutlet var lblGroupVisibility : UILabel!
    @IBOutlet var lblMembers : UILabel!
    
    var groupObj:GroupValue?
    
    func reloadAbout(){
        self.lblAbout.text = self.groupObj?.groupDesc
        self.lblCat.text = self.groupObj?.category
        self.lblVisibility.text = self.groupObj!.privacy ? "Private".localized() : "Public".localized()
        self.lblGroupVisibility.text = self.groupObj!.visibility ? "Private".localized() : "Public".localized()
        self.lblMembers.text = "Members:".localized() + self.groupObj!.totalMember
    }
    
    @IBAction func showMembers(sender : UIButton){
        if self.groupObj!.isMember || !self.groupObj!.privacy{
            let userView = UIApplication.topViewController()!.GetView(nameVC: "UsersListVC", nameSB: "Kids") as! UsersListVC
            userView.arrayUsers = self.groupObj!.groupMembers
            userView.groupObj = self.groupObj
            UIApplication.topViewController()!.navigationController?.pushViewController(userView, animated: true)
        }
    }
}

