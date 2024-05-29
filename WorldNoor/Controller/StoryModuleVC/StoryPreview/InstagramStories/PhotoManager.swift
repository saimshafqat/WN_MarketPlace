//
//  PhotoManager.swift
//  kalam
//
//  Created by Raza najam on 3/8/21.
//  Copyright © 2021 apple. All rights reserved.
//

import UIKit
import Photos

class PhotoManager {
    
    static let albumName = "KalamTime"
    static let sharedInstance = PhotoManager()
    var albumFound:Bool = false
    var assetCollection: PHAssetCollection!
    var assetCollectionPlaceholder: PHObjectPlaceholder!

    
    init() {
        
//        func fetchAssetCollectionForAlbum() -> PHAssetCollection! {
//            let fetchOptions = PHFetchOptions()
//            fetchOptions.predicate = NSPredicate(format: "title = %@", PhotoManager.albumName)
//            let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
//            if let firstObject: AnyObject = collection.firstObject {
//                return collection.firstObject as! PHAssetCollection
//            }
//            return nil
//        }
//        if let assetCollection = fetchAssetCollectionForAlbum() {
//            self.assetCollection = assetCollection
//            return
//        }
//        PHPhotoLibrary.shared().performChanges({
//            PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: PhotoManager.albumName)
//        }) { success, _ in
//            if success {
//                self.assetCollection = fetchAssetCollectionForAlbum()
//            }
//        }
        self.createAlbum()
    }
    
    func createAlbum() {
        //Get PHFetch Options
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", PhotoManager.albumName)
        let collection : PHFetchResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        //Check return value - If found, then get the first album out
        if let _: AnyObject = collection.firstObject {
            self.albumFound = true
            assetCollection = collection.firstObject
        } else {
            //If not found - Then create a new album
            PHPhotoLibrary.shared().performChanges({
                let createAlbumRequest : PHAssetCollectionChangeRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: PhotoManager.albumName)
                self.assetCollectionPlaceholder = createAlbumRequest.placeholderForCreatedAssetCollection
                }, completionHandler: { success, error in
                    self.albumFound = success
                    if (success) {
                        let collectionFetchResult = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [self.assetCollectionPlaceholder.localIdentifier], options: nil)
                        self.assetCollection = collectionFetchResult.firstObject
                    }
            })
        }
    }
    
    func saveImage(image: UIImage) {
        if assetCollection == nil {
            return   // If there was an error upstream, skip the save.
        }
        PHPhotoLibrary.shared().performChanges({
            let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            let assetPlaceholder = assetChangeRequest.placeholderForCreatedAsset
            let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection)
            albumChangeRequest!.addAssets([assetPlaceholder] as NSFastEnumeration)
        }, completionHandler: nil)
    }
    
    func saveVideo(filePath:String){
        if assetCollection == nil {
            return   // If there was an error upstream, skip the save.
        }
        DispatchQueue.main.async {
            DispatchQueue.main.async {
                PHPhotoLibrary.shared().performChanges({
                    let assetChange = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL(fileURLWithPath: filePath))
                    let assetPlaceholder = assetChange?.placeholderForCreatedAsset
                    let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection)
                    albumChangeRequest!.addAssets([assetPlaceholder] as NSFastEnumeration)
                }) { completed, error in
                    if completed {
                    }
                }
            }
        }
    }
}
