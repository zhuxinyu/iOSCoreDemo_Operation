//
//  ViewController.swift
//  iOSCoreDemo_Operation
//
//  Created by xyz on 2022/5/9.
//

import UIKit
import Foundation

public protocol OCAST {}

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

public enum OCToken: OCAST {
    case constant(OCConstant)
    case operation(OCBinOpType)
    case paren(OCDirection)
    case eof
    case whiteSpaceAndNewLine
    
    case brace(OCDirection)
    case asterisk
    case interface
    case implementation
    case end
    case id(String)
    case semi
    case assign
    
    case program
    case method
    case variable
    case property
    case comma
    case comments(String)
}

public enum OCNumber: OCAST {
    case integer(Int)
    case float(Float)
}

public enum OCUnaryOperationType {
    case plus
    case minus
}

public enum OCValue {
    case number(OCNumber)
    case none
}

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
        case let (.brace(left), .brace(right)):
            return left == right
        case (.asterisk, .asterisk):
            return true
        case (.end, .end):
            return true
        case (.implementation, .implementation):
            return true
        case let (.id(left), .id(right)):
            return left == right
        case (.semi, .semi):
            return true
        case (.assign, .assign):
            return true
//        case (.return, .return):
//            return true
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
    
    static prefix func + (left: OCNumber) -> OCNumber {
        switch left {
        case let .integer(value):
            return .integer(+value)
        case let .float(value):
            return .float(+value)
        }
    }
    
    static prefix func - (left: OCNumber) -> OCNumber {
        switch left {
        case let .integer(value):
            return .integer(-value)
        case let .float(value):
            return .float(-value)
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
        
        // identifier
        if CharacterSet.alphanumerics.contains((currentCharacter?.unicodeScalars.first!)!) {
            return id()
        }
        
        // comments
        if currentCharacter == "/" {
            //处理可能注释的情况
            if peek() == "/" {
                advance()
                advance()
                return commentsFromDoubleSlash()
            } else if peek() == "*" {
                advance()
                advance()
                return commentsFromSlashAsterisk()
            } else {
                advance()
                return .operation(.intDiv)
            }
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
        
        if currentCharacter == "@" {
            return at()
        }
        
        if currentCharacter == ";" {
            advance()
            return .semi
        }
        
        if currentCharacter == "=" {
            advance()
            return .assign
        }
        
        if currentCharacter == "{" {
            advance()
            return .brace(.left)
        }
        
        if currentCharacter == "}" {
            advance()
            return .brace(.right)
        }
        
        if currentCharacter == "*" {
            advance()
            return .asterisk
        }
        advance()
        return .eof
    }
    
    // idenfiter and keywords
    private func id() -> OCToken {
        var idStr = ""
        while let character = currentCharacter, CharacterSet.alphanumerics.contains(character.unicodeScalars.first!) {
            idStr += String(character)
            advance()
        }
        // keywords
//        if let token = keywords[idStr] {
//            return token
//        }
        
        return .id(idStr)
    }
    
    // @
    private func at() -> OCToken {
        advance()
        var atStr = ""
        while let character = currentCharacter, CharacterSet.alphanumerics.contains(character.unicodeScalars.first!) {
            atStr += String(character)
            advance()
        }
        if atStr == "interface" {
            return .interface
        }
        if atStr == "end" {
            return .end
        }
        if atStr == "implementation" {
            return .implementation
        }
        
        fatalError("Error: ast string not support")
    }
    
    // 数字处理
    private func number() -> OCToken {
        var numStr = ""
        if let character = currentCharacter, character == "-" {
            numStr += "-"
            advance()
        }
        
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
    
    // 跳过空格和换行
    private func skipWhiteSpaceAndNewlines () {
        while let character = currentCharacter, CharacterSet.whitespacesAndNewlines.contains(character.unicodeScalars.first!) {
            advance()
        }
    }
    
    // double slash
    private func commentsFromDoubleSlash() -> OCToken {
        var cStr = ""
        while let character = currentCharacter, !CharacterSet.newlines.contains(character.unicodeScalars.first!) {
            advance()
            cStr += String(character)
        }
        return .comments(cStr)
    }
    
    // slash aasterisk
    private func commentsFromSlashAsterisk() -> OCToken {
        var cStr = ""
        while let character = currentCharacter {
            if character == "*" && peek() == "/" {
                advance()
                advance()
                break
            } else {
                advance()
                cStr += String(character)
            }
        }
        return .comments(cStr)
    }
}

public class OCInterpreter {
    
    private var lexer: OCLexer
    private var currentTK: OCToken
    
    public lazy var ast: OCAST = {
       return expr()
    }()
    private var scopes: [String: OCValue]
    
    public init(_ input: String) {
        lexer = OCLexer(input)
        currentTK = lexer.nextTK()
        scopes = [String: OCValue]()
    }
    
    private func expr() -> OCAST {
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
        case .operation(.plus):
            eat(.operation(.plus))
            return OCUnaryOperation(operation: .plus, operand: factor())
        case .operation(.minus):
            eat(.operation(.minus))
            return OCUnaryOperation(operation: .minus, operand: factor())
        case .paren(.left):
            eat(.paren(.left))
            let result = expr()
            eat(.paren(.right))
            return result
        case .program:
            return program()
        case .interface:
            return interface()
        case .implementation:
            return implementation()
        case .method:
            return method()
        case .variable:
            return variable()
        case .assign:
            return assignStatement()
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
        case let unaryOperation as OCUnaryOperation:
            return eval(unaryOperation: unaryOperation)
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
    
    func eval(unaryOperation: OCUnaryOperation) -> OCValue {
        guard case let .number(result) = eval(node: unaryOperation.operand) else {
            fatalError("Error: eval unaryOperation")
        }
        
        switch unaryOperation.operation {
        case .plus:
            return .number(+result)
        case .minus:
            return .number(-result)
        }
    }

    func eval(assign: OCAssign) -> OCValue {
        scopes[assign.left.name] = eval(node: assign.right)
        return .none
    }
    
    func eval(variable: OCVar) -> OCValue {
        guard let value = scopes[variable.name] else {
            fatalError("Error: eval var")
        }
        return value
    }
    
    
    // parser
    
    private func program() -> OCProgram {
        return OCProgram(interface: interface(), implementation: implementation())
    }
    
    private func interface() -> OCInterface {
        eat(.interface)
        guard case let .id(name) = currentTK else {
            fatalError("Error interface")
        }
        eat(.id(name))
        let pl = propertyList()
        eat(.end)
        return OCInterface(name: name, propertyList: pl)
    }
    
    private func implementation() -> OCImplementation {
        eat(.implementation)
        guard case let .id(name) = currentTK else {
            fatalError("Error implementation")
        }
        eat(.id(name))
        let methodListNode =  methodList()
        eat(.end)
        return OCImplementation(name: name, methodList: methodListNode)
    }
    
    private func methodList() -> [OCMethod] {
        var methods = [OCMethod]()
        while currentTK == .operation(.plus) || currentTK == .operation(.minus) {
            eat(currentTK)
            methods.append(method())
        }
        return methods
    }
    
    private func method() -> OCMethod {
        eat(.paren(.left))
        guard case let .id(reStr) = currentTK else {
            fatalError("Error reStr")
        }
        eat(.id(reStr))
        eat(.paren(.right))
        guard case let .id(methodName) = currentTK else {
            fatalError("Error methodName")
        }
        eat(.id(methodName))
        eat(.brace(.left))
        let statementsNode = statements()
        eat(.brace(.right))
        return OCMethod(returnIdentifier: reStr, methodName: methodName, statements: statementsNode)
     }
    
    private func statements() -> [OCAST] {
        let sNode = statement()
        var statements = [sNode]
        while currentTK == .semi {
            eat(.semi)
            statements.append(statement())
        }
        return statements
    }
    
    private func statement() -> OCAST {
        switch currentTK {
        case .id:
            return assignStatement()
        default:
            return empty()
        }
    }
    
    private func assignStatement() -> OCAssign {
        let left = variable()
        eat(.assign)
        let right = expr()
        return OCAssign(left: left, right: right)
    }
    
    private func variable() -> OCVar {
        guard case let .id(name) = currentTK else {
            fatalError("Error: var was wrong")
        }
        eat(.id(name))
        return OCVar(name: name)
    }
    
    private func empty() -> OCToken {
        return .eof
    }
    
    // interface function
    private func propertyList() -> [OCPropertyDeclaration] {
        var properties = [OCPropertyDeclaration]()
        while currentTK == .property {
            eat(.property)
            eat(.paren(.left))
            let pa = propertyAttributes()
            eat(.paren(.right))
            guard case let .id(pType) = currentTK else {
                fatalError("Error: property type wrong")
            }
            eat(.id(pType))
            guard case let .id(name) = currentTK else {
                fatalError("Error: property name wrong")
            }
            eat(.id(name))
            let pd = OCPropertyDeclaration(propertyAttributesList: pa, type: pType, name: name)
            properties.append(pd)
            eat(.semi)
        }
        return properties
    }
    
    private func propertyAttributes() -> [OCPropertyAttribute] {
        let p = propertyAttribute()
        var pa = [p]
        while currentTK == .comma {
            eat(.comma)
            pa.append(propertyAttribute())
        }
        return pa
    }
    
    private func propertyAttribute() -> OCPropertyAttribute {
        guard case let .id(name) = currentTK else {
            fatalError("Error: propertyAttribute wrong")
        }
        eat(.id(name))
        return OCPropertyAttribute(name: name)
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

class OCUnaryOperation: OCAST {
    let operation: OCUnaryOperationType
    let operand: OCAST
    
    init(operation: OCUnaryOperationType, operand: OCAST) {
        self.operation = operation
        self.operand = operand
    }
}

class OCProgram: OCAST {
    let interface: OCInterface
    let implementation: OCImplementation
    init(interface: OCInterface, implementation: OCImplementation) {
        self.interface = interface
        self.implementation = implementation
    }
}

class OCInterface: OCAST {
    let name: String
    let propertyList: [OCPropertyDeclaration]
    init(name: String, propertyList: [OCPropertyDeclaration]) {
        self.name = name
        self.propertyList = propertyList
    }
}

class OCPropertyDeclaration: OCAST {
    let propertyAttributesList: [OCPropertyAttribute]
    let type: String
    let name: String
    init(propertyAttributesList: [OCPropertyAttribute], type: String, name: String) {
        self.propertyAttributesList = propertyAttributesList
        self.type = type
        self.name = name
    }
}

class OCPropertyAttribute: OCAST {
    let name: String
    init(name: String) {
        self.name = name
    }
}

class OCImplementation: OCAST {
    let name: String
    let methodList: [OCMethod]
    init(name: String, methodList: [OCMethod]) {
        self.name = name
        self.methodList = methodList
    }
}

class OCMethod: OCAST {
    let returnIdentifier: String
    let methodName: String
    let statements: [OCAST]
    init(returnIdentifier: String, methodName: String, statements: [OCAST]) {
        self.returnIdentifier = returnIdentifier
        self.methodName = methodName
        self.statements = statements
    }
}

class OCAssign: OCAST {
    let left: OCVar
    let right: OCAST
    
    init(left: OCVar, right:OCAST) {
        self.left = left
        self.right = right
    }
}

class OCVar: OCAST {
    let name: String
    init(name: String) {
        self.name = name
    }
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let interpreter = OCInterpreter.init("4 + ( - ( 3.2 * 2 ) )")
        let ast = interpreter.ast
        let result =  interpreter.eval(node: ast)
        
        print(result)
    }
}

