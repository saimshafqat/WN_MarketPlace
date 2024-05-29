//
//  FeedUploadingView.swift
//  WorldNoor
//
//  Created by Raza najam on 6/30/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import UIKit


class FeedUploadingView: UIView {
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var langLbl: UILabel!
    @IBOutlet weak var langBtn: UIButton!
    
    func manageData(uploadObj:FeedUpload){
        self.manageLanguage(uploadObj: uploadObj)
        if uploadObj.type == "audio" {
            self.imgView.image = UIImage(named: "musicUpload")
        }else if uploadObj.type == "video" {
            
        }else if uploadObj.type == "attachment" {
            if uploadObj.fileExt == "pdf" {
                self.imgView.image = UIImage.init(named: "PDFIcon.png")
            }else if uploadObj.fileExt == "doc" || uploadObj.fileExt == "docx"{
                self.imgView.image = UIImage.init(named: "WordFile.png")
            }else if uploadObj.fileExt == "xls" || uploadObj.fileExt == "xlsx"{
                self.imgView.image = UIImage.init(named: "ExcelIcon.png")
            }else if  uploadObj.fileExt == "zip"{
                self.imgView.image = UIImage.init(named: "ZipIcon.png")
            }else if  uploadObj.fileExt == "pptx"{
                self.imgView.image = UIImage.init(named: "pptIcon.png")
            }else {
                self.imgView.image = UIImage.init(named: "PDFIcon.png")
            }
        }else if uploadObj.type == "GIF" {
//            self.imgView.sd_setImage(with: URL(string: uploadObj.imageUrl), placeholderImage: UIImage(named: "placeholder.png"))
            
            self.imgView.loadImageWithPH(urlMain:uploadObj.imageUrl)
            
            self.labelRotateCell(viewMain: self.imgView)
        }
        if let imageData = NSData(contentsOf: URL(fileURLWithPath: uploadObj.imageUrl)) {
            let image = UIImage(data: imageData as Data) // Here you can attach image to UIImageView
            self.imgView.image = image
        }
        if uploadObj.isImageExist {
            self.imgView.image = uploadObj.imageObj
        }
    }
    
    func manageLanguage(uploadObj:FeedUpload) {
        self.langLbl.isHidden = true
        self.langBtn.isHidden = true
        if uploadObj.isLangRequired {
            self.langLbl.isHidden = false
            self.langBtn.isHidden = false
            if uploadObj.isLangSelected {
                self.langLbl.text = String(format: "Language of".localized() + " %@:%@", uploadObj.type, uploadObj.languageName)
            }
        }
    }
}
