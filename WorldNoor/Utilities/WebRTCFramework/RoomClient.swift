//
//  RoomClient.swift
//  mediasoup-ios-cient-sample
//
//  Created by Ethan.
//  Copyright © 2019 Ethan. All rights reserved.
//

import Foundation
import SwiftyJSON
import SocketIO
import WebRTC
import UIKit
import CallKit
import MediaPlayer
import AVKit
import CoreBluetooth
//import ReplayKit


public enum RoomError : Error {
    case DEVICE_NOT_LOADED
    case SEND_TRANSPORT_NOT_CREATED
    case RECV_TRANSPORT_NOT_CREATED
    case DEVICE_CANNOT_PRODUCE_VIDEO
    case DEVICE_CANNOT_PRODUCE_AUDIO
    case PRODUCER_NOT_FOUND
    case CONSUMER_NOT_FOUND
}
struct Connection  {
    var chatId:String?
    var connecteduserid:Int
    var callId:String?
    var audiotransport:RecvTransport?
    var videotransport:RecvTransport?
    var screentransport:RecvTransport?
    var stream:RTCMediaStreamTrack?
    var firstname:String?
    var lastname:String?
    var photoUrl:String?
    var audioconsumer:Consumer?
    var videooconsumer:Consumer?
    var screenconsumer:Consumer?
    var isReconnecting:Bool = false
}

class RoomClient : NSObject {
    static let sharedInstance = RoomClient()

//    let recorder = RPScreenRecorder.shared()
//    var isScreenRecording = false

    var isReconnect = false
    var isButtonsSetup = false
    var room_id = ""
    var room_type = "mediasoup-sfu"
    var chatId = 0
    var screen:CallViewController?
    var device: Device?
    var isSpeakerEnabled = false
    var connections: [Connection] = []
    var callTimerCounter = 0
    var callTimer = Timer()
    var noAnswerTimercounter = 0
    var noAnswerTimer = Timer()
    var failcounter = 0
    var failTimer = Timer()
    var toneTimer = Timer()
    var mambersTimer = Timer()
    var audioPlayer: AVAudioPlayer?
    var isAudioEnabled = false
    var joined:Bool = false
    var isFrontCamera = true
    var connectedUserName = ""
    var connectedUserPhoto = ""
    var isVideoCall = false
    var isIncomingCall = false
    var isCallkitShown = false
    var isGroupCall = false
    var callsReference : [String:Any] = [:]
    var newCallData:Available?
    var isCallInitiated = false
    var isCallConnected = false
    var headphonesConnected = false

    //Fixed values
    let failTime = 25
    let noAnswerTime = 45
    var callId = ""
    var connectedUserId = ""
    var blockedUserArray = [BlockedUsersData]()
    var isAudioSetup = false

    var sendTransport: SendTransport?
    var sendTransportVideo: SendTransport?


    private var sendTransportHandler: SendTransportHandler?
    private var sendTransportHandlerVideo: SendTransportHandler?

    
    private var producerHandler: ProducerHandler?
    private var producerHandlerVideo: ProducerHandler?
    
    private var audioProducer: Producer?
    private var videoProducer: Producer?


    
    override init() {

    }
    func dismissScreenAndTransports(){
        LogClass.debugLog("reject handling connections count\(RoomClient.sharedInstance.connections.count)")
        self.screen?.dismiss(animated: false)
        RoomClient.sharedInstance.closeAllTransport()
        SfuSocketIOManager.sharedInstance.closeConnection()
        MediaCapturer.shared.videoCapturer = nil
        MediaCapturer.shared.videoSource = nil
        for track in MediaCapturer.shared.mediaStream.videoTracks {
            LogClass.debugLog("audio track removed \(track)")
            track.isEnabled = false
            MediaCapturer.shared.mediaStream.removeVideoTrack(track)
            
        }
        for track in MediaCapturer.shared.mediaStream.audioTracks {
            LogClass.debugLog("video track removed \(track)")
            track.isEnabled = false
            MediaCapturer.shared.mediaStream.removeAudioTrack(track)
        }

        RoomClient.sharedInstance.connections.removeAll()
        RoomClient.sharedInstance.resetManager()
        if ATCallManager.shared.provider?.pendingTransactions.count == 0{
            ATCallManager.shared.provider?.invalidate()
        }else{
            LogClass.debugLog("callkit transcations\(ATCallManager.shared.provider?.pendingTransactions.count)")
        }

    }
    func endcallLogic(sendReject:Bool = false){
        let dic:[String:Any] = ["room_id":room_id,"user_id":SharedManager.shared.userObj?.data.id ?? 0]
        LogClass.debugLog("room:left sent")
        LogClass.debugLog(dic)
        LogClass.debugLog("-----------------------------------------------------")
        let dic1 = ["type":"reject","chatId":RoomClient.sharedInstance.chatId,"manually":"1"] as! [String:Any]
    
        if sendReject == true {
            SocketSharedManager.sharedSocket.socket.emit("reject", SharedManager.shared.returnJsonObject(dictionary: dic1))
        }
        if SfuSocketIOManager.sharedInstance.socket != nil {
            if self.isGroupCall == false && self.connections.count < 2 {
                SfuSocketIOManager.sharedInstance.socket.emit(ActionEvent.ROOM_ENDED, dic)
            }else{
                SfuSocketIOManager.sharedInstance.socket.emit(ActionEvent.ROOM_LEFT, dic)
            }
        }
        for item in RoomClient.sharedInstance.callsReference {
            LogClass.debugLog(item)
            let calldata = item.value as? Available
            if calldata?.callId == callId && SharedManager.shared.ReturnValueAsInt(value: calldata?.chatId) == chatId {
                //callsReference.removeValue(forKey: item.key)
                let calluuuid = UUID(uuidString: item.key)!
                let endCallAction = CXEndCallAction(call: calluuuid)
                let transaction = CXTransaction(action: endCallAction)
                let callcontroller = CXCallController()
                callcontroller.request(transaction) { error in
                    LogClass.debugLog(error?.localizedDescription)
                }
            }
        }
        self.dismissScreenAndTransports()

    }
    func minimiserCall()  {
        
        LogClass.debugLog("minimiserCall")
        /*
        CallManager.sharedInstance.callwindow?.resignKey()
        CallManager.sharedInstance.callwindow?.isHidden = true
        CallMinimiser.sharedInstance.showCallBar(name: connectedUserName )
*/
        CallMinimiser.sharedInstance.showCallBar(name: connectedUserName )
        self.screen?.dismiss(animated: true) {
            LogClass.debugLog("screen dismissed")
        }
        LogClass.debugLog("calldebug callscreen dismiss")

    
    }
    func maximiseCall()  {
        LogClass.debugLog("maximiseCall")
        CallMinimiser.sharedInstance.hideCallBar()
        self.screen = AppStoryboard.Call.instance.instantiateViewController(withIdentifier: CallViewController.className) as? CallViewController
        self.screen?.modalPresentationStyle = .overFullScreen
        if let tabController = UIApplication.shared.keyWindow?.rootViewController as? UITabBarController {
            tabController.presentVC(self.screen!) {
                self.screen?.setupCallAgain()
                self.screen?.callerCollectionView.reloadData()
                self.screen?.callMembersTable.reloadData()
            }
        }
        
        /*
        self.callwindow = UIWindow(frame: UIScreen.main.bounds)
        let storyBoard = UIStoryboard(name: "Call", bundle: nil)
        callscreen = storyBoard.instantiateViewController(withIdentifier: CallViewController.className) as? CallViewController
        self.callwindow?.rootViewController = callscreen
        self.callwindow?.makeKeyAndVisible()
*/


    
    }

    func enableDisableVideo(){

        var isVideoOn = false
        if self.sendTransportVideo == nil {
            self.createSendTransport(kind: "video")
            isVideoOn = true
            self.screen?.cameraOnOffBtn.setImage(UIImage(named: "callvideo-on.png"), for: .normal)
            self.screen?.cameraOnOffBtn.isEnabled = false
            self.screen?.cameraSwitchBtn.isHidden = false
        }else{
            //stop video
            self.screen?.localVideoView.isHidden = true
            self.sendTransportVideo?.close()
            self.sendTransportVideo = nil
            self.producerHandlerVideo = nil
            self.sendTransportHandlerVideo = nil
            MediaCapturer.shared.videoCapturer?.stopCapture()
            MediaCapturer.shared.videoCapturer = nil
            MediaCapturer.shared.videoSource = nil
            for track in MediaCapturer.shared.mediaStream.videoTracks{
                LogClass.debugLog("video track removed \(track)")
                track.isEnabled = false
                MediaCapturer.shared.mediaStream.removeVideoTrack(track)
            }
            isVideoOn = false
            self.screen?.cameraOnOffBtn.setImage(UIImage(named: "callvideo-off.png"), for: .normal)
            self.screen?.cameraSwitchBtn.isHidden = true

        }
        let mainObject: [String:Any] = [
            "room_id": room_id,
            "room_type":room_type,
            "user_id":SharedManager.shared.userObj?.data.id ?? 0,
            "is_video_on":isVideoOn
        ]
        SfuSocketIOManager.sharedInstance.socket.emit(ActionEvent.VIDEO_SWITCHED, mainObject)
        LogClass.debugLog("room:VIDEO_SWITCHED sent")
        LogClass.debugLog(mainObject)
        LogClass.debugLog("-----------------------------------------------------")


    }
    func join() throws {
        // Check if the device is loaded
        if !(self.device?.isLoaded())! {
            throw RoomError.DEVICE_NOT_LOADED
        }
        
        // if the user is already joined do nothing
        if self.joined {
            return
        }
        
        self.joined = true
        
     
    }
    
    func createSendTransport(kind:String = "audio") {
        if kind == "both" {
            if (self.sendTransport != nil && self.sendTransport?.getConnectionState() == "completed") {
                return
            }

            self.createWebRtcTransport(direction: "send",kind: "audio")
            if (self.sendTransportVideo != nil && self.sendTransportVideo?.getConnectionState() == "completed") {
                return
            }

            self.createWebRtcTransport(direction: "send",kind: "video")
        }else if(kind == "audio"){
            if (self.sendTransport != nil && self.sendTransport?.getConnectionState() == "completed") {
                return
            }
            self.createWebRtcTransport(direction: "send",kind: "audio")
        }else if(kind == "video"){
            if (self.sendTransportVideo != nil && self.sendTransportVideo?.getConnectionState() == "completed") {
                return
            }
            self.createWebRtcTransport(direction: "send",kind: "video")
        }

    }
    
    
    func produceVideo() throws -> RTCVideoTrack? {
        if self.sendTransportVideo == nil {
            throw RoomError.SEND_TRANSPORT_NOT_CREATED
        }
        

        
        do {
            
            let videoTrack: RTCVideoTrack = try MediaCapturer.shared.createVideoTrack()
            
            let codecOptions: [String:Any] = [
                "videoGoogleStartBitrate": 1000
            ]

            var encodings: Array = Array<RTCRtpEncodingParameters>.init()
            encodings.append(RTCUtils.genRtpEncodingParameters(true, maxBitrateBps: 500000, minBitrateBps: 0, maxFramerate: 60, numTemporalLayers: 0, scaleResolutionDownBy: 0))
            encodings.append(RTCUtils.genRtpEncodingParameters(true, maxBitrateBps: 1000000, minBitrateBps: 0, maxFramerate: 60, numTemporalLayers: 0, scaleResolutionDownBy: 0))
            encodings.append(RTCUtils.genRtpEncodingParameters(true, maxBitrateBps: 1500000, minBitrateBps: 0, maxFramerate: 60, numTemporalLayers: 0, scaleResolutionDownBy: 0))
            
            // TODO: encodings diesn't work with m79 branch?
            self.createProducer(kind:"video",track: videoTrack, codecOptions: nil, encodings: nil)
            
            return videoTrack
        } catch {
            return nil
        }
    }
    func startAudio() {
        do {
            try RoomClient.sharedInstance.produceAudio()
        } catch {
        }
    }
    func produceAudio() throws {
        if self.sendTransport == nil {
            throw RoomError.SEND_TRANSPORT_NOT_CREATED
        }

        
        let audioTrack: RTCAudioTrack = MediaCapturer.shared.createAudioTrack()
        if(audioTrack == nil){
            let dic:[String:Any] = ["room_id":room_id,"user_id":SharedManager.shared.userObj?.data.id ?? 0,"message":"audio track is nil"]
            SfuSocketIOManager.sharedInstance.socket.emit("room:ios_debug_nil", dic)
        }
        self.createProducer(kind:"audio",track: audioTrack, codecOptions: nil, encodings: nil)
    }
    
    func resumeJoinedConsumer(consumer:Consumer,receiveTransport:RecvTransport){
        
        let resumeData:[String:Any] = ["transport_id":receiveTransport.getId()!,"consumer_id":consumer.getId()!,"room_id":self.room_id,"user_id":SharedManager.shared.userObj?.data.id ?? 0]


        SfuSocketIOManager.sharedInstance.socket.emit(ActionEvent.RESUME_CONSMUER_NEW, resumeData)
        consumer.resume()
        
    }
    func onNewConsumer(peerId:Int,type:String,producer:[String:Any],kind:String){
        
        
        let consumerType = "\(peerId)\(type)consumer"
        let producerType = "\(peerId)\(type)producer"
        let dic:[String:Any] = ["connection_id":consumerType,"room_id":room_id,"user_id":SharedManager.shared.userObj?.data.id ?? 0,"room_type":room_type,"transport_type":"consumer"]
       
        let iceServers:[RTCIceServer] = [
            
            RTCIceServer(urlStrings: ["stun:stun.worldnoordev.com:3478?transport=udp"]),
            RTCIceServer(urlStrings: ["turn:turn.worldnoordev.com:3478?transport=udp"],username: "softech", credential: "Kalaam2020"),
            RTCIceServer(urlStrings: ["turn:turn.worldnoordev.com:3478?transport=tcp"],username: "softech", credential: "Kalaam2020"),
            RTCIceServer(urlStrings: ["turn:turn.worldnoordev.com:443?transport=tcp"],username: "softech", credential: "Kalaam2020"),

        ]

        SfuSocketIOManager.sharedInstance.socket.emitWithAck(ActionEvent.CREATE_WEBRTC_TRANSPORT, dic).timingOut(after: 0) {data in
            let dictionary : [String : Any] = data.first as! [String : Any]
           

            let transport = dictionary["transport"] as? [String:Any]
            let id = transport!["id"] as? String
            let iceParameters = transport!["ice_parameters"] as! [String:Any]
            let iceCandidates = transport!["ice_candidates"] as! [Any]
            let dtlsParameters = transport!["dtls_parameters"] as! [String:Any]
            
            let recvTransport:RecvTransport = (self.device?.createRecvTransport(self, id: id, iceParameters: self.returnProperString(dic: iceParameters), iceCandidates: self.returnProperStringArray(dic: iceCandidates), dtlsParameters: self.returnProperString(dic: dtlsParameters)))!

            for i in self.connections.indices {
                if self.connections[i].connecteduserid == peerId {
                    if kind == "video"  {
                        self.connections[i].videotransport = recvTransport
                    }
                    if kind == "audio"  {
                        self.connections[i].audiotransport = recvTransport
                    }
                }
            }
            
                
                //let producer = producers[producerType] as? [String:Any]
                let transport_id = recvTransport.getId().description //audio
            let consumeData : [String:Any] = ["transport_id":transport_id,"producer_id":producer["id"] as! String,"producer_transport_id":producer["transport_id"] as! String,"room_id":self.room_id,"user_id":SharedManager.shared.userObj?.data.id ?? 0,"device_rtp_capabilities":SharedManager.shared.convertToDictionary(text: (self.device?.getRtpCapabilities())!)!]


                SfuSocketIOManager.sharedInstance.socket.emitWithAck(ActionEvent.CONSUME_TRANSPORT, consumeData).timingOut(after: 0) {data in

                    let dictionary : [String : Any] = data.first as! [String : Any]
                  
                    let consumerObject = dictionary["consumer"] as? [String:Any]

                    let id = consumerObject!["id"] as? String
                    let consumerKind = consumerObject!["kind"] as? String
                    let rtpParameters = self.returnProperString(dic: (consumerObject!["rtp_parameters"] as? [String:Any])!)
                    let consumerProducerId = consumerObject!["producer_id"] as? String

                    let consumer = recvTransport.consume(self, id: id, producerId: consumerProducerId, kind: consumerKind, rtpParameters: rtpParameters)
                    
                    
                    
                    for i in self.connections.indices {
                        if self.connections[i].connecteduserid == peerId {
                            if kind == "video"  {
                                self.connections[i].videooconsumer = consumer
                                self.connections[i].isReconnecting = false
                            }
                            if kind == "audio"  {
                                self.connections[i].audioconsumer = consumer
                                self.connections[i].isReconnecting = false
                            }
                        }
                    }

                    self.resumeJoinedConsumer(consumer: consumer!, receiveTransport: recvTransport)
                    DispatchQueue.main.async {
                        self.screen?.callerCollectionView.reloadData()
                        self.screen?.callMembersTable.reloadData()
                    }
                    
                    if RoomClient.sharedInstance.isSpeakerEnabled == true {
                        RoomClient.sharedInstance.switchToSpeakerAudio()
                    }else{
                        RoomClient.sharedInstance.switchToEarPieceAudio()
                    }

                }
        }
    }
    
    
    func returnProperString(dic:[String:Any]) -> String{
        var error : NSError?
        let jsonData = try! JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
        let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
        return jsonString

    }
    func returnProperStringArray(dic:[Any]) -> String{
        var error : NSError?
        let jsonData = try! JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
        let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
        return jsonString

    }
    func sendRoomReconnected(){
        
        let userDic = ["id":SharedManager.shared.userObj?.data.id ?? 0,"first_name":SharedManager.shared.userObj?.data.firstname!,"last_name":SharedManager.shared.userObj?.data.lastname,"profile_pic":SharedManager.shared.userObj?.data.profile_image,"name":SharedManager.shared.userObj?.data.firstname] as [String : Any]
        let object:[String:Any] = [
            "room_id":RoomClient.sharedInstance.room_id,
            "room_type":RoomClient.sharedInstance.room_type,
            "user_id":SharedManager.shared.userObj?.data.id ?? 0,
            "user":userDic
        ]
      

        SfuSocketIOManager.sharedInstance.socket.emit(ActionEvent.ROOM_RECONNECTED, object)

    }

    func sendRoomJoined(){
        
        let userDic = ["id":SharedManager.shared.userObj?.data.id ?? 0,"first_name":SharedManager.shared.userObj?.data.firstname!,"last_name":SharedManager.shared.userObj?.data.lastname,"profile_pic":SharedManager.shared.userObj?.data.profile_image,"name":SharedManager.shared.userObj?.data.firstname] as [String : Any]
        let is_video_on = RoomClient.sharedInstance.isVideoCall ? 1 : 0
        let object:[String:Any] = [
            "room_id":RoomClient.sharedInstance.room_id,
            "room_type":RoomClient.sharedInstance.room_type,
            "user_id":SharedManager.shared.userObj?.data.id ?? 0,
            "user":userDic,
            "is_video_on":"\(is_video_on)",
            "is_audio_on":"1"
        ]
       

        SfuSocketIOManager.sharedInstance.socket.emit(ActionEvent.ROOM_JOINED, object)

    }

    func getPostJoinData(){
        
        if sendTransport != nil {
            if(self.sendTransport?.getConnectionState() == "failed"){
                self.restartTransport(transport: self.sendTransport!)
            }
        }
        if sendTransportVideo != nil {
            if(self.sendTransportVideo?.getConnectionState() == "failed"){
                self.restartTransport(transport: self.sendTransportVideo!)
            }
        }

        
        
        let object1:[String:Any] = ["room_id":self.room_id,"user_id":SharedManager.shared.userObj?.data.id ?? 0,"room_type":room_type]

        
        SfuSocketIOManager.sharedInstance.socket.emitWithAck(ActionEvent.ROOM_POST_JOIN_DATA, object1).timingOut(after: 0) { data in
            let data : [String : Any] = data.first as! [String : Any]

            LogClass.debugLog(data)


            var available_producers = data["available_producers"] as? [String:Any]
            var participants_ids = data["participants_ids"] as? [Int]
            let participants = data["participants"] as? [String:Any]

            for id in participants_ids! {

                let peer = participants?[id.description] as! [String:Any]
                let peerId = SharedManager.shared.ReturnValueAsInt(value: peer["id"])
                let is_Diconnected = SharedManager.shared.ReturnValueAsInt(value: peer["is_disconnected"])

                if SharedManager.shared.userObj?.data.id != peerId{
                    let user = peer["user"] as! [String:Any]
                    var append = true
                    for connection in RoomClient.sharedInstance.connections {
                        if connection.connecteduserid == peerId {
                            append = false
                            var state = connection.audiotransport?.getConnectionState()
                            if(state == "failed"){
                                if connection.audiotransport != nil {
                                    self.restartTransport(transport: connection.audiotransport!)
                                }
                                if connection.videotransport != nil {
                                    self.restartTransport(transport: connection.videotransport!)
                                }
                            }
                        }
                    }
                    if append == true {
                        var connection = Connection(connecteduserid: SharedManager.shared.ReturnValueAsInt(value: user["id"]!), firstname: user["name"] as? String)
                        connection.photoUrl = user["profile_pic"] as? String
                        RoomClient.sharedInstance.connections.append(connection)
                        /*var audioKey = "\(peerId)_user_audio_producer"
                        var videoKey = "\(peerId)_user_video_producer"
                        if available_producers?[audioKey] != nil{
                            self.screen?.consumeProducer(producer: available_producers?[audioKey])
                        }
                        if available_producers?[videoKey] != nil{
                            self.screen?.consumeProducer(producer: available_producers?[videoKey])
                        }*/
                    }
                }
            }
        }
    }
    
    private func restartTransport(transport:Transport){
        
        if(SfuSocketIOManager.sharedInstance.socket != nil){
            let object1:[String:Any] = ["room_id":self.room_id,"user_id":SharedManager.shared.userObj?.data.id ?? 0,"room_type":room_type,"transport_id":transport.getId()!]
            SfuSocketIOManager.sharedInstance.socket.emitWithAck(ActionEvent.RESTART_ICE, object1).timingOut(after: 0) {data in
                LogClass.debugLog("room:restart-ice ack received")
                LogClass.debugLog(data)
                LogClass.debugLog("--------------------------------------------")
                let dictionary : [String : Any] = data.first as! [String : Any]
                let iceParameters: [String:Any] = dictionary["ice_parameters"] as! [String : Any]
                transport.restartIce(self.returnProperString(dic: iceParameters))
            }
        }
        
    }
    private func createWebRtcTransport(direction: String, kind:String = "audio") {
        
        let type = "producer"
        let connection_id = "\(SharedManager.shared.userObj?.data.id ?? 0)_user_\(kind)_\(type)"
        
        let object1:[String:Any] = ["room_id":self.room_id,"user_id":SharedManager.shared.userObj?.data.id ?? 0,"room_type":room_type,"transport_type":type,"connection_id":connection_id]
       

        SfuSocketIOManager.sharedInstance.socket.emitWithAck(ActionEvent.CREATE_WEBRTC_TRANSPORT, object1).timingOut(after: 0) { data in
            //let dic = data.first
            let dictionary : [String : Any] = data.first as! [String : Any]

            let webRtcTransportData: [String:Any] = dictionary["transport"] as! [String : Any]

            let id: String = webRtcTransportData["id"] as! String
            let iceParameters: [String:Any] = webRtcTransportData["ice_parameters"] as! [String : Any]
            let iceCandidatesArray: [Any] = webRtcTransportData["ice_candidates"] as! [Any]
            let dtlsParameters: [String:Any] = webRtcTransportData["dtls_parameters"] as! [String : Any]
            
            

                if kind == "audio" {
                    self.sendTransportHandler = SendTransportHandler.init(parent: RoomClient.sharedInstance)
                    self.sendTransportHandler!.delegate = self.sendTransportHandler!
                    self.sendTransport = self.device?.createSendTransport(self.sendTransportHandler!.delegate!, id: id, iceParameters: self.returnProperString(dic: iceParameters), iceCandidates: self.returnProperStringArray(dic: iceCandidatesArray), dtlsParameters: self.returnProperString(dic: dtlsParameters))
                    LogClass.debugLog("room: sendTransport \(self.sendTransport?.getId())")
                    self.startAudio()

                }
                
                if kind == "video" {
                    self.sendTransportHandlerVideo = SendTransportHandler.init(parent: RoomClient.sharedInstance)
                    self.sendTransportHandlerVideo!.delegate = self.sendTransportHandlerVideo!
                    self.sendTransportVideo = self.device?.createSendTransport(self.sendTransportHandlerVideo!.delegate!, id: id, iceParameters: self.returnProperString(dic: iceParameters), iceCandidates: self.returnProperStringArray(dic: iceCandidatesArray), dtlsParameters: self.returnProperString(dic: dtlsParameters))

                    DispatchQueue.main.async {
                        self.screen?.startVideo()
                    }
                }
        }
    }
    
    private func createProducer(kind:String,track: RTCMediaStreamTrack, codecOptions: String?, encodings: Array<RTCRtpEncodingParameters>?) {
        
        //LogClass.debugLog("room: track \(track.isEnabled) \(track.kind) \(track.trackId)")
        if kind == "audio" {
            self.producerHandler = ProducerHandler.init()
            self.producerHandler!.delegate = self.producerHandler!
            self.audioProducer = self.sendTransport!.produce(self.producerHandler!.delegate!, track: track, encodings: encodings, codecOptions: codecOptions)
            
            let dic:[String:Any] = ["room_id":room_id,"user_id":SharedManager.shared.userObj?.data.id ?? 0,"message":"audio track is produced"]
            SfuSocketIOManager.sharedInstance.socket.emit("room:ios_debug_produced", dic)

        }
        if kind == "video" {
            self.producerHandlerVideo = ProducerHandler.init()
            self.producerHandlerVideo!.delegate = self.producerHandlerVideo!
            self.videoProducer = self.sendTransportVideo!.produce(self.producerHandlerVideo!.delegate!, track: track, encodings: encodings, codecOptions: codecOptions)

        }

    }
    
    private func handleLocalTransportConnectEvent(transport: Transport, dtlsParameters: String) {
        
        
        let dtlsdic = ["dtls_parameters":dtlsParameters.toJSON()!]
        let connectWebRtcTransportRequest: [String:Any] = [
            "action": ActionEvent.CONNECT_WEBRTC_TRANSPORT,
            "room_id": room_id,
            "transport_id": transport.getId()!,
            "user_id":SharedManager.shared.userObj?.data.id ?? 0,
            "connect_parameters": dtlsdic
        ]
      

        SfuSocketIOManager.sharedInstance.socket.emit(ActionEvent.CONNECT_WEBRTC_TRANSPORT, connectWebRtcTransportRequest)

        
    }
    private func handleLocalTransportProduceEvent(transport: Transport, kind: String, rtpParameters: String, appData: String) -> String {
        
        
        let params = ["kind":kind,"rtp_parameters":rtpParameters.toJSON()!] as [String : Any]
        let produceWebRtcTransportRequest: [String:Any] = [
            "action": ActionEvent.PRODUCE,
            "room_id": room_id,
            "transport_id": transport.getId()!,
            "track_type":"user",
            "track_kind":kind,
            "user_id":SharedManager.shared.userObj?.data.id ?? 0,
            "room_type":room_type,
            "producer_name":"\(SharedManager.shared.userObj?.data.id ?? 0)_user_\(kind)_producer",
            "produce_parameters":params
        ]
      

        var pId = ""
        SfuSocketIOManager.sharedInstance.socket.emitWithAck(ActionEvent.PRODUCE, produceWebRtcTransportRequest).timingOut(after: 0) {data in
           
            RoomClient.sharedInstance.sendRoomJoined()

            let dictionary : [String : Any] = data.first as! [String : Any]
            let producer = dictionary["producer"] as! [String:Any]
            var pId = producer["id"] as! String
            //return pId
        }

        return pId
    }
    
    
    func resetManager(){
        UIApplication.shared.isIdleTimerDisabled = false
        self.stopAudioPlayer()
        isReconnect = false
        isButtonsSetup = false
        isCallkitShown = false
        room_id = ""
        room_type = "mediasoup-sfu"
        chatId = 0
        screen = nil
        device = nil
        isSpeakerEnabled = false
        connections.removeAll()
        isCallInitiated = false
        isCallConnected = false
        headphonesConnected = false
        toneTimer.invalidate()
        callTimer.invalidate()
        mambersTimer.invalidate()
        noAnswerTimer.invalidate()
        failTimer.invalidate()
        callId = ""
        connectedUserId = ""
//        callsReference = [:]
        newCallData = nil
        callTimerCounter = 0
        noAnswerTimercounter = 0
        failcounter = 0
        

        audioPlayer?.stop()
        audioPlayer = nil
        isAudioEnabled = false
        joined = false
        isFrontCamera = true
        connectedUserName = ""
        connectedUserPhoto = ""
        isVideoCall = false
        isIncomingCall = false
        isGroupCall = false
        sendTransport?.close()
        sendTransportVideo?.close()

        sendTransport = nil
        sendTransportVideo = nil

        sendTransportHandler = nil
        sendTransportHandlerVideo = nil

        producerHandler = nil
        producerHandlerVideo = nil
        
        audioProducer = nil
        videoProducer = nil
        CallMinimiser.sharedInstance.hideCallBar()
        blockedUserArray.removeAll()
        isAudioSetup = false
        NotificationCenter.default.removeObserver(self, name: AVAudioSession.routeChangeNotification, object: nil)
        //isScreenRecording = false


    }
    func closeAllTransport (){
        
        //cloase all receiving transports in a loop
        self.sendTransport?.close()
        //self.sendTransport?.dispose()
        self.sendTransportVideo?.close()
        //self.sendTransportVideo?.dispose()
        
        self.audioProducer?.close()
        self.videoProducer?.close()
        
        for i in self.connections.indices{
            self.connections[i].videooconsumer?.close()
            self.connections[i].audioconsumer?.close()
            self.connections[i].screenconsumer?.close()
            self.connections[i].videotransport?.close()
            self.connections[i].audiotransport?.close()
            self.connections[i].screentransport?.close()
        }
        self.connections.removeAll()

    }
    public func switchToEarPieceAudio(){

        let sharedSession = AVAudioSession.sharedInstance()
        do {
            
            try sharedSession.setCategory(AVAudioSession.Category.playAndRecord,options: [ .allowBluetooth, .allowBluetoothA2DP ])
            try sharedSession.setMode(AVAudioSession.Mode.voiceChat)
            try sharedSession.setPreferredIOBufferDuration(TimeInterval(0.005))
            try sharedSession.setPreferredSampleRate(44100.0)
            try sharedSession.overrideOutputAudioPort(AVAudioSession.PortOverride.none)
            try sharedSession.setActive(true)
            isSpeakerEnabled = false
            self.screen?.speakerBtn.setImage(UIImage(named: "callspeaker-off"), for: .normal)
            LogClass.debugLog("-------------------------------------------")
            LogClass.debugLog("calldebug EAR PIECE")
            LogClass.debugLog("-------------------------------------------")
        } catch let error as NSError {
            LogClass.debugLog("audioSession error: \(error.localizedDescription)")
        }
    }
    
    public func switchToSpeakerAudio() {

        let sharedSession = AVAudioSession.sharedInstance()
        do {
            try sharedSession.setCategory(AVAudioSession.Category.playAndRecord,options: [ .allowBluetooth, .allowBluetoothA2DP])
            try sharedSession.setMode(AVAudioSession.Mode.voiceChat)
            try sharedSession.setPreferredIOBufferDuration(TimeInterval(0.005))
            try sharedSession.setPreferredSampleRate(44100.0)
            try sharedSession.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
            try sharedSession.setActive(true)
            isSpeakerEnabled = true
            self.screen?.speakerBtn.setImage(UIImage(named: "callspeaker-on"), for: .normal)
            LogClass.debugLog("-------------------------------------------")
            LogClass.debugLog("calldebug SPEAKER")
            LogClass.debugLog("-------------------------------------------")
            
        } catch let error as NSError {
            LogClass.debugLog("audioSession error: \(error.localizedDescription)")
        }
        
    }

    func playCallTone(tuneName:String = "dial_tone",loops:Int = -1){
        if SharedManager.shared.isiPadDevice {
            self.switchToSpeakerAudio()
        }else{
            if(self.isVideoCall){
                self.switchToSpeakerAudio()
            }else{
                self.switchToEarPieceAudio()
            }
        }
        LogClass.debugLog("playCallTone")
        do {
            if let fileURL = Bundle.main.path(forResource: tuneName, ofType: "mp3") {
                self.audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: fileURL))
                self.audioPlayer?.prepareToPlay()
                self.audioPlayer?.volume = 1.0
                self.audioPlayer?.numberOfLoops = loops
                self.audioPlayer?.play()
            } else {
                LogClass.debugLog("No file with specified name exists")
            }
        } catch let error {
            LogClass.debugLog("Can't play the audio file failed with an error \(error.localizedDescription)")
        }

    }
    func playCallWaitToneRepeatedly(){
        toneTimer.invalidate() // just in case this button is tapped multiple times
        toneTimer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(callTonetimerAction), userInfo: nil, repeats: true)

    }
    @objc func callTonetimerAction(){
        LogClass.debugLog("callTonetimerAction")
        RoomClient.sharedInstance.playCallTone(tuneName: "call_wait",loops: 0)
    }
    //MARK: - helper functions
    
    func setupAudioRouteNotifications() {
        // Get the default notification center instance.
        let nc = NotificationCenter.default
        nc.addObserver(self,
                       selector: #selector(handleRouteChange),
                       name: AVAudioSession.routeChangeNotification,
                       object: nil)
    }

    @objc func handleRouteChange(notification: Notification) {
        
        LogClass.debugLog("handleRouteChange")
        //        LogClass.debugLog("============================================================================")
        //        LogClass.debugLog(notification.userInfo as Any)
        guard let userInfo = notification.userInfo,
              let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
              let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else {
            return
        }
        
        // Switch over the route change reason.
        switch reason {
            
        case .newDeviceAvailable: // New device found.
            let session = AVAudioSession.sharedInstance()
            headphonesConnected = hasHeadphones(in: session.currentRoute)
            
        case .oldDeviceUnavailable: // Old device removed.
            if let previousRoute =
                userInfo[AVAudioSessionRouteChangePreviousRouteKey] as? AVAudioSessionRouteDescription {
                headphonesConnected = hasHeadphones(in: previousRoute)
            }
            
        default: ()
        }
        
        //        LogClass.debugLog("===================================")
        //        LogClass.debugLog(headphonesConnected)
        
    }
    func hasHeadphones(in routeDescription: AVAudioSessionRouteDescription) -> Bool {
        // Filter the outputs to only those with a port type of headphones.
        return !routeDescription.outputs.filter({$0.portType == .headphones}).isEmpty
    }
    func bluetoothAudioConnected() -> Bool{
        let outputs = AVAudioSession.sharedInstance().currentRoute.outputs
        for output in outputs{
            if output.portType == AVAudioSession.Port.bluetoothA2DP || output.portType == AVAudioSession.Port.bluetoothHFP || output.portType == AVAudioSession.Port.bluetoothLE{
                return true
            }
        }
        return false
    }

    func stopAudioPlayer(){
        LogClass.debugLog("stopRinger")

        toneTimer.invalidate()
        if audioPlayer != nil {
            if audioPlayer!.isPlaying {
                audioPlayer?.stop()
                audioPlayer = nil
            }
        }
    }
    func startCallTimer(){
        LogClass.debugLog("startCallTimer")
        self.callTimerCounter = 0
        self.callTimer.invalidate() // just in case this button is tapped multiple times
        self.callTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.callTimerAction), userInfo: nil, repeats: true)
        
        
        LogClass.debugLog("room: firstview \(self.screen?.firstView.isHidden)")
        if(self.screen?.firstView.isHidden == false){
            initialSetup()
        }
        
        DispatchQueue.main.async {
            
            self.screen?.callerCollectionView.reloadData()
            self.screen?.callMembersTable.reloadData()
            var changedText = "This Call is End-to-End Encrypted"
            if(self.connections.count == 0){
                self.screen?.callEncryptionLbl.text = changedText
            }
            if(self.screen == nil){
                self.screen?.callEncryptionLbl.text = "\(changedText)."
            }

        }


    }
    @objc func callTimerAction() {
        callTimerCounter += 1
        self.screen?.calltimerlabel.text = "\(convertToHMS(number: callTimerCounter))"
        CallMinimiser.sharedInstance.updateTimerLabeltext(time: self.screen?.calltimerlabel.text ?? "00:00")
    }
    func startNoAnswerTimer(){
        LogClass.debugLog("startNoAnswerTimer")
        noAnswerTimercounter = 0
        noAnswerTimer.invalidate() // just in case this button is tapped multiple times
        noAnswerTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(noAnswerTimerAction), userInfo: nil, repeats: true)
    }
    @objc func noAnswerTimerAction() {
        LogClass.debugLog("noanswertimer")
        noAnswerTimercounter += 1
        if noAnswerTimercounter == noAnswerTime - 2 {
            self.screen?.calltimerlabel.text = "No answer"
        }
        if noAnswerTimercounter == noAnswerTime {
            if RoomClient.sharedInstance.isIncomingCall == false  {
                let alert = SharedManager.shared.showBasicAlertGlobal(message: "The person you are calling is not reachable at this time. Please call later.")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    if let tabController = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController as? UITabBarController {
                        tabController.presentVC(alert) {
                        }
                    }
                }
            }
            LogClass.debugLog("noasnwertimer ENDED calldebug")
            noAnswerTimer.invalidate()
            RoomClient.sharedInstance.endcallLogic(sendReject: false)
            
            

        }
    }
    func convertToHMS(number: Int) -> String {
      let hour    = number / 3600;
      let minute  = (number % 3600) / 60;
      let second = (number % 3600) % 60 ;
      
      var h = String(hour);
      var m = String(minute);
      var s = String(second);
      
      if h.count == 1{
          h = "0\(hour)";
      }
      if m.count == 1{
          m = "0\(minute)";
      }
      if s.count == 1{
          s = "0\(second)";
      }
      
      return "\(h):\(m):\(s)"
    }

    func switchCameraOrientation() {
        if ((MediaCapturer.shared.videoCapturer?.captureSession.isRunning) != nil) {
            if isFrontCamera {
                isFrontCamera = false
            } else {
                isFrontCamera = true
            }
            MediaCapturer.shared.swapCamera()
        }
    }

    func toggleMute(){
        if(isAudioEnabled == false){
            isAudioEnabled = true
            for track in MediaCapturer.shared.mediaStream.audioTracks {
                LogClass.debugLog("newcall audio track enabled \(track)")
                track.isEnabled = true
            }
            self.screen?.mutecallbtn.setImage(UIImage(named: "callunmute"), for: .normal)

        }else{
            isAudioEnabled = false
            for track in MediaCapturer.shared.mediaStream.audioTracks {
                LogClass.debugLog("newcall audio track disabled \(track)")
                track.isEnabled = false
            }
            self.screen?.mutecallbtn.setImage(UIImage(named: "callmute"), for: .normal)
        }
        let mainObject: [String:Any] = [
            "room_id": room_id,
            "room_type":room_type,
            "user_id":SharedManager.shared.userObj?.data.id ?? 0,
            "is_audio_on":isAudioEnabled
        ]
        SfuSocketIOManager.sharedInstance.socket.emit(ActionEvent.AUDIO_SWITCHED, mainObject)
        LogClass.debugLog("room:audio-switched sent")
        LogClass.debugLog(mainObject)
        LogClass.debugLog("-----------------------------------------------------")


    }
    func toggleSpeaker(){
        if (isSpeakerEnabled){
            switchToEarPieceAudio()
        }else{
            switchToSpeakerAudio()
        }

    }
    
    func isEarPieceAvailable() -> Bool{
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            return false; /* Device is iPad */
        }
        else
        {
            return true /* Device is iPhone */
        }
        
    }
    func setupAudioRoute(){

        if(isAudioSetup == false){
            if SharedManager.shared.isiPadDevice {
                self.switchToSpeakerAudio()
            }else{
                if(self.isVideoCall){
                    self.switchToSpeakerAudio()
                }else{
                    self.switchToEarPieceAudio()
                }
            }
            isAudioSetup = true
            

            let bluetoothConnected = isBluetoothHandsfreeConnected()

            if bluetoothConnected {
                if isIncomingCall == true {
                    //showAudioRoutes()
                }
            } else {
            }
        }
    }
    func isBluetoothHandsfreeConnected() -> Bool {
        let audioSession = AVAudioSession.sharedInstance()
        
        if let outputs = audioSession.currentRoute.outputs as? [AVAudioSessionPortDescription] {
            for output in outputs {
                if output.portType == AVAudioSession.Port.bluetoothHFP || output.portType == AVAudioSession.Port.bluetoothLE {
                    return true
                }
            }
        }
        return false
    }
    func showAudioRoutes(){
        
        let routePickerView = AVRoutePickerView(frame: .zero)
        routePickerView.isHidden = true
        self.screen?.view.addSubview(routePickerView)
        let routePickerButton = routePickerView.subviews.first(where: { $0 is UIButton }) as? UIButton
        routePickerButton?.sendActions(for: .touchUpInside)

    }
    func connectedStateChanges(){
        if(isButtonsSetup == false){
            initialSetup()
            isButtonsSetup = true
        }
    }
    
    func initialSetup(){

        self.screen?.mutecallbtn.setImage(UIImage(named: "callunmute"), for: .normal)
        self.screen?.firstView.isHidden = true
        self.screen?.endcallbtn.isHidden = false
        self.screen?.speakerBtn.isHidden = false
        self.screen?.mutecallbtn.isHidden = false
        self.screen?.addtocallBtn.isHidden = false
        self.screen?.optionsbtnView.isHidden = false
        self.screen?.minimiseBtn.isHidden = false

        self.stopAudioPlayer()
        isAudioEnabled = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.setupAudioRoute()
        }


        if (self.isVideoCall) {
            self.screen?.cameraSwitchBtn.isHidden = false
            self.screen?.screenshareBtn.isHidden = true
            self.screen?.cameraOnOffBtn.isHidden = false
            isFrontCamera = true
            

            if self.isIncomingCall == false {
                self.screen?.localVideoView.isHidden = false
                if(MediaCapturer.shared.videoCapturer?.captureSession.isRunning == true){
                    self.screen?.cameraOnOffBtn.setImage(UIImage(named: "callvideo-on.png"), for: .normal)
                }else{
                    self.screen?.cameraOnOffBtn.setImage(UIImage(named: "callvideo-off.png"), for: .normal)
                }
            }

        }else{
            self.screen?.localVideoView.isHidden = true
            self.screen?.cameraSwitchBtn.isHidden = true
            self.screen?.screenshareBtn.isHidden = true
            self.screen?.cameraOnOffBtn.isHidden = false
        }
    }
    
private class SendTransportHandler : NSObject, SendTransportListener {
        fileprivate weak var delegate: SendTransportListener?
        private var parent: RoomClient
        
        init(parent: RoomClient) {
            self.parent = parent
        }

        func onConnect(_ transport: Transport!, dtlsParameters: String!) {
            self.parent.handleLocalTransportConnectEvent(transport: transport, dtlsParameters: dtlsParameters)
        }
        
        func onConnectionStateChange(_ transport: Transport!, connectionState: String!) {
            if connectionState == "connected" {
            }
            if connectionState == "failed" {
                self.parent.restartTransport(transport: transport)
            }

        }
        
        func onProduce(_ transport: Transport!, kind: String!, rtpParameters: String!, appData: String!, callback: ((String?) -> Void)!) {
            let producerId = self.parent.handleLocalTransportProduceEvent(transport: transport, kind: kind, rtpParameters: rtpParameters, appData: appData)
            
            callback(producerId)
        }
    }
    
    
    // Class to handle producer listener events
    private class ProducerHandler : NSObject, ProducerListener {
        fileprivate weak var delegate: ProducerListener?
        
        func onTransportClose(_ producer: Producer!) {
        }
    }
    
}
extension RoomClient:AVRoutePickerViewDelegate{
    func routePickerViewWillBeginPresentingRoutes(_ routePickerView: AVRoutePickerView){
    }

    func routePickerViewDidEndPresentingRoutes(_ routePickerView: AVRoutePickerView){
        
    }

}
extension RoomClient:ConsumerListener{
    func onTransportClose(_ consumer: Consumer!) {
    }
    
    
}
extension RoomClient:RecvTransportListener{
    func onConnect(_ transport: Transport!, dtlsParameters: String!) {
        let dtlsParameters : [String:Any] = ["dtls_parameters":SharedManager.shared.convertToDictionary(text: dtlsParameters)]
        let connectData : [String:Any] = ["transport_id":transport.getId()!,"room_id":room_id,"user_id":SharedManager.shared.userObj?.data.id ?? 0,"connect_parameters":dtlsParameters]


        SfuSocketIOManager.sharedInstance.socket.emit(ActionEvent.CONNECT_WEBRTC_TRANSPORT, connectData)
    }
    
    func onConnectionStateChange(_ transport: Transport!, connectionState: String!) {
        if connectionState == "connected" {
            
 
            /* //TODO: blocked
            if(self.blockedUserArray == nil){
                self.getBlockedUserList()
            }*/
            if !callTimer.isValid {
                DispatchQueue.main.async {
                    self.isCallConnected = true
                    self.startCallTimer()
                    self.noAnswerTimer.invalidate()
                }
            }
        }
        if connectionState == "failed" {
            self.restartTransport(transport: transport)
        }
    }
}
extension String {
    func toJSON() -> Any? {
        guard let data = self.data(using: .utf8, allowLossyConversion: false) else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
    }
}

extension Array {
    mutating func mutateEach(by transform: (inout Element) throws -> Void) rethrows {
        self = try map { el in
            var el = el
            try transform(&el)
            return el
        }
     }
}

extension MutableCollection {
    mutating func mutateEach(_ body: (inout Element) throws -> Void) rethrows {
        for index in self.indices {
            try body(&self[index])
        }
    }
}
extension Array {
    func toJSON() throws -> Data {
        return try JSONSerialization.data(withJSONObject: self, options: JSONSerialization.WritingOptions(rawValue: 0))
    }
}
