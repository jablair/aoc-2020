//: [Previous](@previous)

//: [Day 9](https://adventofcode.com/2020/day/9)

import Foundation

var str = "Hello, playground"

guard let inSeatEntertainmentInput = Bundle.main.url(forResource: "xmas", withExtension: "txt") else {
    exit(0)
}

enum XMASError: Error {
    case insufficientPreamble
    case invalidInputNotFound
}

//let numbers = sample.components(separatedBy: "\n").compactMap(Int.init)
let numbers = try parseFile(at: inSeatEntertainmentInput, transform: Int.init)

//: Problem 1
func firstInvalidXMASInput(in numbers: [Int], preambleLength: Int = 25) throws -> Int? {
    guard numbers.count >= preambleLength else {
        throw XMASError.insufficientPreamble
    }

    let testableValues = numbers[preambleLength..<numbers.endIndex]

    testValueLoop: for testIdx in testableValues.startIndex..<testableValues.endIndex {
        let testValue = testableValues[testIdx]
        let lookbackCandidates = numbers[(testIdx - preambleLength)..<testIdx].filter {
            $0 <= testValue // assumes all input is positive...
        }.sorted()
        
        // Since premable is sorted, preambleCandidate.startIndex always equals 0
        for idx1 in 0..<(lookbackCandidates.endIndex - 1) {
            for idx2 in (idx1 + 1)..<lookbackCandidates.endIndex {
                if lookbackCandidates[idx1] + lookbackCandidates[idx2] == testValue {
                    continue testValueLoop
                }
            }
        }
        
        return testValue
    }
    
    return nil
}

guard let firstInvalid = try firstInvalidXMASInput(in: numbers) else {
    print("No invalid inputs")
    exit(0)
}

print("First invalid input: \(firstInvalid)")

//: Problem 2

func encryptionWeakness(in numbers: [Int], for invalid: Int) throws -> Int? {
    guard let _ = numbers.firstIndex(of: invalid) else {
        throw XMASError.invalidInputNotFound
    }
    
    runStart: for testStartIndex in numbers.startIndex..<numbers.endIndex {
        var contiguousSum = numbers[testStartIndex]
        
        for testEndIndex in numbers.index(after: testStartIndex)..<numbers.endIndex {
            let contiguousInput = numbers[testStartIndex...testEndIndex]
            contiguousSum += numbers[testEndIndex]
            if contiguousSum == invalid, let min = contiguousInput.min(), let max = contiguousInput.max() {
                return min + max
            } else if contiguousSum > invalid {
                continue runStart
            }
        }
    }
    
    return nil
}

guard let weakness = try encryptionWeakness(in: numbers, for: firstInvalid) else {
    print("No weakness found")
    exit(0)
}

print("Encyption weakness: \(weakness)")

//: [Next](@next)
