//
//  CalcViewModelProtocol.swift
//  CalcExam
//
//  Created by Li YongYi on 2024/8/6.
//

import Foundation

protocol CalcViewModelProtocol {
    var valueUpdated: ((Decimal, Int, String?) -> Void)? { get set }
    var processUpdated: ((String) -> Void)? { get set }
    
    func acceptButtonInput(_ input: CalculatorButtonItem)
    func getOperand() -> Decimal
    func setOperand(_ operand: Decimal)
    func reset()
}
