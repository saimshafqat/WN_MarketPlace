//
//  GenderPopUpViewController.swift
//  WorldNoor
//
//  Created by Omnia Samy on 05/01/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit

class GenderPopUpViewController: UIViewController {

    @IBOutlet private weak var maleRaduioIconImageView: UIImageView!
    @IBOutlet private weak var femaleRaduioIconImageView: UIImageView!
    @IBOutlet private weak var otherRaduioIconImageView: UIImageView!
    
    private var selectedRaduiIcon = UIImage(named: "raduio_button_selected")
    private var unSelectedRaduiIcon = UIImage(named: "raduio_button_unselected")
    
    weak var delegate: GenderProtocol?
    private var selectedGender = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func dismissTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func genderSelected(_ sender: UIButton) {
        
        if sender.tag == 0 {
            
            self.selectedGender = "Male"
            maleRaduioIconImageView.image = selectedRaduiIcon
            femaleRaduioIconImageView.image = unSelectedRaduiIcon
            otherRaduioIconImageView.image = unSelectedRaduiIcon
        } else if sender.tag == 1 {
            
            self.selectedGender = "Female"
            maleRaduioIconImageView.image = unSelectedRaduiIcon
            femaleRaduioIconImageView.image = selectedRaduiIcon
            otherRaduioIconImageView.image = unSelectedRaduiIcon
        } else if sender.tag == 2 {
            
            self.selectedGender = "Other"
            maleRaduioIconImageView.image = unSelectedRaduiIcon
            femaleRaduioIconImageView.image = unSelectedRaduiIcon
            otherRaduioIconImageView.image = selectedRaduiIcon
        }
        
        delegate?.genderSelected(selectedGander: self.selectedGender)
        self.dismiss(animated: true)
    }
}
