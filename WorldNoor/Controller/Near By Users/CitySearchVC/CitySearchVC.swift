//
//  CitySearchVC.swift
//  WorldNoor
//
//  Created by apple on 4/16/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import UIKit

protocol CitySelectedDelegate: class {
    func citySelectedMethod(cityModel : CityGoogleSearchModel)
}

class CitySearchVC: UIViewController {
    @IBOutlet weak var viewSearch: UIView!
    @IBOutlet weak var txtFieldSearch: UITextField!
    
    var arrayCityGoogleSearch = [CityGoogleSearchModel]()
    var isfromHome=true

    var delegateCity : CitySelectedDelegate!
        
    @IBOutlet var tbleViewCitySearch : UITableView!
    
    var timeAPI = Timer.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.txtFieldSearch.delegate = self
        tbleViewCitySearch.registerCustomCells([
            "CitySearchCell" ,
        ])

        tbleViewCitySearch.keyboardDismissMode = .interactive
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        self.viewSearch.addShadow()
        self.txtFieldSearch.becomeFirstResponder()
    }
    
}


extension CitySearchVC : UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayCityGoogleSearch.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cellCity = tableView.dequeueReusableCell(withIdentifier: "CitySearchCell", for: indexPath) as! CitySearchCell
        
        guard let cellCity = tableView.dequeueReusableCell(withIdentifier: "CitySearchCell", for: indexPath) as? CitySearchCell else {
                  return UITableViewCell()
               }
        
        cellCity.lblCityName.text = self.arrayCityGoogleSearch[indexPath.row].name
        cellCity.lblCityDescription.text = self.arrayCityGoogleSearch[indexPath.row].formatted_address
        cellCity.selectionStyle = .none
        return cellCity
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.arrayCityGoogleSearch.count > indexPath.row {
            self.delegateCity.citySelectedMethod(cityModel: self.arrayCityGoogleSearch[indexPath.row])
            self.dismiss(animated: true) {
                
            }
        }
        
    }
}

extension CitySearchVC : UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text!.count > 0 {
            
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
                
        timeAPI.invalidate()
        timeAPI = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.apiCitySearch), userInfo: nil, repeats: false)
        
        return true
    }
    
    @objc func apiCitySearch(){
        self.arrayCityGoogleSearch.removeAll()
        let urlString = self.txtFieldSearch.text!.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let newUrl = "https://maps.googleapis.com/maps/api/place/textsearch/json?query=" + urlString! + "&key=AIzaSyBVqyJTLcFZoB46FyL1ulc5_Jhp279XDXA"
        RequestManager.fetchDataGetURL(MainURL: newUrl) { (resultResponse) in
            switch resultResponse {
            case .failure(let error):
SwiftMessages.apiServiceError(error: error)            case .success(let res):
                
                if let resultsMain = (res as! [String : AnyObject])["results"] as? [[String : Any]] {
                    for indexObj in resultsMain {
                        self.arrayCityGoogleSearch.append(CityGoogleSearchModel.init(fromDictionary: indexObj))
                    }
                }
                self.tbleViewCitySearch.reloadData()
            }
        }
    }
}


class CitySearchCell : UITableViewCell
{
    @IBOutlet var lblCityName : UILabel!
    @IBOutlet var lblCityDescription : UILabel!
}


extension UIView {
    func addShadow(scale: Bool = true) {
        self.layer.cornerRadius = 5
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowOpacity = 0.8
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowRadius = 10
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
    }
}
