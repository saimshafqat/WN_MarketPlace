//
//  GenderTVCell.swift
//  YassirChallenge
//
//  Created by Walid Ahmed on 21/05/2023.
//

import UIKit

class GenderTVCell: UITableViewCell {

    @IBOutlet weak var detailsLbl: UILabel!
    @IBOutlet weak var selectedIcon: UIImageView!
    @IBOutlet weak var linebgV: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    
    var gender: Genders? {
        didSet {
            guard let gender = gender else { return }
            titleLbl.text = gender.title
            detailsLbl.text = gender.details
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func checkIfCellIsSelected(selectedIndex: Int, row: Int){
        if selectedIndex == row{
            selectedIcon.image = UIImage(named: "selectedCellIcon")
        }else{
            selectedIcon.image = UIImage(named: "unSelectedCellIcon")
        }
    }
    func hideAndShowViews(row: Int,array: [Genders]){
        if row == array.count - 1{
            linebgV.isHidden = true
            detailsLbl.isHidden = false
        }else{
            linebgV.isHidden = false
            detailsLbl.isHidden = true
        }
    }
    func hideAndShowViews(row: Int,array: [Genders],hideDetailsView: Bool){
        if row == array.count - 1{
            linebgV.isHidden = true
        }else{
            linebgV.isHidden = false
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
