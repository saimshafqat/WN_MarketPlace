//
//  TokenHeader.swift
//  WorldNoor
//
//  Created by Muhammad Asher on 31/05/2023.
//

import Foundation

enum TokenHeader {
    
    private static var apiToken: String {
        return SharedManager.shared.userToken()
    }
    
    private static var bearerHeaderToken: String {
        return "Bearer " + AppConfigurations().HeaderToken
    }
    
    public static var header: Headers {
        var header: Headers = [:]
        let authorization = TokenHeader.bearerHeaderToken
        let token = TokenHeader.apiToken
        var jwtToken: String = .emptyString
        let userObj = SharedManager.shared.userObj
        if userObj != nil && userObj?.data.jwtToken?.count ?? 0 > 0 {
            jwtToken = userObj?.data.jwtToken ?? .emptyString
        }
        header = [
            Const.ResponseKey.accept : "application/Json",
            Const.ResponseKey.jwtToken : jwtToken,
            Const.ResponseKey.authorization : authorization
        ]
        if token.count > 0 {
            header[Const.ResponseKey.token] = token
        }
        return header
    }
}
