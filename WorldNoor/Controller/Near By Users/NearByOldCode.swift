////
////  NearByUsersVC.swift
////  WorldNoor
////
////  Created by apple on 3/27/20.
////  Copyright © 2020 Raza najam. All rights reserved.
////
//
//import UIKit
//import MapKit
//import CoreLocation
//import FittedSheets
//
//class NearByUsersVC: UIViewController, CLLocationManagerDelegate  {
//    
//    @IBOutlet var tbleViewNearUser : UITableView!
//    
////    @IBOutlet weak var map: MKMapView!
//    
//    var arrayNearUser = [NearUserModel]()
//    var sheetController = SheetViewController()
//    
//    var isAPICall = false
//    
//    var pageNumber = 1
//    
//    var timerMain = Timer.init()
//    var newRadious : Float = 20.0
//    
//    var placeLngP = ""
//    var placeLatP = ""
//    var userLngP = ""
//    var userLatP = ""
//    
//    var isMaleP = ""
//    var InterestP = ""
//    
//    @IBOutlet weak var lblHeading: UILabel!
//    @IBOutlet weak var viewNoUser: UIView!
////    @IBOutlet weak var cstMapHeight: NSLayoutConstraint!
////    @IBOutlet weak var mapView: UIView!
//    var locationManager: CLLocationManager!
//
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.title = "People Nearby".localized()
////        self.map.delegate = self
//        
//        locationManager = CLLocationManager()
//        self.tbleViewNearUser.register(UINib.init(nibName: "NearUserCell", bundle: nil), forCellReuseIdentifier: "NearUserCell")
//        self.tbleViewNearUser.register(UINib.init(nibName: "NearUserRangeCell", bundle: nil), forCellReuseIdentifier: "NearUserRangeCell")
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        self.lblHeading.text = "Connect with people near you".localized()
//        if self.arrayNearUser.count == 0 {
//            self.arrayNearUser.removeAll()
//            self.pageNumber = 1
//            
//            if (CLLocationManager.locationServicesEnabled())
//            {
//                locationManager.delegate = self
//                locationManager.desiredAccuracy = kCLLocationAccuracyBest
//                locationManager.requestAlwaysAuthorization()
//                locationManager.startUpdatingLocation()
//            }
//            
//            self.navigationController?.removeRighttButton(self)
//            self.navigationController?.addRightButton(self, selector: #selector(self.filterAction), image: UIImage.init(named: "NearByfilters")!)
//            
//            if CLLocationManager.locationServicesEnabled() {
//                
//                
//                switch CLLocationManager.authorizationStatus() {
//                
//                case .notDetermined, .restricted:
//                    LogClass.debugLog("restricted")
//                case  .denied:
//                    self.ShowAlertWithCompletaionNew(title: "Open setting for change location permission.", message: "", isError: false, DismissButton: "Cancel", AcceptButton: "Open Setting") { (pStatus) in
//                        if pStatus {
//                            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
//                                return
//                            }
//                            
//                            if UIApplication.shared.canOpenURL(settingsUrl) {
//                                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
//
//                                })
//                            }
//                        }
//                        
//                        self.navigationController?.popViewController(animated: true)
//                    }
//                case .authorizedAlways, .authorizedWhenInUse:
//                    LogClass.debugLog("authorizedAlways")
//                }
//                
//                
//            }else {
//                
//            }
//            
//        }
//        
//        
//        
//        
//    }
//    
//    @objc func filterAction() {
//        
//       
//       
////
//        let filterController = self.GetView(nameVC: "FilterUsersVC", nameSB: "EditProfile") as! FilterUsersVC
//        filterController.delegate = self
//        self.sheetController = SheetViewController(controller: filterController, sizes: [.fixed(500)])
//        self.sheetController.overlayColor = UIColor.black.withAlphaComponent(0.3)
//        self.sheetController.extendBackgroundBehindHandle = true
//        self.sheetController.topCornersRadius = 20
//        self.present(self.sheetController, animated: false, completion: nil)
//    }
//    
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        if let location = locations.last{
//            
//            self.userLatP = String(location.coordinate.latitude)
//            self.userLngP = String(location.coordinate.longitude)
//            self.locationManager.stopUpdatingLocation()
//            timerMain.invalidate()
//            
//            
//            timerMain = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(getNearUSer), userInfo: nil, repeats: false)
//        }
//    }
//    
//    @objc func getNearUSer(){
//        self.viewNoUser.isHidden = true
//        if isAPICall {
//            return
//        }
//        
//
//        
//        isAPICall = true
////        SharedManager.shared.showOnWindow()
//        Loader.startLoading()
//        var parameters = ["action": "search/people_nearby","token": SharedManager.shared.userToken() , "circle_radius" : String(newRadious).addDecimalPoints() , "page" : String(pageNumber) , "filters[latitude]" : self.userLatP , "filters[longitude]" : self.userLngP, "fetch_users_by_geo_location":"1"]
//        
//        
//        if self.placeLatP.count > 0 {
//            parameters["filters[latitude]"] = self.placeLatP
//            parameters["filters[longitude]"] = self.placeLngP
//        }
//        
//        if self.isMaleP.count > 0  && self.isMaleP != "all"{
//            parameters["filters[gender]"] = self.isMaleP
//        }
//        
//        if self.InterestP.count > 0 {
//            parameters["filters[interset_ids]"] = self.InterestP
//        }
//        
//
//        RequestManager.fetchDataGet(Completion: { (response) in
////            SharedManager.shared.hideLoadingHubFromKeyWindow()
//            Loader.stopLoading()
//            switch response {
//            case .failure(let error):
//                if error is ErrorModel {
//                    if let error = error as? ErrorModel, let errorMessage = error.meta?.message {
//                        SharedManager.shared.showPopupview(message: errorMessage)
//                    }
//                } else {
//                    SharedManager.shared.showPopupview(message: Const.networkProblemMessage.localized())
//                }
//            case .success(let res):
//                
//                if res is Int {
//                    AppDelegate.shared().loadLoginScreen()
//                } else if let newRes = res as? [[String:Any]] {
//                    for resObj in newRes {
//                        self.isAPICall = false;
//                        self.arrayNearUser.append(NearUserModel.init(fromDictionary: resObj))
//                    }
//                }
//                
//                if self.arrayNearUser.count == 0 {
//                    self.viewNoUser.isHidden = false
//                }
////                self.dropPinOnMap()
//                self.tbleViewNearUser.reloadData()
//            }
//        }, param: parameters)
//    }
//    
////    func dropPinOnMap(){
////
////        var latChoose = 0.0
////        var lngchoose = 0.0
////
////        for indexObj in self.arrayNearUser {
////
////            if indexObj.lat.count > 0 && indexObj.longitude.count > 0{
////
////                if latChoose == 0.0 {
////                    latChoose = Double(indexObj.lat)!
////                    lngchoose = Double(indexObj.longitude)!
////                }
////                let location = CLLocationCoordinate2D(latitude: Double(indexObj.lat)!,longitude: Double(indexObj.longitude)!)
////
////                let annotation = MKPointAnnotation()
////                annotation.coordinate = location
////                annotation.title = indexObj.firstname + " " + indexObj.lastname
////                annotation.subtitle = indexObj.distance_in_km.addDecimalPoints() + "-km from you".localized()
////
////                if indexObj.is_my_friend == "1" {
////                    map.addAnnotation(annotation)
////                }
////            }
////        }
////
////        if latChoose != 0.0 {
////            let center = CLLocationCoordinate2D(latitude: latChoose,longitude: lngchoose)
////
////
////            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03))
////            self.map.setRegion(region, animated: true)
////
////        }
////
////
////        self.tbleViewNearUser.reloadData()
////    }
//    
//    
//    func ShowAlertWithCompletaionNew(title: String = "" , message: String, isError: Bool , DismissButton : String = "No" , AcceptButton : String = "Yes", completion: ((_ status: Bool) -> Void)? = nil) {
//        
//        let alert = UIAlertController(title: title , message: message, preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: DismissButton, style: .default) { action in
//            alert.dismiss(animated: true, completion: nil)
//            completion!(false)
//        })
//        alert.addAction(UIAlertAction(title: AcceptButton, style: .default) { action in
//            alert.dismiss(animated: true, completion: nil)
//            completion!(true)
//        })
//        self.present(alert, animated: true, completion: nil)
//    }
//}
//
//
//extension NearByUsersVC : UITableViewDelegate , UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return self.arrayNearUser.count
//    }
//    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
////        if self.mapView.isHidden {
////            if indexPath.row == 0 {
////                return 0
////            }
////        }
//        
//        return UITableView.automaticDimension
//    }
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        
////        if indexPath.row == 0 {
////
////            guard  let celNear = tableView.dequeueReusableCell(withIdentifier: "NearUserRangeCell", for: indexPath) as? NearUserRangeCell else {
////                      return UITableViewCell()
////                   }
////
////            celNear.lblSearch.text = String(self.arrayNearUser.count) + " " + "Search".localized()
////            celNear.rangeSlider.addTarget(self, action: #selector(self.valueChanged), for: .valueChanged)
////            celNear.rangeSlider.addTarget(self, action: #selector(self.sliderDone), for: .touchUpOutside)
////            celNear.rangeSlider.addTarget(self, action: #selector(self.sliderDone), for: .touchUpInside)
////            return celNear
//            
////        }
//        
//        
//        let index = indexPath.row
//        
//        guard let celNear = tableView.dequeueReusableCell(withIdentifier: "NearUserCell", for: indexPath) as? NearUserCell else {
//                  return UITableViewCell()
//               }
//        
//        if index < self.arrayNearUser.count {
//            celNear.lblUserName.text = self.arrayNearUser[index].firstname + " " + self.arrayNearUser[index].lastname
////            celNear.lblDisctance.text = self.arrayNearUser[index].distance_in_km.addDecimalPoints() + " km from you".localized()
//            celNear.lblDisctance.text = ""
////            celNear.lblDisctance.text = ""
////            celNear.imgViewUSer.sd_imageIndicator = SDWebImageActivityIndicator.gray
////            celNear.imgViewUSer.sd_setImage(with:URL.init(string: self.arrayNearUser[index].profile_image), placeholderImage: UIImage(named: "placeholder.png"))
//            
//            celNear.imgViewUSer.loadImageWithPH(urlMain:self.arrayNearUser[index].profile_image)
//            
//            if self.arrayNearUser[index].friend_status == "friend_not_exist" {
//                celNear.lblFriendStatus.text = "Connect".localized()
//                celNear.viewBG.backgroundColor = UIColor.init(red: 253/255, green: 136/255, blue: 36/255, alpha: 1.0)
//
//            }else if self.arrayNearUser[index].friend_status == "friend_or_my_post" {
//                celNear.lblFriendStatus.text = "Send Message".localized()
//                celNear.viewBG.backgroundColor = UIColor.init(red: 41/255, green: 47/255, blue: 75/255, alpha: 1.0)
//            }else {
//                celNear.lblFriendStatus.text = "Cancel Request".localized()
//                celNear.viewBG.backgroundColor = UIColor.systemRed
//
//            }
////            if self.arrayNearUser[index].is_my_friend == "1" {
////                celNear.lblFriendStatus.text = "Send Message".localized()
////                celNear.viewBG.backgroundColor = UIColor.init(red: 41/255, green: 47/255, blue: 75/255, alpha: 1.0)
////            }else {
////                celNear.lblFriendStatus.text = "Connect".localized()
////                celNear.viewBG.backgroundColor = UIColor.init(red: 253/255, green: 136/255, blue: 36/255, alpha: 1.0)
////            }
//            
//            
//            celNear.viewBG.isHidden = true
//            if self.arrayNearUser[index].can_i_send_fr.count > 0 {
//                if self.arrayNearUser[index].can_i_send_fr == "1" {
//                    celNear.viewBG.isHidden = false
//                }
//            }
//            
//            
//            
//            celNear.btnMessage.tag = index
//            celNear.btnMessage.addTarget(self, action: #selector(self.openMessage), for: .touchUpInside)
//            self.view.labelRotateCell(viewMain: celNear.imgViewUSer)
//        }
//        
//        celNear.selectionStyle = .none
//        return celNear
//    }
//    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if indexPath.row > 0 {
//            self.openProfile(sender: indexPath.row)
//        }
//    }
//    
//    
//    func openProfile(sender : Int){
//        let newDict = [String : Any]()
//        let userModel = SearchUserModel.init(fromDictionary: newDict)
//        userModel.already_sent_friend_req = self.arrayNearUser[sender].already_sent_friend_req
//        userModel.author_name = self.arrayNearUser[sender].author_name
//        userModel.city = self.arrayNearUser[sender].city
//        userModel.country_name = self.arrayNearUser[sender].country_name
//        userModel.is_my_friend = self.arrayNearUser[sender].is_my_friend
//        userModel.profile_image = self.arrayNearUser[sender].profile_image
//        userModel.state_name = ""
//        userModel.user_id = self.arrayNearUser[sender].user_id
//        userModel.username = self.arrayNearUser[sender].author_name
//        userModel.conversation_id = ""
//        
//        
//        let vcProfile = self.GetView(nameVC: "ProfileViewController", nameSB: "PostStoryboard") as! ProfileViewController
//        vcProfile.otherUserID = self.arrayNearUser[sender].user_id
//        vcProfile.otherUserisFriend = self.arrayNearUser[sender].is_my_friend
//        vcProfile.otherUserSearchObj = userModel
//        self.navigationController?.pushViewController(vcProfile, animated: true)
//    }
//    
//    @objc func openMessage(sender : UIButton){
//        self.showProfile(sender: sender.tag)
//    }
//    
//    
//    func showProfile(sender : Int){
//        if self.arrayNearUser[sender].friend_status == "friend_or_my_post" {
////            SharedManager.shared.showOnWindow()
//            Loader.startLoading()
//            let userToken = SharedManager.shared.userToken()
//            let ObjUser = self.arrayNearUser[sender]
//            let memberID:[String] = [ObjUser.user_id]
//            let parameters:NSDictionary = ["action": "conversation/create", "token":userToken, "serviceType":"Node", "conversation_type":"single","member_ids": memberID]
//            
//            
//            RequestManager.fetchDataPost(Completion: { response in
//                switch response {
//                case .failure(let error):
//                    if error is ErrorModel {
//                        if let error = error as? ErrorModel, let errorMessage = error.meta?.message {
//                            SharedManager.shared.showPopupview(message: errorMessage)
//                        }
//                    } else {
//                        SharedManager.shared.showPopupview(message: Const.networkProblemMessage.localized())
//                    }
//                case .success(let res):
//                    
//                    if res is Int {
//                        AppDelegate.shared().loadLoginScreen()
//                    } else if res is String {
//                        SwiftMessages.showMessagePopup(theme: .error, title: "Failed", body: res as? String ?? .emptyString)
//                    } else {
//                        if res is NSDictionary {
//                            let dict = res as! NSDictionary
//                            let conversationID = self.ReturnValueCheck(value: dict["conversation_id"] as Any)
//                            
//                            let moc = CoreDbManager.shared.persistentContainer.viewContext
//                            let objModel = Chat(context: moc)
//                            objModel.profile_image = ObjUser.profile_image
//                            objModel.member_id = ObjUser.user_id
//                            objModel.name = ObjUser.username
//                            objModel.latest_conversation_id = conversationID
//                            objModel.conversation_id = conversationID
//                            objModel.conversation_type = "single"
//                            
//                            let contactGroup = AppStoryboard.PostStoryboard.instance.instantiateViewController(withIdentifier: Const.ChatViewController) as! ChatViewController
//                            contactGroup.conversatonObj = objModel
//                            self.navigationController?.pushViewController(contactGroup, animated: true)
//                            
//                        }
//                    }
//                }
//            }, param:parameters as! [String : Any])
//            
//        }else if self.arrayNearUser[sender].friend_status == "friend_not_exist" {
////            self.sendRequest(userID: self.arrayNearUser[sender].id,sender : sender)
//            self.sendRequest(userID: self.arrayNearUser[sender].id, sender: sender)
//        }else {
////            self.cancelFriendAction(userID: self.arrayNearUser[sender].id)
//            self.cancelFriendAction(userID: self.arrayNearUser[sender].id, sender: sender)
//        }
//    }
//    
//    
//    func cancelFriendAction(userID : String , sender : Int){
//        
////        SharedManager.shared.showOnWindow()
//        Loader.startLoading()
//        let parameters = ["action": "user/cancel_friend_request","token": SharedManager.shared.userToken() , "user_id" : userID]
//        
//        RequestManager.fetchDataPost(Completion: { (response) in
////            SharedManager.shared.hideLoadingHubFromKeyWindow()
//            Loader.stopLoading()
//            switch response {
//            case .failure(let error):
//                if error is ErrorModel {
//                    if let error = error as? ErrorModel, let errorMessage = error.meta?.message {
//                        SharedManager.shared.showPopupview(message: errorMessage)
//                    }
//                } else {
//                    SharedManager.shared.showPopupview(message: Const.networkProblemMessage.localized())
//                }
//            case .success(let res):
//                
//                if res is Int {
//                    AppDelegate.shared().loadLoginScreen()
//                } else if let newRes = res as? [String:Any] {
//                    
//                    self.successOfCancelRequest(sender: sender)
////                    self.feedObj.isAuthorFriendOfViewer = "friend_not_exist"
////                    self.reloadHeaderData()
//                } else if let newRes = res as? String {
//                    self.successOfCancelRequest(sender: sender)
//                    SharedManager.shared.showAlert(message: newRes, view: UIApplication.topViewController()!)
//                }
//            }
//        }, param: parameters)
//    }
//    
//    func successOfCancelRequest(sender:Int){
//        arrayNearUser[sender].friend_status = "friend_not_exist"
//        tbleViewNearUser.reloadData()
//    }
//    
//    func sendRequest(userID : String , sender : Int){
////        SharedManager.shared.showOnWindow()
//        Loader.startLoading()
//        let parameters = ["action": "user/send_friend_request","token": SharedManager.shared.userToken() , "user_id" : userID]
//        
//        RequestManager.fetchDataPost(Completion: { (response) in
////            SharedManager.shared.hideLoadingHubFromKeyWindow()
//            Loader.stopLoading()
//            
//            switch response {
//            case .failure(let error):
//                if error is ErrorModel {
//                    if let error = error as? ErrorModel, let errorMessage = error.meta?.message {
//                        SharedManager.shared.showPopupview(message: errorMessage)
//                    }
//                } else {
//                    SharedManager.shared.showPopupview(message: Const.networkProblemMessage.localized())
//                }
//            case .success(let res):
//                
//                if res is Int {
//                    AppDelegate.shared().loadLoginScreen()
//                } else if let newRes = res as? [String:Any] {
//                    self.arrayNearUser[sender].friend_status = "pending"
//                    self.tbleViewNearUser.reloadData()
//                    
////                    self.feedObj.isAuthorFriendOfViewer = "pending"
////                    self.reloadHeaderData()
//                } else if let newRes = res as? String {
//                                        SwiftMessages.showMessagePopup(theme: .error, title: "Failed", body: newRes)
//                }
//            }
//        }, param: parameters)
//    }
//    
////    @objc func AddOverLayfunction(){
////        self.map.addOverlay(MKCircle(center: self.map.userLocation.coordinate, radius: CLLocationDistance(newRadious * 1000)))
////    }
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        
//        
//        if self.arrayNearUser.count > 0 {
//            if (indexPath.row + 2) == self.arrayNearUser.count - 1 {
//                
//                if self.arrayNearUser.count % 10 == 0 {
//                    self.pageNumber = self.pageNumber + 1
//                    self.getNearUSer()
//                }
//            }
//        }
//    }
//}
//
//
//extension NearByUsersVC : FilterDelegate {
//    func filterapply(placeLat : String , placeLng : String , isMale : String , Interest : String){
//        self.placeLngP = placeLng
//        self.placeLatP = placeLat
//        self.isMaleP = isMale
//        self.InterestP = Interest
//        self.pageNumber = 1
//                
////        if placeLat.count > 0 {
////            self.cstMapHeight.constant = 0
////            self.mapView.isHidden = true
////            self.mapView.frame.size.height = 0.0
////        }else {
////            self.cstMapHeight.constant = 300
////            self.mapView.isHidden = false
////            self.mapView.frame.size.height = 300.0
////        }
//        
//        DispatchQueue.main.async {
//            self.view.layoutSubviews()
//            self.isAPICall = false
//            self.arrayNearUser.removeAll()
//            self.getNearUSer()
//        }
//    }
//}
//
//
////extension NearByUsersVC : MKMapViewDelegate {
//    
////    @objc func sliderDone(sender : UIButton){
////        timerMain.invalidate()
////        self.isAPICall = false;
////        self.arrayNearUser.removeAll()
////        self.pageNumber = 1
////
////        self.map.removeAnnotations(self.map.annotations)
////        timerMain = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(getNearUSer), userInfo: nil, repeats: false)
////    }
//    
////    @objc func valueChanged(sender : UISlider){
////        self.newRadious = sender.value
////        if let cellMain = self.tbleViewNearUser.cellForRow(at: IndexPath.init(row: 0, section: 0)) as? NearUserRangeCell {
////
////            cellMain.lblKM.text = String(self.newRadious).addDecimalPoints(decimalPoint: "0") + " KM"
////            cellMain.lblSearch.text = "0" + " " + "Search".localized()
////        }
////    }
//    
//   
////}
//
//class NearUserCell : UITableViewCell {
//    @IBOutlet var imgViewUSer : UIImageView!
//    
//    @IBOutlet var lblUserName : UILabel!
//    @IBOutlet var lblDisctance : UILabel!
//    
//    @IBOutlet var lblFriendStatus : UILabel!
//    @IBOutlet var btnMessage : UIButton!
//    @IBOutlet var btnProfile : UIButton!
//    @IBOutlet var viewBG : UIView!
//}
//
//class NearUserRangeCell : UITableViewCell {
//    
//    @IBOutlet var rangeSlider : UISlider!
//    
//    @IBOutlet var lblKM : UILabel!
//    @IBOutlet var lblSearch : UILabel!
//}
//
//
