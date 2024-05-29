//
//  ExtensionViewController.swift
//  WorldNoor
//
//  Created by Muhammad Asher on 17/05/2023.
//

import UIKit
import FittedSheets
import Toast_Swift

enum MessageType {
    
    case success
    case error
    case warning
    
    var colorSelection: UIColor {
        switch self {
        case .success:
            return UIColor(red: 97/255, green: 160/255, blue: 23/255, alpha: 1)
        case .error:
            return UIColor(red: 248/255, green: 66/255, blue: 48/255, alpha: 1)
        case .warning:
            return UIColor(red: 237/255, green: 189/255, blue: 35/255, alpha: 1)
        }
    }
}

extension UIViewController {
    
    /// It will helpful to open bottom sheet to specific controller
    /// - Parameters:
    ///   - currentController: bottom sheet for controller
    ///   - sheetSize: sheet size
    /// - Returns: it will return sheetViewController
    
    
    func openBottomSheet(_ currentController: UIViewController, sheetSize: [SheetSize], animated: Bool = true) {
        let sheetController = SheetViewController(controller: currentController, sizes: sheetSize)
        sheetController.topCornersRadius = 12
        sheetController.overlayColor = UIColor.black.withAlphaComponent(0.3)
        sheetController.extendBackgroundBehindHandle = true
        present(sheetController, animated: animated)
    }
    
    func showToast(with message: String?, color: UIColor = UIColor.black.withAlphaComponent(0.8)) {
        var style = ToastStyle()
        style.backgroundColor = color
        topMostViewController().navigationController?.view.makeToast(message ?? .emptyString, style: style)
    }
    
    func showToast(with message: String, type: MessageType) {
        var style = ToastStyle()
        style.backgroundColor = type.colorSelection
        
        topMostViewController().navigationController?.view.makeToast(message, style: style)
    }
    
    func presentAlert(title: String, message: String, hasTextField: Bool = false, fieldPlacerHodler: String = "", fieldTitle: String = "" , options: String..., completion: @escaping (_ index: Int, _ field: UITextField?) -> Void) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        if hasTextField {
            alertController.addTextField { textField in
                textField.placeholder = fieldPlacerHodler
                textField.text = fieldTitle
            }
        }
        for (index, option) in options.enumerated() {
            alertController.addAction(UIAlertAction.init(title: option, style: .default, handler: { (action) in
                let txtField = alertController.textFields?.first
                completion(index, txtField)
            }))
        }
        topMostViewController().present(alertController, animated: true, completion: nil)
    }
    
    /// Get the top most view in the app
    /// — Returns: It returns current foreground UIViewcontroller
    func topMostViewController() -> UIViewController {
        var topViewController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController
//        var topViewController: UIViewController? = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window?.rootViewController
        while ((topViewController?.presentedViewController) != nil) {
            topViewController = topViewController?.presentedViewController
        }
        return topViewController!
    }

}


extension UIViewController {
    
    func embedViewController(viewController: UIViewController, to containerView: UIView) {
        
        viewController.willMove(toParent: self)
        // Add to containerview
        containerView.addSubview(viewController.view)
        self.addChild(viewController)
        
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            viewController.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            viewController.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            viewController.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            viewController.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        viewController.didMove(toParent: self)
    }
}
