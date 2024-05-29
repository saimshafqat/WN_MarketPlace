//
//  CustomGenderVC.swift
//  WorldNoor
//
//  Created by Walid Ahmed on 28/05/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit

class CustomGenderVC: UIViewController {

    var pronouns = [Genders(title: "She".localized(), details: "Wish her a happy birthday!".localized()),
                   Genders(title: "He".localized(), details: "Wish him a happy birthday!".localized()),
                   Genders(title: "They".localized(), details: "Wish them a happy birthday!".localized())
    ]
    var selectedData = RegisterationData()
    var onConfirm: ((RegisterationData) -> Void)?

    @IBOutlet weak var bgV: UIView!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var pronounbgV: UIView!
    @IBOutlet weak var pronounTVHeight: NSLayoutConstraint!
    @IBOutlet weak var pronounTV: UITableView!
    @IBOutlet weak var detailsLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
    }
    func setupUI(){
        
        
        if self.selectedData.selectedEmail.count == 0 && self.selectedData.selectedPhone.count == 0 {
            self.view.backgroundColor = UIColor.init(red: (154/255), green: (154/255), blue: (154/255), alpha: 0.5)
        }
        bgV.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        pronounTV.delegate = self
        pronounTV.dataSource = self
        pronounTV.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.new, context: nil)
        pronounTV.register(UINib(nibName: "GenderTVCell", bundle: nil), forCellReuseIdentifier: "GenderTVCell")
        setLocalizations()
    }
    func setLocalizations(){
        titleLbl.text = "Select your pronoun".localized()
        detailsLbl.text = "Your pronoun is visible to everyone.".localized()
    }
    @IBAction func cancelBtnPressed(_ sender: Any) {
        checkIfViewIsDismissedWithoutSelectingPronoun()
        onConfirm!(selectedData)
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if(keyPath == "contentSize"){
            if let newvalue = change?[.newKey]
            {
                let newsize = newvalue as! CGSize
                pronounTVHeight.constant = newsize.height
            }
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: UITouch? = touches.first
        if touch?.view != bgV && touch?.view != pronounbgV{
            checkIfViewIsDismissedWithoutSelectingPronoun()
            onConfirm!(selectedData)
        }
    }
    func checkIfViewIsDismissedWithoutSelectingPronoun(){
        if selectedData.selectedPronounIndex == -1{
            selectedData.selectedPronounIndex = 2
            selectedData.selectedPronoun = pronouns[selectedData.selectedPronounIndex].title
        }
    }
}
extension CustomGenderVC: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pronouns.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GenderTVCell", for: indexPath) as! GenderTVCell
        cell.selectionStyle = .none
        cell.selectedIcon.isHidden = true
        cell.gender = pronouns[indexPath.row]
        cell.hideAndShowViews(row: indexPath.row, array: pronouns, hideDetailsView: false)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedData.selectedPronounIndex = indexPath.row
        selectedData.selectedPronoun = pronouns[selectedData.selectedPronounIndex].title
        onConfirm!(selectedData)
    }
 
}
