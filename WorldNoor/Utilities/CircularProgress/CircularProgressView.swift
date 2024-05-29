//
//  CircularProgressView.swift
//  TimeLeft Shape Sample
//
//  Created by Augray on 18/06/20.
//  Copyright © 2020 inDabusiness. All rights reserved.
//

import UIKit

class CircularProgressView: UIView {
    
    //  MARK: Private Variables
    
    var stopBtn: UIButton!
    private var retryBtn: UIButton!
    private var downloadBtn: UIButton!

    private var viewCenter: CGPoint {
        return CGPoint(x: frame.width / 2, y: frame.height / 2)
    }
    
    private var layerCenter: CGPoint {
        return CGPoint(x: progressLayer.frame.width / 2, y: progressLayer.frame.height / 2)
    }
    
    private var radius: CGFloat {
        return (self.progressLayer.frame.size.width) / 2
    }

    private var buttonSize: CGSize {
        let height = frame.height > 30 ? 30 : frame.height
        return CGSize(width: frame.width, height: height)
    }
    
    private var layerSize: CGRect {
        let size = frame.width > 35 ? 35 :frame.width
        return CGRect(origin: .zero, size: CGSize(width: size, height: size))
    }
    
    //  MARK: Public Variables
    
    var progress: CGFloat = 0.0 {
        didSet {
            removeRetryBtn()
            removeDownloadBtn()
            setup()
            self.setNeedsDisplay()
        }
    }
    
    var didProgressCompleted: (() -> Void)!
    var didStopBtnPressed: (() -> Void)!
    var didRetryBtnPressed: (() -> Void)!
    var didDownloadBtnPressed: (() -> Void)!

    var progressColor = UIColor.progressColor {
        didSet {
            progressLayer.strokeColor = progressColor.cgColor
        }
    }
    
    var trackColor = UIColor.progressTrackColor {
        didSet {
            backLayer.strokeColor = trackColor.cgColor
        }
    }
    
    var downloadFont = UIFont.systemFont(ofSize: 15) {
        didSet {
            downloadBtn?.titleLabel?.font = downloadFont
        }
    }
    
    var downloadTextColor = UIColor(red: 0.76, green: 0.76, blue: 0.76, alpha: 1.0) {
        didSet {
            downloadBtn?.setTitleColor(downloadTextColor, for: UIControl.State.normal)
        }
    }
    
    var retryFont = UIFont.systemFont(ofSize: 15) {
        didSet {
            retryBtn?.titleLabel?.font = retryFont
        }
    }
    
    var retryTextColor = UIColor(red: 0.76, green: 0.76, blue: 0.76, alpha: 1.0) {
        didSet {
            retryBtn?.setTitleColor(retryTextColor, for: UIControl.State.normal)
        }
    }
    
    lazy private var backLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = trackColor.cgColor
        layer.fillColor = trackColor.cgColor
        layer.lineWidth = 5.0
        layer.lineCap = .round
        return layer
    }()
    
    lazy private var progressLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = progressColor.cgColor
        layer.fillColor = UIColor.clear.cgColor
        layer.lineWidth = 5.0
        layer.lineCap = .round
        return layer
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
        setProperties()
    }
    
    override func awakeFromNib() {
        setProperties()
    }
    
    private func setup() {
        self.backgroundColor = .clear
        self.layer.addSublayer(self.backLayer)
        self.layer.addSublayer(self.progressLayer)
        addStopButton()
    }
    
    private func setProperties() {
        self.trackColor = UIColor.black.withAlphaComponent(0.4)
        self.progressColor = UIColor.progressColor
        self.progress = 1.0
    }
    
    override func draw(_ rect: CGRect) {
        self.backLayer.frame = layerSize // self.bounds.inset(by: UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1))
        self.backLayer.position = viewCenter
        self.backLayer.strokeColor = trackColor.cgColor

        self.progressLayer.frame = layerSize // self.bounds.inset(by: UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1))
        self.progressLayer.position = viewCenter
        self.progressLayer.strokeColor = progressColor.cgColor
        
        let circle = UIBezierPath.init(ovalIn: self.backLayer.bounds)
        self.backLayer.path = circle.cgPath
        
        let start = 0 - CGFloat(Double.pi / 2)
        let end = CGFloat(Double.pi) * 2 * progress - CGFloat(Double.pi / 2)
        let arc = UIBezierPath.init(arcCenter: layerCenter,
                                    radius: radius,
                                    startAngle: start, endAngle: end, clockwise: true)
        self.progressLayer.path = arc.cgPath
    }
    
    private func removeLayers() {
        backLayer.removeFromSuperlayer()
        progressLayer.removeFromSuperlayer()
    }
    
    private func addStopButton() {
        stopBtn?.removeFromSuperview()
        let image = UIImage(named: "stopUploading")
        stopBtn = UIButton(type: .custom)
        stopBtn.frame = layerSize
        stopBtn.center = viewCenter
        stopBtn.setImage(image, for: UIControl.State.normal)
        stopBtn.addTarget(self, action: #selector(stopBtnPressed), for: UIControl.Event.touchUpInside)
        stopBtn.backgroundColor = .clear
        addSubview(stopBtn)
    }
    
    func removeStopBtn() {
        stopBtn?.removeFromSuperview()
    }
    
    private func addRetryButton() {
        retryBtn?.removeFromSuperview()
        
        let image = UIImage(named: "upload")
        
        retryBtn = UIButton(type: .custom)
        retryBtn.frame = CGRect(origin: .zero, size: buttonSize)
        retryBtn.center = viewCenter
        retryBtn.setTitle("  RETRY", for: UIControl.State.normal)
        retryBtn.setImage(image, for: UIControl.State.normal)
        retryBtn.addTarget(self, action: #selector(retryBtnPressed), for: UIControl.Event.touchUpInside)
        retryBtn.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        retryBtn.titleLabel?.font = retryFont
        retryBtn.setTitleColor(retryTextColor, for: UIControl.State.normal)
        
        retryBtn.layer.masksToBounds = true
        retryBtn.layer.cornerRadius = 5
        
        addSubview(retryBtn)
    }
    
    private func removeRetryBtn() {
        retryBtn?.removeFromSuperview()
    }
    
    private func addDownloadButton() {
        downloadBtn?.removeFromSuperview()
        
        let image = UIImage(named: "download")

        downloadBtn = UIButton(type: .custom)
        downloadBtn.frame = CGRect(origin: .zero, size: buttonSize)
        downloadBtn.center = viewCenter
        downloadBtn.setTitle("  Download", for: UIControl.State.normal)
        downloadBtn.setImage(image, for: UIControl.State.normal)
        downloadBtn.addTarget(self, action: #selector(downloadBtnPressed), for: UIControl.Event.touchUpInside)
        downloadBtn.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        downloadBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        downloadBtn.titleLabel?.minimumScaleFactor = 0
        downloadBtn.titleLabel?.font = downloadFont
        downloadBtn.setTitleColor(downloadTextColor, for: UIControl.State.normal)
        
        downloadBtn.layer.masksToBounds = true
        downloadBtn.layer.cornerRadius = 5
        
        addSubview(downloadBtn)
    }
    
    private func removeDownloadBtn() {
        downloadBtn?.removeFromSuperview()
    }
    
    @objc private func stopBtnPressed() {
        didStopBtnPressed?()
    }
    
    @objc private func retryBtnPressed() {
        didRetryBtnPressed?()
    }
    
    @objc private func downloadBtnPressed() {
        didDownloadBtnPressed?()
    }
    
    //  MARK:   Public Methods
    
    func showRetry() {
        removeStopBtn()
        removeDownloadBtn()
        removeLayers()
        addRetryButton()
    }
    
    func showDownload() {
        removeStopBtn()
        removeRetryBtn()
        removeLayers()
        addDownloadButton()
    }
}
