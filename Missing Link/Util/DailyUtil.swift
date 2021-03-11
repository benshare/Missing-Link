//
//  DailyUtil.swift
//  Missing Link
//
//  Created by Benjamin Share on 7/3/20.
//  Copyright © 2020 Benjamin Share. All rights reserved.
//

import Foundation

let DAILY_DBD_GROUP = DispatchGroup()
let DAILY_VARIABLES_GROUP = DispatchGroup()

// Protected by DAILY_VARIABLES_GROUP
var DAILY_PUZZLE = Puzzle(words: ["", "", ""])
var LAST_DAY_PUZZLE_SYNCED: Date?

let DATE_FORMATTER = DateFormatter()

func setDailyPuzzleDateFormat() {
    DATE_FORMATTER.dateFormat = "yyyy-MM-dd"
}

let DAILY_PUZZLE_PATH = "Maintenance/Data/DailyPuzzles/"
let DAILY_PUZZLE_NEXT_UPLOAD_PATH = DAILY_PUZZLE_PATH + "mostRecentUploadDate"
let DAILY_PUZZLE_MOST_RECENT_GENERATION_PATH = DAILY_PUZZLE_PATH + "mostRecentGenerationDate"
