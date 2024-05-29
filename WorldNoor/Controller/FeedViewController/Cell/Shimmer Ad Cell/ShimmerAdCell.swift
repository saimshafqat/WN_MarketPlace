//
//  ShimmerAdCell.swift
//  WorldNoor
//
//  Created by Waseem Shah on 16/02/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import Foundation


class ShimmerAdCell : FeedParentCell  {
    
    @IBOutlet var viewshimmer : ShimmerView!
    
    
    
    override func awakeFromNib() {
    
    }
    
    
    func startShimmer(){
        self.viewshimmer.startAnimating()
    }
    
    func stopShimmer(){
        self.viewshimmer.stopAnimating()
    }
}


