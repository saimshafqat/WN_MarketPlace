//
//  MPProductDetailMeetupMapCell.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 06/03/24.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit
import GoogleMaps

@objc(MPProductDetailMeetupMapCell)
class MPProductDetailMeetupMapCell: SSBaseCollectionCell {
    
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var mapView: GMSMapView?
    
    var googleMapUtility: GoogleMapUtility?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        googleMapUtility = GoogleMapUtility(mapView: mapView)
    }
    
    override func configureCell(_ cell: Any!, atIndex thisIndex: IndexPath!, with object: Any!) {
        if let obj = object as? MpProductDetailModel {
            addressLabel.text = obj.address
            LogClass.debugLog(obj.lat)
            LogClass.debugLog(obj.lng)
            let latitude = Double(obj.lat) ?? 0.0
            let longitude = Double(obj.lng) ?? 0.0
            
            // Load the map at set latitude/longitude and zoom level
            let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: 11)
            mapView?.camera = camera
            mapView?.delegate = self
            
            // Create a circle on the map
            let circleCenter = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let circ = GMSCircle(position: circleCenter, radius: 2000)  // radius in meters
            
            circ.fillColor = UIColor(red: 0.35, green: 0, blue: 0, alpha: 0.05)
            circ.strokeColor = UIColor.blueColor
            circ.strokeWidth = 0.8
            circ.map = mapView // Add circle to your map view in the UI
            // let coordinates = CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude))
            // self.googleMapUtility?.configureMapView(on: coordinates)
        }
    }
}

extension MPProductDetailMeetupMapCell: GMSMapViewDelegate {
    
}

class GoogleMapUtility {
    
    weak var mapView: GMSMapView?
    
    init(mapView: GMSMapView?) {
        self.mapView = mapView
    }
    
    /***************
     * - Description
     *   It will update map view after getting locatio, setup camera view and display marke on map
     */
    func configureMapView(on location: CLLocationCoordinate2D?) {
        if let location {
            print("Lattitude \(location.latitude)")
            print("Logitude \(location.longitude)")
            setMapCameraPosition(on: location)
            drawMapMarker(on: location)
            drawBubble(on: location)
        }
    }
    
    /***************
     * - Description
     *   camera setup
     */
    func setMapCameraPosition(on coordinate: CLLocationCoordinate2D) {
        let camera = GMSCameraPosition(latitude: coordinate.latitude, longitude: coordinate.longitude, zoom: 18)
        let after: DispatchTime = .now() + 1.0
        DispatchQueue.main.asyncAfter(deadline: after) {
            self.mapView?.animate(to: camera)
        }
    }
    
    /***************
     * - Description
     *   draw marker on google map
     */
    func drawMapMarker(on coordinate: CLLocationCoordinate2D) {
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
        marker.map = mapView
    }
    
    func drawBubble(on coordinate: CLLocationCoordinate2D) {
        // Create a circle on the map
        let circleCenter = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let circ = GMSCircle(position: circleCenter, radius: 2000)  // radius in meters
        circ.fillColor = UIColor(red: 0.35, green: 0, blue: 0, alpha: 0.05)
        circ.strokeColor = UIColor.blueColor
        circ.strokeWidth = 0.8
        circ.map = mapView // Add circle to your map view in the UI
    }
}
