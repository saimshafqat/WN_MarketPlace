//
//  GroupOtherTableCell.swift
//  WorldNoor
//
//  Created by Raza najam on 3/27/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import UIKit

class PageCell: UITableViewCell {
    
    @IBOutlet weak var groupCollectionView: UICollectionView!
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var lblNoPost: UILabel!
    var catArray:NSArray?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func manageCategoryData(catArray:NSArray){
        self.lblNoPost.isHidden = true
        
        self.catArray = catArray
        self.groupCollectionView.reloadData()
        self.lblNoPost.text = "No page found".localized()
        if self.catArray?.count == 0 {
            self.lblNoPost.isHidden = false
        }
    }
}

extension PageCell:UICollectionViewDataSource, UICollectionViewDelegate , UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return self.catArray!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GroupOtherCell", for: indexPath) as? GroupOtherCell else {
           return UICollectionViewCell()
        }
        
        
        let dict = self.catArray![indexPath.row] as! NSDictionary
//        cell.catImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
//        cell.catImageView.sd_setImage(with: URL(string: dict["cover_file_path"] as! String), placeholderImage: UIImage(named: "placeholder.png"))
        
        cell.catImageView.loadImageWithPH(urlMain:dict["cover_file_path"] as! String)
        
        self.labelRotateCell(viewMain: cell.catImageView)
        cell.countLbl.text = String(format: "0 " + "Liked".localized())
        if let totalCount = dict["total_likes"] as? Int {
            if totalCount == 0 {
                cell.countLbl.text = ""
            }else if totalCount == 1 {
                cell.countLbl.text = String(format: "%d " + "Liked".localized(), totalCount)
            }else {
                cell.countLbl.text = String(format: "%d " + "Liked".localized(), totalCount)
            }
        }
        cell.nameLbl.text = (dict["title"] as! String)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenSize: CGRect = UIScreen.main.bounds
        return CGSize(width: ((screenSize.width/3)-3), height: self.frame.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell,forItemAt indexPath: IndexPath)    {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let dict = self.catArray![indexPath.row] as! NSDictionary
        let groupObj = GroupValue.init()
        groupObj.managePageData(dict: dict)
        GroupHandler.shared.groupCallBackHandler!(groupObj)
    }
}

