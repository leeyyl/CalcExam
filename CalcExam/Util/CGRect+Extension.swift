//
//  CGRect+Extension.swift
//  CalcExam
//
//  Created by Li YongYi on 2024/8/6.
//

import UIKit

extension CGRect {
    func xOffest(_ xOff: CGFloat) -> CGRect {
        return CGRectMake(self.minX+xOff, self.minY, self.width, self.height)
    }
    
    func yOffset(_ yOff: CGFloat) -> CGRect {
        return CGRectMake(self.minX, self.minY+yOff, self.width, self.height)
    }
    
    func wOffset(_ wOff: CGFloat) -> CGRect {
        return CGRectMake(self.minX, self.minY, self.width+wOff, self.height)
    }
    
    func hOffset(_ hOff: CGFloat) -> CGRect {
        return CGRectMake(self.minX, self.minY, self.width, self.height+hOff)
    }
    
    func newWidth(_ w: CGFloat) -> CGRect {
        return CGRectMake(self.minX, self.minY, w, self.height)
    }
    
    func newHeight(_ h: CGFloat) -> CGRect {
        return CGRectMake(self.minX, self.minY, self.width, h)
    }
    
    var mj_x: CGFloat {
        get {
            return self.minX
        }
        set {
            self = CGRectMake(newValue, self.minY, self.width, self.height)
        }
    }
    
    var mj_y: CGFloat {
        get {
            return self.minY
        }
        set {
            self = CGRectMake(self.minX, newValue, self.width, self.height)
        }
    }
    
    var mj_w: CGFloat {
        get {
            return self.width
        }
        set {
            self = CGRectMake(self.minX, self.minY, newValue, self.height)
        }
    }
    
    var mj_h: CGFloat {
        get {
            return self.height
        }
        set {
            self = CGRectMake(self.minX, self.minY, self.width, newValue)
        }
    }
}

