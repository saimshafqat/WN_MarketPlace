//
//  TopStoriesView.swift
//  WorldNoor
//
//  Created by apple on 5/26/22.
//  Copyright © 2022 Raza najam. All rights reserved.
//

import Foundation
import UIKit

class TopStoriesView : UIView {
    
    var modelObj : FeedVideoModel!
        
    @IBOutlet var imgviewUser : UIImageView!
    @IBOutlet var imgviewStoryUser : UIImageView!
    @IBOutlet var lblUserName : UILabel!
    @IBOutlet var lblLikes : UILabel!
    @IBOutlet var lblcomments : UILabel!
    @IBOutlet var lblShare : UILabel!
    
    @IBOutlet var btnUserProfile : UIButton!
    
    override class func awakeFromNib() {
        
        
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return false
    }
    @IBAction func userProfile(sender : UIButton){
        if let topStory = UIApplication.topViewController()! as? VideoConsumptionPageViewController {
            topStory.openUserProfile()
        }
    }
    
    @IBAction func backAction(sender : UIButton){
        if let topStory = UIApplication.topViewController()! as? VideoConsumptionPageViewController {
            topStory.backAction()
        }
        
    }
    
    
    @IBAction func pauseButton(sender : UIButton){
        
    }
    
    
    
    func reloadData(){
        self.lblcomments.text = "0"
        self.lblLikes.text = "0"
        self.lblShare.text = "0"

    }
}
