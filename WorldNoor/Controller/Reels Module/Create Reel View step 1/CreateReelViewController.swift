//
//  CreateReelViewController.swift
//  WorldNoor
//
//  Created by Omnia Samy on 03/11/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit
import TLPhotoPicker
import Photos
import AVKit

class CreateReelViewController: UIViewController {
    
    @IBOutlet private weak var uploadVideoView: UIView!
    @IBOutlet private weak var previewVideoView: UIView!
    @IBOutlet private weak var videoPreviewImageView: UIImageView!
    @IBOutlet private weak var chooseAnotherViedoView: UIView!
    
    var feedVideoModel = PostCollectionViewObject.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = "Create Reel".localized()
        self.previewVideoView.isHidden = true
        self.chooseAnotherViedoView.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationController?.isNavigationBarHidden = false
    }
}

extension CreateReelViewController {
    
    @IBAction func chooseVideoTapped(_ sender: UIButton) {
        
        let viewController = TLPhotosPickerViewController()
        viewController.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
        viewController.delegate = self
        viewController.configure.mediaType = .video
        viewController.configure.maxSelectedAssets = 1
        self.present(viewController, animated: true, completion: nil)
    }
    
    @IBAction func playVideo(_ sender: Any) {
        
        
        guard let videoURL = self.feedVideoModel.videoURL else { return }
        let player = AVPlayer(url: videoURL)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        self.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    }
    
    @IBAction func nextTapped(_ sender: UIButton) {
        
        // open new screen after check user upload video
        if self.feedVideoModel.videoURL == nil {
            SwiftMessages.showMessagePopup(theme: .success, title: "Alert", body: "Please select video".localized())
        } else {
            let vc = CreateReelStep2ViewController()
            vc.feedVideoModel = self.feedVideoModel
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    private func videoPreview() {
        self.uploadVideoView.isHidden = true
        self.previewVideoView.isHidden = false
        self.chooseAnotherViedoView.isHidden = false
    }
}

extension CreateReelViewController: TLPhotosPickerViewControllerDelegate {
    
    func dismissPhotoPicker(withTLPHAssets: [TLPHAsset]) {
        
//        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        for indexObj in withTLPHAssets {
            if indexObj.type == .video {
                
                feedVideoModel.assetMain = indexObj
                feedVideoModel.isType = PostDataType.Video
                feedVideoModel.langID = "1"
                let thumbImage: UIImage = SharedManager.shared.getImageFromAsset(asset: indexObj.phAsset!)!
                self.videoPreviewImageView.image = thumbImage
                feedVideoModel.imageMain = thumbImage
                self.videoPreview()
                do {
                    let options: PHVideoRequestOptions = PHVideoRequestOptions()
                    options.version = .original
                    PHImageManager.default().requestAVAsset(forVideo: indexObj.phAsset!,
                                                            options: options,
                                                            resultHandler: {(asset, audioMix, info) in
                        if let urlAsset = asset as? AVURLAsset {
                            self.feedVideoModel.videoURL = urlAsset.url
                            
                            CompressManager.shared.compressingVideoURLNEw(url: urlAsset.url) { compressedUrl in
                                
                                if compressedUrl == nil {
                                    DispatchQueue.main.async {
//                                        SharedManager.shared.hideLoadingHubFromKeyWindow()
                                        Loader.stopLoading()
                                    }
                                    
                                } else {
                                    
                                    self.feedVideoModel.videoURL = compressedUrl
                                    DispatchQueue.main.async {
//                                        SharedManager.shared.hideLoadingHubFromKeyWindow()
                                        Loader.stopLoading()
                                    }
                                }
                            }
                        }
                    })
                }
            }
        }
    }
}
