//
//  CustomSlider.swift
//  WorldNoor
//
//  Created by Asher Azeem on 19/04/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit

class CustomSlider: UISlider {
    
    @IBInspectable var trackHeight: CGFloat = 3
    @IBInspectable var highLightTrackHeight: CGFloat = 5

    @IBInspectable var thumbRadius: CGFloat = 6
    @IBInspectable var highLightThumbRadius: CGFloat = 9

    private lazy var thumbView: UIView = {
        let thumb = UIView()
        thumb.backgroundColor = .white//thumbTintColor
        thumb.layer.borderWidth = 0.4
        thumb.layer.borderColor = UIColor.darkGray.cgColor
        return thumb
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let thumb = thumbImage(radius: thumbRadius)
        let hightlightThumb = thumbImage(radius: highLightThumbRadius)
        setThumbImage(thumb, for: .normal)
        setThumbImage(hightlightThumb, for: .highlighted)
    }
    
    private func thumbImage(radius: CGFloat) -> UIImage {
        thumbView.frame = CGRect(x: 0, y: radius / 2, width: radius, height: radius)
        thumbView.layer.cornerRadius = radius / 2
        let renderer = UIGraphicsImageRenderer(bounds: thumbView.bounds)
        return renderer.image { rendererContext in
            thumbView.layer.render(in: rendererContext.cgContext)
        }
    }
    
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        var newRect = super.trackRect(forBounds: bounds)
        let height = self.state == .highlighted ? highLightTrackHeight : trackHeight
        newRect.size.height = height
        return newRect
    }
}
