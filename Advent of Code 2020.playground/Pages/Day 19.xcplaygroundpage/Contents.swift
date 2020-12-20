//: [Previous](@previous)

//: [Day 19](https://adventofcode.com/2020/day/19)

import Foundation

enum Node: CustomStringConvertible {
    case character(Character)
    case expression([[Int]])
    
    var description: String {
        switch self {
        case .character(let character):
            return "Character: \(character)"
        case .expression(let children):
            let childDesc = children.map { subrule -> String in
                subrule.map { String($0) }.joined(separator: " ")
            }.joined(separator: " | ")
            return "Expression: \(childDesc)"
        }
    }
}

enum Error: Swift.Error {
    case noRuleID
    case noRuleDefinitions
    case noRuleForID(Int)
}

class RuleParser {
    private enum Token: Equatable {
        case char(Character)
        case rule(Int)
        case pipe
    }
    
    private(set) var rules: [Int: Node] = [:]
    
    init(_ rules: String, replacementRules: [Int: Node] = [:]) throws {
        let characterRegex = try NSRegularExpression(pattern: #""(\w)""#, options: [])
        for rule in rules.components(separatedBy: "\n") {
            let ruleComponents = rule.components(separatedBy: ":")

            guard let id = Int(ruleComponents[0]) else {
                throw Error.noRuleID
            }
            
            if let replacement = replacementRules[id] {
                self.rules[id] = replacement
                continue
            }
            
            let ruleSets = ruleComponents[1].components(separatedBy: "|")
            guard !ruleSets.isEmpty else {
                throw Error.noRuleDefinitions
            }
            
            let r0 = ruleSets[0]
            let ruleRange = NSRange(r0.startIndex..<r0.endIndex, in: r0)
            
            if ruleSets.count == 1,
               let match = characterRegex.firstMatch(in: r0, options: [], range: ruleRange),
               match.numberOfRanges == 2,
               let matchRange = Range(match.range(at: 1), in: r0) {
                self.rules[id] = .character(r0[matchRange.lowerBound])
            } else {
                let childRules = ruleSets.map {
                    $0.components(separatedBy: " ").compactMap(Int.init)
                }
                self.rules[id] = .expression(childRules)
            }
        }
    }
}

struct RuleMatcher {
    let rules: [Int: Node]
    
    func validate(message: String, for ruleID: Int) throws -> Bool {
        let results = try matches(for: message.map({$0}), with: ruleID)
        let match = results.firstIndex { $0.isEmpty }
        
        return match != nil
    }
    
    private func matches(for message: [Character], with ruleID: Int) throws -> [[Character]] {
        guard let rule = rules[ruleID] else {
            throw Error.noRuleForID(ruleID)
        }
        
        if case let .character(char) = rule {
            guard !message.isEmpty, message[message.startIndex] == char else {
                return []
            }
            
            return [Array(message.dropFirst())]
        } else if case let .expression(children) = rule {
            let matches = try children.flatMap { childRules -> [[Character]] in
                var candidates = [message]
                for childRuleID in childRules {
                    candidates = try candidates.flatMap { try self.matches(for: $0, with: childRuleID)}
                }
                
                return candidates
            }
            
            return matches
        }
            
        fatalError()
    }
}
guard let messagesFile = Bundle.main.url(forResource: "messages", withExtension: "txt") else {
    exit(0)
}

let messageContent = try parseFile(at: messagesFile, separator: "\n\n") { $0 }

let rules = messageContent[0]
let messages = messageContent[1]
    .trimmingCharacters(in: .newlines)
    .components(separatedBy: "\n")

//: Problem 1
let part1RuleParser = try RuleParser(rules)
let part1RuleMatcher = RuleMatcher(rules: part1RuleParser.rules)
let part1Matching = try messages.map { try part1RuleMatcher.validate(message: $0, for: 0) }
let part1MatchCount = part1Matching.reduce(0) { $0 + ($1 ? 1 : 0) }

print("Problem 1 - Items Matching Rule 0: \(part1MatchCount)")

//: Problem 2
func expandRecursiveNode(with id: Int, closedRules: [[Int]], recursive: [Int], iterations: Int) -> [[Int]] {
    guard let recursiveIndex = recursive.firstIndex(of: id) else {
        return []
    }
    
    let newClosed: [[Int]] = closedRules.reduce(into: closedRules) { (set, eachClosed) in
        var updated = recursive
        updated.replaceSubrange(recursiveIndex...recursiveIndex, with: eachClosed)
        set.append(updated)
    }
    var updatedRecursive = recursive
    
    updatedRecursive.replaceSubrange(recursiveIndex...recursiveIndex, with: recursive)
    
    if max(iterations, 0) > 0 {
        return expandRecursiveNode(with: id, closedRules: newClosed, recursive: updatedRecursive, iterations: iterations - 1)
    } else {
        return newClosed
    }
}

let rule8Children = expandRecursiveNode(with: 8, closedRules: [[42]], recursive: [42, 8], iterations: 2)
let rule11Children = expandRecursiveNode(with: 11, closedRules: [[42, 31]], recursive: [42, 11, 31], iterations: 2)
let replacementRules: [Int: Node] = [
    8: .expression(rule8Children),
    11: .expression(rule11Children)
]

let part2RuleParser = try RuleParser(rules, replacementRules: replacementRules)
let part2RuleMatcher = RuleMatcher(rules: part2RuleParser.rules)
let part2Matching = try messages.map { try part2RuleMatcher.validate(message: $0, for: 0) }
let part2MatchCount = part2Matching.reduce(0) { $0 + ($1 ? 1 : 0) }

print("Problem 2 - Items Matching Rule 0: \(part2MatchCount)")



//: [Next](@next)
