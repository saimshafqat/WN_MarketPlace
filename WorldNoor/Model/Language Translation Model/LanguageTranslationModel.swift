//
//  LanguageTranslationModel.swift
//  WorldNoor
//
//  Created by Muhammad Asher on 03/06/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit

class LanguageTranslateModel: Codable {
    
    var action: String?
    var data : [LanguageTranslateDetailModel] = []
    var meta : Meta?
    
    enum CodingKeys: CodingKey {
        case data
        case meta
        case action
    }
    
    convenience required init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.action = try container.decode(String.self, forKey: .action)
        self.meta = try container.decode(Meta.self, forKey: .meta)
        self.data = try container.decode([LanguageTranslateDetailModel].self, forKey: .data)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.action, forKey: .action)
        try container.encodeIfPresent(self.data, forKey: .data)
        try container.encodeIfPresent(self.meta, forKey: .meta)
    }
}

