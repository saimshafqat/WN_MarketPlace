//
//  ShimmerPostCell.swift
//  WorldNoor
//
//  Created by Waseem Shah on 16/02/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import Foundation
import UIKit

class ShimmerPostCell : FeedParentCell {
    @IBOutlet var shimmer_Image : ShimmerView!
    @IBOutlet var shimmer_Name : ShimmerView!
    @IBOutlet var shimmer_Time : ShimmerView!
    @IBOutlet var shimmer_Main : ShimmerView!
    @IBOutlet var shimmer_Share : ShimmerView!
    @IBOutlet var shimmer_Button : ShimmerView!
    
    func startShimmer(){
        self.shimmer_Image.startAnimating()
        self.shimmer_Name.startAnimating()
        self.shimmer_Time.startAnimating()
        self.shimmer_Main.startAnimating()
        self.shimmer_Share.startAnimating()
        self.shimmer_Time.startAnimating()
    }
}
