//
//  MPBottomAvailabilityVC.swift
//  WorldNoor
//
//  Created by Awais on 09/05/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit

class MPBottomAvailabilityVC: UIViewController, RadioButtonDelegate {
    
    @IBOutlet weak var stackView: UIStackView!
    
    var radioButtons = [RadioButton]()
    var selectedOptionId: String = ""
    var selectedOption : ((RadioButtonItem) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let options = [RadioButtonItem(radioId: "1", radioTitle: "List as signle item", radioDescription: "if you're selling one item, show \"Only one\" on your listing."),
                       RadioButtonItem(radioId: "2", radioTitle: "List as in stock", radioDescription: "if you're selling more than one item, show \"In stock\" on your listing.")
        ]
        
        options.forEach { option in
            let radioButton = RadioButton(radioItem: option)
            radioButton.delegate = self
            radioButton.isSelected = option.radioId == selectedOptionId
            stackView.addArrangedSubview(radioButton)
            radioButtons.append(radioButton)
        }
    }
    
    @IBAction func onCrossBtnPressed(_ sender: Any) {
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
                LogClass.debugLog("Selected Option: \(radioButtonItem.radioTitle)")
                selectedOption(radioButtonItem)
            }
        }
        
        dismiss(animated: true)
    }
}
