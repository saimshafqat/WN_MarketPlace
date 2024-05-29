//
//  ATCallManager.swift
//  ATCallKit
//
//  Created by Dejan on 19/05/2019.
//  Copyright © 2019 agostini.tech. All rights reserved.
//

import UIKit
import CallKit
import AVFoundation
import WebRTC

class ATCallManager: NSObject {
    
    static let shared: ATCallManager = ATCallManager()
    
    public var provider: CXProvider?
    
    private override init() {
        super.init()
        self.configureProvider()
    }
    
    private func configureProvider() {
        let config = CXProviderConfiguration(localizedName: "KalamTime Call")
        config.supportsVideo = false
        config.includesCallsInRecents = false
        config.iconTemplateImageData = UIImage(named: "CallKitIconApp")!.pngData()
        config.supportedHandleTypes = [.generic]
//        config.ringtoneSound = "ringtone.caf"
        config.maximumCallGroups = 1
        config.maximumCallsPerCallGroup = 1
        provider = CXProvider(configuration: config)
        provider?.setDelegate(self, queue: nil)
//        provider?.setDelegate(self, queue: DispatchQueue.main)
        configureAudioSession()
    }
    
    public func incommingCall(from: String, hasVideo: Bool = false,delay: TimeInterval, callobject:Available) {
        let update = CXCallUpdate()
        update.localizedCallerName = from
        update.hasVideo = hasVideo
        update.supportsHolding = false
        update.supportsGrouping = false
        update.supportsUngrouping = false
        //update.remoteHandle = CXHandle(type: .generic, value: from)
        LogClass.debugLog("callid-debug incommingCall \(callobject.callId)")
        let uuid = UUID()
        RoomClient.sharedInstance.callsReference["\(uuid)"] = callobject
        LogClass.debugLog(RoomClient.sharedInstance.callsReference)
        self.provider?.reportNewIncomingCall(with: uuid, update: update, completion: { (_) in
        })
    }
    
    public func outgoingCall(from: String, connectAfter: TimeInterval,isVideo:Bool, callobject:Available) {
        let controller = CXCallController()
        let fromHandle = CXHandle(type: .generic, value: from)
        let uuid = UUID()
        let startCallAction = CXStartCallAction(call: uuid, handle: fromHandle)
        startCallAction.isVideo = isVideo
        let startCallTransaction = CXTransaction(action: startCallAction)
        controller.request(startCallTransaction) { error in
            if let error = error {
                LogClass.debugLog("ATcallmanager Error requesting transaction: \(error)")
            } else {
                LogClass.debugLog("ATcallmanager Requested transaction successfully")
            }
        }
        RoomClient.sharedInstance.callsReference["\(uuid)"] = callobject

        self.provider?.reportOutgoingCall(with: startCallAction.callUUID, connectedAt: nil)
        //self.provider?.reportOutgoingCall(with: startCallAction.callUUID, startedConnectingAt: Date.now)

    }
    
    func configureAudioSession() {
            let sharedSession = AVAudioSession.sharedInstance()
            do {
                try sharedSession.setCategory(AVAudioSession.Category.playAndRecord)
                try sharedSession.setMode(AVAudioSession.Mode.voiceChat)
                try sharedSession.setPreferredIOBufferDuration(TimeInterval(0.005))
                try sharedSession.setPreferredSampleRate(44100.0)
                
            } catch {
                
            }
    }
}

extension ATCallManager: CXProviderDelegate {
    func providerDidReset(_ provider: CXProvider) {
        
    }
    
    //INCOMING
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        LogClass.debugLog("ATcallmanager call answered \(action.callUUID)")
        LogClass.debugLog("ATcallmanager callsReference \(RoomClient.sharedInstance.callsReference)")

            if let val = RoomClient.sharedInstance.callsReference["\(action.callUUID)"] as? Available {
                RoomClient.sharedInstance.isCallkitShown = false

                RoomClient.sharedInstance.newCallData = val
                
                RoomClient.sharedInstance.chatId = SharedManager.shared.ReturnValueAsInt(value: val.chatId)
                RoomClient.sharedInstance.callId = val.callId
                LogClass.debugLog("callid-debug answered \(RoomClient.sharedInstance.callId)")
                RoomClient.sharedInstance.connectedUserId = val.connectedUserId
                RoomClient.sharedInstance.room_id = val.roomId!
                RoomClient.sharedInstance.connectedUserName = val.name!
                RoomClient.sharedInstance.connectedUserPhoto = val.photoUrl!
                RoomClient.sharedInstance.isVideoCall = val.isVideo!
                if val.callType == "single" {
                    RoomClient.sharedInstance.isGroupCall = false
                }else{
                    RoomClient.sharedInstance.isGroupCall = true
                }
                LogClass.debugLog("isgroupcall \(RoomClient.sharedInstance.isGroupCall)")
                //RoomClient.sharedInstance.callsReference.removeValue(forKey: "\(action.callUUID)")
                LogClass.debugLog("ATcallmanager \(RoomClient.sharedInstance.callsReference)")
            }
            if let vc = AppStoryboard.Call.instance.instantiateViewController(withIdentifier: "CallViewController") as? CallViewController{
                vc.modalPresentationStyle = .fullScreen
                RoomClient.sharedInstance.screen = vc
                if let tabController = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController as? UITabBarController {
                    tabController.presentVC(vc) {

                        var dic = [String:Any]()
                        dic["type"] = "callAnswered"
                        dic["connectedUserId"] = RoomClient.sharedInstance.connectedUserId
                        dic["callId"] = RoomClient.sharedInstance.callId
                        dic["chatId"] = RoomClient.sharedInstance.chatId
                        LogClass.debugLog("callid-debug \(dic)")
                        SocketSharedManager.sharedSocket.socket.emitWithAck("callAnswered", with: [SharedManager.shared.returnJsonObject(dictionary: dic)]).timingOut(after: 0) { (data) in
                            LogClass.debugLog("callid-debug \(data)")
                        }
                    }
                }
            }
        action.fulfill()

    }
    
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        LogClass.debugLog("ATcallmanager call ended \(action.callUUID)")
        LogClass.debugLog("ATcallmanager callsReference \(RoomClient.sharedInstance.callsReference)")

        
        if let val = RoomClient.sharedInstance.callsReference["\(action.callUUID)"] as? Available {
        
            RoomClient.sharedInstance.isCallkitShown = false
            if SharedManager.shared.userObj?.data.id == 0 {
                return
            }
            let dic:[String:Any] = ["room_id":val.roomId!,"user_id":SharedManager.shared.userObj?.data.id ?? 0]
            LogClass.debugLog("reject sent")
            LogClass.debugLog(dic)
            LogClass.debugLog("-----------------------------------------------------")
            let dic1 = ["type":"reject","chatId":SharedManager.shared.ReturnValueAsInt(value: val.chatId),"manually":"1"] as! [String:Any]
            SocketSharedManager.sharedSocket.socket.emit("reject", SharedManager.shared.returnJsonObject(dictionary: dic1))
            
            if SfuSocketIOManager.sharedInstance.socket != nil {
                SfuSocketIOManager.sharedInstance.socket.emit(ActionEvent.ROOM_LEFT, dic)
            }

            if (SharedManager.shared.ReturnValueAsInt(value: val.chatId) == RoomClient.sharedInstance.chatId && val.callId == RoomClient.sharedInstance.callId) || RoomClient.sharedInstance.connections.count == 0{
                RoomClient.sharedInstance.dismissScreenAndTransports()
            }
            RoomClient.sharedInstance.callsReference.removeValue(forKey: "\(action.callUUID)")
            LogClass.debugLog("ATcallmanager \(RoomClient.sharedInstance.callsReference)")
        }


        //SfuSocketIOManager.sharedInstance.socket.emit(ActionEvent.ROOM_LEFT, dic)
        
        /*CallManager.sharedInstance.stopAudioPlayer()
        let calldata = CallManager.sharedInstance.callsReference["\(action.callUUID)"] as? Available
        if CallManager.sharedInstance.isCallStarted == true {
            var dic = [String:String]()
            dic["type"] = "reject"
            if calldata == nil {
                dic["callId"] = CallManager.sharedInstance.callIdGlobal
                dic["chatId"] = CallManager.sharedInstance.chatIdGlobal
            }else
            {
                dic["callId"] = calldata?.callId
                dic["chatId"] = calldata?.chatId
                dic["connectedUserId"] = calldata?.connectedUserId
            }
            dic["manually"] = "1"
            SocketSharedManager.sharedSocket.sendReject(dictionary: dic)
            if CallManager.sharedInstance.callsReference.count == 0 {
                CallManager.sharedInstance.endCallLogic(newcall: true)
            }

        }else{
            CallManager.sharedInstance.endCallLogic(newcall: true)
        }
        CallManager.sharedInstance.callsReference.removeValue(forKey: "\(action.callUUID)")
         LogClass.debugLog("ATcallmanager \(CallManager.sharedInstance.callsReference)")*/

        action.fulfill()
    }
    
    //OUTGOING
    func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        LogClass.debugLog("ATcallmanager call started \(action.uuid)")
        LogClass.debugLog("ATcallmanager callsReference\(RoomClient.sharedInstance.callsReference)")
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
//            action.fulfill()
//        }
        action.fulfill()

    }
    func provider(  _ provider: CXProvider, perform action: CXSetHeldCallAction) {
        LogClass.debugLog("ATcallmanager call held \(action.uuid)")
    }
    
    func provider( _  provider: CXProvider, timedOutPerforming action: CXAction) {
        LogClass.debugLog("ATcallmanager call timedOutPerforming \(action.uuid)")
        
    }
    
    func provider(  _ provider: CXProvider, perform action: CXPlayDTMFCallAction) {
        LogClass.debugLog("ATcallmanager call CXPlayDTMFCallAction \(action.uuid)")
        
    }
    
    func provider(  _ provider: CXProvider, perform action: CXSetGroupCallAction) {
        LogClass.debugLog("ATcallmanager call CXSetGroupCallAction \(action.uuid)")
        
    }
    
    func provider(  _ provider: CXProvider, perform action: CXSetMutedCallAction) {
        LogClass.debugLog("ATcallmanager call CXSetMutedCallAction \(action.uuid)")
        if let tabController = UIApplication.shared.keyWindow?.rootViewController as? UITabBarController {
            if let vc:CallViewController = tabController.presentedViewController as? CallViewController{
                RoomClient.sharedInstance.isAudioEnabled = action.isMuted
                vc.mutecallbtn.sendActions(for: .touchUpInside)
            }
        }
        action.fulfill()

    }
    
    internal func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
        LogClass.debugLog("--------------------------------")
        RTCAudioSession.sharedInstance().audioSessionDidActivate(audioSession)
        RTCAudioSession.sharedInstance().isAudioEnabled = true
        LogClass.debugLog("ATcallmanager calldebug true didActivate audioSession")
    }
    
    internal func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {
        
        LogClass.debugLog("--------------------------------")
        LogClass.debugLog("ATcallmanager calldebug didDeactivate audioSession")
        RTCAudioSession.sharedInstance().audioSessionDidDeactivate(audioSession)
        RTCAudioSession.sharedInstance().isAudioEnabled = false
        LogClass.debugLog("ATcallmanager calldebug false didDeactivate audioSession")
    }
    
}
