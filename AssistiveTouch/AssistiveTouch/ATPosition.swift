//
//  ATPosition.swift
//  BrcIot
//
//  Created by tian on 2018/12/30.
//  Copyright © 2018 tian. All rights reserved.
//

import UIKit

fileprivate let n_pi_2: CGFloat = .pi / 2.0
fileprivate let n_pi_4: CGFloat = .pi / 4.0

public class ATPosition {
    
    private(set) var count = 0
    public private(set) var index = 0
    public var center: CGPoint {
        var count = self.count
        var index = self.index
        if count == 0 {
            count = 1
            index = 1
        }
        let angle: CGFloat = 5.0 * n_pi_2 - .pi * 2.0 / CGFloat(count) * CGFloat(index)
        let k: CGFloat = tan(angle)
        var x: CGFloat = 0
        var y: CGFloat = 0
        if 9.0 * n_pi_4 < angle || angle <= 3.0 * n_pi_4 {
            y = ATLayoutAttributes.itemWidth
            if angle == n_pi_2 * 5.0 || angle == n_pi_2 * 3.0 {
                x = 0
            } else {
                x = y / k
            }
        } else if n_pi_4 * 7.0 < angle && angle <= n_pi_4 * 9.0 {
            x = ATLayoutAttributes.itemWidth
            y = k * x
        } else if n_pi_4 * 5.0 < angle && angle <= n_pi_4 * 7.0 {
            y = -ATLayoutAttributes.itemWidth
            if angle == n_pi_2 * 5.0 || angle == n_pi_2 * 3.0 {
                x = 0
            } else {
                x = y / k
            }
        } else if n_pi_4 * 3.0 < angle && angle <= n_pi_4 * 5.0 {
            x = -ATLayoutAttributes.itemWidth
            y = k * x
        }
        return coordinatesTransform(CGPoint(x: x, y: y))
        
    }
    public var frame: CGRect {
        let center = self.center
        return CGRect(x: center.x - ATLayoutAttributes.itemWidth / 2.0,
                      y: center.y - ATLayoutAttributes.itemWidth / 2.0,
                      width: ATLayoutAttributes.itemWidth,
                      height: ATLayoutAttributes.itemWidth)
    }
    
    public class func position(count: Int, index: Int) -> ATPosition {
        return ATPosition(count: count, index: index)
    }
    
    convenience init() {
        self.init(count: 0, index: 0)
    }
    
    init(count: Int, index: Int) {
        self.count = min(ATLayoutAttributes.maxCount, max(0, count))
        self.index = max(index, 0)
        self.index = self.index > self.count ? ATLayoutAttributes.maxCount : self.index
    }
    
    private func coordinatesTransform(_ point: CGPoint) -> CGPoint {
        var temp = point
        let rect = UIScreen.main.bounds
        let screenCenter = CGPoint(x: rect.midX, y: rect.midY)
        temp.y = -temp.y
        return CGPoint(x: screenCenter.x + temp.x,
                       y: screenCenter.y + temp.y)
    }
}
