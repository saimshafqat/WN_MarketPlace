//
//  ChatCallBackManager.swift
//  WorldNoor
//
//  Created by Raza najam on 2/29/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import Foundation

class ChatCallBackManager: NSObject {
    
    static let shared = ChatCallBackManager()
    var reloadTableAtSpecificIndex:((IndexPath)->())?
    
}
