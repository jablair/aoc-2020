//: [Previous](@previous)

import Foundation

protocol Instruction { }

func process(instruction: String) -> Instruction? {
    let range = NSRange(instruction.startIndex..<instruction.endIndex, in: instruction)
    
    let maskRegex = try! NSRegularExpression(pattern: #"mask = ([01X]{36})"#, options: [])
    let writeRegex = try! NSRegularExpression(pattern: #"mem\[(\d+)] = (\d+)"#, options: [])
    
    if let match = maskRegex.firstMatch(in: instruction, options: [], range: range),
       match.numberOfRanges == 2,
       let maskRange = Range(match.range(at: 1), in: instruction) {
        return MaskInstruction(mask: String(instruction[maskRange]))// .update(String(instruction[maskRange]))
    } else if let match = writeRegex.firstMatch(in: instruction, options: [], range: range),
              match.numberOfRanges == 3,
              let addressRange = Range(match.range(at: 1), in: instruction),
              let valueRange = Range(match.range(at: 2), in: instruction),
              let address = Int(instruction[addressRange]),
              let value = UInt(instruction[valueRange]) {
        return WriteInstruction(address: address, value: value)
    } else {
        return nil
    }
}

struct MaskInstruction: Instruction {
    let mask: String
  
    var onMask: UInt? {
        UInt(mask.replacingOccurrences(of: "X", with: "0"), radix: 2)
    }
    
    var offMask: UInt? {
        UInt(mask.replacingOccurrences(of: "X", with: "1"), radix: 2)
    }
    
    var chaosPositions: [Int] {
        mask.indices.filter {
            mask[$0] == "X"
        }.map {
            mask.distance(from: mask.startIndex, to: $0)
        }
    }
}

struct WriteInstruction: Instruction {
    let address: Int
    let value: UInt
}

guard let instructionFile = Bundle.main.url(forResource: "instructions", withExtension: "txt") else {
    exit(0)
}

let instructions = try parseFile(at: instructionFile) {
    process(instruction: $0)
}

//: Problem 1

class Seaport {
    let instructions: [Instruction]
    private var mask: MaskInstruction?
    private var memory: [Int: UInt] = [:]
    
    init(instructions: [Instruction]) {
        self.instructions = instructions
    }
    
    func execute() -> UInt {
        memory.removeAll()
        
        for instruction in instructions {
            if let maskInstruction = instruction as? MaskInstruction {
                mask = maskInstruction
            } else if let onMask = mask?.onMask,
                      let offMask = mask?.offMask,
                      let writeInstruction = instruction as? WriteInstruction {
                memory[writeInstruction.address] = (writeInstruction.value | onMask) & offMask
            }
        }
        
        return memory.values.reduce(0, +)
    }
}

let seaport = Seaport(instructions: instructions)
print("V1 Memory sum: \(seaport.execute())")

//: Problem 2

extension String {
    func padded(to length: Int = 36) -> String {
        var padded = self
        for _ in 0..<(36 - count) {
            padded = "0" + padded
        }
        return padded
    }
}

class SeaportV2 {
    let instructions: [Instruction]
    private var memory: [Int: UInt] = [:]
    
    init(instructions: [Instruction]) {
        self.instructions = instructions
    }
    
    func execute() -> UInt {
        memory.removeAll()
        
        var mask: MaskInstruction?

        for instruction in instructions {
            if let maskInstruction = instruction as? MaskInstruction {
                mask = maskInstruction
            } else if let mask = mask,
                      let writeInstruction = instruction as? WriteInstruction {
                // Yup - treating addresses like strings for this part
                // Probably should've kept everything as strings till rendering the final values…
                let address = String(writeInstruction.address, radix: 2).padded()
                let onIndexes = mask.mask.indices.filter { mask.mask[$0] == "1" }
                var baseAddress = address
                onIndexes.forEach {
                    baseAddress.replaceSubrange($0...$0, with: "1")
                }
                
                let addresses = self.addresses(for: baseAddress, floatingPositions: mask.chaosPositions)
                addresses.forEach {
                    guard let addressLoccation = Int($0, radix: 2) else {
                        return
                    }
                    
                    memory[addressLoccation] = writeInstruction.value
                }
            }
        }
        
        return memory.values.reduce(0, +)
    }
    
    private func addresses(for address: String, floatingPositions: [Int]) -> [String] {
        guard let position = floatingPositions.first else {
            return []
        }
        
        let index = address.index(address.startIndex, offsetBy: position)
        
        var onAddress = address
        var offAddress = address
        
        onAddress.replaceSubrange(index...index, with: "1")
        offAddress.replaceSubrange(index...index, with: "0")
        let addresses = [onAddress, offAddress]
                
        let remainingIndices = Array(floatingPositions.dropFirst())
        let childAddresses = addresses.map {
            self.addresses(for: $0, floatingPositions: remainingIndices)
        }
        
        return Set(addresses + childAddresses.flatMap { $0 }).sorted()
    }
}


let seaport2 = SeaportV2(instructions: instructions)
print("V2 Memory sum: \(seaport2.execute())")

//: [Next](@next)
