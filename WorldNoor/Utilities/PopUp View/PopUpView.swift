//
//  PopUpView.swift
//  Petmarket Version2
//
//  Created by apple on 1/18/23.
//

import Foundation
import UIKit

class PopUpView: UIView {
    
    @IBOutlet var viewError : UIView!
    @IBOutlet var lblError : UILabel!
    @IBOutlet var imgViewError : UIImageView!
    
    static func instance() -> PopUpView {
        return UINib(nibName: "PopUpView", bundle: .main)
            .instantiate(withOwner: self, options: nil).first as! PopUpView
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        //        if LanguageManager.shared.isRightToLeft{
        //            lblError.font = UIFont(name: "BahijTheSansArabicPlain", size: 15.0)
        //            lblError.textAlignment = .right
        //        }else{
        lblError.textAlignment = .left
        //        }
        //        animate()
    }
    
    func changeView(popUpObj: PopupClass) {
        
        self.lblError.text = popUpObj.title
        self.viewError.backgroundColor = popUpObj.bgColor
        //        self.imgViewError.image = UIImage.init(named: popUpObj.imgName)
    }
    
    //    func animate() {
    //        self.viewError.alpha = 0
    //        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveLinear], animations: {
    //            self.viewError.alpha = 1
    //        })
    //    }
}

struct PopupClass {
    var title : String!
    var bgColor : UIColor!
    var imgName : String!
}

public extension String {
    
    func height(forConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect,
                                            options: [.usesLineFragmentOrigin, .usesFontLeading],
                                            attributes: [.font: font],
                                            context: nil)
        return boundingBox.height
    }
}
