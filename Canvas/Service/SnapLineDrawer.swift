//
//  SnapLineDrawer.swift
//  Canvas
//
//  Created by Rabia Abdioğlu on 11.09.2024.
//

import UIKit

class SnapLineDrawer {
    
    private weak var canvasContentView: UIView?
    private weak var selectedImageView: UIImageView?
    private var snapLinesLayerForGrid: CAShapeLayer?
    private var snapLinesLayerForCenter: CAShapeLayer?
    private var snapLinesLayerForOtherItems: CAShapeLayer?
    
    private var gridWidth: CGFloat
    private let gridHeight: CGFloat
    private let snapThreshold: CGFloat
    
    // MARK: - Initialization
    init(canvasContentView: UIView, selectedImageView: UIImageView?) {
        self.canvasContentView = canvasContentView
        self.selectedImageView = selectedImageView
        self.gridWidth = canvasContentView.bounds.width / 4
        self.gridHeight = canvasContentView.bounds.height
        self.snapThreshold = 5
        setupLayers()
    }
    
    // MARK: - Setup Layers
    private func setupLayers() {
        // Initialize CAShapeLayer instances for different snap line types
        snapLinesLayerForGrid = CAShapeLayer()
        snapLinesLayerForCenter = CAShapeLayer()
        snapLinesLayerForOtherItems = CAShapeLayer()
        
        // Add layers to the canvasContentView
        if let canvasContentView = canvasContentView {
            canvasContentView.layer.addSublayer(snapLinesLayerForGrid!)
            canvasContentView.layer.addSublayer(snapLinesLayerForCenter!)
            canvasContentView.layer.addSublayer(snapLinesLayerForOtherItems!)
        }
    }
    
    // MARK: - Update Selected Image View
    func updateSelectedImageView(_ imageView: UIImageView?) {
        self.selectedImageView = imageView
    }
    
    // MARK: - Clear Snap Lines
    func clearSnapLines() {
        // Remove existing snap lines layers
        snapLinesLayerForGrid?.removeFromSuperlayer()
        snapLinesLayerForCenter?.removeFromSuperlayer()
        snapLinesLayerForOtherItems?.removeFromSuperlayer()
        
        setupLayers()
    }
    
    // MARK: - Draw Snap Lines
    func drawSnapLines(canvasItems: [CanvasItem]) {
        clearSnapLines()
        
        // Create new CAShapeLayer and UIBezierPath instances for snap lines
        let gridSnapLinesLayer = CAShapeLayer()
        let centerSnapLinesLayer = CAShapeLayer()
        let itemSnapLinesLayer = CAShapeLayer()
        
        let gridPath = UIBezierPath()
        let itemPath = UIBezierPath()
        let centerPath = UIBezierPath()
        
        guard let selectedImageView = selectedImageView else { return }
        let canvasWidth = canvasContentView!.bounds.width
        let canvasHeight = canvasContentView!.bounds.height
        
        // Draw snap lines for the center of the canvas
        drawSnapLinesForCenter(path: centerPath, snapLinesLayer: centerSnapLinesLayer, snapThreshold: snapThreshold, selectedImageView: selectedImageView, canvasWidth: canvasWidth, canvasHeight: canvasHeight)
        
        // Draw snap lines for the grid lines
        drawSnapLinesForGridLine(path: gridPath, snapLinesLayer: gridSnapLinesLayer, snapThreshold: snapThreshold, selectedImageView: selectedImageView, canvasWidth: canvasWidth, canvasHeight: canvasHeight)
        
        // Draw snap lines for other items in the canvas
        drawSnapLinesForOtherItems(path: itemPath, snapLinesLayer: itemSnapLinesLayer, snapThreshold: snapThreshold, selectedImageView: selectedImageView, canvasItems: canvasItems)
        
        // Configure appearance of the snap lines
        centerSnapLinesLayer.path = centerPath.cgPath
        centerSnapLinesLayer.lineWidth = 1
        centerSnapLinesLayer.strokeColor = UIColor.purple.cgColor
        
        gridSnapLinesLayer.path = gridPath.cgPath
        gridSnapLinesLayer.lineWidth = 1
        gridSnapLinesLayer.strokeColor = UIColor.green.cgColor
        
        itemSnapLinesLayer.path = itemPath.cgPath
        itemSnapLinesLayer.lineWidth = 1
        itemSnapLinesLayer.strokeColor = UIColor.red.cgColor
        
        canvasContentView!.layer.addSublayer(centerSnapLinesLayer)
        canvasContentView!.layer.addSublayer(itemSnapLinesLayer)
        canvasContentView!.layer.addSublayer(gridSnapLinesLayer)
        
        self.snapLinesLayerForCenter = centerSnapLinesLayer
        self.snapLinesLayerForOtherItems = itemSnapLinesLayer
        self.snapLinesLayerForGrid = gridSnapLinesLayer
    }
    
    // MARK: - Draw Snap Lines for Center
    private func drawSnapLinesForCenter(path: UIBezierPath, snapLinesLayer: CAShapeLayer, snapThreshold: CGFloat, selectedImageView: UIImageView, canvasWidth: CGFloat, canvasHeight: CGFloat) {
        
        // Calculate the center of the grid cell where the selected image view is
        let gridCellCenterX = (floor(selectedImageView.center.x / gridWidth) + 0.5) * gridWidth
        let gridCellCenterY = (floor(selectedImageView.center.y / gridHeight) + 0.5) * gridHeight
        
        if isNear(value: selectedImageView.center.x, target: gridCellCenterX, threshold: snapThreshold) {
            drawLine(at: CGPoint(x: gridCellCenterX, y: 0), isVertical: true, path: path, snapLinesLayer: snapLinesLayer)
        }
        if isNear(value: selectedImageView.center.y, target: gridCellCenterY, threshold: snapThreshold) {
            drawLine(at: CGPoint(x: 0, y: gridCellCenterY), isVertical: false, path: path, snapLinesLayer: snapLinesLayer)
        }
        
        let minX = selectedImageView.frame.minX
        let maxX = selectedImageView.frame.maxX
        let minY = selectedImageView.frame.minY
        let maxY = selectedImageView.frame.maxY
        
        if isNear(value: minX, target: gridCellCenterX, threshold: snapThreshold) ||
            isNear(value: maxX, target: gridCellCenterX, threshold: snapThreshold) ||
            isNear(value: selectedImageView.center.x, target: gridCellCenterX, threshold: snapThreshold) {
            drawLine(at: CGPoint(x: gridCellCenterX, y: 0), isVertical: true, path: path, snapLinesLayer: snapLinesLayer)
        }
        if isNear(value: minY, target: gridCellCenterY, threshold: snapThreshold) ||
            isNear(value: maxY, target: gridCellCenterY, threshold: snapThreshold) ||
            isNear(value: selectedImageView.center.y, target: gridCellCenterY, threshold: snapThreshold) {
            drawLine(at: CGPoint(x: 0, y: gridCellCenterY), isVertical: false, path: path, snapLinesLayer: snapLinesLayer)
        }
    }
    
    // MARK: - Draw Snap Lines for Grid Lines
    private func drawSnapLinesForGridLine(path: UIBezierPath, snapLinesLayer: CAShapeLayer, snapThreshold: CGFloat, selectedImageView: UIImageView, canvasWidth: CGFloat, canvasHeight: CGFloat) {
        
        let gridSnapColor = UIColor.green.cgColor
        
        // Draw vertical grid lines based on the grid spacing
        func drawGridLines( range: CGFloat, size: CGFloat, color: CGColor) {
            for i in 0...Int(range / size) {
                let linePosition = CGFloat(i) * size
                if isNear(value: selectedImageView.frame.minX, target: linePosition, threshold: snapThreshold) ||
                    isNear(value: selectedImageView.frame.maxX, target: linePosition, threshold: snapThreshold) ||
                    isNear(value: selectedImageView.center.x, target: linePosition, threshold: snapThreshold) {
                    drawLine(at: CGPoint(x: linePosition, y: 0), isVertical: true, path: path, snapLinesLayer: snapLinesLayer)
                    
                }
            }
        }
        
        drawGridLines(range: canvasWidth, size: gridWidth, color: gridSnapColor)
    }
    
    // MARK: - Draw Snap Lines for Other Items
    private func drawSnapLinesForOtherItems(path: UIBezierPath, snapLinesLayer: CAShapeLayer, snapThreshold: CGFloat, selectedImageView: UIImageView, canvasItems: [CanvasItem]) {
        
        if canvasItems.count != 1 {
            
            let selectedMinX = selectedImageView.frame.minX
            let selectedMaxX = selectedImageView.frame.maxX
            let selectedMinY = selectedImageView.frame.minY
            let selectedMaxY = selectedImageView.frame.maxY
            
            for item in canvasItems {
                if item.imageView == selectedImageView {
                    continue
                }
                
                guard let imageView = item.imageView else { continue }
                let itemFrame = imageView.frame
                let itemMinX = itemFrame.minX
                let itemMaxX = itemFrame.maxX
                let itemMinY = itemFrame.minY
                let itemMaxY = itemFrame.maxY
                
                //                print("\n_______________________Poıntcheck_____________________________________________")
                //
                //                print("\nItem MinX: \(itemMinX), MaxX: \(itemMaxX), MinY: \(itemMinY), MaxY: \(itemMaxY)")
                //                print("\nSelected MinX: \(selectedMinX), MaxX: \(selectedMaxX), MinY: \(selectedMinY), MaxY: \(selectedMaxY)")
                //
                
                // Vertical snap
                if isNear(value: selectedMinX, target: itemMinX, threshold: snapThreshold) {
                    drawLine(at: CGPoint(x: itemMinX, y: 0), isVertical: true, path: path, snapLinesLayer: snapLinesLayer)
                }
                if isNear(value: selectedMaxX, target: itemMaxX, threshold: snapThreshold) {
                    drawLine(at: CGPoint(x: itemMaxX, y: 0), isVertical: true, path: path, snapLinesLayer: snapLinesLayer)
                }
                if isNear(value: selectedMaxX, target: itemMinX, threshold: snapThreshold) {
                    drawLine(at: CGPoint(x: itemMinX, y: 0), isVertical: true, path: path, snapLinesLayer: snapLinesLayer)
                }
                if isNear(value: selectedMinX, target: itemMaxX, threshold: snapThreshold) {
                    drawLine(at: CGPoint(x: itemMaxX, y: 0), isVertical: true, path: path, snapLinesLayer: snapLinesLayer)
                }
                
                // Horizontal
                if isNear(value: selectedMinY, target: itemMinY, threshold: snapThreshold) {
                    drawLine(at: CGPoint(x: 0, y: itemMinY), isVertical: false, path: path, snapLinesLayer: snapLinesLayer)                    
                }
                if isNear(value: selectedMaxY, target: itemMaxY, threshold: snapThreshold) {
                    drawLine(at: CGPoint(x: 0, y: itemMaxY), isVertical: false, path: path, snapLinesLayer: snapLinesLayer)
                }
                if isNear(value: selectedMaxY, target: itemMinY, threshold: snapThreshold) {
                    drawLine(at: CGPoint(x: 0, y: itemMinY), isVertical: false, path: path, snapLinesLayer: snapLinesLayer)
                }
                if isNear(value: selectedMinY, target: itemMaxY, threshold: snapThreshold) {
                    drawLine(at: CGPoint(x: 0, y: itemMaxY), isVertical: false, path: path, snapLinesLayer: snapLinesLayer)
                }
            }
        }
    }
    
    
    
    // MARK: - Helper Functions
    private func isNear(value: CGFloat, target: CGFloat, threshold: CGFloat) -> Bool {
        
        return abs(value - target) <= threshold
    }
    
    private func drawLine(at point: CGPoint, isVertical: Bool, path: UIBezierPath, snapLinesLayer: CAShapeLayer) {
        let startPoint = CGPoint(x: isVertical ? point.x : 0, y: isVertical ? 0 : point.y)
        let endPoint = CGPoint(x: isVertical ? point.x : canvasContentView!.bounds.width, y: isVertical ? canvasContentView!.bounds.height : point.y)
        
        path.move(to: startPoint)
        path.addLine(to: endPoint)
        snapLinesLayer.path = path.cgPath
        
        
        //        if let selectedImageView = selectedImageView {
        //            let viewFrame = selectedImageView.frame
        //
        //            if isVertical {
        //                if isNear(value: selectedImageView.center.x, target: point.x, threshold: snapThreshold) {
        //                    selectedImageView.center.x = point.x
        //                }
        //                if isNear(value: viewFrame.minX, target: point.x, threshold: snapThreshold) ||
        //                    isNear(value: viewFrame.maxX, target: point.x, threshold: snapThreshold) {
        //                    selectedImageView.frame.origin.x = point.x - viewFrame.width / 2
        //                }
        //            } else {
        //                if isNear(value: selectedImageView.center.y, target: point.y, threshold: snapThreshold) {
        //                    selectedImageView.center.y = point.y
        //                }
        //                if isNear(value: viewFrame.minY, target: point.y, threshold: snapThreshold) ||
        //                    isNear(value: viewFrame.maxY, target: point.y, threshold: snapThreshold) {
        //                    selectedImageView.frame.origin.y = point.y - viewFrame.height / 2
        //                }
        //            }
        //        }
    }
    
    
    
    
    // MARK: - Snap to Nearest Grid or Item
    func snapToNearestGridOrItem(center: CGPoint) -> CGPoint {
        let snapThreshold: CGFloat = 2
        var snappedX = center.x
        let snappedY = center.y
        
        let canvasCenterX = canvasContentView!.bounds.width / 2
        if abs(center.x - canvasCenterX) < snapThreshold {
            snappedX = canvasCenterX
        }
        
        return CGPoint(x: snappedX, y: snappedY)
    }
    
    
    
}
