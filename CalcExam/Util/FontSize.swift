//
//  FontSize.swift
//  CalcExam
//
//  Created by Li YongYi on 2024/8/6.
//

import Foundation

final class FontSize {
    internal static var singleIns: FontSize?
    static var instance: FontSize {
        if (FontSize.singleIns == nil) {
            FontSize.singleIns = FontSize()
        }
        return FontSize.singleIns!
    }
    
    private var textFontSize : CGFloat = -1.0
    
    var standardFontSize: CGFloat {
        if textFontSize < 0 {
            let (widthB, _) = ScreenSize.realScreenSize
            textFontSize = widthB / 22.0
        }
        return textFontSize
    }
}
