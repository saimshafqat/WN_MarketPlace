//
//  AppDelegate.swift
//  WorldNoor
//
//  Created by Raza najam on 9/3/19.
//  Copyright © 2019 Raza najam. All rights reserved.
//  let feed = AppStoryboard.TabBar.instance.instantiateViewController(withIdentifier: "FeedNavigation")

// swiftlint:disable:this force_cast

import UIKit
import CommonKeyboard
import SDWebImage
import GooglePlaces
import FirebaseMessaging
import Firebase
import PushKit
import WebRTC
import CoreData
import GoogleSignIn
import GoogleMobileAds
import GoogleMaps

protocol PushkitDelegate: AnyObject {
    func didReceiveCall(_ callerId: String)
}

//@UIApplicationMain
@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var restrictRotation = true
    // weak var delegate: PushkitDelegate?
    
    var connectedUserID = ""
    var callId = ""
    var chatId = ""
    // var sessionId = ""
    // var socketId = ""
    var callername = ""
    var callerPhoto = ""
    var isVideo = false
    // var orientationLock = UIInterfaceOrientationMask.all
    var remoteNotificationAtLaunch: NSDictionary?
    let gcmMessageIDKey = "gcm.message_id"
    
    static func shared() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    private let voipRegistry = PKPushRegistry(queue: nil)
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // AppAppearance.setupAppearance()
        Commons.share.customizeAppTheme()
        
        
        if let activityDictionary = launchOptions?[UIApplication.LaunchOptionsKey.userActivityDictionary] as? [AnyHashable: Any] { //Universal link
            for key in activityDictionary.keys {
                if let userActivity = activityDictionary[key] as? NSUserActivity {
                    if let url = userActivity.webpageURL {
                        // your code
                        UserDefaults.standard.set(url.absoluteString, forKey: "url")
                        UserDefaults.standard.synchronize()
                    }
                }
            }
        }
        
        CommonKeyboard.shared.enabled = true
        
        self.remoteNotificationAtLaunch = launchOptions?[.remoteNotification] as?  NSDictionary
        
        GoogleSignInManager.restorePreviousSignIn()
        //        CoreDbManager.shared.persistentContainer.viewContext
        let locale = NSLocale.current.languageCode
        
        var language = "English"
        if locale == "ar" {
            language = "العربية"
        }else if locale == "id" {
            language = "bahasa Indonesia"
        }else if locale == "it" {
            language = "Italiana"
        }else if locale == "ru" {
            language = "русский"
        }else if locale == "so" {
            language = "Soomaali"
        }else if locale == "tr" {
            language = "Türk"
        }else if locale == "fa" {
            language = "فارسی"
        }else if locale == "es" {
            language = "Española"
        }else if locale == "ja" {
            language = "日本人"
        }else if locale == "fr" {
            language = "Française"
        }else if locale == "bn" {
            language = "বাংলা"
        }else if locale == "az" {
            language = "Azərbaycan"
        }else if locale == "de-DE" {
            language = "Deutsche"
        }else if locale == "ur" {
            language = "اردو"
        }else if locale == "pa" {
            language = "ਪੰਜਾਬੀ"
        }else if locale == "te" {
            language = "తెలుగు"
        }else if locale == "ta" {
            language = "தமிழ்"
        }else if locale == "sd" {
            language = "سنڌي"
        }else if locale == "pt" {
            language = "Português"
        }else if locale == "fil" {
            language = "Pilipino"
        }else if locale == "da" {
            language = "dansk"
        }else if locale == "hy" {
            language = "հայերեն"
        }else if locale == "hi" {
            language = "हिंदी"
        }
        
        if UserDefaults.standard.value(forKey: "Lang") == nil {
            UserDefaults.standard.setValue(language, forKey: "Lang")
            UserDefaults.standard.synchronize()
        }
        if #available(iOS 13.0, *) {
            window!.overrideUserInterfaceStyle = .light
        } else {
            // Fallback on earlier versions
        }
        UserDefaults.standard.removeObject(forKey: "VideoUpload")
        FirebaseApp.configure()
        self.manageFirebase(application: application)
        configurePushKit()
        
        
        
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        
        
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        if let isUserObj:User = SharedManager.shared.getProfile() {
            SharedManager.shared.userObj = isUserObj
        }
        
        GMSServices.provideAPIKey("AIzaSyBVqyJTLcFZoB46FyL1ulc5_Jhp279XDXA")
        UserDefaults.standard.set(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")

        UIStackView.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).spacing = -5
        return true
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        if(SocketSharedManager.sharedSocket.manager?.status == .connected){
            var dic = [String:String]()
            dic["type"] = "didEnterBackground"
            dic["userId"] = SharedManager.shared.userObj?.data.id?.description
            SocketSharedManager.sharedSocket.senddidenterBackground(dictionary: dic)
        }
    }
    
    func didenterForegroundSocket(){
        if(SocketSharedManager.sharedSocket.manager?.status == .connected){
            var dic = [String:String]()
            dic["type"] = "didEnterForeground"
            dic["userId"] = SharedManager.shared.userObj?.data.id?.description
            SocketSharedManager.sharedSocket.senddidenterForeground(dictionary: dic)
            
        }
        
    }
    func applicationWillEnterForeground(_ application: UIApplication) {
        didenterForegroundSocket()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        SocketSharedManager.sharedSocket.closeConnection()
        MPSocketSharedManager.sharedSocket.closeConnection()
    }
    
    func sendnewcallreceived() {
        if (self.connectedUserID == "" || self.chatId == ""){
            return
        }

        var dic = [String:String]()
        dic["type"] = "newcallreceived"
        dic["connectedUserId"] = self.connectedUserID
        dic["callId"] = self.callId
        dic["chatId"] = self.chatId
        //        dic["isBusy"] = "\(CallManager.sharedInstance.isCallStarted)"
        LogClass.debugLog("pending sendnewcallreceived\(RoomClient.sharedInstance.callsReference.count)")
        LogClass.debugLog("pending sendnewcallreceived\(RoomClient.sharedInstance.isCallConnected)")
        LogClass.debugLog("pending sendnewcallreceived\(RoomClient.sharedInstance.isCallInitiated)")
        LogClass.debugLog("pending sendnewcallreceived\(RoomClient.sharedInstance.isIncomingCall)")
        LogClass.debugLog("pending sendnewcallreceived\(RoomClient.sharedInstance.isCallkitShown)")
        dic["isBusy"] = "\(false)"
        if(RoomClient.sharedInstance.isCallInitiated == true || RoomClient.sharedInstance.isCallkitShown == true){
            //dic["isBusy"] = "\(true)"
        }
        LogClass.debugLog("pending calldebug sent\(dic)")
        if(RoomClient.sharedInstance.isCallConnected == false){
            RoomClient.sharedInstance.isCallkitShown = true
        }
        // SocketIOManager.sharedInstance.getGroupCallMembers(dictionary: ["chatId":self.chatId])
        // CallManager.sharedInstance.showlocalView = isVideo
        // CallManager.sharedInstance.isVideoEnabled = isVideo
        // CallManager.sharedInstance.connectedUserName = callername
        // CallManager.sharedInstance.connectedUserPhoto = callerPhoto
        SocketSharedManager.sharedSocket.socket.emitWithAck(dic["type"]!, with: [SharedManager.shared.returnJsonObject(dictionary: dic)]).timingOut(after: 0) { (data) in
            let dic = data.first as! [String:Any]
            LogClass.debugLog("pending calldebug \(dic)")
            
            let isRejected = dic["isRejected"] as! Bool
            LogClass.debugLog("pending calldebug \(isRejected)")
            
            if(isRejected) {
                //CallManager.sharedInstance.closeCallScreen()
                return
            }
            
            self.connectedUserID = ""
            self.callId = ""
            self.chatId = ""
            self.callername = ""
            self.callerPhoto = ""
            self.isVideo = false
        }
        // if(CallManager.sharedInstance.isCallStarted == false){
        //     CallManager.sharedInstance.startWebrtc()
        // }
    }
    
    func loadTabBar() {
        self.window?.rootViewController?.dismiss(animated: true, completion: nil)
        let feedTabBar = AppStoryboard.TabBar.instance.instantiateViewController(withIdentifier: Const.feedTab)
         let marketPlace = MPDashboardViewController.instantiate(fromAppStoryboard: .Marketplace)
        self.window?.rootViewController = UINavigationController(rootViewController: marketPlace)
        // self.window?.makeKeyAndVisible()
    }
    
    func loadLoginScreen(){
        FeedCallBManager.shared.videoClipArray.removeAll()
        SharedManager.shared.saveProfile(userObj: nil)
        CoreDbManager.shared.deleteAllEntities()
        
        self.window?.rootViewController?.dismiss(animated: true, completion: nil)
        let loginNav = AppStoryboard.Main.instance.instantiateViewController(withIdentifier: Const.KloginNav)
        self.window?.rootViewController = loginNav
        self.window?.makeKeyAndVisible()
    }
    
    
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        
        completionHandler()
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if(self.restrictRotation) {
            return UIInterfaceOrientationMask.portrait
        }
        else{
            return UIInterfaceOrientationMask.all
        }
    }
    
    func manageFirebase(application:UIApplication){
        // 1- Push Notifications
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: { _, _ in }
            )
        } else {
            let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        // 2- Messaging Delegate
        Messaging.messaging().delegate = self
        
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
    }
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
}

extension AppDelegate: PKPushRegistryDelegate{
    
    public func configurePushKit() {
        voipRegistry.delegate = (self as PKPushRegistryDelegate)
        voipRegistry.desiredPushTypes = [.voIP]
    }
    //new token method
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        let parts = pushCredentials.token.map { String(format: "%02.2hhx", $0) }
        let token = parts.joined()
        SharedManager.shared.callKitToken = token
    }
    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        
    }
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        handleIncomingCall(calldic: payload.dictionaryPayload)
    }
    
    func handleIncomingCall(calldic: [AnyHashable:Any]){
        
        if let chatId = calldic["chatId"] as? String {
            if let connectedUserId = calldic["connectedUserId"] as? String {
                if let callerName = calldic["callerName"] as? String {
                    let callerPhoto = calldic["callerPhoto"] as? String
                    let roomId = calldic["roomId"] as? String
                    let callId = calldic["callId"] as? String
                    LogClass.debugLog("callid-debug \(callId)")
                    
                    let isVideo = SharedManager.shared.ReturnValueAsBool(value: calldic["isVideo"])
                    let sessionId = calldic["sessionId"] as? String
                    let socketId = calldic["socketId"] as? String
                    let isBusy = calldic["isBusy"] as? Bool
                    let callType = calldic["callType"] as? String
                    
                    let signalingMessage = Available.init(type: "newcall", connectedUserId: connectedUserId, isAvailable: false, reason: "", name: callerName ,callId: callId!,chatId: chatId, photoUrl: callerPhoto, isVideo: isVideo, isBusy: isBusy,sessionId: sessionId,socketId: socketId,callType: callType,roomId: roomId)
                    RoomClient.sharedInstance.newCallData = signalingMessage
                    //                        LogClass.debugLog("========CALL PUSH============")
                    //                        CallManager.sharedInstance.showlocalView = isVideo ?? false
                    //                        //ATCallManager.shared.provider?.invalidate()
                    //                                if SharedManager.shared.isCallKitSupported() {
                    ATCallManager.shared.incommingCall(from: callerName,hasVideo: isVideo ?? false , delay: 0, callobject: signalingMessage)
                    //                                }
                    
                    //                        CallManager.sharedInstance.isCallHandled = true
                    RoomClient.sharedInstance.isIncomingCall = true
                    //                        RTCAudioSession.sharedInstance().isAudioEnabled = false
                    //                        LogClass.debugLog("calldebug false call push")
                    
                    if RoomClient.sharedInstance.connections.count == 0 {
                        RoomClient.sharedInstance.startNoAnswerTimer()
                    }
                    self.connectedUserID = connectedUserId
                    self.chatId = chatId
                    self.callId = callId ?? ""
                    LogClass.debugLog("callid-debug local\(self.callId)")
                    
                    SocketSharedManager.sharedSocket.delegateAppdelegate = self
                    if SocketSharedManager.sharedSocket.manager != nil && SocketSharedManager.sharedSocket.manager?.status == .connected && SocketSharedManager.sharedSocket.manager?.status != .connecting {
                        sendnewcallreceived()
                        LogClass.debugLog("========SOCKET WAS CONNECTED============")
                    }
                    else{
                        if let isUserObj:User = SharedManager.shared.getProfile() {
                            SharedManager.shared.userObj = isUserObj
                            if SocketSharedManager.sharedSocket.manager == nil && SocketSharedManager.sharedSocket.manager?.status != .connected && SocketSharedManager.sharedSocket.manager?.status != .connecting{
                                SocketSharedManager.sharedSocket.establishConnection()
                                LogClass.debugLog("========SOCKET WAS NOT CONNECTED============")
                            }
                        }
                    }
                }
            }
        }
    }
}

extension AppDelegate:SocketDelegateAppdelegate{
    func didSocketConnectedAppdelegate(data: [Any]) {
        sendnewcallreceived()
    }
}

extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        completionHandler([[.alert, .sound]])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        
        self.remoteNotificationAtLaunch = userInfo as NSDictionary
        if let messageID = userInfo[gcmMessageIDKey] {
            LogClass.debugLog("MessageID ==> \(messageID)")
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "notification"), object: nil,userInfo: nil)
        completionHandler()
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if let messageID = userInfo[gcmMessageIDKey] {
        }
        LogClass.debugLog("\(#function) detailData <==> \(userInfo) at line => \(#line)")
        completionHandler(UIBackgroundFetchResult.newData)
    }
}


extension AppDelegate : MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        let dataDict: [String: String] = ["token": fcmToken ?? .emptyString]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        FireConfiguration.shared.fcmToken = fcmToken ?? .emptyString
        FireConfiguration.shared.callingFirebaseTokenService()
    }
    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        return GoogleSignInManager.handle(url: url)
    }
}

