//
//  FullGalleryCollectionCell.swift
//  WorldNoor
//
//  Created by Lucky on 31/01/2020.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import UIKit
//import EZPlayer

class FullGalleryCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var bgView: UIView!    
    var postObj:PostFile? = nil
    
    var singleImageView:NewGalleryImageCell? = nil
    var videoView:VideoView? = nil
    var audioView:AudioView? = nil
    var AttachmentCell : AttachmentCollectionCell? = nil
    var mainIndex = IndexPath(row: 0, section: 0)
    var currentIndex = IndexPath(row: 0, section: 0)
    @IBOutlet var parentView : UITableView!

    
    override func awakeFromNib() {
        
    }
    
    func addVideoView(){
        self.layoutIfNeeded()

        
        
        self.videoView?.removeFromSuperview()
        self.videoView = (Bundle.main.loadNibNamed(Const.VideoView, owner: self, options: nil)?.first as! VideoView)
        self.videoView?.isAppearFrom = "Gallery"
        self.videoView?.mainIndex = self.mainIndex
        self.videoView?.currentIndex = self.currentIndex
        self.videoView?.manageVideoDataPost(postObj: self.postObj!, shouldPlay: true)
        self.bgView.addSubview(self.videoView!)
        let screenSize: CGRect = self.frame
        self.videoView?.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height - 150)

        self.videoView?.center = self.bgView.center
        
    }
    
    func addAttachView(){
        self.layoutIfNeeded()
        self.AttachmentCell?.removeFromSuperview()
        self.AttachmentCell = (Bundle.main.loadNibNamed("AttachmentCollectionCell", owner: self, options: nil)?.first as! AttachmentCollectionCell)
        self.AttachmentCell?.manageImageData(postObj: self.postObj!)
        self.bgView.addSubview(self.AttachmentCell!)
        let screenSize: CGRect = self.frame
        self.AttachmentCell?.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: self.contentView.frame.height)
        self.AttachmentCell?.center = self.bgView.center
    }
    
    func addAudioView(){
        self.audioView?.removeFromSuperview()
        self.audioView = (Bundle.main.loadNibNamed(Const.audioView, owner: self, options: nil)?.first as! AudioView)
        self.audioView?.manageAudio(postObj: self.postObj!)
        self.bgView.addSubview(self.audioView!)
        self.audioView?.frame = CGRect(x: 0, y: 0, width: self.bgView.frame.size.width, height: self.bgView.frame.size.height)
    }
    
    func managePostData(postObj:PostFile, mainIndex:IndexPath, currentIndex:IndexPath){
        self.postObj = postObj
        self.mainIndex = mainIndex
        self.currentIndex = currentIndex

        
        if postObj.fileType == FeedType.video.rawValue {
            self.singleImageView?.removeFromSuperview()
            self.audioView?.removeFromSuperview()
            self.addVideoView()
        }else if postObj.fileType == FeedType.audio.rawValue {
//            self.videoView.isHidden = true
//            videoViewUpper.isHidden = true
            self.singleImageView?.removeFromSuperview()
            self.addAudioView()
        }else if postObj.fileType == FeedType.file.rawValue {
//            self.videoView.isHidden = true
//            videoViewUpper.isHidden = true
            self.singleImageView?.removeFromSuperview()
            self.AttachmentCell?.removeFromSuperview()
            self.addAttachView()
        }
    }
    
    func stopPlayingVideo(){
//        if self.videoView != nil {
////            if self.videoView?.playerController != nil {
////                self.videoView?.playerController?.player?.pause()
////            }
//        }
    }
    
    func stopPlayingAudio(){
        if self.audioView != nil {
            if self.audioView?.xqAudioPlayer != nil {
                if self.audioView?.xqAudioPlayer.audioPlayer != nil {
                    self.audioView?.xqAudioPlayer?.audioPlayer!.pause()
                }
            }
        }
    }
    
    func manageSingleImageRemove(){
        self.singleImageView?.removeFromSuperview()
        
    }
}
