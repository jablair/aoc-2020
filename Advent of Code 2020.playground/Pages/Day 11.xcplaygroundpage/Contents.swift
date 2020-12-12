//: [Previous](@previous)

import Foundation

//: [Day 11]: (https://adventofcode.com/2020/day/11)

enum Position: Character {
    case empty = "L"
    case occupied = "#"
    case floor = "."
    
    var isFlippable: Bool {
        return self != .floor
    }
}

let sample = """
L.LL.LL.LL
LLLLLLL.LL
L.L.L..L..
LLLL.LL.LL
L.LL.LL.LL
L.LLLLL.LL
..L.L.....
LLLLLLLLLL
L.LLLLLL.L
L.LLLLL.LL
"""

typealias Floorplan = [[Position]]

//let rows: Floorplan = sample.components(separatedBy: "\n").compactMap { eachRow in
//    eachRow.compactMap(Position.init)
//}

guard let floorplanURL = Bundle.main.url(forResource: "floorplan", withExtension: "txt") else {
    exit(0)
}

let rows: Floorplan = parseFile(at: floorplanURL) { eachRow in
    eachRow.compactMap(Position.init)
}

enum FloorplanError: Error {
    case invalid
}

extension Floorplan {
    fileprivate typealias Location = (row: Int, column: Int)

    enum Scheme {
        case adjacent
        case visible
        
        var fillCount: Int {
            switch self {
            case .adjacent: return 4
            case .visible: return 5
            }
        }
        
        fileprivate typealias LocationCalculator = (Int, Int, Floorplan) -> [Floorplan.Location]
        
        fileprivate var locationCalculator: LocationCalculator {
            switch self {
            case .adjacent:
                return Scheme.adjacentLocation(self)
            case .visible:
                return Scheme.visibleSeats(self)
            }
        }
        
        private func adjacentLocation(for row: Int, column: Int, in floorplan: Floorplan) -> [Floorplan.Location] {
            let rowAbove = row - 1 >= floorplan.startIndex ? row - 1 : nil
            let rowBelow = row + 1 < floorplan.endIndex ? row + 1 : nil
            let columnLeft = column - 1 >= floorplan[row].startIndex ? column - 1 : nil
            let columnRight = column + 1 < floorplan[row].endIndex ? column + 1 : nil
            
            let locationsForRow: (Int) -> [Floorplan.Location] = { testRow -> [Floorplan.Location] in
                var rowLocations: [Floorplan.Location] = []
                if testRow != row {
                    rowLocations.append((testRow, column))
                }
                
                if let columnLeft = columnLeft {
                    rowLocations.append((testRow, columnLeft))
                }
                if let columnRight = columnRight {
                    rowLocations.append((testRow, columnRight))
                }
                
                return rowLocations
            }
            
            var locations: [Floorplan.Location] = locationsForRow(row)
            
            if let rowAbove = rowAbove {
                locations.append(contentsOf: locationsForRow(rowAbove))
            }
            
            if let rowBelow = rowBelow {
                locations.append(contentsOf: locationsForRow(rowBelow))
            }
            
            return locations
        }
        
        private func visibleSeats(for row: Int, column: Int, in floorplan: Floorplan) -> [Location] {
            var locations: [Location] = []
            
            var sameColumnFound: Bool = false
            var leftFound: Bool = false
            var rightFound: Bool = false
            
            // Find seats in the above rows
            for rowIdx in stride(from: row - 1, through: floorplan.startIndex, by: -1) {
                let diff = row - rowIdx
                let row = floorplan[rowIdx]
                
                // upper left target
                if !leftFound {
                    if column - diff >= row.startIndex, row[column - diff] != .floor {
                        locations.append((rowIdx, column - diff))
                        leftFound = true
                    }
                }
                
                // upper right target
                if !rightFound {
                    if column + diff < row.endIndex, row[column + diff] != .floor {
                        locations.append((rowIdx, column + diff))
                        rightFound = true
                    }
                }
                
                // above target
                if !sameColumnFound, row[column] != .floor {
                    sameColumnFound = true
                    locations.append((rowIdx, column))
                }
                
                if sameColumnFound, leftFound, rightFound {
                    break
                }
            }
            
            // Find seats in the current row
            for colIdx in stride(from: column - 1, through: floorplan[row].startIndex, by: -1) {
                if floorplan[row][colIdx] != .floor {
                    locations.append((row, colIdx))
                    break
                }
            }

            for colIdx in stride(from: column + 1, to: floorplan[row].endIndex, by: 1) {
                if floorplan[row][colIdx] != .floor {
                    locations.append((row, colIdx))
                    break
                }
            }

            // Find seats in the below rows
            sameColumnFound = false
            leftFound = false
            rightFound = false

            for rowIdx in stride(from: row + 1, to: floorplan.endIndex, by: 1) {
                let diff = rowIdx - row
                let row = floorplan[rowIdx]
                
                // upper left target
                if !leftFound {
                    if column - diff >= row.startIndex, row[column - diff] != .floor {
                        locations.append((rowIdx, column - diff))
                        leftFound = true
                    }
                }

                // lower right target
                if !rightFound {
                    if column + diff < row.endIndex, row[column + diff] != .floor {
                        locations.append((rowIdx, column + diff))
                        rightFound = true
                    }
                }

                // lower target
                if !sameColumnFound,  row[column] != .floor {
                    sameColumnFound = true
                    locations.append((rowIdx, column))
                }
                
                if sameColumnFound, leftFound, rightFound {
                    break
                }
            }
            
            return locations
        }

    }
    
    func iteratedFloorplan(scheme: Scheme) throws -> Floorplan {
        var iteratedFloorplan = self
        
        guard let rowWidth = rows.first?.count, rows.allSatisfy({$0.count == rowWidth}) else {
            throw FloorplanError.invalid
        }

        for rowIdx in startIndex..<endIndex {
            let row = self[rowIdx]
            for columnIdx in row.startIndex..<row.endIndex {
                let state = row[columnIdx]
                guard state.isFlippable else {
                    continue
                }
                
                let checkLocations: [Location] = scheme.locationCalculator(rowIdx, columnIdx, self)
                    
                let filledCount = checkLocations.reduce(0) { count, location -> Int in
                    count + (self[location.row][location.column] == .occupied ? 1 : 0)
                }
                
                if filledCount == 0 && state == .empty {
                    iteratedFloorplan[rowIdx][columnIdx] = .occupied
                } else if filledCount >= scheme.fillCount && state == .occupied {
                    iteratedFloorplan[rowIdx][columnIdx] = .empty
                }
            }
        }
        
        return iteratedFloorplan
    }
}

var iterationCount = 0
var lastIteration = rows
while (true) {
    let iteration = try lastIteration.iteratedFloorplan(scheme: .adjacent)

    guard iteration != lastIteration else {
        break
    }
    
    lastIteration = iteration
    iterationCount += 1
}

let occupiedCount = lastIteration.reduce(0) { count, row -> Int in
    count + row.filter { $0 == .occupied }.count
}


print("Filled seats with adjacent rules: \(occupiedCount)")

// Problem 2

iterationCount = 0
lastIteration = rows
while (true) {
    let iteration = try lastIteration.iteratedFloorplan(scheme: .visible)
    
    guard iteration != lastIteration else {
        break
    }
    
    lastIteration = iteration
    iterationCount += 1
}

let visibleOccupiedCount = lastIteration.reduce(0) { count, row -> Int in
    count + row.filter { $0 == .occupied }.count
}
print("Filled seat with visible rule: \(visibleOccupiedCount)")

//: [Next](@next)
