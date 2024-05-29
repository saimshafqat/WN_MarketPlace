//
//  ExtensionSwiftMessages.swift
//  WorldNoor
//
//  Created by Asher Azeem on 27/03/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import Foundation

extension SwiftMessages {
    
    static func showMessagePopup(theme: Theme = .success, title: String = .emptyString, body: String = .emptyString) {
        let warning = MessageView.viewFromNib(layout: .cardView)
        warning.configureTheme(theme)
        warning.configureDropShadow()
        warning.configureContent(title: title, body: body)
        warning.button?.isHidden = true
        // Hide when message view tapped
        warning.tapHandler = { _ in SwiftMessages.hide() }
        var warningConfig = SwiftMessages.defaultConfig
        warningConfig.presentationContext = .window(windowLevel: UIWindow.Level.statusBar)
        warningConfig.interactiveHide = false
        warning.buttonTapHandler = { _ in SwiftMessages.hide() }
        SwiftMessages.show(config: warningConfig, view: warning)
    }
    
    static func apiServiceError(error: Error) {
        if error is ErrorModel {
            if let error = error as? ErrorModel, let errorMessage = error.meta?.message {
                SwiftMessages.showMessagePopup(theme: .error, title: "Failed", body: errorMessage)
            }
        } else {
            SwiftMessages.showMessagePopup(theme: .error, title: "Failed", body: Const.networkProblemMessage.localized())
        }
    }
}
