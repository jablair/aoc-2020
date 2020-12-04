//: [Previous](@previous)

//: [Day 4](https://adventofcode.com/2020/day/4)
import Foundation

private enum Field: String {
    case byr
    case iyr
    case eyr
    case hgt
    case hcl
    case ecl
    case pid
    case cid
}

guard let passportFile = Bundle.main.url(forResource: "passports", withExtension: "txt") else {
    exit(0)
}

//: Problem 1

struct FakePassport {
    let birthYear: String
    let issueYear: String
    let expirationYear: String
    let height: String
    let hairColor: String
    let eyeColor: String
    let passportID: String
    let countryID: String?
    
    init?(_ record: String) {
        let fields = record.split {
            $0 == Character("\n") || $0 == Character(" ")
        }

        let values: [Field: String] = fields.reduce(into: [:]) { (result, eachField) in
            let pair = eachField.components(separatedBy: ":")
            guard
                pair.count == 2,
                let field = Field(rawValue: pair[0]) else {
                    return
            }
            
            result[field] = pair[1]
        }
        
        guard
            let birthYear = values[.byr],
            let issueYear = values[.iyr],
            let expirationYear = values[.eyr],
            let height = values[.hgt],
            let hairColor = values[.hcl],
            let eyeColor = values[.ecl],
            let passportID = values[.pid] else {
            return nil
        }
        
        self.birthYear = birthYear
        self.issueYear = issueYear
        self.expirationYear = expirationYear
        self.height = height
        self.hairColor = hairColor
        self.eyeColor = eyeColor
        self.passportID = passportID
        self.countryID = values[.cid]
    }
}

let passports = try parseFile(at: passportFile, separator: "\n\n", transform: FakePassport.init)

print("Valid passport count: \(passports.count)")

//: Problem 2
struct ValidatingFakePassport {
    enum Height {
        case cm(Int)
        case inch(Int)
        
        init?(_ string: String) {
            let unit = string.suffix(2)
            guard let value = Int(string.dropLast(2)) else {
                return nil
            }
            
            switch unit {
            case "cm" where (150...193).contains(value):
                self = .cm(value)
            case "in" where (59...76).contains(value):
                self = .inch(value)
            default:
                return nil
            }
        }
    }
    
    enum EyeColor: String {
        case amb
        case blu
        case brn
        case gry
        case grn
        case hzl
        case oth
    }
    
    let birthYear: Int
    let issueYear: Int
    let expirationYear: Int
    let height: Height
    let hairColor: String
    let eyeColor: EyeColor
    let passportID: String
    let countryID: String?
    
    init?(_ record: String) {
        let fields = record.split {
            $0 == Character("\n") || $0 == Character(" ")
        }

        let values: [Field: String] = fields.reduce(into: [:]) { (result, eachField) in
            let pair = eachField.components(separatedBy: ":")
            guard
                pair.count == 2,
                let field = Field(rawValue: pair[0]) else {
                    return
            }
            
            result[field] = pair[1]
        }
        
        let isValidHaircolor: (String) -> Bool = { hairColor -> Bool in
            guard hairColor.hasPrefix("#") else { return false }
            let possibleCode = hairColor.dropFirst()
            guard possibleCode.count == 6 else  { return false }
            
            let hexCharSet = CharacterSet(charactersIn: "0123456789abcdef")
            return possibleCode.allSatisfy {
                guard let unicode = $0.unicodeScalars.map({ $0.value }).first.flatMap(Unicode.Scalar.init) else {
                    return false
                }
                return hexCharSet.contains(unicode)
            }
        }
        
        guard
            let birthYear = values[.byr].flatMap(Int.init), (1920...2002).contains(birthYear),
            let issueYear = values[.iyr].flatMap(Int.init), (2010...2020).contains(issueYear),
            let expirationYear = values[.eyr].flatMap(Int.init), (2020...2030).contains(expirationYear),
            let height = values[.hgt].flatMap(Height.init),
            let hairColor = values[.hcl], isValidHaircolor(hairColor),
            let eyeColor = values[.ecl].flatMap(EyeColor.init),
            let passportID = values[.pid], passportID.count == 9, Int(passportID) != nil else {
            return nil
        }
        
        self.birthYear = birthYear
        self.issueYear = issueYear
        self.expirationYear = expirationYear
        self.height = height
        self.hairColor = hairColor
        self.eyeColor = eyeColor
        self.passportID = passportID
        self.countryID = values[.cid]
    }
}

let validatingPassports = try parseFile(at: passportFile, separator: "\n\n", transform: ValidatingFakePassport.init)

print("Valid passport count: \(validatingPassports.count)")


//: [Next](@next)
