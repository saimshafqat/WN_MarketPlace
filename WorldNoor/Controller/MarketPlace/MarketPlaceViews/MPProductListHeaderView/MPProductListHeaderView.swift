//
//  MPProductListHeaderView.swift
//  WorldNoor
//
//  Created by moeez akram on 28/05/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit

class MPProductListHeaderView: UICollectionReusableView {
    
    // MARK: - IBOutlets
    @IBOutlet weak var categoryNameLabel: UILabel!
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var filterLabel: UILabel!
    
    @IBOutlet weak var categorySelectorBtn: UIButton!
    static let headerName = "MPProductListHeaderView"

    weak var filterViewDelegate: FilterViewDelegate?

    @IBAction func categoryBtnTapped(_ sender: UIButton) {
        filterViewDelegate?.categoryClicked()
    }
    @IBAction func filterBtnTapped(_ sender: Any) {
        filterViewDelegate?.filterViewDelegate()
    }
    @IBAction func locationBtnTapped(_ sender: UIButton) {
        AppLogger.log("location tapped from category")
    }

    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    // MARK: - Private Methods
    private func commonInit() {
        // Custom initialization code if needed
    }
    
    // MARK: - Public Methods
    func configure(viewModel:MPProductListingViewModel) {
        if(viewModel.selectedApi != .category_items){
            categoryNameLabel.isHidden = true
            categorySelectorBtn.isHidden = true
        }else{
            categoryNameLabel.text = viewModel.categoryItem?.name
            let count = SharedManager.shared.filterItem.count
            filterLabel.text = count == 0 ? "Filters" : "Filters (\(count)"
            filterView.roundCorners(radius: 5, bordorColor: .lightGray, borderWidth: 1)
        }
    }

}
