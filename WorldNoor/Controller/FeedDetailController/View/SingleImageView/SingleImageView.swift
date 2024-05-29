//
//  SingleImageView.swift
//  WorldNoor
//
//  Created by Raza najam on 10/21/19.
//  Copyright © 2019 Raza najam. All rights reserved.
//

import UIKit
import SDWebImage
import SDWebImageWebPCoder
import Kingfisher


class SingleImageView: ParentFeedView {
    let myArray:[String] = ["5.jpg","6.jpg", "7.jpg","8.jpg"]
    
    @IBOutlet weak var userImageView: UIImageView!
    
    @IBOutlet weak var viewDownload: UIView!
    
    @IBOutlet weak var viewPlay: UIView!
    
    @IBOutlet weak var btnDownload: UIButton!
    
    func manageImageData(feedObj:FeedData){
        if feedObj.post!.count > 0 {
            let postFile:PostFile = feedObj.post![0]
            
            self.userImageView.loadImageWithPH(urlMain:postFile.filePath ?? "")
            
            self.labelRotateCell(viewMain: self.userImageView)
            
        }
    }
    
    func manageImageData(postObj:PostFile){
        
        self.viewPlay.isHidden = true
        self.viewDownload.isHidden = true
        if postObj.fileType == FeedType.file.rawValue {
            
            self.viewDownload.isHidden = false
            let urlmain = postObj.filePath?.components(separatedBy: ".")
            
            if urlmain!.last == "pdf" {
                self.userImageView.image = UIImage.init(named: "PDFIconS.png")
            }else if urlmain!.last == "doc" || urlmain!.last == "docx"{
                self.userImageView.image = UIImage.init(named: "WordFileS.png")
            }else if urlmain!.last == "xls" || urlmain!.last == "xlsx"{
                self.userImageView.image = UIImage.init(named: "ExcelIconS.png")
            }else if  urlmain!.last == "zip"{
                self.userImageView.image = UIImage.init(named: "ZipIconS.png")
            }else if  urlmain!.last == "pptx"{
                self.userImageView.image = UIImage.init(named: "pptIconS.png")
            }else {
                self.userImageView.image = UIImage.init(named: "PDFIconS.png")
            }
            
            
        }else {
            
            
            let filepath = postObj.filePath?.split(separator: ".")

            if filepath!.count > 0 {
                if filepath?.last == "webp" {
                    self.userImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
                    let webPCoder = SDImageWebPCoder.shared
                        SDImageCodersManager.shared.addCoder(webPCoder)
                    guard let webpURL = URL(string:  postObj.filePath!)  else {return}
                        DispatchQueue.main.async {
                            self.userImageView.sd_setImage(with: webpURL)
                        }
                } else {
                    if postObj.fileType == FeedType.video.rawValue {
//                        self.viewPlay.isHidden = false
                        self.userImageView.kf.indicatorType = .activity
                        self.userImageView.kf.setImage(
                            with: URL(string:  postObj.thumbnail ?? .emptyString),
                            placeholder: UIImage(named: "placeholder.png"),
                            options: [
    //                            .transition(.fade(1)),
    //                            .cacheOriginalImage
                            ])
                        {
                            result in
                            
                            switch result {
                            case .success(let value):
                                LogClass.debugLog("Task done for: \(value.source.url?.absoluteString ?? "")")
                            case .failure(let error):
                                LogClass.debugLog("Job failed: \(error.localizedDescription)")
                            }
                        }
                    }else {
                        self.userImageView.kf.indicatorType = .activity
                        self.userImageView.kf.setImage(
                            with: URL(string:  postObj.filePath!),
                            placeholder: UIImage(named: "placeholder.png"),
                            options: [
    //                            .transition(.fade(1)),
    //                            .cacheOriginalImage
                            ])
                        {
                            result in
                            
                            switch result {
                            case .success(let value):
                                LogClass.debugLog("Task done for: \(value.source.url?.absoluteString ?? "")")
                            case .failure(let error):
                                LogClass.debugLog("Job failed: \(error.localizedDescription)")
                            }
                        }
                       
                    }
                    
                }
            }else {
                self.userImageView.sd_setImage(with: URL(string: postObj.filePath ?? ""), placeholderImage: UIImage(named: "placeholder.png"))
            }

            self.userImageView.contentMode = .scaleAspectFill
            self.userImageView.clipsToBounds = true
            self.labelRotateCell(viewMain: self.userImageView)
        }
    }
    
    
    
    func manageImageDataForFeed(postObj:PostFile){
        
        self.viewDownload.isHidden = true
        if postObj.fileType == FeedType.file.rawValue {
            
            self.viewDownload.isHidden = false
            let urlmain = postObj.filePath?.components(separatedBy: ".")
            
            if urlmain!.last == "pdf" {
                self.userImageView.image = UIImage.init(named: "PDFIconS.png")
            }else if urlmain!.last == "doc" || urlmain!.last == "docx"{
                self.userImageView.image = UIImage.init(named: "WordFileS.png")
            }else if urlmain!.last == "xls" || urlmain!.last == "xlsx"{
                self.userImageView.image = UIImage.init(named: "ExcelIconS.png")
            }else if  urlmain!.last == "zip"{
                self.userImageView.image = UIImage.init(named: "ZipIconS.png")
            }else if  urlmain!.last == "pptx"{
                self.userImageView.image = UIImage.init(named: "pptIconS.png")
            }else {
                self.userImageView.image = UIImage.init(named: "PDFIconS.png")
            }
            
            
        }else {
//            self.userImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
//            self.userImageView.sd_setImage(with: URL(string: postObj.filePath ?? ""), placeholderImage: UIImage(named: "placeholder.png"))
            
            self.userImageView.loadImageWithPH(urlMain:postObj.filePath ?? "")
            
            self.userImageView.contentMode = .scaleAspectFit
            self.userImageView.clipsToBounds = true
            self.labelRotateCell(viewMain: self.userImageView)
        }
        
//        self.labelRotateCell(viewMain: self.userImageView)
    }
    
    func manageImageDataForFeedComment(commentFileObj:CommentFile){
        
        if commentFileObj.url!.count > 0 {
            self.userImageView.loadImageWithPH(urlMain:commentFileObj.url ?? "")
        }else {
            self.userImageView.image = commentFileObj.localImage
            
            
        }
        self.labelRotateCell(viewMain: self.userImageView)
        self.labelRotateCell(viewMain: self.userImageView)
    }
    
    func manageImageData(indexValue:Int){
        self.userImageView.contentMode = .scaleAspectFit
        self.userImageView.image = UIImage(named: myArray[indexValue])
        
//        self.labelRotateCell(viewMain: self.userImageView)
        
    }
}
