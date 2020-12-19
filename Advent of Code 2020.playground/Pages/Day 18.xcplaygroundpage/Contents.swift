//: [Previous](@previous)

//: [Day 18](https://adventofcode.com/2020/day/18)

import Foundation

guard let mathHomeworkFile = Bundle.main.url(forResource: "mathHomework", withExtension: "txt") else {
    exit(0)
}

let mathHomework = try parseFile(at: mathHomeworkFile) { $0 }

enum MathError: Error {
    case invalidFunction
}

enum Token: Equatable {
    case number(Int)
    case op(Character)
    case parenOpen
    case parenClose
    
    init?(_ char: Character) {
        switch char {
        case "0"..."9":
            guard let int = char.wholeNumberValue else { return nil }
            self = .number(int)
        case "+", "*":
            self = .op(char)
        case "(":
            self = .parenOpen
        case ")":
            self = .parenClose
        default:
            return nil
        }
    }
}

protocol Precedence {
    static func precedence(for token: Token) -> Int
}

protocol Node: CustomStringConvertible {
    func execute() throws -> Int
}

struct NumberNode: Node {
    let value: Int
    var description: String {
        "NumberNode - \(value)"
    }
    
    func execute() -> Int {
        value
    }
}

struct OperationNode: Node {
    let operation: Character
    let lhs: Node
    let rhs: Node
    
    var description: String {
        "OperationNode - \(operation), lhs \(lhs), rhs \(rhs)"
    }
    
    func execute() throws -> Int {
        let left = try lhs.execute()
        let right = try rhs.execute()

        if operation == "+" {
            return left + right
        } else if operation == "*" {
            return left * right
        } else {
            throw SolverError.invalidFunction
        }
        
    }
}

enum SolverError: Swift.Error {
    case invalidFunction
    case expectedNumber
    case expectedCharacter(Character)
    case expectedOperator
}

class Solver<P: Precedence> {

    let tokens: [Token]
    private var index: Int = 0
    
    private var tokensAvailable: Bool {
        index < tokens.endIndex
    }
    
    init(function: String) {
        tokens = function.compactMap(Token.init)
    }

    private func peekCurrentToken() -> Token {
        tokens[index]
    }
    
    private func popCurrentToken() -> Token {
        defer { index += 1}
        return tokens[index]
    }
    
    private func parseNumber() throws -> Node {
        guard case let .number(value) = popCurrentToken() else {
            throw SolverError.expectedNumber
        }
        
        return NumberNode(value: value)
    }
    
    func solve() throws -> Int {
        let node = try parse()
        
        guard let operationNode = node as? OperationNode else {
            guard let numberNode = node as? NumberNode else {
                throw SolverError.invalidFunction
            }
            return numberNode.value
        }
        
        return try operationNode.execute()
    }
    
    func parse() throws -> Node {
        let node = try parsePrimary()
        
        return try parseOperation(node: node)
    }
    
    private func parseParenthesis() throws -> Node {
        guard case .parenOpen = popCurrentToken() else {
            throw SolverError.expectedCharacter("(")
        }
        
        let expression = try parse()
        
        guard case .parenClose = popCurrentToken() else {
            throw SolverError.expectedCharacter(")")
        }
        
        return expression
    }
    
    private func currentTokenPrecedence() throws -> Int {
        guard tokensAvailable else {
            return -1
        }
        
        return P.precedence(for: peekCurrentToken())
    }
    
    private func parseOperation(node: Node, expressionPrecedence: Int = 0) throws -> Node {
        var lhs = node
        
        while true {
            let tokenPrecedence = try currentTokenPrecedence()
            if tokenPrecedence < expressionPrecedence {
                return lhs
            }
            
            guard case let .op(op) = popCurrentToken() else {
                throw SolverError.expectedOperator
            }
            
            var rhs = try parsePrimary()
            let nextPrecedence = try currentTokenPrecedence()
            
            if tokenPrecedence < nextPrecedence {
                rhs = try parseOperation(node: rhs, expressionPrecedence: tokenPrecedence + 1)
            }
            
            lhs = OperationNode(operation: op, lhs: lhs, rhs: rhs)
        }
    }
    
    private func parsePrimary() throws -> Node {
        switch peekCurrentToken() {
        case .number:
            return try parseNumber()
        case .parenOpen:
            return try parseParenthesis()
        default:
            throw SolverError.invalidFunction
        }
    }
}

//: Problem 1
struct LTRPrecedence: Precedence {
    static func precedence(for token: Token) -> Int {
        guard case .op = token else {
            return -1
        }
        
        return 10
    }
}


let ltrSolutions = try mathHomework.map { function -> Int in
    let solver = Solver<LTRPrecedence>(function: function)
    return try solver.solve()
}

let ltrSum = ltrSolutions.reduce(0, +)
print("Problem 1: \(ltrSum)")

//: Problem 2
struct PAMPrecedence: Precedence {
    static func precedence(for token: Token) -> Int {
        guard case let .op(op) = token else {
            return -1
        }
        
        if op == "+" {
            return 20
        } else if op == "*" {
            return 10
        } else {
            return -1
        }
    }
}

let pamSolutions = try mathHomework.map { function -> Int in
    let solver = Solver<PAMPrecedence>(function: function)
    return try solver.solve()
}

let pamSum = pamSolutions.reduce(0, +)
print("Problem 2: \(pamSum)")

//: [Next](@next)
