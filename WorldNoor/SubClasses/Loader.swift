//
//  Loader.swift
//  WorldNoor
//
//  Created by Muhammad Asher on 27/05/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit
import Lottie

final public class Loader {
    static func startLoading() {
        let window = UIApplication.shared.windows.first(where: {$0.isKeyWindow})
        guard let bounds = window?.bounds else {
            fatalError("Bounds are not found")
        }
        // create lottie animation
        let animationView = AnimationView()
        let path = Bundle.main.path(forResource: "WNLoading", ofType: "json") ?? ""
        animationView.animation = Animation.filepath(path)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.play()
        animationView.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
        animationView.center = bounds.center
        let spinnerView = UIView.init(frame: bounds)
        spinnerView.backgroundColor = .black.withAlphaComponent(0.15)
        if window?.viewWithTag(1000)?.superview == nil {
            DispatchQueue.main.async {
                spinnerView.addSubview(animationView)
                spinnerView.tag = 1000
                window?.addSubview(spinnerView)
            }
        }
    }
    
    static func stopLoading() {
        let window = UIApplication.shared.windows.first(where: {$0.isKeyWindow})
        DispatchQueue.main.async {
            window?.viewWithTag(1000)?.removeFromSuperview()
        }
    }
}
