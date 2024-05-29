//
//  ProfileCompleteRelationsCell.swift
//  WorldNoor
//
//  Created by Omnia Samy on 25/01/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit

class ProfileCompleteRelationsCell: UICollectionViewCell {

    @IBOutlet weak var selectedDataCollectionView: UICollectionView!
    
    weak var delegate: ProfileWizardDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    @IBAction func closeTapped(_ sender: Any) {
        self.delegate?.closeTapped(isSkipped: true)
    }
    
    
    
    func bindData(){
        selectedDataCollectionView.register(UINib(nibName: SelectedRelationCell.className, bundle: nil),
                                             forCellWithReuseIdentifier: SelectedRelationCell.className)

    }
    @IBAction func selectRelationsTapped(_ sender: Any) {
        
    }
    
    @IBAction func skipTapped(_ sender: Any) {
        self.delegate?.closeTapped(isSkipped: true)
    }
    
    @IBAction func saveTapped(_ sender: Any) {
        
        
    }
    
}

extension ProfileCompleteRelationsCell: UICollectionViewDataSource , UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
        guard let cell = collectionView
            .dequeueReusableCell(withReuseIdentifier: SelectedRelationCell.className,
                                 for: indexPath) as? SelectedRelationCell else {
                                    return UICollectionViewCell()
        }
        
        return cell
    }
}

extension ProfileCompleteRelationsCell: UICollectionViewDelegateFlowLayout {

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
