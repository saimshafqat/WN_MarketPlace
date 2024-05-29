//
//  LoaderViewVC.swift
//  NewLoader
//
//  Created by apple on 10/6/22.
//

import Foundation
import UIKit
import Lottie

class LoaderViewVC : UIViewController {
    
    @IBOutlet weak var viewAnim: AnimationView!
    
    override func viewDidLoad() {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadLottie(name: "WNLoading")
    }
    
    
    func loadLottie(name: String){
        // 1. Start AnimationView with animation name (without extension)
        let path = Bundle.main.path(forResource: name,
                                    ofType: "json") ?? ""
        viewAnim.animation = Animation.filepath(path)
        viewAnim.contentMode = .scaleAspectFit
        viewAnim.loopMode = .loop
        viewAnim.play()
    }
    
    
}
