//
//  ATViewC.swift
//  BrcIot
//
//  Created by tian on 2018/12/30.
//  Copyright © 2018 tian. All rights reserved.
//

import UIKit

public class ATViewC: UIResponder {
    
    public weak var navigationC: ATNavigationC? = nil
    public lazy var backItem: ATItemView = {
        let item = ATItemView.item( .back)
        item.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backGesture(_:))))
        return item
    }()
    public var items: [ATItemView] {
        set {
            if newValue.count > ATLayoutAttributes.maxCount {
                _items = [ATItemView](newValue.prefix(ATLayoutAttributes.maxCount))
            } else {
                _items = newValue
            }
            for i in 0 ..< _items.count {
                _items[i].position = ATPosition(count: _items.count, index: i)
            }
        }
        get {
            if _items.isEmpty {
                loadView()
                viewDidLoad()
            }
            return _items
        }
    }
    private var _items: [ATItemView] = []
    
    init(items: [ATItemView]) {
        super.init()
        self._items = items
    }
    
    override convenience init() {
        self.init(items: [])
    }
    
    public func loadView() {
        _items = [ATItemView.item(.none),
                  ATItemView.item(.none),
                  ATItemView.item(.none),
                  ATItemView.item(.none),
                  ATItemView.item(.none),
                  ATItemView.item(.none),
                  ATItemView.item(.none),
                  ATItemView.item(.none)]
    }
    
    public func viewDidLoad() {}
    
    @objc private func backGesture(_ gesture: UIGestureRecognizer) {
        self.navigationC?.popViewController()
    }
}
