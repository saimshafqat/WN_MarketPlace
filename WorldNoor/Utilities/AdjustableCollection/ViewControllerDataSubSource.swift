//
//  ViewControllerDataSource.swift
//  PartyPicksVertical
//
//  Created by Raza najam on 3/3/20.
//  Copyright © 2020 PartyWith. All rights reserved.
//

import UIKit

// MARK: - Data Source
class ViewControllerDataSubSource : NSObject, UICollectionViewDataSource {
    
    public var source = [ReportModel]()
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let object = source[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReportCategoryCell.cellIdentifier, for: indexPath) as! ReportCategoryCell
        cell.title.text = object.name
        cell.backgroundColor = UIColor.defaultLightGray
        cell.title.textColor = UIColor.black
        if object.isSelected {
            cell.backgroundColor = UIColor.themeBlueColor
            cell.title.textColor = UIColor.white
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return source.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
}

// MARK: - Party Picks Flow Layout Delegate
extension ViewControllerDataSubSource : PartyPicksVerticalFlowLayoutDelegate {
    
    func collectionView(_ collectionView: UICollectionView, widthForCellAt indexPath: IndexPath, withHeight height: CGFloat) -> CGFloat {
        let object = source[indexPath.row]
        return cellWidthFor(text: object.name)
    }
    
    private func cellWidthFor(text: String) -> CGFloat {
        let label = UILabel(frame: CGRect.zero)
        label.font = UIFont.systemFont(ofSize: 16.0)
        label.text = text
        label.sizeToFit()
        var rect = label.intrinsicContentSize
        rect.width += 32 // Padding
        let newWidth = rect.width.rounded()
        return newWidth
    }
}
