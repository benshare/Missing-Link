//
//  UpdateDailyPuzzle.swift
//  Missing Link
//
//  Created by Benjamin Share on 7/5/20.
//  Copyright © 2020 Benjamin Share. All rights reserved.
//

import Foundation
import AWSDynamoDB

func updateDailyPuzzle() {
    if APP_USER_TYPE == .maintenance {
        updateDailyPuzzleNoCheck()
    }
}

private func updateDailyPuzzleNoCheck() {
    do {
        let uploadString = try String(contentsOf: URL(fileURLWithPath: DAILY_PUZZLE_NEXT_UPLOAD_PATH)).components(separatedBy: .newlines).first!
        let mostRecentUploadDate = DATE_FORMATTER.date(from: uploadString) ?? DATE_FORMATTER.date(from: "2020-01-01")!
        
        let generationString = try String(contentsOf: URL(fileURLWithPath: DAILY_PUZZLE_MOST_RECENT_GENERATION_PATH)).components(separatedBy: .newlines).first!
        let mostRecentGenerationDate = DATE_FORMATTER.date(from: generationString)!
        
        var start = mostRecentUploadDate
        while start <= mostRecentGenerationDate {
            for offset in 0...6 {
                let newDate = Calendar.current.date(byAdding: .day, value: offset, to: start)!
                let newUrl = URL(fileURLWithPath: DAILY_PUZZLE_PATH + DATE_FORMATTER.string(from: newDate))
                do {
                    let fileAsString = try String(contentsOf: newUrl)
                    let lines = fileAsString.components(separatedBy: .newlines)
                    for line in lines {
                        let words = line.components(separatedBy: " - ")
                        if words.count != 3 {
                            print("Wrong line count for line \(line)")
                            continue
                        }
                        let wordsInPuzzleOrder = [words[0], words[2], words[1]]
                        let puzzle = Puzzle(words: wordsInPuzzleOrder)
                        postDailyPuzzle(puzzle: puzzle, date: newDate)
                    }
                } catch {
                    print("Error while reading daily puzzle data for date \(newDate)")
                }
            }
            start = Calendar.current.date(byAdding: .day, value: 7, to: start)!
        }
        do {
            try DATE_FORMATTER.string(from: start).write(to: URL(fileURLWithPath: DAILY_PUZZLE_NEXT_UPLOAD_PATH), atomically: false, encoding: .utf8)
        } catch {
            print("Couldn't update most recent upload date")
        }
        
    } catch {
        print("Error reading info about most recent updates for daily puzzle data")
    }
}
