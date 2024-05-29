//
//  SocketIOManager.swift
//  socketio
//
//  Created by apple on 10/23/19.
//  Copyright © 2019 apple. All rights reserved.
//

import Foundation
import SocketIO


////////////appdelegate delegates//////////////////

protocol SocketDelegateAppdelegate {
    func didSocketConnectedAppdelegate(data: [Any])
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
    func didReceiveReadyforcall(data: Available)
    func didReceiveNewCallData(data: [String :Any])
    func didReceiveVideoSwitch(data: [String :Any])

}
extension SocketDelegateCallmanager {
    //default implementation for optional methods

    func didSocketConnected(data: [Any]) {}
    func didSocketDisConnected(data: [Any]) {}
    
    
    func didReceiveOffer(data: SignalingMessage) {}
    func didReceiveAnswer(data: SignalingMessage) {}
    func didReceiveCandidate(data: SignalingMessage){}
    func didReceiveReject(data :[String :Any]){}
    func didReceiveReadyforcall(data: Available){}
    func didReceiveNewCallData(data: [String :Any]){}
    func didReceiveVideoSwitch(data: [String :Any]){}

}

////////////messaging delegates//////////////////


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

class SocketIOManager: NSObject {
    
    static let serverurl:String = AppConfigurations().BaseUrl
    static let sharedInstance = SocketIOManager()
    
    var socket:SocketIOClient!
    var name: String?
    var resetAck: SocketAckEmitter?
    var delegate: SocketDelegate?
    var delegateAppdelegate: SocketDelegateAppdelegate?
    var delegateCallmanager: SocketDelegateCallmanager?
    
    var manager: SocketManager?
    
    // MARK: - socket init methods
    override init() {
        super.init()
    }
    
    func establishConnection() {
        manager = SocketManager(socketURL: URL(string: SocketIOManager.serverurl)!, config: [.log(true), .connectParams(["token" : (SharedManager.shared.userObj?.data.token)! as String])])
        //        self.socket = SocketIOClient(socketURL: URL(string: "http://166.62.121.191:8495")!, config: [.log(true), .reconnects(true), .reconnectWait(10), .forcePolling(true), .forceWebsockets(true)])
        
        socket = manager?.defaultSocket
        addHandlers()
        manager?.forceNew = true
        manager?.reconnects = true
        manager?.reconnectWaitMax = 0
        manager?.reconnectWait = 0
        socket.connect()
    }
    //    func checkConnection() -> Bool {
    //        if (socket == nil){
    //            return false
    //        }
    //        else if socket.manager?.status == .connected {
    //            return true
    //        }
    //        return false
    //
    //    }
    
    //    func checkConnection() -> Bool {
    //        if manager?.status == .connected {
    //            return true
    //        }
    //        return false
    //
    //    }
    
    func closeConnection() {
        socket.disconnect()
        socket.removeAllHandlers()
        manager = nil
        socket = nil
    }
    
    // MARK: - socket background emit methods
    
    func senddidenterBackground(dictionary:[String:Any]) {
        self.socket.emit(dictionary["type"] as! String, with: [SharedManager.shared.returnJsonObject(dictionary: dictionary)])
    }
    
    func senddidenterForeground(dictionary:[String:Any]) {
        self.socket.emit(dictionary["type"] as! String, with: [SharedManager.shared.returnJsonObject(dictionary: dictionary)])
    }
    // MARK: - socket call methods
    func sendReject(dictionary:[String:Any]) {
        print(dictionary)
        self.socket.emit(dictionary["type"] as! String, with: [SharedManager.shared.returnJsonObject(dictionary: dictionary)])
    }
    
    func sendSDP(dictionary:[String:Any]) {
        self.socket.emit(dictionary["type"] as! String, with: [SharedManager.shared.returnJsonObject(dictionary: dictionary)])
    }
    func sendCandidates(dictionary:[String:Any]) {
        self.socket.emit(dictionary["type"] as! String, with: [SharedManager.shared.returnJsonObject(dictionary: dictionary)])
    }
    func sendReadyForCall(dictionary:[String:Any]) {
        self.socket.emit(dictionary["type"] as! String, with: [SharedManager.shared.returnJsonObject(dictionary: dictionary)])
    }
    
    func sendNewCall(dictionary :[String:Any])  {
        print("sendNewCall")
        self.socket.emitWithAck(dictionary["type"] as! String, with: [SharedManager.shared.returnJsonObject(dictionary: dictionary)]).timingOut(after: 0) { (data) in
            let dic = data.first
            self.delegateCallmanager?.didReceiveNewCallData(data: dic as! [String : Any])
        }
    }
    func sendaddtocall(dictionary:[String:Any]) {
        self.socket.emit(dictionary["type"] as! String, with: [SharedManager.shared.returnJsonObject(dictionary: dictionary)])
    }

    // MARK: - socket user methods
    
    func getGroupCallMembers(dictionary :[String:Any])  {
        print("getGroupCallMembers")
                    ///*
        var dic:[String:Any] = ["firstname":(SharedManager.shared.userObj?.data.firstname)! + " " + (SharedManager.shared.userObj?.data.lastname)!]
                    dic["lastname"] = ""
                    dic["profile_image"] = SharedManager.shared.userObj?.data.profile_image
                    dic["id"] = SharedManager.shared.userObj?.data.id
                    let value = MessageMember(fromDictionary: dic )
                    CallManager.sharedInstance.groupMembersArray.removeAll()
                    CallManager.sharedInstance.groupMembersArray.append(value)
        //*/
//                    CallManager.sharedInstance.callscreen?.callerCollectionView.delegate = CallManager.sharedInstance.callscreen
//                    CallManager.sharedInstance.callscreen?.callerCollectionView.dataSource = CallManager.sharedInstance.callscreen
//                    CallManager.sharedInstance.callscreen?.callerCollectionView.reloadData()

//        self.socket.emitWithAck("groupmembers", with: [SharedManager.shared.returnJsonObject(dictionary: dictionary)]).timingOut(after: 0) { (data) in
//            let array : [Any] = data.first as! [Any]
//            print("GROUP CALL MEMBERS =  \(array.count)")
//            CallManager.sharedInstance.groupMembersArray.removeAll()
//
//            for dic in array{
//                let value = MessageMember(fromDictionary: dic as! [String : Any])
//                //dynamic
//                if(value.id == SharedManager.shared.user.id){
////                    value.isConnected = true
//                    CallManager.sharedInstance.groupMembersArray.append(value)
//                }else{
////                    value.isConnected = false
//                }
//                CallManager.sharedInstance.originalgroupMembersArray.append(value)
////                //!dynamic
////                CallManager.sharedInstance.groupMembersArray.append(value)
//
//
//            }
//
//        }
    }
    
    
    func check_call_status(dictionary:[String:Any]) {
        self.socket.emitWithAck("checkCallStatus", SharedManager.shared.returnJsonObject(dictionary: dictionary)).timingOut(after: 0) {data in
            let dictionary : [String : Any] = data.first as! [String : Any]
            self.delegate?.didReceiveCallstatusAck(data: dictionary)
        }
    }
    func SendVideoSwitch(dictionary:[String:Any]) {
        self.socket.emit("switchvideo", with: [SharedManager.shared.returnJsonObject(dictionary: dictionary)])
    }

    
    
    
    
    // MARK: - socket listeners methods
    func addHandlers() {
        socket.on(clientEvent: .connect) {data, ack in
            print("socket connected")
            self.delegateAppdelegate?.didSocketConnectedAppdelegate(data: data)
            self.delegate?.didSocketConnected(data: data)
            self.delegateCallmanager?.didSocketConnected(data: data)
            
        }
        
        socket.on(clientEvent: .disconnect) {data, ack in
            print("socket disconnected")
            self.delegate?.didSocketDisConnected(data: data)
            self.delegateCallmanager?.didSocketDisConnected(data: data)
        }
        
        socket.on(clientEvent: .error) {data, ack in
            print("error on socket")
        }
        
        socket.on(clientEvent: .reconnect) {data, ack in
            print("socket reconnected")
        }
        
        socket.on("welcome") { data,ack in
            print("----------------------------------WELCOME--------------------")
        }
        socket.on("answer") {[weak self] data, ack in
            print("answer received")
            
            let dictionary : [String : Any] = data.first as! [String : Any]
            let offerDic = dictionary["offer"] as! [String:Any]
            //            print(offerDic)
            let sdp = SDP.init(sdp: offerDic["sdp"] as! String)
            //            print(sdp)
            
            do {
                let signalingMessage = try SignalingMessage.init(type: dictionary["type"] as! String, offer: sdp, candidate: dictionary["candidate"] as? Candidate, phone: dictionary["phone"] as? String, photoUrl: dictionary["photoUrl"] as? String, name: dictionary["name"] as? String, connectedUserId: (dictionary["connectedUserId"] as? String)!, isVideo: dictionary["isVideo"] as? Bool,callId:(dictionary["callId"] as? String)!,chatId: (dictionary["chatId"] as? String)!)
                try self?.delegateCallmanager?.didReceiveAnswer(data: signalingMessage)
                
            }
            catch{
                print("crash")
            }
        }
        
        
        
        socket.on("groupCallStatus") {[weak self] data, ack in
            //            print("groupCallStatus received")
            let dictionary : [String : Any] = data.first as! [String : Any]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "CallStatus"), object: nil,userInfo: dictionary)
            
        }
        socket.on("switchvideo") {[weak self] data, ack in
            print("switch video received")
            let dictionary : [String : Any] = data.first as! [String : Any]
            self?.delegateCallmanager?.didReceiveVideoSwitch(data: dictionary)
        }
        socket.on("candidate") {[weak self] data, ack in
            //            print("candidate received")
            let dictionary : [String : Any] = data.first as! [String : Any]
            let candidate = dictionary["candidate"]  as! [String:Any]
            let candidate1 = Candidate.init(sdp: candidate["sdp"] as! String, sdpMLineIndex: candidate["sdpMLineIndex"] as! Int32, sdpMid: candidate["sdpMid"] as! String)
            
            let signalingMessage = SignalingMessage.init(type: dictionary["type"] as! String, offer: nil, candidate: candidate1, phone: dictionary["phone"] as? String, photoUrl: dictionary["photoUrl"] as? String, name: dictionary["name"] as? String, connectedUserId: (dictionary["connectedUserId"] as? String)!, isVideo: dictionary["isVideo"] as? Bool,callId: (dictionary["callId"] as? String)!, chatId: (dictionary["chatId"] as? String)!)
            self?.delegateCallmanager?.didReceiveCandidate(data: signalingMessage)
            
        }
        socket.on("reject") {[weak self] data, ack in
            print("reject received")
            let dictionary : [String : Any] = data.first as! [String : Any]
            self?.delegateCallmanager?.didReceiveReject(data: dictionary)
        }
        socket.on("newcall") {[weak self] data, ack in
            print("newcall received")
            
            let dictionary : [String : Any] = data.first as! [String : Any]
            print(dictionary)
            let signalingMessage = Available.init(type: dictionary["type"] as! String, connectedUserId: (dictionary["connectedUserId"] as? String)!, isAvailable: dictionary["isAvailable"] as? Bool, reason: dictionary["reason"] as? String, name: dictionary["name"] as? String,callId: (dictionary["callId"] as? String)!,chatId: (dictionary["chatId"] as? String)!, photoUrl: dictionary["photoUrl"] as? String)
            //send reject for busy
            //else send ready for call
            var dic = [String:Any]()
            dic["callId"] = signalingMessage.callId
            dic["chatId"] = signalingMessage.chatId
            if(CallManager.sharedInstance.isCallStarted){
                if(signalingMessage.chatId != CallManager.sharedInstance.chatIdGlobal){
                    print("==============CALL STARTED DIFFERENT CHAT ID=============")
                    dic["type"] = "reject"
                    self?.sendReject(dictionary: dic)
                }else{
                    print("==============CALL STARTED SAME CHAT ID=============")
                    self?.getGroupCallMembers(dictionary: ["chatId":signalingMessage.chatId])
                    dic["type"] = "readyforcall"
                    dic["connectedUserId"] = signalingMessage.connectedUserId
                    CallManager.sharedInstance.connectedUserName = signalingMessage.name ?? "group call"
                    SocketIOManager.sharedInstance.sendReadyForCall(dictionary: dic)
                }
            }else{
                print("==============CALL NOT STARTED=============")
                self?.getGroupCallMembers(dictionary: ["chatId":signalingMessage.chatId])
                dic["type"] = "readyforcall"
                dic["connectedUserId"] = signalingMessage.connectedUserId
                CallManager.sharedInstance.connectedUserName = signalingMessage.name ?? "group call"
                SocketIOManager.sharedInstance.sendReadyForCall(dictionary: dic)
            }
        }
        socket.on("readyforcall") {[weak self] data, ack in
            print("readyforcall received")
            
            let dictionary : [String : Any] = data.first as! [String : Any]
            print(dictionary)
            
            let signalingMessage = Available.init(type: dictionary["type"] as! String, connectedUserId: (dictionary["connectedUserId"] as? String)!, isAvailable: dictionary["isAvailable"] as? Bool, reason: dictionary["reason"] as? String, name: dictionary["name"] as? String,callId: (dictionary["callId"] as? String)!,chatId: (dictionary["chatId"] as? String)!, photoUrl: dictionary["photoUrl"] as? String)
            self?.delegateCallmanager?.didReceiveReadyforcall(data: signalingMessage)
            
        }
        socket.on("offer") {[weak self] data, ack in
            print("offer received")
            let dictionary : [String : Any] = data.first as! [String : Any]
            let offerDic = dictionary["offer"] as! [String:Any]
            let sdp = SDP.init(sdp: offerDic["sdp"] as! String)
            //            print(sdp)
            let signalingMessage = SignalingMessage.init(type: dictionary["type"] as! String, offer: sdp, candidate: dictionary["candidate"] as? Candidate, phone: dictionary["phone"] as? String, photoUrl: dictionary["photoUrl"] as? String, name: dictionary["name"] as? String, connectedUserId: (dictionary["connectedUserId"] as? String)!, isVideo: dictionary["isVideo"] as? Bool,callId: (dictionary["callId"] as? String)!,chatId: (dictionary["chatId"] as? String)!)
            
            print("iscallstarted = \(CallManager.sharedInstance.isCallStarted)")
            if(CallManager.sharedInstance.isCallHandled == false) {
                #if targetEnvironment(simulator)
                // we're on the simulator - calculate pretend movement
                #else
                if(CallManager.sharedInstance.isCallStarted == false){
                    ATCallManager.shared.incommingCall(from: signalingMessage.name!, delay: 0)
                }
                #endif
            }
            CallManager.sharedInstance.isCallHandled = false
            CallManager.sharedInstance.isIncomingCall = true
            if(CallManager.sharedInstance.isCallStarted == false){
                CallManager.sharedInstance.startWebrtc()
            }
            CallManager.sharedInstance.didReceiveOffer(data: signalingMessage)
        }
        
        
        
        
        socket.on("error") {data, ack in
            
        }
        socket.onAny {_ in 
            //            print("Got event: \($0.event), with items: \($0.items!)")
        }
    }
    
    /*
     func addObserversForSockets()  {
     //Receiving a notification
     //Calling a function using #selector
     NotificationCenter.default.addObserver(self, selector: #selector(helloReceived), name: NSNotification.Name("hello"), object: nil)
     
     //Posting a notification
     NotificationCenter.default.post(name:
     NSNotification.Name("hello"), object: nil)
     
     }
     @objc private func helloReceived() {
     print("hello world!")
     }
     */
    //    func getChatMessage(completionHandler: @escaping (_ messageInfo: [String: AnyObject]) -> Void) {
    //        socket.on("message") { (dataArray, socketAck) -> Void in
    //            var messageDictionary = [String: AnyObject]()
    //            messageDictionary["nickname"] = dataArray[0] as! String as AnyObject
    //            messageDictionary["message"] = dataArray[1] as! String as AnyObject
    //            messageDictionary["date"] = dataArray[2] as! String as AnyObject
    //
    //            completionHandler(messageDictionary)
    //        }
    //    }
    //    func startChatMessage(completionHandler: @escaping (_ messageInfo: [String: AnyObject]) -> Void) {
    //        socket.on("startChat") { (dataArray, socketAck) -> Void in
    //            var messageDictionary = [String: AnyObject]()
    //            messageDictionary["nickname"] = dataArray[0] as! String as AnyObject
    //            messageDictionary["message"] = dataArray[1] as! String as AnyObject
    //            messageDictionary["date"] = dataArray[2] as! String as AnyObject
    //
    //            completionHandler(messageDictionary)
    //        }
    //    }
    
    
}

