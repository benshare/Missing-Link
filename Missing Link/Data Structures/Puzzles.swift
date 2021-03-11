//
//  Puzzles.swift
//  Missing Link
//
//  Created by Benjamin Share on 9/4/19.
//  Copyright © 2019 Benjamin Share. All rights reserved.
//

import UIKit

enum Status: String, Codable {
    case locked, unlocked, completed
}

struct Clues: Codable, Hashable {
    let first: String
    let last: String
    let answer: String
    
    init(words: [String]) {
        if words.count != 3 {
            fatalError("Attempted to initialize puzzle with incorrect number of words (\(words.count), should be 3)")
        }
        (first, last, answer) = (words[0], words[1], words[2])
    }
}

class Puzzle: Codable, Hashable {
    private let clues: Clues
    
    init(words: [String]) {
        clues = Clues(words: words)
    }
    
    static func == (lhs: Puzzle, rhs: Puzzle) -> Bool {
        return lhs.clues == rhs.clues
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(clues)
    }
    
    func first() -> String {
        return clues.first
    }
    
    func last() -> String {
        return clues.last
    }
    
    func answer() -> String {
        return clues.answer
    }
}

class PuzzleLevel: Codable {
    private let puzzles: Roulette<Puzzle>
    let id: Int
    
    init(db_id: Int, puzzle_data: [[String]]) {
        self.id = db_id
        self.puzzles = Roulette(data: puzzle_data.map( { return Puzzle(words: $0) }))
    }
    
    init(wrapper: PuzzleLevelServerWrapper) {
        self.id = wrapper.id
        self.puzzles = Roulette(data: wrapper.puzzles)
    }
    
    func updateWithProgress(progress: LevelProgress) {
        puzzles.updateWithProgress(progress: progress)
    }
    
    func getPuzzle() -> Puzzle? {
        return puzzles.nextValue() as! Puzzle?
    }
    
    func skipPuzzle() {
        puzzles.skip()
    }
    
    func completePuzzle() {
        if puzzles.isCompleted() {
            puzzles.skip()
        } else {
            puzzles.popFront()
        }
    }
    
    func length() -> Int {
        return puzzles.totalLength()
    }
    
    func currentPuzzle() -> Int {
        return puzzles.currentIndex()
    }
    
    func isLevelComplete() -> Bool {
        return puzzles.isCompleted()
    }
    
    // TODO: Delete
    func numLeft() -> Int {
        return puzzles.lengthRemaining()
    }
}

class PuzzlePack: NSObject, Codable {
    private var pack: [PuzzleLevel]
    let packName: String
    
    init(data: [PuzzleLevel], name: String) {
        self.pack = data
        self.packName = name
    }
    
    func getLevels() -> [PuzzleLevel] {
        return pack
    }
    
    func addLevel(level: PuzzleLevel) {
        pack.append(level)
    }
    
    func length() -> Int {
        return pack.count
    }
}


class PuzzleLevelServerWrapper: Codable {
    let puzzles: [Puzzle]
    let id: Int

    init(db_id: Int, puzzle_data: [[String]]) {
        self.id = db_id
        self.puzzles = puzzle_data.map( { return Puzzle(words: $0) })
    }
}
