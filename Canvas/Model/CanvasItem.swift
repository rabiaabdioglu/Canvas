//
//  CanvasItem.swift
//  Canvas
//
//  Created by Rabia Abdioğlu on 9.09.2024.
//

import Foundation
import UIKit

class CanvasItem {
    let image: UIImage
    let position: CGPoint
    var size: CGSize
    weak var imageView: UIImageView? // Referansı zayıf (weak) olarak tutun

    init(image: UIImage, position: CGPoint, size: CGSize, imageView: UIImageView?) {
        self.image = image
        self.position = position
        self.size = size
        self.imageView = imageView
    }
}
