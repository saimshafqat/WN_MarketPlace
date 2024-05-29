//
//  PostMenuVC.swift
//  WorldNoor
//
//  Created by Waseem Shah on 03/01/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import Foundation
import UIKit

class PostMenuVC : UIViewController {
    
    @IBOutlet var tblViewMenu : UITableView!
    
    var arrayPostDetail = [PostMenuClass]()
    override func viewDidLoad() {
        self.tblViewMenu.register(UINib.init(nibName: "PostMenuHeadingCell", bundle: nil), forCellReuseIdentifier: "PostMenuHeadingCell")
        self.tblViewMenu.register(UINib.init(nibName: "PostMenuCell", bundle: nil), forCellReuseIdentifier: "PostMenuCell")
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.reloadView()
    }
    
    
}


extension PostMenuVC : UITableViewDelegate , UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        
        return self.arrayPostDetail.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if indexPath.section == 1 {
            let cellPostMenu = tableView.dequeueReusableCell(withIdentifier: "PostMenuCell", for: indexPath) as! PostMenuCell
            
            cellPostMenu.lblHeading.text = self.arrayPostDetail[indexPath.row].heading
            cellPostMenu.lblSubHeading.text = self.arrayPostDetail[indexPath.row].subHeading
            cellPostMenu.imgViewMain.image = self.arrayPostDetail[indexPath.row].imgMain
            return cellPostMenu
            
        }
        let cellPost = tableView.dequeueReusableCell(withIdentifier: "PostMenuHeadingCell", for: indexPath) as! PostMenuHeadingCell
        
        
        return cellPost
    }
    
    
    func reloadView(){
  
        self.arrayPostDetail.removeAll()
//     self.arrayPostDetail.append(PostMenuClass.init(headingP:"Show more".localized() , subHeadingP: "More of your posts will be like this.".localized(), imgName: "PostShowMore.png"))
        
//        self.arrayPostDetail.append(PostMenuClass.init(headingP:"Show less".localized() , subHeadingP: "Less of your posts will be like this.".localized(), imgName: "PostShowLess.png"))
        
        self.arrayPostDetail.append(PostMenuClass.init(headingP:"Save posts".localized() , subHeadingP: "More of your posts will be like this.".localized(), imgName: "PostSave.png"))
        
        self.arrayPostDetail.append(PostMenuClass.init(headingP:"Hide posts".localized() , subHeadingP: "Less of your posts will be like this.".localized(), imgName: "PostHide.png"))
        
        self.arrayPostDetail.append(PostMenuClass.init(headingP:"Report post".localized() , subHeadingP: "Less of your posts will be like this.".localized(), imgName: "PostReport.png"))
        
//        self.arrayPostDetail.append(PostMenuClass.init(headingP:"Turn on notifications for this post".localized() , subHeadingP: "".localized(), imgName: "PostNotification.png"))
        
        self.arrayPostDetail.append(PostMenuClass.init(headingP:"Copy link".localized() , subHeadingP: "".localized(), imgName: "Postcopy.png"))
        
//        self.arrayPostDetail.append(PostMenuClass.init(headingP:"Add Pakwheels to your favorites".localized() , subHeadingP: "More of your posts will be like this.".localized(), imgName: "PostFav.png"))
        
//        self.arrayPostDetail.append(PostMenuClass.init(headingP:"Snooze Pakwheels.com for 30 days".localized() , subHeadingP: "Less of your posts will be like this.".localized(), imgName: "PostSnooz.png"))
        
//        self.arrayPostDetail.append(PostMenuClass.init(headingP:"Unfollow Pakwheels.com".localized() , subHeadingP: "Less of your posts will be like this.".localized(), imgName: "PostUnfollow.png"))
        
        self.arrayPostDetail.append(PostMenuClass.init(headingP:"Block profile".localized() , subHeadingP: "More of your posts will be like this.".localized(), imgName: "PostBlock.png"))
        
//        self.arrayPostDetail.append(PostMenuClass.init(headingP:"Manage your feed".localized() , subHeadingP: "Less of your posts will be like this.".localized(), imgName: "PostManage.png"))
        
        self.tblViewMenu.reloadData()

    }
}


class PostMenuClass {
    var heading : String!
    var subHeading : String!
    var imgMain : UIImage!
    
    init(headingP : String , subHeadingP : String , imgName : String) {
        self.heading = headingP
        self.subHeading = subHeadingP
        self.imgMain = UIImage.init(named: imgName )
    }
}
