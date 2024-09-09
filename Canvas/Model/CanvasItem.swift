//
//  CanvasItem.swift
//  Canvas
//
//  Created by Rabia Abdioğlu on 9.09.2024.
//

import Foundation
import UIKit
struct CanvasItem {
    var image: UIImage
    var position: CGPoint {
        didSet {
            updateBounds()
        }
    }
    var size: CGSize {
        didSet {
            updateBounds()
        }
    }
    var minX: CGFloat
    var maxX: CGFloat
    var minY: CGFloat
    var maxY: CGFloat
    
    init(image: UIImage, position: CGPoint, size: CGSize) {
        self.image = image
        self.position = position
        self.size = size
        self.minX = position.x
        self.maxX = position.x + size.width
        self.minY = position.y
        self.maxY = position.y + size.height
    }
    
    mutating func updateBounds() {
        self.minX = position.x
        self.maxX = position.x + size.width
        self.minY = position.y
        self.maxY = position.y + size.height
    }
}
