//
//  ShimmerView.swift
//
//

import UIKit

class ShimmerView: UIView {

    var gradientColorOne : CGColor = UIColor(white: 0.85, alpha: 1.0).cgColor
    var gradientColorTwo : CGColor = UIColor(white: 0.95, alpha: 1.0).cgColor
    
    
    var layerGradient : CAGradientLayer!
    
    func addGradientLayer()  -> CAGradientLayer{
        
        
        if self.layerGradient == nil {
            self.layerGradient = CAGradientLayer()
            
            self.layerGradient.frame = self.bounds
            self.layerGradient.startPoint = CGPoint(x: 0.0, y: 1.0)
            self.layerGradient.endPoint = CGPoint(x: 1.0, y: 1.0)
            self.layerGradient.colors = [gradientColorOne, gradientColorTwo, gradientColorOne]
            self.layerGradient.locations = [0.0, 0.5, 1.0]
        }
        
        self.layer.addSublayer(self.layerGradient)
        
        
        return self.layerGradient
    }
    
    func addAnimation() -> CABasicAnimation {
       
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [-1.0, -0.5, 0.0]
        animation.toValue = [1.0, 1.5, 2.0]
        animation.repeatCount = .infinity
        animation.duration = 0.9
        return animation
    }
    
    func startAnimating() {
        let animation = addAnimation()
        self.isHidden = false
        self.addGradientLayer().add(animation, forKey: animation.keyPath)
    }
    
    func stopAnimating() {
        self.isHidden = true
        if self.layerGradient != nil {
            self.layerGradient.removeFromSuperlayer()
        }
    }
}


class ShimmerLabel: UILabel {

    var gradientColorOne : CGColor = UIColor(white: 0.85, alpha: 1.0).cgColor
    var gradientColorTwo : CGColor = UIColor(white: 0.95, alpha: 1.0).cgColor
    
    
    var layerGradient : CAGradientLayer!
    
    func addGradientLayer()  -> CAGradientLayer{
        
        
        if self.layerGradient == nil {
            self.layerGradient = CAGradientLayer()
            
            self.layerGradient.frame = self.bounds
            self.layerGradient.startPoint = CGPoint(x: 0.0, y: 1.0)
            self.layerGradient.endPoint = CGPoint(x: 1.0, y: 1.0)
            self.layerGradient.colors = [gradientColorOne, gradientColorTwo, gradientColorOne]
            self.layerGradient.locations = [0.0, 0.5, 1.0]
        }
        
        self.layer.addSublayer(self.layerGradient)
        
        
        return self.layerGradient
    }
    
    func addAnimation() -> CABasicAnimation {
       
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [-1.0, -0.5, 0.0]
        animation.toValue = [1.0, 1.5, 2.0]
        animation.repeatCount = .infinity
        animation.duration = 0.9
        return animation
    }
    
    func startAnimating() {
        let animation = addAnimation()       
        self.addGradientLayer().add(animation, forKey: animation.keyPath)
    }
    
    func stopAnimating() {
        
        self.layerGradient.removeFromSuperlayer()
    }

}
