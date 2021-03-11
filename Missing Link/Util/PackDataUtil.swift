//
//  PackDataUtil.swift
//  Missing Link
//
//  Created by Benjamin Share on 6/11/20.
//  Copyright © 2020 Benjamin Share. All rights reserved.
//

import Foundation


let PACK_DBD_GROUP = DispatchGroup()
let PACK_VARIABLES_GROUP = DispatchGroup()

// Protected by PACK_VARIABLES_GROUP

var VISIBLE_SECTIONS = VisibleSectionsWrapper()
// Map from id -> pack
var AGGREGATE_PACK_INFO = [Int: PuzzlePack]()

// Default unlocked packs is the first in each section
func getDefaultUnlockedPackNames() -> [String] {
    PACK_VARIABLES_GROUP.wait()
    return VISIBLE_SECTIONS.map.values.map( { $0[0].name } )
}

func getDefaultUnlockedPackIds() -> [Int] {
    PACK_VARIABLES_GROUP.wait()
    return VISIBLE_SECTIONS.map.values.map( { $0[0].id } )
}

let PLAY_MODE_PUZZLE_PATH = "Maintenance/Data/PlayPuzzles/"
let PLAY_MODE_MOST_RECENT_UPLOAD_PATH = PLAY_MODE_PUZZLE_PATH + "mostRecentUploadDate"
let PLAY_MODE_GENERATION_FN = "generationDate"
let PLAY_MODE_PACK_ID_FN = "packId"
