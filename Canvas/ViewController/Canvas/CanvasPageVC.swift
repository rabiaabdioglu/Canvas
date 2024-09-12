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
    private var snapLineDrawer: SnapLineDrawer?

    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clrBackground
        
        setupViews()
        setupCustomNavBar()
        
        customTabBar.delegate = self
        
        // Initialize SnapLineDrawer
        snapLineDrawer = SnapLineDrawer(canvasContentView: canvasContentView, selectedImageView: selectedImageView)
        
        // Add observer for photo selection notification
        NotificationCenter.default.addObserver(self, selector: #selector(handleImageSelected(_:)), name: Notification.Name("imageSelected"), object: nil)
        
        // Add tap gesture to detect taps outside of image views
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapOutside(_:)))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        drawGridLines()
    }
    
    deinit {
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
        drawGridLines()
    }
    
    // MARK: - Draw Grid Lines
    private func drawGridLines() {
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
    
    // MARK: - Add Image to Canvas
    private func addImageToCanvas(image: UIImage) {
        let position = CGPoint(x: CGFloat.random(in: 0...canvasContentView.bounds.width), y: CGFloat.random(in: 0...canvasContentView.bounds.height))
        let size = CGSize(width: 100, height: 100)
        let imageView = UIImageView(image: image)

        let canvasItem = CanvasItem(image: image, position: position, size: size, imageView: imageView)
        canvasItems.append(canvasItem)
        displayCanvasItem(canvasItem)
        updateContentSize()
    }
    
    // MARK: - Select/Deselect Image
    private func selectImage(_ imageView: UIImageView) {
        // Deselect previous selection
        deselectImage()
        // Set border for selected image
        imageView.layer.borderColor = UIColor.blue.cgColor
        imageView.layer.borderWidth = 2
        selectedImageView = imageView
        snapLineDrawer?.updateSelectedImageView(imageView)
    }
    
    private func deselectImage() {
        selectedImageView?.layer.borderWidth = 0
        selectedImageView = nil
        // Clear snap lines
        snapLineDrawer?.updateSelectedImageView(selectedImageView)
        snapLineDrawer?.clearSnapLines()
    }
    
    // MARK: - Display Canvas Item
    private func displayCanvasItem(_ item: CanvasItem) {
        guard let imageView = item.imageView else { return }
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

    // MARK: - Update Content Size of the Scroll View
    private func updateContentSize() {
        let contentSize = CGSize(width: canvasContentView.bounds.width, height: canvasContentView.bounds.height)
        scrollView.contentSize = contentSize
    }
    
    // MARK: - Draw Snap Lines
    private func drawSnapLines() {
        snapLineDrawer?.drawSnapLines(canvasItems: canvasItems)
    }
}

// MARK: - Handle Functions
extension CanvasPageVC {
    
    // MARK: - Handle Image Selected Notification
    @objc private func handleImageSelected(_ notification: Notification) {
        if let image = notification.userInfo?["image"] as? UIImage {
            addImageToCanvas(image: image)
        }
    }
    
    // MARK: - Handle Tap Outside
    @objc private func handleTapOutside(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: canvasContentView)
        
        if let selectedImageView = selectedImageView, !selectedImageView.frame.contains(location) {
            deselectImage()
        }
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
    
    // MARK: - Handle Pan Gesture for Moving Image
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        guard let view = gesture.view as? UIImageView else { return }
        
        let translation = gesture.translation(in: canvasContentView)
        let newCenter = CGPoint(x: view.center.x + translation.x, y: view.center.y + translation.y)
        
        let snappedCenter = snapLineDrawer?.snapToNearestGridOrItem(center: newCenter) ?? newCenter
        
        view.center = snappedCenter
        gesture.setTranslation(.zero, in: canvasContentView)
        drawSnapLines()
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
