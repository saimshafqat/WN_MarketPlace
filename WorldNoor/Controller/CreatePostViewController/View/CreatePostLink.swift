//
//  LinkPreview.swift
//  WorldNoor
//
//  Created by Raza najam on 4/22/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import UIKit
import SwiftLinkPreview

class CreatePostLink: UIView {
    @IBOutlet weak var linkImageView: UIImageView!
    @IBOutlet weak var linkTitleLbl: UILabel!
    @IBOutlet weak var linkDescLbl: UILabel!
    @IBOutlet weak var linkCloseBtn: UIButton!

    func manageData(result:Response){
        
        self.linkImageView.loadImageWithPH(urlMain:result.image ?? "")
        
        
        self.labelRotateCell(viewMain: self.linkImageView)
        self.linkTitleLbl.text = result.title ?? "No Title".localized()
        self.linkDescLbl.text = result.description ?? "No Description".localized()
    }
}
