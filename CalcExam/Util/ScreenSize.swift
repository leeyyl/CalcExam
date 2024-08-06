//
//  ScreeSize.swift
//  CalcExam
//
//  Created by Li YongYi on 2024/8/6.
//

import UIKit

final class ScreenSize {
    static var realScreenSize: (width: CGFloat, height: CGFloat) {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        return screenWidth > screenHeight ? (screenHeight, screenWidth) : (screenWidth, screenHeight)
    }
}
