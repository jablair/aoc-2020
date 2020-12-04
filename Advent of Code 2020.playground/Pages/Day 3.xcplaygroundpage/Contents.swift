//: [Previous](@previous)

//: [Day 3](https://adventofcode.com/2020/day/3)
import Foundation

struct TreePositions {
    let treeIndexes: Set<Int>
    let count: Int
    
    init?(_ pattern: String) {
        if pattern.isEmpty {
            return nil
        }
        self.count = pattern.count
        
        self.treeIndexes =  pattern.enumerated().reduce(into: Set<Int>()) { indexes, each in
            if each.1 == Character("#") {
                indexes.insert(each.0)
            }
        }
    }
    
    func isTree(at position: Int) -> Bool {
        let positionIndex = position % count
        return treeIndexes.contains(positionIndex)
    }
}

/// Traverses a hill, calculating the numbers of trees hit on the way down
/// - Parameters:
///   - treePositions: Array of tree position desicriptions for each row of the fill
///   - right: The column shift for each step
///   - down: The row shift for each step
/// - Returns: The number of tree colisions on the way down
func traverseHill(treePositions: [TreePositions], right: Int, down: Int) -> Int {
    treePositions.enumerated().reduce(0) { (input, eachItem) -> Int in
        let (row, treePositions) = eachItem
        guard row % down == 0 else {
            return input
        }
        let position = right * (row / down)
        
        return input + (treePositions.isTree(at: position) ? 1 : 0)
    }
}

guard let treeFile = Bundle.main.url(forResource: "trees", withExtension: "txt") else {
    exit(0)
}
let treePositions: [TreePositions] = try parseFile(at: treeFile, transform: TreePositions.init)

//: Problem 1
let treeCount = traverseHill(treePositions: treePositions, right: 3, down: 1)

print("Problem 1 Tree count: \(treeCount)")

//: Problem 2

let sampleInput = Bundle.main.url(forResource: "SampleTrees", withExtension: "txt")!
let sampleTreePositions = try! parseFile(at: sampleInput, transform: TreePositions.init)

let route1Count = traverseHill(treePositions: treePositions, right: 1, down: 1)
let route2Count = traverseHill(treePositions: treePositions, right: 3, down: 1)
let route3Count = traverseHill(treePositions: treePositions, right: 5, down: 1)
let route4Count = traverseHill(treePositions: treePositions, right: 7, down: 1)
let route5Count = traverseHill(treePositions: treePositions, right: 1, down: 2)

print("Problem 2 Tree product: \(route1Count * route2Count * route3Count * route4Count * route5Count)")

//: [Next](@next)
