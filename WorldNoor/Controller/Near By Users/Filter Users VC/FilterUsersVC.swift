//
//  FilterUsersVC.swift
//  WorldNoor
//
//  Created by apple on 4/16/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import UIKit
import GooglePlaces

protocol FilterDelegate: AnyObject {
    func filterapply(placeLat: String, placeLng: String, isMale: String, Interest: String)
    
    func filterTapped(toAge: String?, toDistance: String?, gender: String?, relationShipID: String?, InterestID: String?)
}

class FilterUsersVC: UIViewController {
    
    @IBOutlet var imgViewMale : UIImageView!
    @IBOutlet var imgViewfeMale : UIImageView!
    @IBOutlet var imgViewAll : UIImageView!
    
    @IBOutlet var lblInterst : UILabel!
    @IBOutlet var lblLocation : UILabel!
    
    var filterlat = ""
    var filterlng = ""
    var selectInterest = ""
    
    var delegate : FilterDelegate!
    var ismale = Gender.All
    
    
    var arrayInterest = [InterestModel]()
    
    var selectedImage = "CheckboxS.png"
    var unSelectedImage = "CheckboxU.png"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ismale = .All
        self.lblInterst.text = "Select Interest".localized()
        self.lblLocation.text = "Select Location".localized()
        self.imgViewMale.image = UIImage.init(named: unSelectedImage)
        self.imgViewAll.image = UIImage.init(named: selectedImage)
        self.imgViewfeMale.image = UIImage.init(named: unSelectedImage)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.getInterestes()
    }
    
    func getInterestes() {
        
        self.arrayInterest.removeAll()
//        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        let userToken = SharedManager.shared.userToken()
        let parameters = ["action": "meta/interests","token": userToken]
        RequestManager.fetchDataGet(Completion: { (response) in
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            
            switch response {
                
            case .failure(let error):
                
SwiftMessages.apiServiceError(error: error)            case .success(let res):
                
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                }else if res is [[String : Any]] {
                    let array = res as! [[String : Any]]
                    
                    for indexObj in array {
                        self.arrayInterest.append(InterestModel.init(fromDictionary: indexObj))
                    }
                }
            }
        }, param: parameters)
    }
    
    
    @IBAction func maleAction(sender : UIButton){
        self.ismale = .Male
        self.imgViewfeMale.image = UIImage.init(named: unSelectedImage)
        self.imgViewAll.image = UIImage.init(named: unSelectedImage)
        self.imgViewMale.image = UIImage.init(named: selectedImage)
    }
    
    @IBAction func femaleAction(sender : UIButton){
        self.ismale = .Female
        self.imgViewMale.image = UIImage.init(named: unSelectedImage)
        self.imgViewAll.image = UIImage.init(named: unSelectedImage)
        self.imgViewfeMale.image = UIImage.init(named: selectedImage)
    }
    
    @IBAction func allAction(sender : UIButton){
        self.ismale = .All
        self.imgViewAll.image = UIImage.init(named: selectedImage)
        self.imgViewMale.image = UIImage.init(named: unSelectedImage)
        self.imgViewfeMale.image = UIImage.init(named: unSelectedImage)
    }
    
    @IBAction func interestAction(sender : UIButton) {
        
        var arrayName = [String]()
                
        for indexObj in self.arrayInterest {
            arrayName.append(indexObj.name)
        }
        
        let picker = self.GetView(nameVC: "Pickerview", nameSB: "EditProfile") as! Pickerview
        picker.isMultipleItem = false
        picker.pickerDelegate = self
        picker.type = 0
        picker.arrayMain = arrayName
        self.present(picker, animated: true)
    }
    
    @IBAction func locationAction(sender : UIButton) {
        
        let citySearch = self.GetView(nameVC: "CitySearchVC", nameSB: "EditProfile") as! CitySearchVC
        
        
        citySearch.delegateCity  = self
        
        self.present(citySearch, animated: true) {
            
        }
    }
    
    @IBAction func submitAction(sender : UIButton) {
        
        var ismaleStr = "all"
        if ismale == .Male {
            ismaleStr = "M"
        }else if ismale == .Female {
            ismaleStr = "F"
        }
        
        self.delegate.filterapply(placeLat: self.filterlat, placeLng: self.filterlng, isMale: ismaleStr, Interest: self.selectInterest)
        self.dismiss(animated: true) {
            
        }
    }
    
    @IBAction func resetAction(sender : UIButton) {
        
        self.lblInterst.text = "Select Interest".localized()
        self.lblLocation.text = "Select Location".localized()
        self.ismale = .All
        
        self.filterlat = ""
        self.filterlng = ""
        self.selectInterest = ""
        
        self.imgViewMale.image = UIImage.init(named: unSelectedImage)
        self.imgViewAll.image = UIImage.init(named: selectedImage)
        self.imgViewfeMale.image = UIImage.init(named: unSelectedImage)
    }
}

extension FilterUsersVC : PickerviewDelegate, CitySelectedDelegate {
    
    func pickerChooseView(text: String , type : Int) {
        self.lblInterst.text = text
        
        
        for indexObj in self.arrayInterest {
            if indexObj.name == self.lblInterst.text {
                self.selectInterest = indexObj.id
            }
        }
    }
    
    func citySelectedMethod(cityModel : CityGoogleSearchModel) {
        
        self.lblLocation.text = cityModel.formatted_address
        self.filterlat = cityModel.placeLat
        self.filterlng = cityModel.placeLng
        
    }
}
