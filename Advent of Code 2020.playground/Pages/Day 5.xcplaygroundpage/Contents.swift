//: [Previous](@previous)

//: [Day 5](https://adventofcode.com/2020/day/5/)

import Foundation

enum Segment {
    case lower
    case upper
}

protocol RangeLimiting {
    var segment: Segment { get }
}

extension ClosedRange where Bound == Int {
    private func limitedRange(for segment: Segment) -> ClosedRange<Int> {
        let splitPoint = (lowerBound + upperBound) / 2
        switch segment {
        case .lower:
            return lowerBound...splitPoint
        case .upper:
            return (splitPoint+1)...upperBound
        }
    }
    
    func reduce(with instructions: [RangeLimiting]) throws -> Int {
        guard count == (pow(2, instructions.count) as NSDecimalNumber).intValue else {
            throw NSError(domain: "AOC", code: 0, userInfo: nil)
        }
        
        var reduced = self
        for segment in instructions.map(\.segment) {
            reduced = reduced.limitedRange(for: segment)
        }
        
        return reduced.lowerBound
    }
}

struct BoardingPass {
    enum RowInstruction: Character, RangeLimiting {
        case f = "F"
        case b = "B"
        
        var segment: Segment {
            switch self {
            case .f: return .lower
            case .b: return .upper
            }
        }
    }
    
    enum SeatInstruction: Character, RangeLimiting {
        case l = "L"
        case r = "R"
        
        var segment: Segment {
            switch self {
            case .l: return .lower
            case .r: return .upper
            }
        }
    }
    
    let passCode: String
    let rowCode: [BoardingPass.RowInstruction]
    let seatCode: [BoardingPass.SeatInstruction]
    let row: Int
    let seat: Int
    
    var seatID: Int {
        8 * row + seat
    }
    
    init?(_ passCode: String) {
        guard passCode.count == 10 else {
            return nil
        }
        self.passCode = passCode
        let splitIndex = passCode.index(passCode.startIndex, offsetBy: 7)
        self.rowCode = self.passCode[..<splitIndex].compactMap(RowInstruction.init)
        self.seatCode = self.passCode[splitIndex...].compactMap(SeatInstruction.init)
        
        do {
            self.row = try (0...127).reduce(with: self.rowCode)
            self.seat = try (0...7).reduce(with: self.seatCode)
        } catch {
            return nil
        }
    }
}

guard let passFile = Bundle.main.url(forResource: "boardingPasses", withExtension: "txt") else  {
    exit(0)
}

let boardingPasses = try parseFile(at: passFile, transform: BoardingPass.init)

//: Problem 1
guard let maxSeatID = boardingPasses.map(\.seatID).max() else {
    print("No seat IDs")
    exit(0)
}
print("Highest Seat ID: \(maxSeatID)")

//: Problem 2
let sortedSeatIDs = boardingPasses.map(\.seatID).sorted()

var comparisonSeatID = sortedSeatIDs[0]
for eachSeatID in sortedSeatIDs {
    if eachSeatID != comparisonSeatID {
        break
    }
    comparisonSeatID = eachSeatID + 1
}

guard comparisonSeatID != sortedSeatIDs.last else {
    print("Failed to find seat ID")
    exit(0)
}

print("Seat ID \(comparisonSeatID)")

//: [Next](@next)
