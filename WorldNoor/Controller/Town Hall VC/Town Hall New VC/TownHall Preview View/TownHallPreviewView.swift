//
//  TownHallPreviewView.swift
//  WorldNoor
//
//  Created by apple on 6/25/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import Foundation
import UIKit
import SwiftLinkPreview

class TownHallPreviewView: UIView {
    @IBOutlet weak var linkImageView: UIImageView!
    @IBOutlet weak var linkTitleLbl: UILabel!
    @IBOutlet weak var linkDescLbl: UILabel!

    func manageData(result:Response){
//        self.linkImageView.sd_setImage(with: URL(string:result.image ?? ""), placeholderImage: UIImage(named: "placeholder"))
        
        self.linkImageView.loadImageWithPH(urlMain:result.image ?? "")
        
        self.labelRotateCell(viewMain: self.linkImageView)
        self.linkTitleLbl.text = result.title ?? "No Title".localized()
        self.linkDescLbl.text = result.description ?? "No Description".localized()
    }
}
