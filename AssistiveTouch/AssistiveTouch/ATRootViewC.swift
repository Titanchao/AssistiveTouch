//
//  ATRootViewC.swift
//  BrcIot
//
//  Created by tian on 2018/12/30.
//  Copyright © 2018 tian. All rights reserved.
//

import UIKit

protocol ATRootViewControllerDelegate: NSObjectProtocol {
    func numberOfItemsIn(_ viewC: ATRootViewC) -> Int
    func viewController(_ viewC: ATRootViewC, itemViewAt position: ATPosition) -> ATItemView?
    func viewController(_ viewC: ATRootViewC, didSelectedAt position: ATPosition)
}

class ATRootViewC: ATViewC {
    
    public weak var delegate: ATRootViewControllerDelegate? = nil
    override func loadView() {
        var itemsArray = [ATItemView]()
        var count = 0
        if let value = delegate?.numberOfItemsIn(self) {
            count = value
            count = min(max(count, 0), ATLayoutAttributes.maxCount)
        }
        for i in 0 ..< count {
            let item = delegate?.viewController(self, itemViewAt: ATPosition(count: count, index: i)) ?? ATItemView()
            item.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapGestureAction(_:))))
            itemsArray.append(item)
        }
        self.items = itemsArray
    }
    
    @objc private func tapGestureAction(_ gesture: UIGestureRecognizer) {
        if let item = gesture.view as? ATItemView {
            delegate?.viewController(self, didSelectedAt: item.position)
        }
    }
}
