//
//  OpenMap.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 08/03/24.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit
import CoreLocation

class OpenMaps {
    
    // Presenting Action Sheet with Map Options Like Google And Apple Maps.
    /// - Parameter coordinate: coordinate of destination
    static func presentActionSheetwithMapOption(coordinate: CLLocationCoordinate2D, currentController: UIViewController) {
        let latitude = coordinate.latitude
        let longitude = coordinate.longitude
        
        // Google MAP URL
        let googleURL = "comgooglemaps://?daddr=\(latitude),\(longitude)&directionsmode=driving&zoom=14"
        let googleItem = ("Google Maps", URL(string:googleURL)!)
        
        // Apple MAP URL
        let appleURL = "maps://?daddr=\(latitude),\(longitude)"
        
        var installedNavigationApps = [("Apple Maps", URL(string:appleURL)!)]
        
        if UIApplication.shared.canOpenURL(googleItem.1) {
            installedNavigationApps.append(googleItem)
        }
        
        if installedNavigationApps.count == 1 {
            if let app = installedNavigationApps.first {
                self.openMap(app: app)
            }
            return
        }
        
        // If there are google map install in the device then System will ask choose map application between apple and google map.
        let alert = UIAlertController(title: nil,
                                      message: "Choose application",
                                      preferredStyle: .actionSheet)
        
        for app in installedNavigationApps {
            let button = UIAlertAction(title: app.0,
                                       style: .default, handler: { _ in
                self.openMap(app: app)
            })
            alert.addAction(button)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancel)
        currentController.present(alert, animated: true)
    }
    
    // Open Selected Map
    /// - Parameter app: Selected Map Application Details
    private static func openMap(app: (String, URL)) {
        guard UIApplication.shared.canOpenURL(app.1) else {
            debugPrint("Unable to open the map.")
            return
        }
        UIApplication.shared.open(app.1, options: [:], completionHandler: nil)
    }
}
