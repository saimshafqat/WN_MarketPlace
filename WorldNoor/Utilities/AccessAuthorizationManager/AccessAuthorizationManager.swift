//
//  AccessAuthorizationManager.swift
//  WorldNoor
//
//  Created by Asher Azeem on 04/05/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class AccessAuthorizationManager {
    
    static let shared = AccessAuthorizationManager()
    
    private init() { }
    
    func requestAccessForVideo(completion: @escaping (Bool) -> Void) {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                completion(granted)
            }
        case .authorized:
            completion(true)
        case .denied, .restricted:
            completion(false)
        default:
            completion(false)
        }
    }
    
    func requestAccessForAudio(completion: @escaping (Bool) -> Void) {
        let status = AVCaptureDevice.authorizationStatus(for: .audio)
        switch status {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .audio) { granted in
                completion(granted)
            }
        case .authorized:
            completion(true)
        case .denied, .restricted:
            completion(false)
        default:
            completion(false)
        }
    }
    
    //    func requestAccessForPhotoLibrary() {
    //        if #available(iOS 14, *) {
    //            PHPhotoLibrary.requestAuthorization { status in
    //                switch status {
    //                case .authorized:
    //                    // as above
    //                    LogClass.debugLog("authorized")
    //                case .denied, .restricted:
    //                    // as above
    //                    LogClass.debugLog("restricted")
    //                case .notDetermined:
    //                    // won't happen but still
    //                    LogClass.debugLog("notDetermined")
    //                case .limited:
    //                    LogClass.debugLog("limited")
    //                default:
    //                    LogClass.debugLog("default")
    //                }
    //            }
    //        }
    //    }
    
    func requestAccessForPhotoLibrary(completion: ((PHAuthorizationStatus) -> Void)? = nil) {
        if #available(iOS 14, *) {
            PHPhotoLibrary.requestAuthorization { status in
                completion?(status)
            }
        }
    }
}

