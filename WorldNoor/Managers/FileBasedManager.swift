//
//  FileBasedManager.swift
//  WorldNoor
//
//  Created by Raza najam on 2/7/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import UIKit
import AVKit
import Foundation
class FileBasedManager: NSObject {
    
    var audioFileSavedInTemp:((URL)->())?
    
    static let shared = FileBasedManager()
    
    var iscancelReuest = false
    func saveFileTemporarily(fileObj:UIImage, name:String) {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileName = name
        let fileManager = FileManager.default
        
        // create the destination file url to save your image
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        
        if fileManager.fileExists(atPath: fileURL.path) {
            do {
                try fileManager.removeItem(atPath: fileURL.path)
            }catch {

            }
        }
        // get your UIImage jpeg data representation and check if the destination file url already exists
        if let data = fileObj.jpegData(compressionQuality:  0.30),
           !FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                // writes the image data to disk
                try data.write(to: fileURL)

            } catch {

            }
        }
    }
    
    func saveStoryImageInDocument(data:NSData, fileName:String)   {
        let image = UIImage.init(data: data as Data)
        if image != nil {
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            // choose a name for your image
            let fileName = fileName + ".jpg"
            // create the destination file url to save your image
            let fileURL = documentsDirectory.appendingPathComponent(fileName)
            
            // get your UIImage jpeg data representation and check if the destination file url already exists
            if let data = image!.jpegData(compressionQuality:  1.0),
               !FileManager.default.fileExists(atPath: fileURL.path) {
                do {
                    // writes the image data to disk

                } catch {
                }
            }
        }
    }
    func getSavedImagePath(name:String)->String{
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        if let pathComponent = url.appendingPathComponent(name) {
            let filePath = pathComponent.path
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: filePath) {
                return filePath
            } else {
                return ""
            }
        } else {
            return ""
        }
    }
    func getFileURLIfExist(fileName:String)-> URL? {
        let fileUrl = self.getFileURL(append: fileName)
        if FileManager.default.fileExists(atPath: fileUrl.path){
            return fileUrl
        }
        return nil
    }
    
    func getFileURL(append:String) -> URL {
        let path = getKDocumentsDirectory().appendingPathComponent(append)
        return path as URL
    }
    func getKDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask)
        return paths[0]
    }
    
    func loadImage(pathMain : String) -> UIImage {
        let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let nsUserDomainMask    = FileManager.SearchPathDomainMask.userDomainMask
        let paths               = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
        if let dirPath          = paths.first
        {
            let imageURL = URL(fileURLWithPath: dirPath).appendingPathComponent(pathMain)
            let image    = UIImage(contentsOfFile: imageURL.path)
            if image == nil {
                return UIImage.init()
            }else {
                return image!
            }
            
        }else {
            return UIImage.init()
        }
    }
    
    func loadProfileImage(pathMain : String) -> UIImage? {
        let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let nsUserDomainMask    = FileManager.SearchPathDomainMask.userDomainMask
        let paths               = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
        if let dirPath          = paths.first
        {
            let imageURL = URL(fileURLWithPath: dirPath).appendingPathComponent(pathMain)
            let image    = UIImage(contentsOfFile: imageURL.path)
            if image == nil {
                return nil
            } else {
                return image!
            }
            
        } else {
            return nil
        }
    }

    func removeImage(nameImage : String = "myImageToUpload.jpg" ){
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let documentDirectoryFileUrl = documentsDirectory.appendingPathComponent(nameImage)
        if FileManager.default.fileExists(atPath: documentDirectoryFileUrl.path) {
            do {
                try FileManager.default.removeItem(at: documentDirectoryFileUrl)
            } catch {

            }
        }
    }
    
    func fileExist(nameFile : String) -> (String , Bool) {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
            let url = NSURL(fileURLWithPath: path)
            if let pathComponent = url.appendingPathComponent(nameFile) {
                let filePath = pathComponent.path
                let fileManager = FileManager.default
                if fileManager.fileExists(atPath: filePath) {
                    return (filePath, true)
                } else {
                    return ("" ,false)
                }
            } else {
                return ("", false)
            }
    }
    
    
    func removeFileFromPath(name:String){
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileName = name
        let fileManager = FileManager.default
        
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        if fileManager.fileExists(atPath: fileURL.path) {
            do {
                try fileManager.removeItem(atPath: fileURL.path)
            } catch {

            }
        }
    }
    
    func saveAudioFileTemporarily(pathURL:NSURL, name:String) {

        let str = pathURL.absoluteString
        let str2 = str!.replacingOccurrences(of: "ipod-library://item/item", with: "")
        let arr = str2.components(separatedBy: "?")
        var mimeType = arr[0]
        mimeType = mimeType.replacingOccurrences(of: ".", with: "")
        
        // Export the ipod library as .m4a file to local directory for remote upload
        let exportSession = AVAssetExportSession(asset: AVAsset(url: pathURL as URL), presetName: AVAssetExportPresetMediumQuality)
        exportSession?.shouldOptimizeForNetworkUse = true
        exportSession?.outputFileType = AVFileType.mp4
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileName = name + Shared.instance.getIdentifierForMessage() + ".wav"
        let fileManager = FileManager.default
        // create the destination file url to save your image
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        if fileManager.fileExists(atPath: fileURL.path) {
            do {
                try fileManager.removeItem(atPath: fileURL.path)
            }catch {

            }
        }
        exportSession?.outputURL = fileURL
        exportSession?.exportAsynchronously(completionHandler: { () -> Void in
            if exportSession!.status == AVAssetExportSession.Status.completed  {
                DispatchQueue.main.async(execute: {
                    self.audioFileSavedInTemp!(fileURL)
                })
            } else {
                
            }
        })
    }
    
    func saveFileToDocumentsDirectory(image: UIImage, name: String, extention: String) -> URL? {
        let path = try! FileManager.default.url(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask, appropriateFor: nil, create: false)
        let imagePath = path.appendingPathComponent(name + extention)
        let jpgImageData = image.jpegData(compressionQuality: 0)
        do {
            try jpgImageData!.write(to: imagePath)
            return imagePath
        } catch {
            return nil
        }
    }
    
    func encodeVideo(videoURL: URL,completion : @escaping ((_ newURL : URL?) -> Void))  {
        let avAsset = AVURLAsset(url: videoURL, options: nil)
        var exportSession : AVAssetExportSession?
        exportSession = AVAssetExportSession(asset: avAsset, presetName: AVAssetExportPreset640x480)
        
        // exportSession = AVAssetExportSession(asset: composition, presetName: mp4Quality)
        //Creating temp path to save the converted video
        let name = Shared.instance.getIdentifierForMessage()
        let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let myDocumentPath = NSURL(fileURLWithPath: documentsDirectory).appendingPathComponent(name)?.absoluteString
        _ = URL.init(string: myDocumentPath!)
        let documentsDirectory2 = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as NSURL
        let filePath = documentsDirectory2.appendingPathComponent("rendered-Video.mp4")
        self.deleteFile(filePath: filePath!)
        
        
        //Check if the file already exists then remove the previous file
        if FileManager.default.fileExists(atPath: myDocumentPath!) {
            do {

                try FileManager.default.removeItem(atPath: myDocumentPath!)
            }
            catch let error {
               
            }
        }
        
        exportSession!.outputURL = filePath
        exportSession!.outputFileType = AVFileType.mp4
        exportSession!.shouldOptimizeForNetworkUse = true
        let start = CMTimeMakeWithSeconds(0.0, preferredTimescale: 0)
        let range = CMTimeRangeMake(start: start, duration: avAsset.duration)
        exportSession!.timeRange = range
        
        exportSession!.exportAsynchronously(completionHandler: {() -> Void in
            switch exportSession?.status {
            case .failed:
                completion(nil)
            case .cancelled:
                completion(nil)
            case .completed:
                completion(exportSession?.outputURL)
            default:
                break
            }
        })
    }
    
    func deleteFile(filePath: URL) {
        guard FileManager.default.fileExists(atPath: filePath.path) else {
            return
        }
        
        do {
            try FileManager.default.removeItem(atPath: filePath.path)
        }catch{
            fatalError("Unable to delete file: \(error) : \(#function).")
        }
    }
    
    func clearTmpDirectory() {

        do {
            let fileManager = FileManager.default
            let tmpDirectory = try fileManager.contentsOfDirectory(atPath: NSTemporaryDirectory())
            try tmpDirectory.forEach { file in
                let path = String.init(format: "%@%@", NSTemporaryDirectory(), file)
                try fileManager.removeItem(atPath: path)
            }
        } catch {
        }
    }
}

extension FileBasedManager {
    func fileOutput(_ output: AVCaptureFileOutput,
                    didFinishRecordingTo outputFileURL: URL,
                    from connections: [AVCaptureConnection],
                    error: Error?) {
        guard let data = try? Data(contentsOf: outputFileURL) else {
            return
        }
        
        
        let compressedURL = NSURL.fileURL(withPath: NSTemporaryDirectory() + UUID().uuidString + ".mp4")
        compressVideo(inputURL: outputFileURL as URL,
                      outputURL: compressedURL) { exportSession in
            guard let session = exportSession else {
                return
            }
            
            switch session.status {
            case .unknown:
                break
            case .waiting:
                break
            case .exporting:
                break
            case .completed:
                guard let compressedData = try? Data(contentsOf: compressedURL) else {
                    return
                }
                
            case .failed:
                break
            case .cancelled:
                break
            }
        }
    }
    
    func compressVideo(inputURL: URL,
                       outputURL: URL,
                       handler:@escaping (_ exportSession: AVAssetExportSession?) -> Void) {
        let urlAsset = AVURLAsset(url: inputURL, options: nil)
        guard let exportSession = AVAssetExportSession(asset: urlAsset,
                                                       presetName: AVAssetExportPresetMediumQuality) else {
            handler(nil)
            
            return
        }
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4
        exportSession.exportAsynchronously {
            handler(exportSession)
        }
    }
}
