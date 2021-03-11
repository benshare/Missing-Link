//
//  PuzzleUtil.swift
//  Missing Link
//
//  Created by Benjamin Share on 11/9/20.
//  Copyright © 2020 Benjamin Share. All rights reserved.
//

let MAX_LETTERS_IN_LINK = 12

import Foundation

func hintLetterToShow(level: PuzzleLevel, answer: String) -> Int {
    return (level.getPuzzle()!.first().count * level.getPuzzle()!.last().count + level.currentPuzzle()) % answer.count
}
