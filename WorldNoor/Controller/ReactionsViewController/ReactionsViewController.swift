//
//  ReactionsViewController.swift
//  Worldnoor
//
//  Created by apple on 5/28/22.
//  Copyright © 2022 apple. All rights reserved.
//

import UIKit
import SDWebImage

class ReactionCell: UITableViewCell {
    
    @IBOutlet weak var reactionImage: UIImageView!
    @IBOutlet weak var personName: UILabel!
    @IBOutlet weak var personImage: UIImageView!
}

class ReactionsViewController: UIViewController {
    
    var message_id = ""
    var message:Message?
    var segmentView = SMSegmentView()
    var types = SharedManager.shared.arrayGif
    var reactionArray: [String: [Reaction]] = [:]
    var reactionDataArray = [[Reaction]]()
    
    @IBOutlet weak var tableView: UITableView!{
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.tableFooterView = UIView()
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = []
        getReactionDetails()
    }
    
    func getReactionDetails() {
        if let reactionSet = self.message?.toReaction as? Set<Reaction> {
            let reactionArr = Array(reactionSet)
            for reactionType in SharedManager.shared.arrayChatGif {
                let reactionArr = reactionArr.filter { $0.reaction == reactionType }
                if reactionArr.count > 0 {
                    reactionArray[reactionType] = reactionArr
                }
            }
        }
        
        if self.reactionArray.count > 0 {
            self.addSegment()
        }
    }
    
    func addSegment() {
        let appearance = SMSegmentAppearance()
        appearance.segmentOnSelectionColour = .vLightGrayColor
        appearance.segmentOffSelectionColour = UIColor.white
        appearance.titleOnSelectionColour = UIColor.black
        appearance.titleOffSelectionColour = UIColor.black
        appearance.titleOnSelectionFont = UIFont.systemFont(ofSize: 12.0)
        appearance.titleOffSelectionFont = UIFont.systemFont(ofSize: 12.0)
        appearance.contentVerticalMargin = 10.0
        let rect = CGRect(x: 0,y: 20,width: ScreenSizeUtil.width(),height: 40)
        
        segmentView = SMSegmentView(frame: rect, dividerColour: UIColor(white: 0.95, alpha: 0.3), dividerWidth: 1.0, segmentAppearance: appearance)
        // Add segments
        if let likeArr = self.reactionArray["like"] {
            segmentView.addSegmentWithTitle("(\(likeArr.count))", onSelectionImage: UIImage(named: "like"), offSelectionImage: UIImage(named: "like"))
            reactionDataArray.append(likeArr)
        }
        if let happyArr = self.reactionArray["happy"] {
            segmentView.addSegmentWithTitle("(\(happyArr.count))", onSelectionImage: UIImage(named: "happy"), offSelectionImage: UIImage(named: "happy"))
            reactionDataArray.append(happyArr)
        }
        if let cryArr = self.reactionArray["cry"] {
            segmentView.addSegmentWithTitle("(\(cryArr.count))", onSelectionImage: UIImage(named: "cry"), offSelectionImage: UIImage(named: "cry"))
            reactionDataArray.append(cryArr)
            
        }
        if let laughArr = self.reactionArray["laugh"] {
            segmentView.addSegmentWithTitle("(\(laughArr.count))", onSelectionImage: UIImage(named: "laugh"), offSelectionImage: UIImage(named: "laugh"))
            reactionDataArray.append(laughArr)
            
        }
        if let sadArr = self.reactionArray["sad"] {
            segmentView.addSegmentWithTitle("(\(sadArr.count))", onSelectionImage: UIImage(named: "sad"), offSelectionImage: UIImage(named: "sad"))
            reactionDataArray.append(sadArr)
            
        }
        if let angryArr = self.reactionArray["angry"] {
            segmentView.addSegmentWithTitle("(\(angryArr.count))", onSelectionImage: UIImage(named: "angry"), offSelectionImage: UIImage(named: "angry"))
            reactionDataArray.append(angryArr)
            
        }
        
        segmentView.addTarget(self, action: #selector(selectSegmentInSegmentView(segmentView:)), for: .valueChanged)
        segmentView.selectedSegmentIndex = 0
        self.view.addSubview(segmentView)
    }
    
    // SMSegment selector for .ValueChanged
    @objc func selectSegmentInSegmentView(segmentView: SMSegmentView) {
        print("Select segment at index: \(segmentView.selectedSegmentIndex)")
        self.tableView.reloadData()
    }
}


extension ReactionsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if reactionDataArray.count > 0 {
            return reactionDataArray[segmentView.selectedSegmentIndex].count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ReactionCell.className, for: indexPath) as! ReactionCell
        
        let reactionArr = reactionDataArray[segmentView.selectedSegmentIndex]
        let person = reactionArr[indexPath.row]
        cell.personName.text = person.firstName
        
        if let url = URL(string: person.profileImage){
            cell.personImage.sd_setImage(with: url, completed: nil)
            cell.personImage.circularView()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
