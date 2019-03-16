//
//  AssistiveTouch.swift
//  BrcIot
//
//  Created by tian on 2018/12/30.
//  Copyright © 2018 tian. All rights reserved.
//

import UIKit

public protocol AssistiveTouchDelegate: NSObjectProtocol {
    func numberOfItemsIn(_ viewC: ATViewC) -> Int
    func viewController(_ viewC: ATViewC, itemViewAt position: ATPosition) -> ATItemView?
    func viewController(_ viewC: ATViewC, didSelectedAt position: ATPosition)
}

public class AssistiveTouch: NSObject {
    
    public static let share = AssistiveTouch()
    public weak var delegate: AssistiveTouchDelegate? = nil
    private lazy var assistiveWindow: UIWindow = {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: ATLayoutAttributes.itemImageWidth, height: ATLayoutAttributes.itemImageWidth))
        window.center = assistiveWindowPoint
        window.windowLevel = UIWindow.Level(rawValue: CGFloat.greatestFiniteMagnitude)
        window.rootViewController = navigationC
        window.layer.masksToBounds = true
        window.isHidden = true
        return window
    }()
    public lazy var navigationC: ATNavigationC = {
        let rootViewC = ATRootViewC()
        rootViewC.delegate = self
        let nav = ATNavigationC(rootViewC: rootViewC)
        nav.delegate = self
        nav.beginTimer()
        return nav
    }()
    private var assistiveWindowPoint: CGPoint = ATLayoutAttributes.contentViewDefaultPoint
    private var coverWindowPoint: CGPoint = .zero
    public var isShow: Bool { return !assistiveWindow.isHidden }
    
    public class func auto() {
        if UserDefaults.standard.bool(forKey: "assistive_touch_show") {
            AssistiveTouch.share.show()
        }
    }
    
    public func show() {
        let keywindow = UIApplication.shared.keyWindow
        assistiveWindow.makeKeyAndVisible()
        keywindow?.makeKeyAndVisible()
        assistiveWindow.isHidden = false
        UserDefaults.standard.set(true, forKey: "assistive_touch_show")
    }
    
    public func hide() {
        assistiveWindow.isHidden = true
        UserDefaults.standard.set(false, forKey: "assistive_touch_show")
    }
}

extension AssistiveTouch: ATNavigationControllerDelegate, ATRootViewControllerDelegate {
    func numberOfItemsIn(_ viewC: ATRootViewC) -> Int {
        return delegate?.numberOfItemsIn(viewC) ?? 0
    }
    
    func viewController(_ viewC: ATRootViewC, itemViewAt position: ATPosition) -> ATItemView? {
        return delegate?.viewController(viewC, itemViewAt: position)
    }
    
    func viewController(_ viewC: ATRootViewC, didSelectedAt position: ATPosition) {
        delegate?.viewController(viewC, didSelectedAt: position)
    }
    
    public func navigationC(_ nav: ATNavigationC, actionBeginAt point: CGPoint) {
        coverWindowPoint = .zero
        assistiveWindow.frame = UIScreen.main.bounds
        navigationC.view.frame = UIScreen.main.bounds
        navigationC.moveContentViewTo(assistiveWindowPoint)
    }
    
    public func navigationC(_ nav: ATNavigationC, actionEndAt point: CGPoint) {
        assistiveWindowPoint = point
        assistiveWindow.frame = CGRect(x: 0, y: 0, width: ATLayoutAttributes.itemImageWidth, height: ATLayoutAttributes.itemImageWidth)
        assistiveWindow.center = assistiveWindowPoint
        let contentPoint = CGPoint(x: ATLayoutAttributes.itemImageWidth / 2.0,
                                   y: ATLayoutAttributes.itemImageWidth / 2.0)
        navigationC.moveContentViewTo(contentPoint)
    }
}
