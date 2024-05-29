//
//  MediaCapturer.swift
//  mediasoup-ios-cient-sample
//
//  Created by Ethan.
//  Copyright © 2019 Ethan. All rights reserved.
//

import Foundation
import WebRTC
import AVFoundation
import Accelerate


public enum MediaError : Error {
    case CAMERA_DEVICE_NOT_FOUND
}

final internal class MediaCapturer : NSObject {
    private static let MEDIA_STREAM_ID: String = "ARDAMS"
    private static let VIDEO_TRACK_ID: String = "ARDAMSv0"
    private static let AUDIO_TRACK_ID: String = "ARDAMSa0"

    let peerConnectionFactory: RTCPeerConnectionFactory
    var mediaStream: RTCMediaStream
    var customFrameCapturer = true
    var videoCapturer: RTCCameraVideoCapturer?
    var videoSource: RTCVideoSource?
//    var device:AVCaptureDevice = AVCaptureDevice.default(for: .video)
    var device:AVCaptureDevice?
    internal static let shared = MediaCapturer.init();
    
    private override init() {
        self.peerConnectionFactory = RTCPeerConnectionFactory.init();
        self.mediaStream = self.peerConnectionFactory.mediaStream(withStreamId: MediaCapturer.MEDIA_STREAM_ID)
    }
    
    internal func createVideoTrack() -> RTCVideoTrack {
        device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)!
        do {
            let input = try AVCaptureDeviceInput(device: device!)
          
        } catch {
            

        }

        // if there is a device start capturing it
        self.videoCapturer = RTCCameraVideoCapturer.init();
        self.videoCapturer!.delegate = self
        self.videoCapturer!.startCapture(with: device!, format: device!.activeFormat, fps: 22);
        self.videoSource = self.peerConnectionFactory.videoSource();
        self.videoSource!.adaptOutputFormat(toWidth: 640, height: 480, fps: 22);

        let videoTrack: RTCVideoTrack = self.peerConnectionFactory.videoTrack(with: self.videoSource!, trackId: MediaCapturer.VIDEO_TRACK_ID)
        self.mediaStream.addVideoTrack(videoTrack)
        videoTrack.isEnabled = true
        return videoTrack
    }
    internal func createAudioTrack() -> RTCAudioTrack {
        //autoGainControl = true
        //googEchoCancellation2 = true
        var mandatoryConstraints: [String: String]?
//        mandatoryConstraints = ["minFrameRate": "\(Constants.Callframes.low)", "maxFrameRate": "\(Constants.Callframes.high)","echoCancellation": "true","noiseSuppression":"true","autoGainControl":"true","googEchoCancellation2":"true"]
        mandatoryConstraints = ["audio":"true","noiseSuppression":"true","echoCancellation":"true"]
        let audioConstrains = RTCMediaConstraints(mandatoryConstraints: mandatoryConstraints, optionalConstraints: nil)
        let audioSource = self.peerConnectionFactory.audioSource(with: audioConstrains)
        let audioTrack = self.peerConnectionFactory.audioTrack(with: audioSource, trackId: MediaCapturer.AUDIO_TRACK_ID)
        audioTrack.source.volume = 0
        audioTrack.isEnabled = true
        self.mediaStream.addAudioTrack(audioTrack)
        
        return audioTrack
    }
    
    func captureDevice(with position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        
        let devices = AVCaptureDevice.DiscoverySession(deviceTypes: [ .builtInWideAngleCamera, .builtInMicrophone, .builtInDualCamera, .builtInTelephotoCamera ], mediaType: AVMediaType.video, position: .unspecified).devices
        for device in devices {
            if device.position == position {
                return device
            }
        }
        return nil
    }

    func swapCamera() {
        
        // Get current input
        //self.videoCapturer?.captureSession
        guard let input = self.videoCapturer?.captureSession.inputs[0] as? AVCaptureDeviceInput else { return }
        
        // Begin new session configuration and defer commit
        self.videoCapturer?.captureSession.beginConfiguration()
        defer { self.videoCapturer?.captureSession.commitConfiguration() }
        
        // Create new capture device
        var newDevice: AVCaptureDevice?
        if input.device.position == .back {
            newDevice = captureDevice(with: .front)
        } else {
            newDevice = captureDevice(with: .back)
        }
        
        // Create new capture input
        var deviceInput: AVCaptureDeviceInput!
        do {
            deviceInput = try AVCaptureDeviceInput(device: newDevice!)
        } catch let error {
            return
        }
        
        // Swap capture device inputs
        self.videoCapturer?.captureSession.removeInput(input)
        if ((self.videoCapturer?.captureSession.canAddInput(deviceInput)) != nil) {
            self.videoCapturer?.captureSession.addInput(deviceInput)
        }
    }
}

extension MediaCapturer : RTCVideoCapturerDelegate {
    func capturer(_ capturer: RTCVideoCapturer, didCapture frame: RTCVideoFrame) {
        DispatchQueue.main.async {
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
            self.videoSource?.capturer(capturer, didCapture: frame)
        }
    }
}
