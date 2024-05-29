//
//  JoinVC.swift
//
//  Created by Walid Ahmed on 25/05/2023.
//

import UIKit

class JoinVC: UIViewController {

    @IBOutlet weak var addImageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var haveAccountBtn: UIButton!
    @IBOutlet weak var getStartedBtn: UIButton!
    @IBOutlet weak var createLbl: UILabel!
    @IBOutlet weak var joinLbl: UILabel!
    @IBOutlet weak var adImg: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI(){
        bannerAdSetup()
        setLocalizations()
    }
    
    func setLocalizations(){
        joinLbl.text = "Join WorldNoor".localized()
        createLbl.text = "Create an account to connect with friends, family and communities of people who share your interests.".localized()
        getStartedBtn.setTitle("Get started".localized(), for: .normal)
        haveAccountBtn.setTitle("Already have an account?".localized(), for: .normal)
    }
    
    func bannerAdSetup() {
        adImg.image = UIImage(named: UIDevice().iPad ? "bannerIpad" : "join")
        addImageHeightConstraint = addImageHeightConstraint.setMultiplier(UIDevice().iPad ? 0.35 : 0.23)
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func getStartedBtnPressed(_ sender: Any){
        let UsernameVC = GetView(nameVC: "UsernameVC", nameSB: "Registeration" ) as! UsernameVC
        navigationController?.pushViewController(UsernameVC, animated: true)
    }
    
    @IBAction func haveAccountBtnPressed(_ sender: Any) {
        let hiddenVC = GetView(nameVC: "LoginViewController", nameSB: "Main" ) as! LoginViewController
        navigationController?.pushViewController(hiddenVC, animated: true)
    }
}
