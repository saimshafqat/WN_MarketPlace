//
//  LinkPreview.swift
//  WorldNoor
//
//  Created by Raza najam on 4/22/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import UIKit


class LinkPreview: UIView {
    @IBOutlet weak var linkImageView: UIImageView!
    @IBOutlet weak var linkTitleLbl: UILabel!
    @IBOutlet weak var linkDescLbl: UILabel!
    @IBOutlet weak var linkPreviewBtn: UIButton!
    
    func manageData(feedObj:FeedData)   {
        self.linkImageView.sd_setImage(with: URL(string: feedObj.linkImage ?? ""), placeholderImage: UIImage(named: "placeholder"))
        self.labelRotateCell(viewMain: self.linkImageView)
        self.linkTitleLbl.text = feedObj.linkTitle ?? "No Title".localized()
        self.linkDescLbl.text = feedObj.linkDesc ?? "No Description".localized()
    }
}
