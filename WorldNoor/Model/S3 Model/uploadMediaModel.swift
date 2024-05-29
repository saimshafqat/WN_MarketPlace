//
//  uploadMediaModel.swift
//  WorldNoor
//
//  Created by Waseem Shah on 21/02/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import Foundation


class uploadMediaModel: Codable {
    let action:String?
    let data :  [uploadMediaArray]?
    let meta : Meta?
}


class uploadMediaArray: Codable {
    let fileName : String?
    let fileUrl : String?
    let preSignedUrl : String?
}
