//
//  SettingVideosCell.swift
//  WorldNoor
//
//  Created by apple on 4/1/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import Foundation
import UIKit

class SettingVideosCell : UITableViewCell , UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    @IBOutlet var collectionViewVideos : UICollectionView!
    
    @IBOutlet var lblVideosHeading : UILabel!
    
    @IBOutlet var lblNoVideoFound : UILabel!
    
    var arrayVideos = [Any]()
    
    
    var delegateVideo : VideoChooseDelegate?
    
    override func awakeFromNib() {
        self.collectionViewVideos.register(UINib.init(nibName: "SettingVideosCollectionCell", bundle: nil), forCellWithReuseIdentifier: "SettingVideosCollectionCell")
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.lblNoVideoFound.isHidden = true
                
        if arrayVideos.count == 0 {
            self.lblNoVideoFound.isHidden = false
        }
        
        return arrayVideos.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cellVideo = collectionView.dequeueReusableCell(withReuseIdentifier: "SettingVideosCollectionCell", for: indexPath) as! SettingVideosCollectionCell
           
        guard let cellVideo = collectionView.dequeueReusableCell(withReuseIdentifier: "SettingVideosCollectionCell", for: indexPath) as? SettingVideosCollectionCell else {
           return UICollectionViewCell()
        }
        
        
        let objMain = self.arrayVideos[indexPath.row]
        cellVideo.viewProgress.isHidden = true
        cellVideo.viewLanguage.isHidden = true
        cellVideo.viewSubmit.isHidden = true
        cellVideo.viewTranspit.isHidden = true
        cellVideo.viewOriginal.isHidden = true
        cellVideo.viewProcessing.isHidden = true
        
        
        if  ((objMain as? SettingVideoModel) != nil) {
            cellVideo.lblName.text = (objMain as! SettingVideoModel).author_name                 
//            cellVideo.imgViewVideo.sd_imageIndicator = SDWebImageActivityIndicator.gray
//            let urlImage = URL.init(string: (objMain as! SettingVideoModel).thumbnail_path)
//            cellVideo.imgViewVideo.sd_setImage(with:urlImage, placeholderImage: UIImage(named: "placeholder.png"))
            
            cellVideo.imgViewVideo.loadImageWithPH(urlMain:(objMain as! SettingVideoModel).thumbnail_path)
            
            self.labelRotateCell(viewMain: cellVideo.imgViewVideo)
             cellVideo.viewTranspit.isHidden = true
            if (objMain as! SettingVideoModel).has_speech_to_text == "1" {
                 cellVideo.viewTranspit.isHidden = false
            }
            
           
            cellVideo.btnTranspit.tag = indexPath.row
            cellVideo.btnTranspit.addTarget(self, action: #selector(self.TranspitAction), for: .touchUpInside)
            
            if (objMain as! SettingVideoModel).file_translation_link.count > 0 {
                cellVideo.viewOriginal.isHidden = false
                cellVideo.btnOriginal.tag = indexPath.row
                cellVideo.btnOriginal.addTarget(self, action: #selector(self.OriginalAction), for: .touchUpInside)
            }
            
        }else if  (objMain as? VideoClipModel != nil){
            cellVideo.lblName.text = (objMain as! VideoClipModel).authorObj.username
//            cellVideo.imgViewVideo.sd_imageIndicator = SDWebImageActivityIndicator.gray
//            let urlImage = URL.init(string: (objMain as! VideoClipModel).thumbnail)
            
            if (objMain as! VideoClipModel).localVideoURL.count > 0 {
                cellVideo.imgViewVideo.image = (objMain as! VideoClipModel).localImage
            }else {
//                cellVideo.imgViewVideo.sd_setImage(with:urlImage, placeholderImage: UIImage(named: "placeholder.png"))
                
                cellVideo.imgViewVideo.loadImageWithPH(urlMain:(objMain as! VideoClipModel).thumbnail)
                
                self.labelRotateCell(viewMain: cellVideo.imgViewVideo)
            }
            
            if (objMain as! VideoClipModel).isProcessing {
                
                cellVideo.viewProcessing.isHidden = false
            }else if (objMain as! VideoClipModel).localVideoURL.count > 0 {
                cellVideo.viewProgress.isHidden = false
                cellVideo.progressLbl.isHidden = false
                
                var newValue = (objMain as! VideoClipModel).processing_status

                if newValue.count == 0 {
                   newValue = "0"
                }else {
                    newValue = newValue.addDecimalPoints(decimalPoint: "2")
                }
                
                if newValue.count > 2 {
//                    newValue = newValue.substr
                }
                
                cellVideo.progressLbl.text = String(Double(newValue)!) + "% " + "Uploading".localized()
                
                if Double(newValue)! == 100.0 {
                    cellVideo.progressLbl.isHidden = true
                    cellVideo.viewLanguage.isHidden = false
                    cellVideo.viewSubmit.isHidden = false
                    
                    if (objMain as! VideoClipModel).languageName.count == 0 {
                        cellVideo.lblLanguage.text = "Language of:".localized()
                    }else {
                        cellVideo.lblLanguage.text = (objMain as! VideoClipModel).languageName
                    }
                    
                    cellVideo.btnViewLanguage.tag = indexPath.row
                    cellVideo.btnViewLanguage.addTarget(self, action: #selector(self.ChooseLanguage), for: .touchUpInside)
                    
                    cellVideo.btnViewSubmit.tag = indexPath.row
                    cellVideo.btnViewSubmit.addTarget(self, action: #selector(self.SubmitAction), for: .touchUpInside)
                    
                }
                
            }
        }
              
                
        cellVideo.imgViewVideo.backgroundColor = UIColor.clear
        cellVideo.btnPlay.tag = indexPath.row
        cellVideo.btnPlay.addTarget(self, action: #selector(self.PlayAciton), for: .touchUpInside)
        return cellVideo
    }
    
    
    @objc func TranspitAction(sender : UIButton){
        
        self.delegateVideo!.TransciptChoose(videoIndex: sender.tag, collectionIndex: collectionViewVideos.tag)
    }
    
    @objc func OriginalAction(sender : UIButton){
        self.delegateVideo?.VideoChooseDelegate(videoIndex: sender.tag + 1000, arrayIndex: collectionViewVideos.tag)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize.init(width: collectionView.frame.size.height, height: collectionView.frame.size.height)
        
        return CGSize.init(width: collectionView.frame.size.width / 2, height: 180)
        
    }
    
    @objc func PlayAciton(sender : UIButton){
        self.delegateVideo?.VideoChooseDelegate(videoIndex: sender.tag, arrayIndex: collectionViewVideos.tag)
    }
    
    @objc func ChooseLanguage(sender : UIButton){
        self.delegateVideo?.VideoChooseDelegate(videoIndex: (sender.tag + 1) * -1, arrayIndex: collectionViewVideos.tag)
    }
    
    @objc func SubmitAction(sender : UIButton){
           
        let objMain = self.arrayVideos[sender.tag]
        
        
        if  (objMain as? VideoClipModel != nil){
            if (objMain as! VideoClipModel).languageName.count == 0 {
            
                self.delegateVideo?.LanguageChoose(videoIndex: -1)
            }else {
                self.delegateVideo?.LanguageChoose(videoIndex: sender.tag)
            }
        }
//           self.delegateVideo?.VideoChooseDelegate(videoIndex: (sender.tag + 1) * -1, arrayIndex: collectionViewVideos.tag)
       }
}


class SettingVideosCollectionCell : UICollectionViewCell {
    @IBOutlet var imgViewVideo : UIImageView!
    @IBOutlet var btnPlay : UIButton!
    
    @IBOutlet var lblName : UILabel!
    
    
    @IBOutlet var viewProgress : UIView!
    @IBOutlet var progressLbl : UILabel!
    
    @IBOutlet var viewProcessing : UIView!
    
    @IBOutlet var viewLanguage : UIView!
    @IBOutlet var lblLanguage : UILabel!
    @IBOutlet var btnViewLanguage : UIButton!
    
    
    @IBOutlet var viewSubmit : UIView!
    @IBOutlet var btnViewSubmit : UIButton!
    
    @IBOutlet var viewTranspit : UIView!
    @IBOutlet var viewOriginal : UIView!
    
    @IBOutlet var btnTranspit : UIButton!
    @IBOutlet var btnOriginal : UIButton!
}





class SettingVideosSectionCell : UITableViewCell , UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    @IBOutlet var collectionViewVideos : UICollectionView!
    
    @IBOutlet var lblVideosHeading : UILabel!
    
    @IBOutlet var lblNoVideoFound : UILabel!
    @IBOutlet var viewLoadMore : UIView!
    @IBOutlet var lblLoadMore : UILabel!
    @IBOutlet var btnLoadMore : UIButton!
    
    
    
    var arrayVideos = [Any]()
    
    
    var delegateVideo : VideoChooseDelegate?
    
    override func awakeFromNib() {
        self.collectionViewVideos.register(UINib.init(nibName: "SettingVideosCollectionCell", bundle: nil), forCellWithReuseIdentifier: "SettingVideosCollectionCell")
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.lblNoVideoFound.isHidden = true
                
        if arrayVideos.count == 0 {
            self.lblNoVideoFound.isHidden = false
        }
        
        return arrayVideos.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cellVideo = collectionView.dequeueReusableCell(withReuseIdentifier: "SettingVideosCollectionCell", for: indexPath) as! SettingVideosCollectionCell
           
        
        guard let cellVideo = collectionView.dequeueReusableCell(withReuseIdentifier: "SettingVideosCollectionCell", for: indexPath) as? SettingVideosCollectionCell else {
           return UICollectionViewCell()
        }
        
        let objMain = self.arrayVideos[indexPath.row]
        cellVideo.viewProgress.isHidden = true
        cellVideo.viewLanguage.isHidden = true
        cellVideo.viewSubmit.isHidden = true
        cellVideo.viewTranspit.isHidden = true
        cellVideo.viewOriginal.isHidden = true
        cellVideo.viewProcessing.isHidden = true
        
        
        if  ((objMain as? SettingVideoModel) != nil) {
            cellVideo.lblName.text = (objMain as! SettingVideoModel).author_name
            cellVideo.imgViewVideo.loadImageWithPH(urlMain:(objMain as! SettingVideoModel).thumbnail_path)
            
            self.labelRotateCell(viewMain: cellVideo.imgViewVideo)
             cellVideo.viewTranspit.isHidden = true
            if (objMain as! SettingVideoModel).has_speech_to_text == "1" {
                 cellVideo.viewTranspit.isHidden = false
            }
            
           
            cellVideo.btnTranspit.tag = indexPath.row
            cellVideo.btnTranspit.addTarget(self, action: #selector(self.TranspitAction), for: .touchUpInside)
            
            if (objMain as! SettingVideoModel).file_translation_link.count > 0 {
                cellVideo.viewOriginal.isHidden = false
                cellVideo.btnOriginal.tag = indexPath.row
                cellVideo.btnOriginal.addTarget(self, action: #selector(self.OriginalAction), for: .touchUpInside)
            }
            
        }else if  (objMain as? VideoClipModel != nil){
            cellVideo.lblName.text = (objMain as! VideoClipModel).authorObj.username
//            cellVideo.imgViewVideo.sd_imageIndicator = SDWebImageActivityIndicator.gray
//            let urlImage = URL.init(string: (objMain as! VideoClipModel).thumbnail)
            
            if (objMain as! VideoClipModel).localVideoURL.count > 0 {
                cellVideo.imgViewVideo.image = (objMain as! VideoClipModel).localImage
            }else {
//                cellVideo.imgViewVideo.sd_setImage(with:urlImage, placeholderImage: UIImage(named: "placeholder.png"))
                
                cellVideo.imgViewVideo.loadImageWithPH(urlMain:(objMain as! VideoClipModel).thumbnail)
                
                self.labelRotateCell(viewMain: cellVideo.imgViewVideo)
            }
            
            if (objMain as! VideoClipModel).isProcessing {
                
                cellVideo.viewProcessing.isHidden = false
            }else if (objMain as! VideoClipModel).localVideoURL.count > 0 {
                cellVideo.viewProgress.isHidden = false
                cellVideo.progressLbl.isHidden = false
                
                var newValue = (objMain as! VideoClipModel).processing_status

                if newValue.count == 0 {
                   newValue = "0"
                }else {
                    newValue = newValue.addDecimalPoints(decimalPoint: "2")
                }
                
                if newValue.count > 2 {
//                    newValue = newValue.substr
                }
                
                cellVideo.progressLbl.text = String(Double(newValue)!) + "% " + "Uploading".localized()
                
                if Double(newValue)! == 100.0 {
                    cellVideo.progressLbl.isHidden = true
                    cellVideo.viewLanguage.isHidden = false
                    cellVideo.viewSubmit.isHidden = false
                    
                    if (objMain as! VideoClipModel).languageName.count == 0 {
                        cellVideo.lblLanguage.text = "Language of:".localized()
                    }else {
                        cellVideo.lblLanguage.text = (objMain as! VideoClipModel).languageName
                    }
                    
                    cellVideo.btnViewLanguage.tag = indexPath.row
                    cellVideo.btnViewLanguage.addTarget(self, action: #selector(self.ChooseLanguage), for: .touchUpInside)
                    
                    cellVideo.btnViewSubmit.tag = indexPath.row
                    cellVideo.btnViewSubmit.addTarget(self, action: #selector(self.SubmitAction), for: .touchUpInside)
                    
                }
                
            }
        }
              
                
        cellVideo.imgViewVideo.backgroundColor = UIColor.white
        cellVideo.btnPlay.tag = indexPath.row
        cellVideo.btnPlay.addTarget(self, action: #selector(self.PlayAciton), for: .touchUpInside)
        return cellVideo
    }
    
    
    @objc func TranspitAction(sender : UIButton){
        
        self.delegateVideo!.TransciptChoose(videoIndex: sender.tag, collectionIndex: collectionViewVideos.tag)
    }
    
    @objc func OriginalAction(sender : UIButton){
        self.delegateVideo?.VideoChooseDelegate(videoIndex: sender.tag + 1000, arrayIndex: collectionViewVideos.tag)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize.init(width: collectionView.frame.size.width / 2, height: 180)
        
    }
    
    @objc func PlayAciton(sender : UIButton){
        self.delegateVideo?.VideoChooseDelegate(videoIndex: sender.tag, arrayIndex: collectionViewVideos.tag)
    }
    
    @objc func ChooseLanguage(sender : UIButton){
        self.delegateVideo?.VideoChooseDelegate(videoIndex: (sender.tag + 1) * -1, arrayIndex: collectionViewVideos.tag)
    }
    
    @objc func SubmitAction(sender : UIButton){
           
        let objMain = self.arrayVideos[sender.tag]
        
        
        if  (objMain as? VideoClipModel != nil){
            if (objMain as! VideoClipModel).languageName.count == 0 {
            
                self.delegateVideo?.LanguageChoose(videoIndex: -1)
            }else {
                self.delegateVideo?.LanguageChoose(videoIndex: sender.tag)
            }
        }
       }
}
