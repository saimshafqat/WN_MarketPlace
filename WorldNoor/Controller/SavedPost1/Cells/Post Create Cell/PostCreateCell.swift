//
//  PostCreateCell.swift
//  WorldNoor
//
//  Created by Waseem Shah on 19/12/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import Foundation
import FTPopOverMenu

protocol PostCreateDelegate {
    func tappedCreatePost(TypeChoose : Int)
}


class PostCreateCell: ConfigableCollectionCell {
    
    var createPostDelegate : PostCreateDelegate!
    
    @IBOutlet weak var userProfileImage: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        if SharedManager.shared.getProfile() != nil {
            let isUserObj:User = SharedManager.shared.getProfile()!
            userProfileImage.imageLoad(with: isUserObj.data.profile_image)
        }
    }
    
    // MARK: - Override -
    override func displayCellContent(data: AnyObject?, parentData: AnyObject?, at indexPath: IndexPath) {

    }
    @IBAction func photoAction(sender : UIButton){
        FTPopOverMenu.show(forSender: sender, withMenuArray: ["Take a picture".localized() , "Upload".localized()], imageArray: nil, configuration: SharedManager.shared.configWithMenuStyle()) { (selectedIndex) in
            
            if selectedIndex == 0 {
                self.createPostDelegate.tappedCreatePost(TypeChoose: 1)
            }else {
                self.createPostDelegate.tappedCreatePost(TypeChoose: 2)
            }
        } dismiss: {
            
        }
    
    }
    
    @IBAction func videoAction(sender : UIButton){
        FTPopOverMenu.show(forSender: sender, withMenuArray: ["Record".localized() , "Upload".localized()], imageArray: nil, configuration: SharedManager.shared.configWithMenuStyle()) { (selectedIndex) in
            
            if selectedIndex == 0 {
                self.createPostDelegate.tappedCreatePost(TypeChoose: 3)
            }else {
                self.createPostDelegate.tappedCreatePost(TypeChoose: 4)
            }
        } dismiss: {
            
        }
    }
    
    @IBAction func liveAction(sender : UIButton){
        self.createPostDelegate.tappedCreatePost(TypeChoose: 5)
    }
    
    @IBAction func moreAction(sender : UIButton){
        self.createPostDelegate.tappedCreatePost(TypeChoose: 6)
    }
    
    @IBAction func textAction(sender : UIButton){
        self.createPostDelegate.tappedCreatePost(TypeChoose: 7)
    }

   
}
