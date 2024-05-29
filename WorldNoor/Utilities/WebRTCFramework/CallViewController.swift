//
//  CallViewController.swift
//  SimpleWebRTC
//
//  Created by n0 on 2019/01/05.
//  Copyright © 2019年 n0. All rights reserved.
//

import UIKit
import Starscream
import WebRTC
import UIKit
import CallKit
import SwiftySound
import Contacts
import ContactsUI
import Lottie
import CoreData
import SDWebImage
import MBProgressHUD
import SwiftEntryKit

class CallMembersCell: UITableViewCell {
    
    @IBOutlet weak var callerimage: UIImageView!
    {
        didSet{
            callerimage.circularView()
        }
    }
    @IBOutlet weak var callername: UILabel!{
        didSet{
            callername.makeFontDynamicBody()
        }
    }
    @IBOutlet weak var callerStatusBtn: UIButton!{
        didSet{
            callerStatusBtn.makeFontDynamic(.caption1, weight: .regular)
        }
    }
    @IBAction func callerStatusBtnTapped(_ sender: UIButton) {
        
    }
}


class CallerCell: UICollectionViewCell {
    
    @IBOutlet weak var callerimage: UIImageView!
    @IBOutlet weak var callername: UILabel!
    @IBOutlet weak var callerVideo: UIView!
    @IBOutlet weak var callStatus: UILabel!
    var remoteRenderView: RTCEAGLVideoView?//multiple
    var userId = 0
    
}
class CallViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,RTCVideoViewDelegate,UIGestureRecognizerDelegate/*,TCPickerViewOutput*/ {
    
    @IBOutlet weak var fullscreenView: UIView!
    //MARK: - Outlets
    @IBOutlet weak var topGreenView: UIView!
    @IBOutlet weak var addtocallBtn: UIButton!
    @IBOutlet weak var calltypelabel: UILabel!
    @IBOutlet weak var calltimerlabel: UILabel!
    @IBOutlet weak var callername: UILabel!
    @IBOutlet weak var minimiseBtn: UIButton!
    @IBOutlet weak var bottomBarBtn: UIButton!

    @IBOutlet weak var bottomGreenView: UIView!{
        didSet{
            bottomGreenView.roundCorners(radius: 15, bordorColor: .blueColor, borderWidth: 0.5)
        }
    }

    //middle view
    //@IBOutlet weak var callActionsStackView: UIStackView!
    @IBOutlet weak var endcallbtn: UIButton!
    @IBOutlet weak var acceptcallbtn: UIButton!
    
    //bottonview
    @IBOutlet weak var optionsbtnView: UIView!
    @IBOutlet weak var speakerBtn: UIButton!
    @IBOutlet weak var cameraSwitchBtn: UIButton!
    @IBOutlet weak var mutecallbtn: UIButton!
    @IBOutlet weak var screenshareBtn: UIButton!
    @IBOutlet weak var cameraOnOffBtn: UIButton!
    @IBOutlet weak var firstImageView: UIImageView!{
        didSet{
            firstImageView.circularView(bordorColor: .white, borderWidth: 5)
        }
    }
    @IBOutlet weak var callEncryptionLbl: UILabel!
    @IBOutlet weak var firstView: UIView!
    
    @IBOutlet weak var endCallBtnBIG: UIButton!
    @IBOutlet weak var firstAnimationImage: UIImageView!
    @IBOutlet weak var callMembersTable: UITableView!
    @IBOutlet weak var participantsLbl: UILabel!


    
    //    @IBOutlet weak var videoswitcBtn: UIButton!
    
    //MARK: - Properties
    
    // UI
    var wsStatusLabel: UILabel!
    var webRTCStatusLabel: UILabel!
    var webRTCMessageLabel: UILabel!
    var likeImage: UIImage!
    var likeImageViewRect: CGRect!
    var isLocalViewFullscreen: Bool = false


    @IBOutlet weak var localVideoView: UIView!
    @IBOutlet weak var localRenderView: RTCEAGLVideoView!
    
    
    @IBOutlet weak var callerCollectionView: UICollectionView!
    var margin:CGFloat = 0
    var contactsArray = [SaveContactsObject]()
//    var contactsDBArray = [Contact]()

    var localVideoFrame:CGRect?
    var contactStore = CNContactStore()
    var contactDict = [[String: Any]]()
    var navconContacts:UINavigationController = UINavigationController()
    var loadingNotification = MBProgressHUD()
    @IBOutlet var bottomBarConstraint:NSLayoutConstraint?
    
    var bottomValue : CGFloat!
    var topValue : CGFloat!
    //var isGroupCall = false
    //MARK:  add to call actions
    @IBAction func addtocallTapped(_ sender: UIButton) {
        self.showContacts()
    }
    @IBAction func bottomBarTapped(_ sender: UIButton) {
        
        
        if(bottomBarConstraint?.constant == bottomValue){
            bottomBarBtn.setImage(UIImage(named: "downcall"), for: .normal)
            UIView.animate(withDuration:0.3,
                           delay: 1.0,
                           usingSpringWithDamping: 0.5,
                           initialSpringVelocity: 0.5,
                           options: .curveEaseInOut,
                           animations: {
                self.bottomBarConstraint?.constant = self.topValue
            }, completion: {
                //Code to run after animating
                (value: Bool) in
            })

        }else{
            bottomBarBtn.setImage(UIImage(named: "upcall"), for: .normal)
            UIView.animate(withDuration:0.3,
                           delay: 1.0,
                           usingSpringWithDamping: 0.5,
                           initialSpringVelocity: 0.5,
                           options: .curveEaseInOut,
                           animations: {
                self.bottomBarConstraint?.constant = self.bottomValue
            }, completion: {
                //Code to run after animating
                (value: Bool) in
            })

        }
        
    }


    func showContacts() {
        
        var items:[SaveContactsObject] = [SaveContactsObject]()
        for contact in contactsArray{
            if contact.id != 0 {
                var found = false
                for connection in RoomClient.sharedInstance.connections{
                    if(connection.connecteduserid == contact.id){
                        found = true
                    }
                }
                if(!found){
                    items.append(contact)
                }
            }
        }
        
        
        let goLive = AppStoryboard.Broadcasting.instance.instantiateViewController(withIdentifier: "ChatFriendController") as! ChatFriendController
        goLive.delegate = self
        
        navconContacts = UINavigationController(rootViewController: goLive)
        navconContacts.title = "Select contacts to call"
        self.view.addSubview(navconContacts.view)
        self.addChild(navconContacts)
        navconContacts.didMove(toParent: self)

        
    }
    
    

    //MARK:  buttons actions
    
    @IBAction func cameraOnOffTapped(_ sender: UIButton) {
        
        
        RoomClient.sharedInstance.enableDisableVideo()
        
        
        /*
        if(!WebRTCClient.sharedInstance.isScreenRecording){
             switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .denied:
         LogClass.debugLog("Denied, request permission from settings")
                CallManager.sharedInstance.presentCameraSettings(isVideoenabled: CallManager.sharedInstance.isVideoEnabled,endcalllogic: false)
            case .restricted:
         LogClass.debugLog("Restricted, device owner must approve")
            case .authorized:
         LogClass.debugLog("Authorized, proceed")
                switchVideoAudio()
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { success in
                    if success {
                        DispatchQueue.main.async {
                            self.switchVideoAudio()
                        }
                        
                    } else {
                        DispatchQueue.main.async {
                            CallManager.sharedInstance.presentCameraSettings(isVideoenabled: CallManager.sharedInstance.isVideoEnabled,endcalllogic: false)
                        }
                    }
                }
            @unknown default:
         LogClass.debugLog("default")
            }
        }
        */
        
        /*
         if(CallManager.sharedInstance.isVideoEnabled && !WebRTCClient.sharedInstance.isScreenRecording){
         CallManager.sharedInstance.callscreen?.callerCollectionView.delegate = CallManager.sharedInstance.callscreen
         CallManager.sharedInstance.callscreen?.callerCollectionView.dataSource = CallManager.sharedInstance.callscreen
         CallManager.sharedInstance.showlocalView = !CallManager.sharedInstance.showlocalView
         CallManager.sharedInstance.cameraSession?.isEnabled = !CallManager.sharedInstance.cameraSession!.isEnabled
         CallManager.sharedInstance.callscreen?.callerCollectionView.reloadData()
         if(CallManager.sharedInstance.cameraSession?.isEnabled == true){
         cameraOnOffBtn.setImage(UIImage(named: "callvideo-on.png"), for: .normal)
         }else{
         cameraOnOffBtn.setImage(UIImage(named: "callvideo-off.png"), for: .normal)
         }
         }*/
    }
    
    @IBAction func screenshareTapped(_ sender: UIButton) {
        //RoomClient.sharedInstance.startScreenRecording()
    }
    @IBAction func callMinimise(_ sender: UIButton) {
        RoomClient.sharedInstance.minimiserCall()
    }
    @IBAction func switchOrientationBtnTapped(_ sender: UIButton) {
        RoomClient.sharedInstance.switchCameraOrientation()
    }
    @IBAction func muteTapped(_ sender: UIButton) {
        RoomClient.sharedInstance.toggleMute()
    }
    @IBAction func speakerToggleTapped(_ sender: UIButton) {
        RoomClient.sharedInstance.toggleSpeaker()
    }
    @IBAction func acceptcalltapped(_ sender: Any) {
    }
    @IBAction func endcallTapped(_ sender: Any) {
        RoomClient.sharedInstance.endcallLogic(sendReject: true)

    }
    //MARK: - notifications methods
    
//    @objc func onDidReceiveData(_ notification:Notification) {
//        LogClass.debugLog(notification.userInfo as Any)
//        let array:[Contact] = notification.userInfo?["contacts"] as! [Contact]
//        for con in array{
//            var dic:[String:Any] = ["chatId":RoomClient.sharedInstance.chatId]
//            dic["userId"] = con.contactId
//            dic["roomId"] = RoomClient.sharedInstance.room_id
//            dic["type"] = "addincall"
//            LogClass.debugLog(dic)
//            SocketSharedManager.sharedSocket.sendaddtocall(dictionary: dic)
//        }
//    }
    
    //MARK: - view methods
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isBeingDismissed {
            LogClass.debugLog("calldebug callscreen dismissed")
        }
    }
    private func connectWebSocket() {
        SfuSocketIOManager.sharedInstance.closeConnection()
        SfuSocketIOManager.sharedInstance.sfudelegateCallmanager = self
        if SfuSocketIOManager.sharedInstance.manager?.status != .connected && SfuSocketIOManager.sharedInstance.manager?.status != .connecting{
            SfuSocketIOManager.sharedInstance.establishConnection()
        }
    }
    private func initializeMediasoup() {
        
        Mediasoupclient.initializePC()
        
        LogClass.debugLog("initializeMediasoup() client initialized")
        
        // Set mediasoup log
        Logger.setLogLevel(LogLevel.LOG_WARN)
        Logger.setDefaultHandler()
    }
    func startVideo() {
        
        DispatchQueue.main.async {
            do {
                let track = try RoomClient.sharedInstance.produceVideo()
                LogClass.debugLog("newcall track found \(String(describing: track))")
                track?.add(self.localRenderView!)
                if (RoomClient.sharedInstance.connections.count) > 0 {
                    self.localVideoView.isHidden = false
                }
                self.cameraOnOffBtn.isEnabled = true
                self.localVideoView.addDraggability(withinView: self.view)
                self.view.bringSubviewToFront(self.localVideoView)
            } catch {
                LogClass.debugLog("failed to start video!")
            }
        }
    }
    
    

    func requestRoomJoin() {
        
        let roomObject: [String:Any] = [
            "id": RoomClient.sharedInstance.room_id,
        ]
        let mainObject: [String:Any] = [
            "room_id": RoomClient.sharedInstance.room_id,
            "room_type":RoomClient.sharedInstance.room_type,
            "user_id":SharedManager.shared.userObj?.data.id ?? 0,
            "room":roomObject
        ]
        SfuSocketIOManager.sharedInstance.socket.emit(ActionEvent.ROOM_REQUEST_JOIN, mainObject)
        LogClass.debugLog("room:request-join sent")
        LogClass.debugLog(mainObject)
        LogClass.debugLog("-----------------------------------------------------")

    }
    
    func sendEndRoom() {
        
        let mainObject: [String:Any] = [
            "room_id": RoomClient.sharedInstance.room_id,
            "room_type":RoomClient.sharedInstance.room_type,
            "user_id":SharedManager.shared.userObj?.data.id ?? 0,
        ]
        SfuSocketIOManager.sharedInstance.socket.emit(ActionEvent.ROOM_ENDED, mainObject)
        LogClass.debugLog("room:ended sent")
        LogClass.debugLog(mainObject)
        LogClass.debugLog("-----------------------------------------------------")

    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        LogClass.debugLog("calldebug viewDidLoad")
        
        callEncryptionLbl.text = "callencryption".localized()
        self.callerCollectionView.delegate = self
        self.callerCollectionView.dataSource = self
        self.callerCollectionView.reloadData()
        

        self.view.bringSubviewToFront(bottomGreenView)
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(wasDragged(_:)))
        bottomGreenView.addGestureRecognizer(gesture)
        gesture.delegate = self

        bottomBarConstraint?.constant = ScreenSizeUtil.height() - 130
        bottomValue = bottomBarConstraint?.constant
        topValue = bottomValue - 300
        bottomBarBtn.setTitle("", for: .normal)
        self.localVideoView.frame = CGRect(x: 0, y: self.localVideoView.frame.origin.y, width: fullscreenView.frame.size.width/4, height: (fullscreenView.frame.size.width*(640/360)/4))
        LogClass.debugLog("calldebug bottomValue\(bottomValue)")
        LogClass.debugLog("calldebug topValue\(topValue)")
        setupUI()
        self.connectWebSocket()

    }
    
    @objc func wasDragged(_ sender: UIPanGestureRecognizer) {
        let velocity = sender.velocity(in: view)
        let translation = sender.translation(in: view)
        LogClass.debugLog("translation \(translation)")
        if sender.state == UIGestureRecognizer.State.began {
        } else if sender.state == UIGestureRecognizer.State.changed {
            bottomBarConstraint!.constant = bottomBarConstraint!.constant + translation.y
            sender.setTranslation(CGPoint.zero, in: self.view)
        } else if sender.state == UIGestureRecognizer.State.ended {
            if velocity.y > 0 {
                UIView.animate(withDuration:0.3,
                               delay: 0,
                               usingSpringWithDamping: 0.5,
                               initialSpringVelocity: 1,
                               options: .curveEaseInOut,
                               animations: {
                    self.bottomBarConstraint?.constant = self.bottomValue
                }, completion: {
                    (value: Bool) in
                    self.bottomBarBtn.setImage(UIImage(named: "upcall"), for: .normal)
                })
            } else {
                UIView.animate(withDuration:0.3,
                               delay: 1.0,
                               usingSpringWithDamping: 0.5,
                               initialSpringVelocity: 0.5,
                               options: .curveEaseInOut,
                               animations: {
                    self.bottomBarConstraint?.constant = self.topValue
                }, completion: {
                    (value: Bool) in
                    self.bottomBarBtn.setImage(UIImage(named: "downcall"), for: .normal)
                })
            }
        }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
    
    //MARK: - Collectionview
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        LogClass.debugLog("collectionViewLayout")
        if(RoomClient.sharedInstance.connections.count == 1){
            return CGSize(width: collectionView.frame.size.width-margin, height: collectionView.frame.size.height-margin)
        }else if(RoomClient.sharedInstance.connections.count == 2){
            return CGSize(width: collectionView.frame.size.width-margin, height: collectionView.frame.size.height/2-margin)
            
        }else if(RoomClient.sharedInstance.connections.count == 3){
            if(indexPath.row == 0 || indexPath.row == 1){
                return CGSize(width: collectionView.frame.size.width/2-margin, height: collectionView.frame.size.height/2-margin)
                
            }else{
                return CGSize(width: collectionView.frame.size.width-margin, height: collectionView.frame.size.height/2-margin)
            }
        }
        else if((RoomClient.sharedInstance.connections.count) >= 3){
            return CGSize(width: collectionView.frame.size.width/2-margin, height: collectionView.frame.size.height/2-margin)
        }
        return CGSize(width: 0, height: 0)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        LogClass.debugLog("------------reload--------------")
        LogClass.debugLog("connections = \(RoomClient.sharedInstance.connections.count)")
        return RoomClient.sharedInstance.connections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "callercell", for: indexPath) as! CallerCell
        let user:Connection = RoomClient.sharedInstance.connections[indexPath.row]
        
        cell.callername.text = user.firstname
        if(user.isReconnecting == true){
            cell.callername.text = user.firstname! + " (Reconnecting)"
        }
        if(user.photoUrl != nil && user.photoUrl != ""){
            LogClass.debugLog("photu \(user.photoUrl)")
            cell.callerimage.setImage(url: user.photoUrl ?? "",style: .squared)
        }
        cell.callStatus.text = ""
        let videoConsumer = user.videooconsumer
        if videoConsumer == nil {
            cell.callerimage.isHidden = false
            cell.contentView.bringSubviewToFront(cell.callerimage)
            cell.contentView.bringSubviewToFront(cell.callername)
            cell.contentView.bringSubviewToFront(cell.callStatus)

        }else
        {
            if videoConsumer?.getKind() == "video" {
                LogClass.debugLog("video track found")
                cell.remoteRenderView = nil
                cell.remoteRenderView = RTCEAGLVideoView()
//                cell.remoteRenderView?.frame = CGRect(x: 0, y: 0, width: cell.frame.size.width, height: cell.frame.size.width*(320/240))
                cell.remoteRenderView?.frame = CGRect(x: 0, y: 0, width: cell.frame.size.width, height: cell.frame.size.width*(640/360))
                cell.remoteRenderView?.backgroundColor = .clear

                let videoTrack = videoConsumer?.getTrack() as! RTCVideoTrack
                videoTrack.isEnabled = true
                videoTrack.add(cell.remoteRenderView!)
                cell.callerVideo?.frame = CGRect(x: 0, y: 0, width: cell.frame.size.width, height: cell.frame.size.height)
                //cell.remoteRenderView?.center.x = cell.callerVideo.center.x
                //cell.remoteRenderView?.center.y = cell.callerVideo.center.y
                cell.callerVideo.addSubview(cell.remoteRenderView!)
                cell.callerVideo.backgroundColor = .clear
                cell.callerVideo.isHidden = false
                cell.contentView.bringSubviewToFront(cell.callerVideo)
                cell.contentView.bringSubviewToFront(cell.callername)
                cell.contentView.bringSubviewToFront(cell.callStatus)

                cell.callerimage.isHidden = true

            }

        }

        
        LogClass.debugLog("cell frame = \(cell.frame)")
        LogClass.debugLog("remoteRenderViewframe = \(cell.remoteRenderView?.frame as Any)")
        LogClass.debugLog("callerVideoframe = \(cell.callerVideo.frame)")
        LogClass.debugLog("remoteRenderView = \(cell.remoteRenderView)")
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let member = RoomClient.sharedInstance.connections[indexPath.row]
        let url =  URL(string: (member.photoUrl)!)
        if(url != nil){
            if let cell:CallerCell = self.callerCollectionView.cellForItem(at: indexPath) as? CallerCell{
                //cell.callerimage.setupImageViewer(url: url!)
            }
        }
    }
    
    @IBAction func localVideoViewTapped(_ sender: Any) {
        if isLocalViewFullscreen {
            return
        }
        localVideoFrame = self.localVideoView.frame
        self.localVideoView.frame = CGRect(x: 0, y: 0, width: fullscreenView.frame.size.width, height: fullscreenView.frame.size.width*(640/360))
        
        let button = UIButton(frame: CGRect(x: 25, y: 50, width: 70, height: 35))
        button.setTitle("Close", for: .normal)
        button.backgroundColor = .white
        button.setTitleColor(UIColor.black, for: .normal)
        button.addTarget(self, action: #selector(self.buttonTapped), for: .touchUpInside)
        self.localVideoView.addSubview(button)
        self.localVideoView.removeDraggability()
        isLocalViewFullscreen = true

    }
    
    
    
    @objc func buttonTapped(sender : UIButton) {
        sender.removeFromSuperview()
        self.localVideoView.frame = self.localVideoFrame!
        self.localVideoView.addDraggability(withinView: self.view)
        isLocalViewFullscreen = false

    }
    //MARK: - video view delegates
    
    func videoView(_ videoView: RTCVideoRenderer, didChangeVideoSize size: CGSize) {
               
        
        
    }
    //MARK: - callscreendelegate
    
    func peerConnectionRTCPeerConnectionStateCallscreen(peerConnection: RTCPeerConnection, didChange newState: RTCPeerConnectionState){
        
  
        
    }
    
    func didIceConnectionRTCIceConnectionStateCallscreen(iceConnectionState: RTCIceConnectionState, peerCon: RTCPeerConnection) {
        


        
    }
    @objc func fireTimer(timer: Timer) {
        
        LogClass.debugLog("Timer fired!\(timer.timeInterval)")
        if timer.timeInterval == 3 {
            timer.invalidate()
        }
    }

    
    func peerConnectionRTCSignalingStateChangedCallscreen(peerConnection: RTCPeerConnection, didChange stateChanged: RTCSignalingState) {
        
    }
    func didStreamRemoved(peerConnection: RTCPeerConnection, stream: RTCMediaStream) {
      
        
    }

    
    func setupCallAgain(){
        
        if(RoomClient.sharedInstance.isVideoCall){
            self.calltypelabel.text = "KalamTime video call".localized()
            screenshareBtn.isHidden = true
            cameraOnOffBtn.isHidden = false
            

        }else{
            self.calltypelabel.text = "KalamTime audio call".localized()
            screenshareBtn.isHidden = true
            cameraOnOffBtn.isHidden = false
            
        }
        self.callername.text = RoomClient.sharedInstance.connectedUserName
        
        acceptcallbtn.isHidden = true
        firstView.isHidden = true
        endcallbtn.isHidden = false
        speakerBtn.isHidden = false
        minimiseBtn.isHidden = false
        mutecallbtn.isHidden = false
        addtocallBtn.isHidden = false
        optionsbtnView.isHidden = false
        //callActionsStackView.isHidden = false
        
        if(MediaCapturer.shared.videoCapturer?.captureSession.isRunning == true){
            self.cameraOnOffBtn.setImage(UIImage(named: "callvideo-on.png"), for: .normal)
            if let vTrack = MediaCapturer.shared.mediaStream.videoTracks.first{
                vTrack.add(self.localRenderView)
            }
            cameraSwitchBtn.isHidden = false
            self.localVideoView.isHidden = false
            self.localVideoView.addDraggability(withinView: self.view)
            self.view.bringSubviewToFront(self.localVideoView)

        }else{
            cameraSwitchBtn.isHidden = true
            self.cameraOnOffBtn.setImage(UIImage(named: "callvideo-off.png"), for: .normal)
        }

        if(RoomClient.sharedInstance.isAudioEnabled == false){
            mutecallbtn.setImage(UIImage(named: "callmute"), for: .normal)
        }else{
            mutecallbtn.setImage(UIImage(named: "callunmute"), for: .normal)
        }
        
        if (RoomClient.sharedInstance.isSpeakerEnabled){
            speakerBtn.setImage(UIImage(named: "callspeaker-on"), for: .normal)
        } else {
            speakerBtn.setImage(UIImage(named: "callspeaker-off"), for: .normal)
        }
    }
    
    func setupUI(){
        LogClass.debugLog("room: calldebug setupUI ")

        
        if(RoomClient.sharedInstance.callTimer.isValid){
            return
        }
        
        UIApplication.shared.isIdleTimerDisabled = true
        self.callername.text = RoomClient.sharedInstance.connectedUserName
        self.optionsbtnView.isHidden = false
        self.mutecallbtn.isHidden   = false
        self.speakerBtn.isHidden    = false
        self.cameraSwitchBtn.isHidden      = true
        self.minimiseBtn.isHidden = true
        self.screenshareBtn.isHidden = true
        self.cameraOnOffBtn.isHidden = true
        self.addtocallBtn.isHidden = true
        
        self.firstView.isHidden = false
        self.firstImageView.isHidden = false
        self.firstImageView.isHidden = false
        self.firstImageView.setImage(url: RoomClient.sharedInstance.connectedUserPhoto)
        self.view.bringSubviewToFront(self.firstAnimationImage)
        self.view.bringSubviewToFront(self.firstImageView)
        self.view.bringSubviewToFront(self.firstView)
        //self.view.bringSubviewToFront(self.callActionsStackView)
        self.view.bringSubviewToFront(self.optionsbtnView)

        self.view.bringSubviewToFront(self.mutecallbtn)
        self.view.bringSubviewToFront(self.speakerBtn)

        let simpleAnimation = false
        let lottieAnimation = true
        if(simpleAnimation ==  true){
            let image1 = UIImage(named: "wet_rond4.png")
            let image2 = UIImage(named: "wet_rond3.png")
            let image3 = UIImage(named: "wet_rond2.png")
            let image4 = UIImage(named: "wet_rond1.png")
            let array = [image1!,image2!,image3!,image4!]
            self.firstAnimationImage.backgroundColor = .clear
            self.firstAnimationImage.animationImages = array
            self.firstAnimationImage.animationDuration = 1.0
            self.firstAnimationImage.animationRepeatCount = 0
            self.firstAnimationImage.startAnimating()

        }

        if(lottieAnimation == true){
            
            let animationView = AnimationView()
            let animation = Animation.named("20026-calling")
            animationView.animation = animation
            animationView.frame = CGRect(x: 0, y: 0, width: 350, height: 350)
            animationView.contentMode = .scaleAspectFill
            animationView.loopMode = .loop
            animationView.animationSpeed = 1.0

            self.firstAnimationImage.addSubview(animationView)
            animationView.play()

        }
        
        if RoomClient.sharedInstance.isIncomingCall {
            LogClass.debugLog("setupUI isIncomingCall")
            //incoming
            /*if !SharedManager.shared.isCallKitSupported() {
                self.acceptcallbtn.isHidden = false
                self.view.bringSubviewToFront(self.acceptcallbtn)
            }*/
            self.acceptcallbtn.isHidden = true
            self.endcallbtn.isHidden = false
            self.view.bringSubviewToFront(self.endcallbtn)

        }else{
            LogClass.debugLog("setupUI outgoingcall")

            self.acceptcallbtn.isHidden = true
            self.endcallbtn.isHidden = false
            self.view.bringSubviewToFront(self.endcallbtn)
            self.calltimerlabel.text = "Calling..."

        }
        
        if(RoomClient.sharedInstance.isVideoCall == true){
            if RoomClient.sharedInstance.isIncomingCall == true {
                //self.cameraOnOffBtn.sendActions(for: .touchUpInside)
                SharedManager.shared.showAlert(message: "Please turn on your camera to start your video", view: self)
            }
            self.calltypelabel.text = "KalamTime video call".localized()
        }else{
            self.calltypelabel.text = "KalamTime audio call".localized()
        }
    }
    
}


extension CallViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        LogClass.debugLog("calldebug \(RoomClient.sharedInstance.connections.count)")
        return RoomClient.sharedInstance.connections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "callmemberscell", for: indexPath) as! CallMembersCell
        let connection:Connection = RoomClient.sharedInstance.connections[indexPath.row]
        if let imgUrl = connection.photoUrl {
            LogClass.debugLog("photourl \(imgUrl)")
            cell.callerimage.setImage(url: imgUrl,style: .rounded)
        }
        if let name:String = connection.firstname {
            
            if RoomClient.sharedInstance.blockedUserArray.count == 0 {
                cell.callername.text = name
            }else{
                var exist = false
                for user in RoomClient.sharedInstance.blockedUserArray {
                    if(user.blockId == connection.connecteduserid){
                        exist = true
                    }
                }
                if(exist == true){
                    cell.callername.text = name + " (blocked)"
                }else
                {
                    cell.callername.text = name
                }
            }
            
        }
        
        if let state = connection.audiotransport?.getConnectionState(){
            if state == "completed" || state == "connected"{
                cell.callerStatusBtn.setTitle("Connected", for: .normal)
            }
            else{
                cell.callerStatusBtn.setTitle("", for: .normal)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}


extension CallViewController:SfuSocketDelegateCallmanager{
    func didSocketConnected(data: [Any]) {
        
        LogClass.debugLog("sfu socket connected")
        LogClass.debugLog(data)
        LogClass.debugLog("-------------------------------------")
        
        if RoomClient.sharedInstance.sendTransport == nil {
            self.requestRoomJoin()
        }else
        {
            RoomClient.sharedInstance.sendRoomReconnected()
            RoomClient.sharedInstance.getPostJoinData()
        }

    }

    
    func didReceiveCanMakeConnection(data: [String : Any]) {
        self.initializeMediasoup()
        if let router = data["router"] as? [String:Any]{
            if let rtpCapabilities = router["rtp_capabilities"] as? [String:Any] {
                
                var error : NSError?
                let jsonData = try! JSONSerialization.data(withJSONObject: rtpCapabilities, options: .prettyPrinted)
                let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
                
                let device: Device = Device.init()
                device.load(jsonString)
               

                RoomClient.sharedInstance.device = device
                
                do {
                    try RoomClient.sharedInstance.join()
                } catch {
                   
                    return
                }
                
                if RoomClient.sharedInstance.isIncomingCall == false {
                    //call made
                    if RoomClient.sharedInstance.isVideoCall == true {
                        RoomClient.sharedInstance.createSendTransport(kind: "both")
                    }else{
                        RoomClient.sharedInstance.createSendTransport(kind: "audio")
                    }
                }else{
                    //incoming call
                    RoomClient.sharedInstance.createSendTransport(kind: "audio")
                }
            }
        }
    }
    func didReceiveUserleft(data:[String:Any]){
        let userId = SharedManager.shared.ReturnValueAsInt(value: data["user_id"]!)
        //let roomId = data["room_id"] as! String
        //let roomType = data["room_type"] as! String
        
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
            }
            LogClass.debugLog(RoomClient.sharedInstance.connections.count)
            self.callerCollectionView.reloadData()
            self.callMembersTable.reloadData()
            
            if RoomClient.sharedInstance.isSpeakerEnabled == true {
                RoomClient.sharedInstance.switchToSpeakerAudio()
            }else{
                RoomClient.sharedInstance.switchToEarPieceAudio()
            }

            if RoomClient.sharedInstance.connections.count == 0 {
                RoomClient.sharedInstance.dismissScreenAndTransports()
            }
        }
        

        
        

    }
    func didReceiveNewProducer(data: [String:Any]){
        var producer = data["producer"] as? [String:Any]
        self.consumeProducer(producer: producer!)
        if (RoomClient.sharedInstance.isIncomingCall == true || RoomClient.sharedInstance.connections.count > 0) {
            RoomClient.sharedInstance.connectedStateChanges()
        }

    }
    
    func consumeProducer(producer:[String:Any]){
        if producer["user_id"] as! Int == SharedManager.shared.userObj?.data.id {
            return
        }
        let pName = producer["name"] as? String
        let parts = pName?.components(separatedBy: "_")
        let type = parts?[1]
        let kind = parts?[2]
        let peerId = SharedManager.shared.ReturnValueAsInt(value: parts?.first)
        RoomClient.sharedInstance.onNewConsumer(peerId: peerId, type: "_\(type!)_\(kind!)_", producer: producer,kind: kind!)

    }
    
    func didReceiveRoomJoined(data: [String : Any]) {
        
        var available_producers = data["available_producers"] as? [String:Any]
        var participants_ids = data["participants_ids"] as? [Int]
        let participants = data["participants"] as? [String:Any]

            
        for id in participants_ids! {
            
            let peer = participants?[id.description] as! [String:Any]
            let peerId = SharedManager.shared.ReturnValueAsInt(value: peer["id"])
            
            if SharedManager.shared.userObj?.data.id != peerId{
                let user = peer["user"] as! [String:Any]
                if RoomClient.sharedInstance.connections.contains(where: { $0.connecteduserid == peerId}) {
                    LogClass.debugLog("room:already exist")
                } else {
                    var connection = Connection(connecteduserid: SharedManager.shared.ReturnValueAsInt(value: user["id"]!), firstname: user["name"] as? String)
                    connection.photoUrl = user["profile_pic"] as? String
                    RoomClient.sharedInstance.connections.append(connection)
                    LogClass.debugLog("room:appended")

                }
            }
        }
        LogClass.debugLog("room: connections\(RoomClient.sharedInstance.connections.count)")

        if (RoomClient.sharedInstance.isIncomingCall == true || RoomClient.sharedInstance.connections.count > 0) {
            DispatchQueue.main.async {
                RoomClient.sharedInstance.connectedStateChanges()
            }
        }

        let user = data["user"] as? [String:Any]
        if SharedManager.shared.userObj?.data.id == user?["id"] as? Int{
            available_producers?.forEach { t in
                self.consumeProducer(producer: t.value as! [String : Any])
            }
        }
        
    }
    func didReceiveVideoSwitched(data:[String:Any]){
        
        let userId = SharedManager.shared.ReturnValueAsInt(value: data["user_id"]!)
        LogClass.debugLog(RoomClient.sharedInstance.connections.count)
        for i in RoomClient.sharedInstance.connections.indices {
            if var user = RoomClient.sharedInstance.connections[i] as? Connection{
                if Int(user.connecteduserid) == userId {
                    RoomClient.sharedInstance.connections[i].videotransport?.close()
                    RoomClient.sharedInstance.connections[i].videotransport = nil
                    RoomClient.sharedInstance.connections[i].videooconsumer?.close()
                    RoomClient.sharedInstance.connections[i].videooconsumer = nil
                }
            }
        }
        LogClass.debugLog(RoomClient.sharedInstance.connections.count)
        self.callerCollectionView.reloadData()
        self.callMembersTable.reloadData()

        
        
    }
    
    func didReceiveUserReconnecting(data: [String : Any]) {
        LogClass.debugLog("reconnecting \(data)")
        let roomid = data["room_id"] as? String
        if(roomid == RoomClient.sharedInstance.room_id){
            let userid = SharedManager.shared.ReturnValueAsInt(value: data["user_id"])
            LogClass.debugLog("reconnecting userid\(userid)")
            LogClass.debugLog("reconnecting connections\(RoomClient.sharedInstance.connections)")

            if RoomClient.sharedInstance.connections.count > 0 {
                if let row = RoomClient.sharedInstance.connections.firstIndex(where: {$0.connecteduserid == userid}) {
                    RoomClient.sharedInstance.connections[row].isReconnecting = true
                    let indexpath = IndexPath(row: row, section: 0)
                    self.callerCollectionView.reloadItems(at: [indexpath])
                }
            }
        }
    }
    func didReceiveUserReconnected(data: [String : Any]) {
        LogClass.debugLog("reconnecting \(data)")
        let roomid = data["room_id"] as? String
        if(roomid == RoomClient.sharedInstance.room_id){
            let userid = SharedManager.shared.ReturnValueAsInt(value: data["user_id"])
            LogClass.debugLog("reconnecting userid\(userid)")
            LogClass.debugLog("reconnecting connections\(RoomClient.sharedInstance.connections)")

            
            if(RoomClient.sharedInstance.connections.count > 0){
                if(!(RoomClient.sharedInstance.screen?.callerCollectionView.isHidden)!){
                    if let row = RoomClient.sharedInstance.connections.firstIndex(where: {$0.connecteduserid == userid}) {
                        if(RoomClient.sharedInstance.connections[row].isReconnecting == true){
                            RoomClient.sharedInstance.connections[row].isReconnecting = false
                            let indexpath = IndexPath(row: row, section: 0)
                            self.callerCollectionView.reloadItems(at: [indexpath])
                        }
                    }
                }
            }
        }
    }
}

extension CallViewController:ChatFriendDelegate {
    func friendCancelDelegate(){
        navconContacts.willMove(toParent: nil)
        navconContacts.removeFromParent()
        navconContacts.view.removeFromSuperview()
    }
    
    func friendSelectedDelegate(friendArray: [FriendChatModel]) {
    
        navconContacts.willMove(toParent: nil)
        navconContacts.removeFromParent()
        navconContacts.view.removeFromSuperview()
        
        for con in friendArray{
            
            var dic:[String:Any] = ["chatId":RoomClient.sharedInstance.chatId]
            dic["userId"] = con.id
            dic["roomId"] = RoomClient.sharedInstance.room_id
            dic["type"] = "addincall"
            LogClass.debugLog(dic)
            SocketSharedManager.sharedSocket.sendaddtocall(dictionary: dic)
            
        }
    }
}
