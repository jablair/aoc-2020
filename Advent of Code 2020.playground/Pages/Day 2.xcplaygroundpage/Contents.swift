//: [Previous](@previous)

//: [Day 2](https://adventofcode.com/2020/day/2)

import Foundation

protocol PasswordValidating {
    init?(ruleString: String)
    func isValidPassword(_ password: String) -> Bool
}

func readPasswords<T: PasswordValidating>() throws -> [(rule: T, password: String)] {
    guard let passwordFile = Bundle.main.url(forResource: "passwords", withExtension: "txt") else {
        return []
    }
    
    return try parseFile(at: passwordFile) { eachEntry -> (T, String)? in
        let split = eachEntry.split(separator: ":")
        guard split.count == 2, let rule = T(ruleString: String(split[0])) else {
            return nil
        }
        
        
        return (rule, String(split[1]))
    }
}

//: Problem 1
struct PasswordRule: PasswordValidating {
    let letter: Character
    let ruleRange: ClosedRange<Int>
    
    init?(ruleString: String) {
        let components = ruleString.split { (char) -> Bool in
            return char == "-" || char == " "
        }
        
        guard
            components.count == 3,
            let lowerBound = Int(components[0]),
            let upperBound = Int(components[1]),
            lowerBound <= upperBound
            else {
            return nil
        }
        
        ruleRange = lowerBound...upperBound
        letter = Character(String(components[2]))
    }
    
    func isValidPassword(_ password: String) -> Bool {
        let charCount = password.filter { $0 == letter }.count
        
        return ruleRange.contains(charCount)
    }
}

let passwordEntries: [(rule: PasswordRule, password: String)] = try! readPasswords()
let problem1Result = passwordEntries.filter {
    $0.rule.isValidPassword($0.password)
}.count

print("Problem 1 valid password count: \(problem1Result)")

//: Problem 2
struct OTCASRule: PasswordValidating {
    let letter: Character
    let position1: Int
    let position2: Int
    
    init?(ruleString: String) {
        let components = ruleString.split { (char) -> Bool in
            return char == "-" || char == " "
        }
        
        guard
            components.count == 3,
            let position1 = Int(components[0]),
            let position2 = Int(components[1])
            else {
                return nil
        }
        
        self.position1 = position1
        self.position2 = position2
        self.letter = Character(String(components[2]))
    }
    
    func isValidPassword(_ password: String) -> Bool {
        let p1Index = password.index(password.startIndex, offsetBy: position1)
        let p2Index = password.index(password.startIndex, offsetBy: position2)
        let isAtP1 = p1Index < password.endIndex ? password[p1Index] == letter : false
        let isAtP2 = p2Index < password.endIndex ? password[p2Index] == letter : false

        return (isAtP1 || isAtP2) && isAtP1 != isAtP2
    }
}

let otcasPasswordEntries: [(rule: OTCASRule, password: String)] = try! readPasswords()

let problem2Result = otcasPasswordEntries.filter {
    $0.rule.isValidPassword($0.password)
}.count

print("Problem 2 valid password count: \(problem2Result)")


//: [Next](@next)
