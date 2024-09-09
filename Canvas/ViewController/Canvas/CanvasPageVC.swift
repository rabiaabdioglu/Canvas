//
//  CanvasPageVC.swift
//  Canvas
//
//  Created by Rabia Abdioğlu on 9.09.2024.
//

import UIKit
import SnapKit

class CanvasPageVC: UIViewController, TabBarDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    private let canvasView = UIView()
    private let customNavBar = NavigationBar()
    private let customTabBar = TabBar()
    private var canvasItems: [CanvasItem] = []
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clrBackground
        
        setupViews()
        setupConstraints()
        setupCustomNavBar()
        customTabBar.delegate = self
        
        // Add observer for photo selection notification
        NotificationCenter.default.addObserver(self, selector: #selector(handleImageSelected(_:)), name: Notification.Name("imageSelected"), object: nil)
    }
    
    deinit {
        // Remove observer when deinitializing
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup views
    private func setupViews() {
        view.addSubview(canvasView)
        view.addSubview(customTabBar)
        view.addSubview(customNavBar)
        
        canvasView.backgroundColor = .white
    }
    
    // MARK: - Setup constraints
    private func setupConstraints() {
        canvasView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.3)
            make.center.equalToSuperview()
        }
        
        customTabBar.snp.makeConstraints { make in
            make.left.bottom.right.equalToSuperview()
            make.height.equalTo(100)
        }
        
        customNavBar.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.height.equalTo(50)
        }
    }
    
    // MARK: - Setup custom navigation bar
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
    
    // MARK: - CustomTabBarDelegate method
    func customTabBarDidTapAddButton(_ tabBar: TabBar) {
        showAddButtonSheet()
    }
    
    // MARK: - Show add button sheet
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
    
    // MARK: - Handle image selected notification
    @objc private func handleImageSelected(_ notification: Notification) {
        if let image = notification.userInfo?["image"] as? UIImage {
            addImageToCanvas(image: image)
        }
    }
    
    // MARK: - Add image to canvas
    private func addImageToCanvas(image: UIImage) {
        // Create new CanvasItem with a random position
        let position = CGPoint(x: CGFloat.random(in: 0...canvasView.bounds.width), y: CGFloat.random(in: 0...canvasView.bounds.height))
        let canvasItem = CanvasItem(image: image, position: position, size: CGSize(width: 100, height: 100))
        canvasItems.append(canvasItem)
        displayCanvasItem(canvasItem)
    }
    
    // MARK: - Display canvas item
    private func displayCanvasItem(_ item: CanvasItem) {
        let imageView = UIImageView(image: item.image)
        imageView.contentMode = .scaleAspectFit
        canvasView.addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.size.equalTo(item.size)
            make.center.equalToSuperview()
        }
        
        imageView.center = item.position
        
        // Add pan and pinch gesture recognizers to make image movable and resizable
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        imageView.addGestureRecognizer(panGesture)
        imageView.isUserInteractionEnabled = true
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(_:)))
        imageView.addGestureRecognizer(pinchGesture)
    }
    
    // MARK: - Handle pan gesture for moving image
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
    
    // MARK: - Handle pinch gesture for resizing image
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
