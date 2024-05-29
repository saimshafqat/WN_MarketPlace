//
//  IGStoryPreviewHeaderView.swift
//  InstagramStories
//
//  Created by Boominadha Prakash on 06/09/17.
//  Copyright © 2017 DrawRect. All rights reserved.
//

import UIKit

protocol StoryPreviewHeaderProtocol:class {
    func didTapCloseButton()
    func didPausingSnapDelegate()
    func didResumeSnapDelegate()
    func didForwardSnapDelegate()
    func didDownloadSnapDelegate()
}

fileprivate let maxSnaps = 1000

//Identifiers
public let progressIndicatorViewTag = 800
public let progressViewTag = 1000

final class IGStoryPreviewHeaderView: UIView {
    
    //MARK: - iVars
    public weak var delegate:StoryPreviewHeaderProtocol?
    fileprivate var snapsPerStory:Int = 1
    private var viewModels: [DPArrowMenuViewModel] = []
    
    public var story:FeedVideoModel? {
        didSet {
            snapsPerStory  = (story?.snaps.count)! < maxSnaps ? (story?.snapsCount)! : maxSnaps
            
        }
    }
    fileprivate var progressView:UIView?
    fileprivate var progressView1:UIView?
    
    
    internal let snaperImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = imageView.frame.height/2
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 1.0
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    private let detailView:UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let snaperNameLabel:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        return label
    }()
    internal let lastUpdatedLabel:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 15.0)
        return label
    }()
    
    private lazy var backButton:UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(#imageLiteral(resourceName: "backWhiteArrow"), for: .normal)
        //      button.backgroundColor = UIColor.white
        button.addTarget(self, action: #selector(didTapBackButton(_:)), for: .touchUpInside)
        return button
    }()
    
    //Replacing close button logic with more button...
    private lazy var closeButton:UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(#imageLiteral(resourceName: "verw-dots"), for: .normal)
        //      button.backgroundColor = UIColor.white
        button.addTarget(self, action: #selector(didTapOptionButton(_:)), for: .touchUpInside)
        return button
    }()
    public var getProgressView: UIView {
        if let progressView = self.progressView {
            return progressView
        }
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        self.progressView = v
        self.addSubview(self.getProgressView)
     //   self.isHidden = true
        
        return v
    }
    public var getProgressView1: UIView {
        if let progressView = self.progressView1 {
            return progressView
        }
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        self.progressView = v
        self.addSubview(self.getProgressView1)
       
        
        return v
    }
    var type = ""
    //MARK: - Overriden functions
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = frame
        applyShadowOffset()
        loadUIElements()
        installLayoutConstraints()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //MARK: - Private functions
    private func loadUIElements(){
        backgroundColor = .clear
        addSubview(getProgressView)
      //  addSubview(snaperImageView)
      //  addSubview(detailView)
     //   detailView.addSubview(snaperNameLabel)
     //   detailView.addSubview(lastUpdatedLabel)
      //  addSubview(closeButton)
     //   addSubview(backButton)

        self.addOptions()
    }
    private func installLayoutConstraints(){
        //Setting constraints for progressView
        let pv = getProgressView
        NSLayoutConstraint.activate([
            pv.igLeftAnchor.constraint(equalTo: self.igLeftAnchor),
            pv.igTopAnchor.constraint(equalTo: self.igTopAnchor, constant: 8),
            self.igRightAnchor.constraint(equalTo: pv.igRightAnchor),
            pv.heightAnchor.constraint(equalToConstant: 10)
        ])
        
        //Setting constraints for snapperImageView
//        NSLayoutConstraint.activate([
//            snaperImageView.widthAnchor.constraint(equalToConstant: 40),
//            snaperImageView.heightAnchor.constraint(equalToConstant: 40),
//            snaperImageView.igLeftAnchor.constraint(equalTo: detailView.igLeftAnchor, constant: 10),
//            snaperImageView.igCenterYAnchor.constraint(equalTo: self.igCenterYAnchor),
//            detailView.igLeftAnchor.constraint(equalTo: snaperImageView.igRightAnchor, constant: 2)
//        ])
//        layoutIfNeeded() //To make snaperImageView round. Adding this to somewhere else will create constraint warnings.
        
        //Setting constraints for detailView
//        NSLayoutConstraint.activate([
////          detailView.igLeftAnchor.constraint(equalTo: snaperImageView.igRightAnchor, constant: 10),
//            detailView.igCenterYAnchor.constraint(equalTo: snaperImageView.igCenterYAnchor),
//            detailView.heightAnchor.constraint(equalToConstant: 40),
//            closeButton.igLeftAnchor.constraint(equalTo: detailView.igRightAnchor, constant: 10)
//        ])
        
        //Setting constraints for snapperImageView
//        NSLayoutConstraint.activate([
//            backButton.widthAnchor.constraint(equalToConstant: 30),
//            backButton.heightAnchor.constraint(equalToConstant: 30),
//            backButton.leftAnchor.constraint(equalTo: self.igLeftAnchor, constant: 5),
//            backButton.igCenterYAnchor.constraint(equalTo: self.igCenterYAnchor),
//            backButton.igRightAnchor.constraint(equalTo: detailView.igLeftAnchor, constant: 10)
//        ])
        //Setting constraints for closeButton
//        NSLayoutConstraint.activate([
//            closeButton.igLeftAnchor.constraint(equalTo: detailView.igRightAnchor, constant: 10),
//            closeButton.igCenterYAnchor.constraint(equalTo: self.igCenterYAnchor),
//            closeButton.igRightAnchor.constraint(equalTo: self.igRightAnchor),
//            closeButton.widthAnchor.constraint(equalToConstant: 60),
//            closeButton.heightAnchor.constraint(equalToConstant: 45)
//        ])
//
        //Setting constraints for snapperNameLabel
//        NSLayoutConstraint.activate([
//            snaperNameLabel.igLeftAnchor.constraint(equalTo: snaperImageView.rightAnchor, constant: 6.0),
//            detailView.igRightAnchor.constraint(equalTo: snaperNameLabel.igRightAnchor, constant: 10.0),
//            snaperNameLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 180),
//            snaperNameLabel.igCenterYAnchor.constraint(equalTo: detailView.igCenterYAnchor, constant: -8.0)
//        ])
        
        //Setting constraints for lastUpdatedLabel
//        NSLayoutConstraint.activate([
//            lastUpdatedLabel.igTopAnchor.constraint(equalTo: snaperNameLabel.igBottomAnchor, constant: -5),
//            lastUpdatedLabel.igRightAnchor.constraint(equalTo: detailView.igRightAnchor, constant:10.0),
//           // lastUpdatedLabel.igLeftAnchor.constraint(equalTo: snaperImageView.rightAnchor, constant:5.0),
//            lastUpdatedLabel.heightAnchor.constraint(equalToConstant: 30.0)
//        ])
    }
    private func applyShadowOffset() {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: -1, height: 1)
        layer.shadowRadius = 1
    }
    private func applyProperties<T: UIView>(_ view: T, with tag: Int? = nil, alpha: CGFloat = 1.0) -> T {
        view.layer.cornerRadius = 1
        view.layer.masksToBounds = true
        view.backgroundColor = UIColor.white.withAlphaComponent(alpha)
        if let tagValue = tag {
            view.tag = tagValue
        }
        return view
    }
    
    //MARK: - Selectors
    @objc func didTapOptionButton(_ sender: UIButton) {
        self.delegate?.didPausingSnapDelegate()
        self.showOptions(sender)
    }
    
    @objc func didTapBackButton(_ sender: UIButton) {
        delegate?.didTapCloseButton()
    }
    
    func addOptions() {
        let arrowMenuViewModel0 = DPArrowMenuViewModel(title: "Forward",
                                                       imageName: "")
        //      let arrowMenuViewModel1 = DPArrowMenuViewModel(title: "Forward",
        //                                                       imageName: "")
        
        viewModels.append(arrowMenuViewModel0)
        //      viewModels.append(arrowMenuViewModel1)
        
    }
    
    func showOptions(_ sender: Any) {
        viewModels.removeAll()
        if self.type == "text" {
            let arrowMenuViewModel0 = DPArrowMenuViewModel(title: "Forward",
                                                           imageName: "")
            viewModels.append(arrowMenuViewModel0)
        }else {
            let arrowMenuViewModel0 = DPArrowMenuViewModel(title: "Forward",
                                                           imageName: "")
            let arrowMenuViewModel1 = DPArrowMenuViewModel(title: "Download",
                                                           imageName: "")
            viewModels.append(arrowMenuViewModel0)
          viewModels.append(arrowMenuViewModel1)
        }
        
        guard let view = sender as? UIView else { return }
        DPArrowMenu.show(view, viewModels: viewModels, done: { [weak self] index in
            if index == 0 {
                self!.delegate?.didForwardSnapDelegate()

            }else if index == 1 {
                self?.delegate?.didDownloadSnapDelegate()
            }
        }) {
            self.delegate?.didResumeSnapDelegate()
        }
    }
    
    //MARK: - Public functions
    public func clearTheProgressorSubviews() {
        getProgressView.subviews.forEach { v in
            v.subviews.forEach{v in (v as! IGSnapProgressView).stop()}
            v.removeFromSuperview()
        }
    }
    
    public func createSnapProgressors(){
        let padding: CGFloat = 8 //GUI-Padding
        let height: CGFloat = 3
        var pvIndicatorArray: [UIView] = []
        var pvArray: [IGSnapProgressView] = []
        
        // Adding all ProgressView Indicator and ProgressView to seperate arrays
        for i in 0..<snapsPerStory{
            let pvIndicator = UIView()
            pvIndicator.translatesAutoresizingMaskIntoConstraints = false
            getProgressView.addSubview(applyProperties(pvIndicator, with: i+progressIndicatorViewTag, alpha:0.2))
            pvIndicatorArray.append(pvIndicator)
            
            let pv = IGSnapProgressView()
            pv.translatesAutoresizingMaskIntoConstraints = false
            pvIndicator.addSubview(applyProperties(pv))
            pvArray.append(pv)
        }
        // Setting Constraints for all progressView indicators
        for index in 0..<pvIndicatorArray.count {
            let pvIndicator = pvIndicatorArray[index]
            if index == 0 {
                NSLayoutConstraint.activate([
                    pvIndicator.igLeftAnchor.constraint(equalTo: self.getProgressView.igLeftAnchor, constant: padding),
                    pvIndicator.igCenterYAnchor.constraint(equalTo: self.getProgressView.igCenterYAnchor),
                    pvIndicator.heightAnchor.constraint(equalToConstant: height)
                ])
                if pvIndicatorArray.count == 1 {
                    self.getProgressView.igRightAnchor.constraint(equalTo: pvIndicator.igRightAnchor, constant: padding).isActive = true
                }
            }else {
                let prePVIndicator = pvIndicatorArray[index-1]
                NSLayoutConstraint.activate([
                    pvIndicator.igLeftAnchor.constraint(equalTo: prePVIndicator.igRightAnchor, constant: padding),
                    pvIndicator.igCenterYAnchor.constraint(equalTo: prePVIndicator.igCenterYAnchor),
                    pvIndicator.heightAnchor.constraint(equalToConstant: height),
                    pvIndicator.widthAnchor.constraint(equalTo: prePVIndicator.widthAnchor, multiplier: 1.0)
                ])
                if index == pvIndicatorArray.count-1 {
                    self.igRightAnchor.constraint(equalTo: pvIndicator.igRightAnchor, constant: padding).isActive = true
                }
            }
        }
        // Setting Constraints for all progressViews
        for index in 0..<pvArray.count {
            let pv = pvArray[index]
            let pvIndicator = pvIndicatorArray[index]
            pv.widthConstraint = pv.widthAnchor.constraint(equalToConstant: 0)
            NSLayoutConstraint.activate([
                pv.igLeftAnchor.constraint(equalTo: pvIndicator.igLeftAnchor),
                pv.heightAnchor.constraint(equalTo: pvIndicator.heightAnchor),
                pv.igTopAnchor.constraint(equalTo: pvIndicator.igTopAnchor),
                pv.widthConstraint!
            ])
        }
        snaperNameLabel.text = story?.authorName
    }
}
