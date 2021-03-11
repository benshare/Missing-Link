//
//  FeedbackUtil.swift
//  Missing Link
//
//  Created by Benjamin Share on 7/19/20.
//  Copyright © 2020 Benjamin Share. All rights reserved.
//

import Foundation

func setFeedbackDateFormat() {
    DATE_FORMATTER.dateFormat = "yyyy-MM-dd HH:mm:ss"
}

public enum FeedbackSource {
    case
        // Page sources
        login, home, feedback, packSelection, levelSelection, puzzle, dailyPuzzle, leaderboard, account, credits, tutorial, newSolution
}

public let feedbackSourceData: [FeedbackSource: String] = [
    .login: "Log In Page",
    .home: "Home Page",
    .feedback: "Feedback Page",
    .packSelection: "Pack Selection Page",
    .levelSelection: "Level Selection Page",
    .puzzle: "Puzzle Page",
    .dailyPuzzle: "Daily Puzzle Page",
    .leaderboard: "Leaderboard Page",
    .account: "Account Page",
    .credits: "Credits",
    .tutorial: "Tutorial",
    .newSolution: "New Solution",
]
