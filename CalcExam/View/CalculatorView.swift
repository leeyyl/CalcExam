//
//  CalculatorView.swift
//  CalcExam
//
//  Created by Li YongYi on 2024/8/6.
//

import Foundation
import UIKit

class CalculatorView: UIView {
    var timeStampLatestClick: Int64 = -1
    
    private var alignmentCalcu: CalculatorAlignment = .center
    
    private weak var resultLabel: UILabel?
    private weak var resultShowLabel: UILabel?
    private weak var processLabel: UILabel?
    
    private weak var number0: UIButton?
    private weak var number1: UIButton?
    private weak var number2: UIButton?
    private weak var number3: UIButton?
    private weak var number4: UIButton?
    private weak var number5: UIButton?
    private weak var number6: UIButton?
    private weak var number7: UIButton?
    private weak var number8: UIButton?
    private weak var number9: UIButton?
    private weak var numberDecimal: UIButton?
    
    // Operators
    private weak var operatorAC: UIButton?
    private weak var operatorPlusMinus: UIButton?
    private weak var operatorPercent: UIButton?
    private weak var operatorResult: UIButton?
    private weak var operatorAddition: UIButton?
    private weak var operatorSubstraction: UIButton?
    private weak var operatorMultiplication: UIButton?
    private weak var operatorDivision: UIButton?
    
    // MARK: - Variables
    private var total: Double = 0                   // Total
    private var temp: Double = 0                    // Value per screen
    private var finishedCurCalculate = true         // just completed current calculate
    private var operating = false                   // Indicates whether an operator has been selected
    private var decimal = false                     // Indicates whether the value is in decimal
    private var operation: OperationType = .none    // Current operation
    
    // MARK: - Constantes
    private let kDecimalSeparator = Locale.current.decimalSeparator!
    private let kMaxLength = 9
    private let kTotal = "total"
    
    enum OperationType {
        case none, addiction, substraction, multiplication, division, percent
        var toStr: String {
            switch self {
            case .none:
                return ""
            case .addiction:
                return "+"
            case .substraction:
                return "-"
            case .multiplication:
                return "x"
            case .division:
                return "÷"
            case .percent:
                return "%"
            }
        }
        
        static func getFrom(_ strOpe: String) -> OperationType {
            switch strOpe {
            case "+":
                return .addiction
            case "-":
                return .substraction
            case "x":
                return .multiplication
            case "÷":
                return .division
            case "%":
                return .percent
            default:
                return .none
            }
        }
    }
    
    enum CalculatorAlignment {
        case left, center, right
    }
    
    // Format of auxiliary values
    private let auxFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        let locale = Locale.current
        formatter.groupingSeparator = ""
        formatter.decimalSeparator = locale.decimalSeparator
        formatter.numberStyle = .decimal
        formatter.maximumIntegerDigits = 100
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 100
        return formatter
    }()
    
    // Format of total auxiliary values
    private let auxTotalFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = ""
        formatter.decimalSeparator = ""
        formatter.numberStyle = .decimal
        formatter.maximumIntegerDigits = 100
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 100
        return formatter
    }()
    
    // Format of default screen values
    private let printFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        let locale = Locale.current
        formatter.groupingSeparator = locale.groupingSeparator
        formatter.decimalSeparator = locale.decimalSeparator
        formatter.numberStyle = .decimal
        formatter.maximumIntegerDigits = 9
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 8
        return formatter
    }()
    
    // Format values on screen in scientific format
    private let printScientificFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .scientific
        formatter.maximumFractionDigits = 3
        formatter.exponentSymbol = "e"
        return formatter
    }()
    
    convenience init(frame: CGRect, alignment: CalculatorAlignment, tag: Int) {
        self.init(frame: frame)
        self.alignmentCalcu = alignment
        self.tag = tag
        self.initUI()
        self.layoutSubviews()
        self.loadInfo()
    }
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private class func GetXInterFromFrameHeight(_ height: CGFloat) -> CGFloat {
        let (_, heightReal) = ScreenSize.realScreenSize
        let xInter = (FontSize.instance.standardFontSize * 0.8)*(height/heightReal)
        return xInter
    }
    
    private class func GetAppropriteSizeFrom(width: CGFloat, height: CGFloat) -> (suggestW: CGFloat, suggestH: CGFloat) {
        let numX = 4
        let numY = 5
        let xInter = CalculatorView.GetXInterFromFrameHeight(height)
        let yInter = xInter
        var sizeSmallBtn = (width - (CGFloat(numX)+1.0)*xInter)/CGFloat(numX)
        let fontSizeSmallBtn: CGFloat = sizeSmallBtn/1.8
        let fontSizeResult = fontSizeSmallBtn * 1.3
        let hResult = fontSizeResult * 1.5
        let fontSizeProcess = fontSizeSmallBtn * 0.85
        let hProcess = fontSizeProcess * 1.5
        let rateResult = hResult/sizeSmallBtn
        let rateProcess = hProcess/sizeSmallBtn
        
        let hFinal = CGFloat(numY)*sizeSmallBtn + CGFloat(numY+4)*yInter + hResult + hProcess
        if hFinal < height {
            return (width, height)
        } else {
            sizeSmallBtn = (height - CGFloat(numY+4)*yInter)/(CGFloat(numY)+rateResult+rateProcess)
            let wFinal = CGFloat(numX)*sizeSmallBtn + CGFloat(numX+1)*xInter
            return (wFinal, height)
        }
    }
    
    var divisionOperatorRect: CGRect {
        if operatorDivision != nil {
            return operatorDivision!.frame
        } else {
            return CGRectMake(0, self.frame.height/3.0, FontSize.instance.standardFontSize*2.5, FontSize.instance.standardFontSize*2.5)
        }
    }
    
    override func layoutSubviews() {
        let (widthR, heightR) = CalculatorView.GetAppropriteSizeFrom(width: self.frame.width, height: self.frame.height)
        var xStart: CGFloat = (self.frame.width-widthR)*0.5
        if alignmentCalcu == .left {
            xStart = 0.0
        } else if alignmentCalcu == .right {
            xStart = self.frame.width - widthR
        }
        
        let wTotal = widthR
        let hTotal = heightR
        let numX = 4
        let xInter = CalculatorView.GetXInterFromFrameHeight(self.frame.height)
        let yInter = xInter
        let sizeSmallBtn = (wTotal - (CGFloat(numX)+1.0)*xInter)/CGFloat(numX)
        let fontSizeSmallBtn: CGFloat = sizeSmallBtn/1.8
        let fontSizeResult = fontSizeSmallBtn * 1.3
        let fontSizeProcess = fontSizeSmallBtn * 0.85
        let wResult = wTotal - 2.0 * xInter
        let hResult = fontSizeResult * 1.5
        let wProcess = wTotal - 2.0 * xInter
        let hProcess = fontSizeProcess * 1.5
        let radiusBtn = sizeSmallBtn * 0.25
        
        let topLastLine = hTotal - yInter - sizeSmallBtn
        let leftFirst = xStart + xInter
        let xAddOneStep = xInter + sizeSmallBtn
        let yAddOneStep = -1.0 * (yInter + sizeSmallBtn)
        number0?.frame = CGRectMake(leftFirst, topLastLine, sizeSmallBtn*2.0+xInter, sizeSmallBtn)
        numberDecimal?.frame = number0!.frame.xOffest(2.0*(xInter+sizeSmallBtn)).newWidth(sizeSmallBtn)
        operatorResult?.frame = numberDecimal!.frame.xOffest(xAddOneStep)
        
        number1?.frame = number0!.frame.yOffset(yAddOneStep).newWidth(sizeSmallBtn)
        number2?.frame = number1!.frame.xOffest(xAddOneStep)
        number3?.frame = number2!.frame.xOffest(xAddOneStep)
        operatorAddition?.frame = number3!.frame.xOffest(xAddOneStep)
        
        number4?.frame = number1!.frame.yOffset(yAddOneStep)
        number5?.frame = number4!.frame.xOffest(xAddOneStep)
        number6?.frame = number5!.frame.xOffest(xAddOneStep)
        operatorSubstraction?.frame = number6!.frame.xOffest(xAddOneStep)
        
        number7?.frame = number4!.frame.yOffset(yAddOneStep)
        number8?.frame = number7!.frame.xOffest(xAddOneStep)
        number9?.frame = number8!.frame.xOffest(xAddOneStep)
        operatorMultiplication?.frame = number9!.frame.xOffest(xAddOneStep)
        
        operatorAC?.frame = number7!.frame.yOffset(yAddOneStep)
        operatorPlusMinus?.frame = operatorAC!.frame.xOffest(xAddOneStep)
        operatorPercent?.frame = operatorPlusMinus!.frame.xOffest(xAddOneStep)
        operatorDivision?.frame = operatorPercent!.frame.xOffest(xAddOneStep)
        
        let arrBtn: [UIButton] = [number0!,number1!,number2!,number3!,number4!,number5!,number6!,number7!,number8!,number9!,numberDecimal!,operatorResult!,operatorAddition!,operatorSubstraction!,operatorMultiplication!,operatorDivision!,operatorPercent!,operatorPlusMinus!,operatorAC!]
        self.setBtnList(arrBtn, fontSize: fontSizeSmallBtn, radius: radiusBtn)
        
        processLabel?.frame = operatorAC!.frame.yOffset(-yInter-hProcess).newWidth(wProcess).newHeight(hProcess)
        processLabel?.font = UIFont.systemFont(ofSize: fontSizeProcess)
        
        resultLabel?.frame = processLabel!.frame.yOffset(-yInter-hResult).newWidth(wResult).newHeight(hResult)
        resultLabel?.font = UIFont.systemFont(ofSize: fontSizeResult)
        
        resultShowLabel?.frame = resultLabel!.frame
        resultShowLabel?.font = UIFont.systemFont(ofSize: fontSizeResult)
    }
    
    // (strResult: String, strResultShow: String, strProcess: String, total: Double, temp: Double, operating: Bool, Operation: OperationType, decimal:Bool, finishedCurCalculate: Bool)
    func getCurInfo() -> (String, String, String, Double, Double, Bool, OperationType, Bool, Bool) {
        return (resultLabel?.text ?? "", resultShowLabel?.text ?? "", processLabel?.text ?? "", total, temp, operating, operation, decimal, finishedCurCalculate)
    }
    
    // (strResult: String, strResultShow: String, strProcess: String, total: Double, temp: Double, operating: Bool, Operation: OperationType, decimal:Bool, finishedCurCalculate: Bool)
    func setCurInfo(_ infoDetail: (String, String, String, Double, Double, Bool, OperationType, Bool, Bool)) {
        resultLabel?.text = infoDetail.0
        resultShowLabel?.text = infoDetail.1
        processLabel?.text = infoDetail.2
        total = infoDetail.3
        temp = infoDetail.4
        operating = infoDetail.5
        operation = infoDetail.6
        decimal = infoDetail.7
        finishedCurCalculate = infoDetail.8
        
        selectVisualOperation()
    }
    
    var curShowResult: String {
        let strCurProcess = processLabel?.text ?? ""
        let strShow = resultShowLabel?.text ?? ""
        if strCurProcess.isEquationStr || strCurProcess.containOperator {
            return strShow
        } else {
            if strShow.isEmpty || strShow == "0" {
                return strCurProcess
            } else {
                return strShow
            }
        }
    }
    
    func transferShowResult(_ strResult: String) {
        if strResult.isEmpty {
            return
        }
        let totalCur = Double(strResult.tripedCommaStr) ?? 0
        UserDefaults.standard.set(totalCur, forKey: kTotal+String(self.tag))
        
        total = totalCur
        temp = 0
        operating = false
        decimal = false
        operation = .none
        finishedCurCalculate = true
        loadInfo()
    }
    
    var canDelOneChar: Bool {
        let strCurProcess = processLabel?.text ?? ""
        if strCurProcess.isEmpty || strCurProcess == "0" {
            return false
        } else {
            return true
        }
    }
    
    func onDelOneChar() {
        let strCurProcess = processLabel?.text ?? ""
        if strCurProcess.isEmpty || strCurProcess == "0" {
            processLabel?.text = "0"
            resultLabel?.text = "0"
            return
        }
        
        if strCurProcess.count == 1 {
            clear()
            finishedCurCalculate = true
        } else {
            let hasOpeBefore = strCurProcess.containOperator
            let isEquationBefore = strCurProcess.isEquationStr
            if isEquationBefore {
                let strLeft = strCurProcess.operatorLeftStr
                let strRight = strCurProcess.operatorRightStr
                total = Double(strLeft.tripedCommaStr) ?? 0
                temp = Double(strRight.coreNumStr.tripedCommaStr) ?? 0
                finishedCurCalculate = false
                operating = false
                operation = OperationType.getFrom(strCurProcess.operatorStr)
                processLabel?.text = strCurProcess.equationBeforeStr
                resultLabel?.text = strRight
            } else if hasOpeBefore {
                let strLeft = strCurProcess.operatorLeftStr
                let strRight = strCurProcess.operatorRightStr
                let strOpe = strCurProcess.operatorStr
                if strRight.isEmpty {
                    operating = false
                    operation = .none
                    total = 0
                    temp = Double(strLeft.coreNumStr.tripedCommaStr) ?? 0
                    processLabel?.text = strLeft
                    resultLabel?.text = strLeft
                    
                } else {
                    let strRightDel = strRight.getDelOneCharStrIfItIsNum()
                    let dRightDel: Double = Double(strRightDel.coreNumStr.tripedCommaStr) ?? 0
                    temp = dRightDel
                    processLabel?.text = strLeft + strOpe + strRightDel
                    if strRightDel.isEmpty {
                        resultLabel?.text = strLeft
                    } else {
                        resultLabel?.text = strRightDel
                    }
                }
            } else {
                var strSingleNum = strCurProcess.getDelOneCharStrIfItIsNum().coreNumStr
                if strSingleNum.isEmpty {
                    strSingleNum = "0"
                }
                processLabel?.text = strSingleNum
                resultLabel?.text = strSingleNum
                temp = Double(strSingleNum.tripedCommaStr) ?? 0
                total = 0
            }
        }
    }
    
    private func setBtnList(_ arrBtn: [UIButton]?, fontSize: CGFloat, radius: CGFloat) {
        if arrBtn != nil {
            for btn in arrBtn! {
                btn.titleLabel?.font = UIFont.systemFont(ofSize: fontSize)
                btn.layer.cornerRadius = radius
            }
        }
    }
    
    private func createBaseLabelWithText(strText: String) -> UILabel {
        let colorResultBnd: UIColor = .clear
        let colorResultText: UIColor = .white
        
        let label = UILabel()
        label.text = strText
        label.backgroundColor = colorResultBnd
        label.textColor = colorResultText
        
        return label
    }
    
    private func createBaseNumberBtnWithTitle(strTitle: String) -> UIButton {
        let cornerRadiusBtn: CGFloat = 5.0
        let colorNumberBtnBnd: UIColor = .darkGray
        let colorNumberBtnText: UIColor = .white
        
        let numberBtn = UIButton()
        numberBtn.setTitle(strTitle, for: .normal)
        numberBtn.setTitleColor(colorNumberBtnText, for: .normal)
        numberBtn.backgroundColor = colorNumberBtnBnd
        numberBtn.layer.masksToBounds = true
        numberBtn.layer.cornerRadius = cornerRadiusBtn
        
        return numberBtn
    }
    
    private func createBaseSpecialBtnWithTitle(strTitle: String) -> UIButton {
        let cornerRadiusBtn: CGFloat = 5.0
        let colorSpecialBtnBnd: UIColor = .lightGray
        let colorSpecialBtnText: UIColor = .white
        
        let specialBtn = UIButton()
        specialBtn.setTitle(strTitle, for: .normal)
        specialBtn.setTitleColor(colorSpecialBtnText, for: .normal)
        specialBtn.backgroundColor = colorSpecialBtnBnd
        specialBtn.layer.masksToBounds = true
        specialBtn.layer.cornerRadius = cornerRadiusBtn
        
        return specialBtn
    }
    
    private func createBaseOperatorBtnWithTitle(strTitle: String) -> UIButton {
        let cornerRadiusBtn: CGFloat = 5.0
        let colorOperatorBtnBnd: UIColor = .orange
        let colorOperatorBtnText: UIColor = .white
        
        let opeBtn = UIButton()
        opeBtn.setTitle(strTitle, for: .normal)
        opeBtn.setTitleColor(colorOperatorBtnText, for: .normal)
        opeBtn.backgroundColor = colorOperatorBtnBnd
        opeBtn.layer.masksToBounds = true
        opeBtn.layer.cornerRadius = cornerRadiusBtn
        
        return opeBtn
    }
    
    private func initUI() {
        self.backgroundColor = .black
        
        if operatorDivision != nil {
            return
        }
        
        resultLabel = createBaseLabelWithText(strText: "0").getWithAddToSuperView(self)
        resultLabel?.textAlignment = .right
        resultLabel?.isHidden = true
        resultShowLabel = createBaseLabelWithText(strText: "0").getWithAddToSuperView(self)
        resultShowLabel?.textAlignment = .right
        processLabel = createBaseLabelWithText(strText: "0").getWithAddToSuperView(self)
        processLabel?.textAlignment = .left
        number0 = createBaseNumberBtnWithTitle(strTitle: "0").getWithAddToSuperView(self).getWithBindClickEventWith(target: self, action: #selector(numberAction(_:)), tag: 0)
        number1 = createBaseNumberBtnWithTitle(strTitle: "1").getWithAddToSuperView(self).getWithBindClickEventWith(target: self, action: #selector(numberAction(_:)), tag: 1)
        number2 = createBaseNumberBtnWithTitle(strTitle: "2").getWithAddToSuperView(self).getWithBindClickEventWith(target: self, action: #selector(numberAction(_:)), tag: 2)
        number3 = createBaseNumberBtnWithTitle(strTitle: "3").getWithAddToSuperView(self).getWithBindClickEventWith(target: self, action: #selector(numberAction(_:)), tag: 3)
        number4 = createBaseNumberBtnWithTitle(strTitle: "4").getWithAddToSuperView(self).getWithBindClickEventWith(target: self, action: #selector(numberAction(_:)), tag: 4)
        number5 = createBaseNumberBtnWithTitle(strTitle: "5").getWithAddToSuperView(self).getWithBindClickEventWith(target: self, action: #selector(numberAction(_:)), tag: 5)
        number6 = createBaseNumberBtnWithTitle(strTitle: "6").getWithAddToSuperView(self).getWithBindClickEventWith(target: self, action: #selector(numberAction(_:)), tag: 6)
        number7 = createBaseNumberBtnWithTitle(strTitle: "7").getWithAddToSuperView(self).getWithBindClickEventWith(target: self, action: #selector(numberAction(_:)), tag: 7)
        number8 = createBaseNumberBtnWithTitle(strTitle: "8").getWithAddToSuperView(self).getWithBindClickEventWith(target: self, action: #selector(numberAction(_:)), tag: 8)
        number9 = createBaseNumberBtnWithTitle(strTitle: "9").getWithAddToSuperView(self).getWithBindClickEventWith(target: self, action: #selector(numberAction(_:)), tag: 9)
        numberDecimal = createBaseNumberBtnWithTitle(strTitle: ".").getWithAddToSuperView(self).getWithBindClickEventWith(target: self, action: #selector(numberDecimalAction(_:)), tag: nil)
        
        // Operators
        operatorAC = createBaseSpecialBtnWithTitle(strTitle: "AC").getWithAddToSuperView(self).getWithBindClickEventWith(target: self, action: #selector(operatorACAction(_:)), tag: nil)
        operatorPlusMinus = createBaseSpecialBtnWithTitle(strTitle: "+/-").getWithAddToSuperView(self).getWithBindClickEventWith(target: self, action: #selector(operatorPlusMinusAction(_:)), tag: nil)
        operatorPercent = createBaseSpecialBtnWithTitle(strTitle: "%").getWithAddToSuperView(self).getWithBindClickEventWith(target: self, action: #selector(operatorPercentAction(_:)), tag: nil)
        
        // Operators
        operatorResult = createBaseOperatorBtnWithTitle(strTitle: "=").getWithAddToSuperView(self).getWithBindClickEventWith(target: self, action: #selector(operatorResultAction(_:)), tag: nil)
        operatorAddition = createBaseOperatorBtnWithTitle(strTitle: "+").getWithAddToSuperView(self).getWithBindClickEventWith(target: self, action: #selector(operatorAdditionAction(_:)), tag: nil)
        operatorSubstraction = createBaseOperatorBtnWithTitle(strTitle: "-").getWithAddToSuperView(self).getWithBindClickEventWith(target: self, action: #selector(operatorSubstractionAction(_:)), tag: nil)
        operatorMultiplication = createBaseOperatorBtnWithTitle(strTitle: "x").getWithAddToSuperView(self).getWithBindClickEventWith(target: self, action: #selector(operatorMultiplicationAction(_:)), tag: nil)
        operatorDivision = createBaseOperatorBtnWithTitle(strTitle: "÷").getWithAddToSuperView(self).getWithBindClickEventWith(target: self, action: #selector(operatorDivisionnAction(_:)), tag: nil)
    }
    
    private func loadInfo() {
        numberDecimal?.setTitle(kDecimalSeparator, for: .normal)
        total = UserDefaults.standard.double(forKey: kTotal+String(self.tag))
        result()
        processLabel?.text = resultLabel?.text
        resultShowLabel?.text = resultLabel?.text
    }
    
    private func refreshResultShowLabel() {
        resultShowLabel?.text = resultLabel!.text
    }
    
    private func refreshProcessAfterClickResultFrom(strResult: String) {
        if processLabel!.text != nil && processLabel!.text!.containOperator {
            let strOpe = processLabel!.text!.operatorStr
            let strLeft = processLabel!.text!.operatorLeftStr
            let strRight = processLabel!.text!.operatorRightStr
            
            if !strRight.isEmpty {
                processLabel?.text = strLeft + strOpe + strRight + "=" + strResult
            }
        } else {
            processLabel?.text = strResult
        }
    }
    
    private func refreshProcessWithPlusMinusActFromCurStr(_ strCur: String, isResult: Bool) {
        if isResult {
            processLabel?.text = strCur
        } else {
            if processLabel!.text != nil && processLabel!.text!.containOperator {
                var strOpe = processLabel!.text!.operatorStr
                if operation == .addiction {
                    strOpe = "+"
                } else if operation == .substraction {
                    strOpe = "-"
                }
                let strLeft = processLabel!.text!.operatorLeftStr
                var strCur_r = strCur
                
                if strCur.hasPrefix("-") {
                    if strOpe == "+" {
                        strOpe = "-"
                        strCur_r = String(strCur.dropFirst(1))
                    } else if strOpe == "-" {
                        strOpe = "+"
                        strCur_r = String(strCur.dropFirst(1))
                    } else {
                        strCur_r = "(" + strCur + ")"
                    }
                    processLabel?.text = strLeft + strOpe + strCur_r
                } else {
                    processLabel?.text = strLeft + strOpe + strCur
                }
                
            } else {
                processLabel?.text = strCur
            }
        }
    }
    
    private func refreshProcessFromCurStr(_ strCur: String, isResult: Bool) {
        
        if isResult {
            processLabel?.text = strCur
        } else {
            if processLabel!.text != nil && processLabel!.text!.containOperator {
                var strOpe = processLabel!.text!.operatorStr
                let strLeft = processLabel!.text!.operatorLeftStr
                var strCur_r = strCur
                
                if strCur.hasPrefix("-") {
                    if strOpe == "+" {
                        strOpe = "-"
                        strCur_r = String(strCur.dropFirst(1))
                    } else if strOpe == "-" {
                        strOpe = "+"
                        strCur_r = String(strCur.dropFirst(1))
                    } else {
                        strCur_r = "(" + strCur + ")"
                    }
                    processLabel?.text = strLeft + strOpe + strCur_r
                } else {
                    processLabel?.text = strLeft + processLabel!.text!.operatorStr + strCur
                }
                
            } else {
                processLabel?.text = strCur
            }
        }
    }
    
    private func refreshProcessFromCurStr(_ strCur: String, operationCur: OperationType) {
        if operationCur == .addiction || operationCur == .substraction || operationCur == .multiplication || operationCur == .division {
            
            processLabel?.text = strCur + operationCur.toStr
        } else {
            processLabel?.text = strCur
        }
    }
    
    // MARK: - Button Actions
    
    @objc func operatorACAction(_ sender: UIButton) {
        timeStampLatestClick = Timestamp.currentTimestamp
        
        clear()
        finishedCurCalculate = true
        sender.shine()
    }
    
    @objc func operatorPlusMinusAction(_ sender: UIButton) {
        timeStampLatestClick = Timestamp.currentTimestamp
        
        if finishedCurCalculate {
            result()
            total = total * (-1)
            temp = total
            resultLabel?.text = printFormatter.string(from: NSNumber(value: total))
            refreshProcessWithPlusMinusActFromCurStr(resultLabel?.text ?? "", isResult: true)
        } else {
            temp = temp * (-1)
            resultLabel?.text = printFormatter.string(from: NSNumber(value: temp))
            refreshProcessWithPlusMinusActFromCurStr(resultLabel?.text ?? "", isResult: false)
        }
        finishedCurCalculate = false
        sender.shine()
    }
    
    @objc func operatorPercentAction(_ sender: UIButton) {
        timeStampLatestClick = Timestamp.currentTimestamp
        
        if operation != .percent {
            result()
        }
        operating = true
        operation = .percent
        result()
        refreshProcessFromCurStr(resultLabel?.text ?? "", isResult: true)
        finishedCurCalculate = false
    
        sender.shine()
    }
    
    @objc func operatorResultAction(_ sender: UIButton) {
        timeStampLatestClick = Timestamp.currentTimestamp
        
        result()
        refreshProcessAfterClickResultFrom(strResult: resultLabel?.text ?? "")
        refreshResultShowLabel()
        finishedCurCalculate = true
        sender.shine()
    }
    
    @objc func operatorAdditionAction(_ sender: UIButton) {
        timeStampLatestClick = Timestamp.currentTimestamp
        
        if operation != .none {
            result()
        }
        
        operating = true
        operation = .addiction
        refreshProcessFromCurStr(resultLabel?.text ?? "", operationCur: operation)
        
        finishedCurCalculate = false
        
        sender.selectOperation(true)
        sender.shine()
    }
    
    @objc func operatorSubstractionAction(_ sender: UIButton) {
        timeStampLatestClick = Timestamp.currentTimestamp
        
        if operation != .none {
            result()
        }
        
        operating = true
        operation = .substraction
        refreshProcessFromCurStr(resultLabel?.text ?? "", operationCur: operation)
        
        finishedCurCalculate = false
        
        sender.selectOperation(true)
        sender.shine()
    }
    
    @objc func operatorMultiplicationAction(_ sender: UIButton) {
        timeStampLatestClick = Timestamp.currentTimestamp
        
        if operation != .none {
            result()
        }
        
        operating = true
        operation = .multiplication
        refreshProcessFromCurStr(resultLabel?.text ?? "", operationCur: operation)
        finishedCurCalculate = false
        
        sender.selectOperation(true)
        sender.shine()
    }
    
    @objc func operatorDivisionnAction(_ sender: UIButton) {
        timeStampLatestClick = Timestamp.currentTimestamp
        
        if operation != .none {
            result()
        }
        
        operating = true
        operation = .division
        refreshProcessFromCurStr(resultLabel?.text ?? "", operationCur: operation)
        finishedCurCalculate = false
        
        sender.selectOperation(true)
        sender.shine()
    }
    
    @objc func numberDecimalAction(_ sender: UIButton) {
        timeStampLatestClick = Timestamp.currentTimestamp
        
        if finishedCurCalculate {
            temp = 0
        }
        
        let currentTemp = auxTotalFormatter.string(from: NSNumber(value: temp))!
        if resultLabel!.text?.contains(kDecimalSeparator) ?? false || (!operating && currentTemp.count >= kMaxLength) {
            return
        }
        
        resultLabel!.text = resultLabel!.text! + kDecimalSeparator
        refreshProcessFromCurStr(resultLabel!.text ?? "", isResult: finishedCurCalculate)
        decimal = true
        
        selectVisualOperation()
        
        finishedCurCalculate = false

        sender.shine()
    }
    
    @objc func numberAction(_ sender: UIButton) {
        timeStampLatestClick = Timestamp.currentTimestamp
        
        if finishedCurCalculate {
            temp = 0
            total = 0
        }
        
        operatorAC?.setTitle("C", for: .normal)
        
        var currentTemp = auxTotalFormatter.string(from: NSNumber(value: temp))!
        if !operating && currentTemp.count >= kMaxLength {
            return
        }
        
        currentTemp = auxFormatter.string(from: NSNumber(value: temp))!
        
        // If have chosen an operation
        if operating {
            total = total == 0 ? temp : total
            resultLabel?.text = ""
            currentTemp = ""
            operating = false
        }
        
        // If have chosen decimals
        if decimal {
            currentTemp = "\(currentTemp)\(kDecimalSeparator)"
            decimal = false
        }
        
        let number = sender.tag
        temp = Double((currentTemp + String(number)).tripedCommaStr)!
        resultLabel?.text = printFormatter.string(from: NSNumber(value: temp))
        refreshProcessFromCurStr(resultLabel!.text ?? "", isResult: finishedCurCalculate)
        
        selectVisualOperation()
        
        finishedCurCalculate = false
        
        sender.shine()
    }
    
    // Clear value
    private func clear() {
        if operation == .none {
            total = 0
        }
        operation = .none
        operatorAC?.setTitle("AC", for: .normal)
        if temp != 0 {
            temp = 0
            resultLabel?.text = "0"
        } else {
            total = 0
            result()
        }
        processLabel?.text = "0"
        resultShowLabel?.text = "0"
    }
    
    // Obtain the final result
    private func result() {
        switch operation {
        case .none:
            // don't do anything
            break
        case .addiction:
            total = total + temp
            break
        case .substraction:
            total = total - temp
            break
        case .multiplication:
            total = total * temp
            break
        case .division:
            total = total / temp
            break
        case .percent:
            if finishedCurCalculate {
                temp = total / 100
            } else {
                temp = temp / 100
            }
            total = temp
        }
        
        // Screen format
        if let currentTotal = auxTotalFormatter.string(from: NSNumber(value: total)), currentTotal.count > kMaxLength {
            resultLabel?.text = printScientificFormatter.string(from: NSNumber(value: total))
        } else {
            resultLabel?.text = printFormatter.string(from: NSNumber(value: total))
        }
        
        operation = .none
        selectVisualOperation()
        UserDefaults.standard.set(total, forKey: kTotal+String(self.tag))
        print("TOTAL: \(total)")
    }
    
    // Visualize the selected operation
    private func selectVisualOperation() {
        if !operating {
            // Don't have any operations
            operatorAddition?.selectOperation(false)
            operatorSubstraction?.selectOperation(false)
            operatorMultiplication?.selectOperation(false)
            operatorDivision?.selectOperation(false)
        } else {
            switch operation {
            case .none, .percent:
                operatorAddition?.selectOperation(false)
                operatorSubstraction?.selectOperation(false)
                operatorMultiplication?.selectOperation(false)
                operatorDivision?.selectOperation(false)
                break
            case .addiction:
                operatorAddition?.selectOperation(true)
                operatorSubstraction?.selectOperation(false)
                operatorMultiplication?.selectOperation(false)
                operatorDivision?.selectOperation(false)
                break
            case .substraction:
                operatorAddition?.selectOperation(false)
                operatorSubstraction?.selectOperation(true)
                operatorMultiplication?.selectOperation(false)
                operatorDivision?.selectOperation(false)
                break
            case .multiplication:
                operatorAddition?.selectOperation(false)
                operatorSubstraction?.selectOperation(false)
                operatorMultiplication?.selectOperation(true)
                operatorDivision?.selectOperation(false)
                break
            case .division:
                operatorAddition?.selectOperation(false)
                operatorSubstraction?.selectOperation(false)
                operatorMultiplication?.selectOperation(false)
                operatorDivision?.selectOperation(true)
                break
            }
        }
    }
}
