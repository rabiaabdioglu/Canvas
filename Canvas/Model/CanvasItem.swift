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
    var position: CGPoint
    var size: CGSize
    weak var imageView: UIImageView? // Referansı zayıf (weak) olarak tutun

    init(position: CGPoint, size: CGSize, imageView: UIImageView?) {
        self.id = UUID()
        self.position = position
        self.size = size
        self.imageView = imageView
    }
}
// Undo/Redo için daha basit bir yapı
struct CanvasItemState {
    let id: String
    let position: CGPoint
    let size: CGSize
}
