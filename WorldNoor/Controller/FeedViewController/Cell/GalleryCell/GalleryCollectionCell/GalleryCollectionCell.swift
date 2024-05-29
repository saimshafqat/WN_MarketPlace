//
//  GalleryCollectionCell.swift
//  WorldNoor
//
//  Created by Raza najam on 11/16/19.
//  Copyright © 2019 Raza najam. All rights reserved.
//

import UIKit

class GalleryCollectionCell: UICollectionViewCell {
    @IBOutlet weak var bgView: UIView!
    var postObj:PostFile? = nil
    var singleImageView:SingleImageView? = nil
    var videoView:VideoView? = nil
    var audioView:AudioView? = nil
    var mainIndex = IndexPath()
    var currentIndex = IndexPath()
    var isAppearFrom = ""
    var isFromFeed = false
    
    override func awakeFromNib() {
        
    }
    
    func addImageView(){
        self.singleImageView?.removeFromSuperview()
        self.singleImageView = (Bundle.main.loadNibNamed(Const.SingleImageView, owner: self, options: nil)?.first as! SingleImageView)
        
        if isFromFeed {
            self.singleImageView?.manageImageDataForFeed(postObj: self.postObj!)
        }else {
            self.singleImageView?.manageImageData(postObj: self.postObj!)
        }
        
        self.bgView.addSubview(self.singleImageView!)
        self.singleImageView?.btnDownload.addTarget(self, action: #selector(self.downloadFile), for: .touchUpInside)
        self.singleImageView?.frame = CGRect(x: 0, y: 0, width: self.bgView.frame.size.width, height: self.bgView.frame.size.height)
    }
    
//    func addVideoView(){
//        self.videoView?.removeFromSuperview()
//        self.videoView = (Bundle.main.loadNibNamed(Const.VideoView, owner: self, options: nil)?.first as! VideoView)
//        self.videoView?.currentIndex = self.currentIndex
//        self.videoView?.mainIndex = self.mainIndex
//        self.videoView?.isAppearFrom = isAppearFrom
//        self.videoView?.isPartOf = "Gallery"
//        self.videoView?.manageVideoDataPost(postObj: self.postObj!, shouldPlay: true)
//        self.bgView.addSubview(self.videoView!)
//        self.videoView?.frame = CGRect(x: 0, y: 0, width: self.bgView.frame.size.width, height: self.bgView.frame.size.height)
//        self.videoView?.viewOgrinalLangBtn.addTarget(self, action: #selector(viewOrignalBtnClicked), for: .touchUpInside)
//    }
    
    @objc func downloadFile(){
     
        if isAppearFrom == "Feed" {
            FeedCallBManager.shared.downloadShareFile?(self.mainIndex , self.currentIndex)
        }
    }
    
    @objc func viewTranscriptBtnClicked(){

    }
    
    @objc func viewOrignalBtnClicked(){
        self.videoView?.viewOgrinalLangBtn.isSelected = !(self.videoView?.viewOgrinalLangBtn.isSelected)!
        if (self.videoView?.viewOgrinalLangBtn.isSelected)! {
            self.videoView?.manageVideoDataPost(postObj: self.postObj!, shouldPlay: true, isShowTranslated: false)
        }else {
            self.videoView?.manageVideoDataPost(postObj: self.postObj!, shouldPlay: true)
        }
    }
    
    func addAudioView(){
        self.audioView?.removeFromSuperview()
        self.audioView = (Bundle.main.loadNibNamed(Const.audioView, owner: self, options: nil)?.first as! AudioView)
        self.audioView?.manageAudio(postObj: self.postObj!)
        self.bgView.addSubview(self.audioView!)
        self.audioView?.frame = CGRect(x: 0, y: 0, width: self.bgView.frame.size.width, height: self.bgView.frame.size.height)
    }
    
    
    func managePostData(postObj:PostFile, mainIndex:IndexPath, currentIndex:IndexPath, isAppearFrom:String){
        self.postObj = postObj
        self.isAppearFrom = isAppearFrom
        self.mainIndex = mainIndex
        self.currentIndex = currentIndex
        if postObj.fileType == FeedType.image.rawValue {
            self.addImageView()
            self.videoView?.removeFromSuperview()
            self.audioView?.removeFromSuperview()
        }else if postObj.fileType == FeedType.video.rawValue {
            self.singleImageView?.removeFromSuperview()
            self.audioView?.removeFromSuperview()
//            self.addVideoView()
            self.addImageView()
        }else if postObj.fileType == FeedType.audio.rawValue {
//            self.singleImageView?.removeFromSuperview()
//            self.videoView?.removeFromSuperview()
//            self.addAudioView()
        }else if postObj.fileType == FeedType.file.rawValue {
            self.addImageView()
            self.videoView?.removeFromSuperview()
            self.audioView?.removeFromSuperview()
        }
    }
    
    func stopPlayingVideo(){
        if self.videoView != nil {
            if self.videoView?.playerController != nil {
                self.videoView?.playerController?.player?.pause()
            }
        }
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



