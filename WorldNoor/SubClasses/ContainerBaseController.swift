//
//  ContainerBaseController.swift
//  WorldNoor
//
//  Created by Muhammad Asher Azeem on 04/03/24.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import Foundation
import UIKit

class ContainerBaseController: UIViewController {
    
    // MARK: - Properties -
    var allViewControllers: [UIViewController] = []
    var currentChildController: UIViewController?
    
    // MARK: - IBActions -
    @IBOutlet weak var changeViewButton: UIButton?
    @IBOutlet var changeViewCollectionButton: [UIButton]?
    @IBOutlet weak var changeSegment: UISegmentedControl?
    @IBOutlet weak var childView: UIView!
    
    // MARK: - Life Cycle -
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    public func changeSegmentControlView(to index: Int) {
        guard let incomingViewController = allViewControllers[safe: index] else {
            print("Index out of range or view controller not found.")
            return
        }
        cycle(from: currentChildController, to: incomingViewController)
    }
    
    func cycle(from oldVC: UIViewController?, to newVC: UIViewController?) {
        guard oldVC !== newVC, let newVC = newVC else { return }
        newVC.view.frame = childView.bounds
        if let oldVC = oldVC {
            transitionChildControllers(from: oldVC, to: newVC)
        } else {
            addChildController(newVC)
        }
    }
    
    private func transitionChildControllers(from oldVC: UIViewController, to newVC: UIViewController) {
        oldVC.willMove(toParent: nil)
        addChild(newVC)
        
        transition(from: oldVC, to: newVC, duration: 0.3, options: .transitionCrossDissolve) {
            // Additional animations if needed
        } completion: { finished in
            oldVC.removeFromParent()
            newVC.didMove(toParent: self)
            self.currentChildController = newVC
        }
    }
    
    private func addChildController(_ childController: UIViewController) {
        addChild(childController)
        childView.addSubview(childController.view)
        childController.didMove(toParent: self)
        currentChildController = childController
    }
    
    @IBAction func changeViewSegment(_ sender: UISegmentedControl) {
        changeSegmentControlView(to: sender.selectedSegmentIndex)
    }
    
    @IBAction func changeViewAction(_ sender: UIButton) {
        changeSegmentControlView(to: sender.tag)
    }
    
    func buttonStyle(at btn: UIButton) {
        changeViewCollectionButton?.forEach({ button in
            if button.tag == btn.tag {
                animateButton(button: button)
            } else {
                button.backgroundColor = .clear
                button.setTitleColor(.black, for: .normal)
            }
        })
    }
    
    func animateButton(button: UIButton) {
        UIView.animate(withDuration: 0.2, animations: {
            // Change the background color to light grey
            button.backgroundColor = UIColor.systemGray6
            button.transform = CGAffineTransform(scaleX: 1.02, y: 1.02)
            button.setTitleColor(UIColor.blueColor, for: .normal)
        }) { _ in
            UIView.animate(withDuration: 0.2) {
                // Change the background color to light blue
                button.backgroundColor = UIColor().hexStringToUIColor(hex: "#F1F7FF")
                button.transform = .identity
                button.setTitleColor(UIColor.blueColor, for: .normal)
            }
        }
    }
    
    deinit {
        currentChildController = nil
    }
}


extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
