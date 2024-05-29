//
//  WeatherCell.swift
//  WorldNoor
//
//  Created by apple on 10/7/21.
//  Copyright © 2021 Raza najam. All rights reserved.
//

import Foundation
import UIKit

class WeatherDayCell : UITableViewCell {
    @IBOutlet var imgviewIcon : UIImageView!
    
    @IBOutlet var lblDate : UILabel!
    @IBOutlet var lblMin : UILabel!
    @IBOutlet var lblMax : UILabel!
    @IBOutlet var lblWeatherType : UILabel!
    
}


class WeatherCurrentDayCell : UITableViewCell {
    @IBOutlet var imgviewIcon : UIImageView!
    
    @IBOutlet var lblCityName : UILabel!
    @IBOutlet var lblWeather : UILabel!
    @IBOutlet var lblWeatherType : UILabel!
    
}
