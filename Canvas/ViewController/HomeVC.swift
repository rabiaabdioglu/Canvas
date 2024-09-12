//
//  HomeVC.swift
//  Canvas
//
//  Created by Rabia Abdioğlu on 9.09.2024.
//
// HomeVC.swift

import UIKit
import SnapKit

class HomeVC: UIViewController {
    
    var goToCanvasButton: UIButton!
    var header: UILabel!
    var gridLineCountLabel: UILabel!
    var gridLineStepper: UIStepper!
    
    var templateSegmentedControl: UISegmentedControl!
    var templates = [
        ("16:9", (width: 1920, height: 1080)),
        ("4:3", (width: 1600, height: 1200)),
        ("1:1", (width: 1000, height: 1000)),
        ("21:9", (width: 2560, height: 1080))
    ]
    
    var selectedTemplate: (width: CGFloat, height: CGFloat) = (1000, 1000)
    var gridLineCount: Int = 4 {
        didSet {
            gridLineCountLabel.text = "Number of Grid Lines: \(gridLineCount)"
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
                
        header = UILabel()
        header.text = "Canvas App"
        header.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        header.textAlignment = .center
        view.addSubview(header)
        
        header.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(60)
            make.width.equalToSuperview()
            make.height.equalTo(50)
        }
        
        setupUI()
        
        goToCanvasButton = UIButton(type: .system)
        goToCanvasButton.setTitle("Create Canvas", for: .normal)
        goToCanvasButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        goToCanvasButton.backgroundColor = .clrFont
        goToCanvasButton.setTitleColor(.clrBackground, for: .normal)
        goToCanvasButton.layer.cornerRadius = 10
        goToCanvasButton.addTarget(self, action: #selector(goToCanvas), for: .touchUpInside)
        
        view.addSubview(goToCanvasButton)
        
        goToCanvasButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(100)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.8)
            make.height.equalTo(50)
        }
    }
    
    private func setupUI() {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .fill
        view.addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.top.equalTo(header.snp.bottom).offset(100)
            make.left.right.equalToSuperview().inset(40)
        }
        
        // Grid Line Count
        gridLineCountLabel = UILabel()
        gridLineCount = 4
        gridLineCountLabel.textColor = .clrFont
        gridLineCountLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        stackView.addArrangedSubview(gridLineCountLabel)
        
        gridLineStepper = UIStepper()
        gridLineStepper.minimumValue = 1
        gridLineStepper.maximumValue = 14
        gridLineStepper.stepValue = 1
        gridLineStepper.value = Double(gridLineCount)
        gridLineStepper.addTarget(self, action: #selector(stepperValueChanged), for: .valueChanged)
        stackView.addArrangedSubview(gridLineStepper)
        
        let templateLabel = UILabel()
        templateLabel.text = "Select Template"
        templateLabel.textColor = .clrFont
        templateLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        stackView.addArrangedSubview(templateLabel)
        
        // Segmented Control
        templateSegmentedControl = UISegmentedControl(items: templates.map { $0.0 })
        templateSegmentedControl.selectedSegmentIndex = 2
        templateSegmentedControl.addTarget(self, action: #selector(templateChanged), for: .valueChanged)
        view.addSubview(templateSegmentedControl)
        
        templateSegmentedControl.snp.makeConstraints { make in
            make.top.equalTo(templateLabel.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(40)
            make.height.equalTo(40)
        }
        
        let initialTemplate = templates[2].1
        selectedTemplate = (width: CGFloat(initialTemplate.width), height: CGFloat(initialTemplate.height))
    }
    
    @objc private func goToCanvas() {
        let canvasVC = CanvasPageVC()
        canvasVC.gridLineCount = gridLineCount
        canvasVC.canvasWidth = selectedTemplate.width
        canvasVC.canvasHeight = selectedTemplate.height
        navigationController?.pushViewController(canvasVC, animated: true)
    }
    
    @objc private func templateChanged() {
        let selectedIndex = templateSegmentedControl.selectedSegmentIndex
        let template = templates[selectedIndex].1
        selectedTemplate = (width: CGFloat(template.width), height: CGFloat(template.height))
    }
    
    @objc private func stepperValueChanged() {
        gridLineCount = Int(gridLineStepper.value)
    }
}

#Preview(body: {
    HomeVC()
})
