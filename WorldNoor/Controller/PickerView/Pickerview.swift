//
//  Pickerview.swift
//  WeTravel
//
//  Created by apple on 12/17/19.
//  Copyright © 2019 apple. All rights reserved.
//

import UIKit

protocol PickerviewDelegate: class {
    func pickerChooseView(text: String , type : Int)
    func pickerChooseMultiView(text: [String] , type : Int)
}

extension PickerviewDelegate {
    func pickerChooseMultiView(text: [String] , type : Int){
        
    }
}

class Pickerview: UIViewController {
    
    @IBOutlet var searchView : UISearchBar!
    @IBOutlet var tbleViewMain : UITableView!
    
    var arrayMain = [String]()
    var arrayMtbleView = [String]()
    var isMultipleItem = false
    var isFromRelationship: Bool = false
    var type = 0
    var isFromLanguage: Bool = false
    var selectedItems = [String]()
    @IBOutlet weak var cstBottom: NSLayoutConstraint!
    var pickerDelegate : PickerviewDelegate!
    var languageCompletion: (([String], Int) -> Void)? = nil
    var relationshipCompletion: ((String, Int) -> Void)? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tbleViewMain.register(UINib.init(nibName: "PickerViewCell", bundle: nil), forCellReuseIdentifier: "PickerViewCell")
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.arrayMtbleView = self.arrayMain
        self.tbleViewMain.reloadData()
        if isMultipleItem {
            self.cstBottom.constant = 75.0
        }
    }
    
    @IBAction func doneAction(sender : UIButton) {
        var selectValue = ""
        for indexObj in self.selectedItems {
            if selectValue.count > 0 {
                selectValue = selectValue + ","
            }
            selectValue = selectValue + indexObj
        }
        if self.isMultipleItem {
            if isFromLanguage {
                self.dismiss(animated: true) {
                    self.languageCompletion?(self.selectedItems, self.type)
                }
            } else {
                self.dismiss(animated: true) {
                    self.pickerDelegate.pickerChooseMultiView(text: self.selectedItems, type: self.type)
                }
            }
        } else {
            self.dismiss(animated: true) {
                if self.isFromRelationship {
                    self.relationshipCompletion?(selectValue, self.type)
                } else {
                    self.pickerDelegate.pickerChooseView(text: selectValue, type: self.type)
                }
            }
        }
    }
}

extension Pickerview : UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayMtbleView.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cellPicker = tableView.dequeueReusableCell(withIdentifier: "PickerViewCell", for: indexPath) as? PickerViewCell else {
            return UITableViewCell()
        }
        
        cellPicker.lblHeading.text = self.arrayMtbleView[indexPath.row]
        cellPicker.accessoryType = .none
        if self.selectedItems.contains(self.arrayMtbleView[indexPath.row]) {
            cellPicker.accessoryType = .checkmark
        }
        cellPicker.selectionStyle = .none
        return cellPicker
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellMain = tableView.cellForRow(at: indexPath) as! PickerViewCell
        if self.isMultipleItem {
            if self.selectedItems.contains(self.arrayMtbleView[indexPath.row]) {
                cellMain.accessoryType = .none
                self.selectedItems.remove(at: self.selectedItems.firstIndex(of: self.arrayMtbleView[indexPath.row])!)
            }else {
                cellMain.accessoryType = .checkmark
                self.selectedItems.append(self.arrayMtbleView[indexPath.row])
            }
        } else {
            self.dismiss(animated: true) {
                if self.isFromRelationship {
                    self.relationshipCompletion?(self.arrayMtbleView[indexPath.row], self.type)
                } else {
                    self.pickerDelegate.pickerChooseView(text: self.arrayMtbleView[indexPath.row], type: self.type)
                }
            }
        }
    }
}

extension Pickerview: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.arrayMtbleView =  self.arrayMain.filter({(item: String) -> Bool in
            let stringMatch = item.lowercased().range(of: searchText.lowercased())
            return stringMatch != nil ? true : false
        })
        
        if searchText.count == 0 {
            self.arrayMtbleView = self.arrayMain
        }
        self.tbleViewMain.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

class PickerViewCell : UITableViewCell {
    @IBOutlet var lblHeading : UILabel!
}
