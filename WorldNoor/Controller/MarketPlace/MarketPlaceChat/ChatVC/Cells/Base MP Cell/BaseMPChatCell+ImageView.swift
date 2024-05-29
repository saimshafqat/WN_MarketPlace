//
//  BaseMPChatCell+ImageView.swift
//  WorldNoor
//
//  Created by Awais on 08/04/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import Foundation
import SKPhotoBrowser
import AVKit

extension BaseMPChatCell
{
    func setImageView()
    {
        self.imageBubbleView.isHidden = false
        self.lblImageBody.text = self.chatObj.content
        LinkDetector.lblHandling(lblNewBody: lblImageBody)
        self.viewPlay.addShadowToView(shadowRadius: 1, alphaComponent: 0.3)
        
        self.viewImageText.isHidden = false
        if(self.lblImageBody.text?.count ?? 0 == 0)
        {
            self.viewImageText.isHidden = true
        }
        
        self.viewPlay.isHidden = true
        if self.chatObj.messageLabel == FeedType.video.rawValue {
            self.viewPlay.isHidden = false
        }
        
        if self.chatObj.toMessageFile?.count ?? 0 > 0
        {
            if let msgFile = self.chatObj.toMessageFile?.first as? MPMessageFile {
                if self.chatObj.messageLabel == FeedType.image.rawValue
                {
                    if msgFile.localthumbnailimage.count > 0, let image = SharedManager.shared.loadImage(fileName: msgFile.localthumbnailimage) {
                            self.imgViewMain.image = image
                    }
                    else if msgFile.name.count > 0, let image = SharedManager.shared.loadImage(fileName: msgFile.name) {
                            self.imgViewMain.image = image
                    }
                    else if msgFile.url.count > 0 {
                        self.imgViewMain.loadImageWithPH(urlMain: msgFile.url)
                    }
                }else if self.chatObj.messageLabel == FeedType.video.rawValue
                {

                    if msgFile.localthumbnailimage.count > 0, let image = SharedManager.shared.loadImage(fileName: msgFile.localthumbnailimage) {
                            self.imgViewMain.image = image
                    }else
                    {
                        self.imgViewMain.loadImageWithPH(urlMain: msgFile.thumbnailUrl)
                    }
                }
            }
        }
    }
    
    @IBAction func showimage(sender : UIButton){
        var images = [SKPhoto]()
        var photo : SKPhoto!
        
        if self.chatObj.toMessageFile?.count ?? 0 > 0, let msgFile = self.chatObj.toMessageFile?.first as? MPMessageFile
        {
            if self.chatObj.messageLabel == FeedType.image.rawValue
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
                    if msgFile.localthumbnailimage.count > 0, let image = SharedManager.shared.loadImage(fileName: msgFile.localthumbnailimage) {
                        photo = SKPhoto.photoWithImage(image)
                    }
                    else if msgFile.name.count > 0, let image = SharedManager.shared.loadImage(fileName: msgFile.name) {
                        photo = SKPhoto.photoWithImage(image)
                    }
                    else if msgFile.url.count > 0 {
                        photo = SKPhoto.photoWithImageURL(msgFile.url)
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
                if videoURLString.count > 0 {
                    self.VideoPlayWithURL(URLVideo: videoURLString )
                }else if msgFile.localFileURL.count > 0 {
                    self.VideoPlayWithURL(URLVideo: msgFile.localFileURL)
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
                
        let player = AVPlayer.init(url: URL.init(fileURLWithPath: URLVideo))
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        UIApplication.topViewController()!.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    }
}
