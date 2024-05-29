//
//  viewExtension.swift
//  WorldNoor
//
//  Created by Waseem Shah on 07/09/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func addSenderChatColor() {
        self.layer.cornerRadius = 20
        self.backgroundColor = SharedManager.shared.colourBG
    }
    
    func addReceiverChatColor() {
        self.layer.cornerRadius = 20
        self.backgroundColor = UIColor.init().hexStringToUIColor(hex: "F0F0F0")
    }
    
    func addReplyChatColor() {
        self.layer.cornerRadius = 10
        self.backgroundColor = UIColor.init().hexStringToUIColor(hex: "F5F5F5")
    }
}

class SendChatBubbleView: UIView {

//    let bubbleLayer = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    func commonInit() -> Void {
//        layer.addSublayer(bubbleLayer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

//        let width = bounds.size.width
//        let height = bounds.size.height
//
//        let bezierPath = UIBezierPath()
//
//
//            bezierPath.move(to: CGPoint(x: width - 22, y: height))
//            bezierPath.addLine(to: CGPoint(x: 17, y: height))
//            bezierPath.addCurve(to: CGPoint(x: 0, y: height - 17), controlPoint1: CGPoint(x: 7.61, y: height), controlPoint2: CGPoint(x: 0, y: height - 7.61))
//            bezierPath.addLine(to: CGPoint(x: 0, y: 17))
//            bezierPath.addCurve(to: CGPoint(x: 17, y: 0), controlPoint1: CGPoint(x: 0, y: 7.61), controlPoint2: CGPoint(x: 7.61, y: 0))
//            bezierPath.addLine(to: CGPoint(x: width - 21, y: 0))
//            bezierPath.addCurve(to: CGPoint(x: width - 4, y: 17), controlPoint1: CGPoint(x: width - 11.61, y: 0), controlPoint2: CGPoint(x: width - 4, y: 7.61))
//            bezierPath.addLine(to: CGPoint(x: width - 4, y: height - 11))
//            bezierPath.addCurve(to: CGPoint(x: width, y: height), controlPoint1: CGPoint(x: width - 4, y: height - 1), controlPoint2: CGPoint(x: width, y: height))
//            bezierPath.addLine(to: CGPoint(x: width + 0.05, y: height - 0.01))
////            bezierPath.addCurve(to: CGPoint(x: width - 11.04, y: height - 4.04), controlPoint1: CGPoint(x: width - 4.07, y: height + 0.43), controlPoint2: CGPoint(x: width - 8.16, y: height - 1.06))
////            bezierPath.addCurve(to: CGPoint(x: width - 22, y: height), controlPoint1: CGPoint(x: width - 16, y: height), controlPoint2: CGPoint(x: width - 19, y: height))
//            bezierPath.close()
//
//        bubbleLayer.fillColor =  SharedManager.shared.colourBG.cgColor
//
//        bubbleLayer.path = bezierPath.cgPath
        
        self.layer.cornerRadius = 20
        self.addGradientColor()
    }
    
    func updateBubbleColor() {
        addGradientColor()
    }

    func addGradientColor() {
        removePreviousGradientLayer()
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds

        gradientLayer.colors = [SharedManager.shared.colourBG.cgColor, UIColor.init().hexStringToUIColor(hex: "#4BB3D8").cgColor]
        gradientLayer.cornerRadius = 20
        layer.insertSublayer(gradientLayer, at: 0)
        clipsToBounds = true
    }

    func removePreviousGradientLayer() {
        if let existingLayers = layer.sublayers {
            for layer in existingLayers {
                if layer is CAGradientLayer {
                    layer.removeFromSuperlayer()
                }
            }
        }
    }
    
}

class ChatBubbleView: UIView {

//    let bubbleLayer = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    func commonInit() -> Void {

        // add the bubble layer
//        layer.addSublayer(bubbleLayer)


    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let width = bounds.size.width
        let height = bounds.size.height

//        let bezierPath = UIBezierPath()
//
//            bezierPath.move(to: CGPoint(x: 22, y: height))
//            bezierPath.addLine(to: CGPoint(x: width - 17, y: height))
//            bezierPath.addCurve(to: CGPoint(x: width, y: height - 17), controlPoint1: CGPoint(x: width - 7.61, y: height), controlPoint2: CGPoint(x: width, y: height - 7.61))
//            bezierPath.addLine(to: CGPoint(x: width, y: 17))
//            bezierPath.addCurve(to: CGPoint(x: width - 17, y: 0), controlPoint1: CGPoint(x: width, y: 7.61), controlPoint2: CGPoint(x: width - 7.61, y: 0))
//            bezierPath.addLine(to: CGPoint(x: 21, y: 0))
//            bezierPath.addCurve(to: CGPoint(x: 4, y: 17), controlPoint1: CGPoint(x: 11.61, y: 0), controlPoint2: CGPoint(x: 4, y: 7.61))
//            bezierPath.addLine(to: CGPoint(x: 4, y: height - 11))
//            bezierPath.addCurve(to: CGPoint(x: 0, y: height), controlPoint1: CGPoint(x: 4, y: height - 1), controlPoint2: CGPoint(x: 0, y: height))
//            bezierPath.addLine(to: CGPoint(x: -0.05, y: height - 0.01))
////            bezierPath.addCurve(to: CGPoint(x: 11.04, y: height - 4.04), controlPoint1: CGPoint(x: 4.07, y: height + 0.43), controlPoint2: CGPoint(x: 8.16, y: height - 1.06))
////            bezierPath.addCurve(to: CGPoint(x: 22, y: height), controlPoint1: CGPoint(x: 16, y: height), controlPoint2: CGPoint(x: 19, y: height))
//            bezierPath.close()
//
//
//        bubbleLayer.fillColor = UIColor.init(red: (210/255), green: (210/255), blue: (210/255), alpha: 1.0).cgColor
//
//        bubbleLayer.path = bezierPath.cgPath

        self.layer.cornerRadius = 20
        self.backgroundColor = UIColor.init(red: (240/255), green: (240/255), blue: (240/255), alpha: 1.0)
    }
}



/*
 
 //
 //  viewExtension.swift
 //  WorldNoor
 //
 //  Created by Waseem Shah on 07/09/2023.
 //  Copyright © 2023 Raza najam. All rights reserved.
 //

 import Foundation
 import UIKit


 class SendChatBubbleView: UIView {

     let bubbleLayer = CAShapeLayer()


     override init(frame: CGRect) {
         super.init(frame: frame)
         commonInit()
     }

     required init?(coder aDecoder: NSCoder) {
         super.init(coder: aDecoder)
         commonInit()
     }

     func commonInit() -> Void {

         layer.addSublayer(bubbleLayer)
     }

     override func layoutSubviews() {
         super.layoutSubviews()

         let width = bounds.size.width
         let height = bounds.size.height

         let bezierPath = UIBezierPath()
         bezierPath.move(to: CGPoint(x: width, y: 0))
         bezierPath.addLine(to: CGPoint(x: 17, y: 0))
         bezierPath.addCurve(to: CGPoint(x: 0, y: 17), controlPoint1: CGPoint(x: 7.61, y: 0), controlPoint2: CGPoint(x: 0, y: 7.61))
         bezierPath.addLine(to: CGPoint(x: 0, y: height - 17))
         
         bezierPath.addCurve(to: CGPoint(x: 17, y: height), controlPoint1: CGPoint(x: 0, y: height - 7.61), controlPoint2: CGPoint(x: 7.61, y: height ))
         bezierPath.addLine(to: CGPoint(x: width - 17, y: height))
         bezierPath.addCurve(to: CGPoint(x: width, y: height -  17), controlPoint1: CGPoint(x: width - 6.71, y: height ), controlPoint2: CGPoint(x: width , y: height - 6.71))
         bezierPath.addLine(to: CGPoint(x: width, y: 0))
         
         bezierPath.close()

         bubbleLayer.fillColor =  UIColor.init(red: (57/255), green: (130/255), blue: (247/255), alpha: 1.0).cgColor

         bubbleLayer.path = bezierPath.cgPath

     }
 }


 class ChatBubbleView: UIView {

     let bubbleLayer = CAShapeLayer()

     override init(frame: CGRect) {
         super.init(frame: frame)
         commonInit()
     }

     required init?(coder aDecoder: NSCoder) {
         super.init(coder: aDecoder)
         commonInit()
     }

     func commonInit() -> Void {

         // add the bubble layer
         layer.addSublayer(bubbleLayer)


     }

     override func layoutSubviews() {
         super.layoutSubviews()

         let width = bounds.size.width
         let height = bounds.size.height

         let bezierPath = UIBezierPath()
         
         bezierPath.move(to: CGPoint(x: 0, y: 0))
         bezierPath.addLine(to: CGPoint(x: 0, y: height - 17))
         
 //
         bezierPath.addCurve(to: CGPoint(x: 17, y: height), controlPoint1: CGPoint(x: 0, y: height - 7.61), controlPoint2: CGPoint(x: 7.61, y: height ))
         bezierPath.addLine(to: CGPoint(x: width - 17, y: height))
         bezierPath.addCurve(to: CGPoint(x: width, y: height -  17), controlPoint1: CGPoint(x: width - 6.71, y: height ), controlPoint2: CGPoint(x: width , y: height - 6.71))
         
         bezierPath.addLine(to: CGPoint(x: width, y: height - 17))
         
 //        bezierPath.addCurve(to: CGPoint(x: 0, y: 17), controlPoint1: CGPoint(x: 7.61, y: 0), controlPoint2: CGPoint(x: 0, y: 7.61))

 //        bezierPath.addCurve(to: CGPoint(x: width - 17, y: 0), controlPoint1: CGPoint(x: width + 7.61 , y: height - 17 ), controlPoint2: CGPoint(x: width - 17 , y: 7.61))
         
         bezierPath.addCurve(to: CGPoint(x: width - 17, y: 0), controlPoint1: CGPoint(x: width, y: 7.61), controlPoint2: CGPoint(x: width - 7.61, y: 0))

         
         
         bezierPath.addLine(to: CGPoint(x: 0, y: 0))
         
         bezierPath.close()


         bubbleLayer.fillColor = UIColor.init(red: (210/255), green: (210/255), blue: (210/255), alpha: 1.0).cgColor

         bubbleLayer.path = bezierPath.cgPath

     }
     
     
     
 //    override func layoutSubviews() {
 //        super.layoutSubviews()
 //
 //        let width = bounds.size.width
 //        let height = bounds.size.height
 //
 //        let bezierPath = UIBezierPath()
 //
 //            bezierPath.move(to: CGPoint(x: 22, y: height))
 //            bezierPath.addLine(to: CGPoint(x: width - 17, y: height))
 //            bezierPath.addCurve(to: CGPoint(x: width, y: height - 17), controlPoint1: CGPoint(x: width - 7.61, y: height), controlPoint2: CGPoint(x: width, y: height - 7.61))
 //            bezierPath.addLine(to: CGPoint(x: width, y: 17))
 //            bezierPath.addCurve(to: CGPoint(x: width - 17, y: 0), controlPoint1: CGPoint(x: width, y: 7.61), controlPoint2: CGPoint(x: width - 7.61, y: 0))
 //            bezierPath.addLine(to: CGPoint(x: 21, y: 0))
 //            bezierPath.addCurve(to: CGPoint(x: 4, y: 17), controlPoint1: CGPoint(x: 11.61, y: 0), controlPoint2: CGPoint(x: 4, y: 7.61))
 //            bezierPath.addLine(to: CGPoint(x: 4, y: height - 11))
 //            bezierPath.addCurve(to: CGPoint(x: 0, y: height), controlPoint1: CGPoint(x: 4, y: height - 1), controlPoint2: CGPoint(x: 0, y: height))
 //            bezierPath.addLine(to: CGPoint(x: -0.05, y: height - 0.01))
 //            bezierPath.close()
 //
 //
 //        bubbleLayer.fillColor = UIColor.init(red: (210/255), green: (210/255), blue: (210/255), alpha: 1.0).cgColor
 //
 //        bubbleLayer.path = bezierPath.cgPath
 //
 //    }
 }

 
 
 */


class ChatReplyBubbleView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let width = bounds.size.width
        let height = bounds.size.height

        self.layer.cornerRadius = 20
        self.backgroundColor = UIColor.init(red: (247/255), green: (247/255), blue: (247/255), alpha: 1.0)
    }
}
