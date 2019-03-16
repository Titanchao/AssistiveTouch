//
//  ATItemView.swift
//  BrcIot
//
//  Created by tian on 2018/12/30.
//  Copyright © 2018 tian. All rights reserved.
//

import UIKit

public enum ATItemViewType: Int {
    case none = 0
    case system = 1
    case back = 2
    case star = 3
    case count = 10
    case unknow
}

fileprivate enum ATInnerCircle {
    case small
    case middle
    case large
}

public class ATItemView: UIView {
    
    public var position = ATPosition(count: 0, index: 0)
    public var title: String? = "" {
        didSet {
            titleLabel.text = title
        }
    }
    
    private var titleLabel = UILabel(frame: .zero)
    
    init(layer: CALayer?) {
        super.init(frame: CGRect(x: 0, y: 0, width: ATLayoutAttributes.itemWidth, height: ATLayoutAttributes.itemWidth))
        if layer != nil {
            layer!.contentsScale = UIScreen.main.scale
            if layer!.bounds == .zero {
                layer!.bounds = CGRect(x: 0,
                                       y: 0,
                                       width: ATLayoutAttributes.itemImageWidth,
                                       height: ATLayoutAttributes.itemImageWidth)
            }
            if layer!.position == .zero {
                layer!.position = CGPoint(x: ATLayoutAttributes.itemWidth / 2.0,
                                          y: ATLayoutAttributes.itemWidth / 2.0)
            }
            self.layer.addSublayer(layer!)
            
            titleLabel.textAlignment = .center
            titleLabel.font = .systemFont(ofSize: 15)
            titleLabel.textColor = .white
            titleLabel.text = title
            var frame = layer!.frame
            frame.origin.y += (frame.size.height + 3)
            frame.size.height = 17
            titleLabel.frame = frame
            self.addSubview(titleLabel)            
        }
    }
    
    override convenience init(frame: CGRect) {
        self.init(layer: nil)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init(layer: nil)
    }
    
    public class func item(_ type: ATItemViewType) -> ATItemView {
        var layer: CALayer? = nil
        switch type {
        case .system:
            layer = createLayerSystemType()
            break
        case .none:
            layer = createLayerWithNoneType()
            break
        case .back:
            layer = createLayerBackType()
            break
        case .star:
            layer = createLayerStarType()
            break
        default:
            if type.rawValue >= ATItemViewType.count.rawValue {
                let count = type.rawValue - ATItemViewType.count.rawValue
                layer = createLayer(count)
            }
            break
        }
        let item = ATItemView(layer: layer)
        if type == .system {
            item.bounds = CGRect(x: 0,
                                 y: 0,
                                 width: ATLayoutAttributes.itemImageWidth,
                                 height: ATLayoutAttributes.itemImageWidth)
            item.layer.zPosition = CGFloat(Float.greatestFiniteMagnitude)
        }
        return item
    }
    
    public class func item(_ layer: CALayer) -> ATItemView {
        return ATItemView(layer: layer)
    }
    
    public class func item(_ image: UIImage?, title: String?) -> ATItemView {
        guard let itemImage = image else {
            return ATItemView(layer: nil)
        }
        let size = CGSize(width: min(itemImage.size.width, ATLayoutAttributes.itemWidth), height: min(itemImage.size.height, ATLayoutAttributes.itemWidth))
        let layer = CALayer()
        layer.contents = itemImage.cgImage
        layer.bounds = CGRect(x: 0, y: 0, width: min(size.width, ATLayoutAttributes.itemImageWidth), height: min(size.height, ATLayoutAttributes.itemImageWidth))
        let item = ATItemView(layer: layer)
        item.title = title
        return item
    }
}

extension ATItemView {
    private class func createLayerWithNoneType() -> CALayer {
        return CALayer()
    }
    
    private class func createLayerSystemType() -> CALayer {
        let layer = CALayer()
        layer.addSublayer(createInnerCircle(type: .large))
        layer.addSublayer(createInnerCircle(type: .middle))
        layer.addSublayer(createInnerCircle(type: .small))
        layer.position = CGPoint(x: ATLayoutAttributes.itemImageWidth / 2.0,
                                 y: ATLayoutAttributes.itemImageWidth / 2.0)
        return layer
    }
    
    private class func createLayerBackType() -> CALayer {
        let layer = CAShapeLayer()
        let size = CGSize(width: 22, height: 22)
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: size.height / 2.0))
        path.addLine(to: CGPoint(x: size.width / 2.0, y: 8.5 + size.height / 2.0))
        path.addLine(to: CGPoint(x: size.width / 2.0, y: 3.5 + size.height / 2))
        path.addLine(to: CGPoint(x: size.width, y: 3.5 + size.height / 2.0))
        path.addLine(to: CGPoint(x: size.width, y: -3.5 + size.height / 2.0))
        path.addLine(to: CGPoint(x: size.width / 2.0, y: -3.5 + size.height / 2.0))
        path.addLine(to: CGPoint(x: size.width / 2.0, y: -8.5 + size.height / 2.0))
        path.close()
        layer.path = path.cgPath
        layer.lineWidth = 2.0
        layer.fillColor = UIColor.white.cgColor
        layer.strokeColor = UIColor.white.cgColor
        layer.bounds = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        return layer
    }
    
    private class func createLayerStarType() -> CALayer {
        let layer = CAShapeLayer()
        let size = CGSize(width: ATLayoutAttributes.itemImageWidth,
                          height: ATLayoutAttributes.itemImageWidth)
        let numberOfPoints: CGFloat = 5.0
        let starRatio: CGFloat = 0.5
        let steps: CGFloat = numberOfPoints * 2.0
        let outerRadius: CGFloat = min(size.height, size.width) / 2.0
        let innerRadius: CGFloat = outerRadius * starRatio
        let stepAngle: CGFloat = 2.0 * .pi / steps
        let center: CGPoint = CGPoint(x: size.width / 2.0,
                                      y: size.height / 2.0)
        let path = UIBezierPath()
        for i in 0 ..< Int(steps) {
            let radius: CGFloat = i % 2 == 0 ? outerRadius : innerRadius
            let angle: CGFloat = CGFloat(i) * stepAngle - .pi
            let x: CGFloat = radius * cos(angle) + center.x
            let y: CGFloat = radius * sin(angle) + center.y
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        path.close()
        layer.path = path.cgPath
        layer.fillColor = UIColor.white.cgColor
        return layer
    }
    
    private class func createLayer(_ count: Int) -> CALayer {
        let layer = CAShapeLayer()
        let bounds = CGRect(x: 0,
                            y: 0,
                            width: ATLayoutAttributes.itemImageWidth,
                            height: ATLayoutAttributes.itemImageWidth)
        let path = UIBezierPath(ovalIn: bounds)
        path.append(UIBezierPath(ovalIn: bounds.insetBy(dx: 5, dy: 5)).reversing())
        layer.path = path.cgPath
        layer.fillColor = UIColor.white.cgColor
        layer.bounds = bounds
        
        let textLayer = CATextLayer()
        if count >= 10 || count < 0 {
            textLayer.string = "!"
        } else {
            textLayer.string = "\(count)"
        }
        textLayer.fontSize = 48
        textLayer.alignmentMode = .center
        textLayer.bounds = bounds
        textLayer.position = CGPoint(x: layer.bounds.midX,
                                     y: layer.bounds.midY)
        textLayer.contentsScale = UIScreen.main.scale
        layer.addSublayer(textLayer)
        return layer
    }
    
    private class func createInnerCircle(type: ATInnerCircle) -> CAShapeLayer {
        var circleAlpha: CGFloat = 0
        var radius: CGFloat = 0
        var borderAlpha: CGFloat = 0
        switch type {
        case .small:
            circleAlpha = 1
            radius = 14.5
            borderAlpha = 0.3
            break
        case .middle:
            circleAlpha = 0.4
            radius = 18.5
            borderAlpha = 0.15
            break
        case .large:
            circleAlpha = 0.2
            radius = 22
            borderAlpha = 0
            break
        }
        
        let layer = CAShapeLayer()
        let position = CGPoint(x: ATLayoutAttributes.itemImageWidth / 2.0,
                               y: ATLayoutAttributes.itemImageWidth / 2.0)
        let path = UIBezierPath(arcCenter: position, radius: radius, startAngle: 0, endAngle: .pi * 2.0, clockwise: true)
        layer.path = path.cgPath
        layer.lineWidth = 1
        layer.fillColor = UIColor(white: 1, alpha: circleAlpha).cgColor
        layer.strokeColor = UIColor(white: 0, alpha: borderAlpha).cgColor
        layer.bounds = CGRect(x: 0,
                              y: 0,
                              width: ATLayoutAttributes.itemImageWidth,
                              height: ATLayoutAttributes.itemImageWidth)
        layer.position = CGPoint(x: position.x, y: position.y)
        layer.contentsScale = UIScreen.main.scale
        return layer
    }
}
