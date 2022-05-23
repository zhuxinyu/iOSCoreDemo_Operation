//
//  ViewController.swift
//  iOSCoreDemo_Operation
//
//  Created by xyz on 2022/5/9.
//

import UIKit
import Foundation

public enum OCConstant {
    case integer(Int)
    case float(Float)
    case boolean(Bool)
    case string(String)
}

public enum OCBinOpType {
    case plus
    case minus
    case mult
    case intDiv
}

public enum OCDirection {
    case left
    case right
}

public enum OCToken {
    case constant(OCConstant)
    case operation(OCBinOpType)
    case paren(OCDirection)
    case eof
    case whiteSpaceAndNewLine
}

public enum OCNumber: OCAST {
    case integer(Int)
    case float(Float)
}

public enum OCValue {
    case number(OCNumber)
    case none
}

public protocol OCAST {}

extension OCConstant: Equatable {
    public static func == (lhs: OCConstant, rhs: OCConstant) -> Bool {
        switch (lhs, rhs) {
        case let (.integer(left), .integer(right)):
            return left == right
        case let (.float(left), .float(right)):
            return left == right
        case let (.boolean(left), .boolean(right)):
            return left == right
        case let (.string(left), .string(right)):
            return left == right
        default:
            return false
        }
    }
}

extension OCBinOpType: Equatable {
    public static func == (lhs: OCBinOpType, rhs: OCBinOpType) -> Bool {
        switch (lhs, rhs) {
        case (.plus, .plus):
            return true
        case (.minus, .minus):
            return true
        case (.mult, .mult):
            return true
        case (.intDiv, .intDiv):
            return true
        default:
            return false
        }
    }
}

extension OCDirection: Equatable {
    public static func == (lhs: OCDirection, rhs: OCDirection) -> Bool {
        switch (lhs, rhs) {
        case (.left, .left):
            return true
        case (.right, .right):
            return true
        default:
            return false
        }
    }
}

extension OCToken: Equatable {
    public static func == (lhs: OCToken, rhs: OCToken) -> Bool {
        switch (lhs, rhs) {
        case let (.constant(left), .constant(right)):
            return left == right
        case let (.operation(left), .operation(right)):
            return left == right
        case let (.paren(left), .paren(right)):
            return left == right
        case (.eof, .eof):
            return true
        case (.whiteSpaceAndNewLine, .whiteSpaceAndNewLine):
            return true
        default:
            return false
        }
    }
}

extension OCNumber {
    // binOp
    static func + (left: OCNumber, right: OCNumber) -> OCNumber {
        switch (left, right) {
        case let (.integer(left), .integer(right)):
            return .integer(left + right)
        case let (.float(left), .float(right)):
            return .float(left + right)
        case let (.integer(left), .float(right)):
            return .float(Float(left) + right)
        case let (.float(left), .integer(right)):
            return .float(left + Float(right))
        }
    }
    
    static func - (left: OCNumber, right: OCNumber) -> OCNumber {
        switch (left, right) {
        case let (.integer(left), .integer(right)):
            return .integer(left - right)
        case let (.float(left), .float(right)):
            return .float(left - right)
        case let (.integer(left), .float(right)):
            return .float(Float(left) - right)
        case let (.float(left), .integer(right)):
            return .float(left - Float(right))
        }
    }
    
    static func * (left: OCNumber, right: OCNumber) -> OCNumber {
        switch (left, right) {
        case let (.integer(left), .integer(right)):
            return .integer(left * right)
        case let (.float(left), .float(right)):
            return .float(left * right)
        case let (.integer(left), .float(right)):
            return .float(Float(left) * right)
        case let (.float(left), .integer(right)):
            return .float(left * Float(right))
        }
    }
    
    static func / (left: OCNumber, right: OCNumber) -> OCNumber {
        switch (left, right) {
        case let (.integer(left), .integer(right)):
            return .integer(left / right)
        case let (.float(left), .float(right)):
            return .float(left / right)
        case let (.integer(left), .float(right)):
            return .float(Float(left) / right)
        case let (.float(left), .integer(right)):
            return .float(left / Float(right))
        }
    }
}

public class OCLexer {
    private let text: String
    private var currentIndex: Int
    private var currentCharacter: Character?
    
    public init(_ input: String) {
        if input.count == 0 {
            fatalError("Error! input can't be empty")
        }
        self.text = input
        currentIndex = 0
        currentCharacter = text[text.startIndex]
    }
    
    // 流程函数
    func nextTK() -> OCToken {
        if currentIndex > self.text.count - 1 {
            return .eof
        }
        
        if CharacterSet.whitespacesAndNewlines.contains((currentCharacter?.unicodeScalars.first!)!) {
            skipWhiteSpaceAndNewlines()
            return .whiteSpaceAndNewLine
        }
        
        if CharacterSet.decimalDigits.contains((currentCharacter?.unicodeScalars.first!)!) {
            return number()
        }
        
        if currentCharacter == "+" {
            advance()
            return .operation(.plus)
        }
        
        if currentCharacter == "-" {
            advance()
            return .operation(.minus)
        }
        
        if currentCharacter == "*" {
            advance()
            return .operation(.mult)
        }
        
        if currentCharacter == "/" {
            advance()
            return .operation(.intDiv)
        }
        
        if currentCharacter == "(" {
            advance()
            return .paren(.left)
        }
        
        if currentCharacter == ")" {
            advance()
            return .paren(.right)
        }
        advance()
        return .eof
    }
    
    // 数字处理
    private func number() -> OCToken {
        var numStr = ""
        while let character = currentCharacter, CharacterSet.decimalDigits.contains(character.unicodeScalars.first!) {
            numStr += String(character)
            advance()
        }
        
        if let charater = currentCharacter, charater == "." {
            numStr += "."
            advance()
            while let character = currentCharacter, CharacterSet.decimalDigits.contains(character.unicodeScalars.first!) {
                numStr += String(character)
                advance()
            }
            return .constant(.float(Float(numStr)!))
        }
        return .constant(.integer(Int(numStr)!))
    }
    
    private func advance() {
        currentIndex += 1
        guard currentIndex < text.count else {
            currentCharacter = nil
            return
        }
        currentCharacter = text[text.index(text.startIndex, offsetBy: currentIndex)]
    }
    
    // 在currentIndex的值不变的情况下，获取第一个字符
    private func peek() -> Character? {
        let peekIndex = currentIndex + 1
        guard peekIndex < text.count else {
            return nil
        }
        return text[text.index(text.startIndex, offsetBy: peekIndex)]
    }
    
    private func skipWhiteSpaceAndNewlines () {
        while let character = currentCharacter, CharacterSet.whitespacesAndNewlines.contains(character.unicodeScalars.first!) {
            advance()
        }
    }
}

public class OCInterpreter {
    
    private var lexer: OCLexer
    private var currentTK: OCToken
    
    public init(_ input: String) {
        lexer = OCLexer(input)
        currentTK = lexer.nextTK()
    }
    
    public func expr() -> OCAST {
        print("expr \(currentTK)")
        var node = term()
        
        while [.operation(.plus), .operation(.minus)].contains(currentTK) {
            let tk = currentTK
            eat(currentTK)
            if tk == .operation(.plus) {
                node = OCBindOp(left: node, operation: .plus, right: factor())
            } else if tk ==  .operation(.minus) {
                node = OCBindOp(left: node, operation: .minus, right: factor())
            }
        }
        return node
    }
    
    // 语法解析中对数字的处理
    private func term() -> OCAST {
        print("term \(currentTK)")
        var node = factor()
        
        while [.operation(.mult), .operation(.intDiv)].contains(currentTK) {
            let tk = currentTK
            eat(currentTK)
            if tk == .operation(.mult) {
                node = OCBindOp(left: node, operation: .mult, right: factor())
            } else if tk == .operation(.intDiv) {
                node = OCBindOp(left: node, operation: .intDiv, right: factor())
            }
        }
        return node
    }
        
    private func factor() -> OCAST {
        print("factor \(currentTK)")
        let tk = currentTK
        switch tk {
        case let .constant(.integer(result)):
            eat(.constant(.integer(result)))
            return OCNumber.integer(result)
        case let .constant(.float(result)):
            eat(.constant(.float(result)))
            return OCNumber.float(result)
        case .paren(.left):
            eat(.paren(.left))
            let result = expr()
            eat(.paren(.right))
            return result
        default:
            return OCNumber.integer(0)
        }
    }
    
    private func eat(_ token: OCToken) {
        if currentTK == token {
            currentTK = lexer.nextTK()
            if currentTK == OCToken.whiteSpaceAndNewLine {
                currentTK = lexer.nextTK()
            }else if currentTK == OCToken.eof {
                print("end")
            } else {
                error()
            }
        }
        
        func error() {
            fatalError("Error!")
        }
    }
    
    // eval
    
    func eval(node: OCAST) -> OCValue {
        switch node {
        case let number as OCNumber:
            return eval(number: number)
        case let binOp as OCBindOp:
            return eval(binOp: binOp)
        default:
            return .none
        }
    }
    
    func eval(number: OCNumber) -> OCValue {
        return .number(number)
    }
    
    func eval(binOp: OCBindOp) -> OCValue {
        guard case let .number(leftResult) = eval(node: binOp.left), case let .number(rightResult) = eval(node: binOp.right) else {
            fatalError("Error! binOp is wrong")
        }
        
        switch binOp.operation {
        case .plus:
            return .number(leftResult + rightResult)
        case .minus:
            return .number(leftResult - rightResult)
        case .mult:
            return .number(leftResult * rightResult)
        case .intDiv:
            return .number(leftResult / rightResult)
        }
    }
}

class OCBindOp: OCAST {
    let left: OCAST
    let operation: OCBinOpType
    let right: OCAST
    
    init(left: OCAST, operation: OCBinOpType, right: OCAST) {
        self.left = left
        self.operation = operation
        self.right = right
    }
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let interpreter = OCInterpreter.init("4 + ( 3.2 * 2 )")
        let ast = interpreter.expr()
        let result =  interpreter.eval(node: ast)
        
        print(result)
    }
}

