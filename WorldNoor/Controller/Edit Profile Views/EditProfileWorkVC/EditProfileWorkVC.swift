//
//  EditProfileWorkVC.swift
//  WorldNoor
//
//  Created by apple on 1/20/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import UIKit
import SwiftDate


class EditProfileWorkVC: UIViewController {

    @IBOutlet var tbleViewWork : UITableView!
    
    var parentview : ProfileViewController!    
    var refreshParentView: (()->())?
    
    var type = -1
    var rowIndex = -1
    
    var arrayWrok = [[String : String]]()
    
    var countryArray = [CountryModel]()
    var chooseCountry = CountryModel.init()
    
    var editWork : UserWorkExperiences!
    var startDate : Date!
    var endDate : Date!
    
    
    var work_copmany = ""
    var work_position = ""
    var work_city = ""
    var work_description = ""
    var work_StartDate = ""
    var work_Currently = "0"
    var work_EndDate = ""
    
    
    @IBOutlet var viewDelete : UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tbleViewWork.register(UINib.init(nibName: "EditProfileWorkTextCell", bundle: nil), forCellReuseIdentifier: "EditProfileWorkTextCell")
        self.tbleViewWork.register(UINib.init(nibName: "EditProfileWorkTextViewCell", bundle: nil), forCellReuseIdentifier: "EditProfileWorkTextViewCell")
        self.tbleViewWork.register(UINib.init(nibName: "EditProfileWorkCheckBoxCell", bundle: nil), forCellReuseIdentifier: "EditProfileWorkCheckBoxCell")
        
        
        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.viewDelete.isHidden = true
    }
    override func viewDidAppear(_ animated: Bool) {
        arrayWrok.removeAll()
        
        if self.type == -1 {
            
            self.reloadDataTable()
        }else {
            self.viewDelete.isHidden = false
            if self.countryArray.count == 0 {
                self.getCountry()
            }else {
                 self.getCountry()
            }
        }
    }
    
    
    func reloadDataTable(){
        
        if self.type == 2 {
            work_copmany = self.editWork.company
            work_position = self.editWork.title
            work_city = self.editWork.city
            work_description = self.editWork.descriptionExp
            work_StartDate = (self.editWork.start_date.toDate()?.toFormat("YYYY-MM-dd"))!
            work_Currently = self.editWork.employment_status
            work_EndDate = (self.editWork.end_date.toDate()?.toFormat("YYYY-MM-dd"))!
            
        }else {
             work_copmany = ""
             work_position = ""
             work_city = ""
             work_description = ""
             work_StartDate = ""
             work_Currently = "0"
             work_EndDate = ""
            self.chooseCountry = CountryModel.init()
        }
          
          
          arrayWrok.append(["Type" : "1" , "Title" : "Company".localized(), "PH" : "Company".localized()  , "ID": "1" , "Text" : work_copmany])
          arrayWrok.append(["Type" : "1" , "Title" : "Position".localized(), "PH" : "Position".localized() , "ID": "2" , "Text" : work_position])
        arrayWrok.append(["Type" : "1" , "Title" : "Country".localized(), "PH" : "Country".localized(), "ID": "4" , "Text" : self.chooseCountry.name])
        
          arrayWrok.append(["Type" : "1" , "Title" : "City/Town".localized(), "PH" : "City/Town".localized() , "ID": "3" , "Text" : work_city])
          
          arrayWrok.append(["Type" : "2" , "Title" : "Description".localized(), "PH" : "Description".localized() , "ID": "5" , "Text" : work_description])
          arrayWrok.append(["Type" : "1" , "Title" : "Start Date".localized(), "PH" : "Start Date".localized() , "ID": "6" , "Text" : work_StartDate])
          arrayWrok.append(["Type" : "3" , "Title" : "", "PH" : "" , "ID": "7" , "Text" : work_Currently])
          arrayWrok.append(["Type" : "1" , "Title" : "End Date".localized(), "PH" : "End Date".localized() , "ID": "8" , "Text" : work_EndDate])
          self.tbleViewWork.reloadData()
    }
  
    func reloadView(type : Int , rowIndexP : Int ){
        
         self.type = type
         self.rowIndex = rowIndexP    
    }
    
    func getCountry(){
           
           
           if self.countryArray.count > 0 {
               for indexObj in self.countryArray {
                 if indexObj.id == self.editWork.country_id {
                     self.chooseCountry = indexObj
                     break
                 }
             }
            
            self.reloadDataTable()
               return
           }
//           SharedManager.shared.showOnWindow()
        Loader.startLoading()
             let userToken = SharedManager.shared.userToken()
           let parameters = ["action": "meta/countries","token": userToken]
           RequestManager.fetchDataGet(Completion: { (response) in
//                SharedManager.shared.hideLoadingHubFromKeyWindow()
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
                           self.countryArray.append(CountryModel.init(fromDictionary: indexObj))
                       }
                       

                       for indexObj in self.countryArray {
                           if indexObj.id == self.editWork.country_id {
                               self.chooseCountry = indexObj
                               break
                           }
                       }
                    
                    self.reloadDataTable()
                       
                   }
                   
               }
               
               
           }, param: parameters)
       }
    func getcountryList(){
        
        if self.countryArray.count > 0 {
            self.showcountryPicker(Type: 1)
         return
        }
        
//         SharedManager.shared.showOnWindow()
        Loader.startLoading()
          let userToken = SharedManager.shared.userToken()
        let parameters = ["action": "meta/countries","token": userToken]
        RequestManager.fetchDataGet(Completion: { (response) in
//             SharedManager.shared.hideLoadingHubFromKeyWindow()
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
                    
                    self.showcountryPicker(Type: 1)
                }
                
            }
            
            
        }, param: parameters)
    }
    
    
    @IBAction func deleteAction(sender : UIButton){
        let placeid = self.editWork.id
        self.ShowAlertWithCompletaion(message: "Are you sure to delete this work?".localized()) { (status) in

            if status {
                let userToken = SharedManager.shared.userToken()
                let parameters = ["action": "user/works/delete","token": userToken , "id" : placeid , "_method" : "DELETE"]
                Loader.startLoading()
                RequestManager.fetchDataPost(Completion: { response in
                    Loader.stopLoading()
                    switch response {
                    case .failure(let error):
                        SwiftMessages.apiServiceError(error: error)
                    case .success(let res):
                        if res is Int {
                            AppDelegate.shared().loadLoginScreen()
                        }else if res is String {

                        }else {

                            SharedManager.shared.userEditObj.workExperiences.remove(at: self.rowIndex)
                            self.refreshParentView?()
                            self.view.removeFromSuperview()
                        }
                    }
                }, param:parameters)
            }
        }
    }
}


extension EditProfileWorkVC : UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayWrok.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.arrayWrok[indexPath.row]["Type"] == "2" {
           return EditProfileWorkTextViewCell(tableView: tableView, cellForRowAt: indexPath)
        }else if self.arrayWrok[indexPath.row]["Type"] == "3" {
           return EditProfileWorkCheckBoxCell(tableView: tableView, cellForRowAt: indexPath)
        }
        return EditProfileWorkTextCell(tableView: tableView, cellForRowAt: indexPath)
    }
    
    
    func EditProfileWorkTextCell(tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "EditProfileWorkTextCell", for: indexPath) as! EditProfileWorkTextCell
     
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "EditProfileWorkTextCell", for: indexPath) as? EditProfileWorkTextCell else {
                  return UITableViewCell()
               }
        
        cell.lblHeading.text = self.arrayWrok[indexPath.row]["Title"]
        cell.txtFieldMain.text = self.arrayWrok[indexPath.row]["Text"]
        cell.txtFieldMain.placeholder = self.arrayWrok[indexPath.row]["PH"]
        
        if cell.txtFieldMain.placeholder == "End Date".localized() {
            if self.work_Currently == "1" {
                cell.lblHeading.textColor = UIColor.lightGray
                cell.txtFieldMain.text = ""
                cell.txtFieldMain.isEnabled = false
            }
        }
        cell.txtFieldMain.delegate = self
        cell.txtFieldMain.tag = indexPath.row
        cell.selectionStyle = .none
        return cell
    }
        
    func EditProfileWorkTextViewCell(tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "EditProfileWorkTextViewCell", for: indexPath) as! EditProfileWorkTextViewCell
                  
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "EditProfileWorkTextViewCell", for: indexPath) as? EditProfileWorkTextViewCell else {
                  return UITableViewCell()
               }
        
        
        cell.lblHeading.text = self.arrayWrok[indexPath.row]["Title"]
        cell.txtViewMain.text = self.arrayWrok[indexPath.row]["Text"]
        cell.txtViewMain.textColor = UIColor.black
        cell.txtViewMain.delegate = self
        cell.txtViewMain.tag = indexPath.row
        if self.arrayWrok[indexPath.row]["Text"]!.count == 0 {
            cell.txtViewMain.text = "Description here...".localized()
            cell.txtViewMain.textColor = UIColor.lightGray
        }
        
        cell.selectionStyle = .none
        return cell
    }
    
    func EditProfileWorkCheckBoxCell(tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cellCheck = tableView.dequeueReusableCell(withIdentifier: "EditProfileWorkCheckBoxCell", for: indexPath) as! EditProfileWorkCheckBoxCell

        guard let cellCheck = tableView.dequeueReusableCell(withIdentifier: "EditProfileWorkCheckBoxCell", for: indexPath) as? EditProfileWorkCheckBoxCell else {
                  return UITableViewCell()
               }
        
        cellCheck.imgViewTick.image = UIImage.init(named: "CheckboxU")
        
        if self.arrayWrok[indexPath.row]["Text"] == "1" {
            cellCheck.imgViewTick.image = UIImage.init(named: "CheckboxS")
        }
        
        cellCheck.btntick.tag = indexPath.row
        cellCheck.btntick.addTarget(self, action: #selector(self.tickAction), for: .touchUpInside)
        cellCheck.selectionStyle = .none
        return cellCheck
    }
    
    @objc func tickAction(sender : UIButton){
        let cellCheck = self.tbleViewWork.cellForRow(at: IndexPath.init(row: sender.tag, section: 0)) as! EditProfileWorkCheckBoxCell
        
        
        let cellText = self.tbleViewWork.cellForRow(at: IndexPath.init(row: sender.tag + 1, section: 0) ) as! EditProfileWorkTextCell
        
        
        if self.arrayWrok[sender.tag]["Text"] == "1" {
            cellCheck.imgViewTick.image = UIImage.init(named: "CheckboxU")
            self.arrayWrok[sender.tag]["Text"] = "0"
            self.work_Currently = "0"
            cellText.lblHeading.textColor = UIColor.black
            cellText.txtFieldMain.text = ""
            cellText.txtFieldMain.isEnabled = true
        }else {
            cellCheck.imgViewTick.image = UIImage.init(named: "CheckboxS")
            self.arrayWrok[sender.tag]["Text"] = "1"
            cellText.lblHeading.textColor = UIColor.lightGray
            cellText.txtFieldMain.text = ""
            cellText.txtFieldMain.isEnabled = false
            self.work_Currently = "1"
        }
        
    }
    
}


extension EditProfileWorkVC {
    @IBAction func submitAction(sender : UIButton){
        self.view.endEditing(true)
        

        if self.work_copmany.count == 0  {
            SharedManager.shared.showAlert(message: "Enter company name".localized(), view: self)
            return
//        }else if self.work_position.count == 0  {
//            SharedManager.shared.showAlert(message: "Enter position".localized(), view: self)
//            return
//        }else if self.work_city.count == 0 {
//            SharedManager.shared.showAlert(message: "Enter city name".localized(), view: self)
//            return
//        }else if self.chooseCountry.id.count == 0  {
//            SharedManager.shared.showAlert(message: "Enter country".localized(), view: self)
//            return
//        }else if self.work_description.count == 0  {
//            SharedManager.shared.showAlert(message: "Enter description".localized(), view: self)
//            return
//        }else if self.work_StartDate.count == 0  {
//            SharedManager.shared.showAlert(message: "Enter start date".localized(), view: self)
//            return
//        }else if self.work_Currently != "1" {
//            if self.work_EndDate.count == 0  {
//                SharedManager.shared.showAlert(message: "Enter end date".localized(), view: self)
//                return
//            }
        }

        let userToken = SharedManager.shared.userToken()

        var action = ""
        var placeID = ""

        if type == 2 {
            action = "user/works/update"
            placeID = self.editWork.id
        }else {
            action = "user/works/create"
            placeID = ""
        }

        let parameters = ["action": action,
                          "token": userToken ,
                          "country_id" : self.chooseCountry.id ,
                          "city" : self.work_city,
                          "description" : self.work_description,
                          "employment_status" : self.work_Currently ,
                          "id" : placeID ,
                          "title" : self.work_position,
                          "company" : self.work_copmany,
                          "start_date" : self.work_StartDate,
                          "end_date" : self.work_EndDate]

//        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        RequestManager.fetchDataPost(Completion: { response in

//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            switch response {
            case .failure(let error):
SwiftMessages.apiServiceError(error: error)
            case .success(let res):

                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                }else if res is String {
                    SharedManager.shared.showAlert(message: res as! String, view: self)
                }else if res is [String : Any] {

                    if self.type == 2 {
                        
                        SharedManager.shared.userEditObj.workExperiences[self.rowIndex].country_id = self.chooseCountry.id
                        SharedManager.shared.userEditObj.workExperiences[self.rowIndex].title = self.work_position
                        SharedManager.shared.userEditObj.workExperiences[self.rowIndex].company = self.work_copmany
                        SharedManager.shared.userEditObj.workExperiences[self.rowIndex].descriptionExp = self.work_description
                        
                        if self.work_Currently == "1" {
                            SharedManager.shared.userEditObj.workExperiences[self.rowIndex].end_date = Date().toFormat("YYYY-MM-dd")
                        }else {
                            SharedManager.shared.userEditObj.workExperiences[self.rowIndex].end_date = self.work_EndDate
                        }
                        SharedManager.shared.userEditObj.workExperiences[self.rowIndex].employment_status = self.work_Currently
                        SharedManager.shared.userEditObj.workExperiences[self.rowIndex].start_date = self.work_StartDate
                        SharedManager.shared.userEditObj.workExperiences[self.rowIndex].city = self.work_city
                        
                    }else {
                        SharedManager.shared.userEditObj.workExperiences.append(UserWorkExperiences.init(fromDictionary: res as! [String : Any]))
                    }


                    self.refreshParentView?()
                    self.view.removeFromSuperview()
                }
            }

        }, param:parameters)
    }
}


extension EditProfileWorkVC : UITextFieldDelegate , UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Description here...".localized() {
            textView.text = ""
        }
        
        textView.textColor = UIColor.black
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.work_description = textView.text!
        
        if textView.text.count == 0 {
            textView.text = "Description here...".localized()
            textView.textColor = UIColor.lightGray
        }
        
        self.arrayWrok[textView.tag]["Text"] = textView.text
    }
    
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
                
        if self.arrayWrok[textField.tag]["ID"] == "4" {
            self.getcountryList()
            return false
        }else if self.arrayWrok[textField.tag]["ID"] == "6" {
            self.datePickerTapped()
            return false
        }else if self.arrayWrok[textField.tag]["ID"] == "8" {
            self.datePickerTapped(isEndDate: true)
            return false
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.arrayWrok[textField.tag]["Text"] = textField.text!
        if let cellText = self.tbleViewWork.cellForRow(at: IndexPath.init(row: textField.tag, section: 0)) as? EditProfileWorkTextCell {
            cellText.txtFieldMain.text = textField.text!
        }
        
        
        if self.arrayWrok[textField.tag]["ID"] == "1" {
            self.work_copmany = textField.text!
        }else if self.arrayWrok[textField.tag]["ID"] == "2" {
            self.work_position = textField.text!
        }else if self.arrayWrok[textField.tag]["ID"] == "3" {
            self.work_city = textField.text!
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

     override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
         let touch = touches.first!
         if(touch.view!.tag == 100 ) {
             self.view.removeFromSuperview()
         }
     }
}


extension EditProfileWorkVC : PickerviewDelegate {
    
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
        }
        
        cuntryPicker.arrayMain = arrayData
        
        self.present(cuntryPicker, animated: true) {
            
        }
    }
    
     
    func pickerChooseView(text: String , type : Int )
    {
        if type == 1 {
            
            for indexObj in self.countryArray {
                if indexObj.name == text {
                    self.chooseCountry = indexObj
                }
            }
            
            
            self.arrayWrok[2]["Text"] = text
            let cellText = self.tbleViewWork.cellForRow(at: IndexPath.init(row: 2, section: 0)) as! EditProfileWorkTextCell
            cellText.txtFieldMain.text = text
            
        }
    }
    
    
    func datePickerTapped(isEndDate : Bool = false) {
        
        if isEndDate {
            if self.arrayWrok[5]["Text"]?.count == 0 {
            
            }else {
                
                let dateMain = DatePickerDialog.init(textColor: UIColor.black , buttonColor: UIColor.themeBlueColor, font: UIFont.boldSystemFont(ofSize: 12.0), locale: Locale.current, showCancelButton: true)
                
                
                dateMain.show("End Date".localized(), doneButtonTitle: "Done".localized(), cancelButtonTitle: "Cancel".localized(), defaultDate: Date(), minimumDate: startDate, maximumDate: Date(), datePickerMode: .date) {
                    (date) -> Void in
                    if let dt = date {

                        self.endDate = dt
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd"
                        self.arrayWrok[7]["Text"] = formatter.string(from: dt)

                        let cellText = self.tbleViewWork.cellForRow(at: IndexPath.init(row: 7, section: 0)) as! EditProfileWorkTextCell
                        cellText.txtFieldMain.text = formatter.string(from: dt)
                        self.work_EndDate = formatter.string(from: dt)
                        
                        
                    }
                }
                
                
                
//                if #available(iOS 13.4, *) {
//                    DatePickerDialog().datePicker.preferredDatePickerStyle = .automatic
//                } else {
//                    // Fallback on earlier versions
//                }
//                DatePickerDialog().show("End Date".localized(), doneButtonTitle: "Done".localized(), cancelButtonTitle: "Cancel".localized(), minimumDate: startDate, maximumDate: Date(), datePickerMode: UIDatePicker.Mode.date) { (date) in
//                     if let dt = date {
//
//                        self.endDate = dt
//                        let formatter = DateFormatter()
//                        formatter.dateFormat = "yyyy-MM-dd"
//                        self.arrayWrok[7]["Text"] = formatter.string(from: dt)
//
//                        let cellText = self.tbleViewWork.cellForRow(at: IndexPath.init(row: 7, section: 0)) as! EditProfileWorkTextCell
//                        cellText.txtFieldMain.text = formatter.string(from: dt)
//                        self.work_EndDate = formatter.string(from: dt)
//                    }
//                }
            }
        }else {
            
            let dateMain = DatePickerDialog.init(textColor: UIColor.black , buttonColor: UIColor.themeBlueColor, font: UIFont.boldSystemFont(ofSize: 12.0), locale: Locale.current, showCancelButton: true)
            
            
            dateMain.show("Start Date".localized(), doneButtonTitle: "Done".localized(), cancelButtonTitle: "Cancel".localized(), defaultDate: Date(), minimumDate: nil, maximumDate: Date(), datePickerMode: .date) {
                (date) -> Void in
                if let dt = date {

                    self.startDate = dt
                    
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"
                    
                    self.arrayWrok[5]["Text"] = formatter.string(from: dt)
                    let cellText = self.tbleViewWork.cellForRow(at: IndexPath.init(row: 5, section: 0)) as! EditProfileWorkTextCell
                    cellText.txtFieldMain.text = formatter.string(from: dt)
                    self.work_StartDate = formatter.string(from: dt)
                    
                    
                }
            }
            
//            if #available(iOS 13.4, *) {
//                DatePickerDialog().datePicker.preferredDatePickerStyle = .automatic
//            } else {
//                // Fallback on earlier versions
//            }
//            DatePickerDialog().show("Start Date".localized(), doneButtonTitle: "Done".localized(), cancelButtonTitle: "Cancel".localized(), maximumDate : Date(), datePickerMode: .date) {
//                (date) -> Void in
//                if let dt = date {
//                    self.startDate = dt
//
//                    let formatter = DateFormatter()
//                    formatter.dateFormat = "yyyy-MM-dd"
//
//                    self.arrayWrok[5]["Text"] = formatter.string(from: dt)
//                    let cellText = self.tbleViewWork.cellForRow(at: IndexPath.init(row: 5, section: 0)) as! EditProfileWorkTextCell
//                    cellText.txtFieldMain.text = formatter.string(from: dt)
//                    self.work_StartDate = formatter.string(from: dt)
//                }
//            }
        }
        
           
       }
}
