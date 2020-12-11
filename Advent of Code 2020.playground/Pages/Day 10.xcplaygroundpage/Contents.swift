//: [Previous](@previous)

//: [Day 10](https://adventofcode.com/2020/day/10)

import Foundation

struct Adapter: Comparable {
    static var inputSlop: Int = 3
    let jolts: Int
    
    var inputRange: ClosedRange<Int> {
        (jolts - Adapter.inputSlop)...jolts
    }
    static func < (lhs: Adapter, rhs: Adapter) -> Bool {
        lhs.jolts < rhs.jolts
    }

}

guard let adapterFile = Bundle.main.url(forResource: "powerAdapters", withExtension: "txt") else {
    exit(0)
}

let adapters = parseFile(at: adapterFile) { input -> Adapter? in
    guard let jolts = Int(input) else { return nil }
    return Adapter(jolts: jolts)
}

enum PowerError: Error {
    case noAvailableAdapter(Adapter, Adapter)
}

//: Problem 1

extension Array where Element == Adapter {
    func joltageDifferences() throws -> [Int: Int] {
        guard let deviceAdapter = self.max().map( {Adapter(jolts: $0.jolts + 3)} ) else {
            return [:]
        }
        let sortedAdapters = sorted() + [deviceAdapter]

        var lastAdapter = Adapter(jolts: 0)
        
        let distributions: [Int: Int] = try sortedAdapters.reduce(into: [:]) { distributions, eachAdapter in
            guard eachAdapter.inputRange.contains(lastAdapter.jolts) else {
                throw PowerError.noAvailableAdapter(eachAdapter, lastAdapter)
            }
            
            let difference = eachAdapter.jolts - lastAdapter.jolts
            distributions[difference, default: 0] += 1
            
            lastAdapter = eachAdapter
        }
        
        return distributions
    }
}

let distributions = try adapters.joltageDifferences()
print("1 jolt difference * 3 jolt differences: \(distributions[1, default: 0] * distributions[3, default: 0])")

//: Problem 2

guard let deviceAdapter = adapters.max().map( {Adapter(jolts: $0.jolts + 3)} ) else { exit(0) }

    
extension Array where Element == Adapter {
    func subdivide() -> [[Adapter]] {
        guard !isEmpty else { return [] }

        var lastAdapter = self[0]

        let sorted = self.sorted()
        var currentGroup: [Adapter] = []
        var groups: [[Adapter]] = []

        sorted.forEach { adapter in
            if currentGroup.isEmpty || adapter.inputRange.lowerBound < lastAdapter.jolts {
                currentGroup.append(adapter)
            } else {
                groups.append(currentGroup)
                currentGroup = [adapter]
            }
            lastAdapter = adapter
        }
        groups.append(currentGroup)

        return groups
    }
    
    func validAdapterPaths() -> Int {
        guard !isEmpty else {
            return 0
        }
        
        if count == 1 { return 1 }

        let destinations: [Int: [Int]] = reduce(into: [:]) { result, each in
            result[each.jolts] = (1...Adapter.inputSlop).map { $0 + each.jolts }
        }
        
        let count = hasNextStep(from: self[0].jolts, destinations: destinations, endValue: self.last!.jolts)
        
        return count
    }
    
    private func hasNextStep(from voltage: Int, destinations: [Int: [Int]], endValue: Int) -> Int {
        guard let possibleDestinations = destinations[voltage] else {
            return 0
        }
        
        let paths: Int = possibleDestinations.reduce(0) {
            guard destinations[$1] != nil else {
                return $0
            }
            
            if $1 == endValue {
                return $0 + 1
            }
            
            return $0 + hasNextStep(from: $1, destinations: destinations, endValue: endValue)
        }
        
        return paths
    }
}

let groups = (adapters + [Adapter(jolts: 0), deviceAdapter]).subdivide()

let subgroupPaths = groups.map {
    $0.validAdapterPaths()
}

print ("Total Possible Paths: \(subgroupPaths.reduce(1, *))")

//: [Next](@next)
