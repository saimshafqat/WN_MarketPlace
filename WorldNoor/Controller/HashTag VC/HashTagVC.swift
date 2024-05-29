//
//  HashTagVC.swift
//  WorldNoor
//
//  Created by Waseem Shah on 11/10/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import Foundation
import UIKit
import Charts

class HashTagVC : UIViewController {
    
    @IBOutlet weak var lineChartView: LineChartView!
    
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblMain: UILabel!
    
    @IBOutlet weak var lblTotalPost         : UILabel!
    @IBOutlet weak var lblTotalContributors : UILabel!
    
    var isFromReelScreen: Bool = false
    
    var tagModel : TagsModel!
    var Hashtags : String = ""
    let xData = ["1 am", "2 am", "3 am", "4 am", "5 am", "6 am", "7 am", "8 am", "9 am", "10 am", "11 am", "12 am", "1 pm", "2 pm", "3 pm", "4 pm", "5 pm", "6 pm", "7 pm", "8 pm", "9 pm", "10 pm", "11 pm"]
    
    
    override func viewDidLoad() {
        
    }
    
    func showChart() {
        
        var yData = [Int]()
        
        
        for indexObj in xData {
            
            if let objectIndex = self.tagModel.data!.graph_data!.first(where: {$0.hour!.lowercased() == indexObj.lowercased()}) {
                yData.append(objectIndex.count!)
            }else {
                yData.append(0)
            }
        }
        var entries : [ChartDataEntry] = []
        
        for i in 0..<xData.count {
            entries.append(ChartDataEntry(x: convertTimeToTimeInterval(xData[i]), y: Double(yData[i])))
        }
        
        let dataSet = LineChartDataSet(entries: entries, label: "Hourly trend")
        
        dataSet.colors = [NSUIColor.blue]
        dataSet.drawCirclesEnabled = true
        dataSet.circleRadius = 2.0
        
        let data = LineChartData(dataSet: dataSet)
        lineChartView.data = data
        
        lineChartView.xAxis.labelPosition = .bottom
        lineChartView.xAxis.drawGridLinesEnabled = true
        lineChartView.xAxis.valueFormatter = DateValueFormatter()
        lineChartView.xAxis.labelCount = xData.count
        
        lineChartView.leftAxis.axisMinimum = 0.0
        lineChartView.rightAxis.axisMinimum = 0.0
    }
    
    func convertTimeToTimeInterval(_ timeString: String) -> TimeInterval {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let currentDate = Date()
        let commonDateString = dateFormatter.string(from: currentDate)
        
        let dateTimeString = "\(commonDateString) \(timeString)"
        
        dateFormatter.dateFormat = "yyyy-MM-dd h a"
        
        var timeInterval: TimeInterval = 0.0
        if let date = dateFormatter.date(from: dateTimeString) {
            timeInterval = date.timeIntervalSince1970
        }
        
        return timeInterval
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if isFromReelScreen {
            visibleNavigation()
        }
        self.lblMain.text = ""
        self.lblDescription.text = ""
        self.lblTotalPost.text = ""
        self.lblTotalContributors.text = ""
        self.callAPI()
    }
    
    func visibleNavigation() {
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    func callAPI(){
        
        
//        SharedManager.shared.showOnWindow()
        Loader.startLoading()
        var parameters = ["action": "hashtag-count","token":SharedManager.shared.userToken()]
        parameters["hash_tag_name"] = self.Hashtags

        
        RequestManagerGen.fetchDataGet(Completion: { (response: Result<(TagsModel), Error>) in
//            SharedManager.shared.hideLoadingHubFromKeyWindow()
            Loader.stopLoading()
            switch response {
            case .failure(let error):
                if error is ErrorModel  {
                    let err = error as! ErrorModel
                    if ((err.meta?.message!.contains("not found")) != nil) {

                    }else if err.meta?.code == ResponseKey.unAuthorizedResp.rawValue {
                        AppDelegate.shared().loadLoginScreen()
                    }
                }
            case .success(let res):
                self.handleFeedResponse(tagObj: res)
            }
        }, param:parameters)
    }
    
    func handleFeedResponse(tagObj:TagsModel){
        
        self.tagModel = tagObj
        self.lblMain.text = tagObj.data?.hash_tag_name
        self.lblDescription.text = tagObj.data?.hash_tag_description
        
        self.lblTotalPost.text = String(tagObj.data?.news_feed ?? 0)
        self.lblTotalContributors.text = String(tagObj.data?.contributors_count ?? 0)
        
        self.showChart()
    }
    
    @IBAction func showAllPost(sender : UIButton){
        let tagSection = AppStoryboard.More.instance.instantiateViewController(withIdentifier: "TagsVC") as! TagsVC
        tagSection.Hashtags = self.Hashtags
        UIApplication.topViewController()!.navigationController?.pushViewController(tagSection, animated: true)

    }
}

public class DateValueFormatter: NSObject, AxisValueFormatter {
    
    private let dateFormatter = DateFormatter()
    override init() {
        super.init()
        dateFormatter.dateFormat = "h"
    }
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let formattedDate = dateFormatter.string(from: Date(timeIntervalSince1970: value))

        return formattedDate
    }
}
