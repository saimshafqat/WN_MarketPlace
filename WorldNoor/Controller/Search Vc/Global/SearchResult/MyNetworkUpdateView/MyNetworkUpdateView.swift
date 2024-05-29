//
//  MyNetworkUpdateView.swift
//  SweetSpot
//
//  Created by Muhammad Asher Azeem on 08/10/2021.
//

import UIKit

@objc(MyNetworkUpdateView)
class MyNetworkUpdateView: SSBaseCollectionReusableView {
    
    @IBOutlet weak var containerView: UIView?
    @IBOutlet weak var emptyText: UILabel?
    @IBOutlet weak var emptyImage: UIImageView?
    
    // MARK: - init -
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    class func customInit() -> MyNetworkUpdateView? {
        return .loadNib()
    }
    
    // MARK: - Fuctions
    func setupView(text: String? = "No updates found") {
        // perform functionality
        emptyText?.text = text?.localized()
    }
    
    func setupImage() {
        // use if want to change image icon
    }
    
    func hideEmptyImage() {
        emptyImage?.isHidden = true
    }
}
