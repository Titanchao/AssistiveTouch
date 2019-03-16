//
//  ATNavigationC.swift
//  BrcIot
//
//  Created by tian on 2018/12/30.
//  Copyright © 2018 tian. All rights reserved.
//

import UIKit

public protocol ATNavigationControllerDelegate: NSObjectProtocol {
    func navigationC(_ nav: ATNavigationC, actionBeginAt point: CGPoint)
    func navigationC(_ nav: ATNavigationC, actionEndAt point: CGPoint)
}

public class ATNavigationC: UIViewController {
    
    public var viewControllers: [ATViewC] = []
    private(set) var isShow = false
    public weak var delegate: ATNavigationControllerDelegate? = nil
    private var pushPosition = [ATPosition]()
    private lazy var contentItem: ATItemView = {
        let contentItem = ATItemView.item(.system)
        contentItem.center = contentPoint
        return contentItem
    }()
    private lazy var contentView: UIView = {
        let contentView = UIView(frame: CGRect(x: 0, y: 0, width: ATLayoutAttributes.itemImageWidth, height: ATLayoutAttributes.itemImageWidth))
        contentView.center = contentPoint;
        contentView.layer.cornerRadius = ATLayoutAttributes.cornerRadius;
        return contentView
    }()
    private lazy var effectView: UIVisualEffectView = {
        let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        effectView.frame = contentView.bounds
        effectView.layer.cornerRadius = ATLayoutAttributes.cornerRadius
        effectView.layer.masksToBounds = true
        return effectView
    }()
    private var contentPoint: CGPoint {
        set {
            if isShow == false {
                _contentPoint = newValue
                contentView.center = newValue
                contentItem.center = newValue
            }
        }
        get {
            return _contentPoint
        }
    }
    private var _contentPoint: CGPoint = ATLayoutAttributes.contentViewDefaultPoint
    private var contentAlpha: CGFloat {
        set {
            if isShow == false {
                _contentAlpha = newValue
                contentView.alpha = newValue
                contentItem.alpha = newValue
            }
        }
        get {
            return _contentAlpha
        }
    }
    private var _contentAlpha: CGFloat = ATLayoutAttributes.inactiveAlpha
    private var timer: Timer? = nil
    
    override public var prefersStatusBarHidden: Bool {
        return false
    }
    
    override convenience init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.init(rootViewC: nil)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init(rootViewC: nil)
    }
    
    init(rootViewC: ATViewC?) {
        super.init(nibName: nil, bundle: nil)
        let temp = rootViewC ?? ATViewC()
        temp.navigationC = self
        viewControllers = [temp]
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(contentView)
        contentView.addSubview(effectView)
        self.view.addSubview(contentItem)
        self.view.frame = CGRect(x: 0,
                                 y: 0,
                                 width: ATLayoutAttributes.itemImageWidth,
                                 height: ATLayoutAttributes.itemImageWidth)
        contentPoint = CGPoint(x: ATLayoutAttributes.itemImageWidth / 2.0,
                               y: ATLayoutAttributes.itemImageWidth / 2.0)
        
        self.contentItem.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(spread)))
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(shrink)))
        self.contentItem.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(panGestureAction(_:))))
    }
    
    public func moveContentViewTo(_ point: CGPoint) {
        contentPoint = point
    }
    
    @objc public func spread() {
        if isShow {
            return
        }
        stopTimer()
        invokeActionBeginDelegate()
        isShow = true
        guard let count = viewControllers.first?.items.count else { return }
        for i in 0 ..< count {
            if let item = viewControllers.first?.items[i] {
                item.alpha = 0
                item.center = self.contentPoint
                self.view.addSubview(item)
                UIView.assistiveAnimation {
                    item.center = ATPosition(count: count, index: i).center
                    item.alpha = 1
                }
            }
        }
        UIView.assistiveAnimation {
            self.contentView.frame = ATLayoutAttributes.contentViewSpreadFrame
            self.effectView.frame = self.contentView.bounds
            self.contentView.alpha = 1
            self.contentItem.center = ATPosition(count: count, index: count - 1).center
            self.contentItem.alpha = 0
        }
    }
    
    @objc public func shrink() {
        guard isShow else {
            return
        }
        beginTimer()
        isShow = false
        for item in viewControllers.last?.items ?? [] {
            UIView.assistiveAnimation {
                item.center = self.contentPoint
                item.alpha = 0
            }
        }
        UIView.assistiveAnimation {
            self.viewControllers.last?.backItem.center = self.contentPoint
            self.viewControllers.last?.backItem.alpha = 0
        }
        UIView.animate(withDuration: ATLayoutAttributes.animationDuration, animations: {
            self.contentView.frame = CGRect(x: 0, y: 0, width: ATLayoutAttributes.itemImageWidth, height: ATLayoutAttributes.itemImageWidth)
            self.contentView.center = self.contentPoint
            self.effectView.frame = self.contentView.bounds
            self.contentItem.alpha = 1
            self.contentItem.center = self.contentPoint
        }) { _ in
            for viewC in self.viewControllers {
                viewC.items.forEach({ (item) in
                    item.removeFromSuperview()
                })
                viewC.backItem.removeFromSuperview()
            }
            self.viewControllers = [self.viewControllers.first] as! [ATViewC]
            self.invokeActionEndDelegate()
        }
    }
    
    public func push(_ viewC: ATViewC, at position: ATPosition) {
        guard let old = viewControllers.last else {
            print("no root")
            return
        }
        for item in old.items {
            UIView.assistiveAnimation {
                item.alpha = 0
            }
        }
        UIView.assistiveAnimation {
            old.backItem.alpha = 0
        }
        let count = viewC.items.count
        for i in 0 ..< count {
            let item = viewC.items[i]
            item.alpha = 0
            item.center = position.center
            self.view.addSubview(item)
            UIView.assistiveAnimation {
                item.center = ATPosition(count: count, index: i).center
                item.alpha = 1
            }
        }
        viewC.backItem.alpha = 0
        viewC.backItem.center = position.center
        self.view.addSubview(viewC.backItem)
        UIView.assistiveAnimation {
            viewC.backItem.center = self.view.center
            viewC.backItem.alpha = 1
        }
        viewC.navigationC = self
        viewControllers.append(viewC)
        pushPosition.append(position)
    }
    
    public func popViewController() {
        guard pushPosition.count > 0 else {
            return
        }
        let position = pushPosition.last!
        for item in viewControllers.last?.items ?? [] {
            UIView.assistiveAnimation {
                item.center = position.center
                item.alpha = 0
            }
        }
        UIView.animate(withDuration: ATLayoutAttributes.animationDuration, animations: {
            self.viewControllers.last?.backItem.center = position.center
            self.viewControllers.last?.backItem.alpha = 0
        }) { (_) in
            self.viewControllers.last?.items.forEach({ (item) in
                item.removeFromSuperview()
            })
            self.viewControllers.last?.backItem.removeFromSuperview()
            self.viewControllers.removeLast()
            self.pushPosition.removeLast()
            for item in self.viewControllers.last?.items ?? [] {
                UIView.assistiveAnimation {
                    item.alpha = 1
                }
            }
            UIView.assistiveAnimation {
                self.viewControllers.last?.backItem.alpha = 1
            }
        }
    }
    
    public func beginTimer() {
        timer = Timer(timeInterval: ATLayoutAttributes.activeDuration, target: self, selector: #selector(timerFired), userInfo: nil, repeats: false)
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    private func stopTimer() {
        if timer?.isValid == true {
            timer?.invalidate()
            timer = nil
        }
    }
    
    @objc private func timerFired() {
        UIView.assistiveAnimation {
            self.contentAlpha = ATLayoutAttributes.inactiveAlpha
        }
        stopTimer()
    }
    
    private static var pointOffset = CGPoint.zero
    @objc private func panGestureAction(_ gesture: UIGestureRecognizer) {
        let point = gesture.location(in: self.view)
        if gesture.state == .began {
            ATNavigationC.pointOffset = point
            invokeActionBeginDelegate()
            stopTimer()
            UIView.assistiveAnimation {
                self.contentAlpha = 1
            }
        } else if gesture.state == .changed {
            self.contentPoint = CGPoint(x: point.x + ATLayoutAttributes.itemImageWidth / 2.0 - ATNavigationC.pointOffset.x, y: point.y  + ATLayoutAttributes.itemImageWidth / 2.0 - ATNavigationC.pointOffset.y)
        } else if gesture.state == .ended || gesture.state == .cancelled || gesture.state == .failed {
            UIView.animate(withDuration: ATLayoutAttributes.animationDuration, animations: {
                self.contentPoint = self.stickToPointByHorizontal()
            }) { (_) in
                self.invokeActionEndDelegate()
                self.beginTimer()
            }
        }
    }
    
    private func stickToPointByHorizontal() -> CGPoint {
        let screen = UIScreen.main.bounds
        let center = self.contentPoint
        if center.y < center.x && center.y < -center.x + screen.size.width {
            let point = CGPoint(x: center.x,
                                y: ATLayoutAttributes.margin + ATLayoutAttributes.itemImageWidth / 2.0)
            return makePointValid(point)
        } else if center.y > center.x + screen.size.height - screen.size.width && center.y > -center.x + screen.size.height {
            let point = CGPoint(x: center.x, y: screen.height - ATLayoutAttributes.itemImageWidth / 2.0 - ATLayoutAttributes.margin)
            return makePointValid(point)
        } else {
            if center.x < screen.size.width / 2.0 {
                let point = CGPoint(x: ATLayoutAttributes.margin + ATLayoutAttributes.itemImageWidth / 2.0, y: center.y)
                return makePointValid(point)
            } else {
                let point = CGPoint(x: screen.width - ATLayoutAttributes.itemImageWidth / 2.0 - ATLayoutAttributes.margin, y: center.y);
                return makePointValid(point)
            }
        }
    }
    
    private func makePointValid(_ origin: CGPoint) -> CGPoint {
        var point = origin
        let screen = UIScreen.main.bounds
        if point.x < ATLayoutAttributes.margin + ATLayoutAttributes.itemImageWidth / 2.0 {
            point.x = ATLayoutAttributes.margin + ATLayoutAttributes.itemImageWidth / 2.0
        }
        if point.x > screen.width - ATLayoutAttributes.itemImageWidth / 2.0 - ATLayoutAttributes.margin {
            point.x = screen.width - ATLayoutAttributes.itemImageWidth / 2.0 - ATLayoutAttributes.margin
        }
        if point.y < ATLayoutAttributes.margin + ATLayoutAttributes.itemImageWidth / 2.0 {
            point.y = ATLayoutAttributes.margin + ATLayoutAttributes.itemImageWidth / 2.0
        }
        if point.y > screen.height - ATLayoutAttributes.itemImageWidth / 2.0 - ATLayoutAttributes.margin {
            point.y = screen.height - ATLayoutAttributes.itemImageWidth / 2.0 - ATLayoutAttributes.margin
        }
        return point
    }
    
    private func invokeActionBeginDelegate() {
        if isShow == false {
            delegate?.navigationC(self, actionBeginAt: contentPoint)
        }
    }
    
    private func invokeActionEndDelegate() {
        delegate?.navigationC(self, actionEndAt: contentPoint)
    }
}

fileprivate extension UIView {
    class func assistiveAnimation(animations: @escaping () -> Swift.Void) {
        UIView.animate(withDuration: ATLayoutAttributes.animationDuration, animations: animations)
    }
}
