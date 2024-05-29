//
//  LocationManager.swift
//  WorldNoor
//
//  Created by Raza najam on 4/7/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import UIKit
import CoreLocation

class LocationManager: NSObject {
    static let shared = LocationManager()
    
    var locationManager: CLLocationManager = CLLocationManager()
    var latString:String = ""
    var lngString:String = ""
    
    func manageLocation() {
        locationManager = CLLocationManager()
        DispatchQueue.global().async {
            if (CLLocationManager.locationServicesEnabled()) {
                self.locationManager.delegate = self
                self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
                self.locationManager.requestAlwaysAuthorization()
                self.locationManager.startUpdatingLocation()
            }
        }
    }
}


extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last  {
            self.latString = String(location.coordinate.latitude)
            self.lngString = String(location.coordinate.longitude)
            self.locationManager.stopUpdatingLocation()
        }
    }
}
