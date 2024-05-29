//
//  ActionEvent.swift
//  mediasoup-ios-cient-sample
//
//  Created by Moeez.
//  Copyright © 2019 Moeez. All rights reserved.
//

import Foundation

final internal class ActionEvent {
    public static let CONSUME_TRANSPORT: String = "room:consume-transport"
    public static let RESUME_CONSMUER_NEW: String = "room:resume-consumer"
    public static let CREATE_WEBRTC_TRANSPORT: String = "room:create-transport"
    public static let CONNECT_WEBRTC_TRANSPORT: String = "room:connect-transport"
    public static let PRODUCE: String = "room:produce-transport"
    public static let RESTART_ICE: String = "room:restart-ice"
    public static let NEW_CONSUMER: String = "room:new-consumer"
    public static let ROOM_REQUEST_JOIN = "room:request-join"
    public static let ROOM_JOINED = "room:joined"
    public static let ROOM_POST_JOIN_DATA = "room:get-post-join-data"

    public static let ROOM_RECONNECTED = "room:reconnected"
    public static let ROOM_LEFT = "room:left"
    public static let VIDEO_SWITCHED = "room:video-switched"
    public static let AUDIO_SWITCHED = "room:audio-switched"
    public static let ROOM_ENDED = "room:ended"

    
}
