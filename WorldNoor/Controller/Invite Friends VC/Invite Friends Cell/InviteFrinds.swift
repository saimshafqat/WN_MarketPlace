//
//  InviteFrinds.swift
//  WorldNoor
//
//  Created by apple on 12/14/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import Foundation
import UIKit
protocol shareDelegate {
    func shareDelegateAction(type : String)
}



struct ShareType {
    let FB = "FB"
    let Twitter = "Twitter"
    let GMail = "GMail"
    let WhatsApp = "WhatsApp"
    let SMS = "SMS"
    let FBSMS = "FBSMS"
    let Linkdin = "Linkdin"
    let Instagram = "Instagram"
    
    let Yahoo = "Yahoo"
    let Live = "Live"
    
    
}


class InviteSectionCell: UITableViewCell {
    
    var catArray:[ShareTypeCell]?
    
    @IBOutlet weak var groupCollectionView: UICollectionView!
    @IBOutlet weak var lblHeading: UILabel!
    @IBOutlet weak var imgViewBG: UIImageView!
    
    var seletedCell = -1
    var currentSection:IndexPath?
    
    var delegateType : shareDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func manageCategoryData(catArray:[ShareTypeCell], currentSection:IndexPath){
        self.currentSection = currentSection
        self.catArray = catArray
        self.groupCollectionView.reloadData()
    }
}

extension InviteSectionCell:UICollectionViewDataSource, UICollectionViewDelegate , UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return self.catArray!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InviteOtherCell", for: indexPath) as! InviteOtherCell
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InviteOtherCell", for: indexPath) as? InviteOtherCell else {
           return UICollectionViewCell()
        }
        
        cell.catImageView.image = UIImage.init(named: self.catArray![indexPath.row].imageShare!)
        
        if indexPath.row == self.seletedCell {
            cell.viewBG.RoundCornerWithColor(colorMain: UIColor.init(red: (237/255), green: (178/255), blue: (84/255), alpha: 1.0), cornerRadious: 5.0)
        }else {
            cell.viewBG.RoundCornerWithColor(colorMain: UIColor.init(red: 0.8, green: 0.8, blue: 0.8, alpha: 0.3), cornerRadious: 5.0)
        }
        
        
        cell.viewBG.backgroundColor = UIColor.white
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenSize: CGRect = self.frame
        return CGSize(width: ((screenSize.width/3)-13), height: self.frame.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell,forItemAt indexPath: IndexPath)    {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        seletedCell = indexPath.row
        self.groupCollectionView.reloadData()
        self.delegateType!.shareDelegateAction(type: self.catArray![indexPath.row].typeShare!)
    }
}



class InviteOtherCell: UICollectionViewCell {
    
    @IBOutlet weak var catImageView: UIImageView!
    @IBOutlet weak var viewBG: UIView!

}
