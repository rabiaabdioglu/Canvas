//
//  NavigationBar.swift
//  Canvas
//
//  Created by Rabia Abdioğlu on 9.09.2024.
//

import UIKit
import SnapKit

class NavigationBar: UIView {
    
    // MARK: - Callbacks for button actions
    var onBackButtonTapped: (() -> Void)?
    var onUndoButtonTapped: (() -> Void)?
    var onRedoButtonTapped: (() -> Void)?
    var onNextButtonTapped: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = .clrBackground

        // MARK: - Left back button
        let backButton = UIButton(type: .system)
        backButton.setImage(UIImage(systemName: "chevron.left")?.withTintColor(.clrFont, renderingMode: .alwaysOriginal), for: .normal)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        addSubview(backButton)
        
        backButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
        }
        
        // MARK: - Undo and redo buttons in a stack
        let undoRedoStack = UIStackView()
        undoRedoStack.axis = .horizontal
        undoRedoStack.spacing = 20
        addSubview(undoRedoStack)
        
        let undoButton = UIButton(type: .system)
        undoButton.setImage(UIImage(systemName: "arrow.counterclockwise.circle")?.withTintColor(.clrGray, renderingMode: .alwaysOriginal), for: .normal)
        undoButton.addTarget(self, action: #selector(undoButtonTapped), for: .touchUpInside)
        
        undoRedoStack.addArrangedSubview(undoButton)
        
        let redoButton = UIButton(type: .system)
        redoButton.setImage(UIImage(systemName: "arrow.clockwise.circle")?.withTintColor(.clrGray, renderingMode: .alwaysOriginal), for: .normal)
        redoButton.addTarget(self, action: #selector(redoButtonTapped), for: .touchUpInside)
        
        undoRedoStack.addArrangedSubview(redoButton)
        
        undoRedoStack.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(3)
        }
        
        // MARK: - Right next button
        let nextButton = UIButton(type: .system)
        nextButton.setTitle("Next", for: .normal)
        nextButton.backgroundColor = .clrFont
        nextButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        nextButton.setTitleColor(.clrBackground, for: .normal)
        nextButton.layer.cornerRadius = 15
        nextButton.clipsToBounds = true
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        addSubview(nextButton)

        nextButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
            make.width.equalTo(60)
            make.height.equalTo(30)
        }
    }
    
    // MARK: - Button action handlers
    @objc private func backButtonTapped() {
        onBackButtonTapped?()
    }
    
    @objc private func undoButtonTapped() {
        onUndoButtonTapped?()
    }
    
    @objc private func redoButtonTapped() {
        onRedoButtonTapped?()
    }
    
    @objc private func nextButtonTapped() {
        onNextButtonTapped?()
    }
}
