//
//  SingleInstance.swift
//  CalcExam
//
//  Created by Li YongYi on 2024/8/6.
//

import Foundation

protocol SingleInstanceProtocol {
    associatedtype Item
    static var sceneInstance: Item? { get set }
    static var instance: Item { get }
}

protocol InstanceNotCreateProtocol {
    associatedtype Item
    static var sceneInstance: Item? { get set }
    static var instanceNotCreate: Item? { get }
}
