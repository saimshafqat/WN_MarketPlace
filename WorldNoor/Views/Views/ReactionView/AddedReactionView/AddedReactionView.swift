//
//  AddedReactionView.swift
//  WorldNoor
//
//  Created by HAwais on 20/12/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import Foundation
import UIKit

class AddedReactionView: UIView {
    
    @IBOutlet weak var emoji1: UIButton!
    @IBOutlet weak var emoji2: UIButton!
    @IBOutlet weak var emoji3: UIButton!
    @IBOutlet weak var countLbl:UILabel!
    @IBOutlet weak var viewHeight: NSLayoutConstraint!
    @IBOutlet weak var reactionStackView:UIStackView!{
        didSet{
            reactionStackView.layoutMargins = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
            reactionStackView.isLayoutMarginsRelativeArrangement = true
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let cornerRadius = min(bounds.width, bounds.height) / 2
        self.layer.cornerRadius = cornerRadius
        self.backgroundColor = UIColor.white
        self.addShadowToView(shadowRadius: 1, alphaComponent: 0.3)
    }
    
    func manageReactionStack(reactionArr: [String], count:Int)   {
        self.emoji1.isUserInteractionEnabled = false
        self.emoji2.isUserInteractionEnabled = false
        self.emoji3.isUserInteractionEnabled = false
        self.emoji1.isHidden = true
        self.emoji2.isHidden = true
        self.emoji3.isHidden = true
        self.countLbl.isHidden = true
        self.viewHeight.constant = 0
        
        // Create a dictionary to store counts
        var reactionCounts: [String: Int] = [:]
        for reactionType in SharedManager.shared.arrayChatGif {
            let count = reactionArr.filter { $0 == reactionType }.count
            if count > 0 {
                reactionCounts[reactionType] = count
            }
        }
        
        self.countLbl.isHidden = true
        if count > 3 {
            self.countLbl.text = "\(count)"
            self.countLbl.isHidden = false
        }else if reactionCounts["happy"] ?? 0 > 1  || reactionCounts["laugh"] ?? 0 > 1 || reactionCounts["sad"] ?? 0 > 1 || reactionCounts["cry"] ?? 0 > 1 || reactionCounts["angry"] ?? 0 > 1 || reactionCounts["like"] ?? 0 > 1{
            self.countLbl.isHidden = false
            self.countLbl.text = "\(count)"
        }
        
        let array = Array(reactionCounts.keys).sorted()
        switch array.count {
        case 1:
            self.emoji1.setImage(UIImage(named: "\(array[0])"), for: .normal)
            self.emoji1.isHidden = false
            self.viewHeight.constant = 32
            break
        case 2:
            self.emoji1.setImage(UIImage(named: "\(array[0])"), for: .normal)
            self.emoji1.isHidden = false
            self.emoji2.setImage(UIImage(named: "\(array[1])"), for: .normal)
            self.emoji2.isHidden = false
            self.viewHeight.constant = 32
            break
        case 3:
            self.emoji1.setImage(UIImage(named: "\(array[0])"), for: .normal)
            self.emoji1.isHidden = false
            self.emoji2.setImage(UIImage(named: "\(array[1])"), for: .normal)
            self.emoji2.isHidden = false
            self.emoji3.setImage(UIImage(named: "\(array[2])"), for: .normal)
            self.emoji3.isHidden = false
            self.viewHeight.constant = 32
            
            break
        case 4,5,6,7,8:
            self.emoji1.setImage(UIImage(named: "\(array[0])"), for: .normal)
            self.emoji1.isHidden = false
            self.emoji2.setImage(UIImage(named: "\(array[1])"), for: .normal)
            self.emoji2.isHidden = false
            self.emoji3.setImage(UIImage(named: "\(array[2])"), for: .normal)
            self.emoji3.isHidden = false
            self.viewHeight.constant = 32
            break
        default:
            LogClass.debugLog("default")
        }
    }
    
    func hideStack(){
        self.emoji1.isHidden = true
        self.emoji2.isHidden = true
        self.emoji3.isHidden = true
        self.countLbl.isHidden = true
        self.viewHeight.constant = 0
    }
    
}
