//
//  ContributionsData.swift
//  Missing Link
//
//  Created by Benjamin Share on 12/5/20.
//  Copyright © 2020 Benjamin Share. All rights reserved.
//

import Foundation

class ContributionsData: Codable, Equatable {
    var score: Int
    var puzzlesSubmitted: Int
    var numBugReports: Int
    var numBonuses: Int
    
    static func == (lhs: ContributionsData, rhs: ContributionsData) -> Bool {
        return structComparisonFn(lhs: lhs, rhs: rhs)
    }
    
    init() {
        score = 0
        puzzlesSubmitted = 0
        numBugReports = 0
        numBonuses = 0
    }
    
    func getScore() -> Int {
        return score
    }
    
    func updateAfterSubmittingPuzzle() {
        puzzlesSubmitted += 1
    }
    
    func updateAfterSubmittingFeedback() {
        numBugReports += 1
    }
}
