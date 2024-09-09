//
//  CanvasItem.swift
//  Canvas
//
//  Created by Rabia Abdioğlu on 9.09.2024.
//

import Foundation
import UIKit
class CanvasItem {
    var id: UUID
    var image: UIImage
    var position: CGPoint
    var size: CGSize

    init(image: UIImage, position: CGPoint, size: CGSize) {
        self.id = UUID()
        self.image = image
        self.position = position
        self.size = size
    }
}
