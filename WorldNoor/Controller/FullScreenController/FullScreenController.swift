//
//  FullScreenController.swift
//  WorldNoor
//
//  Created by Raza najam on 11/1/19.
//  Copyright © 2019 Raza najam. All rights reserved.
//

import UIKit
import SDWebImage
class FullScreenController: UIViewController {
    public var minimumVelocityToHide = 1500 as CGFloat
    public var minimumScreenRatioToHide = 0.3 as CGFloat
    public var animationDuration = 0.3 as TimeInterval
    private lazy var transitionDelegate: TransitionDelegate = TransitionDelegate()
    var collectionArray:[PostFile] = []
    var isAppearFrom:String = ""
    var typeOfImage:String = "post"
    var commentObj:CommentFile?
    
    var isFromShare = false
    
    @IBOutlet weak var fullCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fullCollectionView.dataSource = self
        self.fullCollectionView.delegate = self
        (self.fullCollectionView?.collectionViewLayout as? UICollectionViewFlowLayout)?.estimatedItemSize = CGSize(width: 1, height: 1)
        
        self.testingPanGesture()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    func testingPanGesture(){
        self.transitioningDelegate = self.transitionDelegate
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)   {
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .overFullScreen;
        self.modalTransitionStyle = .coverVertical;
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.modalPresentationStyle = .overFullScreen;
        self.modalTransitionStyle = .coverVertical;
    }
    
    @objc func onPan(_ panGesture: UIPanGestureRecognizer) {
        let translation = panGesture.translation(in: self.view)
        let verticalMovement = translation.y / self.view.bounds.height
        let downwardMovement = fmaxf(Float(verticalMovement), 0.0)
        let downwardMovementPercent = fminf(downwardMovement, 1.0)
        let progress = CGFloat(downwardMovementPercent)
        let velocity = panGesture.velocity(in: self.view)
        let shouldFinish = progress > self.minimumScreenRatioToHide || velocity.y > self.minimumVelocityToHide
        switch panGesture.state {
        case .began:
            self.transitionDelegate.interactiveTransition.hasStarted = true
            self.dismiss(animated: true, completion: nil)
        case .changed:

            self.view.backgroundColor = UIColor.black.withAlphaComponent((1 - progress))
            self.transitionDelegate.interactiveTransition.shouldFinish = shouldFinish
            self.transitionDelegate.interactiveTransition.update(progress)
        case .cancelled:
            self.view.backgroundColor = UIColor.black.withAlphaComponent(1)
            self.transitionDelegate.interactiveTransition.hasStarted = false
            self.transitionDelegate.interactiveTransition.cancel()
        case .ended:
            self.transitionDelegate.interactiveTransition.hasStarted = false
            if self.transitionDelegate.interactiveTransition.shouldFinish {
                self.transitionDelegate.interactiveTransition.finish()
            }else {
                self.view.backgroundColor = UIColor.black.withAlphaComponent(1)
                self.transitionDelegate.interactiveTransition.cancel()
            }
        default:
            break
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        
//        if !self.isFromShare {
//            fullCollectionView.collectionViewLayout.invalidateLayout()
//        }
        
    }
}

extension FullScreenController:UICollectionViewDataSource, UICollectionViewDelegate   {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.typeOfImage == "comment" {
            return 1
        }
        return self.collectionArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        guard let cell = collectionView
                .dequeueReusableCell(withReuseIdentifier: Const.FullCollectionCell, for: indexPath) as? FullCollectionCell else {
           return UICollectionViewCell()
        }
        
        
        if self.typeOfImage == "post" {
            let postFile:PostFile = self.collectionArray[0] as PostFile
            cell.manageImageData(indexValue: indexPath.row,cellSize:self.fullCollectionView.frame.size, postFile:postFile)
        }else if self.typeOfImage == "comment" {
            cell.manageImageDataOfComment(indexValue: indexPath.row,cellSize:self.fullCollectionView.frame.size, commentObj:self.commentObj!)
        }
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(onPan(_:)))
        cell.imgScrollView.addGestureRecognizer(panGesture)
        cell.dismissClosure = { [weak self] in
            self?.dismiss(animated:true, completion:nil)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
    
    
    @IBAction func shareAction(sender : UIButton){
        self.isFromShare = true
//        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        let filePath = self.collectionArray[0].filePath ?? .emptyString
        guard let url = URL(string: filePath) else { return }
        FileDownloader.loadFileAsync(url: url) { (path, error) in
            if error == nil {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
//                    SharedManager.shared.hideLoadingHubFromKeyWindow()
                    Loader.stopLoading()
                    self.sharedata(dataMain: path ?? .emptyString, orignalFile: filePath, feedObj: FeedData.init(valueDict: [String : Any]()))
                }
            }
        }
    }
}
