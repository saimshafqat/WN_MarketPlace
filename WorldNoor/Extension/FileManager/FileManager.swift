//
//  FileManager.swift
//  kalam
//
//  Created by mac on 17/10/2019.
//  Copyright © 2019 apple. All rights reserved.
//

import UIKit
import AVKit
extension FileManager {
    func clearTmpDirectory() {
        do {
            let tmpDirectory = try contentsOfDirectory(atPath: NSTemporaryDirectory())
            try tmpDirectory.forEach {[unowned self] file in
                let path = String.init(format: "%@%@", NSTemporaryDirectory(), file)
                try self.removeItem(atPath: path)
            }
        } catch {

        }
    }
    
}

extension FileManager {
    
    func saveFileToDocumentDirectory(fileUrl: URL, name: String, extention:String) -> URL? {
        let videoData = NSData(contentsOf: fileUrl as URL)
        let path = try! FileManager.default.url(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask, appropriateFor: nil, create: false)
        let filePath = path.appendingPathComponent(name + "." + extention)
        do {
            try videoData?.write(to: filePath)
            return filePath
        }
        catch {
            return nil
        }
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
    
    func removeFileFromDocumentsDirectory(fileUrl: URL) -> Bool {
        do {
            try self.removeItem(at: fileUrl)
            return true
        } catch {
            return false
        }
    }
 
}
