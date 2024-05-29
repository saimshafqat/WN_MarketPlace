//
//  FeedDetailUploadView.swift
//  WorldNoor
//
//  Created by Raza najam on 7/2/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import UIKit

class FeedDetailUploadView: UIView {
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
    
    func handlingUploadFeedView(fileType:String, selectLang:Bool = false, videoUrl:String = "", imgUrl:String = "", isPosting:Bool = false, imageObj:UIImage = UIImage(), isImageObjExist:Bool = false, fileExt:String = "") -> FeedUpload {
         let uploadObj:FeedUpload = FeedUpload(body:"", firstName: SharedManager.shared.getFirstName(), lastName: SharedManager.shared.getlastName(), profileImage: SharedManager.shared.getProfileImage(), isPosting:true, identifierStr:"", fileType: fileType, selectLanguage: selectLang, videoUrlToUpload: videoUrl, imgUrl:imgUrl, imageObj: imageObj, isImageObjExist: isImageObjExist, fileExt: fileExt)
        self.manageData(uploadObj:uploadObj)
        return uploadObj
    }
    
}
