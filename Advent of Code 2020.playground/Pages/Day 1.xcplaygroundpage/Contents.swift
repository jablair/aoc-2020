//: [Previous](@previous)

/*:[Day 1](https://adventofcode.com/2020/day/1)*/
import Cocoa

guard let expenseFile = Bundle.main.url(forResource: "expenses", withExtension: "txt") else {
    exit(0)
}

let entries: [Int] = parseFile(at: expenseFile, transform: Int.init)

/*: Problem 1 */
var v1 = 0
var v2 = 0
outer: for entry in entries.enumerated() {
    let (idx, value) = entry
    for idx2 in (idx + 1)..<entries.count {
        if value + entries[idx2] == 2020 {
            v1 = value
            v2 = entries[idx2]
            break outer
        }
    }
}

print(v1)
print(v2)
print("Problem 1 Product: \(v1*v2)")

//: Problem 2
var p2v1 = 0
var p2v2 = 0
var p2v3 = 0
outer: for entry1 in entries.enumerated() {
    let (idx, value) = entry1
    for entry2 in entries[(idx+1)..<entries.count].enumerated() {
        let (idx2, value2) = entry2
        
        for idx2 in (idx2 + 1)..<entries.count {
            if value + value2 + entries[idx2] == 2020 {
                p2v1 = value
                p2v2 = value2
                p2v3 = entries[idx2]
            }
        }
    }
}

print(p2v1)
print(p2v2)
print(p2v3)
print("Problem 2 Product: \(p2v1*p2v2*p2v3)")

//: [Next](@next)

