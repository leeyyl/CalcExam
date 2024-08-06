//
//  UILable+Extension.swift
//  CalcExam
//
//  Created by Li YongYi on 2024/8/6.
//

import Foundation
import UIKit

extension UILabel : UIExtensionProtocol {
    // MARK: - UIExtensionProtocol
    func getWithAddToSuperView(_ superView: UIView?) -> UILabel {
        superView?.addSubview(self)
        return self
    }
    func getWithBindClickEventWith(target: Any?, action: Selector, tag: Int?) -> UILabel {
        if tag != nil {
            self.tag = tag!
        }
        self.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: target, action: action)
        self.addGestureRecognizer(tap)
        return self
    }
}
