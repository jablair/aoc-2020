//: [Previous](@previous)

//: [Day 15](https://adventofcode.com/2020/day/15)


import Foundation

var input = [5,2,8,16,18,0,1]

var positions: [Int: [Int]] = [:]

class MemoryGame {
    private var lastIndexPerCard: [Int: Int]
    private var playCard: Int
    let startRound: Int
    
    init?(seed: [Int]) {
        guard let position = seed.last else {
            return nil
        }
        
        self.playCard = position
        self.startRound = seed.endIndex
        
        self.lastIndexPerCard = [:]
        
        seed.dropLast().indices.forEach { idx in
            self.lastIndexPerCard[seed[idx]] = idx + 1
        }
    }
    
    func play(rounds: Int) -> Int {
         
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

let game = MemoryGame(seed: input)!

//: Problem 1
print("Round 2020: \(game.play(rounds: 2020))")

//: Problem 2
print("Round 30000000: \(game.play(rounds: 30_000_000))")
