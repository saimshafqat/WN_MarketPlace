//
//  LifeEventImageVideoView.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 28/12/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit

protocol LifeEventImageVideoDelegate: AnyObject {
    func deleteImageVideo(at indexPath: IndexPath)
    func playVideo(at indexPath: IndexPath?, obj: CreateLifeEventImageVideoModel?)
}

class LifeEventImageVideoView: UIView {

    // MARK: - Properties -
    var indexPath: IndexPath?
    var eventImageVideoDelegate: LifeEventImageVideoDelegate?
    var createLifeEventImageVideoModel: CreateLifeEventImageVideoModel?
    
    // MARK: - IBOutlets -
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var playView: UIView!
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var deleteView: UIView!
    @IBOutlet weak var btnDelete: UIButton!
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: UIScreen.main.bounds)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    // MARK: - IBActions -
    @IBAction func onClickDelete(_ sender: UIButton) {
        if let indexPath {
            eventImageVideoDelegate?.deleteImageVideo(at: indexPath)
        }
    }
    
    @IBAction func onClickPlay(_ sender: UIButton) {
        eventImageVideoDelegate?.playVideo(at: indexPath, obj: createLifeEventImageVideoModel)
    }
    
    // MARK: - Methods
    private func commonInit() {
        _ = loadNibView(.lifeEventImageVideoView)
        addSubview(contentView)
        contentView.setConstraintWithBoundary(self)
    }

    // main method
    public func displayViewContent(_ obj: Any? ,at indexPath: IndexPath) {
        self.indexPath = indexPath
        if let obj = obj as? CreateLifeEventImageVideoModel {
            self.createLifeEventImageVideoModel = obj
            let isTypeImage = obj.postType == .Image
            playView.isHidden = isTypeImage
            eventImage.image = obj.image?.compress(to: 100)
        }
    }
}
