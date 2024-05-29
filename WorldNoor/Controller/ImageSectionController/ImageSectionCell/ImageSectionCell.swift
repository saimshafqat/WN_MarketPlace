//
//  ImageSectionCell.swift
//  WorldNoor
//
//  Created by Raza najam on 3/27/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import UIKit


class ImageSectionCell: UITableViewCell {
    
    var catArray:NSArray?
    @IBOutlet weak var groupCollectionView: UICollectionView!
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var lblLoadMore: UILabel!
    @IBOutlet weak var btnLoadMore: UIButton!
    
    var currentSection:IndexPath?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func manageCategoryData(catArray:NSArray, currentSection:IndexPath){
        self.currentSection = currentSection
        self.catArray = catArray
        self.groupCollectionView.reloadData()
    }
}

extension ImageSectionCell:UICollectionViewDataSource, UICollectionViewDelegate , UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return self.catArray!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GroupOtherCell", for: indexPath) as! GroupOtherCell
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GroupOtherCell", for: indexPath) as? GroupOtherCell else {
           return UICollectionViewCell()
        }
        
        
        let dict = self.catArray![indexPath.row] as! NSDictionary
//        cell.catImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
//        cell.catImageView.sd_setImage(with: URL(string: dict["file_path"] as! String), placeholderImage: UIImage(named: "placeholder.png"))
        
        cell.catImageView.loadImageWithPH(urlMain:dict["file_path"] as! String)
        
        
        self.labelRotateCell(viewMain: cell.catImageView)
        if let name = dict["title"] as? String {
            cell.nameLbl.text = name
        }
        if let memberName = dict["author_name"] as? String {
            cell.countLbl.text = String(format: "by %@", memberName)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenSize: CGRect = UIScreen.main.bounds
//        return CGSize(width: ((screenSize.width/3)-3), height: self.frame.size.height)
        return CGSize(width: ((screenSize.width/3) - 20), height: 175.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell,forItemAt indexPath: IndexPath)    {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let dict = self.catArray![indexPath.row] as! NSDictionary
//        let groupObj = GroupValue.init()
//        groupObj.manageImageData(dict: dict)
        GroupHandler.shared.ImageSectionHandler!(self.currentSection!.row, indexPath.row)
    }
}
