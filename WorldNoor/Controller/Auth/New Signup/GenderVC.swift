//
//  GenderVC.swift
//
//  Created by Walid Ahmed on 25/05/2023.
//

import UIKit

class GenderVC: UIViewController {
    
    var genders = [Genders(title: "Female".localized(), details: ""),
                   Genders(title: "Male".localized(), details: ""),
                   Genders(title: "Custom".localized(), details: "Select Custom to choose another gender or if you'd rather not say.".localized())
    ]
    var selectedData = RegisterationData()

    @IBOutlet weak var genderTF: UITextField!
    @IBOutlet weak var customTitleLbl: UILabel!
    @IBOutlet weak var pronounLbl: UILabel!
    @IBOutlet weak var customDetailsbgV: UIView!
    @IBOutlet weak var custombgV: UIView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var genderbgV: UIView!
    @IBOutlet weak var genderTVHeight: NSLayoutConstraint!
    @IBOutlet weak var genderTV: UITableView!
    @IBOutlet weak var haveAccountBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var detailsLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
    }
    func setupUI(){
        hideAndShowCustomGenderView()
        genderTF.paddingLeft(padding: 8)
        genderTV.delegate = self
        genderTV.dataSource = self
        genderTV.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.new, context: nil)
        genderTV.register(UINib(nibName: "GenderTVCell", bundle: nil), forCellReuseIdentifier: "GenderTVCell")
        
        customDetailsbgV.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(customGenderbgVTapped(gesture:))))
        customDetailsbgV.isUserInteractionEnabled = true
        
        setLocalizations()
    }
    func setLocalizations(){
        titleLbl.text = "What's your gender?".localized()
        detailsLbl.text = "You can change who sees your gender on your profile later.".localized()
        nextBtn.setTitle("Next".localized(), for: .normal)
        haveAccountBtn.setTitle("Already have an account?".localized(), for: .normal)
        pronounLbl.text = "Your pronoun".localized()
        genderTF.placeholder = "Gender (optional)".localized()
    }
    @IBAction func backBtnPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nextBtnPressed(_ sender: Any) {
        
        selectedData.setGenderString()
        
//        LogClass.debugLog("nextBtnPressed ===>")
//        LogClass.debugLog(self.genderTF.text)
//        LogClass.debugLog(selectedData.selectedGender)
//        LogClass.debugLog(selectedData.selectedCustomGender)
//        LogClass.debugLog(selectedData.selectedPronoun)
        
        if !validateData() {
            return
        }
//        
//
        selectedData.selectedCustomGender = self.genderTF.text!
        let PhoneVC = GetView(nameVC: "PhoneVC", nameSB: "Registeration" ) as! PhoneVC
        PhoneVC.selectedData = selectedData
        navigationController?.pushViewController(PhoneVC, animated: true)
    }
    @IBAction func haveAccountBtnPressed(_ sender: Any) {
        let hiddenVC = GetView(nameVC: "LoginViewController", nameSB: "Main" ) as! LoginViewController
        navigationController?.pushViewController(hiddenVC, animated: true)
    }
    @objc func customGenderbgVTapped(gesture: UIGestureRecognizer) {
        openCustomGenderVC()
    }
    func validateData ()->Bool {
        if selectedData.selectedGenderIndex == -1 {
            SwiftMessages.showMessagePopup(theme: .success, title: "Alert", body: "Please choose your gender.".localized())
            return false
        }
        return true
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if(keyPath == "contentSize"){
            if let newvalue = change?[.newKey]
            {
                let newsize = newvalue as! CGSize
                genderTVHeight.constant = newsize.height
            }
        }
    }
}
extension GenderVC: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return genders.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GenderTVCell", for: indexPath) as! GenderTVCell
        cell.selectionStyle = .none
        cell.gender = genders[indexPath.row]
        cell.checkIfCellIsSelected(selectedIndex: selectedData.selectedGenderIndex, row: indexPath.row)
        cell.hideAndShowViews(row: indexPath.row, array: genders)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedData.selectedGenderIndex = indexPath.row
        hideAndShowCustomGenderView()
        openCustomGenderVC()
        genderTV.reloadData()
    }
    func hideAndShowCustomGenderView(){
        custombgV.isHidden = selectedData.selectedGenderIndex == 2 ? false : true
    }
    func openCustomGenderVC(){
        if selectedData.selectedGenderIndex == 2{
            view.alpha = 0.3
            let CustomGenderVC = GetView(nameVC: "CustomGenderVC", nameSB: "Registeration" ) as! CustomGenderVC
            CustomGenderVC.modalPresentationStyle = .overCurrentContext
            CustomGenderVC.selectedData = selectedData
            CustomGenderVC.onConfirm = {[weak self] selectedData in
                guard let self = self else{return}
                self.selectedData = selectedData
                self.customTitleLbl.text = selectedData.selectedPronoun
                self.dismissVC {
                    self.view.alpha = 1
                }
            }
            presentVC(CustomGenderVC, completion: nil)
        }
    }
}
