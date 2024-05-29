//
//  WeatherViewController.swift
//  WorldNoor
//
//  Created by Raza najam on 4/3/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import GooglePlacesSearchController

class WeatherViewController: UIViewController {
    @IBOutlet weak var weatherTableView: UITableView!
    
    
    var arrayWeather = [[String : Any]]()
    var locationinfo : ReversedGeoLocation!
    var imgBaseUrl = "https://openweathermap.org/img/wn/"
    let GoogleMapsAPIServerKey = "AIzaSyBVqyJTLcFZoB46FyL1ulc5_Jhp279XDXA"
    lazy var placesSearchController: GooglePlacesSearchController = {
        let controller = GooglePlacesSearchController(delegate: self,
                                                      apiKey: GoogleMapsAPIServerKey,
                                                      placeType: .all
        )
        return controller
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.weatherTableView.register(UINib.init(nibName: "WeatherCurrentDayCell", bundle: nil), forCellReuseIdentifier: "WeatherCurrentDayCell")
        self.weatherTableView.register(UINib.init(nibName: "WeatherDayCell", bundle: nil), forCellReuseIdentifier: "WeatherDayCell")
        LocationManager.shared.manageLocation()
        self.getCurrentWeather()
        self.manageUI()
    }
    
    func manageUI(){
        let backButton = UIButton(frame: CGRect(x: 0, y: 0, width: 27, height: 22))
        backButton.setImage(UIImage(named: "Search"), for: .normal)
        backButton.addTarget(self, action: #selector(self.searchBtnClicked), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: backButton)
    }
    
    @objc func searchBtnClicked() {
        present(placesSearchController, animated: true, completion: nil)

    }
    

    
    func getCurrentWeather() {
        if LocationManager.shared.latString == "" {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.getCurrentWeather()
            }
        }else {
            self.getWeatherData(lat: LocationManager.shared.latString, lng: LocationManager.shared.lngString)
            
            let location = CLLocation(latitude: Double(LocationManager.shared.latString)!, longitude: Double(LocationManager.shared.lngString)!)

            CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in

                guard let placemark = placemarks!.first else {
                    let errorString = error?.localizedDescription ?? "Unexpected Error"
                    return
                }

                self.locationinfo = ReversedGeoLocation(with: placemark)
                self.weatherTableView.reloadData()
            }
            
        }
    }
    
    func getWeatherData(lat:String, lng:String){
        self.arrayWeather.removeAll()
//        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        let urlMain = "https://api.openweathermap.org/data/2.5/onecall?lat=" + lat + "&lon=" + lng + "&units=metric&exclude=hourly,alerts,hourly,minutely&appid=c67a833418adb0a882567cb32e1b92de"
        RequestManager.fetchDataGetURL(MainURL: urlMain) { (resultMain) in
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            switch resultMain {
            case .failure(let error):
//                if error is String {
                    SharedManager.shared.showAlert(message: Const.networkProblemMessage.localized(), view: self)
//                }
            case .success(let res):

                if let resultCurrent = (res as! [String : AnyObject])["current"] as? [String : Any] {
                    self.arrayWeather.append(resultCurrent)
                    
                }
                
                if let resultDays = (res as! [String : AnyObject])["daily"] as? [[String : Any]] {
                    for indexObj in resultDays {
                        self.arrayWeather.append(indexObj)
                    }
                }
            }
            
            self.weatherTableView.reloadData()
            
        }
    }
}

extension WeatherViewController : UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayWeather.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cellCurrent = tableView.dequeueReusableCell(withIdentifier: "WeatherCurrentDayCell", for: indexPath) as! WeatherCurrentDayCell
            
            var temp = ""
            if let tempValue = self.arrayWeather[indexPath.row]["temp"] as? Double {
                
                temp = String(tempValue).addDecimalPoints() + "ºC ,"
                
                temp = temp + String((tempValue * 9/5) + 32).addDecimalPoints(decimalPoint: "2") + "ºF ,"
                temp = temp + String(tempValue + 273.15).addDecimalPoints(decimalPoint: "2") + "K"

            }
            
            cellCurrent.lblCityName.text = ""
            if self.locationinfo != nil {
                cellCurrent.lblCityName.text = self.locationinfo.formattedAddress
            }
            
            cellCurrent.lblWeather.text = temp
            
            if let weatherValue = self.arrayWeather[indexPath.row]["weather"] as? [[String : Any]] {
                if weatherValue.count > 0 {
                    let valueWeather = weatherValue.first!
                    
                    
                    cellCurrent.lblWeatherType.text = (valueWeather["main"] as! String)
                    
                    let imgUrlString = String(format:"%@/%@.png", self.imgBaseUrl, valueWeather["icon"] as! CVarArg)
              
                    cellCurrent.imgviewIcon.loadImageWithPH(urlMain:imgUrlString)
                    
                }
            }
            
            
            
            return cellCurrent
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherDayCell", for: indexPath) as? WeatherDayCell else {
           return UITableViewCell()
        }
        
        
        if let dayValue = self.arrayWeather[indexPath.row]["dt"] as? Int {
            let dateMain = String(dayValue).dateConvert()
            cell.lblDate.text = dateMain.dateString("EEEE, dd MMM yyyy")
        }
        
        
       if indexPath.row == 1 {
            cell.lblDate.text = "Today".localized()
            
        }
        
        
        if let tempValue = self.arrayWeather[indexPath.row]["temp"] as? [String : Any] {
            if let minValue = tempValue["min"] as? Double {
                var temp = ""
                temp = String(minValue).addDecimalPoints() + "ºC ,"
                
                temp = temp + String((minValue * 9/5) + 32).addDecimalPoints(decimalPoint: "2") + "ºF ,"
                temp = temp + String(minValue + 273.15).addDecimalPoints(decimalPoint: "2") + "K"
                cell.lblMin.text =  temp
            }
            
            if let minValue = tempValue["max"] as? Double {
                
                var temp = ""
                temp = String(minValue).addDecimalPoints() + "ºC ,"
                
                temp = temp + String((minValue * 9/5) + 32).addDecimalPoints(decimalPoint: "2") + "ºF ,"
                temp = temp + String(minValue + 273.15).addDecimalPoints(decimalPoint: "2") + "K"
                cell.lblMax.text =  temp
                
            }
            
        }
        
        if let weatherValue = self.arrayWeather[indexPath.row]["weather"] as? [[String : Any]] {
            if weatherValue.count > 0 {
                let valueWeather = weatherValue.first!
                
                
                cell.lblWeatherType.text = (valueWeather["main"] as! String)
                
                let imgUrlString = String(format:"%@/%@.png", self.imgBaseUrl, valueWeather["icon"] as! CVarArg)
                
                cell.imgviewIcon.loadImageWithPH(urlMain:imgUrlString)
                
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

class WeatherCell:UITableViewCell {
    @IBOutlet weak var dayNamelbl: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var UpTempLbl: UILabel!
    @IBOutlet weak var lowTempLbl: UILabel!    
}


extension WeatherViewController: GooglePlacesAutocompleteViewControllerDelegate {
    func viewController(didAutocompleteWith place: PlaceDetails) {
        placesSearchController.isActive = false
        let lat:String = String(place.coordinate!.latitude)
        let lng:String = String(place.coordinate!.longitude)
        self.getWeatherData(lat: lat, lng: lng)
        let location = CLLocation(latitude: Double(lat)!, longitude: Double(lng)!)

        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in

            guard let placemark = placemarks?.first else {
                let errorString = error?.localizedDescription ?? "Unexpected Error"
                return
            }

            self.locationinfo = ReversedGeoLocation(with: placemark)
            
            
            self.weatherTableView.reloadData()
        }
    }
}


struct ReversedGeoLocation {
    let name: String            // eg. Apple Inc.
    let streetName: String      // eg. Infinite Loop
    let streetNumber: String    // eg. 1
    let city: String            // eg. Cupertino
    let state: String           // eg. CA
    let zipCode: String         // eg. 95014
    let country: String         // eg. United States
    let isoCountryCode: String  // eg. US

    var formattedAddress: String {
        return """
        \(city), \(state)
        \(country)
        """
    }

    // Handle optionals as needed
    init(with placemark: CLPlacemark) {
        self.name           = placemark.name ?? ""
        self.streetName     = placemark.thoroughfare ?? ""
        self.streetNumber   = placemark.subThoroughfare ?? ""
        self.city           = placemark.locality ?? ""
        self.state          = placemark.administrativeArea ?? ""
        self.zipCode        = placemark.postalCode ?? ""
        self.country        = placemark.country ?? ""
        self.isoCountryCode = placemark.isoCountryCode ?? ""
    }
}
