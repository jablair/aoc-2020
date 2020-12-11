//: [Previous](@previous)

//: [Day 8](https://adventofcode.com/2020/day/8)

import Foundation

enum Operation {
    case accumulate(Int)
    case jump(Int)
    case noOp(Int)
    
    var flipped: Operation {
        switch self {
        case .jump(let amount):
            return .noOp(amount)
        case .noOp(let amount):
            return .jump(amount)
        case .accumulate:
            return self
        }
    }
    
    init?(_ instruction: String) {
        let components = instruction.split(separator: " ")
        guard components.count == 2,
              let amount = Int(components[1]) else {
            return nil
        }
        
        switch components[0] {
        case "acc":
            self = .accumulate(amount)
        case "jmp":
            self = .jump(amount)
        case "nop":
            self = .noOp(amount)
        default:
            return nil
        }
    }
}

guard let bootCodeFile = Bundle.main.url(forResource: "bootCode", withExtension: "txt") else { exit(0) }

let instructions = try parseFile(at: bootCodeFile, transform: Operation.init)

//: Problem 1
typealias AccumulateResult = (value: Int, didComplete: Bool)
extension Array where Element == Operation {
    func accumulate() -> AccumulateResult {
        var idx = startIndex
        var visitedIDs = Set<Int>()
        var accumulator = 0
        
        while idx < endIndex, !visitedIDs.contains(idx) {
            visitedIDs.insert(idx)
            
            switch self[idx] {
            case .accumulate(let amount):
                accumulator += amount
                idx += 1
            case .jump(let amount):
                idx += amount
            case .noOp:
                idx += 1
            }
        }
        
        return (accumulator, idx == endIndex)
    }
}

let programResult = instructions.accumulate()
print("Terminating result: \(programResult.value)")

//: Problem 2

enum AccumulateError: Error {
    case noSolution
}
extension Array where Element == Operation {
    func fixAndAccumulate() throws -> Int {
        let firstPass = accumulate()
        if firstPass.didComplete {
            return firstPass.value
        }

        let fixPositionCandidates = enumerated().compactMap { (idx, instruction) -> Int? in
            switch instruction {
            case .jump:
                return idx
            case .noOp(let count):
                return count != 0 ? idx : nil // jmp 0 is infinite loop
            case .accumulate:
                return nil
            }
        }

        for fixIdx in fixPositionCandidates {
            var fixed = self
            fixed[fixIdx] = fixed[fixIdx].flipped
            
            let result = fixed.accumulate()
            if result.didComplete {
                return result.value
            }
        }
        
        throw AccumulateError.noSolution
    }
}

let fixedProgramResult = try instructions.fixAndAccumulate()
print("Fixed result: \(fixedProgramResult)")

//: [Next](@next)
