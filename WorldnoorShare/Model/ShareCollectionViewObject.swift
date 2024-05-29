//
//  ShareCollectionViewObject.swift
//  WorldnoorShare
//
//  Created by Raza najam on 7/6/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import UIKit

class ShareCollectionViewObject : NSObject {
    var imageMain : UIImage!
    var imageUrl = ""
    var id:String = ""
    var videoURL : URL!
    var isType = PostDataType.Empty
    var photoUrl:URL!
    var messageBody:String!
    var langID:String = ""
    var langName:String = ""

    var isEditPost:Bool = false
    var isUploading = false
    var thumbURL:String = ""
    var hashString:String = ""
    var fileUrl:String = ""
    
    override init() {
        
    }
    
    init(dict:NSDictionary) {
        super.init()
        self.isUploading = true
        if let thumb = dict["thumbnail"] as? [String:Any] {
            self.thumbURL = self.ReturnValueAsString(value: thumb["url"] as Any)
        }
        if let url = dict["url"] {
            self.hashString = self.ReturnValueAsString(value:url as Any)
        }
        if let langObjID = dict["language_id"] {
            self.langID = self.ReturnValueAsString(value:langObjID as Any)
        }
    }
    
    func getPostData(respArray:NSArray) -> [ShareCollectionViewObject]{
        var postArray:[ShareCollectionViewObject] = [ShareCollectionViewObject]()
        for data in respArray {
            postArray.append(ShareCollectionViewObject.init(dict: data as! NSDictionary))
        }
        return postArray
    }
    
    func ReturnValueAsString(value : Any) -> String{
        if let MainValue = value as? Int {
            return String(MainValue)
        }else  if let MainValue = value as? String {
            return MainValue
        }else  if let MainValue = value as? Double {
            return String(MainValue)
        }
        return ""
    }
    
    func ReturnValueAsBool(value : Any) -> Bool{
        if let MainValue = value as? Int {
            if MainValue == 1 {
                return true
            }
        }else  if let MainValue = value as? String {
            if MainValue == "1" {
                return true
            }
        }
        return false
    }

}
