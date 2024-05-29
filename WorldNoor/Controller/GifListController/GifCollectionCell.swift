//
//  GifCollectionCell.swift
//  WorldNoor
//
//  Created by Raza najam on 3/14/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import UIKit

class GifCollectionCell: UICollectionViewCell {
    
    @IBOutlet private weak var gifImgView:UIImageView!
    @IBOutlet private weak var selectedBgView: UIView!
    
    func bind(gif: GifModel) {
        // gifImgView.loadImageWithPH(urlMain: gif.url)
        // gifImgView.imageLoad(urlMain: gif.url)
        gifImgView.imageLoad(with: gif.url)
        self.contentView.labelRotateCell(viewMain: gifImgView)
        selectedBgView.isHidden = true
        if gif.isSelected {
            selectedBgView.isHidden = false
        }
    }
}
