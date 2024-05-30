//
//  MarkerPlaceForYouHeaderView.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 05/03/24.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import UIKit
protocol FilterViewDelegate: AnyObject {
    func filterViewDelegate()
    func categoryClicked()
    func createListingTapped()
    func sortTapped()
    func locationTapped()
}
@objc(MarkerPlaceForYouHeaderView)
class MarkerPlaceForYouHeaderView: SSBaseCollectionReusableView {
    
    class func customInit() -> MarkerPlaceForYouHeaderView? {
        return .loadNib()
    }
    
    static let headerName = "MarkerPlaceForYouHeaderView"

    // MARK: - Properties -
    @IBOutlet weak var categoryListName: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var actionBtn: UIButton!
    @IBOutlet weak var filterOrLocation: UIImageView!

    weak var filterViewDelegate: FilterViewDelegate?
    // MARK: - Methods -
    func configureView(obj: AnyObject?, parentObj: AnyObject? ,indexPath: IndexPath) {
        locationView.isHidden = (indexPath.section != 0)
        if let itemSection = obj as? SSSection {
            categoryListName.text = itemSection.header
            if let pObj = parentObj as? MarketPlaceForYouUser {
                filterOrLocation.image = UIImage(named: "mark_location_icon")
                locationLabel.text = pObj.city + " " + pObj.country
            }
        }
    }
    
    @IBAction private func btnLocationOrFilter_Pressed(_ sender: UIButton) {
        filterViewDelegate?.filterViewDelegate()
    }
}
