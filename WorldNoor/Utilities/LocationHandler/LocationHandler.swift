//
//  LocationHandler.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 29/01/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import Foundation
import CoreLocation

protocol LocationHandlerDelegate: AnyObject {
    func locationUpdated(location: CLLocation)
    func locationAuthorizationStatusChanged()
}

class LocationHandler: NSObject {
    
    // MARK: - Properties -
    weak var delegate: LocationHandlerDelegate?
    
    private var locationManager = CLLocationManager()
    
    // MARK: - Init -
    override init() {
        super.init()
        setupLocationManager()
    }
    
    // MARK: - Methods -
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
            
    func checkLocationAuthorization() {
        DispatchQueue.global(qos: .background).async {
            // Perform location authorization check on a background thread
            if CLLocationManager.locationServicesEnabled() {
                switch CLLocationManager.authorizationStatus() {
                case .notDetermined, .restricted:
                    LogClass.debugLog("restricted")
                case .denied:
                    self.showLocationPermissionAlert()
                case .authorizedAlways, .authorizedWhenInUse:
                    LogClass.debugLog("authorizedAlways")
                @unknown default:
                    LogClass.debugLog("Unhandled authorization status")
                }
            }
        }
    }
    
    private func showLocationPermissionAlert() {
        locationAuthorization(status: .denied)
    }
    
    private func locationAuthorization(status: CLAuthorizationStatus) {
        guard status == .denied else { return }
        SharedManager.shared.ShowAlertWithCompletaion(title: Const.locationPermissionTitle, message: .emptyString, isError: false, DismissButton: Const.dismissButtonTitle, AcceptButton: Const.acceptButtonTitle) { [weak self] status in
            guard let self else { return }
            if status {
                Commons.share.canOpenURL(value: UIApplication.openSettingsURLString)
            }
            delegate?.locationAuthorizationStatusChanged()
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationHandler: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Handle location updates
        if let location = locations.last {
            locationManager.stopUpdatingLocation()
            delegate?.locationUpdated(location: location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // Handle authorization status changes
        locationAuthorization(status: status)
    }
}
