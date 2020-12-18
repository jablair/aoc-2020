//: [Previous](@previous)

//: [Day 17](https://adventofcode.com/2020/day/17)

import Foundation

//let seed = """
//.#.
//..#
//###
//"""

guard let seedFile = Bundle.main.url(forResource: "seed", withExtension: "txt") else {
    exit(0)
}

let seed = String(contentsOf: seedFile)

//: Problem 1
struct Coordinate: Comparable, Hashable {
    let x: Int
    let y: Int
    let z: Int
    
    var neighbors: Set<Coordinate> {
        var neighbors: Set<Coordinate> = []
        
        for zIdx in -1...1 {
            for yIdx in -1...1 {
                for xIdx in -1...1 {
                    if xIdx == 0, yIdx == 0, zIdx == 0 {
                        continue
                    }
                    neighbors.insert(Coordinate(x: x + xIdx, y: y + yIdx, z: z + zIdx))
                }
            }
        }
        
        return neighbors
    }
    
    static func < (lhs: Coordinate, rhs: Coordinate) -> Bool {
        if lhs.z != rhs.z {
            return lhs.z < rhs.z
        } else if lhs.y != rhs.y {
            return lhs.y < rhs.y
        } else {
            return lhs.x < rhs.x
        }
    }
}

class Conway {
    private(set) var cubes: [Coordinate: Bool] = [:]
    private let seed: String
    
    init(seed: String) {
        self.seed = seed
        
        reset()
    }
    
    func reset() {
        var x = 0, y = 0
        let z = 0
        for index in seed.indices {
            if seed[index] == "\n" {
                x = 0
                y += 1
                continue
            }
            
            self.cubes[Coordinate(x: x, y: y, z: z)] = seed[index] == "#"
            x += 1
        }
    }
    
    func play(rounds: Int) {
        for _ in 0..<rounds {
            let currentCubes = cubes
            let soortedCoordinates = cubes.keys.sorted()
            guard let zMin = soortedCoordinates.map(\.z).min(),
                  let zMax = soortedCoordinates.map(\.z).max(),
                  let yMin = soortedCoordinates.map(\.y).min(),
                  let yMax = soortedCoordinates.map(\.y).max(),
                  let xMin = soortedCoordinates.map(\.x).min(),
                  let xMax = soortedCoordinates.map(\.x).max() else {
                return
            }
            
            let xRange = (xMin - 1)...(xMax + 1)
            let yRange = (yMin - 1)...(yMax + 1)
            let zRange = (zMin - 1)...(zMax + 1)
            
            for z in zRange {
                for y in yRange {
                    for x in xRange {
                        let coord = Coordinate(x: x, y: y, z: z)
                        let neighborCubes = coord.neighbors.compactMap { currentCubes[$0] == true ? $0 : nil }
                        if currentCubes[coord] == true {
                            cubes[coord] = (2...3).contains(neighborCubes.count)
                        } else if neighborCubes.count == 3 {
                            cubes[coord] = true
                        }
                    }
                }
            }
        }
    }
}

let conway = Conway(seed: seed)
conway.play(rounds: 6)

let active: Int = conway.cubes.values.reduce(0) { (total, active) -> Int in
    return total + (active ? 1 : 0)
}

print("Part 1 Active Cubes: \(active)")

//: Problem 2

struct HyperCoordinate: Comparable, Hashable {
    let w: Int
    let x: Int
    let y: Int
    let z: Int
    
    var neighbors: Set<HyperCoordinate> {
        var neighbors: Set<HyperCoordinate> = []
        
        for zOffset in -1...1 {
            for yOffset in -1...1 {
                for xOffset in -1...1 {
                    for wOffset in -1...1 {
                        if wOffset == 0, xOffset == 0, yOffset == 0, zOffset == 0 {
                            continue
                        }
                        neighbors.insert(HyperCoordinate(w: w + wOffset, x: x + xOffset, y: y + yOffset, z: z + zOffset))
                    }
                }
            }
        }
        
        return neighbors
    }
    
    static func < (lhs: HyperCoordinate, rhs: HyperCoordinate) -> Bool {
        if lhs.z != rhs.z {
            return lhs.z < rhs.z
        } else if lhs.y != rhs.y {
            return lhs.y < rhs.y
        } else if lhs.x < rhs.x {
            return lhs.x < rhs.x
        } else {
            return lhs.w < rhs.w
        }
    }
}

class HyperConway {
    private(set) var cubes: [HyperCoordinate: Bool] = [:]
    private let seed: String
    
    init(seed: String) {
        self.seed = seed
        
        reset()
    }
    
    func reset() {
        var x = 0, y = 0
        let z = 0
        let w = 0
        
        for index in seed.indices {
            if seed[index] == "\n" {
                x = 0
                y += 1
                continue
            }
            
            self.cubes[HyperCoordinate(w: w, x: x, y: y, z: z)] = seed[index] == "#"
            x += 1
        }
    }
    
    func play(rounds: Int) {
        for _ in 0..<rounds {
            let currentCubes = cubes
            let soortedCoordinates = cubes.keys.sorted()
            guard let zMin = soortedCoordinates.map(\.z).min(),
                  let zMax = soortedCoordinates.map(\.z).max(),
                  let yMin = soortedCoordinates.map(\.y).min(),
                  let yMax = soortedCoordinates.map(\.y).max(),
                  let xMin = soortedCoordinates.map(\.x).min(),
                  let xMax = soortedCoordinates.map(\.x).max(),
                  let wMin = soortedCoordinates.map(\.w).min(),
                  let wMax = soortedCoordinates.map(\.w).max() else {
                return
            }
            
            let wRange = (wMin - 1)...(wMax + 1)
            let xRange = (xMin - 1)...(xMax + 1)
            let yRange = (yMin - 1)...(yMax + 1)
            let zRange = (zMin - 1)...(zMax + 1)
            
            for z in zRange {
                for y in yRange {
                    for x in xRange {
                        for w in wRange {
                            let coord = HyperCoordinate(w: w, x: x, y: y, z: z)
                            let neighborCubes = coord.neighbors.compactMap { currentCubes[$0] == true ? $0 : nil }
                            if currentCubes[coord] == true {
                                cubes[coord] = (2...3).contains(neighborCubes.count)
                            } else if neighborCubes.count == 3 {
                                cubes[coord] = true
                            }
                        }
                    }
                }
            }
        }
    }
}


let hyper = HyperConway(seed: seed)
hyper.play(rounds: 6)

let hyperActive: Int = hyper.cubes.values.reduce(0) { (total, active) -> Int in
    return total + (active ? 1 : 0)
}

print("Part 2 Active Cubes: \(hyperActive)")

