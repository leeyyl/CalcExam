//
//  UIExtensionProtocol.swift
//  CalcExam
//
//  Created by Li YongYi on 2024/8/6.
//

import Foundation
import UIKit

protocol UIExtensionProtocol {
    associatedtype UIItem
    func getWithAddToSuperView(_ superView: UIView?) -> UIItem
    func getWithBindClickEventWith(target: Any?, action: Selector, tag: Int?) -> UIItem
}
