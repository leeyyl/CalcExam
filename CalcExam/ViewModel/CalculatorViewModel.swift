//
//  CalculatorViewModel.swift
//  CalcExam
//
//  Created by Li YongYi on 2024/8/6.
//

import Foundation

class CalculatorViewModel: CalcViewModelProtocol {
    var valueUpdated: ((Decimal, Int, String?) -> Void)?
    var processUpdated: ((String) -> Void)?
    fileprivate var state: CalculatorState?
    
    init() {
        state = CalculatorState(context: self, previousOperand: 0)
    }
    
    func acceptButtonInput(_ input: CalculatorButtonItem) {
        state?.acceptButtonInput(input)
    }
    
    func getOperand() -> Decimal {
        return state?.currentOperand ?? state?.previousOperand ?? 0
    }
    
    func setOperand(_ operand: Decimal) {
        state?.currentOperand = operand
        state?.shouldReplace = true
        valueUpdated?(operand, 0, nil)
        state?.showProcess()
    }
    
    fileprivate func changeState(_ state: CalculatorState) {
        self.state = state
    }
    
    func reset() {
        valueUpdated?(0, 0, nil)
        processUpdated?("0")
        changeState(CalculatorState(context: self, previousOperand: 0))
    }
}

private class CalculatorState {
    unowned var context: CalculatorViewModel
    var previousOperand: Decimal
    var currentOperand: Decimal? = nil
    var oprator: CalculatorButtonItem.Operator?
    var fractionDigits: Int = 0
    var shouldReplace: Bool = false

    init(context: CalculatorViewModel, previousOperand: Decimal, oprator: CalculatorButtonItem.Operator? = nil) {
        self.context = context
        self.previousOperand = previousOperand
        self.oprator = oprator
    }

    func acceptButtonInput(_ input: CalculatorButtonItem) {
        switch input {
        case .digit(let digit):
            handleDigit(digit)
        case .dot:
            handleDot()
        case .operator(let op):
            handleOperator(op)
        case .command(let command):
            handleCommand(command)
        case .function, .blank:
            break
        }
    }

    func handleDigit(_ digit: Int) {
        let digitDecimal = Decimal(digit)
        if shouldReplace {
            shouldReplace = false
            currentOperand = digitDecimal
        } else if fractionDigits == 0 {
            currentOperand = (currentOperand ?? 0) * 10 + digitDecimal
        } else {
            currentOperand = (currentOperand ?? 0) + digitDecimal / pow(10, fractionDigits)
            fractionDigits += 1
        }

        context.valueUpdated?(currentOperand!, fractionDigits, nil)
        showProcess()
    }

    func handleDot() {
        if shouldReplace || currentOperand == nil {
            shouldReplace = false
            fractionDigits = 0
            currentOperand = 0
        }
        guard fractionDigits == 0 else { return }
        fractionDigits += 1

        context.valueUpdated?(currentOperand!, fractionDigits, nil)
    }

    func handleOperator(_ op: CalculatorButtonItem.Operator) {
        if currentOperand == nil {
            if op == .equal {
                currentOperand = previousOperand
            } else {
                oprator = op
                showProcess()
                return
            }
        }
        
        if let oprator = oprator {
            do {
                let result = try oprator.calculate(x: previousOperand, y: currentOperand!)
                let newState = CalculatorState(context: context, previousOperand: result, oprator: op)
                context.changeState(newState)
                context.valueUpdated?(result, 0, nil)
                showProcess(result: result)
            } catch CalculatorButtonItem.OperatorError.divisorIsZero {
                context.valueUpdated?(0, 0, "Not number")
            } catch {

            }
        } else {
            let newState = CalculatorState(context: context, previousOperand: currentOperand!, oprator: op)
            context.changeState(newState)
            newState.showProcess()
        }
    }

    fileprivate func handleCommand(_ command: CalculatorButtonItem.Command) {
        fractionDigits = 0
        switch command {
        case .clear:
            context.reset()
        case .flip:
            handleFlip()
        case .percent:
            handlePercent()
        case .delete:
            break
        }
    }

    func handleFlip() {
        if currentOperand == nil {
            currentOperand = previousOperand
        }
        currentOperand = -currentOperand!
        context.valueUpdated?(currentOperand!, 0, nil)
        showProcess()
    }

    func handlePercent() {
        shouldReplace = true
        if currentOperand == nil {
            currentOperand = previousOperand
        }
        currentOperand! /= 100
        context.valueUpdated?(currentOperand!, 0, nil)
        showProcess()
    }

    fileprivate func showProcess(result: Decimal? = nil) {
        if let oprator = oprator {
            let firstString = "\(previousOperand)"
            let operatorString = oprator.rawValue
            let secondString = currentOperand == nil ? "" : String(describing: currentOperand!)
            let resultString = result == nil ? "" : "=" + String(describing: result!)
            context.processUpdated?(firstString + operatorString + secondString + resultString)
        } else {
            context.processUpdated?(currentOperand == nil ? "" : String(describing: currentOperand!))
        }
    }
}
