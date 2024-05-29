//
//  NewPageaboutCell.swift
//  WorldNoor
//
//  Created by apple on 10/21/21.
//  Copyright © 2021 Raza najam. All rights reserved.
//

import Foundation
import UIKit

class NewPageaboutCell : UITableViewCell {
    
    @IBOutlet var lblAbout : UILabel!
    @IBOutlet var lblCat : UILabel!
    @IBOutlet var lblLike : UILabel!
    @IBOutlet var lblFollows : UILabel!
    
    var groupObj:GroupValue?
    
    func reloadAbout(){
        self.lblAbout.text = self.groupObj?.groupDesc
        self.lblLike.text = self.groupObj?.totalLikes
        self.lblFollows.text = self.groupObj?.totalFollow
        self.lblCat.text = self.groupObj?.categoriesStr
    }
    
    
    @IBAction func showFollowerUser(sender : UIButton){
        let userView = UIApplication.topViewController()!.GetView(nameVC: "UsersListVC", nameSB: "Kids") as! UsersListVC
        userView.arrayUsers = self.groupObj!.groupMembers
        userView.groupObj = self.groupObj
        userView.isFromPage = 1
        UIApplication.topViewController()!.navigationController?.pushViewController(userView, animated: true)
    }
    
    @IBAction func showLikeUser(sender : UIButton){
            let userView = UIApplication.topViewController()!.GetView(nameVC: "UsersListVC", nameSB: "Kids") as! UsersListVC
            userView.arrayUsers = self.groupObj!.groupMembers
            userView.groupObj = self.groupObj
        userView.isFromPage = 2
            UIApplication.topViewController()!.navigationController?.pushViewController(userView, animated: true)
    }
}
