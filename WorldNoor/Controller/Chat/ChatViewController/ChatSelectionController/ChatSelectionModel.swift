//
//  ChatSelectionModel.swift
//  WorldNoor
//
//  Created by Awais on 23/02/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import Foundation

struct ChatSelectionModel {
    var name: String
    var id: Int
    var image: String
        
    init(name: String, id: Int, image: String) {
        self.name = name
        self.id = id
        self.image = image
    }
}
