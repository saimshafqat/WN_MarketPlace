//
//  SharedClass.swift
//  WorldNoor
//
//  Created by Waseem Shah on 08/12/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

//import Foundation
//import SwiftKeychainWrapper
//
//open class SharedClass: NSObject {
//    
//    static let shared = SharedClass()
//    
//    private override init() {
//        super.init()
//    }
//    
////    func openXApp(senderType : AppType){
////        if senderType == .Kalamtime {
////            LogClass.debugLog("Kalam Time ===>")
////          //  self.openXapp(urlString: "KalamTimeApp://")
////            self.openXapp(urlString: "KTMessenger://")
////        }else if senderType == .Werfie {
////            LogClass.debugLog("Werfie ===>")
////            self.openXapp(urlString: "WerfieApp://")
////        }else if senderType == .Mizdah {
////            LogClass.debugLog("Mizdah ==>")
////            self.openXapp(urlString: "MizdahApp://")
////        }else if senderType == .Seezitt {
////            LogClass.debugLog("Seezitt ===>")
////            self.openXapp(urlString: "SeezittApp://")
////        }
////    }
//
// 
//    func logoutFromKeychain(){
//        let keychain = KeychainWrapper(serviceName: "PoshData",accessGroup: "DJ3DSQD2BW.com.ogoul.PoshGroup")
//        keychain.removeAllKeys()
//    }
//    
//    private func openXapp(urlString : String){
//        self.saveXDataApp()
//        self.openApp(urlString: urlString)
//    }
//    
////    func clearAllFiles() {
////        let fileManager = FileManager.default
////        clearAllTempFiles()
////        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
////            
////        print("Directory: \(paths)")
////            
////        do {
////            let fileName = try fileManager.contentsOfDirectory(atPath: paths)
////                
////            for file in fileName {
////                // For each file in the directory, create full path and delete the file
////                
////                LogClass.debugLog("file ===>")
////                LogClass.debugLog(file)
////                
////                if !file.contains("myImageToUpload") {
////                    LogClass.debugLog("If ===>")
////                    let filePath = URL(fileURLWithPath: paths).appendingPathComponent(file).absoluteURL
////                    try fileManager.removeItem(at: filePath)
////                }else {
////                    LogClass.debugLog("Else ===>")
////                }
////               
////            }
////        } catch let error {
////            print(error)
////        }
////    }
//    
//    func clearAllTempFiles() {
////        let fileManager = FileManager.default.temporaryDirectory
////            
//////        let paths = NSSearchPathForDirectoriesInDomains(NSTemporaryDirectory(), .userDomainMask, true).first!
//////            
////        print("Directory: clearAllTempFiles \(fileManager)")
//////
////        do {
////            let fileName = try fileManager.contentsOfDirectory(atPath: fileManager)
////                
////            for file in fileName {
////                // For each file in the directory, create full path and delete the file
////                
////                LogClass.debugLog("file ===>")
////                LogClass.debugLog(file)
////                
//////                if !file.contains("myImageToUpload") {
//////                    LogClass.debugLog("If ===>")
//////                    let filePath = URL(fileURLWithPath: paths).appendingPathComponent(file).absoluteURL
//////                    try fileManager.removeItem(at: filePath)
//////                }else {
//////                    LogClass.debugLog("Else ===>")
//////                }
////               
////            }
////        } catch let error {
////            print(error)
////        }
//    }
//    
////    func saveXDataApp(){
////        //        LogClass.debugLog("saveXDataApp() ==>")
////        //        LogClass.debugLog(SharedManager.shared.userObj?.data.posh_id)
////        //        LogClass.debugLog(SharedManager.shared.userObj?.data.email)
////        //        LogClass.debugLog(SharedManager.shared.userObj?.data.profile_image)
////        LogClass.debugLog(SharedManager.shared.userObj?.data.phone)
////        let keychain = KeychainWrapper(serviceName: "PoshData",accessGroup: "DJ3DSQD2BW.com.ogoul.PoshGroup")
////        keychain.set(SharedManager.shared.userObj?.data.posh_id ?? "", forKey: "posh_id")
////        keychain.set(SharedManager.shared.userObj?.data.email ?? "", forKey: "posh_email")
////        keychain.set(SharedManager.shared.userObj?.data.profile_image ?? "", forKey: "posh_image")
////        keychain.set(SharedManager.shared.userObj?.data.fullname ?? "", forKey: "posh_name")
////        keychain.set(SharedManager.shared.userObj?.data.phone ?? "", forKey: "posh_Phone")
////    }
//    
//    private func openApp(urlString : String) {
//        
//        let openUrl = URL(string: urlString)!
//        UIApplication.shared.open(openUrl , options:[:]) { (success) in
//            if !success {
//                if urlString.contains("MizdahApp") {
//                    if let url = URL(string: "https://apps.apple.com/pk/app/mizdah-video-communications/id6445909307") {
//                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
//                    }
//                }
//                // else if urlString.contains("KalamTimeApp") {
//                //     if let url = URL(string: "https://apps.apple.com/pk/app/kalamtime-messaging-calls/id1517801485") {
//                //         // https://apps.apple.com/sa/app/kt-messenger/id6478195913
//                //         UIApplication.shared.open(url, options: [:], completionHandler: nil)
//                // }
//                else if urlString.contains("KTMessenger") {
//                    if let url = URL(string: "https://apps.apple.com/sa/app/kt-messenger/id6478195913") {
//                        // https://apps.apple.com/sa/app/kt-messenger/id6478195913
//                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
//                    }
//                }else if urlString.contains("SeezittApp") {
//                    if let url = URL(string: "https://apps.apple.com/pk/app/seezitt/id6444735823") {
//                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
//                    }
//                    
//                }else if urlString.contains("WerfieApp") {
//                    if let url = URL(string: "https://apps.apple.com/pk/app/werfie-create-a-werf/id1599453650") {
//                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
//                    }
//                }
//            }
//        }
//    }
//}
//
//
//enum AppType {
//    case Werfie
//    case Mizdah
//    case Kalamtime
//    case Seezitt
//    
//}
