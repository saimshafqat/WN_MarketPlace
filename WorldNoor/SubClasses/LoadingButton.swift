//
//  LoadingButon.swift
//  WorldNoor
//
//  Created by Muhammad Asher on 16/05/2023.
//

import UIKit

final class LoadingButton: UIButton {
    
    // MARK: - Properties -
    private let loader: UIActivityIndicatorView
    private var originalTitle: String?
    private var orignalImage: UIImage?
    private var isLoading: Bool = false
    
    // MARK: - CallBack
    private var tapClosure: (() -> Void)?
    
    // MARK: - Init
    override init(frame: CGRect) {
        loader = UIActivityIndicatorView(style: .medium)
        super.init(frame: frame)
        commonInit()
    }
    
    // MARK: - required
    required init?(coder aDecoder: NSCoder) {
        loader = UIActivityIndicatorView(style: .medium)
        super.init(coder: aDecoder)
        commonInit()
    }
    
    // MARK: - Methods
    private func commonInit() {
        addSubview(loader)
        loader.translatesAutoresizingMaskIntoConstraints = false
        loader.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        loader.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        loader.hidesWhenStopped = true
        loader.color = UIColor().hexStringToUIColor(hex: "#127FA5")
        
        addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    @objc private func buttonTapped() {
        // startLoading()
        tapClosure?()
    }
    
    func startLoading() {
        guard !(isLoading) else { return }
        isEnabled = false
        isLoading = true
        originalTitle = title(for: .normal)
        orignalImage = image(for: .normal)
        setTitle("", for: .normal)
        setImage(nil, for: .normal)
        loader.startAnimating()
    }
    
    func stopLoading() {
        isEnabled = true
        isLoading = false
        setTitle(originalTitle, for: .normal)
        setImage(orignalImage, for: .normal)
        originalTitle = nil
        orignalImage = nil
        loader.stopAnimating()
    }
    
    func setTapClosure(_ closure: (() -> Void)?) {
        tapClosure = closure
    }
}
