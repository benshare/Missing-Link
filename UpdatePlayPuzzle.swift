//
//  UpdatePlayPuzzle.swift
//  Missing Link
//
//  Created by Benjamin Share on 7/26/20.
//  Copyright © 2020 Benjamin Share. All rights reserved.
//

import Foundation

let sections = getSectionMap()

private func getSectionMap() -> [Int: String] {
    var s = [Int: String]()
    for i in 1...6 {
        s[i] = "Animals"
    }
    for i in 7...9 {
        s[i] = "Colors"
    }
    for i in 10...11 {
        s[i] = "Body"
    }
    return s
}

//private func getSections() -> PackInfoWrapper {
//    var s = [String: [(Int, String)]]()
//    s["Animals"] = [(Int, String)]()
//    s["Colors"] = [(Int, String)]()
//    s["Body"] = [(Int, String)]()
//    return s
//}

func updatePlayPuzzles() {
    if APP_USER_TYPE == .maintenance {
        updatePlayPuzzlesNoCheck()
        updatePuzzleVisibility()
    }
}

private func updatePlayPuzzlesNoCheck() {
    print("Updating Play puzzles")
    do {
        let uploadString = try String(contentsOf: URL(fileURLWithPath: PLAY_MODE_MOST_RECENT_UPLOAD_PATH)).components(separatedBy: .newlines).first!
        let mostRecentUploadDate: Date = (DATE_FORMATTER.date(from: uploadString) ?? DATE_FORMATTER.date(from: "2020-01-01"))!
        
        let manager = FileManager.default
        let playUrl = URL(fileURLWithPath: PLAY_MODE_PUZZLE_PATH)
        do {
            let dirUrls = try manager.contentsOfDirectory(at: playUrl, includingPropertiesForKeys: nil)
            var packs = [(PuzzlePack, Int)]()
            for dirUrl in dirUrls {
                let isDirectory = (try? dirUrl.resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory ?? false
                if !isDirectory {
                    continue
                }
                var levels = [PuzzleLevel]()
                var level_num = 1
                let packName = dirUrl.lastPathComponent
                let generationFN = PLAY_MODE_PUZZLE_PATH + packName + "/" + PLAY_MODE_GENERATION_FN
                let generationString = try String(contentsOf: URL(fileURLWithPath: generationFN)).components(separatedBy: .newlines).first!
                let generationDate = DATE_FORMATTER.date(from: generationString)!
                print("Generation date: \(generationDate)\nUpload date: \(mostRecentUploadDate)\nSkipping: \(generationDate < mostRecentUploadDate)")
                if generationDate < mostRecentUploadDate {
                    continue
                }
                while true {
                    let puzzle_fn = PLAY_MODE_PUZZLE_PATH + packName + "/" + String(level_num)
                    if !manager.fileExists(atPath: puzzle_fn) {
                        break
                    }
                    let fileAsString = try String(contentsOf: URL(fileURLWithPath: puzzle_fn))
                    let lines = fileAsString.components(separatedBy: .newlines)
                    
                    var level_strings = [[String]]()
                    for line in lines {
                        if line == "" {
                            continue
                        }
                        let words = line.components(separatedBy: " - ")
                        if words.count != 3 {
                            print("Wrong word count for line \(line)")
                            continue
                        }
                        let wordsInPuzzleOrder = [words[0], words[2], words[1]]
                        level_strings.append(wordsInPuzzleOrder)
                    }
                    level_num += 1
                    levels.append(PuzzleLevel(db_id: 0, puzzle_data: level_strings))
                }
                let packIdFN = PLAY_MODE_PUZZLE_PATH + packName + "/" + PLAY_MODE_PACK_ID_FN
                let packId = try Int(String(contentsOf: URL(fileURLWithPath: packIdFN)).components(separatedBy: .newlines).first!)!
                packs.append((PuzzlePack(data: levels, name: packName), packId))
            }
            do {
                try DATE_FORMATTER.string(from: Date()).write(to: URL(fileURLWithPath: PLAY_MODE_MOST_RECENT_UPLOAD_PATH), atomically: false, encoding: .utf8)
            } catch {
                print("Couldn't update most play mode recent upload date")
            }
        } catch {
            print("Error while enumerating files \(playUrl.path): \(error.localizedDescription)")
        }
    } catch {
        print("Error: couldn't read upload string")
    }
}

func updatePuzzleVisibility() {
    let manager = FileManager.default
    let playUrl = URL(fileURLWithPath: PLAY_MODE_PUZZLE_PATH)
    do {
        let dirUrls = try manager.contentsOfDirectory(at: playUrl, includingPropertiesForKeys: nil)
        
        var idsAndNames = [(Int, String)]()
        for dirUrl in dirUrls {
            let isDirectory = (try? dirUrl.resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory ?? false
            if !isDirectory {
                continue
            }
            let packName = dirUrl.lastPathComponent
            let packIdFN = PLAY_MODE_PUZZLE_PATH + packName + "/" + PLAY_MODE_PACK_ID_FN
            
            let packId = try Int(String(contentsOf: URL(fileURLWithPath: packIdFN)).components(separatedBy: .newlines).first!)!
            idsAndNames.append((packId, packName))
        }
        idsAndNames.sort(by: { $0.0 < $1.0 })
        let sections = VisibleSectionsWrapper()
        let map = getSectionMap()
        for pack in idsAndNames {
            sections.addPack(section: map[pack.0]!, pack: pack)
        }
//        print("Sections:")
//        for k in sections.map.keys {
//            print("\n", k)
//            print(sections.map[k])
//        }
//        for _ in sections {
//            packSections.append([:])
//        }
        updateVisiblePackData(packs: sections)
        do {
            try DATE_FORMATTER.string(from: Date()).write(to: URL(fileURLWithPath: PLAY_MODE_MOST_RECENT_UPLOAD_PATH), atomically: false, encoding: .utf8)
        } catch {
            print("Couldn't update most play mode recent upload date")
        }
    } catch {
        print("Error while enumerating files \(playUrl.path): \(error.localizedDescription)")
    }
}
