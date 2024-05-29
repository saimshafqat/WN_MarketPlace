import UIKit
import Alamofire
import Photos

protocol DownloadingStoryManagerProtocol {
    func requestStoryManagerDownloadingProgressDelegate(progress:Int)
    func requestStoryManagerDownloadingResponseUploadedDelegate()
    func requestStoryManagerDownloadingResponseFailureDelegate()
}

class DownloadStoryManager: NSObject {
    var progressStatus = ""
    var progressPercentage = ""
    var statusObj: StoryObject? = nil
    var delegate: DownloadingStoryManagerProtocol?

    func startDownload(downloadUrl:URL, type:String, fileName:String = "") -> Void {
        let lastPart = downloadUrl.lastPathComponent
        Alamofire.request(downloadUrl).downloadProgress(closure : { (progress) in
            self.progressStatus = "downloading"
            let progressVal = CGFloat(progress.fractionCompleted*100)
//            self.existingMessage?.uploadingProgress = String(format: "%f", progressVal)
       //     CoreDataStack.shared.saveContext()
//            self.delegate?.requestManagerDownloadingProgressDelegate(progress: Int(progressVal))
        }).responseData{ [self] (response) in
            if let data = response.result.value {
                self.progressStatus = "downloaded"
                if type == "image" {
                  let identifier = SharedManager.shared.getIdentifierForMessage()
        //            let fileName = String(statusObj!.timeStamp)
                    let imgData = data as NSData
                    FileBasedManager.shared.saveStoryImageInDocument(data:imgData, fileName: fileName)
                }else if type == "video" {
              //      let fileName = String(statusObj!.timeStamp) + lastPart
//                  let fileName = SharedManager.shared.getIdentifierForMessage() + lastPart
              //      FileBasedManager.shared.saveStoryVideoInDocument(data:data as NSData, fileName: fileName)
                }
//                self.delegate?.requestManagerDownloadingResponseUploadedDelegate()
            }
        }
    }
}
