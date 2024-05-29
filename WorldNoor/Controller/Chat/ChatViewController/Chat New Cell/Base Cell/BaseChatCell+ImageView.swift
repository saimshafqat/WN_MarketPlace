//
//  BaseChatCell+ImageView.swift
//  WorldNoor
//
//  Created by Awais on 22/02/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import Foundation
import SKPhotoBrowser
import AVKit

extension BaseChatCell
{
    func setImageView()
    {
        self.imageBubbleView.isHidden = false
        self.lblImageBody.text = self.chatObj.body
        LinkDetector.lblHandling(lblNewBody: lblImageBody)
        self.viewPlay.addShadowToView(shadowRadius: 1, alphaComponent: 0.3)
        
        self.viewImageText.isHidden = false
        if(self.lblImageBody.text?.count ?? 0 == 0)
        {
            self.viewImageText.isHidden = true
        }
        
        self.viewPlay.isHidden = true
        if self.chatObj.post_type == FeedType.video.rawValue {
            self.viewPlay.isHidden = false
        }
        
        if self.chatObj.toMessageFile?.count ?? 0 > 0
        {
            if let msgFile = self.chatObj.toMessageFile?.first as? MessageFile {
                if msgFile.post_type == FeedType.image.rawValue
                {
                    if (msgFile.localimage.count == 0) && (msgFile.url.count > 0) {
                        self.imgViewMain.loadImageWithPH(urlMain: msgFile.url )
                    }else
                    {
                        if msgFile.thumbnail_url.count == 0 && msgFile.localthumbnailimage != ""
                        {
                            if let image = SharedManager.shared.loadImage(fileName: msgFile.localthumbnailimage) {
                                self.imgViewMain.image = image
                            }
                        }else
                        {
                            self.imgViewMain.loadImageWithPH(urlMain: msgFile.thumbnail_url)
                        }
                    }
                }else if msgFile.post_type == FeedType.video.rawValue
                {
                    
                    if msgFile.thumbnail_url.count == 0 && msgFile.localthumbnailimage != ""
                    {
                        if let image = SharedManager.shared.loadImage(fileName: msgFile.localthumbnailimage) {
                            self.imgViewMain.image = image
                        }
                    }else
                    {
                        self.imgViewMain.loadImageWithPH(urlMain: msgFile.thumbnail_url)
                    }
                }
            }
        }
    }
    
    @IBAction func showimage(sender : UIButton){
        var images = [SKPhoto]()
        var photo : SKPhoto!
        
        if self.chatObj.toMessageFile?.count ?? 0 > 0, let msgFile = self.chatObj.toMessageFile?.first as? MessageFile
        {
            if msgFile.post_type == FeedType.image.rawValue
            {
                if let imageURL = URL(string: msgFile.url), imageURL.pathExtension.lowercased() == "gif" {
                    let gifViewController = GifViewController()
                    gifViewController.gifURL = imageURL
                    gifViewController.modalPresentationStyle = .overFullScreen
                    
                    UIApplication.topViewController()!.present(gifViewController, animated: true, completion: nil)
                } else
                {
                    if let image = self.imgViewMain.image, image != UIImage(named: "PlaceHolderImage.png") {
                        photo = SKPhoto.photoWithImage(image)
                    }
                    else
                    if msgFile.localimage.count == 0
                    {
                        photo = SKPhoto.photoWithImageURL(msgFile.url)
                    }else
                    {
                        if msgFile.thumbnail_url.count == 0 && msgFile.localthumbnailimage != ""
                        {
                            if let image = SharedManager.shared.loadImage(fileName: msgFile.localthumbnailimage) {
                                photo = SKPhoto.photoWithImage(image)
                            }
                        }else
                        {
                            photo = SKPhoto.photoWithImageURL(msgFile.thumbnail_url)
                        }
                    }
                    
                    if photo != nil {
                        photo.shouldCachePhotoURLImage = true
                        images.append(photo)
                        
                        let browser = SKPhotoBrowser(photos: images)
                        SKPhotoBrowserOptions.displayAction = false
                        UIApplication.topViewController()!.present(browser, animated: true, completion: {})
                    }
                }
            }else {
                let videoURLString = msgFile.url
                if videoURLString.count != 0 {
                    self.VideoPlayWithURL(URLVideo: videoURLString )
                }else if msgFile.localVideoURL.count > 0 {
                    
                    self.VideoPlayWithURL(URLVideo: msgFile.localVideoURL )
                }
                
            }
        }
    }
    
    func VideoPlayWithURL(URLVideo : String){
        let videoURL = URL.init(string: URLVideo)
        let player = AVPlayer(url: videoURL! as URL)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        UIApplication.topViewController()!.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    }
    
    func VideoPlayLocalFile(URLVideo : String){
        
        let strArray = URLVideo.components(separatedBy: "/")
        
        let player = AVPlayer.init(url: URL.init(fileURLWithPath: URLVideo))
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        UIApplication.topViewController()!.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    }
}
