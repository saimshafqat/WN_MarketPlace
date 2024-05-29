//
//  AppDelegate.swift
//  WorldNoor
//
//  Created by Raza najam on 9/3/19.
//  Copyright © 2019 Raza najam. All rights reserved.
//
//  let BaseUtrl = "http://192.168.0.137/request.php/"

import Foundation

final class AppConfigurations {
    let HeaderToken = "77a75176-6f0a-481b-adca-331a0ba694ad"
    // Staging
//    let BaseUrl = "https://staging.worldnoor.com/api/"
//    let BaseUrlMedia = "https://media.worldnoor.com/api/"
//    let BaseUrlNodeApi = "https://staging-nodeapi.worldnoor.com/api/"
//    let BaseUrlSocket = "https://staging-nodeapi.worldnoor.com"
    //Live
    let BaseUrl = "https://worldnoor.com/api/"
    let BaseUrlSocket = "https://nodeapi2.worldnoor.com"
    let BaseUrlNodeApi = "https://nodeapi2.worldnoor.com/api/"
    let BaseUrlMedia = "https://media.worldnoor.com/api/"
    
    let MPBaseUrl = "https://marketplace.worldnoor.com/api/"    
    
    //     let BaseUrl = "https://staging.worldnoor.com/api/"
        // let BaseUrlSocket = "https://nodeapi.worldnoor.com"
    let BaseUrlLiveStreaming = "rtmp://Antmedia-RTMP-LB-ff626617008e48cc.elb.us-west-1.amazonaws.com/WNLive/"
    static let mizdahUrl:String = "https://room-server.mizdah.com/"
    
    
    let BaseUrlStream = "https://streaming.worldnoor.com:3000/api/"
    let LiscenseLink = "https://worldnoor.com/eula.html"
    let privacyLink = "https://worldnoor.com/privacy-policy"
    
    let MarketPlaceSocketURL = "https://marketplace.worldnoor.com"
    
    //PreLive
    //    let BaseUrl = "https://testing.worldnoor.com/api/"
    //    let BaseUrlSocket = "https://nodeapi-testing.worldnoor.com/"
    //    let BaseUrlNodeApi = "https://nodeapi-testing.worldnoor.com/"
    //        let BaseUrlMedia = "https://media-testing.worldnoor.com/api/"
    //    let BaseUrlLiveStreaming = "rtmp://Antmedia-RTMP-LB-ff626617008e48cc.elb.us-west-1.amazonaws.com/WNTesting/"
}
