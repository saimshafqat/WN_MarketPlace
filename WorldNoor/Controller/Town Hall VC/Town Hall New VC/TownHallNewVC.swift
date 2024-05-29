//
//  TownHallNewVC.swift
//  WorldNoor
//
//  Created by apple on 6/23/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import UIKit
import SwiftLinkPreview

class TownHallNewVC: UIViewController , PickerviewDelegate{
    
    @IBOutlet var tbleViewTownHall : UITableView!
    
    
    @IBOutlet var lblCountry : UILabel!
    @IBOutlet var lblState : UILabel!
    @IBOutlet var lblCity : UILabel!
    
    var cityName = ""
    var cityWebSite = ""
    
    var countryName = ""
    var countryWebSite = ""
    
    var countyName = ""
    var countyWebSite = ""
    
    var stateName = ""
    var stateWebSite = ""
    
    
    var cityStr = "Select City".localized()
    var stateStr = "Select State".localized()
    var countryStr = "Select Country".localized()
    
    var resultData = [String : Any]()
    
    
    var countryArray = [CountryModel]()
    var chooseCountry = CountryModel.init()
    
    
    var stateArray = [StateModel]()
    var chooseState = StateModel.init()
    
    
    var cityArray = [StateModel]()
    var chooseCity = StateModel.init()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Town Hall".localized()
        self.tbleViewTownHall.register(UINib.init(nibName: "TownHallNewCell", bundle: nil), forCellReuseIdentifier: "TownHallNewCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.tbleViewTownHall.rotateViewForLanguage()
        self.lblCity.text = cityStr
        self.lblCountry.text = countryStr
        self.lblState.text = stateStr
        
        self.getAllTownHall()
    }
    
    func getAllTownHall(){
        
        let userToken = SharedManager.shared.userToken()
        var parameters = ["action": "town_hall/get_data","token": userToken]
        
        if chooseCountry.id.count != 0 {
            parameters["country_id"] = chooseCountry.id
        }
        
        if chooseState.id.count != 0 {
            parameters["state_id"] = chooseState.id
        }
        
        if chooseCity.id.count != 0 {
            parameters["city_id"] = chooseCity.id
        }
//        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        RequestManager.fetchDataGet(Completion: { response in
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            switch response {
            case .failure(let error):
                SwiftMessages.apiServiceError(error: error)
            case .success(let res):
                
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                }else if let dataMain = res as? [String : Any] {
                    self.resultData = dataMain
                }
                
                if let countryModel = (res as! [String : Any])["country"] as? [String : Any] {
                    if let name = (countryModel["name"] as? String) {
                        self.countryName = name
                    }else {
                        self.countryName = "N/A"
                    }
                    
                    if let urlMain = countryModel["website_url"] as? String {
                        self.countryWebSite = urlMain
                    }else {
                        self.countryWebSite = "N/A"
                    }
                }
                
                if let cityModel = (res as! [String : Any])["city"] as? [String : Any] {
                    if let name = (cityModel["name"] as? String) {
                        self.cityName = name
                    }else {
                        self.cityName = "N/A"
                    }
                    if let urlMain = cityModel["website_url"] as? String{
                        self.cityWebSite = urlMain
                    }else {
                        self.cityWebSite = "N/A"
                    }
                }
                
                
                
                if let stateModel = (res as! [String : Any])["state"] as? [String : Any] {
                    if let name = (stateModel["name"] as? String) {
                        self.stateName = name
                    }else {
                        self.stateName = "N/A"
                    }
                    
                    if let urlMain =  stateModel["website_url"] as? String {
                        self.stateWebSite = urlMain
                    }else {
                        self.stateWebSite = "N/A"
                    }
                }
                
                if let countryModel = (res as! [String : Any])["county"] as? [String : Any] {
                    if let name = (countryModel["name"] as? String) {
                        self.countyName = name
                    }else {
                        self.countyName = "N/A"
                    }
                    if let urlMain =  countryModel["website_url"] as? String {
                        self.countyWebSite = urlMain
                    }else {
                        self.countyWebSite = "N/A"
                    }
                }
                
                
                if self.countryArray.count == 0 {
                    self.showCountry()
                }
                
                self.tbleViewTownHall.reloadData()
            }
        }, param:parameters)
    }
    
    
    @objc func OpenWebPage(sender : UIButton){
        
        let cellMAin = self.tbleViewTownHall.cellForRow(at: IndexPath.init(row: sender.tag, section: 0)) as! TownHallNewCell
        
        switch sender.tag {
        case 0:
            if self.countryWebSite == "N/A" {
                
            }else {
                if self.countryWebSite.count == 0 {
                    cellMAin.viewSave.isHidden = false
                }else {
                    self.OpenLink(webUrl: self.countryWebSite)
                }
            }
            
        case 1:
            if self.stateWebSite == "N/A" {
                
            }else {
                if self.stateWebSite.count == 0 {
                    cellMAin.viewSave.isHidden = false
                }else {
                    self.OpenLink(webUrl: self.stateWebSite)
                }
                
            }
        case 2:
            
            if self.countyWebSite == "N/A" {
                
            }else {
                
                if self.countyWebSite.count == 0 {
                    cellMAin.viewSave.isHidden = false
                }else {
                    self.OpenLink(webUrl: self.countyWebSite)
                }
                
            }
        default:
            if self.cityWebSite == "N/A" {
                
            }else {
                if self.cityWebSite.count == 0 {
                    cellMAin.viewSave.isHidden = false
                }else {
                    self.OpenLink(webUrl: self.cityWebSite)
                }
            }
        }
    }
    
}



extension TownHallNewVC : UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cellMain = tableView.dequeueReusableCell(withIdentifier: "TownHallNewCell", for: indexPath) as! TownHallNewCell
        
        guard let cellMain = tableView.dequeueReusableCell(withIdentifier: "TownHallNewCell", for: indexPath) as? TownHallNewCell else {
                  return UITableViewCell()
               }
        
        switch indexPath.row {
        case 0:
            cellMain.lblNAme.text = self.countryName
            
            if self.countryWebSite.count == 0 {
                cellMain.lblWebsite.text = ""
            }else {
                cellMain.lblWebsite.text = self.countryWebSite
            }
            
            cellMain.lblNAmeHeading.text = "Country:".localized()
            
        case 1:
            cellMain.lblNAme.text = self.stateName
            
            if self.stateWebSite.count == 0 {
                cellMain.lblWebsite.text = "N/A"
            }else {
                cellMain.lblWebsite.text = self.stateWebSite
            }
            
            cellMain.lblNAmeHeading.text = "State:".localized()
        case 2:
            cellMain.lblNAme.text = self.countyName
            
            if self.countyWebSite.count == 0 {
                cellMain.lblWebsite.text = ""
            }else {
                cellMain.lblWebsite.text = self.countyWebSite
            }
            
            cellMain.lblNAmeHeading.text = "County:".localized()
            
        default:
            cellMain.lblNAme.text = self.cityName
            
            if self.cityWebSite.count == 0 {
                cellMain.lblWebsite.text = ""
            }else {
                cellMain.lblWebsite.text = self.cityWebSite
            }
            
            cellMain.lblNAmeHeading.text = "City:".localized()
        }
        
        cellMain.getLink(textURL: cellMain.lblWebsite.text!)
        cellMain.btnWebsite.tag = indexPath.row
        cellMain.btnWebsite.addTarget(self, action: #selector(self.OpenWebPage), for: .touchUpInside)
        
        cellMain.tfWebsite.tag = indexPath.row
        cellMain.btnSave.tag = indexPath.row
        cellMain.btnSave.addTarget(self, action: #selector(self.saveWebPage), for: .touchUpInside)
        
        cellMain.lblWebsite.rotateForTextAligment()
        cellMain.lblNAme.rotateForTextAligment()
        cellMain.lblWebsitePreview.rotateForTextAligment()
        cellMain.lblNAmeHeading.rotateForTextAligment()
        cellMain.lblWebsiteHeading.rotateForTextAligment()
        
        self.view.labelRotateCell(viewMain: cellMain.lblWebsiteHeading)
        self.view.labelRotateCell(viewMain: cellMain.lblWebsite)
        self.view.labelRotateCell(viewMain: cellMain.lblNAme)
        self.view.labelRotateCell(viewMain: cellMain.lblWebsitePreview)
        self.view.labelRotateCell(viewMain: cellMain.lblNAmeHeading)
        return cellMain
    }
    
    @objc func saveWebPage(sender : UIButton){
        let cellMAin = self.tbleViewTownHall.cellForRow(at: IndexPath.init(row: sender.tag, section: 0)) as! TownHallNewCell
        
        
        if cellMAin.tfWebsite.text?.count == 0 {
            
        }else {
            
            
            let userToken = SharedManager.shared.userToken()
            
            var urlAdded = cellMAin.tfWebsite.text!
            let fullNameArr = urlAdded.components(separatedBy: ".")
            
            if fullNameArr.count > 0 {
                
                if fullNameArr.first!.lowercased() == "https://" || fullNameArr.first!.lowercased() == "http://"{
                    
                }else {
                    urlAdded = "https://" + urlAdded
                }
            }
            
            var parameters = ["action": "town_hall/add_website", "token": userToken , "url": urlAdded]
            
            
            if sender.tag == 0 {
                if let countryModel = self.resultData["country"] as? [String : Any] {
                    parameters["country_id"] = SharedManager.shared.ReturnValueAsString(value: countryModel["country_id"] as Any)
                }
            }else if sender.tag == 1 {
                if let countryModel = self.resultData["state"] as? [String : Any] {
                    parameters["state_id"] = SharedManager.shared.ReturnValueAsString(value: countryModel["country_id"] as Any)
                }
            }else if sender.tag == 2 {
                
                if let countryModel = self.resultData["county"] as? [String : Any] {
                    parameters["county_id"] = SharedManager.shared.ReturnValueAsString(value: countryModel["country_id"] as Any)
                }
            }else if sender.tag == 3 {
                if let countryModel = self.resultData["county"] as? [String : Any] {
                    parameters["city_id"] = SharedManager.shared.ReturnValueAsString(value: countryModel["country_id"] as Any)
                }
                
            }
            
            Loader.startLoading()
            RequestManager.fetchDataPost(Completion: { response in
                Loader.stopLoading()
                switch response {
                case .failure(let error):
                    SwiftMessages.apiServiceError(error: error)
                case .success(let res):
                    if res is Int {
                        AppDelegate.shared().loadLoginScreen()
                    } else if res is String {
                        SwiftMessages.showMessagePopup(theme: .error, title: "Failed", body: res as? String ?? .emptyString)
                    }
                }
            }, param:parameters)
        }
    }
    
    
    func showCountry(){
        self.countryArray.removeAll()
//        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        let userToken = SharedManager.shared.userToken()
        let parameters = ["action": "meta/countries","token": userToken]
        RequestManager.fetchDataGet(Completion: { (response) in
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            switch response {
            case .failure(let error):
                SwiftMessages.apiServiceError(error: error)
            case .success(let res):
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                }else if res is [[String : Any]] {
                    let array = res as! [[String : Any]]
                    
                    for indexObj in array {
                        self.countryArray.append(CountryModel.init(fromDictionary: indexObj))
                    }
                }
            }
        }, param: parameters)
    }
    @IBAction func countryAction(sender : UIButton){
        self.showcountryPicker(Type: 1)
    }
    
    @IBAction func stateAction(sender : UIButton){
        self.getStateList()
    }
    
    func getStateList(){
        
        if self.chooseCountry.id.count == 0 {
            return
            
        }
        
        self.stateArray.removeAll()
//        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        let userToken = SharedManager.shared.userToken()
        let parameters = ["action": "meta/states_of_country","token": userToken ,"country_id": self.chooseCountry.id]
        RequestManager.fetchDataGet(Completion: { (response) in
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            
            switch response {
                
            case .failure(let error):
                SwiftMessages.apiServiceError(error: error)
            case .success(let res):
                
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                } else if res is [[String : Any]] {
                    let array = res as! [[String : Any]]
                    
                    for indexObj in array {
                        self.stateArray.append(StateModel.init(fromDictionary: indexObj))
                    }
                    self.showcountryPicker(Type: 2)
                }
            }
        }, param: parameters)
    }
    
    @IBAction func cityAction(sender : UIButton){
        self.cityGet()
    }
    
    
    @IBAction func submitAction(sender : UIButton){
        if self.chooseCountry.id.count != 0 || self.chooseState.id.count != 0 || self.chooseCity.id.count != 0{
            self.getAllTownHall()
        }
    }
    
    func cityGet(){
        
        if self.chooseState.id.count == 0 {
            return
        }
        
        self.cityArray.removeAll()
//        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        let userToken = SharedManager.shared.userToken()
        let parameters = ["action": "meta/cities_of_state","token": userToken ,"state_id": self.chooseState.id]
        RequestManager.fetchDataGet(Completion: { (response) in
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            
            switch response {
                
            case .failure(let error):
                SwiftMessages.apiServiceError(error: error)
            case .success(let res):
                
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                }else if res is [[String : Any]] {
                    let array = res as! [[String : Any]]
                    
                    for indexObj in array {
                        self.cityArray.append(StateModel.init(fromDictionary: indexObj))
                    }
                    self.showcountryPicker(Type: 3)
                }
            }
            
            
        }, param: parameters)
        
    }
    
    func showcountryPicker(Type : Int){
        let cuntryPicker = self.GetView(nameVC: "Pickerview", nameSB: "EditProfile") as! Pickerview
        
        cuntryPicker.isMultipleItem = false
        cuntryPicker.pickerDelegate = self
        cuntryPicker.type = Type
        
        var arrayData = [String]()
        
        if Type == 1 {
            for indexObj in self.countryArray {
                arrayData.append(indexObj.name)
            }
        }else if Type == 2 {
            for indexObj in self.stateArray {
                arrayData.append(indexObj.name)
            }
        }else if Type == 3 {
            for indexObj in self.cityArray {
                arrayData.append(indexObj.name)
            }
        }
        
        cuntryPicker.arrayMain = arrayData
        self.present(cuntryPicker, animated: true) {
            
        }
    }
    
    
    func pickerChooseView(text: String , type : Int ) {
        
        if type == 1 {
            
            for indexObj in self.countryArray {
                if indexObj.name == text {
                    self.chooseCountry = indexObj
                }
            }
            self.lblCountry.text = text
            
        }else if type == 2 {
            for indexObj in self.stateArray {
                if indexObj.name == text {
                    self.chooseState = indexObj
                }
            }
            self.lblState.text = text
        }else if type == 3 {
            for indexObj in self.cityArray {
                if indexObj.name == text {
                    self.chooseCity = indexObj
                }
            }
            self.lblCity.text = text
        }
    }
}


class TownHallNewCell : UITableViewCell, LinkGeneratorDelegate {
    @IBOutlet var lblNAme : UILabel!
    @IBOutlet var lblNAmeHeading : UILabel!
    @IBOutlet var lblWebsite : UILabel!
    @IBOutlet var lblWebsiteHeading : UILabel!
    @IBOutlet var btnWebsite : UIButton!
    @IBOutlet var websitePreview : UIView!
    
    @IBOutlet var lblWebsitePreview : UILabel!
    @IBOutlet var viewSave : UIView!
    @IBOutlet var btnSave : UIButton!
    @IBOutlet var tfWebsite : UITextField!
    
    var linkGeneratorObj = LinkGenerator()
    private var result:Response?
    var linkView: TownHallPreviewView?
    private let slp = SwiftLinkPreview(cache: InMemoryCache())
    
    func getLink(textURL : String){
        self.viewSave.isHidden = true
        if let url = self.slp.extractURL(text: textURL)    {
            self.linkGeneratorObj.delegate = self
            self.linkGeneratorObj.getLinkData(text: textURL)
            self.lblWebsitePreview.text = "Website preview".localized()
        }else {
            self.lblWebsitePreview.text = "N/A".localized()
            
        }
    }
    
    func linkGeneratedDelegate(result: Response) {
        self.result = result
        self.linkView = Bundle.main.loadNibNamed("TownHallPreviewView", owner: self, options: nil)?.first as? TownHallPreviewView
        self.linkView?.manageData(result: result)
        self.linkView?.backgroundColor = UIColor.white
        self.websitePreview.addSubview(self.linkView!)
        self.linkView!.translatesAutoresizingMaskIntoConstraints = false
        self.linkView!.leadingAnchor.constraint(equalTo: self.websitePreview.leadingAnchor, constant: 0).isActive = true
        self.linkView!.trailingAnchor.constraint(equalTo: self.websitePreview.trailingAnchor, constant: 0).isActive = true
        self.linkView!.topAnchor.constraint(equalTo: self.websitePreview.topAnchor, constant: 0).isActive = true
        self.linkView!.bottomAnchor.constraint(equalTo: self.websitePreview.bottomAnchor, constant: 0).isActive = true
        //        self.linkView!.linkCloseBtn.isHidden = true
    }
    
    func linkGenerateFailedDelegate() {
        
        
    }
    
    
    
    
}
