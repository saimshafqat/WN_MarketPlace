//
//  SocketSharedManager.swift
//  WorldNoor
//
//  Created by Raza najam on 10/28/19.
//  Copyright © 2019 Raza najam. All rights reserved.
//

import UIKit
import SocketIO
import WebRTC
import CallKit

@objc protocol feedCommentDelegate:AnyObject {
    @objc optional func feedCommentReceivedFromSocket(res: NSDictionary)
    @objc optional func chatMessageReceived(res:NSArray)
    @objc optional func chatMessageDelete(res:NSArray)
    @objc optional func videoProcessingSocketResponse(res:NSArray)
    @objc optional func goLiveSessionSocketResponse(res:NSArray)
    @objc optional func pinnedMessageDelegate(res:NSDictionary)
    @objc optional func updateChatMessage()

}

protocol SocketOnlineUser {
    func userValueChange(data: [Any] , isOnline:Bool)
}


protocol SocketAppListner {
    func appDataREcived()
}


protocol SocketDelegateAppdelegate {
    func didSocketConnectedAppdelegate(data: [Any])
}

protocol SocketDelegateForGroup {
    func didSocketContactGroup(data: [String : Any])
    func didSocketRemoveContactGroup(data: [String : Any])
    func didSocketGroupUpdate(data: [String : Any])
    func didSocketGroupThemeUpdate(data: [String : Any])
}
extension SocketDelegateAppdelegate {
    //default implementation for optional methods
    func didSocketConnectedAppdelegate(data: [Any]){}
}

////////////call delegates//////////////////


protocol SocketDelegateCallmanager {
    
    func didSocketConnected(data: [Any])
    func didSocketDisConnected(data: [Any])
    
    
    func didReceiveOffer(data: SignalingMessage)
    func didReceiveAnswer(data: SignalingMessage)
    func didReceiveCandidate(data: SignalingMessage)
    func didReceiveReject(data :[String :Any])
    func didReceiveReadyforcall(data: Available, join:Bool)
    func didReceiveNewCallData(data: [String :Any])
    func didReceiveVideoSwitch(data: [String :Any])
    func didReceiveNewCallReceived(data: Available)
    func didReceiveSendCallMembersAck(data: [String:Any])

    
}
extension SocketDelegateCallmanager {
    //default implementation for optional methods
    
    func didSocketConnected(data: [Any]) {}
    func didSocketDisConnected(data: [Any]) {}
    
    
    func didReceiveOffer(data: SignalingMessage) {}
    func didReceiveAnswer(data: SignalingMessage) {}
    func didReceiveCandidate(data: SignalingMessage){}
    func didReceiveReject(data :[String :Any]){}
    func didReceiveReadyforcall(data: Available, join:Bool){}
    func didReceiveNewCallData(data: [String :Any]){}
    func didReceiveVideoSwitch(data: [String :Any]){}
    func didReceiveNewCallReceived(data: Available) {}
    func didReceiveSendCallMembersAck(data: [String:Any])
    {}
}


////////////messaging delegates//////////////////

protocol SocketDelegate {
    
    
    func didSocketConnected(data: [Any])
    func didSocketDisConnected(data: [Any])
    func didReceiveCallstatusAck(data: [String:Any])
    
}

extension SocketDelegate {
    
    //default implementation for optional methods
    
    func didSocketConnected(data: [Any])
    {}
    func didSocketDisConnected(data: [Any])
    {}
    func didReceiveCallstatusAck(data: [String:Any])
    {}
}


class SocketSharedManager: NSObject {
    weak var commentDelegate:feedCommentDelegate?
    
    var userValueDelegate:SocketOnlineUser?
    var delegateAppListner:SocketAppListner?
    var delegate: SocketDelegate?
    var delegateAppdelegate: SocketDelegateAppdelegate?
    var delegateCallmanager: SocketDelegateCallmanager?
    
    var delegateGroup: SocketDelegateForGroup?
    
    static let sharedSocket = SocketSharedManager()
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
        
        LogClass.debugLog("socket establishConnection")
        LogClass.debugLog("dict ===> 6")

        var stateInt = 0
        let state = UIApplication.shared.applicationState
        if state == .background {
            LogClass.debugLog("bg")
            LogClass.debugLog("dict ===> 7")
            stateInt = 0
        }else if (state == .active){
            LogClass.debugLog("active")
            LogClass.debugLog("dict ===> 8")
            stateInt = 1
        }else if (state == .inactive){
            LogClass.debugLog("in active")
            LogClass.debugLog("dict ===> 9")
            stateInt = 2
        }
        var isCommunicationEncrypted = false
        manager = SocketManager(socketURL: URL(string: AppConfigurations().BaseUrlSocket)!, config: [.log(false), .connectParams(["token" : SharedManager.shared.userToken()])])
        
        manager = SocketManager(socketURL: URL(string: AppConfigurations().BaseUrlSocket)!, config: [.log(true), .compress,.connectParams(["token" : SharedManager.shared.userToken(),"isEncrypted":isCommunicationEncrypted,"state":stateInt]),.forceWebsockets(true),.reconnectAttempts(2)])


        

        self.socket = manager?.defaultSocket
        manager?.forceNew = true
        manager?.reconnects = true
        manager?.reconnectWaitMax = 2
        manager?.reconnectWait = 1
        socket?.connect()
        addHandlers()
        LogClass.debugLog("----\(socket?.sid)")
        LogClass.debugLog("----connect request sent")
    }
    
    func playVideoSocket(postID : String){
        let messageDict:NSDictionary = ["post_id":postID, "platform" : "IOS"]
        LogClass.debugLog(messageDict)
        LogClass.debugLog("playVideoSocket ===> 32")
        AppLogger.log(tag: .success, "playVideoSocket ===> 32", messageDict)
        self.socket.emit("video_played", messageDict)
    }
    
    func addLikeHandler(postID : String){
        let valueMain = "reactions_count_updated" + postID
        self.socket.on(valueMain) {data, ack in
            
            if data.count > 0 {
                if let dict = data[0] as? [String : Any] {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reactions_count_updated"), object: nil, userInfo: dict)
                }
            }
        }
        
    }
    func addHandlers() {
        
        self.socket?.removeAllHandlers()

        self.socket.on("new_message") {data, ack in
            if self.commentDelegate?.chatMessageReceived != nil {
                self.commentDelegate?.chatMessageReceived?(res: data as NSArray)
            }
        }
        
        self.socket.on(clientEvent: .connect) {data, ack in

            LogClass.debugLog("socket connected\(data)")
            LogClass.debugLog("dict ===> 10")
            self.delegateAppdelegate?.didSocketConnectedAppdelegate(data: data)
            self.delegate?.didSocketConnected(data: data)
            self.delegateCallmanager?.didSocketConnected(data: data)
            self.appDelegate.didenterForegroundSocket()
            if(RoomClient.sharedInstance.isCallConnected){
                let param: [String:Any] = ["callId": RoomClient.sharedInstance.callId,"chatId": RoomClient.sharedInstance.chatId]
                self.socket.emit("rejoined", [SharedManager.shared.returnJsonObject(dictionary: param)])
            }
        }
        
        socket.on(clientEvent: .disconnect) {data, ack in

            LogClass.debugLog("socket disconnect\(data)")
            LogClass.debugLog("dict ===> 11")
            self.delegate?.didSocketDisConnected(data: data)
            self.delegateCallmanager?.didSocketDisConnected(data: data)
            
            if (SharedManager.shared.userObj != nil){
                LogClass.debugLog("socket connected request sent from disconnect")
                LogClass.debugLog("dict ===> 12")
                self.establishConnection()
            }
            
        }
        
        socket.on("update_profile_user") {[weak self] data, ack in
            if ((data as? [String : Any]) != nil) {
            }else if let arrayData = (data as? [[String : Any]]) {
                if arrayData.count > 0 {
                    if let firstObj = arrayData[0] as? [String : Any]{
                        
                        
                        if SharedManager.shared.ReturnValueCheck(value: firstObj["id"] ) == String((SharedManager.shared.userObj?.data.id)!) {
                            SharedManager.shared.userObj?.data.profile_image = SharedManager.shared.ReturnValueCheck(value: firstObj["profile_image"])
                            SharedManager.shared.userObj?.data.firstname = SharedManager.shared.ReturnValueCheck(value: firstObj["firstname"])
                            
                            SharedManager.shared.userObj?.data.lastname = SharedManager.shared.ReturnValueCheck(value: firstObj["lastname"])
                            
                            SharedManager.shared.downloadUserImage(imageUrl: (SharedManager.shared.userObj?.data.profile_image)!)
                        }
                    }
                }
            }
        }
        
        socket.on("posh_notification") {[weak self] data, ack in
            LogClass.debugLog("data posh_notification ==>")
            LogClass.debugLog("dict ===> 13")
            LogClass.debugLog(data)
            LogClass.debugLog(data.first)
            
            
            
//            let dictionary : [String : Any] = data.first as! [String : Any]
            if self?.delegateAppListner != nil {
                self?.delegateAppListner!.appDataREcived()
            }
            
        }
        socket.on("chatThemeUpdated") {[weak self] data, ack in
            LogClass.debugLog("data chatThemeUpdated ==>")
            LogClass.debugLog("dict ===> 14")
            LogClass.debugLog(data)
            let dictionary : [String : Any] = data.first as! [String : Any]
            if let colorCode = dictionary["color_code"] as? String, let id = dictionary["conversation_id"] as? Int {
                ChatDBManager.updateChatTheme(chat_id: id, colorCode: colorCode)
            }
            self?.delegateGroup?.didSocketGroupThemeUpdate(data: dictionary)
        }
        
        //MARK: call listeners
        
        socket.on("answer") {[weak self] data, ack in
            
            let dictionary : [String : Any] = data.first as! [String : Any]
            let offerDic = dictionary["offer"] as! [String:Any]
            let sdp = SDP.init(sdp: offerDic["sdp"] as! String)
            
            do {
                let signalingMessage = try SignalingMessage.init(type: dictionary["type"] as! String, offer: sdp, candidate: dictionary["candidate"] as? Candidate, phone: dictionary["phone"] as? String, photoUrl: dictionary["photoUrl"] as? String, name: dictionary["name"] as? String, connectedUserId: (dictionary["connectedUserId"] as? String)!, isVideo: dictionary["isVideo"] as? Bool,callId:(dictionary["callId"] as? String)!,chatId: (dictionary["chatId"] as? String)!,sessionId: dictionary["sessionId"] as? String, socketId: dictionary["socketId"] as? String)
                try self?.delegateCallmanager?.didReceiveAnswer(data: signalingMessage)
                
            }
            catch{
                LogClass.debugLog("crash")
            }
        }
        socket.on("callaccepted") {[weak self] data, ack in
            LogClass.debugLog("callaccepted received")
            LogClass.debugLog("dict ===> 15")
            let dictionary : [String : Any] = data.first as! [String : Any]
            LogClass.debugLog(dictionary)
            //CallManager.sharedInstance.closeCallScreen()
            RoomClient.sharedInstance.dismissScreenAndTransports()
        }

        socket.on("groupCallStatus") {[weak self] data, ack in
            
            let dictionary : [String : Any] = data.first as! [String : Any]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "CallStatus"), object: nil,userInfo: dictionary)
            
        }
        socket.on("switchvideo") {[weak self] data, ack in
            
            let dictionary : [String : Any] = data.first as! [String : Any]
            self?.delegateCallmanager?.didReceiveVideoSwitch(data: dictionary)
        }
        socket.on("candidate") {[weak self] data, ack in
            let dictionary : [String : Any] = data.first as! [String : Any]
            let candidate = dictionary["candidate"]  as! [String:Any]
            let candidate1 = Candidate.init(sdp: candidate["sdp"] as! String, sdpMLineIndex: candidate["sdpMLineIndex"] as! Int32, sdpMid: candidate["sdpMid"] as! String)
            
            let signalingMessage = SignalingMessage.init(type: dictionary["type"] as! String, offer: nil, candidate: candidate1, phone: dictionary["phone"] as? String, photoUrl: dictionary["photoUrl"] as? String, name: dictionary["name"] as? String, connectedUserId: (dictionary["connectedUserId"] as? String)!, isVideo: dictionary["isVideo"] as? Bool,callId: (dictionary["callId"] as? String)!, chatId: (dictionary["chatId"] as? String)!,sessionId: dictionary["sessionId"] as? String, socketId: dictionary["socketId"] as? String)
            self?.delegateCallmanager?.didReceiveCandidate(data: signalingMessage)
        }
        

        socket.on("reject") {[weak self] data, ack in
            LogClass.debugLog("reject received")
            LogClass.debugLog("dict ===> 16")
            LogClass.debugLog(data)
            let dictionary : [String : Any] = data.first as! [String : Any]
            let userId = SharedManager.shared.ReturnValueAsInt(value: dictionary["connectedUserId"]!)
            let callType = SharedManager.shared.ReturnValueAsString(value: dictionary["callType"]!)
            let chatId = SharedManager.shared.ReturnValueAsInt(value: dictionary["chatId"]!)
            let callId = SharedManager.shared.ReturnValueAsInt(value: dictionary["callId"]!)
            let manually = SharedManager.shared.ReturnValueAsInt(value: dictionary["manually"]!)

            
            
            if userId != SharedManager.shared.userObj?.data.id {
                for i in RoomClient.sharedInstance.connections.indices {
                    LogClass.debugLog(RoomClient.sharedInstance.connections.count)
                    LogClass.debugLog(RoomClient.sharedInstance.connections.indices)
                    LogClass.debugLog(i)
                    if i < RoomClient.sharedInstance.connections.count {
                        if let user = RoomClient.sharedInstance.connections[i] as? Connection{
                            if Int(user.connecteduserid) == userId {
                                user.audioconsumer?.close()
                                user.audiotransport?.close()
                                user.videooconsumer?.close()
                                user.videotransport?.close()
                                user.screenconsumer?.close()
                                user.screentransport?.close()
                                RoomClient.sharedInstance.connections.remove(at: i)
                            }
                        }
                    }
                    RoomClient.sharedInstance.screen?.callerCollectionView.reloadData()
                }
            }
            
            for item in RoomClient.sharedInstance.callsReference {
                LogClass.debugLog(item)
                LogClass.debugLog("dict ===> 17")
                LogClass.debugLog(item.value)
                let calldata = item.value as? Available
                if /*SharedManager.shared.ReturnValueAsInt(value: calldata?.callId) == callId &&*/ SharedManager.shared.ReturnValueAsInt(value: calldata?.chatId) == chatId {
                    if(callType == "single"){
                        if(chatId == RoomClient.sharedInstance.chatId || RoomClient.sharedInstance.isCallConnected == false){
                            RoomClient.sharedInstance.dismissScreenAndTransports()
                        }
                        //if(RoomClient.sharedInstance.connections.count == 0){
                        LogClass.debugLog(RoomClient.sharedInstance.callsReference)
                            RoomClient.sharedInstance.callsReference.removeValue(forKey: item.key)
                        LogClass.debugLog(RoomClient.sharedInstance.callsReference)
                            let calluuuid = UUID(uuidString: item.key)!
                            let endCallAction = CXEndCallAction(call: calluuuid)
                            let transaction = CXTransaction(action: endCallAction)
                            let callcontroller = CXCallController()
                            callcontroller.request(transaction) { error in
                                LogClass.debugLog(error?.localizedDescription)
                            }
                        //}
                        
                    }else if(callType == "group"){
                        if RoomClient.sharedInstance.isCallConnected == true{
                            if RoomClient.sharedInstance.connections.count == 0 {
                                //if SharedManager.shared.ReturnValueAsInt(value: calldata?.connectedUserId) == userId {
                                    RoomClient.sharedInstance.dismissScreenAndTransports()
                                LogClass.debugLog(RoomClient.sharedInstance.callsReference)
                                    RoomClient.sharedInstance.callsReference.removeValue(forKey: item.key)
                                LogClass.debugLog(RoomClient.sharedInstance.callsReference)
                                    let calluuuid = UUID(uuidString: item.key)!
                                    let endCallAction = CXEndCallAction(call: calluuuid)
                                    let transaction = CXTransaction(action: endCallAction)
                                    let callcontroller = CXCallController()
                                    callcontroller.request(transaction) { error in
                                        LogClass.debugLog(error?.localizedDescription)
                                    }

                                //}
                            }
                        }
                    }
                }
            }
            
            
            
            
        }

        socket.on("startNewCalll") {[weak self] data, ack in
            LogClass.debugLog("newcall received \(data)")
            LogClass.debugLog("dict ===> 18")
            var handleCall = false
            
            let dictionary : [String : Any] = data.first as! [String : Any]
            LogClass.debugLog(dictionary)
            let signalingMessage = Available.init(type: dictionary["type"] as! String, connectedUserId: (dictionary["connectedUserId"] as? String)!, isAvailable: dictionary["isAvailable"] as? Bool, reason: dictionary["reason"] as? String, name: dictionary["name"] as? String,callId: (dictionary["callId"] as? String)!,chatId: (dictionary["chatId"] as? String)!, photoUrl: dictionary["photoUrl"] as? String, isVideo: dictionary["isVideo"] as? Bool, isBusy: dictionary["isBusy"] as? Bool,sessionId: dictionary["sessionId"] as? String, socketId: dictionary["socketId"] as? String,callType: "",roomId: "")
            
            ATCallManager.shared.incommingCall(from: signalingMessage.name!,hasVideo: signalingMessage.isVideo ?? false , delay: 0, callobject: signalingMessage)

        }
        
        
        
        socket.on("newcallreceived") {[weak self] data, ack in
            LogClass.debugLog("newcallreceived received")
            LogClass.debugLog("dict ===> 19")
            LogClass.debugLog(data)
            
            let dictionary : [String : Any] = data.first as! [String : Any]
            
            let signalingMessage = Available.init(type: dictionary["type"] as! String, connectedUserId: (dictionary["connectedUserId"] as? String)!, isAvailable: dictionary["isAvailable"] as? Bool, reason: dictionary["reason"] as? String, name: dictionary["name"] as? String,callId: "",chatId: (dictionary["chatId"] as? String)!, photoUrl: dictionary["photoUrl"] as? String, isVideo: dictionary["isVideo"] as? Bool, isBusy: dictionary["isBusy"] as? Bool,sessionId: dictionary["sessionId"] as? String, socketId: dictionary["socketId"] as? String,callType: "",roomId: "")
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [self] in
                if(RoomClient.sharedInstance.screen != nil){
                    let isBusy = signalingMessage.isBusy
                    if(isBusy != nil){
                        if(isBusy == true){
                            RoomClient.sharedInstance.screen?.calltimerlabel.text = "\(RoomClient.sharedInstance.connectedUserName) is on another call"
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [self] in
                                RoomClient.sharedInstance.endcallLogic(sendReject: true)
                            }
                        }else{
                            RoomClient.sharedInstance.screen?.calltimerlabel.text = "Ringing"
                        }
                    }else{
                        RoomClient.sharedInstance.screen?.calltimerlabel.text = "Ringing"
                    }
                }
            }
            //self?.delegateCallmanager?.didReceiveNewCallReceived(data: signalingMessage)
        }
        
        
        
        socket.on("readyforcall") {[weak self] data, ack in
            LogClass.debugLog("readyforcall received")
            LogClass.debugLog("dict ===> 20")
            LogClass.debugLog(data)
            
            let dictionary : [String : Any] = data.first as! [String : Any]
            LogClass.debugLog(dictionary)
            var join = dictionary["join"] as? Bool
            //var foreNewPc = dictionary["forceNew"] as? Bool
            let signalingMessage = Available.init(type: dictionary["type"] as! String, connectedUserId: (dictionary["connectedUserId"] as? String)!, isAvailable: dictionary["isAvailable"] as? Bool, reason: dictionary["reason"] as? String, name: dictionary["name"] as? String,callId: (dictionary["callId"] as? String)!,chatId: (dictionary["chatId"] as? String)!, photoUrl: dictionary["photoUrl"] as? String, isVideo: dictionary["isVideo"] as? Bool, isBusy: dictionary["isBusy"] as? Bool,sessionId: dictionary["sessionId"] as? String, socketId: dictionary["socketId"] as? String,callType: "",roomId: "")
            self?.delegateCallmanager?.didReceiveReadyforcall(data: signalingMessage,join: join ?? false)
            
        }
        socket.on("offer") {[weak self] data, ack in
            
            let dictionary : [String : Any] = data.first as! [String : Any]
            let offerDic = dictionary["offer"] as! [String:Any]
            let sdp = SDP.init(sdp: offerDic["sdp"] as! String)
            let signalingMessage = SignalingMessage.init(type: dictionary["type"] as! String, offer: sdp, candidate: dictionary["candidate"] as? Candidate, phone: dictionary["phone"] as? String, photoUrl: dictionary["photoUrl"] as? String, name: dictionary["name"] as? String, connectedUserId: (dictionary["connectedUserId"] as? String)!, isVideo: dictionary["isVideo"] as? Bool,callId: (dictionary["callId"] as? String)!,chatId: (dictionary["chatId"] as? String)!,sessionId: dictionary["sessionId"] as? String, socketId: dictionary["socketId"] as? String)
            
            //CallManager.sharedInstance.didReceiveOffer(data: signalingMessage)
        }
        
        socket.on("i_am_offline") {[weak self] data, ack in
            
            let dictionary : [String : Any] = data.first as! [String : Any]
            LogClass.debugLog(dictionary)
            LogClass.debugLog("dict ===> 21")
            if self?.userValueDelegate != nil {
                self?.userValueDelegate!.userValueChange(data: dictionary["data"] as! [Any],isOnline: false)
            }

            
        }
        
        socket.on("i_am_online") {[weak self] data, ack in
            
            let dictionary : [String : Any] = data.first as! [String : Any]
//            LogClass.debugLog(dictionary)
//            LogClass.debugLog("dict ===> 22")
            
            
            if self?.userValueDelegate != nil {
                self?.userValueDelegate!.userValueChange(data: dictionary["data"] as! [Any],isOnline: true)
            }
        }
        
        self.socket.on("seen_by") {data, ack in
            LogClass.debugLog(data)
            LogClass.debugLog("dict ===> 23")
            let dictionary : [String : Any] = data.first as! [String : Any]
            if let msgID = dictionary["m"] as? Int, let userID = dictionary["u"] as? Int {
                let messageStr = SharedManager.shared.ReturnValueAsString(value: msgID)
                let userIDStr = SharedManager.shared.ReturnValueAsString(value: userID)
                DBMessageManager.updateSeenStatus(messageID: messageStr, userID: userIDStr)
                if self.commentDelegate?.chatMessageReceived != nil {
                    self.commentDelegate?.updateChatMessage?()
                }
            }
        }

        socket.on("newUserAddedToConversation") {[weak self] data, ack in
            let dictionary : [String : Any] = data.first as! [String : Any]
            self?.delegateGroup?.didSocketContactGroup(data: dictionary)
        }
        
        socket.on("groupConversationDataUpdated") {[weak self] data, ack in
            let dictionary : [String : Any] = data.first as! [String : Any]
            self?.delegateGroup?.didSocketGroupUpdate(data: dictionary)
        }
        
        socket.on("userHasLeftConversation") {[weak self] data, ack in
                   let dictionary : [String : Any] = data.first as! [String : Any]
                   self?.delegateGroup?.didSocketRemoveContactGroup(data: dictionary)
        }

        self.socket.on(clientEvent: .statusChange) {data, ack in
            LogClass.debugLog(data)
            LogClass.debugLog("dict ===> 24")
        }
        self.socket.on(clientEvent: .error) {data, ack in
            LogClass.debugLog(data)
            LogClass.debugLog("dict ===> 25")

        }

        self.socket.on("new_comment") {data, ack in
            if data.count > 0 {
                let dict = data[0] as! NSDictionary
                self.commentDelegate?.feedCommentReceivedFromSocket?(res:dict)
            }
        }
        
        self.socket.on("delete_message") {data, ack in

            LogClass.debugLog(data)
            LogClass.debugLog("dict ===> 26")
//            if data.count > 0 {
//                let dict = data[0] as! NSDictionary
//                self.commentDelegate?.feedCommentReceivedFromSocket?(res:dict)
//            }
        }
        
        self.socket.on("pinunpinlistner") {data, ack in

            LogClass.debugLog(data)
            LogClass.debugLog("dict ===> 27")
            if data.count > 0 {
                if let dict = data[0] as? NSDictionary {
                    if self.commentDelegate?.pinnedMessageDelegate != nil {
                        self.commentDelegate?.pinnedMessageDelegate?(res: dict)
                    }
                }
            }
        }
        
        self.socket.on("deleted_a_message") {data, ack in
            if data.count > 0 {
                let dict = data[0] as! NSDictionary
                self.commentDelegate?.feedCommentReceivedFromSocket?(res:dict)
            }
        }
        
        self.socket.on("welcome") {data, ack in
            LogClass.debugLog(data)
            LogClass.debugLog("dict ===> 28")
        }
        self.socket.on("error") {data, ack in

            LogClass.debugLog("socket ==> error 2")
            LogClass.debugLog("dict ===> 29")
            LogClass.debugLog(data)
        }
        
        self.socket.on("reactMesssageListner") {data, ack in
            if data.count > 0, let dict = data[0] as? [String:Any] {
                let userID = SharedManager.shared.ReturnValueAsString(value: dict["reacted_by"] as Any)
                let messageID = SharedManager.shared.ReturnValueAsString(value: dict["message_id"] as Any)
                let reactionName = SharedManager.shared.ReturnValueAsString(value: dict["reaction"] as Any)
                let userName = SharedManager.shared.ReturnValueAsString(value: dict["name"] as Any)
                let profileImage = SharedManager.shared.ReturnValueAsString(value: dict["profile_image"] as Any)
                DBReactionManager.reactionHandling(action: "", selectedReaction: reactionName, messageID: messageID, userID: userID, name: userName, profileImage: profileImage)
            }
            self.commentDelegate?.updateChatMessage?()
            LogClass.debugLog("socket ==> reaction 2")
            LogClass.debugLog("dict ===> 30")
            LogClass.debugLog(data)
        }
        
        self.socket.on("reactThisMessage") {data, ack in
            LogClass.debugLog("socket ==> reaction 2")
            LogClass.debugLog("dict ===> 31")
            LogClass.debugLog(data)
        }

        self.receiveGenericNotification()
    }
    
    func changeStatus(valueMain : String){
        let messageDict:NSDictionary = ["user_active":valueMain]
        LogClass.debugLog(messageDict)
        LogClass.debugLog("dict ===> 32")
        self.socket.emit("active_user_switch", messageDict)
        
    }
    
    func updateUserProfile(dictionary:[String:Any]) {
        self.socket.emit("update_profile_user_web", with: [SharedManager.shared.returnJsonObject(dictionary: dictionary)], completion: nil)
        
    }
    
    func receiveChatMessage(){
        self.socket.on("new_message") {data, ack in
            if self.commentDelegate?.chatMessageReceived != nil {
                self.commentDelegate?.chatMessageReceived?(res: data as NSArray)
            }
        }
    }
    
    func pinMessage(dict:[String:Any]) {
        self.socket.emitWithAck("pinUnpinThisMessage", dict).timingOut(after: 0) {data in
            LogClass.debugLog(data)
            LogClass.debugLog("dict ===> 33")
        }
        
    }
    
    
    func deleteChatMessage(){
        self.socket.on("deleted_a_message") {data, ack in
            if self.commentDelegate?.chatMessageDelete != nil {
                self.commentDelegate?.chatMessageDelete?(res: data as NSArray)
            }
        }
    }
    
    func newsFeedProcessingHandler(){
        let userID = String(SharedManager.shared.getUserID())
        let userEvent = String(format: "user.%@", userID)

        self.socket.on(userEvent) {data, ack in
            self.commentDelegate?.videoProcessingSocketResponse?(res: data as NSArray)
        }
    }
    
    func newsFeedProcessingHandlerGlobal(){
        let userEvent = "global"

        self.socket.on(userEvent) {data, ack in
            self.commentDelegate?.videoProcessingSocketResponse?(res: data as NSArray)
        }
    }
    func senddidenterBackground(dictionary:[String:Any]) {
        self.socket.emit(dictionary["type"] as! String, with: [SharedManager.shared.returnJsonObject(dictionary: dictionary)], completion: nil)
    }
    
    
    func markmessageSeen(valueMain : Int ){
        let messageDict:NSDictionary = ["m":[valueMain]]
        self.socket.emit("markMessagesAsSeen", messageDict)
    }
    
    func senddidenterForeground(dictionary:[String:Any]) {
        self.socket.emit(dictionary["type"] as! String, with: [SharedManager.shared.returnJsonObject(dictionary: dictionary)], completion: nil)
    }
    // MARK: - socket call methods
    func sendReject(dictionary:[String:Any]) {

        self.socket.emit(dictionary["type"] as! String, with: [SharedManager.shared.returnJsonObject(dictionary: dictionary)], completion: nil)
    }
    
    func markConversationUnread(dictionary:[String:Any]){
        
        self.socket.emitWithAck("markThisConversationUnread", dictionary).timingOut(after: 0) {data in
        }
    }
    
    func markConversationArchive(dictionary:[String:Any] , completionHandler: @escaping (_ returnValue: [Any]?)->Void)  {
        
        self.socket.emitWithAck("markThisConversationArchive", dictionary).timingOut(after: 0) {data in
            completionHandler(data)
        }
    }
    
    func markConversationSpam(dictionary:[String:Any] , completionHandler: @escaping (_ returnValue: [Any]?)->Void)  {
        
        self.socket.emitWithAck("ignoreThisConversation", dictionary).timingOut(after: 0) {data in
            completionHandler(data)
        }
    }
    
    func sendSDP(dictionary:[String:Any]) {
        self.socket.emit(dictionary["type"] as! String, with: [SharedManager.shared.returnJsonObject(dictionary: dictionary)], completion: nil)
    }
    func sendCandidates(dictionary:[String:Any]) {
        self.socket.emit(dictionary["type"] as! String, with: [SharedManager.shared.returnJsonObject(dictionary: dictionary)], completion: nil)
    }
    func sendReadyForCall(dictionary:[String:Any]) {
        self.socket.emit(dictionary["type"] as! String, with: [SharedManager.shared.returnJsonObject(dictionary: dictionary)], completion: nil)
    }
    
    func sendNewCall(dictionary :[String:Any])  {
        LogClass.debugLog("sendNewCall")
        LogClass.debugLog("dict ===> 34")
        self.socket?.emitWithAck(dictionary["type"] as! String, with: [SharedManager.shared.returnJsonObject(dictionary: dictionary)]).timingOut(after: 0) { (data) in
            let dic = data.first
            self.delegateCallmanager?.didReceiveNewCallData(data: dic as! [String : Any])
        }
    }
    
    func livenotification(dictionary:[String:Any]){

        self.socket.emit("notification", with: [SharedManager.shared.returnJsonObject(dictionary: dictionary)], completion: nil)
    }
    
    func sendaddtocall(dictionary:[String:Any]) {
        self.socket.emit(dictionary["type"] as! String, with: [SharedManager.shared.returnJsonObject(dictionary: dictionary)], completion: nil)
    }
    
    // MARK: - socket user methods
    
    func getGroupCallMembers(dictionary :[String:Any])  {
        var dic:[String:Any] = ["firstname":(SharedManager.shared.userObj?.data.firstname!)! + " " + (SharedManager.shared.userObj?.data.lastname!)!]
        dic["lastname"] = ""
        dic["profile_image"] = SharedManager.shared.userObj?.data.profile_image
        dic["id"] = SharedManager.shared.userObj?.data.id
//        _ = MessageMember(fromDictionary: dic )
//        CallManager.sharedInstance.groupMembersArray.removeAll()
        let value = MessageMember(fromDictionary: dic )
        //CallManager.sharedInstance.groupMembersArray.removeAll()
        //CallManager.sharedInstance.groupMembersArray.append(value)
    }
    func send_call_members(dictionary:[String:Any]) {
        
        self.socket?.emitWithAck("checkCallMembers", SharedManager.shared.returnJsonObject(dictionary: dictionary)).timingOut(after: 0) {data in
            let dictionary : [String : Any] = data.first as! [String : Any]
            self.delegateCallmanager?.didReceiveSendCallMembersAck(data: dictionary)
        }
    }
    
    func check_call_status(dictionary:[String:Any]) {
        self.socket.emitWithAck("checkCallStatus", SharedManager.shared.returnJsonObject(dictionary: dictionary)).timingOut(after: 0) {data in
            let dictionary : [String : Any] = data.first as! [String : Any]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "CallStatus"), object: nil,userInfo: dictionary)
            //self.delegate?.didReceiveCallstatusAck(data: dictionary)
        }
    }
    
    func likeEvent(dict:NSDictionary) {
        if self.socket != nil {
            self.socket.emitWithAck("notification", dict).timingOut(after: 0) {data in


                let dictionary : [String : Any] = data.first as! [String : Any]
                self.delegate?.didReceiveCallstatusAck(data: dictionary)
            }
        }
        
    }
    
    func SendVideoSwitch(dictionary:[String:Any]) {
        self.socket.emit("switchvideo", with: [SharedManager.shared.returnJsonObject(dictionary: dictionary)], completion: nil)
    }
    
    // Notification section...
    func receiveGenericNotification(){
        self.socket.on("notification") {data, ack in
            GenericNotification.shared.manageGenericNotification(arr: data)
        }
    }
    
    
    // MARK: -
    // MARK: Emit Actions...
    
    func emitSomeAction(dict: NSDictionary) {
        self.socket.emit("onJob", dict)
    }
    
    func emitSaveLiveStream(dict: NSDictionary) {
        self.socket.emit("save_stream", dict)
    }
    
    func emitLiveStreamingStayLive(dict: NSDictionary) {
        self.socket.emit("last_packet_sent_at", dict)
    }
    
    func emitFeedComment(dict:NSDictionary) {
        let dataDict = dict ["data"] as! NSDictionary

        let commentDict: NSDictionary = ["new_comment": dataDict]

        self.socket.emit("new_comment", commentDict)
    }
    
    // MARK:Messenger Socket
    func emitChatText(dict:NSDictionary) {
        LogClass.debugLog("dict ===> 1")
        LogClass.debugLog(dict)
        self.socket.emitWithAck("new_message", dict).timingOut(after: 0) {data in
            LogClass.debugLog(data)
            LogClass.debugLog("dict ===> 2")
            if self.commentDelegate?.chatMessageReceived != nil {
                self.commentDelegate?.chatMessageReceived?(res: data as NSArray)
            }
        }
    }
    
    func emitDeleteChatText(dict:[String:Any]) {

        self.socket.emitWithAck("delete_message", dict).timingOut(after: 0) {data in
            LogClass.debugLog(data)
            LogClass.debugLog("dict ===> 3")
        }
    }
    
    func checkUserIsBlocked(dict:NSDictionary , completionHandler: @escaping (_ returnValue: [Any]?)->Void) {
        self.socket.emitWithAck("isUserBlocked", dict).timingOut(after: 0) {data in

            completionHandler(data)
        }
    }
    
    func removeUserFromGroupText(dict:NSDictionary , completionHandler: @escaping (_ returnValue: [Any]?)->Void) {
        self.socket.emitWithAck("removeFromGroupConversation", dict).timingOut(after: 0) {data in
            completionHandler(data)
        }
    }
    
    
    func updateGroupConversation(dict:NSDictionary , completionHandler: @escaping (_ returnValue: [Any]?)->Void) {
          self.socket.emitWithAck("groupConversationDataUpdated", dict).timingOut(after: 0) {data in
              completionHandler(data)
          }
      }
    
    func makeNewAdminForGroup(dict:NSDictionary , completionHandler: @escaping (_ returnValue: [Any]?)->Void) {
        self.socket.emitWithAck("removeFromGroupConversation", dict).timingOut(after: 0) {data in
            LogClass.debugLog(dict)
            LogClass.debugLog("dict ===> 4")
            completionHandler(data)
        }
    }
    
    func addUserstoGroup(dict:NSDictionary , completionHandler: @escaping (_ returnValue: [Any]?)->Void) {
        self.socket.emitWithAck("addUserToGroupConversation", dict).timingOut(after: 0) {data in
            completionHandler(data)
        }
    }
    
    func emitLiveStreamNotificationAction(dict: [String:Any]) {
        self.socket.emit("notification", dict)
    }
    
    func goLiveSession() {
        // self.socket.emit("live_stream_session_id", [:])
        self.socket.emitWithAck("get_live_stream_id", ["generate_new":"true"]).timingOut(after: 60) {data in
            self.commentDelegate?.goLiveSessionSocketResponse?(res: data as NSArray)
        }
    }
    
    //MARK: -
    
    func addReaction(dictionary:[String:Any]){
        self.socket.emitWithAck("reactThisMessage", dictionary).timingOut(after: 0) {data in
            LogClass.debugLog(data)
            LogClass.debugLog("dict ===> 5")
        }
    }
}
