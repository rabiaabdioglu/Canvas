//
//  CircleButtonWithText.swift
//  Canvas
//
//  Created by Rabia Abdioğlu on 9.09.2024.
//

import Foundation

import UIKit
import SnapKit

final class CircleButtonWithText: UIView {
    
    private let button: UIButton
    private let buttonLabel: UILabel
    
    var buttonTapped: (() -> Void)?
    
    init(frame: CGRect = .zero, imageName: String, title: String) {
        self.button = UIButton()
        self.buttonLabel = UILabel()
        
        super.init(frame: frame)
        
        setupUI(imageName: imageName, title: title)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(imageName: String, title: String) {
        let configuration = UIImage.SymbolConfiguration(pointSize: 25, weight: .regular)
        let iconImage = UIImage(systemName: imageName)?.withConfiguration(configuration)
        
        button.setImage(iconImage?.withTintColor(.clrFont, renderingMode: .alwaysOriginal), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.backgroundColor = .clrGray
        button.layer.cornerRadius = 40
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        
        
        addSubview(button)
        
        button.snp.makeConstraints { make in
            make.width.height.equalToSuperview()
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(10)
        }
        
        buttonLabel.text = title
        buttonLabel.textColor = .clrFont
        buttonLabel.textAlignment = .center
        buttonLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        
        addSubview(buttonLabel)
        
        buttonLabel.snp.makeConstraints { make in
            make.top.equalTo(button.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.8)
        }
    }
    
    @objc private func buttonAction() {
        buttonTapped?()
    }
}
