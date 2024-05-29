//
//  GroupProfileVC.swift
//  WorldNoor
//
//  Created by apple on 6/19/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import UIKit

class GroupProfileVC: UIViewController {
    
    @IBOutlet var lblGroupName : UILabel!
    
    @IBOutlet var imgViewGroup : UIImageView!
    
    @IBOutlet var collectionViewUser : UICollectionView!
    
    var chatObj :NSDictionary = [:]
    var arrayFriends = [[String : AnyObject]]()
    
    var filePath = ""
    var isAdmin = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.isAdmin = false
                
        for indexObj in (self.chatObj["admin_ids"] as! [Int]) {
            if indexObj == SharedManager.shared.userObj!.data.id! {
                self.isAdmin = true
            }
        }
        
        self.arrayFriends = (chatObj["members"] as? [[String : AnyObject]])!
        self.title = (chatObj["name"] as! String)
        self.lblGroupName.text = self.title
        
//        let urlString = URL.init(string: self.chatObj["group_image"] as! String)
//        self.imgViewGroup.sd_imageIndicator = SDWebImageActivityIndicator.gray
//        self.imgViewGroup.sd_setImage(with:urlString, placeholderImage: UIImage(named: "placeholder.png"))
        
        
        self.imgViewGroup.loadImageWithPH(urlMain:self.chatObj["group_image"] as! String)
        
        self.view.labelRotateCell(viewMain: self.imgViewGroup)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.collectionViewUser.reloadData()
    }

}




extension GroupProfileVC : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: collectionView.frame.size.width / 4 , height: 150)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrayFriends.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        guard let cellUser = collectionView.dequeueReusableCell(withReuseIdentifier: "GroupchatUserCell", for: indexPath) as? GroupchatUserCell else {
           return UICollectionViewCell()
        }
        
        
//        let urlString = URL.init(string: self.arrayFriends[indexPath.row]["profile_image"] as? String ?? "")
//        cellUser.imgViewUser.sd_imageIndicator = SDWebImageActivityIndicator.gray
//        cellUser.imgViewUser.sd_setImage(with:urlString, placeholderImage: UIImage(named: "placeholder.png"))
        
        cellUser.imgViewUser.loadImageWithPH(urlMain:self.arrayFriends[indexPath.row]["profile_image"] as? String ?? "")
        
        self.view.labelRotateCell(viewMain: cellUser.imgViewUser)
        cellUser.lblName.text = (self.arrayFriends[indexPath.row]["firstname"] as! String) + " " + (self.arrayFriends[indexPath.row]["lastname"] as! String)
        cellUser.viewRemove.isHidden = true
                        
        return cellUser
    }
}
