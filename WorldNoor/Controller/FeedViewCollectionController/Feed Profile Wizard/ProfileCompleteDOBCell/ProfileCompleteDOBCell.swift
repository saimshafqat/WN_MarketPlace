//
//  ProfileCompleteDOBCell.swift
//  WorldNoor
//
//  Created by Waseem Shah on 22/01/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import Foundation
import UIKit

class ProfileCompleteDOBCell : UICollectionViewCell {
    
    @IBOutlet private weak var selectedDOBLabel: UILabel!
    
    weak var delegate: ProfileWizardDelegate?
    
    var selectedBirthDate: Date?
    
    
    
    var dateFormatter: DateFormatter = {
      let formatter = DateFormatter()
      formatter.dateFormat = "EEE dd, yyyy"
      formatter.locale = Locale(identifier: "en_US")
      return formatter
    }()
    
    
    override class func awakeFromNib() {
        
        
    }
    
    @IBAction func closeTapped(_ sender: Any) {
        self.delegate?.closeTapped(isSkipped: true)
    }

    
    @IBAction func dateOfBirthTapped(_ sender: Any) {
        
        let dateMain = DatePickerDialog.init(textColor: UIColor.black,
                                             buttonColor: UIColor.themeBlueColor,
                                             font: UIFont.boldSystemFont(ofSize: 12.0),
                                             locale: Locale.current,
                                             showCancelButton: true)
        dateMain.show("Date Of Birth".localized(), 
                      doneButtonTitle: "Done".localized(),
                      cancelButtonTitle: "Cancel".localized(),
                      defaultDate: selectedBirthDate ?? (Date().dateByAddingYears(-16)), minimumDate: nil,
                      maximumDate: Date().dateByAddingYears(-16),
                      datePickerMode: .date) {[weak self] (date) -> Void in
            
            guard let self = self else { return }
            if let dt = date {
                self.selectedBirthDate = dt
                self.selectedDOBLabel.text = self.dateFormatter.string(from: dt)
//                self.setBirthdayString()
            }
        }
    }
    
    @IBAction func skipTapped(_ sender: Any) {
       self.delegate?.closeTapped(isSkipped: true)
    }
    
    @IBAction func saveTapped(_ sender: Any) {
        
        if self.selectedDOBLabel.text!.count == 0 {
            UIApplication().topViewController()!.ShowAlert(message: "Date Of Birth is missing".localized())
            return
        }
        
        let userToken = SharedManager.shared.userToken()
        var parameters = [String : Any]()
        parameters["action"] = "profile/update"
        parameters["token"] = userToken
        parameters["dob"] = self.selectedDOBLabel.text!.changeDateString(inputformat: "EEE dd, yyyy", outputformat: "yyyy-MM-dd")
        
        Loader.startLoading()
        RequestManager.fetchDataPost(Completion: { response in
            Loader.stopLoading()
            switch response {
            case .failure(let error):
SwiftMessages.apiServiceError(error: error)            case .success(let res):
                if res is Int {
                    AppDelegate.shared().loadLoginScreen()
                } else if res is String {
                    SwiftMessages.showMessagePopup(theme: .error, title: "Failed", body: res as? String ?? .emptyString)
                } else if res is [String : Any] {
                    SharedManager.shared.userObj?.data.dob = self.selectedDOBLabel.text!.changeDateString(inputformat: "EEE dd, yyyy", outputformat: "yyyy-MM-dd")
                    SharedManager.shared.saveProfile(userObj: SharedManager.shared.userObj)
                    self.delegate?.closeTapped(isSkipped: false)
                    
                }
            }
        }, param:parameters)
        
        
    }
}
