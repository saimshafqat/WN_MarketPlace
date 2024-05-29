
//
//  AttachmentView.swift
//  WorldNoor
//
//  Created by Raza najam on 6/10/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import UIKit

class AttachmentView: UIView {
    
    @IBOutlet var imgViewIcon : UIImageView!
    @IBOutlet var lblFileName : UILabel!
    @IBOutlet var btnDownload : UIButton!
    
    func reloadView(feedObj:FeedData){
        let name2 = feedObj.post?.first?.filePath!.components(separatedBy: "/")
        self.lblFileName.text = name2!.last!
        let urlmain = feedObj.post!.first!.filePath!.components(separatedBy: ".")
        if urlmain.last == "pdf" {
            self.imgViewIcon.image = UIImage.init(named: "PDFIcon.png")
        }else if urlmain.last == "doc" || urlmain.last == "docx"{
            self.imgViewIcon.image = UIImage.init(named: "WordFile.png")
        }else if urlmain.last == "xls" || urlmain.last == "xlsx"{
            self.imgViewIcon.image = UIImage.init(named: "ExcelIcon.png")
        }else if  urlmain.last == "zip"{
            self.imgViewIcon.image = UIImage.init(named: "ZipIcon.png")
        }else if  urlmain.last == "pptx"{
            self.imgViewIcon.image = UIImage.init(named: "pptIcon.png")
        }else {
            self.imgViewIcon.image = UIImage.init(named: "PDFIcon.png")
        }
    }
    
    func manageaAttachment(commentFileObj:CommentFile){
           let name2 = commentFileObj.filePath?.components(separatedBy: "/")
            self.lblFileName.text = name2?.last!
           let urlmain = commentFileObj.filePath!.components(separatedBy: ".")
           if urlmain.last == "pdf" {
               self.imgViewIcon.image = UIImage.init(named: "PDFIcon.png")
           }else if urlmain.last == "doc" || urlmain.last == "docx"{
               self.imgViewIcon.image = UIImage.init(named: "WordFile.png")
           }else if urlmain.last == "xls" || urlmain.last == "xlsx"{
               self.imgViewIcon.image = UIImage.init(named: "ExcelIcon.png")
           }else if  urlmain.last == "zip"{
               self.imgViewIcon.image = UIImage.init(named: "ZipIcon.png")
           }else if  urlmain.last == "pptx"{
               self.imgViewIcon.image = UIImage.init(named: "pptIcon.png")
           }else {
               self.imgViewIcon.image = UIImage.init(named: "PDFIcon.png")
           }
       }
    
}
