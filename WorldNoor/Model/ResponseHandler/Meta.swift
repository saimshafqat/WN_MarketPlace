//
//  Meta.swift
//  WorldNoor
//
//  Created by Raza najam on 10/7/19.
//  Copyright © 2019 Raza najam. All rights reserved.
//


import Foundation
struct Meta : Codable {
	let code : Int?
	let message : String?
    let is_public_posts_feed : Bool?
    
	enum CodingKeys: String, CodingKey {
		case code = "code"
		case message = "message"
        case is_public_posts_feed = "is_public_posts_feed"
	}
    
	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		code = try values.decodeIfPresent(Int.self, forKey: .code)
		message = try values.decodeIfPresent(String.self, forKey: .message)
        is_public_posts_feed = try values.decodeIfPresent(Bool.self, forKey: .is_public_posts_feed)
//      is_public_posts_feed = try values.decodeIfPresent(Int.self, forKey: .is_public_posts_feed)
	}
}
