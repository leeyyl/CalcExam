//
//  String+Extension.swift
//  CalcExam
//
//  Created by Li YongYi on 2024/8/6.
//

import Foundation

extension String {
    var tripedCommaStr: String {
        return self.replacingOccurrences(of: ",", with: "")
    }
    
    var containOperator: Bool {
        if operatorStr.isEmpty {
            return false
        } else {
            return true
        }
    }
    
    var operatorStr: String {
        let strTripFirst = String(self.dropFirst(1))
        
        if strTripFirst.contains("+") {
            return "+"
        } else if strTripFirst.contains("x") {
            return "x"
        } else if strTripFirst.contains("÷") {
            return "÷"
        } else if strTripFirst.contains("-") {
            return "-"
        } else {
            return ""
        }
    }
    
    var operatorStrPos: Index? {
        let opeStr_r = self.operatorStr
        if opeStr_r.isEmpty {
            return nil
        } else {
            let strTripFirst = String(self.dropFirst(1))
            let posIndex = strTripFirst.firstIndex(of: Character(opeStr_r))
            if posIndex != nil {
                let n_posIndex: Int = strTripFirst.distance(from: strTripFirst.startIndex, to: posIndex!)
                return self.index(self.startIndex, offsetBy: n_posIndex+1)
                //return strTripFirst.index(posIndex!, offsetBy: 1)
                //return self.index(after: posIndex!)
            } else {
                return nil
            }
        }
    }
    
    var operatorLeftStr: String {
        let strOpe = self.operatorStr
        if strOpe.isEmpty {
            return ""
        } else {
            let indexOpe = self.operatorStrPos
            if indexOpe != nil {
                return String(self[..<indexOpe!])
            } else {
                return ""
            }
        }
    }
    
    var operatorRightStr: String {
        let strOpe = self.operatorStr
        if strOpe.isEmpty {
            return ""
        } else {
            let indexOpe = self.operatorStrPos
            if indexOpe != nil {
                var strRight = String(self[self.index(indexOpe!, offsetBy: 1)...])
                if strRight.contains("=") {
                    strRight = String(strRight[..<strRight.lastIndex(of: "=")!])
                }
                return strRight
            } else {
                return ""
            }
        }
    }
    
    var hasBracket: Bool {
        if self.hasPrefix("(") && self.hasSuffix(")") {
            return true
        } else {
            return false
        }
    }
    
    var isEquationStr: Bool {
        if self.contains("=") {
            return true
        } else {
            return false
        }
    }
    
    var equationBeforeStr: String {
        var strRes = self
        if isEquationStr {
            let posIndex = self.firstIndex(of: Character("="))
            strRes = String(self[..<posIndex!])
        }
        return strRes
    }
    
    var coreNumStr: String {
        var strRes = self
        if self.hasBracket {
            strRes = String(strRes[strRes.index(strRes.startIndex, offsetBy: 1)...])
            strRes = String(strRes[..<strRes.index(strRes.endIndex, offsetBy: -1)])
        }
        return strRes
    }
    
    var isOperator: Bool {
        switch self {
        case "+":
            return true
        case "-":
            return true
        case "x":
            return true
        case "÷":
            return true
        default:
            return false
        }
    }
    
    var isFirstCharOperator: Bool {
        let strPrefix: String = String(self.first ?? Character(""))
        return strPrefix.isOperator
    }
    
    func getDelOneCharStrIfItIsNum() -> String {
        let strCoreNum = self.coreNumStr
        var strRes = self
        
        if strCoreNum.count <= 0 {
            strRes = ""
        } else if strCoreNum.count == 1 {
            if strCoreNum.isOperator {
                strRes = ""
            } else {
                strRes = ""
            }
        } else if strCoreNum.count == 2 {
            if strCoreNum.isFirstCharOperator {
                strRes = ""
            } else {
                if strCoreNum.hasSuffix(",") {
                    strRes = ""
                } else {
                    strRes = String(strCoreNum[..<strCoreNum.index(strCoreNum.endIndex, offsetBy: -1)])
                }
            }
        } else {
            if strCoreNum.hasSuffix(",") {
                strRes = String(strCoreNum[..<strCoreNum.index(strCoreNum.endIndex, offsetBy: -2)])
            } else {
                strRes = String(strCoreNum[..<strCoreNum.index(strCoreNum.endIndex, offsetBy: -1)])
            }
            
            if strCoreNum.isFirstCharOperator {
                if strRes.count <= 1 {
                    strRes = ""
                } else {
                    strRes = "(" + strRes + ")"
                }
            }
        }
        return strRes
    }
}
