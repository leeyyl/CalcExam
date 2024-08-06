//
//  Timestamp.swift
//  CalcExam
//
//  Created by Li YongYi on 2024/8/6.
//

import Foundation

final class Timestamp {
    static var currentTimestamp: Int64 {
        return Int64(Date().timeIntervalSince1970 * 1000)
    }
}
