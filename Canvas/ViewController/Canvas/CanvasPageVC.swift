//
//  CanvasPageVC.swift
//  Canvas
//
//  Created by Rabia Abdioğlu on 9.09.2024.
//

import UIKit
import SnapKit

class CanvasPageVC: UIViewController, TabBarDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    // MARK: - Properties
    private let canvasView = UIView()
    private let customNavBar = NavigationBar()
    private let customTabBar = TabBar()
    private var canvasItems: [CanvasItem] = []
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clrBackground
        
        setupViews()
        setupCustomNavBar()
        customTabBar.delegate = self
        
        // Add observer for photo selection notification
        NotificationCenter.default.addObserver(self, selector: #selector(handleImageSelected(_:)), name: Notification.Name("imageSelected"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup Views
    private func setupViews() {
        view.addSubview(canvasView)
        canvasView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.3)
            make.center.equalToSuperview()
        }
        
        view.addSubview(customTabBar)
        customTabBar.snp.makeConstraints { make in
            make.left.bottom.right.equalToSuperview()
            make.height.equalTo(100)
        }
        
        view.addSubview(customNavBar)
        customNavBar.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.height.equalTo(50)
        }
        
        canvasView.backgroundColor = .white
    }
  
    // MARK: - Setup Custom Navigation Bar
    private func setupCustomNavBar() {
        customNavBar.onBackButtonTapped = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        customNavBar.onUndoButtonTapped = {
            // Implement undo functionality
        }
        customNavBar.onRedoButtonTapped = {
            // Implement redo functionality
        }
        customNavBar.onNextButtonTapped = {
            // Implement next functionality
        }
    }
    
    // MARK: - CustomTabBarDelegate Method
    func customTabBarDidTapAddButton(_ tabBar: TabBar) {
        showAddButtonSheet()
    }
    
    // MARK: - Show Add Button Sheet
    private func showAddButtonSheet() {
        let popUpVC = NewLayerView()
        popUpVC.modalPresentationStyle = .pageSheet
        if let sheet = popUpVC.sheetPresentationController {
            sheet.detents = [.custom { _ in
                return self.view.bounds.height * 0.35
            }]
            sheet.prefersGrabberVisible = false
        }
        present(popUpVC, animated: true, completion: nil)
    }
    
    // MARK: - Handle Image Selected Notification
    @objc private func handleImageSelected(_ notification: Notification) {
        if let image = notification.userInfo?["image"] as? UIImage {
            addImageToCanvas(image: image)
        }
    }
    
    // MARK: - Add Image to Canvas
    private func addImageToCanvas(image: UIImage) {
        let position = CGPoint(x: CGFloat.random(in: 0...canvasView.bounds.width), y: CGFloat.random(in: 0...canvasView.bounds.height))
        let canvasItem = CanvasItem(image: image, position: position, size: CGSize(width: 100, height: 100))
        canvasItems.append(canvasItem)
        displayCanvasItem(canvasItem)
    }
    
    // MARK: - Display Canvas Item
    private func displayCanvasItem(_ item: CanvasItem) {
        let imageView = UIImageView(image: item.image)
        imageView.contentMode = .scaleAspectFit
        canvasView.addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.size.equalTo(item.size)
            make.center.equalToSuperview()
        }
        
        // Add pan and pinch gesture recognizers to make image movable and resizable
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        imageView.addGestureRecognizer(panGesture)
        imageView.isUserInteractionEnabled = true
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(_:)))
        imageView.addGestureRecognizer(pinchGesture)
    }
    
    // MARK: - Handle Pan Gesture for Moving Image
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        guard let view = gesture.view else { return }
        
        let translation = gesture.translation(in: view.superview)
        view.center = CGPoint(x: view.center.x + translation.x, y: view.center.y + translation.y)
        gesture.setTranslation(.zero, in: view.superview)
        
        // Update position in canvasItems
        if let index = canvasItems.firstIndex(where: { $0.image == (view as? UIImageView)?.image }) {
            canvasItems[index].position = view.center
        }
    }
    
    // MARK: - Handle Pinch Gesture for Resizing Image
    @objc private func handlePinchGesture(_ gesture: UIPinchGestureRecognizer) {
        guard let view = gesture.view else { return }
        
        let scale = gesture.scale
        view.transform = view.transform.scaledBy(x: scale, y: scale)
        gesture.scale = 1.0
        
        // Update size in canvasItems
        if let index = canvasItems.firstIndex(where: { $0.image == (view as? UIImageView)?.image }) {
            let currentSize = view.frame.size
            canvasItems[index].size = CGSize(width: currentSize.width, height: currentSize.height)
        }
    }
}

#Preview(body: {
    CanvasPageVC()
})
