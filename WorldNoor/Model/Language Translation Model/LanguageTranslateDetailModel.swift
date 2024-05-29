//
//  LanguageTranslateDetailModel.swift
//  WorldNoor
//
//  Created by Muhammad Asher on 03/06/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit

class LanguageTranslateDetailModel: Codable {
    
    var body: String?
    
    enum CodingKeys: CodingKey {
        case body
    }
    
    convenience required init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.body = try container.decodeIfPresent(String.self, forKey: .body)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.body, forKey: .body)
    }
}
