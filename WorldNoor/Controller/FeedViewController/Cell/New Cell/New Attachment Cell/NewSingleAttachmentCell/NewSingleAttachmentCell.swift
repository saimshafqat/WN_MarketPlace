//
//  NewSingleAttachmentCell.swift
//  WorldNoor
//
//  Created by apple on 11/12/21.
//  Copyright © 2021 Raza najam. All rights reserved.
//

import Foundation
import UIKit

class NewSingleAttachmentCell : UITableViewCell {
    
    var feedObj:FeedData?
    
    @IBOutlet weak var imgviewFileIcon: UIImageView!
    @IBOutlet weak var lblFileName: UILabel!
    
    @IBOutlet weak var btnDownload: UIButton!
    @IBOutlet weak var lblDownload: UILabel!
    
    override func awakeFromNib() {
        
        self.contentView.rotateViewForLanguage()
        super.awakeFromNib()
    }
    
    @IBAction func downloadAction(sender : UIButton) {
        
//        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // your code here
            
            do {
                let imageData = try Data(contentsOf: URL.init(string: (self.feedObj!.post?.first!.filePath)!)!)
                let activityViewController = UIActivityViewController(activityItems: [ imageData], applicationActivities: nil)
                activityViewController.excludedActivityTypes = SharedManager.shared.excludingArray
                UIApplication.topViewController()!.present(activityViewController, animated: true) {
//                    SharedManager.shared.hideLoadingHubFromKeyWindow()
                    Loader.stopLoading()
                }
                
            } catch {

            }
        }
    }
    
    //Manage Feed Data inside cell...
    func manageCellData(feedObj:FeedData) {
        self.feedObj = feedObj
        self.lblFileName.rotateViewForLanguage()
        self.lblFileName.rotateForTextAligment()
        self.lblDownload.rotateViewForLanguage()
        self.imgviewFileIcon.rotateViewForLanguage()
        
        if SharedManager.shared.checkLanguageAlignment() {
            self.lblFileName.textAlignment = .right
        }else {
            self.lblFileName.textAlignment = .left
        }
        
        if feedObj.postType == FeedType.file.rawValue {
            
            if feedObj.post!.count > 0 {
                 let urlmain = feedObj.post!.first!.filePath!.components(separatedBy: ".")
                            
                let name2 = feedObj.post?.first?.filePath!.components(separatedBy: "/")
                
                self.lblFileName.text = name2!.last!
                
                if urlmain.last == "pdf" {
                   self.imgviewFileIcon.image = UIImage.init(named: "PDFIcon.png")
               }else if urlmain.last == "doc" || urlmain.last == "docx"{
                   self.imgviewFileIcon.image = UIImage.init(named: "WordFile.png")
               }else if urlmain.last == "xls" || urlmain.last == "xlsx"{
                   self.imgviewFileIcon.image = UIImage.init(named: "ExcelIcon.png")
               }else if  urlmain.last == "zip"{
                   self.imgviewFileIcon.image = UIImage.init(named: "ZipIcon.png")
               }else if  urlmain.last == "pptx"{
                   self.imgviewFileIcon.image = UIImage.init(named: "pptIcon.png")
               }else {
                   self.imgviewFileIcon.image = UIImage.init(named: "PDFIcon.png")
                           
                }
            }
           
            
        }
        
        
    }
    

}

