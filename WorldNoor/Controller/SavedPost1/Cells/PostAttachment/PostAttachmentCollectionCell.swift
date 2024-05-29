//
//  PostAttachmentCollectionCell.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 01/03/24.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit

enum CellUpdateError: Error {
    case invalidFilePath
}

class PostAttachmentCollectionCell: PostBaseCollectionCell {
    
    @IBOutlet weak var fileIconImage: UIImageView!
    @IBOutlet weak var fileNameLabel: UILabel!
    
    @IBOutlet weak var dowloadButton: UIButton!
    @IBOutlet weak var downloadLabel: UILabel!
    
    // MARK: - Override -
    override func displayCellContent(data: AnyObject?, parentData: AnyObject?, at indexPath: IndexPath) {
        super.displayCellContent(data: data, parentData: parentData, at: indexPath)
        let obj = data as? FeedData
        let parentObj = parentData as? FeedData
        if let obj {
            LogClass.debugLog("Parent Post Type ==> \(parentObj?.postType ?? .emptyString)")
            updateCellData(feedObj: obj)
        }
    }
    
    @IBAction func onClickDownload(_ sender: UIButton) {
        Loader.startLoading()
        DispatchQueue.global().async {
            do {
                guard let filePath = self.parentObj?.post?.first?.filePath,
                      let fileURL = URL(string: filePath) else {
                    throw APIError.errorMessage("file path not exist")
                }
                
                let imageData = try Data(contentsOf: fileURL)
                let activityViewController = self.prepareActivityViewController(with: imageData)
                DispatchQueue.main.async {
                    Loader.stopLoading()
                    UIApplication.topViewController()?.present(activityViewController, animated: true) { }
                }
            } catch {
                DispatchQueue.main.async {
                    Loader.stopLoading()
                }
            }
        }
    }
    
    private func prepareActivityViewController(with imageData: Data) -> UIActivityViewController {
        let activityViewController = UIActivityViewController(activityItems: [imageData], applicationActivities: nil)
        activityViewController.excludedActivityTypes = SharedManager.shared.excludingArray
        return activityViewController
    }
    
    func updateCellData(feedObj: FeedData) {
        
        fileNameLabel.rotateViewForLanguage()
        fileNameLabel.rotateForTextAligment()
        downloadLabel.rotateViewForLanguage()
        fileIconImage.rotateViewForLanguage()
        
        // Set text alignment based on language
        fileNameLabel.textAlignment = SharedManager.shared.checkLanguageAlignment() ? .right : .left
        
        guard parentObj?.postType == FeedType.file.rawValue,
              let firstPost = feedObj.post?.first,
              let filePath = firstPost.filePath else { return }
        
        let urlComponents = filePath.components(separatedBy: ".")
        let fileNameComponents = filePath.components(separatedBy: "/")
        
        // Set file name
        if let fileName = fileNameComponents.last {
            fileNameLabel.text = fileName
        }
        
        // Set file icon based on file extension
        let fileExtension = FileExtension(fileExtension: urlComponents.last)
        fileIconImage.image = UIImage(named: fileExtension.iconImageName)
    }
}


enum FileExtension {
    case pdf
    case doc, docx
    case xls, xlsx
    case zip
    case pptx
    case unknown
    
    var iconImageName: String {
        switch self {
        case .pdf:
            return "PDFIcon.png"
        case .doc, .docx:
            return "WordFile.png"
        case .xls, .xlsx:
            return "ExcelIcon.png"
        case .zip:
            return "ZipIcon.png"
        case .pptx:
            return "pptIcon.png"
        case .unknown:
            return "DefaultIcon.png"
        }
    }
    
    init(fileExtension: String?) {
        guard let ext = fileExtension else {
            self = .unknown
            return
        }
        
        switch ext.lowercased() {
        case "pdf":
            self = .pdf
        case "doc", "docx":
            self = .docx
        case "xls", "xlsx":
            self = .xlsx
        case "zip":
            self = .zip
        case "pptx":
            self = .pptx
        default:
            self = .unknown
        }
    }
}
