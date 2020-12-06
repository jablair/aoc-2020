//: [Previous](@previous)

//: [Day 6](https://adventofcode.com/2020/day/6)

import Foundation

guard let customsFile = Bundle.main.url(forResource: "customForms", withExtension: "txt") else  {
    exit(0)
}

//: Problem 1

let customGroups = try parseFile(at: customsFile, separator: "\n\n") { groupInput -> [Set<String.Element>] in
    let forms = groupInput.components(separatedBy: "\n").filter { !$0.isEmpty }
    
    return forms.map {
        Set($0.sorted())
    }
}

let yesAnswerCounts = customGroups.map { eachGroup -> Int in
    guard !eachGroup.isEmpty else {
        return 0
    }
    
    var groupAnswers = eachGroup[0]
    let yesAnswers = eachGroup.reduce(into: groupAnswers) { (result, answers) in
        result.formUnion(answers)
    }
    
    return yesAnswers.count
}

print("Sum of group yes answers: \(yesAnswerCounts.reduce(0, +))")

//: Problem 2

let allYesAnswerCounts = customGroups.map { eachGroup -> Int in
    guard !eachGroup.isEmpty else {
        return 0
    }
    
    var groupAnswers = eachGroup[0]
    let yesAnswers = eachGroup.reduce(into: groupAnswers) { (result, answers) in
        result.formIntersection(answers)
    }
    
    return yesAnswers.count
}

print("Sum of group all yes answers: \(allYesAnswerCounts.reduce(0, +))")


//: [Next](@next)
