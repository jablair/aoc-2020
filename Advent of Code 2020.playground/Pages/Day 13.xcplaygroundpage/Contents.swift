//: [Previous](@previous)

//: [Day 13](https://adventofcode.com/2020/day/13)

import Foundation

guard let scheduleFile = Bundle.main.url(forResource: "busSchedule", withExtension: "txt") else {
    exit(0)
}

let input = try parseFile(at: scheduleFile) { $0 }

guard input.count == 2,
      let earliestTime = Int(input[0]) else {
    exit(0)
}

//: Problem 1

let inServiceSchedule = input[1].components(separatedBy: ",").compactMap(Int.init)

typealias WaitInfo = (id: Int, delay: Int)
let waitPerSchedule: [WaitInfo] = inServiceSchedule.map {
    ($0, $0 - (earliestTime % $0))
}

let shortestWait: WaitInfo = waitPerSchedule.reduce((0, .max)) { shortestWaitInfo, eachWaitInfo -> WaitInfo in
    eachWaitInfo.delay < shortestWaitInfo.delay ? eachWaitInfo : shortestWaitInfo
}

print("Shortest wait * delay: \(shortestWait.id * shortestWait.delay)")

//: Problem 2

typealias OffsetInfo = (offset: Int, runtime: Int)
let scheduleWithOffset: [OffsetInfo] = input[1].components(separatedBy: ",").enumerated().compactMap { idx, runtime in
    Int(runtime).map { (idx, $0) }
}

func matchPoint(for busses: ArraySlice<OffsetInfo>, startPoint: Int = 0, jumpingBy: Int) -> Int {
    for t in stride(from: startPoint, to: .max, by: jumpingBy) {
        guard busses.allSatisfy( { info in (t + info.offset) % info.runtime == 0}) else {
            continue
        }
        
        return t
    }
    
    return 0
}

func lcm(for values: ArraySlice<OffsetInfo>) -> Int {
    guard values.count > 1 else {
        return values.first?.runtime ?? 0
    }
    
    func gcd(_ m: Int, _ n: Int) -> Int {
        var a = 0
        var b = max(m, n)
        var r = min(m, n)
        
        while r != 0 {
            a = b
            b = r
            r = a % b
        }
        
        return b
    }
    
    func lcm(_ m: Int, _ n: Int) -> Int {
        (m * n) / gcd(m, n)
    }
    
    var val1 = values[values.startIndex].runtime
    for idx in (values.startIndex + 1)..<values.endIndex {
        val1 = lcm(val1, values[idx].runtime)
    }
    
    return val1
}

var match = scheduleWithOffset[0].runtime
var jumpBy = match

for idx in 1..<scheduleWithOffset.endIndex {
    let busses = scheduleWithOffset[...idx]
    match = matchPoint(for: busses, startPoint: match, jumpingBy: jumpBy)
    jumpBy = lcm(for: busses)
    
    print("idx match: \(match)")
    print("idx jump: \(jumpBy)")
}

print("Sequential schedule at t: \(match)")

//: [Next](@next)
