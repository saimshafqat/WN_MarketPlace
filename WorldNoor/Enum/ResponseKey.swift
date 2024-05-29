//
//  ResponseKey.swift
//  WorldNoor
//
//  Created by Raza najam on 10/7/19.
//  Copyright © 2019 Raza najam. All rights reserved.
//

import Foundation

enum ResponseKey:Int {
    case successResp = 200
    case failureResp = 422
    case unAuthorizedResp = 401
    case unAuthorizedRespForNode = 400
    case serverErrorResp = 500
    case forbiddenResp = 403
}
