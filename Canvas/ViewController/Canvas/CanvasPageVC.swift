// CanvasPageVC.swift
// Canvas
//
// Created by Rabia Abdioğlu on 9.09.2024.
//

import UIKit
import SnapKit

class CanvasPageVC: UIViewController, TabBarDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    // MARK: - Properties
    private let scrollView = UIScrollView()
    private let canvasContentView = UIView()
    private let customNavBar = NavigationBar()
    private let customTabBar = TabBar()
    private var canvasItems: [CanvasItem] = []
    private var selectedImageView: UIImageView?
    private var snapLinesLayer: CAShapeLayer?
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clrBackground
        setupViews()
        setupCustomNavBar()
        customTabBar.delegate = self
        
        // Add observer for photo selection notification
        NotificationCenter.default.addObserver(self, selector: #selector(handleImageSelected(_:)), name: Notification.Name("imageSelected"), object: nil)
        
        // Add tap gesture to detect taps outside of image views
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapOutside(_:)))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Vertical Lines'ı çiz
          drawVerticalLines()
          
    }
    
    deinit {
        // Remove observer when deinitializing
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup Views
    private func setupViews() {
        view.addSubview(customNavBar)
        customNavBar.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.height.equalTo(50)
        }
        
        view.addSubview(customTabBar)
        customTabBar.snp.makeConstraints { make in
            make.left.bottom.right.equalToSuperview()
            make.height.equalTo(100)
        }
        
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.3)
            make.center.equalToSuperview()
        }
        
        scrollView.addSubview(canvasContentView)
        canvasContentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(view).multipliedBy(2)
            make.height.equalToSuperview()
        }
        
        scrollView.isScrollEnabled = true
        scrollView.showsHorizontalScrollIndicator = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.backgroundColor = .separator
        canvasContentView.backgroundColor = .white
        
        // Draw grid
        drawVerticalLines()
    }
    
    // MARK: - Draw Vertical Lines
    private func drawVerticalLines() {
        let numberOfLines = 3
        let lineWidth: CGFloat = 2
        let lineColor = UIColor.gray
        
        let lineSpacing = canvasContentView.bounds.width / CGFloat(numberOfLines + 1)
        
        let linesLayer = CAShapeLayer()
        let path = UIBezierPath()
        
        for i in 1...numberOfLines {
            let x = CGFloat(i) * lineSpacing
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x, y: canvasContentView.bounds.height))
        }
        
        linesLayer.path = path.cgPath
        linesLayer.strokeColor = lineColor.cgColor
        linesLayer.lineWidth = lineWidth
        canvasContentView.layer.addSublayer(linesLayer)
        canvasContentView.layoutIfNeeded()
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
        let position = CGPoint(x: CGFloat.random(in: 0...canvasContentView.bounds.width), y: CGFloat.random(in: 0...canvasContentView.bounds.height))
        let size = CGSize(width: 100, height: 100)
        var canvasItem = CanvasItem(image: image, position: position, size: size)
        canvasItems.append(canvasItem)
        displayCanvasItem(&canvasItem)
        updateContentSize()
    }
    
    // MARK: - Display Canvas Item
    private func displayCanvasItem(_ item: inout CanvasItem) {
        let imageView = UIImageView(image: item.image)
        imageView.contentMode = .scaleToFill
        canvasContentView.addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.size.equalTo(item.size)
            make.center.equalToSuperview()
        }
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        imageView.addGestureRecognizer(panGesture)
        imageView.isUserInteractionEnabled = true
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(_:)))
        imageView.addGestureRecognizer(pinchGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapOnImage(_:)))
        imageView.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Handle Tap on Image
    @objc private func handleTapOnImage(_ gesture: UITapGestureRecognizer) {
        if let tappedImageView = gesture.view as? UIImageView {
            if selectedImageView == tappedImageView {
                // Deselect if the same image is tapped again
                deselectImage()
            } else {
                // Select new image
                selectImage(tappedImageView)
            }
        }
    }
    
    // MARK: - Handle Tap Outside
    @objc private func handleTapOutside(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: canvasContentView)
        
        // Eğer bir öğe seçiliyse ve bu öğe ile tıklama noktası çakışmıyorsa deselect yap
        if let selectedImageView = selectedImageView, !selectedImageView.frame.contains(location) {
            deselectImage()
        }
    }
    
    // MARK: - Select Image
    private func selectImage(_ imageView: UIImageView) {
        // Deselect previous selection
        deselectImage()
        
        // Set border for selected image
        imageView.layer.borderColor = UIColor.blue.cgColor
        imageView.layer.borderWidth = 2
        selectedImageView = imageView
    }
    
    // MARK: - Deselect Image
    private func deselectImage() {
        selectedImageView?.layer.borderWidth = 0
        selectedImageView = nil
    }
    
    // MARK: - Update Content Size of the Scroll View
    private func updateContentSize() {
        let contentSize = CGSize(width: canvasContentView.bounds.width, height: canvasContentView.bounds.height)
        scrollView.contentSize = contentSize
    }



// MARK: - Snap and Drawing Functions

    // MARK: - Handle Pan Gesture for Moving Image
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        guard let view = gesture.view as? UIImageView else { return }
        
        let translation = gesture.translation(in: canvasContentView)
        let newCenter = CGPoint(x: view.center.x + translation.x, y: view.center.y + translation.y)
        
        let snappedCenter = snapToNearestGridOrItem(center: newCenter)
        
        view.center = snappedCenter
        gesture.setTranslation(.zero, in: canvasContentView)
        drawSnapLines()
    }
    
    // MARK: - Snap to Nearest Grid or Item
    private func snapToNearestGridOrItem(center: CGPoint) -> CGPoint {
        let gridWidth: CGFloat = 100
        let snapThreshold: CGFloat = 5
        var snappedX = center.x
        var snappedY = center.y
        
        let gridSnapX = round(center.x / gridWidth) * gridWidth
        let gridSnapY = round(center.y / gridWidth) * gridWidth
        
        if abs(center.x - gridSnapX) < snapThreshold {
            snappedX = gridSnapX
        }
        if abs(center.y - gridSnapY) < snapThreshold {
            snappedY = gridSnapY
        }
        
        for item in canvasItems {
            if abs(center.x - item.minX) < snapThreshold {
                snappedX = item.minX
            } else if abs(center.x - item.maxX) < snapThreshold {
                snappedX = item.maxX
            }
            
            if abs(center.y - item.minY) < snapThreshold {
                snappedY = item.minY
            } else if abs(center.y - item.maxY) < snapThreshold {
                snappedY = item.maxY
            }
        }
        
        return CGPoint(x: snappedX, y: snappedY)
    }
    private func drawSnapLines() {
        snapLinesLayer?.removeFromSuperlayer()
        
        let snapLinesLayer = CAShapeLayer()
        let path = UIBezierPath()
        let snapThreshold: CGFloat = 5
        
        guard let selectedImageView = selectedImageView else { return }
        
        let gridWidth: CGFloat = 100
        
        let canvasWidth = canvasContentView.bounds.width
        let canvasHeight = canvasContentView.bounds.height
        
        let gridLinesX = stride(from: 0, to: canvasWidth, by: gridWidth).map { $0 }
        
        let gridSnapX = round(selectedImageView.center.x / gridWidth) * gridWidth
        if abs(selectedImageView.center.x - gridSnapX) < snapThreshold {
            path.move(to: CGPoint(x: gridSnapX, y: 0))
            path.addLine(to: CGPoint(x: gridSnapX, y: canvasHeight))
        }
        
        if abs(selectedImageView.frame.midY - canvasContentView.frame.midY) < snapThreshold {
            path.move(to: CGPoint(x: 0, y: canvasContentView.frame.midY))
            path.addLine(to: CGPoint(x: canvasWidth, y: canvasContentView.frame.midY))
        }
        
        for item in canvasItems {
            let itemFrame = CGRect(origin: item.position, size: item.size)
            
            if abs(selectedImageView.frame.maxX - itemFrame.minX) < 1 {
                path.move(to: CGPoint(x: itemFrame.minX, y: 0))
                path.addLine(to: CGPoint(x: itemFrame.minX, y: canvasHeight))
            }
            if abs(selectedImageView.frame.minX - itemFrame.maxX) < 1 {
                path.move(to: CGPoint(x: itemFrame.maxX, y: 0))
                path.addLine(to: CGPoint(x: itemFrame.maxX, y: canvasHeight))
            }
            
            if abs(selectedImageView.frame.maxY - itemFrame.minY) < 1 {
                path.move(to: CGPoint(x: 0, y: itemFrame.minY))
                path.addLine(to: CGPoint(x: canvasWidth, y: itemFrame.minY))
            }
            if abs(selectedImageView.frame.minY - itemFrame.maxY) < 1 {
                path.move(to: CGPoint(x: 0, y: itemFrame.maxY))
                path.addLine(to: CGPoint(x: canvasWidth, y: itemFrame.maxY))
            }
        }
        
        for gridLineX in gridLinesX {
            if abs(selectedImageView.center.x - gridLineX) < snapThreshold {
                path.move(to: CGPoint(x: gridLineX, y: 0))
                path.addLine(to: CGPoint(x: gridLineX, y: canvasHeight))
            }
        }
        
        // Ortalamayı hesapla (yatay) gridler arasında
        let gridLinesY = stride(from: 0, to: canvasHeight, by: gridWidth).map { $0 }
        for gridLineY in gridLinesY {
            if abs(selectedImageView.center.y - gridLineY) < snapThreshold {
                path.move(to: CGPoint(x: 0, y: gridLineY))
                path.addLine(to: CGPoint(x: canvasWidth, y: gridLineY))
            }
        }
        
        snapLinesLayer.path = path.cgPath
        snapLinesLayer.strokeColor = UIColor.orange.cgColor
        snapLinesLayer.lineWidth = 1
        canvasContentView.layer.addSublayer(snapLinesLayer)
        self.snapLinesLayer = snapLinesLayer
    }


    // MARK: - Handle Pinch Gesture for Resizing Image
    @objc private func handlePinchGesture(_ gesture: UIPinchGestureRecognizer) {
        guard let view = gesture.view else { return }
        
        let scale = gesture.scale
        view.transform = view.transform.scaledBy(x: scale, y: scale)
        gesture.scale = 1.0
        
        // Update size in canvasItems
        if let index = canvasItems.firstIndex(where: { $0.image == (view as? UIImageView)?.image }) {
            canvasItems[index].size = view.frame.size
        }
    }
}
#Preview(body: {
    CanvasPageVC()
})
