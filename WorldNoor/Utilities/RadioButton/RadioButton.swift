//
//  RadioButton.swift
//  WorldNoor
//
//  Created by Awais on 09/05/2024.
//  Copyright © 2024 Raza najam. All rights reserved.
//

import Foundation
import UIKit

protocol RadioButtonDelegate: AnyObject {
    func radioButtonDidSelect(_ radioButton: RadioButton)
}

struct RadioButtonItem {
    let radioId: String
    let radioTitle: String
    let radioDescription: String?
}

class RadioButton: UIView {
    
    weak var delegate: RadioButtonDelegate?
    
    var isSelected: Bool = false {
        didSet {
            radioButton.isSelected = isSelected
        }
    }
    
    var radioButtonItem: RadioButtonItem?
    
    private let radioButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "mark_selected_raduio_unselected_icon"), for: .normal)
        button.setImage(UIImage(named: "mark_selected_raduio_icon"), for: .selected)
        button.isUserInteractionEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue-Regular", size: 14.0)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue-Regular", size: 10.0)
        label.textColor = .darkGray
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    init(radioItem: RadioButtonItem) {
        super.init(frame: .zero)
        titleLabel.text = radioItem.radioTitle
        descriptionLabel.text = radioItem.radioDescription
        self.radioButtonItem = radioItem
        setupViews()
        setupConstraints()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(radioButtonTapped))
        addGestureRecognizer(tapGesture)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(descriptionLabel)
        addSubview(radioButton)
        addSubview(stackView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            radioButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            radioButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            radioButton.widthAnchor.constraint(equalToConstant: 20),
            radioButton.heightAnchor.constraint(equalToConstant: 20),
            
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.trailingAnchor.constraint(equalTo: radioButton.leadingAnchor, constant: -8),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        // Conditionally hide description label if empty
        descriptionLabel.isHidden = descriptionLabel.text == nil
    }
    
    func reset() {
        isSelected = false
        delegate?.radioButtonDidSelect(self)
    }
    
    @objc private func radioButtonTapped() {
        isSelected = !isSelected
        delegate?.radioButtonDidSelect(self)
    }
    
    static func resetAll(in view: UIView) {
        for subview in view.subviews where subview is RadioButton {
            if let radioButton = subview as? RadioButton {
                radioButton.reset()
            }
        }
    }
}
