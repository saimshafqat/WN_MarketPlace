//
//  ProfileCompletePlaceCell.swift
//  WorldNoor
//
//  Created by Omnia Samy on 23/01/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit

class ProfileCompletePlaceCell: UICollectionViewCell , ProfileWizardDelegate {
    

    @IBOutlet weak var selectedDataCollectionView: UICollectionView!
    weak var delegate: ProfileWizardDelegate?
    
    var profileCity = ProfileEizardPopUP.init()
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profileCity = UIApplication.topViewController()!.GetView(nameVC: "ProfileEizardPopUP", nameSB: "Notification") as! ProfileEizardPopUP
        selectedDataCollectionView.dataSource = self
        selectedDataCollectionView.delegate = self
        selectedDataCollectionView.register(UINib(nibName: SelectedPlaceCell.className, bundle: nil),
                                             forCellWithReuseIdentifier: SelectedPlaceCell.className)
       
    }

    @IBAction func closeTapped(_ sender: Any) {
        self.delegate?.closeTapped(isSkipped: true)
    }
    
    @IBAction func selectPlaceTapped(_ sender: Any) {
        profileCity.delegate = self
        UIApplication.topViewController()?.view.addSubview(profileCity.view)
    }
    
    @IBAction func skipTapped(_ sender: Any) {
        self.delegate?.closeTapped(isSkipped: true)
    }
    
    @IBAction func saveTapped(_ sender: Any) {

    }
    
    
    func closeTapped(isSkipped: Bool){
        self.delegate!.closeTapped(isSkipped: true)
    }
    
}

extension ProfileCompletePlaceCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
        guard let cell = collectionView
            .dequeueReusableCell(withReuseIdentifier: SelectedPlaceCell.className,
                                 for: indexPath) as? SelectedPlaceCell else {
                                    return UICollectionViewCell()
        }
        
        return cell
    }
}

extension ProfileCompletePlaceCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var width = CGFloat()
        
        let title = "Label"
        width = title.width(font: UIFont.systemFont(ofSize: 14), height: 40)
        return CGSize(width: width + 18, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
