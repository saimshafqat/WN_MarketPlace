//
//  MovieTableCell.swift
//  WorldNoor
//
//  Created by Raza najam on 3/27/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import UIKit
import AlamofireRSSParser

class MovieTableCell: UITableViewCell {
    @IBOutlet weak var groupCollectionView: UICollectionView!
    @IBOutlet weak var descLbl: UILabel!
    var rssFeedObj:RSSFeed?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func manageCategoryData(catArray:RSSFeed){
        self.rssFeedObj = catArray
        self.groupCollectionView.reloadData()
    }
}

extension MovieTableCell:UICollectionViewDataSource, UICollectionViewDelegate
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return self.rssFeedObj!.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GroupOtherCell", for: indexPath) as! GroupOtherCell
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GroupOtherCell", for: indexPath) as? GroupOtherCell else {
           return UICollectionViewCell()
        }
        
        let rssItem = self.rssFeedObj?.items[indexPath.row]
        cell.nameLbl.text = rssItem?.title

        if let arr = rssItem!.enclosures  {
            if arr.count > 0 {
                let dict:[String:String] = arr[0]
                let urlString = dict["url"]!
//                cell.catImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
//                cell.catImageView.sd_setImage(with: URL(string: urlString), placeholderImage: UIImage(named: "placeholder.png"))
                
                cell.catImageView.loadImageWithPH(urlMain:urlString)
                
                self.labelRotateCell(viewMain: cell.catImageView)
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenSize: CGRect = UIScreen.main.bounds
        return CGSize(width: ((screenSize.width/2)-3), height: self.frame.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell,forItemAt indexPath: IndexPath)    {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let rssItem = self.rssFeedObj?.items[indexPath.row]
        UIApplication.topViewController()?.OpenLink(webUrl: rssItem!.guid!)
        
    }
}

