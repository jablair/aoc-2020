//: [Previous](@previous)

//: [Day 15](https://adventofcode.com/2020/day/15)

import Foundation

let input = [5,2,8,16,18,0,1]

class MemoryGame {
    private var lastIndexPerCard: [Int: Int]
    private var playCard: Int
    private let startRound: Int
    private let rounds: Int
    
    init?(seed: [Int], rounds: Int) {
        guard let position = seed.last else {
            return nil
        }
        
        self.playCard = position
        self.startRound = seed.endIndex
        self.rounds = rounds
        
        self.lastIndexPerCard = [:]
        
        seed.dropLast().indices.forEach { idx in
            self.lastIndexPerCard[seed[idx]] = idx + 1
        }
    }
    
    func play() -> Int {
         
        for round in startRound..<rounds {
            let newVal: Int
            if let lastCardIndex = lastIndexPerCard[playCard] {
                newVal = round - lastCardIndex
            } else {
                newVal = 0
            }
            
            lastIndexPerCard[playCard] = round
            playCard = newVal
        }

        return playCard
    }
}

//: Problem 1
let game1 = MemoryGame(seed: input, rounds: 2020)!
print("Round 2020: \(game1.play())")

//: Problem 2
let game2 = MemoryGame(seed: input, rounds: 30_000_000)!
print("Round 30000000: \(game2.play(rounds: 30_000_000))")
