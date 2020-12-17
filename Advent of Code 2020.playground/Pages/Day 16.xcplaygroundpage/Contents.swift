//: [Previous](@previous)

//: [Day 16](https://adventofcode.com/2020/day/16)

import Foundation

struct RuleProcessor {
    enum RuleError: Error {
        case unreducedRules
    }

    let rules: [String: Set<Int>]
    
    init(ruleDescriptions: [String]) throws {
        self.rules = try ruleDescriptions.reduce(into: [:]) { rules, eachRule in
            let components = eachRule.components(separatedBy: ": ")
            guard components.count == 2 else {
                return
            }
            
            
            let ruleName = String(eachRule.prefix { $0 != ":" })
            var values: Set<Int> = []
            
            let range = NSRange(eachRule.startIndex..<eachRule.endIndex, in: eachRule)
            let rangeRegexp = try NSRegularExpression(pattern: #"(\d+)-(\d+)"#, options: [])
            rangeRegexp.enumerateMatches(in: eachRule, options: [], range: range) { (match, _, _) in
                guard let match = match,
                      match.numberOfRanges == 3,
                      let startRange = Range(match.range(at: 1), in: eachRule),
                      let endRange = Range(match.range(at: 2), in: eachRule),
                      let start = Int(eachRule[startRange]),
                      let end = Int(eachRule[endRange]) else {
                    return
                }

                values.formUnion(Set(start...end))
            }
            
            rules[ruleName] = values
        }
    }
    
    func errorRate(for tickets: [[Int]]) -> Int {
        tickets.reduce(0) { error, ticket -> Int in
            let invalidTicketFields = ticket.filter { ticketField -> Bool in
                rules.values.allSatisfy { !$0.contains(ticketField) }
            }
            return invalidTicketFields.reduce(0, +) + error
        }
    }
    
    func reducedFields(from tickets: [[Int]]) throws -> [String: Int] {
        let fields = candidateFields(for: tickets)
        let (reduction, success) = reduce(fields: fields)
        guard success else {
            throw RuleError.unreducedRules
        }
        
        return Dictionary(uniqueKeysWithValues: reduction.map({ ($1.first!, $0) }))
    }
    
    private func validTickets(from allTickets: [[Int]]) -> [[Int]] {
        allTickets.filter { ticket -> Bool in
            ticket.allSatisfy { ticketField -> Bool in
                !rules.values.allSatisfy { !$0.contains(ticketField) }
            }
        }
    }

    private func candidateFields(for tickets: [[Int]]) -> [Int: Set<String>] {
        let validTickets = self.validTickets(from: tickets)
        guard !validTickets.isEmpty else {
            return [:]
        }
        
        let fieldCount = validTickets[0].count
        guard rules.count == fieldCount, validTickets.allSatisfy({ $0.count == fieldCount }) else {
            return [:]
        }
        
        return (0..<fieldCount).reduce(into: [:]) { (result, idx) in
            let field = validTickets.map { $0[idx] }
            
            let rulesForField = rules.filter { key, indices -> Bool in
                field.allSatisfy {indices.contains($0) }
            }.keys
            .map{ $0 }
            
            result[idx] = Set(rulesForField)
        }
    }
    
    private func reduce(fields: [Int: Set<String>]) -> ([Int: Set<String>], Bool) {
        let solvedFieldsCount = fields.values.filter { $0.count == 1}.count
        if solvedFieldsCount == 0 {
            return (fields, false)
        } else if solvedFieldsCount == fields.count {
            return (fields, true)
        }
        
        let solvedFieldIndices = Set(fields.keys).filter {
            fields[$0]?.count == 1
        }
        let solvedFields: Set<String> = solvedFieldIndices.reduce(into: []) { (result, idx) in
            result.formUnion(fields[idx]!)
        }
        
        let unsolvedFieldIndices = Set(fields.keys).symmetricDifference(solvedFieldIndices)
        var reducedFields = fields
        for index in unsolvedFieldIndices {
            reducedFields[index] = reducedFields[index]!.subtracting(solvedFields)
        }
        
        return reduce(fields: reducedFields)
    }
}

guard let ticketInfoURL = Bundle.main.url(forResource: "ticketInfo", withExtension: "txt") else {
    exit(0)
}

let segments = try parseFile(at: ticketInfoURL, separator: "\n\n") { $0 }

guard segments.count == 3 else {
    print("invalid segment info")
    exit(0)
}

let rules = segments[0].components(separatedBy: "\n")
let processor = try RuleProcessor(ruleDescriptions: rules)

//: Problem 1
let nearbyTickets = segments[2]
    .trimmingCharacters(in: .newlines)
    .components(separatedBy: "\n")
    .dropFirst()
    .map {
        $0.components(separatedBy: ",").compactMap(Int.init)
    }

print("Error Rate: \(processor.errorRate(for: nearbyTickets))")

//: Problem 2
let yourTicket = segments[1]
    .trimmingCharacters(in: .newlines)
    .components(separatedBy: "\n")
    .dropFirst()
    .map {
        $0.components(separatedBy: ",").compactMap(Int.init)
    }
    .first!

let reducedCandidates = try processor.reducedFields(from: nearbyTickets)

let departureFields: [Int] = reducedCandidates.keys.reduce(into: []) { result, key in
    guard key.hasPrefix("departure"), let index = reducedCandidates[key] else {
        return
    }
    result.append(index)
}

let product = departureFields.reduce(1) { result, index in
    result * yourTicket[index]
}

print("Destination product: \(product)")

//: [Next](@next)
