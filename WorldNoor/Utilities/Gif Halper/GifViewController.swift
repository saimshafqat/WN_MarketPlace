//
//  GifViewController.swift
//  WorldNoor
//
//  Created by Awais on 25/12/2023.
//  Copyright © 2023 Raza najam. All rights reserved.
//

import UIKit
import Kingfisher

class GifViewController: UIViewController {
    var gifURL: URL!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black

        let animatedImageView = UIImageView()
        animatedImageView.contentMode = .scaleAspectFit
        view.addSubview(animatedImageView)
        animatedImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            animatedImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            animatedImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            animatedImageView.topAnchor.constraint(equalTo: view.topAnchor),
            animatedImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        animatedImageView.kf.setImage(with: gifURL, options: [.transition(.fade(1))])

        let closeButton = UIButton(type: .system)
        closeButton.setTitle("✕", for: .normal)
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 24)
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        view.addSubview(closeButton)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
        ])
    }

    @objc func closeButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
}
