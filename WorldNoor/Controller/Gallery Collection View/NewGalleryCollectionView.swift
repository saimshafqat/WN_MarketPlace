//
//  NewGalleryCollectionView.swift
//  WorldNoor
//
//  Created by Lucky on 06/02/2020.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import UIKit

class NewGalleryCollectionView: UIViewController {

    @IBOutlet var collectionview : UICollectionView!
    
    
    var arrayColelction = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionview.register(UINib.init(nibName: "NewGalleryImageCell", bundle: nil), forCellWithReuseIdentifier: "NewGalleryImageCell")
        // Do any additional setup after loading the view.
    }
}


extension NewGalleryCollectionView : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellimage = collectionView.dequeueReusableCell(withReuseIdentifier: "NewGalleryImageCell", for: indexPath) as! NewGalleryImageCell
        
        cellimage.imageMain.image = UIImage.init(named: "DeleteBlack")
        return cellimage
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
}

