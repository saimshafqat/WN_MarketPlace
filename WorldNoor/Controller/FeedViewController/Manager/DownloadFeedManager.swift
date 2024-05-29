//
//  DownloadFeedManager.swift
//  WorldNoor
//
//  Created by Raza najam on 7/9/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import UIKit
import Alamofire
import Photos

class DownloadFeedManager: NSObject {
    var progressStatus = ""
    var progressPercentage = ""
    var downloadPLbl: UILabel?

    func startDownload(downloadUrl:URL) -> Void {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
        let fileName = SharedManager.shared.getIdentifierForMessage()
        let filePath = String(format: "%@/%@myFile.mp4",documentsPath,fileName)
        Alamofire.request(downloadUrl).downloadProgress(closure : { (progress) in
            self.progressStatus = "downloading"
            let progressVal = CGFloat(progress.fractionCompleted*100)
            self.progressPercentage = String(format: "%f", progressVal)
            self.downloadPLbl?.text = "\(Int(progressVal))%"

        }).responseData{ (response) in
            if let data = response.result.value {
                self.progressStatus = "downloaded"
                DispatchQueue.main.async {
                    let videoData = data as NSData
                    videoData.write(toFile: filePath, atomically: true)
                    PHPhotoLibrary.shared().performChanges({
                        PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL(fileURLWithPath: filePath))
                    }) { completed, error in
                        if completed {
                            self.progressStatus = "saved"
                            DispatchQueue.main.async {
                                self.downloadPLbl?.isHidden = true
                            }
                        }
                    }
                }
            }
        }
    }
}
