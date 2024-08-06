//
//  Decimal+Extension.swift
//  CalcExam
//
//  Created by Li YongYi on 2024/8/6.
//

import Foundation

extension Decimal {
    func toString(fractionDigit: Int = 0) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = fractionDigit
        let str = formatter.string(from: self as NSNumber) ?? ""
        return str
    }
}
