//
//  NewLayerView.swift
//  Canvas
//
//  Created by Rabia Abdioğlu on 9.09.2024.
//


import UIKit
import SnapKit

class NewLayerView: UIViewController ,UIImagePickerControllerDelegate & UINavigationControllerDelegate{
    
    private let titleLabel = UILabel()
    private let closeButton = UIButton(type: .close)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    // MARK: - Setup View
    private func setupView() {
        // Set background color and corner radius for the popup view
        view.backgroundColor = UIColor.clrGray2
        view.layer.cornerRadius = 5
        
        // Title Label
        titleLabel.text = "New Layer"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textColor = .clrFont
        titleLabel.textAlignment = .center
        
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.snp.top).offset(10)
            make.left.equalTo(view.snp.left).offset(10)
            make.right.equalTo(view.snp.right).offset(-10)
            make.height.equalTo(30)
        }
        
        // Close Button
        closeButton.addTarget(self, action: #selector(handleCloseButtonTapped), for: .touchUpInside)
        
        view.addSubview(closeButton)
        closeButton.snp.makeConstraints { make in
            make.top.equalTo(view.snp.top).offset(15)
            make.left.equalTo(view.snp.left).offset(30)
            make.width.height.equalTo(30)
        }
        
        // Image Button
        let imageButton = CircleButtonWithText(imageName: "photo.fill", title: "Image")
        imageButton.buttonTapped = {
            self.presentPhotoPicker()
        }
        
        view.addSubview(imageButton)
        imageButton.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(30)
            make.left.equalTo(view.snp.left).offset(20)
            make.width.height.equalTo(view.snp.width).multipliedBy(0.2)
        }
        
        // Video Button
        let videoButton = CircleButtonWithText(imageName: "play.circle.fill", title: "Video")
        videoButton.buttonTapped = {
            self.handleVideoButtonTapped()
        }
        
        view.addSubview(videoButton)
        videoButton.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(30)
            make.left.equalTo(imageButton.snp.right).offset(15)
            make.width.height.equalTo(view.snp.width).multipliedBy(0.2)
        }
        
        // GIF Button
        let gifButton = CircleButtonWithText(imageName: "theatermasks.fill", title: "GIF")
        gifButton.buttonTapped = {
            self.handleGifButtonTapped()
        }
        
        view.addSubview(gifButton)
        gifButton.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(30)
            make.left.equalTo(videoButton.snp.right).offset(15)
            make.width.height.equalTo(view.snp.width).multipliedBy(0.2)
        }
        
        
        // Overlay Button
        let overlayButton = CircleButtonWithText(imageName: "wand.and.stars", title: "Overlay")
        overlayButton.buttonTapped = {
            self.handleOverlayButtonTapped()
        }
        
        view.addSubview(overlayButton)
        overlayButton.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(30)
            make.right.equalTo(view.snp.right).offset(-20)
            make.width.height.equalTo(view.snp.width).multipliedBy(0.2)
        }
        // Drawing Button
        let drawingButton = CircleButtonWithText(imageName: "scribble", title: "Drawing")
        
        view.addSubview(drawingButton)
        drawingButton.snp.makeConstraints { make in
            make.top.equalTo(imageButton.snp.bottom).offset(40)
            make.left.equalTo(view.snp.left).offset(20)
            make.width.height.equalTo(view.snp.width).multipliedBy(0.2)
        }
        
    }
    
    // MARK: - Handle Button Tapped Functions

    
    @objc private func handleVideoButtonTapped() {
        // Video button tapped action
        print("Video button tapped")
    }
    
    @objc private func handleGifButtonTapped() {
        // GIF button tapped action
        print("GIF button tapped")
    }
    
    @objc private func handleOverlayButtonTapped() {
        // Overlay button tapped action
        print("Overlay button tapped")
    }
    
    @objc private func handleDrawingButtonTapped() {
        // Drawing button tapped action
        print("Drawing button tapped")
    }
    
    
    // MARK: - Handle Button Tapped Functions
      private func presentPhotoPicker() {
          let imagePickerController = UIImagePickerController()
          imagePickerController.sourceType = .photoLibrary
          imagePickerController.delegate = self
          present(imagePickerController, animated: true, completion: nil)
      }
      
    
    
      // MARK: - UIImagePickerControllerDelegate methods
      func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
          if let selectedImage = info[.originalImage] as? UIImage {
              NotificationCenter.default.post(name: Notification.Name("imageSelected"), object: nil, userInfo: ["image": selectedImage])
          }
          picker.dismiss(animated: true, completion: nil)
          dismiss(animated: true, completion: nil)
      }
      
      func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
          picker.dismiss(animated: true, completion: nil)
          dismiss(animated: true, completion: nil)
      }
      
    @objc private func handleCloseButtonTapped() {
        // Close the popup
        self.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Animation when popup appear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Animate popup appearance
        view.transform = CGAffineTransform(translationX: 0, y: view.bounds.height)
        
        UIView.animate(withDuration: 0.3) {
            self.view.transform = .identity
        }
    }
}

#Preview(body: {
    NewLayerView()
})
