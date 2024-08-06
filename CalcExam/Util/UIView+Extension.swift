//
//  UIView+Extension.swift
//  CalcExam
//
//  Created by Li YongYi on 2024/8/6.
//

import UIKit

extension UIView {
    var left: CGFloat {
        return self.frame.minX
    }
    
    var right: CGFloat {
        return self.frame.maxX
    }
    
    var top: CGFloat {
        return self.frame.minY
    }
    
    var bottom: CGFloat {
        return self.frame.maxY
    }
}
