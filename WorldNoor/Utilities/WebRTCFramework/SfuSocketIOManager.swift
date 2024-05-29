//
//  SocketIOManager.swift
//  socketio
//
//  Created by apple on 10/23/19.
//  Copyright © 2019 apple. All rights reserved.
//

import Foundation
import SocketIO
import WebRTC
import CryptoKit
import Security

////////////call delegates//////////////////

protocol SfuSocketDelegateCallmanager {
    
    func didSocketConnected(data: [Any])
    func didSocketDisConnected(data: [Any])
    func didReceiveCanMakeConnection(data: [String :Any])
    func didReceiveRoomJoined(data: [String :Any])
    func didReceiveNewProducer(data: [String:Any])
    func didReceiveUserleft(data: [String:Any])
    func didReceiveVideoSwitched(data: [String:Any])
    func didReceiveUserReconnecting(data: [String:Any])
    func didReceiveUserReconnected(data: [String:Any])
    
}

extension SfuSocketDelegateCallmanager {
    //default implementation for optional methods
    
    func didSocketConnected(data: [Any]) {}
    func didSocketDisConnected(data: [Any]) {}
    func didReceiveCanMakeConnection(data: [String :Any]){}
    func didReceiveRoomJoined(data: [String :Any]) {}
    func didReceiveNewProducer(data: [String:Any]) {}
    func didReceiveUserleft(data: [String:Any]) {}
    func didReceiveVideoSwitched(data: [String:Any]) {}
    func didReceiveUserReconnecting(data: [String:Any]){}
    func didReceiveUserReconnected(data: [String:Any]) {}

}

////////////messaging delegates//////////////////



class SfuSocketIOManager: NSObject {
    
    static let sharedInstance = SfuSocketIOManager()
    var socket:SocketIOClient!
    var name: String?
    var resetAck: SocketAckEmitter?
    var sfudelegateCallmanager: SfuSocketDelegateCallmanager?
    var socketTimeout = 10
    var manager: SocketManager?
    

    // MARK: - socket init methods
    override init() {
        super.init()
    }
    
    func establishConnection() {
        manager = SocketManager(socketURL: URL(string: AppConfigurations.mizdahUrl)!, config: [.log(false), .connectParams(["user_id":SharedManager.shared.userObj?.data.id ?? 0 ]),.forceWebsockets(true)])
        
        socket = manager?.defaultSocket
        manager?.forceNew = true
        manager?.reconnects = true
        manager?.reconnectWaitMax = 0
        manager?.reconnectWait = 0
        socket?.connect()
        addHandlers()
       
    }
    
    func closeConnection() {
        if socket != nil {
            socket?.disconnect()
            socket?.removeAllHandlers()
            manager = nil
            socket = nil
        }
    }
    
    // MARK: - socket background emit methods related to call
    
    func senddidenterBackground(dictionary:[String:Any]) {
        self.socket?.emit(dictionary["type"] as! String,[SharedManager.shared.returnJsonObject(dictionary: dictionary)])
    }
    
    func senddidenterForeground(dictionary:[String:Any]) {
        self.socket?.emit(dictionary["type"] as! String, [SharedManager.shared.returnJsonObject(dictionary: dictionary)])
    }

    
    func addHandlers() {
        socket?.removeAllHandlers()
        socket?.on(clientEvent: .connect) {data, ack in
            self.sfudelegateCallmanager?.didSocketConnected(data: data)
        }
        
        socket?.on(clientEvent: .disconnect) {data, ack in
            self.sfudelegateCallmanager?.didSocketDisConnected(data: data)
        }
        
        socket?.on(clientEvent: .error) {data, ack in
        }
        
        socket?.on(clientEvent: .reconnect) {data, ack in
        }
//        socket.onAny {LogClass.debugLog("Got event: \($0.event), with items: \($0.items)")};        socket?.on("error") {data, ack in
//
//        }
        socket.on("room:can-make-connection") {[weak self] data, ack in
            let dictionary : [String : Any] = data.first as! [String : Any]
            self?.sfudelegateCallmanager?.didReceiveCanMakeConnection(data: dictionary)

        }
        socket.on("room:joined") {[weak self] data, ack in
           
            let dictionary : [String : Any] = data.first as! [String : Any]
            self?.sfudelegateCallmanager?.didReceiveRoomJoined(data: dictionary)

        }
        socket.on("room:new-producer") {[weak self] data, ack in
           
            let dic : [String:Any] = data.first as! [String:Any]
            self?.sfudelegateCallmanager?.didReceiveNewProducer(data: dic)
        }
        socket.on("room:created") {[weak self] data, ack in
          
        }
        socket.on("room:audio-switched") {[weak self] data, ack in
           
        }
        socket.on("room:producer-closed") {[weak self] data, ack in
           
        }
        socket.on("room:left") {[weak self] data, ack in
           
            let dic : [String:Any] = data.first as! [String:Any]
            self?.sfudelegateCallmanager?.didReceiveUserleft(data: dic)
        }
        socket.on("room:producer-closed") {[weak self] data, ack in
           
        }
        socket.on("room:consumer-closed") {[weak self] data, ack in
           
        }
        socket.on("room:video-switched") {[weak self] data, ack in
            
            let dic : [String:Any] = data.first as! [String:Any]
            self?.sfudelegateCallmanager?.didReceiveVideoSwitched(data: dic)
        }
        socket.on("room:reconnecting") {[weak self] data, ack in
           
            let dic : [String:Any] = data.first as! [String:Any]
            self?.sfudelegateCallmanager?.didReceiveUserReconnecting(data: dic)

        }
        socket.on("room:reconnected") {[weak self] data, ack in
          
            let dic : [String:Any] = data.first as! [String:Any]
            self?.sfudelegateCallmanager?.didReceiveUserReconnected(data: dic)

        }
        socket.on("room:connection-reconnecting") {[weak self] data, ack in
           
        }
        socket.on("room:connection-reconnected") {[weak self] data, ack in
           
        }
    }
}

