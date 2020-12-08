//: [Previous](@previous)

//: [Day 7](https://adventofcode.com/2020/day/7)

import Foundation

struct Bag: Hashable {
    let color: String
    let children: [Bag: Int]
    
    init(color: String) {
        self.color = color
        self.children = [:]
    }
    
    init?(rule: String) {
        let components = rule.components(separatedBy: " bags contain ")
        guard components.count == 2 else { return nil }
        
        self.color = components[0]
        let childrenRules = components[1]
        
        do {
            var children: [Bag: Int] = [:]
            let ruleRegex = try NSRegularExpression(pattern: #"(\d+) ([\w ]+) bags?,?"#, options: [])
            let range = NSRange(childrenRules.startIndex..<childrenRules.endIndex, in: childrenRules)
            ruleRegex.enumerateMatches(in: childrenRules, options: [], range: range) { (match, _, _) in
                guard let match = match,
                      match.numberOfRanges == 3,
                      let countRange = Range(match.range(at: 1), in: childrenRules),
                      let bagRange = Range(match.range(at: 2), in: childrenRules),
                      let count = Int(childrenRules[countRange]) else {
                    return
                }
                
                let bag = Bag(color: String(childrenRules[bagRange]))
                children[bag] = count
            }

            self.children = children
        } catch {
            return nil
        }
    }
}

guard let bagRulesFile = Bundle.main.url(forResource: "bagRules", withExtension: "txt") else  {
    exit(0)
}

let bags = try parseFile(at: bagRulesFile) { rule -> Bag? in
    Bag(rule: rule)
}

//: Problem 1

func bags(_ allBags: [Bag], canContain bagColor: String, containers: inout Set<String>) {
    let directly = allBags.filter {
        return $0.children.keys.map { $0.color }.contains(bagColor)
    }.map {
        $0.color
    }.filter {
        !containers.contains($0)
    }
    
    directly.forEach { containers.insert($0) }
    
    guard !directly.isEmpty else {
        return
    }
    
    directly.forEach {
        bags(allBags, canContain: $0, containers: &containers)
    }
}

var containers: Set<String> = Set()
bags(bags, canContain: "shiny gold", containers: &containers)
print("Bags that can contain 1 gold bag: \(containers.count)")

//: Problem 2

func children(of bagColor: String, multiplier: Int = 1, from allBags: [Bag], indent: Int = 0) -> [(String, Int)] {
    guard let bag = allBags.first(where: { $0.color == bagColor }) else {
        return []
    }
    
    let childInfo = bag.children.reduce(into: [:]) {
        $0[$1.key.color] = $1.value * multiplier
    }
    
    let containedChildren = childInfo.map { color, count -> [(String, Int)] in
        return children(of: color, multiplier: count, from: allBags, indent: indent + 1)
    }
    
    return childInfo.map { ($0, $1) } + containedChildren.flatMap {$0}
}

let luggageSet = children(of: "shiny gold", from: bags)
let luggageSetCount = luggageSet.map { $0.1 }
print("Contained bags for 1 gold bag: \(luggageSetCount.reduce(0, +))")

//: [Next](@next)
