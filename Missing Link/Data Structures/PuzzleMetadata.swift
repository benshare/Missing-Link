//
//  PuzzleMetadata.swift
//  Missing Link
//
//  Created by Benjamin Share on 11/29/20.
//  Copyright © 2020 Benjamin Share. All rights reserved.
//

import Foundation
import UIKit

// Back button is considered the same as skip
enum PuzzleAction: String {
    case complete, hint, skip, rate
}

enum PuzzleDifficultyRating: Int, Codable {
    case one, two, three, four, five
    
    init(rating: Int) {
        switch rating {
        case 1:
            self = .one
        case 2:
            self = .two
        case 3:
            self = .three
        case 4:
            self = .four
        case 5:
            self = .five
        default:
            print("Invalid value provided for difficulty rating initializer")
            self = .one
        }
    }
}

class PuzzleMetadataPoint: Codable {
    var didComplete: Bool
    var usedHint: Bool
    var skipped: Bool
    var timeSpent: Double?
    var rating: PuzzleDifficultyRating?
    
    enum CodingKeys: String, CodingKey {
        case didComplete = "didComplete"
        case usedHint = "usedHint"
        case skipped = "skipped"
        case timeSpent = "timeSpent"
        case rating = "rating"
    }
    
    init(didComplete: Bool=false, usedHint: Bool=false, skipped: Bool=false, timeSpent: Double?=nil, rating: PuzzleDifficultyRating?=nil) {
        self.didComplete = didComplete
        self.usedHint = usedHint
        self.skipped = skipped
        self.timeSpent = timeSpent
        self.rating = rating
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.didComplete = try container.decode(Bool.self, forKey: .didComplete)
        self.usedHint = try container.decode(Bool.self, forKey: .usedHint)
        self.skipped = try container.decode(Bool.self, forKey: .skipped)
        self.timeSpent = try container.decode(Double.self, forKey: .timeSpent)
        self.rating = try container.decode(PuzzleDifficultyRating.self, forKey: .rating)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.didComplete, forKey: .didComplete)
        try container.encode(self.usedHint, forKey: .usedHint)
        try container.encode(self.skipped, forKey: .skipped)
        try container.encode(self.timeSpent, forKey: .timeSpent)
        try container.encode(self.rating, forKey: .rating)
    }
}

class PuzzleMetadata: Codable {
    private var puzzleData: [Puzzle: PuzzleMetadataPoint]
    
    init() {
        puzzleData = [Puzzle: PuzzleMetadataPoint]()
    }
    
    func update(puzzle: Puzzle, action: PuzzleAction, time: Double = 0, rating: PuzzleDifficultyRating = .one) {
        switch action {
        case .complete:
            if puzzleData[puzzle] != nil {
                puzzleData[puzzle]?.didComplete = true
                puzzleData[puzzle]?.timeSpent! += time
            } else {
                puzzleData[puzzle] = PuzzleMetadataPoint(didComplete: true, timeSpent: time)
            }
        case .hint:
            if puzzleData[puzzle] != nil {
                puzzleData[puzzle]?.usedHint = true
                puzzleData[puzzle]?.timeSpent! += time
            } else {
                puzzleData[puzzle] = PuzzleMetadataPoint(usedHint: true, timeSpent: time)
            }
        case .skip:
            if puzzleData[puzzle] != nil {
                puzzleData[puzzle]?.skipped = true
                puzzleData[puzzle]?.timeSpent! += time
            } else {
                puzzleData[puzzle] = PuzzleMetadataPoint(usedHint: true, timeSpent: time)
            }
        case .rate:
            if puzzleData[puzzle] != nil {
                puzzleData[puzzle]?.rating = rating
            } else {
                puzzleData[puzzle] = PuzzleMetadataPoint(rating: rating)
            }
        }
    }
}
