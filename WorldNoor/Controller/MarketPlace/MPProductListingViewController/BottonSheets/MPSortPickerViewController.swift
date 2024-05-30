//
//  SortPickerViewController.swift
//  WorldNoor
//
//  Created by moeez akram on 29/05/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//
//

import UIKit

class MPSortPickerViewController: UIViewController, RadioButtonDelegate {
    
    @IBOutlet weak var stackView: UIStackView!
    
    var radioButtons = [RadioButton]()
    var selectedOptionId: String = ""
    var selectedOption : ((RadioButtonItem) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let options = [RadioButtonItem(radioId: "1", radioTitle: "Recommended", radioDescription: "",radioButtonValue: "recommended"),
                       RadioButtonItem(radioId: "2", radioTitle: "Price - Lowest first", radioDescription: "",radioButtonValue: "price_ascend"),
                       RadioButtonItem(radioId: "3", radioTitle: "Price - Highest first", radioDescription: "",radioButtonValue: "price_descend"),
                       RadioButtonItem(radioId: "4", radioTitle: "Date listed - Newest first", radioDescription: "",radioButtonValue: "creation_time_descend"),
                       RadioButtonItem(radioId: "5", radioTitle: "Date listed - Oldest first", radioDescription: "",radioButtonValue: "creation_time_ascend")
        ]
        options.forEach { option in
            let radioButton = RadioButton(radioItem: option)
            radioButton.delegate = self
            radioButton.isSelected = option.radioId == selectedOptionId
            stackView.addArrangedSubview(radioButton)
            radioButtons.append(radioButton)
        }
    }
    @IBAction func onCrossTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    
    func radioButtonDidSelect(_ radioButton: RadioButton) {
        
        for otherButton in radioButtons {
            if otherButton != radioButton {
                otherButton.isSelected = false
            }
        }
        
        if radioButton.isSelected {
            if let selectedOption = selectedOption, let radioButtonItem = radioButton.radioButtonItem {
                LogClass.debugLog("Selected Option: \(radioButtonItem)")
                selectedOption(radioButtonItem)
            }
        }
        dismiss(animated: true)
    }
}
