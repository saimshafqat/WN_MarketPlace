//
//  PostSectionCell.swift
//  WorldNoor
//
//  Created by Waseem Shah on 21/12/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import Foundation


class PostSectionCell: ConfigableCollectionCell {
    
    @IBOutlet var viewStory : UIView!
    @IBOutlet var viewReel : UIView!
    @IBOutlet var viewRoom : UIView!
    
    
    @IBOutlet var lblStory : UILabel!
    @IBOutlet var lblReel : UILabel!
    @IBOutlet var lblRoom : UILabel!
    
    @IBOutlet var imgViewStory : UIImageView!
    @IBOutlet var imgViewReel : UIImageView!
    @IBOutlet var imgViewRoom : UIImageView!
    
    var createPostDelegate : PostCreateDelegate!
    
    // MARK: - Override -
    override func displayCellContent(data: AnyObject?, parentData: AnyObject?, at indexPath: IndexPath) {

    }
    
    @IBAction func segmentAction(sender : UIButton){
        
       
        self.viewReel.isHidden = true
        self.viewRoom.isHidden = true
        self.viewStory.isHidden = true

        self.lblReel.textColor = UIColor.black
        self.lblRoom.textColor = UIColor.black
        self.lblStory.textColor = UIColor.black
        
        self.imgViewStory.image = UIImage.init(named: "Icon-Stories.png")
        self.imgViewReel.image = UIImage.init(named: "Icon-Reels.png")
        self.imgViewRoom.image = UIImage.init(named: "Icon-Rooms.png")
        
      
        
        if sender.tag == 1 {
            self.imgViewReel.image = UIImage.init(named: "Icon-Reels-S.png")
            self.viewReel.isHidden = false
         //   self.lblReel.font = UIFont.boldSystemFont(ofSize: 17.0)
            self.lblReel.textColor = UIColor.init(named: "LogoColor")
            
            createPostDelegate.tappedCreatePost(TypeChoose: 102)
        } else if sender.tag == 0 {
            self.imgViewStory.image = UIImage.init(named: "Icon-Stories-S.png")
            self.viewStory.isHidden = false
         //   self.lblStory.font = UIFont.boldSystemFont(ofSize: 15)
            self.lblStory.textColor = UIColor.init(named: "LogoColor")
            createPostDelegate.tappedCreatePost(TypeChoose: 101)
        }
        
        if sender.tag == 2 {
            self.imgViewRoom.image = UIImage.init(named: "Icon-Rooms-S.png")
            self.viewRoom.isHidden = false
         //   self.lblRoom.font = UIFont.boldSystemFont(ofSize: 17.0)
            self.lblRoom.textColor = UIColor.init(named: "LogoColor")
            createPostDelegate.tappedCreatePost(TypeChoose: 103)
       }
     
        
        
        
    }
   

   
}
