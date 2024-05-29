//
//  GroupCatTableCell.swift
//  WorldNoor
//
//  Created by Raza najam on 3/27/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import UIKit

class GroupCatTableCell: UITableViewCell {
    
    @IBOutlet weak var descView: UIView!
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var groupCollectionView: UICollectionView!
    @IBOutlet weak var createNewBtn: UIButton!
    var catArray:[[String:Any]] = [[String:Any]]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func manageCategoryData(catArray:[[String:Any]]){
        self.catArray = catArray
        self.groupCollectionView.reloadData()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}

extension GroupCatTableCell:UICollectionViewDataSource, UICollectionViewDelegate , UICollectionViewDelegateFlowLayout
{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return self.catArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GroupCategoryCell", for: indexPath) as! GroupCategoryCell
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GroupCategoryCell", for: indexPath) as? GroupCategoryCell else {
           return UICollectionViewCell()
        }
        
        
        let catObj = self.catArray[indexPath.row]
//        cell.catImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
//        cell.catImageView.sd_setImage(with: URL(string: catObj["image_path"] as! String), placeholderImage: UIImage(named: "placeholder.png"))
        
        cell.catImageView.loadImageWithPH(urlMain:catObj["image_path"] as! String)
        self.labelRotateCell(viewMain: cell.catImageView)
        cell.nameLbl.text = (catObj["name"] as! String)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell,forItemAt indexPath: IndexPath)    {
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {

    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let dict = self.catArray[indexPath.row] as NSDictionary
        let groupObj = GroupValue.init()
        if let grpID = dict["id"] as? Int {
            groupObj.groupID = String(grpID)
        }
        groupObj.groupName = dict["name"] as! String
        groupObj.groupImage = dict["image_path"] as! String
        GroupHandler.shared.groupCategoryCallBackHandler!(groupObj)
    }
}


