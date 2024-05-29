//
//  GroupOtherTableCell.swift
//  WorldNoor
//
//  Created by Raza najam on 3/27/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import UIKit

class GroupOtherTableCell: UITableViewCell {
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
        self.lblNoPost.text = "No groups availalbe.".localized()
        self.catArray = catArray
        self.groupCollectionView.reloadData()
        
        if self.catArray!.count == 0 {
            self.lblNoPost.isHidden = false
        }
    }
}

extension GroupOtherTableCell:UICollectionViewDataSource, UICollectionViewDelegate , UICollectionViewDelegateFlowLayout
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
//        cell.catImageView.sd_setImage(with: URL(string: dict["cover_photo_path"] as! String), placeholderImage: UIImage(named: "placeholder.png"))
        
        
        cell.catImageView.loadImageWithPH(urlMain:dict["cover_photo_path"] as! String)
        
        self.labelRotateCell(viewMain: cell.catImageView)
        if let totalCount = dict["total_members"] as? Int {
            if totalCount == 0 {
                cell.countLbl.text = "No member.".localized()
            }else if totalCount == 1 {
                cell.countLbl.text = String(format: "%d " + "member".localized(), totalCount)
            }else {
                cell.countLbl.text = String(format: "%d " + "members".localized(), totalCount)
            }
        }
        cell.nameLbl.text = (dict["name"] as! String)
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
        groupObj.manageGroupData(dict: dict)
        GroupHandler.shared.groupCallBackHandler!(groupObj)
    }
}

