//
//  NewLinkPreviewCell.swift
//  WorldNoor
//
//  Created by apple on 12/24/21.
//  Copyright © 2021 Raza najam. All rights reserved.
//


import Foundation
import UIKit
//import SwiftLinkPreview


class NewLinkPreviewCell : UITableViewCell {
    
    var feedObj : FeedData!
    
    @IBOutlet weak var linkPHImageView: UIImageView!
    
    @IBOutlet weak var linkImageView: UIImageView!
    @IBOutlet weak var linkTitleLbl: UILabel!
    @IBOutlet weak var linkDescLbl: UILabel!

    @IBOutlet weak var imgViewPlay: UIImageView!
    
    @IBOutlet weak var viewLink: UIView!
    @IBOutlet weak var cstHeight: NSLayoutConstraint!
//    var linkGeneratorObj = LinkGenerator()
//    private var result:Response?
    var linkView: TownHallPreviewView?
//    private let slp = SwiftLinkPreview(cache: InMemoryCache())
    
    @IBOutlet private weak var imageSectionView: UIView!
    
    
    func reloadHeaderData() {

        self.imgViewPlay.isHidden = true
        
        self.cstHeight.constant = 175.0
        
        self.linkImageView.isHidden = false
        self.linkPHImageView.alpha = 1.0
        
        self.linkTitleLbl.dynamicTitle3Bold20WithoutClip()
        self.linkDescLbl.dynamicBodyRegular17WithoutClip()
        
        
        if self.feedObj.linkImage == nil {
            self.linkPHImageView.isHidden = true
            self.linkImageView.isHidden = true
            self.imgViewPlay.isHidden = true
            self.cstHeight.constant = 0.0
            self.linkPHImageView.alpha = 0.0
        }else if self.feedObj.linkImage!.count == 0 {
            self.linkPHImageView.isHidden = true
            self.linkImageView.isHidden = true
            self.imgViewPlay.isHidden = true
            self.cstHeight.constant = 0.0
            self.linkPHImageView.alpha = 0.0
        }
        
        self.linkPHImageView.isHidden = true
        self.linkImageView.sd_setImage(with: URL(string:self.feedObj.linkImage ?? "")) { imageMain, error, typeCache, mainURL in
            if imageMain == nil {
                self.linkPHImageView.isHidden = false
            }else {
                self.linkImageView.image = imageMain
            }
        }
        
        self.linkTitleLbl.text = self.feedObj.linkTitle
        self.linkDescLbl.text = self.feedObj.linkDesc
        
        if self.feedObj.previewLink!.contains("youtube") {
            self.imgViewPlay.isHidden = false
        }
        
        // handle svg image issue
        if (self.feedObj.linkImage ?? "").contains(".svg") {
            self.imageSectionView.isHidden = true
        } else {
            self.imageSectionView.isHidden = false
        }
            
    }
 
    
    @IBAction func openlink(sender : UIButton){


    }
 
    func playYoutubeVideo(videoID:String){
        var chatStoryboard: UIStoryboard {
            return UIStoryboard(name: "Group", bundle: nil)
        }

        
        if SharedManager.shared.ytPlayer == nil {
            SharedManager.shared.ytPlayer = (chatStoryboard.instantiateViewController(withIdentifier: "YouTubePlayeriOSHelperViewController") as! YouTubePlayeriOSHelperViewController)
        }
        
        
        
        SharedManager.shared.ytPlayer.view.frame = CGRect.init(x: 0, y: 0, width:UIScreen.main.bounds.size.width , height: 300)
        UIApplication.topViewController()?.view.addSubview(SharedManager.shared.ytPlayer.view)
        
        SharedManager.shared.ytPlayer.closeBtn.addTarget(self, action: #selector(closeVideoPreview), for: .touchUpInside)
    //    SharedManager.shared.ytPlayer.view.tag = 100
        SharedManager.shared.ytPlayer.playerView.translatesAutoresizingMaskIntoConstraints = false
        SharedManager.shared.ytPlayer.bottomView.translatesAutoresizingMaskIntoConstraints = false
        SharedManager.shared.ytPlayer.playerView.heightAnchor.constraint(equalToConstant: 210.0).isActive = true

        SharedManager.shared.ytPlayer.loadVideo(videoID: videoID)
    }
    
    @objc func closeVideoPreview(sender : UIButton){
    }
}
