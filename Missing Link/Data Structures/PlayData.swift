//
//  PlayData.swift
//  Missing Link
//
//  Created by Benjamin Share on 12/5/20.
//  Copyright © 2020 Benjamin Share. All rights reserved.
//

import Foundation

private let PUZZLE_MULTIPLIER = 1
private let LEVEL_MULTIPLIER = 3
private let PACK_MULTIPLIER = 10

class PlayData: Codable, Equatable {
    // MARK: Properties
    var score: Int
    var puzzlesCompleted: Int
    var levelsCompleted: Int
    var packsCompleted: Int
    var puzzlesToday: Int
    var mostPuzzlesInOneDay: Int
    var lastDay: String
    var metadata: PuzzleMetadata
    
    static func == (lhs: PlayData, rhs: PlayData) -> Bool {
        return structComparisonFn(lhs: lhs, rhs: rhs)
    }
    
    enum CodingKeys: String, CodingKey {
        case score = "score"
        case puzzlesCompleted = "puzzlesCompleted"
        case levelsCompleted = "levelsCompleted"
        case packsCompleted = "packsCompleted"
        case puzzlesToday = "puzzlesToday"
        case mostPuzzlesInOneDay = "mostPuzzlesInOneDay"
        case lastDay = "lastDay"
        case metadata = "metadata"
    }
    
    init(overall: Int = 0, puzzles: Int = 0, levels: Int = 0, packs: Int = 0, today: Int = 0, oneDay: Int = 0, day: String = "2020-01-01", data: PuzzleMetadata = PuzzleMetadata()) {
        score = overall
        puzzlesCompleted = puzzles
        levelsCompleted = levels
        packsCompleted = packs
        puzzlesToday = today
        mostPuzzlesInOneDay = oneDay
        lastDay = day
        metadata = data
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.score = try container.decode(Int.self, forKey: .score)
        self.puzzlesCompleted = try container.decode(Int.self, forKey: .puzzlesCompleted)
        self.levelsCompleted = try container.decode(Int.self, forKey: .levelsCompleted)
        self.packsCompleted = try container.decode(Int.self, forKey: .levelsCompleted)
        self.puzzlesToday = try container.decode(Int.self, forKey: .puzzlesToday)
        self.mostPuzzlesInOneDay = try container.decode(Int.self, forKey: .mostPuzzlesInOneDay)
        self.lastDay = try container.decode(String.self, forKey: .lastDay)
        do {
            self.metadata = try container.decode(PuzzleMetadata.self, forKey: .metadata)
        } catch {
            self.metadata = PuzzleMetadata()
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.score, forKey: .score)
        try container.encode(self.puzzlesCompleted, forKey: .puzzlesCompleted)
        try container.encode(self.levelsCompleted, forKey: .levelsCompleted)
        try container.encode(self.packsCompleted, forKey: .packsCompleted)
        try container.encode(self.puzzlesToday, forKey: .puzzlesToday)
        try container.encode(self.mostPuzzlesInOneDay, forKey: .mostPuzzlesInOneDay)
        try container.encode(self.lastDay, forKey: .lastDay)
        try container.encode(self.metadata, forKey: .metadata)
    }
    
    func updateOnPuzzleComplete() {
        score += PUZZLE_MULTIPLIER
        puzzlesCompleted += 1
        let today = DATE_FORMATTER.string(from: Date())
        if lastDay != today {
            puzzlesToday = 0
        }
        lastDay = today
        puzzlesToday += 1
        if puzzlesToday > mostPuzzlesInOneDay {
            mostPuzzlesInOneDay = puzzlesToday
        }
    }

    func updateOnLevelComplete() {
        score += LEVEL_MULTIPLIER
        levelsCompleted += 1
    }

    func updateOnPackComplete() {
        score += PACK_MULTIPLIER
        packsCompleted += 1
    }

    func updateTodayIfExpired() {
        if lastDay != DATE_FORMATTER.string(from: Date()) {
            puzzlesToday = 0
        }
    }
}
