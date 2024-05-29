//
//  HQPagerMenuView.swift
//  HQPagerViewController
//
//  Created by robert pham on 11/10/16.
//  Copyright © 2016 quangpc. All rights reserved.
//

import UIKit

private let switchAnimationDuration: TimeInterval = 0.3
private let highlighterAnimationDuration: TimeInterval = switchAnimationDuration / 2

public struct HQPagerMenuViewItemProvider {
    public var title: String
    public var normalImage: UIImage?
    public var selectedImage: UIImage?
    public var selectedBackgroundColor: UIColor?
    
    public init(title: String, normalImage: UIImage?, selectedImage: UIImage?, selectedBackgroundColor: UIColor?) {
        self.title = title
        self.normalImage = normalImage
        self.selectedImage = selectedImage
        self.selectedBackgroundColor = selectedBackgroundColor
    }
}

public protocol HQPagerMenuViewDataSource: class {
    func numberOfItems(inPagerMenu menuView: HQPagerMenuView)-> Int
    func pagerMenuView(_ menuView: HQPagerMenuView, itemAt index: Int)-> HQPagerMenuViewItemProvider?
}

public protocol HQPagerMenuViewDelegate: class {
    func menuView(_ menuView: HQPagerMenuView, didChangeToIndex index: Int)
}

open class HQPagerMenuView: UIView {
    @IBOutlet var btn1:UIButton!
    @IBOutlet var btn2:UIButton!
    @IBOutlet var btn3:UIButton!
    @IBOutlet var selectionBarView:UIView!
    public var selectedIndex: Int = 0
    open weak var delegate: HQPagerMenuViewDelegate?
    
    @IBAction func tabBtnCalled(_ sender: UIButton) {
        let oldIndex = selectedIndex
        let newIndex = sender.tag
        setSelectedIndex(index: newIndex, animated: true)
        if oldIndex != newIndex {
            delegate?.menuView(self, didChangeToIndex: newIndex)
        }
        self.selectionBarView.frame =  CGRect(x: sender.frame.origin.x, y: self.selectionBarView.frame.origin.y, width: self.selectionBarView.frame.size.width, height: self.selectionBarView.frame.size.height)
    }
    
    public func setSelectedIndex(index: Int, animated: Bool) {
        selectedIndex = index
    }
    
    @objc fileprivate func buttonPressed(button: UIButton) {
        let oldIndex = selectedIndex
        let newIndex = button.tag
        setSelectedIndex(index: newIndex, animated: true)
        if oldIndex != newIndex {
            delegate?.menuView(self, didChangeToIndex: newIndex)
        }
    }
}

open class HQRoundCornerView: UIView {
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = bounds.size.height/2
    }
}
