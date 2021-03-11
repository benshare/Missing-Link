//
//  User.swift
//  Missing Link
//
//  Created by Benjamin Share on 9/24/19.
//  Copyright © 2019 Benjamin Share. All rights reserved.
//

import Foundation

class User: Codable {
    var username: String
    var passwordHash: String
    var progress: AppProgress
    var data: UserDataStruct
    var rewards: Rewards
    var preferences: UserPreferencesStruct
    
    static func == (lhs: User, rhs: User) -> Bool {
        return (lhs.username == rhs.username) && (lhs.passwordHash == rhs.passwordHash) && (lhs.progress == rhs.progress) && (lhs.data == rhs.data) && (lhs.rewards == rhs.rewards) && (lhs.preferences == rhs.preferences)
    }
    
    enum CodingKeys: String, CodingKey {
        case username = "username"
        case password = "passwordHash"
        case progress = "progress"
        case data = "data"
        case rewards = "rewards"
        case preferences = "preferences"
    }
    
    init(username: String, password: String) {
        self.username = username
        self.passwordHash = passwordHashFunction(username, password)
        self.progress = AppProgress()
        self.data = UserDataStruct()
        self.rewards = Rewards()
        self.preferences = UserPreferencesStruct()
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.username = try container.decode(String.self, forKey: .username)
        self.passwordHash = try container.decode(String.self, forKey: .password)
        self.progress = try container.decode(AppProgress.self, forKey: .progress)
        self.data = try container.decode(UserDataStruct.self, forKey: .data)
        self.rewards = try container.decode(Rewards.self, forKey: .rewards)
        self.preferences = try container.decode(UserPreferencesStruct.self, forKey: .preferences)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.username, forKey: .username)
        try container.encode(self.passwordHash, forKey: .password)
        try container.encode(self.progress, forKey: .progress)
        try container.encode(self.data, forKey: .data)
        try container.encode(self.rewards, forKey: .rewards)
        try container.encode(self.preferences, forKey: .preferences)
    }
}

class LoggedInUser {
    var isGuest: Bool
    var rememberMe: Bool
    var user: User!
    
    init() {
        isGuest = true
        rememberMe = false
    }
    
    init(user: User, rememberMe: Bool) {
        isGuest = false
        self.rememberMe = rememberMe
        self.user = user
    }
}

func structComparisonFn(lhs: AnyObject, rhs: AnyObject) -> Bool {
    var left_as_map = [String: Any]()
    for child in Mirror(reflecting: lhs).children {
        left_as_map.updateValue(child.value, forKey: child.label!)
    }
    for child in Mirror(reflecting: rhs).children {
        switch child.label {
        case "lastDayInStreak", "lastDay":
            if left_as_map[child.label!] as! String != child.value as! String {
                return false
            }
        default:
            if left_as_map[child.label!] as! Int != child.value as! Int {
                return false
            }
        }
    }
    return true
}

struct UserDataStruct: Codable, Equatable {
    var playData: PlayData
    var dailyData: DailyData
    var contributionsData: ContributionsData
    
    init(play: PlayData, daily: DailyData, contributions: ContributionsData) {
        self.playData = play
        self.dailyData = daily
        self.contributionsData = contributions
    }
    
    init() {
        self.playData = PlayData()
        self.dailyData = DailyData()
        self.contributionsData = ContributionsData()
    }
}

struct UserPreferencesStruct: Codable, Equatable {
    var submitDifficultyFeedback: Bool
    var showOnLeaderboard: Bool
    var allowMetadataCollection: Bool
    
    init(submit: Bool, show: Bool, allow: Bool) {
        self.submitDifficultyFeedback = submit
        self.showOnLeaderboard = show
        self.allowMetadataCollection = allow
    }
    
    init() {
        self.submitDifficultyFeedback = true
        self.showOnLeaderboard = true
        self.allowMetadataCollection = true
    }
}
