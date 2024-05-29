//
//  DropDownBase.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 22/12/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import Foundation
import UIKit

class DropDownBase: UITextField {
    
    lazy var dropDown: DropDown = {
        let dd = updateDropDown()
        return dd
    }()
    
    lazy var dataSource: [Any] = []

    var selectionHandler: ((Int, Any) -> Void)?
    let padding = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 30)
    
    // MARK: - Init -
    override func becomeFirstResponder() -> Bool {
        let didBecomeFirstResponder = super.becomeFirstResponder()
        if didBecomeFirstResponder {
            resignFirstResponder() // Prevent the keyboard from appearing
            dropDown.show() // Show your dropdown
        }
        return false // Return false to indicate that we didn't become the first responder
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupDropdown()
        setupRightView()
    }
    
    // MARK: - Methods -
    private func setupDropdown() {
        dropDown.anchorView = self
        dropDown.bottomOffset = CGPoint(x: 0, y: self.bounds.height + 4)
        // appearence
        setAppearence()
        // Customize data source
        dropDown.dataSource = dataSource
        dropDown.selectRow(at: 0)
        dropDown.selectionAction = { [unowned self] (index: Int, item: Any) in
            self.selectionHandler?(index, item)
        }
    }
    
    private func setAppearence() {
        // Customize dropdown appearance
        dropDown.backgroundColor = UIColor.white
        dropDown.textColor = UIColor.black
        dropDown.cornerRadius = updateCornerRadius()
        dropDown.selectionBackgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        dropDown.direction = .any
    }
    
    func updateCornerRadius() -> CGFloat {
        return 3.0
    }
    
    private func setupRightView() {
        let rightView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: self.bounds.height))
        let imageView = UIImageView(image: UIImage(named: "arrow_down"))
        imageView.tintColor = .darkGray
        imageView.contentMode = .scaleAspectFit
        imageView.frame = rightView.bounds
        rightView.addSubview(imageView)
        self.rightView = rightView
        self.rightViewMode = .always
    }
    
    func updateDropDown() -> DropDown {
        return DropDown()
    }
}
