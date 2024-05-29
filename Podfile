# Uncomment the next line to define a global platform for your project
#platform :ios, '11.0'

abstract_target 'BasePods' do
  use_frameworks!
  pod 'Alamofire', '~> 4.9.1'
  pod 'SDWebImage'
  pod 'SwiftLinkPreview'
  pod 'Kingfisher'
  pod 'AlamofireRSSParser'
  # Has its own copy of ShowsKit + ShowWebAuth
  target 'WorldNoor' do
    use_frameworks!
    pod 'SwiftDate', '~> 6.0'
    pod 'FittedSheets', '~> 1.4.5'
    pod 'SDWebImageWebPCoder'
    pod 'CommonKeyboard'
    pod "TLPhotoPicker"
    pod 'Socket.IO-Client-Swift', '~> 16.0.1'
    pod 'SKPhotoBrowser', '~> 6.1.0'
    
    pod 'OAuthSwift', '~> 2.0.0'
    pod 'GooglePlacesSearchController'
    pod 'GooglePlaces', '~> 7.3.0'
    pod 'GoogleMaps', '6.1.0'
    pod 'Google-Maps-iOS-Utils', '3.4.0'
    pod 'Firebase'
    pod 'FirebaseAnalytics'
    pod 'FirebaseMessaging'
    pod 'SwiftKeychainWrapper'
    # pod 'PhoneNumberKit', '~> 3.3'
    pod 'PhoneNumberKit'
    pod 'LFLiveKit'
    pod 'TOCropViewController'
    pod 'SwiftySound'
    #    pod 'RealmSwift', '~> 10.39.1'
    pod 'VersaPlayer' , '~> 3.0.2'
    pod 'CountryPickerView'
    pod 'GoogleAnalytics', '~> 3.21.0'
    pod 'FBSDKShareKit'
    pod 'GoogleSignIn', '~> 7.0'
    # pod 'GoogleAPIClientForREST/PeopleService'
    # pod 'Google-Mobile-Ads-SDK', '~> 7.67.0' old version
    # pod 'Google-Mobile-Ads-SDK', '~> 11.0' ==> current version
    pod 'Google-Mobile-Ads-SDK'
    pod 'FTPopOverMenu'
    pod 'SwiftLint'
    pod "SwiftSiriWaveformView"
    pod 'Cosmos'
    pod 'ActiveLabel'
    pod 'DeviceKit'
    pod 'SwiftSoup'
    pod "SwiftyXMLParser", :git => 'https://github.com/yahoojapan/SwiftyXMLParser.git'
    pod 'FeedKit', '~> 9.0'
    pod 'lottie-ios', '~> 3.2.1'
    pod 'Toast-Swift'
    pod "mediasoup_ios_client", "~> 1.3.5"
    pod 'SwiftyJSON', '~> 4.0'
    pod 'Socket.IO-Client-Swift', '~> 16.0.1'
    pod 'SwiftyRSA'
    pod 'SwiftKeychainWrapper'
    pod 'SwiftEntryKit', '1.2.3'
    pod 'MBProgressHUD', '~> 1.2.0'
    pod 'Charts'
    
    # for marketplace
    pod 'TextFieldEffects'
    # pod 'ImageSlideshow'
    # pod "ImageSlideshow/Kingfisher"
    pod 'Hero'
    pod 'UIView-Shimmer'
    pod 'UIScrollView-InfiniteScroll', '~> 1.3.0'
    
  end
  
  # Has its own copy of ShowsKit + ShowTVAuth
  target 'WorldnoorShare' do
    use_frameworks!
    
  end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      if config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'].to_f < 13.0
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
      end
    end
  end
end
