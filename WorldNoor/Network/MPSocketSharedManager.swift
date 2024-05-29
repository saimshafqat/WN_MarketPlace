//
//  MPSocketSharedManager.swift
//  WorldNoor
//
//  Created by Awais on 24/03/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//


import UIKit
import SocketIO
import WebRTC

protocol MPSocketDelegate {
    func didSocketConnected(data: [Any])
    func didSocketDisConnected(data: [Any])
    func didReceiveCallstatusAck(data: [String:Any])
}

extension MPSocketDelegate {
    //default implementation for optional methods
    
    func didSocketConnected(data: [Any])
    {}
    func didSocketDisConnected(data: [Any])
    {}
    func didReceiveCallstatusAck(data: [String:Any])
    {}
}

@objc protocol MPChatDelegate:AnyObject {
    @objc optional func chatMessageReceived(res:NSArray)
    @objc optional func updateChatMessageReceived(res:NSArray)
    @objc optional func chatMessageDelete(res:NSArray)
    @objc optional func pinnedMessageDelegate(res:NSDictionary)
    @objc optional func reactMessageDelegate(res:NSDictionary)
    @objc optional func updateChatMessage()

}

class MPSocketSharedManager: NSObject {

    var delegate: MPSocketDelegate?
    var chatDelegate:MPChatDelegate?
    
    static let sharedSocket = MPSocketSharedManager()
    var manager: SocketManager?
    var socket:SocketIOClient!
    var resetAck: SocketAckEmitter?
    
    private override init() {
        super.init()
    }
    
    func closeConnection() {
        
        if socket != nil {
            socket.disconnect()
            socket.removeAllHandlers()
            socket = nil
            
            if manager != nil {
                manager = nil
            }
        }
        
    }
    
    func establishConnection(){
        
        LogClass.debugLog("MP socket establishConnection")

        var stateInt = 0
        let state = UIApplication.shared.applicationState
        if state == .background {
            LogClass.debugLog("MP bg")
            stateInt = 0
        }else if (state == .active){
            LogClass.debugLog("MP active")
            stateInt = 1
        }else if (state == .inactive){
            LogClass.debugLog("MP in active")
            stateInt = 2
        }
        let isCommunicationEncrypted = false
        
        manager = SocketManager(socketURL: URL(string: AppConfigurations().MarketPlaceSocketURL)!, config: [.log(true), .compress,.connectParams(["token" : SharedManager.shared.marketplaceUserToken(),"isEncrypted":isCommunicationEncrypted,"state":stateInt]),.forceWebsockets(true),.reconnectAttempts(2)])

        self.socket = manager?.defaultSocket
        manager?.forceNew = true
        manager?.reconnects = true
        manager?.reconnectWaitMax = 2
        manager?.reconnectWait = 1
        socket?.connect()
        addHandlers()
        LogClass.debugLog("----\(socket?.sid ?? "--")")
        LogClass.debugLog("----MP connect request sent")
    }

    func addHandlers() {
        
        self.socket?.removeAllHandlers()
        
        self.socket.on(clientEvent: .connect) {data, ack in

            LogClass.debugLog("MP socket connected\(data)")
            self.delegate?.didSocketConnected(data: data)
        }
        
        socket.on(clientEvent: .disconnect) {data, ack in

            LogClass.debugLog("MP socket disconnect\(data)")
            self.delegate?.didSocketDisConnected(data: data)
            
            if (SharedManager.shared.userObj != nil){
                LogClass.debugLog("MP socket connected request sent from disconnect")
                self.establishConnection()
            }
            
        }
        
        self.socket.on(clientEvent: .statusChange) {data, ack in
            LogClass.debugLog(data)
        }
        
        self.socket.on(clientEvent: .error) {data, ack in
            LogClass.debugLog(data)
        }
        
        self.socket.on("welcome") {data, ack in
            LogClass.debugLog("MP socket welcome: \(data)")
        }
        
        self.socket.on("send_message") {data, ack in
            LogClass.debugLog("MP new_message: \(data)")
            if self.chatDelegate?.updateChatMessageReceived != nil {
                self.chatDelegate?.updateChatMessageReceived?(res: data as NSArray)
            }
        }
        
        self.socket.on("delete_message") {data, ack in
            LogClass.debugLog("MP delete_message: \(data)")
            if self.chatDelegate?.chatMessageDelete != nil {
                self.chatDelegate?.chatMessageDelete?(res: data as NSArray)
            }
        }
        
        self.socket.on("reactThisMessage") {data, ack in
            LogClass.debugLog("MP reactThisMessage: \(data)")
            if data.count > 0 {
                if let dict = data[0] as? NSDictionary {
                    if self.chatDelegate?.reactMessageDelegate != nil {
                        self.chatDelegate?.reactMessageDelegate?(res: dict)
                    }
                }
            }
        }
        
        self.socket.on("pinUnpinThisMessage") {data, ack in
            LogClass.debugLog("MP pinUnpinThisMessage: \(data)")
            if let dataArray = data as? [[Any]], let firstElement = dataArray.first, let dictionary = firstElement.first as? NSDictionary {
                if self.chatDelegate?.pinnedMessageDelegate != nil {
                    self.chatDelegate?.pinnedMessageDelegate?(res: dictionary)
                }
            }
        }
    }
    
    
    // MARK: -
    // MARK: Emit Actions...
    
    func markConversationReadUnRead(dictionary:[String:Any]){
        
        self.socket.emitWithAck("markConversationReadUnRead", dictionary).timingOut(after: 0) {data in
        }
    }
    
    func markConversationArchive(dictionary:[String:Any] , completionHandler: @escaping (_ returnValue: [Any]?)->Void)  {
        
        self.socket.emitWithAck("ArchivedConversations", dictionary).timingOut(after: 0) {data in
            completionHandler(data)
        }
    }
    
    func markConversationMuteUnMute(dictionary:[String:Any] , completionHandler: @escaping (_ returnValue: [Any]?)->Void)  {
        
        self.socket.emitWithAck("markConversationMuteUnMute", dictionary).timingOut(after: 0) {data in
            completionHandler(data)
        }
    }
    
    func deleteConversation(dictionary:[String:Any] , completionHandler: @escaping (_ returnValue: [Any]?)->Void)  {
        
        self.socket.emitWithAck("deleteConversation", dictionary).timingOut(after: 0) {data in
            completionHandler(data)
        }
    }
    
    func leaveGroup(dictionary:[String:Any] , completionHandler: @escaping (_ returnValue: [Any]?)->Void)  {
        
        self.socket.emitWithAck("LeaveGroup", dictionary).timingOut(after: 0) {data in
            completionHandler(data)
        }
    }
    
    func emitChatText(dict:[String:Any]) {
        LogClass.debugLog("dict ===> 1")
        LogClass.debugLog(dict)
        self.socket.emitWithAck("send_message", dict).timingOut(after: 0) {data in
            LogClass.debugLog(data)
            LogClass.debugLog("dict ===> 2")
            if self.chatDelegate?.chatMessageReceived != nil {
                self.chatDelegate?.chatMessageReceived?(res: data as NSArray)
            }
        }
    }
    
    func emitDeleteChatText(dict:[String:Any]) {

        self.socket.emitWithAck("delete_message", dict).timingOut(after: 0) {data in
            LogClass.debugLog(data)
            LogClass.debugLog("dict ===> 3")
        }
    }
    
    func updateGroupConversation(dict:NSDictionary , completionHandler: @escaping (_ returnValue: [Any]?)->Void) {
          self.socket.emitWithAck("groupConversationDataUpdated", dict).timingOut(after: 0) {data in
              completionHandler(data)
          }
      }
    
    func updateNickname(dictionary:[String:Any] , completionHandler: @escaping (_ returnValue: [Any]?)->Void)  {
        
        self.socket.emitWithAck("updateNickNames", dictionary).timingOut(after: 0) {data in
            completionHandler(data)
        }
    }
    
    func addReaction(dictionary:[String:Any]){
        LogClass.debugLog("dict ===> 4")
        LogClass.debugLog(dictionary)
        self.socket.emitWithAck("reactThisMessage", dictionary).timingOut(after: 0) {data in
            LogClass.debugLog(data)
            LogClass.debugLog("dict ===> 5")
        }
    }
    
    func pinMessage(dict:[String:Any]) {
        self.socket.emitWithAck("pinUnpinThisMessage", dict).timingOut(after: 0) {data in
            LogClass.debugLog(data)
            LogClass.debugLog("dict ===> 33")
        }
        
    }
}
