//
//  HomeVC.swift
//  Canvas
//
//  Created by Rabia Abdioğlu on 9.09.2024.
//

import Foundation
import UIKit

class HomeVC: UIViewController {

    var goToCanvasButton : UIButton!
    var header: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clrBackground
    
        
        header = UILabel()
        header.text = "Canvas App"
        header.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        header.textAlignment = .center
        view.addSubview(header)
        
        header.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(60)
            make.width.equalToSuperview()
            make.height.equalTo(50)
        }
        
        
        goToCanvasButton = UIButton(type: .system)
        goToCanvasButton.setTitle("Create Canvas", for: .normal)
        goToCanvasButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        goToCanvasButton.backgroundColor = .clrGray
        goToCanvasButton.setTitleColor(.clrFont, for: .normal)
        goToCanvasButton.layer.cornerRadius = 10
        goToCanvasButton.addTarget(self, action: #selector(goToCanvas), for: .touchUpInside)
        
        view.addSubview(goToCanvasButton)
        
        goToCanvasButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(200)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.8)
            make.height.equalTo(50)
        }
    }
    
    @objc private func goToCanvas() {
        let canvasVC = CanvasPageVC()
      navigationController?.pushViewController(canvasVC, animated: true)
    }
}
#Preview(body: {
    HomeVC()
})
