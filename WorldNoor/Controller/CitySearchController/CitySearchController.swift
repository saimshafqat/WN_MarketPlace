//
//  Pickerview.swift
//  WeTravel
//
//  Created by apple on 12/17/19.
//  Copyright © 2019 apple. All rights reserved.
//

import UIKit

protocol CitySearchDelegate {
    func pickerChooseView(locationDict:[String:String])
}

class CitySearchController: UIViewController {
    
    @IBOutlet var searchView : UISearchBar!
    @IBOutlet var tbleViewMain : UITableView!
    @IBOutlet weak var cstBottom: NSLayoutConstraint!
    
    var arrayMain = [[String:String]]()
    var arrayMtbleView = [[String:String]]()
    var type = 0
    var selectedItems = [String]()
    var pickerDelegate : CitySearchDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tbleViewMain.register(UINib.init(nibName: "PickerViewCell", bundle: nil), forCellReuseIdentifier: "PickerViewCell")
        self.loadCityData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    func loadCityData(){
        if SharedManager.shared.cityArrayCached.count > 0 {
            self.arrayMain = SharedManager.shared.cityArrayCached
            self.arrayMtbleView = self.arrayMain
            self.tbleViewMain.reloadData()
            self.selectedItems.removeAll()
        }else {
            if let path = Bundle.main.path(forResource: "cities", ofType: "json") {
                do {
                    let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                    let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                    if let jsonResult = jsonResult as? [[String:String]] {
                        SharedManager.shared.cityArrayCached = jsonResult
                        self.arrayMain = jsonResult
                        self.arrayMtbleView = self.arrayMain
                        self.tbleViewMain.reloadData()
                        self.selectedItems.removeAll()
                    }
                } catch {
                    // handle error
                }
            }
        }
    }
    
    @IBAction func doneAction(sender : UIButton){
        var selectValue = ""
        for indexObj in self.selectedItems {
            if selectValue.count > 0 {
                selectValue = selectValue + ","
            }
            selectValue = selectValue + indexObj
        }
        self.dismiss(animated: true) {
        }
    }
}

extension CitySearchController : UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayMtbleView.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cellPicker = tableView.dequeueReusableCell(withIdentifier: "PickerViewCell", for: indexPath) as! PickerViewCell
        
        guard let cellPicker = tableView.dequeueReusableCell(withIdentifier: "PickerViewCell", for: indexPath) as? PickerViewCell else {
           return UITableViewCell()
        }
        
        let dict = self.arrayMtbleView[indexPath.row]
        cellPicker.lblHeading.text = String(format: "%@, %@",(dict["name"]!), (dict["country"]!))
        cellPicker.selectionStyle = .none
        return cellPicker
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dict = self.arrayMtbleView[indexPath.row]
        self.pickerDelegate.pickerChooseView(locationDict: dict)
    }
}

extension CitySearchController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.arrayMtbleView = self.arrayMain.filter{
            $0["name"]!.range(of: searchText,
                              options: .caseInsensitive,
                              range: nil,
                              locale: nil) != nil
        }
        
        if searchText.count == 0 {
            self.arrayMtbleView = self.arrayMain
        }
        self.tbleViewMain.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
