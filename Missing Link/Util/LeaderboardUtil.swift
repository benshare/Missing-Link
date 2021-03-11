//
//  LeaderboardUtil.swift
//  Missing Link
//
//  Created by Benjamin Share on 5/3/20.
//  Copyright © 2020 Benjamin Share. All rights reserved.
//

import Foundation
import AWSDynamoDB


// MARK: Leaderboard Data Classes

enum LeaderboardState {
    case play, daily, contributions
}

public class LeaderboardUtil {
    static let stateToDatatype: [(LeaderboardState, AWSDynamoDBObjectModel.Type)] = [
        (LeaderboardState.play, PlayLeaderboard.self),
        (LeaderboardState.daily, DailyLeaderboard.self),
        (LeaderboardState.contributions, ContributionsLeaderboard.self),
    ]
}

public class LeaderboardOutput: Codable {
    public var rank: Int
    public var username: String
    public var score: Int
    
    init(rank: Int, username: String, score: Int) {
        self.rank = rank
        self.username = username
        self.score = score
    }
}

public class LeaderboardTopUsersList {
    public var data: [LeaderboardOutput]
    public var minScore: Int
    
    init(data: [LeaderboardOutput]) {
        self.data = data
        minScore = data.last?.score ?? -1
    }
}


// MARK: Globals

let LEADERBOARD_READY_GROUP = DispatchGroup()

var TOP_USERS_LEADERBOARD_DATA: [LeaderboardState: LeaderboardTopUsersList?] = [
    LeaderboardState.play: nil,
    LeaderboardState.daily: nil,
    LeaderboardState.contributions: nil,
]

let MAX_LEADERBOARD_LENGTH = 10


// MARK: Test Data

public let testNames = [
    "Ben",
    "Rachel",
    "Lisa",
    "Robert",
    "Paul",
    "Ayush",
    "Jen",
    "Ruchir",
    "Kupenda",
    "Safi",
    "Nick",
    "Stephen",
    "Vanshil",
    "Harry",
    "Hermione",
    "Ron",
    "McGonagall",
    "Snape",
    "Dumbledore",
    "Malfoy",
    "Dobby",
    "Devon",
    "Ella",
    "Erin",
    "Angela",
    "Maia",
]
