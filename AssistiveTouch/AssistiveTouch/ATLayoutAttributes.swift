//
//  ATLayoutAttributes.swift
//  BrcIot
//
//  Created by tian on 2018/12/30.
//  Copyright © 2018 tian. All rights reserved.
//

import UIKit

class ATLayoutAttributes {
    
    static var contentViewSpreadFrame: CGRect {
        let spreadWidth: CGFloat = 295.0
        let screenFrame = UIScreen.main.bounds
        return CGRect(x: (screenFrame.width - spreadWidth) / 2.0,
                      y: (screenFrame.height - spreadWidth) / 2.0,
                      width: spreadWidth,
                      height: spreadWidth)
    }
    
    static var contentViewDefaultPoint: CGPoint {
        let screenFrame = UIScreen.main.bounds
        return CGPoint(x: screenFrame.width - itemImageWidth / 2.0 - margin,
                       y: screenFrame.midY)
    }
    
    static var itemWidth: CGFloat {
        return contentViewSpreadFrame.width / 3.0
    }
    
    static let itemImageWidth: CGFloat = 60.0
    static let cornerRadius: CGFloat = 14.0
    static let margin: CGFloat = 2.0
    static let maxCount: Int = 8
    static let inactiveAlpha: CGFloat = 0.4
    static let animationDuration: TimeInterval = 0.25
    static let activeDuration: TimeInterval = 4.0
}
