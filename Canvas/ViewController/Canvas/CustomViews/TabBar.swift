//
//  TabBar.swift
//  Canvas
//
//  Created by Rabia Abdioğlu on 9.09.2024.
//

import Foundation
import UIKit
import SnapKit

protocol TabBarDelegate: AnyObject {
    func customTabBarDidTapAddButton(_ tabBar: TabBar)
}

class TabBar: UIView, UITabBarDelegate {
    
    // MARK: - Delegate for tab bar actions
    weak var delegate: TabBarDelegate?
    private let tabBar = UITabBar()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        configureTabBarAppearance()
        configureTabBarItems()
        setupLayout()
    }
    
    // MARK: - Configure tab bar appearance
    private func configureTabBarAppearance() {
        tabBar.delegate = self
        let appearance = UITabBarAppearance()
        appearance.backgroundColor = .clrBackground
        
        let normalAppearance = appearance.stackedLayoutAppearance.normal
        let selectedAppearance = appearance.stackedLayoutAppearance.selected
        
        configureItemAppearance(normalAppearance, color: .clrFont)
        configureItemAppearance(selectedAppearance, color: .clrGray)
        
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        tabBar.isTranslucent = false
        addSubview(tabBar)
    }
    
    // MARK: - Configure item appearance
    private func configureItemAppearance(_ itemAppearance: UITabBarItemStateAppearance, color: UIColor) {
        itemAppearance.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 13),
            .foregroundColor: color
        ]
        itemAppearance.iconColor = color
        itemAppearance.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 10)
    }
    
    // MARK: - Configure tab bar items
    private func configureTabBarItems() {
        let items = [
            UITabBarItem(title: "Background", image: systemIcon("circle.circle", size: 20), tag: 0),
            UITabBarItem(title: "Text", image: systemIcon("t.circle", size: 20), tag: 1),
            UITabBarItem(title: "", image: systemIcon("plus.circle.fill", size: 30), tag: 2),
            UITabBarItem(title: "Ratio", image: systemIcon("45.square", size: 20), tag: 3),
            UITabBarItem(title: "Slides", image: systemIcon("4.square", size: 20), tag: 4)
        ]
        tabBar.items = items
    }
    
    private func systemIcon(_ name: String, size: CGFloat) -> UIImage? {
        return UIImage(systemName: name)?.withConfiguration(UIImage.SymbolConfiguration(pointSize: size, weight: .bold))
    }
    
    // MARK: - Setup layout constraints
    private func setupLayout() {
        let tabBarContainer = UIView()
        tabBarContainer.backgroundColor = .clrBackground
        
        addSubview(tabBarContainer)
        tabBarContainer.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(90)
        }
        
        tabBarContainer.addSubview(tabBar)
        tabBar.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(30)
            make.height.equalTo(100)
        }
        
        // Top border
        let topBorder = UIView()
        topBorder.backgroundColor = .clrFont
        
        tabBarContainer.addSubview(topBorder)
        topBorder.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(2)
        }
    }
    
    // MARK: - Handle tab bar item selection
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        switch item.tag {
        case 0: print("Background tapped")
        case 1: print("Text tapped")
        case 2: delegate?.customTabBarDidTapAddButton(self)
        case 3: print("Ratio tapped")
        case 4: print("Slides tapped")
        default: break
        }
    }
}
