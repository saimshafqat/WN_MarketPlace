//
//  SignalingMessage.swift
//  kalam
//
//  Created by mac on 04/12/2019.
//  Copyright © 2019 apple. All rights reserved.
//

import Foundation

struct SignalingMessage: Codable {
    let type: String
    let offer: SDP?
    let candidate: Candidate?
    let phone: String?
    let photoUrl: String?
    let name: String?
    let connectedUserId: String
    let isVideo: Bool?
    let callId: String
    let chatId: String
    let sessionId: String?
    let socketId: String?


}
struct Available: Codable {
    let type: String
    let connectedUserId: String
    let isAvailable: Bool?
    let reason: String?
    let name: String?
    let callId: String
    let chatId: String
    let photoUrl: String?
    let isVideo: Bool?
    let isBusy: Bool?
    let sessionId: String?
    let socketId: String?
    let callType:String?
    let roomId:String?

    

}

struct SDP: Codable {
    let sdp: String
    

}

struct Candidate: Codable {
    let sdp: String
    let sdpMLineIndex: Int32
    let sdpMid: String


}
