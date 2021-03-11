//
//  ProgressUtil.swift
//  Missing Link
//
//  Created by Benjamin Share on 6/10/20.
//  Copyright © 2020 Benjamin Share. All rights reserved.
//

import Foundation

let PROGRESS_DBD_GROUP = DispatchGroup()
let PROGRESS_VARIABLES_GROUP = DispatchGroup()

// MARK: Progress Data Classes

class LevelProgress: Codable, Equatable {
    static func == (lhs: LevelProgress, rhs: LevelProgress) -> Bool {
        return lhs.status == rhs.status && lhs.puzzleStatuses == rhs.puzzleStatuses && lhs.nextPuzzle == rhs.nextPuzzle
    }
    
    var status: Status
    var puzzleStatuses: [Status]?
    var nextPuzzle: Int
    
    enum CodingKeys: String, CodingKey {
        case status
        case puzzleStatuses
        case nextPuzzle
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.status = try container.decode(Status.self, forKey: .status)
        self.puzzleStatuses = try container.decode([Status]?.self, forKey: .puzzleStatuses)
        self.nextPuzzle = try container.decode(Int.self, forKey: .nextPuzzle)
    }
    
    init(status: Status, puzzleStatuses: [Status]?=nil, nextPuzzle: Int=0) {
        self.status = status
        if status == .unlocked {
            if puzzleStatuses == nil {
                fatalError("Nil values provided for in-progress level")
            }
        }
        self.puzzleStatuses = puzzleStatuses
        self.nextPuzzle = nextPuzzle
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.status, forKey: .status)
        try container.encode(self.puzzleStatuses, forKey: .puzzleStatuses)
        try container.encode(self.nextPuzzle, forKey: .nextPuzzle)
    }
    
    func unlock(length: Int) {
        if status != .locked {
            fatalError("Unlock called on non-locked level")
        }
        status = .unlocked
        puzzleStatuses = (0...length-1).map( { _ in Status.unlocked } )
    }
    
    func completePuzzle(newNext: Int) {
        puzzleStatuses![nextPuzzle] = .completed
        nextPuzzle = newNext
    }
    
    func completeLevel() {
        status = .completed
        puzzleStatuses = nil
        nextPuzzle = 0
    }
}

class PackProgress: Codable, Equatable {
    static func == (lhs: PackProgress, rhs: PackProgress) -> Bool {
        return lhs.status == rhs.status && lhs.nextLevel == rhs.nextLevel && lhs.levelProgresses == rhs.levelProgresses
    }
    
    var status: Status
    var levelProgresses: [LevelProgress]?
    var levelLengths: [Int]?
    // nextLevel is technically redundant, since levels must be completed in order
    var nextLevel: Int
    
    enum CodingKeys: String, CodingKey {
        case levelProgresses = "level_progresses"
        case levelLengths = "level_lengths"
        case nextLevel = "next_level"
        case status
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.status = try container.decode(Status.self, forKey: .status)
        self.levelProgresses = try container.decode([LevelProgress]?.self, forKey: .levelProgresses)
        self.levelLengths = try container.decode([Int].self, forKey: .levelLengths)
        self.nextLevel = try container.decode(Int.self, forKey: .nextLevel)
    }
    
    init(status: Status, levelProgresses: [LevelProgress]?=nil, levelLengths: [Int]?=nil, nextLevel: Int=0) {
        self.status = status
        if status == .unlocked {
            if levelProgresses == nil || levelLengths == nil {
                fatalError("Nil values provided for in-progress pack")
            }
        }
        self.levelProgresses = levelProgresses
        self.levelLengths = levelLengths
        self.nextLevel = nextLevel
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.levelProgresses, forKey: .levelProgresses)
        try container.encode(self.levelLengths, forKey: .levelLengths)
        try container.encode(self.nextLevel, forKey: .nextLevel)
        try container.encode(self.status, forKey: .status)
    }
    
    func unlock(pack: PuzzlePack) {
        let packLength = pack.length()
        if status != .locked {
            fatalError("Unlock called on non-locked pack")
        }
        status = .unlocked
        levelProgresses = (0...packLength-1).map( { _ in LevelProgress(status: .locked) } )
        self.levelLengths = pack.getLevels().map( { $0.length() } )
        levelProgresses![0].unlock(length: levelLengths![0])
    }
    
    func completeLevel() {
        levelProgresses![nextLevel].completeLevel()
        nextLevel += 1
        if nextLevel < levelProgresses!.count {
            levelProgresses![nextLevel].unlock(length: levelLengths![nextLevel])
        }
    }
    
    func completePack() {
        status = .completed
        levelProgresses = nil
        nextLevel = 0
    }
}

class AppProgress: Codable, Equatable {
    static func == (lhs: AppProgress, rhs: AppProgress) -> Bool {
        return lhs.pack_progresses == rhs.pack_progresses
    }
    
    var pack_progresses: [String: PackProgress]
    
    enum CodingKeys: String, CodingKey {
        case progress = "pack_progresses"
    }
    
    // Call to create a new user's app progress
    init() {
        PACK_VARIABLES_GROUP.wait()
        pack_progresses = [:]
        for pack in AGGREGATE_PACK_INFO.values {
            pack_progresses[pack.packName] = PackProgress(status: .locked)
        }
        for id in getDefaultUnlockedPackIds() {
            unlockPack(id: id)
        }
//        for pack in getDefaultUnlockedPackList() {
//            pack_progresses[pack]?.unlock(pack: <#T##PuzzlePack#>)
//        }
//        if !VISIBLE_SECTIONS.map.isEmpty {
//            for section in VISIBLE_SECTIONS.map.values {
//                unlockPack(id: section[0].id)
//            }
//        }
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.pack_progresses = try container.decode([String: PackProgress].self, forKey: .progress)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.pack_progresses, forKey: .progress)
    }
    
    func unlockPack(id: Int) {
        let pack = AGGREGATE_PACK_INFO[id]!
        pack_progresses[pack.packName]?.unlock(pack: pack)
    }
}

// MARK: Progress Data Functions

func resolveRememberedAndFetchedProgresses(rememberedUser: User, fetchedProgress: (AppProgress, UserDataStruct, Rewards, UserPreferencesStruct)) {
    // TODO: Fill in this implementation. Should probably be whichever is more up to date (or union of two?). For now, default to remembered since it's likely more up to date
    (rememberedUser.progress, rememberedUser.data, rememberedUser.rewards, rememberedUser.preferences) = fetchedProgress
}
