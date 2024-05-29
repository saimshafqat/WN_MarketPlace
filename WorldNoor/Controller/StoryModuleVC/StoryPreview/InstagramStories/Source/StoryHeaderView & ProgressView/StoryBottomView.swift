////
//  IGStoryPreviewHeaderView.swift
//  InstagramStories
//
//  Created by Boominadha Prakash on 06/09/17.
//  Copyright © 2017 DrawRect. All rights reserved.
//

import UIKit

//protocol StoryPreviewHeaderProtocol:class {func didTapCloseButton()}



final class StoryBottomView: UIView {
    
    //MARK: - iVars
    //    public weak var delegate:StoryPreviewHeaderProtocol?
    let snaperBtn:UIButton = {
        let btn = UIButton.init()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitleShadowColor(UIColor.black, for: .normal)
     //   btn.titleLabel!.shadowOffset = CGSize(width: -1, height: 1)
        btn.layer.masksToBounds = false
        btn.layer.shadowColor = UIColor.black.cgColor
        btn.layer.shadowOpacity = 1
        btn.layer.shadowOffset = CGSize(width: -1, height: 1)
        btn.layer.shadowRadius = 1
        return btn
    }()
    
    let countLbl:UILabel = {
        let viewLbl = UILabel.init()
        viewLbl.translatesAutoresizingMaskIntoConstraints = false
        viewLbl.textColor = UIColor.white
        viewLbl.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        viewLbl.translatesAutoresizingMaskIntoConstraints = false
        viewLbl.layer.masksToBounds = false
        viewLbl.layer.shadowColor = UIColor.black.cgColor
        viewLbl.layer.shadowOpacity = 1
        viewLbl.layer.shadowOffset = CGSize(width: -1, height: 1)
        viewLbl.layer.shadowRadius = 2
        return viewLbl    }()
    
    //MARK: - Overriden functions
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = frame
      //  loadUIElements()
      //  installLayoutConstraints()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //MARK: - Private functions
    private func loadUIElements(){
        backgroundColor = .clear
     //   addSubview(snaperBtn)
   //     addSubview(countLbl)
    }
    private func installLayoutConstraints(){
        //Setting constraints for progressView
        
        //Setting constraints for snapperImageView
        NSLayoutConstraint.activate([
            snaperBtn.widthAnchor.constraint(equalToConstant: 80),
            snaperBtn.heightAnchor.constraint(equalToConstant: 80),
            snaperBtn.igCenterYAnchor.constraint(equalTo: self.igCenterYAnchor),
            snaperBtn.igCenterXAnchor.constraint(equalTo: self.igCenterXAnchor),
            snaperBtn.topAnchor.constraint(equalTo: self.igTopAnchor, constant: 10)
        ])
        
        NSLayoutConstraint.activate([
            countLbl.widthAnchor.constraint(equalToConstant: 80),
            countLbl.heightAnchor.constraint(equalToConstant: 80),
            countLbl.igCenterXAnchor.constraint(equalTo: self.igCenterXAnchor, constant: 65),
            countLbl.igCenterYAnchor.constraint(equalTo: self.igCenterYAnchor),
            countLbl.topAnchor.constraint(equalTo: self.igTopAnchor, constant: 10)
        ])
        layoutIfNeeded()
        
    }
    
    //MARK: - Selectors
    //    @objc func didTapClose(_ sender: UIButton) {
    //        delegate?.didTapCloseButton()
    //    }
    
}
