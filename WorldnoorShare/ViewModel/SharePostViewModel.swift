//
//  SharePostViewModel.swift
//  WorldnoorShare
//
//  Created by Raza najam on 7/6/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import UIKit

class SharePostViewModel: NSObject {
    var selectedAssets = [ShareCollectionViewObject]()
    var oldAssets = [ShareCollectionViewObject]()
    var newAssets = [ShareCollectionViewObject]()
    
    var reloadCreateCollection: (()->())?
    
    override init() {
        super.init()
    }
}

extension SharePostViewModel:UICollectionViewDropDelegate, UICollectionViewDragDelegate   {
    
    @available(iOS 11.0, *)
    private func reorderItems(coordinator: UICollectionViewDropCoordinator, destinationIndexPath: IndexPath, collectionView: UICollectionView) {
        let items = coordinator.items
        if  items.count == 1, let item = items.first,
            let sourceIndexPath = item.sourceIndexPath,
            let localObject = item.dragItem.localObject as? ShareCollectionViewObject {
            
            collectionView.performBatchUpdates ({
                self.selectedAssets.remove(at: sourceIndexPath.item)
                self.selectedAssets.insert(localObject, at: destinationIndexPath.item)
                collectionView.deleteItems(at: [sourceIndexPath])
                collectionView.insertItems(at: [destinationIndexPath])
                self.reloadCreateCollection?()
            })
        }
    }
    
    @available(iOS 11.0, *)
    private func copyItems(coordinator: UICollectionViewDropCoordinator, destinationIndexPath: IndexPath, collectionView: UICollectionView) {
        collectionView.performBatchUpdates({
            var indexPaths = [IndexPath]()
            for (index, item) in coordinator.items.enumerated() {
                if let localObject = item.dragItem.localObject as? ShareCollectionViewObject {
                    let indexPath = IndexPath(row: destinationIndexPath.row + index, section: destinationIndexPath.section)
                    self.selectedAssets.insert(localObject, at: indexPath.row)
                    indexPaths.append(indexPath)
                }
            }
            collectionView.insertItems(at: indexPaths)
        })
    }
    
    @available(iOS 11.0, *)
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        let destinationIndexPath: IndexPath
        if let indexPath = coordinator.destinationIndexPath {
            destinationIndexPath = indexPath
        } else {
            let section = collectionView.numberOfSections - 1
            let row = collectionView.numberOfItems(inSection: section)
            destinationIndexPath = IndexPath(row: row, section: section)
        }
        switch coordinator.proposal.operation {
        case .move:
            reorderItems(coordinator: coordinator, destinationIndexPath:destinationIndexPath, collectionView: collectionView)
        case .copy:
            copyItems(coordinator: coordinator, destinationIndexPath: destinationIndexPath, collectionView: collectionView)
        default: return
        }
    }
    
    @available(iOS 11.0, *)
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        return true
        
    }
    
    @available(iOS 11.0, *)
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        if collectionView.hasActiveDrag, let _ = destinationIndexPath {
            return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        } else {
            return UICollectionViewDropProposal(operation: .forbidden)
        }
    }
    
    @available(iOS 11.0, *)
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let itemProvider = NSItemProvider(object: "\(indexPath)" as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = self.selectedAssets[indexPath.row]
        return [dragItem]
    }
    
    func compressImage(_ image: UIImage?) -> UIImage? {
        var actualHeight = Float(image?.size.height ?? 0.0)
        var actualWidth = Float(image?.size.width ?? 0.0)
        let maxHeight: Float = 600.0
        let maxWidth: Float = 800.0
        var imgRatio = actualWidth / actualHeight
        let maxRatio = maxWidth / maxHeight
        let compressionQuality: Float = 0.5 //50 percent compression
        
        if actualHeight > maxHeight || actualWidth > maxWidth {
            if imgRatio < maxRatio {
                //adjust width according to maxHeight
                imgRatio = maxHeight / actualHeight
                actualWidth = imgRatio * actualWidth
                actualHeight = maxHeight
            } else if imgRatio > maxRatio {
                //adjust height according to maxWidth
                imgRatio = maxWidth / actualWidth
                actualHeight = imgRatio * actualHeight
                actualWidth = maxWidth
            } else {
                actualHeight = maxHeight
                actualWidth = maxWidth
            }
        }
        
        let rect = CGRect(x: 0.0, y: 0.0, width: CGFloat(actualWidth), height: CGFloat(actualHeight))
        UIGraphicsBeginImageContext(rect.size)
        image?.draw(in: rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        let imageData = img?.jpegData(compressionQuality: CGFloat(compressionQuality))
        UIGraphicsEndImageContext()
        
        if let imageData = imageData {
            return UIImage(data: imageData)
        }
        return nil
    }
    
    func saveFileToDocumentDirectory(image: UIImage) -> URL?
    {
        if let savedUrl = FileBasedManager.shared.saveFileToDocumentsDirectory(image: image, name: "image\(Date().timeIntervalSince1970)", extention: ".jpg") {
            return savedUrl
        }
        return nil
    }
}
