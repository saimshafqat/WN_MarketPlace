//
//  PermissionManager.swift
//  WorldNoor
//
//  Created by moeez akram on 29/11/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import AVFoundation
import Foundation
import UIKit

import AVFoundation
import UIKit

class PermissionManager {
    
    enum PermissionType {
        case camera
        case microphone
    }
    
    enum PermissionStatus {
        case notDetermined
        case denied
        case restricted
        case authorized
    }
    
    typealias PermissionsCallback = (PermissionStatus, PermissionStatus?) -> Void
    
    // MARK: - Public Methods
    
    static func requestAudioCallPermissions(callback: @escaping PermissionsCallback) {
        requestPermissions(for: [.microphone], callback: callback)
    }
    
    static func requestVideoCallPermissions(callback: @escaping PermissionsCallback) {
        requestPermissions(for: [.camera, .microphone], callback: callback)
    }
    
    // MARK: - Private Methods
    
    private static func requestPermissions(for types: [PermissionType], callback: @escaping PermissionsCallback) {
        let dispatchGroup = DispatchGroup()
        var cameraStatus: PermissionStatus?
        var microphoneStatus: PermissionStatus?
        
        for type in types {
            dispatchGroup.enter()
            
            switch type {
            case .camera:
                requestPermissionStatus(for: AVMediaType.video) { (status) in
                    cameraStatus = status
                    dispatchGroup.leave()
                }
            case .microphone:
                requestPermissionStatus(for: AVMediaType.audio) { (status) in
                    microphoneStatus = status
                    dispatchGroup.leave()
                }
            }
        }
        
        dispatchGroup.notify(queue: DispatchQueue.main) {
            callback(microphoneStatus ?? .notDetermined, cameraStatus)
        }
    }
    
    private static func requestPermissionStatus(for mediaType: AVMediaType, callback: @escaping (PermissionStatus) -> Void) {
        AVCaptureDevice.requestAccess(for: mediaType) { (granted) in
            DispatchQueue.main.async {
                let status: PermissionStatus
                switch AVCaptureDevice.authorizationStatus(for: mediaType) {
                case .authorized:
                    status = .authorized
                case .denied:
                    status = .denied
                case .restricted:
                    status = .restricted
                case .notDetermined:
                    status = .notDetermined
                @unknown default:
                    fatalError("Unhandled AVAuthorizationStatus case")
                }
                callback(status)
                
                if status == .denied {
                    showSettingsAlert(for: mediaType)
                }
            }
        }
    }
    
    private static func showSettingsAlert(for mediaType: AVMediaType) {
        let alert = UIAlertController(
            title: "Permission Denied",
            message: "Please go to Settings and enable \(mediaType == .video ? "Camera" : "Microphone") access.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
            }
        })
        
        if let topController = UIApplication.shared.windows.first?.rootViewController {
            topController.present(alert, animated: true, completion: nil)
        }
    }
}
