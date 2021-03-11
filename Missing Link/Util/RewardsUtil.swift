//
//  RewardsUtil.swift
//  Missing Link
//
//  Created by Benjamin Share on 11/26/20.
//  Copyright © 2020 Benjamin Share. All rights reserved.
//

import Foundation

// MARK: Rewards Class
class Rewards: Codable, Equatable {
    var coins: Int
    
    static func == (lhs: Rewards, rhs: Rewards) -> Bool {
        return lhs.coins == rhs.coins
    }
    
    enum CodingKeys: String, CodingKey {
        case coins = "coins"
    }
    
    init(coins: Int=0) {
        self.coins = coins
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.coins = try container.decode(Int.self, forKey: .coins)
    }
    
    internal func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.coins, forKey: .coins)
    }
}

// MARK: Constants
let PLAY_MODE_HINT_COST = 5
let DAILY_MODE_HINT_COST = 5


// MARK: Public Methods
func updateRewardsOnLevelComplete(rewards: Rewards) {
    rewards.coins += 1
}

func purchase(rewards: Rewards, cost: Int) -> Bool {
    if rewards.coins >= cost {
        rewards.coins = rewards.coins - cost
        return true
    }
    return false
}
