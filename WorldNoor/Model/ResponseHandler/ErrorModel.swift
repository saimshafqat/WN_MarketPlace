//
//  ErrorModel.swift
//  WorldNoor
//
//  Created by Raza najam on 10/7/19.
//  Copyright © 2019 Raza najam. All rights reserved.
//

import Foundation

struct ErrorModel : Codable, LocalizedError {
    
    let action : String?
    let meta : Meta?

    enum CodingKeys: String, CodingKey {
        case action = "action"
        case meta = "meta"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        action = try values.decodeIfPresent(String.self, forKey: .action)
        meta = try values.decodeIfPresent(Meta.self, forKey: .meta)
    }
}
