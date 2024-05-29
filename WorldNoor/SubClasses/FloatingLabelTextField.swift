//
//  FloatingLabelTextField.swift
//  Demo Alfa
//
//  Created by Muhammad Asher on 17/08/2023.
//

import UIKit
import Foundation

public enum ErrorMessagePlacement {
    case `default`
    case bottom
}

@objc
protocol FloatingLabelTextFieldRightViewDelegate: NSObjectProtocol {
    @objc
    optional func didPressOptionView(_ textField: FloatingLabelTextField)
    
    //    @objc
    //    func didPressRightView(_ textField: FloatingLabelTextField)
    //
    //    @objc
    //    func didPressLeftView(_ textField: FloatingLabelTextField)
}


class FloatingLabelTextField: UITextField {
    
    var rightViewPaddingX: CGFloat = 8
    var leftViewPaddingX: CGFloat = 8
    
    var textPaddingX: CGFloat = 8
    var selectdTitlePaddingX: CGFloat = 8 {
        didSet {
            updateFrames()
        }
    }
    
    var titleFont: UIFont = .systemFont(ofSize: 13)
    var errorFont: UIFont = .systemFont(ofSize: 13)
    
    @IBInspectable var title: String? {
        didSet {
            createTitleLabel()
            titleLabel.sizeToFit()
        }
    }
    @IBInspectable var selectedTitle: String?
    
    @IBInspectable override var placeholder: String? {
        didSet {
            guard let placeholder = placeholder, let font = font else {
                return
            }
            updatePlaceholder(color: floatingPlaceholderColor, placeholder: placeholder, font: font)
        }
    }
    @IBInspectable override var text: String? {
        didSet {
            super.text = text
            updateFrames()
        }
    }
    
    
    // MARK: Colors
    
    fileprivate var cachedTextColor: UIColor?
    
    @IBInspectable override dynamic var textColor: UIColor? {
        set {
            cachedTextColor = newValue
        }
        get {
            return cachedTextColor
        }
    }
    
    @IBInspectable override dynamic var floatingPlaceholderColor: UIColor {
        didSet {
            
        }
    }
    
    @IBInspectable dynamic var titleColor: UIColor = .gray {
        didSet {
            
        }
    }
    
    @IBInspectable dynamic var selectedTitleColor: UIColor = .blue {
        didSet {
            
        }
    }
    
    @IBInspectable dynamic var lineColor: UIColor = .lightGray {
        didSet {
            
        }
    }
    
    @IBInspectable dynamic var selectedLineColor: UIColor = .black {
        didSet {
            
        }
    }
    
    // MARK: Error Colors
    @IBInspectable dynamic var textErrorColor: UIColor = .red {
        didSet {
            
        }
    }
    
    @IBInspectable dynamic var titleErrorColor: UIColor = .red {
        didSet {
            
        }
    }
    
    @IBInspectable dynamic var lineErrorColor: UIColor = .red {
        didSet {
            
        }
    }
    
    @IBInspectable dynamic var errorLabelColor: UIColor = .red {
        didSet {
            
        }
    }
    
    var hasErrorMessage: Bool {return errorMessage != nil && errorMessage != .emptyString}
    @IBInspectable var errorMessage: String? {
        didSet {
            invalidateIntrinsicContentSize()
            errorLabel.text = self.errorMessage
            layoutIfNeeded()
            updateFrames()
        }
    }
    
    var errorMessagePlacement: ErrorMessagePlacement = .default {
        didSet {
            updateTitleColor()
        }
        
    }
    
    
    var isLTRLanguage: Bool = UIApplication.shared.userInterfaceLayoutDirection == .leftToRight {
        didSet {
            updateTextAligment()
        }
    }
    
    var errorLabelAlignment: NSTextAlignment? {
        didSet {
            updateTextAligment()
        }
    }
    
    
    var editingOrSelected: Bool {
        return super.isEditing || isSelected
    }
    
    var titleFadeInDuration: TimeInterval = 0.5
    var titleFadeOutDuration: TimeInterval = 0.0
    
    
    override var intrinsicContentSize: CGSize {
        if errorMessagePlacement == .bottom && hasErrorMessage {
            return CGSize(width: bounds.size.width, height: titleHeight() + textHeight() + errorHeight() + errorTopSpacing())
        } else {
            return CGSize(width: bounds.size.width, height: titleHeight() + textHeight())
        }
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        commonInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        commonInit()
    }
    
    func commonInit() {
        borderStyle = .none
        createLineView()
        createTitleLabel()
        createErrorLabel()
        
        updateTextAligment()
        lineView.layer.borderWidth = 0.5
        updateFrames()
        addTarget(self, action: #selector(editingChanged), for: .editingChanged)
    }
    
    @objc func editingChanged() {
        updateFrames()
    }
    
    func updateFrames() {
        invalidateIntrinsicContentSize()
        updateLabels()
        lineView.frame = lineViewRectForBounds(bounds)
        rightView?.frame = rightViewRect(forBounds: bounds)
        leftView?.frame = leftViewRect(forBounds: bounds)
        updateColors()
    }
    
    fileprivate func titleOrPlaceholder() -> String? {
        guard let title = title ?? placeholder else {
            return nil
        }
        return title
    }
    
    fileprivate func selectedTitleOrTitlePlaceholder() -> String? {
        guard let title = selectedTitle ?? title ?? placeholder else {
            return nil
        }
        return title
    }
    
    fileprivate func updateLabels() {
        guard let titleLabel = titleLabel else {
            return
        }
        
        var titleText: String?
        var errorText: String?
        
        if errorMessagePlacement == .default {
            if hasErrorMessage {
                titleText = errorMessage
            } else {
                if editingOrSelected {
                    titleText = selectedTitleOrTitlePlaceholder()
                    if titleText == nil {
                        titleText = titleOrPlaceholder()
                    }
                } else {
                    titleText = titleOrPlaceholder()
                }
            }
        } else {
            if hasErrorMessage {
                errorText = errorMessage
            }
            if editingOrSelected {
                titleText = selectedTitleOrTitlePlaceholder()
                if titleText == nil {
                    titleText = titleOrPlaceholder()
                }
            } else {
                titleText = titleOrPlaceholder()
            }
        }
        titleLabel.text = titleText
        titleLabel.font = titleFont
        
        errorLabel.text = errorText
        errorLabel.font = errorFont
        updateTitleVisibility()
        updateErrorVisibility()
    }
    
    fileprivate func updateTitleVisibility() {
        let alpha: CGFloat = isTitleVisible() ? 1.0 : 0.0
        let frame: CGRect = titleLabelRect(bounds, editing: isTitleVisible())
        weak var weakSelf = self
        let updateBlock = { () -> Void in
            weakSelf?.titleLabel.alpha = alpha
            weakSelf?.titleLabel.frame = frame
            weakSelf?.updateTitleColor()
        }
        let duration = isErrorVisible() ? titleFadeInDuration : titleFadeOutDuration
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut, animations: {
            updateBlock()
        }) { (completed) in
            
        }
    }
    
    fileprivate func updateErrorVisibility() {
        let alpha: CGFloat = isErrorVisible() ? 1.0 : 0.0
        let frame: CGRect = errorLabelRect(bounds, editing: isErrorVisible())
        weak var weakSelf = self
        let updateBlock = { () -> Void in
            weakSelf?.errorLabel.alpha = alpha
            weakSelf?.errorLabel.frame = frame
        }
        let duration = isErrorVisible() ? titleFadeInDuration : titleFadeOutDuration
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut, animations: {
            updateBlock()
        }) { (completed) in
            
        }
    }
    
    func updateColors() {
        weak var weakSelf = self
        DispatchQueue.main.async {
            weakSelf?.drawBorder()
        }
        
        updateTextColor()
        updateTitleColor()
    }
    
    fileprivate func updateTextColor() {
        if hasErrorMessage {
            super.textColor = textErrorColor
        } else {
            super.textColor = cachedTextColor
        }
    }
    
    fileprivate func updateTitleColor() {
        if hasErrorMessage {
            titleLabel.textColor = titleErrorColor
        } else {
            titleLabel.textColor = isTitleVisible() && isFirstResponder ? selectedTitleColor : titleColor
        }
    }
    
    
    fileprivate func updateTextAligment() {
        if isLTRLanguage {
            textAlignment = .left
            titleLabel.textAlignment = .left
            errorLabel.textAlignment = .left
        } else {
            textAlignment = .right
            titleLabel.textAlignment = .right
            errorLabel.textAlignment = .right
        }
        
        // Override error message default alignment
        if let errorLabelAlignment = errorLabelAlignment {
            errorLabel.textAlignment = errorLabelAlignment
        }
    }
    
    func isTitleVisible() -> Bool {
        if errorMessagePlacement == .default {
            return hasText || hasErrorMessage || isFirstResponder
        } else {
            return hasText || isFirstResponder
        }
    }
    
    func isErrorVisible() -> Bool {
        return hasErrorMessage
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        
        let lineRect = lineViewRectForBounds(bounds)
        
        let rightRect = CGRect.zero //rightViewRect(forBounds: bounds)
        let leftRect = CGRect.zero //leftViewRect(forBounds: bounds)
        
        
        let x = lineRect.origin.x + leftRect.size.width + (leftRect.size == .zero ? textPaddingX : textPaddingX*2)
        let y = lineRect.origin.y
        let width = lineRect.size.width - rightRect.size.width - leftRect.size.width - (rightRect.size == .zero ? textPaddingX : textPaddingX*2) - (leftRect.size == .zero ? textPaddingX : textPaddingX*2)
        let height = lineRect.size.height
        
        let rect = CGRect(x: x, y: y, width: width, height: height)
        
        return rect
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let rect = textRect(forBounds: bounds)
        return rect
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        if isFirstResponder {
            return .zero
        }
        return editingRect(forBounds: bounds)
    }
    
    
    
    func titleLabelRect(_ bounds: CGRect, editing: Bool) -> CGRect {
        var rect: CGRect
        if isLTRLanguage {
            if editing {
                rect = CGRect(x: selectdTitlePaddingX, y: 0, width: titleWidth(), height: titleHeight())
                return rect
            }
            rect = CGRect(x: selectdTitlePaddingX, y: 0, width: titleWidth(), height: titleHeight())
            return rect
        }
        else {
            if editing {
                
                rect = CGRect(x: bounds.size.width - titleWidth() - selectdTitlePaddingX, y: 0, width: titleWidth(), height: titleHeight())
                return rect
            }
            rect = CGRect(x: bounds.size.width - titleWidth() - selectdTitlePaddingX, y: 0, width: titleWidth(), height: titleHeight())
            return rect
        }
    }
    
    func errorLabelRect(_ bounds: CGRect, editing: Bool) -> CGRect {
        if errorMessagePlacement == .default {
            return CGRect.zero
        } else {
            let rect = lineViewRectForBounds(bounds)
            let originY = rect.maxY + errorTopSpacing()
            let errorRect = CGRect(x: 0, y: originY, width: bounds.size.width, height: errorHeight())
            return errorRect
        }
    }
    
    func lineViewRectForBounds(_ bounds: CGRect) -> CGRect {
        let rect: CGRect
        if hasErrorMessage {
            rect = CGRect(x: 0, y: titleHeight()/2, width: bounds.size.width, height: super.textRect(forBounds: bounds).height - titleHeight()/2 - errorHeight() - errorTopSpacing())
        }
        else {
            rect = CGRect(x: 0, y: titleHeight()/2, width: bounds.size.width, height: super.textRect(forBounds: bounds).height - titleHeight()/2)
        }
        return rect
    }
    
    func titleHeight() -> CGFloat {
        if let titleLabel = titleLabel,
           let font = titleLabel.font {
            return font.lineHeight
        }
        return 15.0
    }
    
    func titleWidth() -> CGFloat {
        if let titleLabel = titleLabel, let text = titleLabel.text, !text.isEmpty {
            titleLabel.textAlignment = .center
            return titleLabel.width(titleHeight(), font: titleLabel.font) + 8
        }
        return 0
    }
    
    func errorTopSpacing() -> CGFloat {
        if let errorLabel = errorLabel,
           let _ = errorLabel.font {
            return 2
        }
        return 0.0
    }
    
    func errorHeight() -> CGFloat {
        if let errorLabel = errorLabel,
           let _ = errorLabel.font {
            //            return font.lineHeight
            return errorLabel.height(errorLabel.bounds.width)
        }
        return 15.0
    }
    
    func textHeight() -> CGFloat {
        guard let font = self.font else {
            return 0.0
        }
        
        return font.lineHeight + 20.0
    }
    
    var titleLabel: UILabel!
    var errorLabel: UILabel!
    var lineView: UIView!
    
    fileprivate func createTitleLabel() {
        guard let titleLabel = titleLabel else {
            let titleLabel = UILabel()
            titleLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            titleLabel.font = titleFont
            titleLabel.alpha = 0.0
            titleLabel.textColor = titleColor
            
            addSubview(titleLabel)
            self.titleLabel = titleLabel
            return
        }
        
        self.titleLabel = titleLabel
    }
    
    fileprivate func createErrorLabel() {
        guard let errorLabel = errorLabel else {
            let errorLabel = UILabel()
            errorLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            errorLabel.font = errorFont
            errorLabel.alpha = 0.0
            errorLabel.textColor = errorLabelColor
            errorLabel.numberOfLines = 0
            
            addSubview(errorLabel)
            self.errorLabel = errorLabel
            return
        }
        self.errorLabel = errorLabel
    }
    
    fileprivate func createLineView() {
        
        guard let lineView = lineView else {
            let lineView = UIView()
            lineView.isUserInteractionEnabled = false
            self.lineView = lineView
            lineView.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
            addSubview(lineView)
            return
        }
        
        sendSubviewToBack(lineView)
    }
    
    var path: UIBezierPath? = nil
    
    func drawBorder() {
        CATransaction.begin()
        lineView.layer.borderColor = UIColor.clear.cgColor
        let layer : CAShapeLayer = CAShapeLayer()
        
        var strokeColor: CGColor {
            if hasErrorMessage {
                return lineErrorColor.cgColor
            }
            else if isFirstResponder {
                return selectedLineColor.cgColor
            }
            else {
                return lineColor.cgColor
            }
        }
        
        layer.strokeColor = strokeColor
        
        layer.lineWidth = lineView.layer.borderWidth
        layer.fillColor = UIColor.clear.cgColor
        
        let lineRect = lineViewRectForBounds(bounds)
        
        let pointsMargin: CGFloat = 8
        let p0 = CGPoint(x: selectdTitlePaddingX, y: 0)
        let p1 = CGPoint(x: pointsMargin, y: p0.y)
        let p2 = CGPoint(x: 0, y: 0) // arc
        let p3 = CGPoint(x: p2.x, y: pointsMargin)
        let p4 = CGPoint(x: p3.x, y: lineRect.size.height - pointsMargin)
        let p5 = CGPoint(x: p4.x, y: lineRect.size.height) // arc
        let p6 = CGPoint(x: p5.x + pointsMargin, y: lineRect.size.height)
        let p7 = CGPoint(x: lineRect.size.width - pointsMargin, y: p6.y)
        let p8 = CGPoint(x: p7.x + pointsMargin, y: p7.y) // arc
        let p9 = CGPoint(x: p8.x, y: lineRect.size.height - pointsMargin)
        let p10 = CGPoint(x: p9.x, y: pointsMargin)
        let p11 = CGPoint(x: p10.x, y: p10.y - pointsMargin) // arc
        let p12 = CGPoint(x: lineRect.size.width - pointsMargin, y: p11.y)
        
        let p13 = isTitleVisible() ? CGPoint(x: p0.x + titleWidth(), y: p12.y) : CGPoint(x: titleLabel.frame.origin.x, y: p12.y)
        
        let path = UIBezierPath()
        
        path.move(to: p0)
        path.addLine(to: p1)
        path.addCurve(to: p3, controlPoint1: p1, controlPoint2: p2)
        path.addLine(to: p3)
        
        path.addLine(to: p4)
        path.addCurve(to: p6, controlPoint1: p4, controlPoint2: p5)
        path.addLine(to: p6)
        
        path.addLine(to: p7)
        path.addCurve(to: p9, controlPoint1: p7, controlPoint2: p8)
        path.addLine(to: p9)
        
        path.addLine(to: p10)
        path.addCurve(to: p12, controlPoint1: p10, controlPoint2: p11)
        path.addLine(to: p13)
        
        layer.path = path.cgPath
        
        let animation : CABasicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0.0
        animation.toValue = 1.0
        
        animation.duration = 0.0
        animation.speed = 500
        
        layer.add(animation, forKey: "myStroke")
        CATransaction.commit()
        
        for layer in lineView.layer.sublayers ?? [] {
            layer.removeFromSuperlayer()
        }
        
        lineView.layer.addSublayer(layer)
    }
    
    
    
    // MARK: RightView
    weak var floatingLabelTextFieldRightViewDelegate: FloatingLabelTextFieldRightViewDelegate?
    
    open override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        guard let _ = self.rightView else {
            return .zero
        }
        
        let max: CGFloat = 20
        
        var superRect = super.rightViewRect(forBounds: bounds)
        
        if superRect.width > max {
            superRect.size = CGSize(width: max, height: superRect.height)
        }
        
        if superRect.height > max {
            superRect.size = CGSize(width: superRect.width, height: max)
        }
        
        let x = superRect.origin.x - rightViewPaddingX
        let y = lineView.center.y - superRect.size.height/2
        let width = superRect.size.width
        let height = superRect.size.height
        
        let rect = CGRect(x: x, y: y, width: width, height: height)
        return rect
    }
    
    open override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        guard let _ = leftView else {
            return .zero
        }
        let max: CGFloat = 20
        
        var superRect = super.leftViewRect(forBounds: bounds)
        
        if superRect.width > max {
            superRect.size = CGSize(width: max, height: superRect.height)
        }
        
        if superRect.height > max {
            superRect.size = CGSize(width: superRect.width, height: max)
        }
        
        
        let x = superRect.origin.x + leftViewPaddingX
        let y = lineView.center.y - superRect.size.height/2
        let width = superRect.size.width
        let height = superRect.size.height
        
        let rect = CGRect(x: x, y: y, width: width, height: height)
        return rect
    }
    
    @IBInspectable open override var rightView: UIView?  {
        didSet {
            if let rightView = rightView {
                let max: CGFloat = 20
                
                if rightView.bounds.width > max {
                    rightView.bounds.size = CGSize(width: max, height: rightView.bounds.height)
                }
                
                if rightView.bounds.height > max {
                    rightView.bounds.size = CGSize(width: rightView.bounds.width, height: max)
                }
                
                bringSubviewToFront(rightView)
                rightViewMode = .always
                let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didPressOptionView))
                tap.cancelsTouchesInView = false
                rightView.isUserInteractionEnabled = true
                rightView.addGestureRecognizer(tap)
            }
            else {
                rightViewMode = .never
            }
        }
    }
    
    @IBInspectable open override var leftView: UIView?  {
        didSet {
            if let leftView = leftView {
                let max: CGFloat = 20
                
                if leftView.bounds.width > max {
                    leftView.bounds.size = CGSize(width: max, height: leftView.bounds.height)
                }
                
                if leftView.bounds.height > max {
                    leftView.bounds.size = CGSize(width: leftView.bounds.width, height: max)
                }
                
                bringSubviewToFront(leftView)
                leftViewMode = .always
                let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didPressOptionView))
                tap.cancelsTouchesInView = false
                leftView.isUserInteractionEnabled = true
                leftView.addGestureRecognizer(tap)
            }
            else {
                leftViewMode = .never
            }
        }
    }
    
    @objc func didPressOptionView() {
        floatingLabelTextFieldRightViewDelegate?.didPressOptionView?(self)
    }
    
    func setOptionView(view: UIView? = nil, imageName: String) {
        let optionView: UIView
        
        let max: CGFloat = 20
        
        if let view = view {
            optionView = view
        }
        else {
            let imageView = UIImageView(image: UIImage(named: imageName))
            imageView.contentMode = .scaleAspectFit
            imageView.clipsToBounds = true
            
            if imageView.bounds.width > max {
                imageView.bounds.size = CGSize(width: max, height: imageView.bounds.height)
            }
            
            if imageView.bounds.height > max {
                imageView.bounds.size = CGSize(width: imageView.bounds.width, height: max)
            }
            
            optionView = imageView
        }
        
        if isLTRLanguage {
            rightView = optionView
            leftView = UIView(frame: .zero)
        }
        else {
            rightView = UIView(frame: .zero)
            leftView = optionView
        }
        
        super.leftView?.frame = leftView?.frame ?? .zero
        super.rightView?.frame = rightView?.frame ?? .zero
        super.leftView?.bounds = leftView?.bounds ?? .zero
        super.rightView?.bounds = rightView?.bounds ?? .zero
        
        weak var weakSelf = self
        DispatchQueue.main.async {
            weakSelf?.layoutIfNeeded()
        }
    }
}

private var vtextFieldPlaceholderColor: UIColor = .gray

extension UITextField {
    @IBInspectable var floatingPlaceholderColor: UIColor {
        get {
            return vtextFieldPlaceholderColor
        }
        set {
            guard let placeholder = placeholder, let font = font else {
                return
            }
            updatePlaceholder(color: newValue, placeholder: placeholder, font: font)
        }
    }
    
    func updatePlaceholder(color: UIColor, placeholder: String, font: UIFont) {
        vtextFieldPlaceholderColor = color
        attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor: vtextFieldPlaceholderColor, NSAttributedString.Key.font: font
                                                                                    ])
    }
}

extension UILabel {
    
    func height(_ width: CGFloat) -> CGFloat {
        if let text = self.text, let font = self.font {
            let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
            let boundingBox = text.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
            
            return ceil(boundingBox.height)
        }
        return 0
    }
    
    func width(_ height: CGFloat, font: UIFont) -> CGFloat {
        if let text = self.text, let font = self.font {
            let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
            let boundingBox = text.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
            
            return ceil(boundingBox.width)
        }
        return 0
    }
    
}
