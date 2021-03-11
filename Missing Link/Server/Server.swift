//
//  Server.swift
//  Missing Link
//
//  Created by Benjamin Share on 12/1/19.
//  Copyright © 2019 Benjamin Share. All rights reserved.
//
// functions with "fetch" or "update" prefix modify a global and are async
// functions with "get" prefix return the AWS entry(s) and are synchronous

import Foundation
import AWSCore
import AWSDynamoDB


private let ddbMapper = AWSDynamoDBObjectMapper.default()
private let decoder = JSONDecoder()

// MARK: General Functions

// TODO
func checkForConnection() -> Bool {
    return true
}

func getScanForUser(table: AWSDynamoDBObjectModel.Type, user: User?, bySort: Bool=false) -> AWSTask<AWSDynamoDBPaginatedOutput> {
    let scanExpression = AWSDynamoDBScanExpression()
    if user == nil {
        return ddbMapper.scan(table, expression: scanExpression)
    }
    scanExpression.filterExpression = "#user = :user"
    scanExpression.expressionAttributeNames = ["#user": bySort ? "username_sort" : "username"]
    scanExpression.expressionAttributeValues = [":user": bySort ? user!.username.uppercased() : user!.username]
    return ddbMapper.scan(table, expression: scanExpression)
}

// TODO: Convert to limit to top N, make to sort in fetch
func getScanForTopNUsers(table: AWSDynamoDBObjectModel.Type, n: Int, keyword: String = "score") -> AWSTask<AWSDynamoDBPaginatedOutput> {
    let scanExpression = AWSDynamoDBScanExpression()
    scanExpression.filterExpression = "#" + keyword + " > :" + keyword
    scanExpression.expressionAttributeNames = ["#" + keyword: keyword]
    scanExpression.expressionAttributeValues = [":" + keyword: 0]
    return ddbMapper.scan(table, expression: scanExpression)
}

func getScanForMatchingKeys(table: AWSDynamoDBObjectModel.Type, keyName: String, matchingKeys: Set<String>) -> AWSTask<AWSDynamoDBPaginatedOutput> {
    let scanExpression = AWSDynamoDBScanExpression()
    
    var filterExpression = ""
    var expressionAttributeValues: [String: String] = [:]
    var ind = 0
    for str in matchingKeys {
        if ind > 0 {
            filterExpression.append(" OR ")
        }
        let indVal = ":val" + String(ind)
        filterExpression.append("#key = " + indVal)
        expressionAttributeValues.updateValue(str, forKey: indVal)
        ind += 1
    }
    
    scanExpression.filterExpression = filterExpression
    scanExpression.expressionAttributeNames = ["#key": keyName]
    scanExpression.expressionAttributeValues = expressionAttributeValues
    return ddbMapper.scan(table, expression: scanExpression)
}


// MARK: Accounts
// Owned tables: UserAccounts

func createAccountForUser(user: User) -> Bool {
    var success = true
    ACCOUNT_DBD_GROUP.enter()
    DispatchQueue.global(qos: .background).async {
        print("Creating new user account: \(user.username)")
        if getLoginForUser(user: user).found {
            print("Error: user \(user.username) already has an account.")
            success = false
            ACCOUNT_DBD_GROUP.leave()
            return
        }
        let newItem: UserAccounts = UserAccounts(username: user.username, hash: user.passwordHash)
        ddbMapper.save(newItem, completionHandler: {(error: Error?) -> Void in
            if let error = error {
                print("Amazon DBD Save Error while creating account: \(error)")
                print("Item: \(newItem)\n")
            }
        })
        print("Finished creating new user account: \(user.username)\n")
        ACCOUNT_DBD_GROUP.leave()
    }
    ACCOUNT_DBD_GROUP.wait()
    return success
}

func getLoginForUser(user: User) -> AccountInfo {
    var userAccount: AccountInfo = AccountInfo(username: "", hash: "", found: false)
    
    let group1 = DispatchGroup()
    group1.enter()

    let userScan = getScanForUser(table: UserAccounts.self, user: user, bySort: true)
    userScan.continueWith(block: { (task: AWSTask) -> Any? in
        if let error = task.error as NSError? {
            print("The user account request failed. Error: \(error)")
        }
        else if let paginatedOutput = task.result {
            let asList = paginatedOutput.items as [AWSDynamoDBObjectModel]
            if !asList.isEmpty {
                let entry = asList[0] as! UserAccounts
                userAccount.found = true
                userAccount.username = entry._username!
                userAccount.hash = entry._hash!
            }
        }
        group1.leave()
        return nil
    })
    group1.wait()
    return userAccount
}


// MARK: User Progress
// Owned tables: UserProgress

func updateProgressForUser(user: User) {
    PROGRESS_DBD_GROUP.enter()
    DispatchQueue.global(qos: .background).async {
        print("Updating user progress")
        
        let group1 = DispatchGroup()
        group1.enter()
        let newItem: UserProgress = UserProgress(user: user)
        ddbMapper.save(newItem, completionHandler: {(error: Error?) -> Void in
            if let error = error {
                print("Amazon DBD Save Error while updating progress: \(error)")
                print("Item: \(newItem)\n")
            }
            group1.leave()
        })
        group1.wait()
        PROGRESS_DBD_GROUP.leave()
        print("User progress updated\n")
    }
}


func getFullProgressForUser(user: User) -> (AppProgress, UserDataStruct, Rewards, UserPreferencesStruct) {
    PROGRESS_VARIABLES_GROUP.enter()
    PROGRESS_DBD_GROUP.wait()
    print("Fetching full progress for user \(user.username)")
    var progress: AppProgress?
    var data: UserDataStruct?
    var rewards: Rewards?
    var preferences: UserPreferencesStruct?
    
    let group1 = DispatchGroup()
    group1.enter()
    
    let userScan = getScanForUser(table: UserProgress.self, user: user)
    userScan.continueWith(block: { (task: AWSTask) -> Any? in
        if let error = task.error as NSError? {
            print("The user account request failed. Error: \(error)")
        }
        else if let paginatedOutput = task.result {
            let asList = paginatedOutput.items as [AWSDynamoDBObjectModel]
            if !asList.isEmpty {
                let entry = asList[0] as! UserProgress
                progress = try! decoder.decode(AppProgress.self, from: (entry._appProgress?.data(using: .utf8))!)
                data = try! decoder.decode(UserDataStruct.self, from: (entry._userData?.data(using: .utf8))!)
                rewards = try! decoder.decode(Rewards.self, from: (entry._rewards?.data(using: .utf8))!)
                preferences = try! decoder.decode(UserPreferencesStruct.self, from: (entry._preferences?.data(using: .utf8))!)
            } else {
                print("Didn't get any results from UserProgress query for \(user.username)")
            }
        }
        group1.leave()
        return nil
    })
    group1.wait()
    print("Progress fetched for user \(user.username)\n")
    PROGRESS_VARIABLES_GROUP.leave()
    return (progress!, data!, rewards!, preferences!)
}

// MARK: Pack Data
// Owned tables: PackData, VisiblePacks

func updatePackData(pack: PuzzlePack, packId: Int) {
    DispatchQueue.global(qos: .background).async {
        PACK_DBD_GROUP.enter()
        
        let group1 = DispatchGroup()
        group1.enter()
        
        let newItem: PackData = PackData(pack: pack, id: packId)
        ddbMapper.save(newItem, completionHandler: {(error: Error?) -> Void in
            if let error = error {
                print("Amazon DBD Save Error while updating pack data: \(error)")
                print("Item: \(newItem)\n")
                fatalError()
            }
            group1.leave()
        })
        group1.wait()
        print("Pack data updated\n")
        PACK_DBD_GROUP.leave()
    }
}

func fetchDataForPacks(packs: [String]) {
    PACK_VARIABLES_GROUP.enter()
    DispatchQueue.global(qos: .background).async {
        PACK_DBD_GROUP.wait()
        print("Fetching data for packs:")
        for pack in packs {
            print("\t\(pack)")
        }

        let group1 = DispatchGroup()
        group1.enter()

        let packScan = getScanForMatchingKeys(table: PackData.self, keyName: "packName", matchingKeys: Set(packs))
        packScan.continueWith(block: { (task: AWSTask) -> Any? in
            if let error = task.error as NSError? {
                print("Pack data request failed. Error: \(error)")
            }
            else if let paginatedOutput = task.result {
                let asList = paginatedOutput.items as [AWSDynamoDBObjectModel]
                if !asList.isEmpty {
                    for entry in asList as! [PackData] {
//                    let entry = asList[0] as! PackData
                    let dataWrapper = try! decoder.decode([PuzzleLevelServerWrapper].self, from: (entry._data?.data(using: .utf8))!)
                    let data = dataWrapper.map( { PuzzleLevel(wrapper: $0) })
                    AGGREGATE_PACK_INFO.updateValue(PuzzlePack(data: data, name: entry._packName!), forKey: Int(truncating: entry._packId!))
                    }
                }
            }
            group1.leave()
            return nil
        })
        group1.wait()
        print("Data fetched for \(packs.count) pack(s)")
        PACK_VARIABLES_GROUP.leave()
    }
}

//func fetchAggregatePackData(progresses: [String: PackProgress]) {
//    PACK_VARIABLES_GROUP.enter()
//    DispatchQueue.global(qos: .background).async {
//        PACK_DBD_GROUP.wait()
//        print("Fetching pack data")
//        var packsToFetch = Set<String>()
//        for item in progresses {
//            if item.value.status == .completed || item.value.status == .unlocked {
//                packsToFetch.insert(item.key)
//            }
//        }
//        if packsToFetch.isEmpty {
//            print("Defaulting to base pack")
//            packsToFetch.insert("Animals 1")
//        }
//
//        let group1 = DispatchGroup()
//        group1.enter()
//
//        let packScan = getScanForMatchingKeys(table: PackData.self, keyName: "packName", matchingKeys: packsToFetch)
//        packScan.continueWith(block: { (task: AWSTask) -> Any? in
//            if let error = task.error as NSError? {
//                print("Pack data request failed. Error: \(error)")
//            }
//            else if let paginatedOutput = task.result {
//                let asList = paginatedOutput.items as [AWSDynamoDBObjectModel]
//                if !asList.isEmpty {
//                    for entry in (asList as! [PackData]) {
//                        let dataWrapper = try! decoder.decode([PuzzleLevelServerWrapper].self, from: (entry._data?.data(using: .utf8))!)
//                        let data = dataWrapper.map( { PuzzleLevel(wrapper: $0) })
//                        AGGREGATE_PACK_INFO.updateValue(PuzzlePack(data: data, name: entry._packName!), forKey: Int(truncating: entry._packId!))
//                    }
//                }
//            }
//            group1.leave()
//            return nil
//        })
//        group1.wait()
//        print("Pack data fetched\n")
//        PACK_VARIABLES_GROUP.leave()
//    }
//}
//
//func fetchNewPack(packName: String) {
//    PACK_VARIABLES_GROUP.enter()
//    DispatchQueue.global(qos: .background).async {
//        PACK_DBD_GROUP.wait()
//        print("Fetching data for unlocked pack \(packName)")
//        var packsToFetch = Set<String>()
//        packsToFetch.insert(packName)
//
//        let group1 = DispatchGroup()
//        group1.enter()
//
//        let packScan = getScanForMatchingKeys(table: PackData.self, keyName: "packName", matchingKeys: packsToFetch)
//        packScan.continueWith(block: { (task: AWSTask) -> Any? in
//            if let error = task.error as NSError? {
//                print("Pack data request failed. Error: \(error)")
//            }
//            else if let paginatedOutput = task.result {
//                let asList = paginatedOutput.items as [AWSDynamoDBObjectModel]
//                if !asList.isEmpty {
//                    let entry = asList[0] as! PackData
//                    let dataWrapper = try! decoder.decode([PuzzleLevelServerWrapper].self, from: (entry._data?.data(using: .utf8))!)
//                    let data = dataWrapper.map( { PuzzleLevel(wrapper: $0) })
//                    AGGREGATE_PACK_INFO.updateValue(PuzzlePack(data: data, name: entry._packName!), forKey: Int(truncating: entry._packId!))
//                }
//            }
//            group1.leave()
//            return nil
//        })
//        group1.wait()
//        print("Data fetched for unlocked pack \(packName)\n")
//        PACK_VARIABLES_GROUP.leave()
//    }
//}

func updateVisiblePackData(packs: VisibleSectionsWrapper, visibility: String="general") {
    PACK_DBD_GROUP.enter()
    DispatchQueue.global(qos: .background).async {
        print("Updating visibility data")
        
        let combinedInfo = VisibleSectionsWrapper()
        
        let visibilityScan = getScanForMatchingKeys(table: VisiblePackInfo.self, keyName: "visibility", matchingKeys: Set<String>(arrayLiteral: visibility))
        visibilityScan.continueWith(block: { (task: AWSTask) -> Any? in
            if let error = task.error as NSError? {
                print("Visibility data request failed. Error: \(error)")
            }
            else if let paginatedOutput = task.result {
                let asList = paginatedOutput.items as [AWSDynamoDBObjectModel]
                if !asList.isEmpty {
                    let entry = asList[0] as! VisiblePackInfo
                    combinedInfo.map = (try! decoder.decode(VisibleSectionsWrapper.self, from: (entry._packInfo?.data(using: .utf8))!)).map
                }
            }
            return nil
        })
        
        for sectionName in packs.map.keys {
            var usedIds = Set<Int>()
            if !combinedInfo.map.keys.contains(sectionName) {
                combinedInfo.map[sectionName] = [VisiblePackWrapper]()
            } else {
                for entry in combinedInfo.map[sectionName]! {
                    usedIds.insert(entry.id)
                }
            }
            let entries = packs.map[sectionName]!
            for entry in entries {
                if usedIds.contains(entry.id) {
                    continue
                }
                combinedInfo.map[sectionName]?.append(entry)
            }
        }
        
        let group1 = DispatchGroup()
        group1.enter()
        
        let newItem: VisiblePackInfo = VisiblePackInfo(packInfo: combinedInfo)
        ddbMapper.save(newItem, completionHandler: {(error: Error?) -> Void in
            if let error = error {
                print("Amazon DBD Save Error while updating visibility data: \(error)")
                print("Item: \(newItem)\n")
            }
            group1.leave()
        })
        group1.wait()
        print("Visibility data updated\n")
        PACK_DBD_GROUP.leave()
    }
}

func fetchVisiblePackData(visibility: String="general") {
    PACK_VARIABLES_GROUP.enter()
    DispatchQueue.global(qos: .background).async {
        PACK_DBD_GROUP.wait()
        if !VISIBLE_SECTIONS.map.isEmpty {
            print("Visible pack data already fetched, not sending new request.")
            PACK_VARIABLES_GROUP.leave()
            return
        }
        
        print("Fetching visibility data")

        let group1 = DispatchGroup()
        group1.enter()

        let visibilityScan = getScanForMatchingKeys(table: VisiblePackInfo.self, keyName: "visibility", matchingKeys: Set<String>(arrayLiteral: visibility))
        visibilityScan.continueWith(block: { (task: AWSTask) -> Any? in
            if let error = task.error as NSError? {
                print("Visibility data request failed. Error: \(error)")
            }
            else if let paginatedOutput = task.result {
                let asList = paginatedOutput.items as [AWSDynamoDBObjectModel]
                if !asList.isEmpty {
                    let entry = asList[0] as! VisiblePackInfo
                    VISIBLE_SECTIONS = try! decoder.decode(VisibleSectionsWrapper.self, from: (entry._packInfo?.data(using: .utf8))!)
//                    var map = [(Int, String)]()
//                    for i in 0...packIds.count-1 {
//                        map.append((packIds[i], packNames[i]))
//                    }
//                    VISIBLE_PACK_LIST = map.sorted(by: { $0.0 < $1.0})
                }
            }
            group1.leave()
            return nil
        })
        group1.wait()
        print("Visibility data fetched\n")
        PACK_VARIABLES_GROUP.leave()
    }
}


// MARK: Daily Puzzle Data
// Owned tables: DailyPuzzle

func fetchNewDailyPuzzleData() {
    DAILY_VARIABLES_GROUP.enter()
    DispatchQueue.global(qos: .background).async {
        print("Fetching daily puzzle data")
        let today = Date()
        
        let group1 = DispatchGroup()
        group1.enter()
        
        let dailyScan = getScanForMatchingKeys(table: DailyPuzzle.self, keyName: "date", matchingKeys: Set(arrayLiteral: DATE_FORMATTER.string(from: today)))
        dailyScan.continueWith(block: { (task: AWSTask) -> Any? in
            if let error = task.error as NSError? {
                  print("The top users request failed. Error: \(error)")
            }
            else if let paginatedOutput = task.result {
                if paginatedOutput.items.isEmpty {
                    print("Found no puzzles for this day--not updating daily puzzle")
                } else {
                    let puzzle = paginatedOutput.items[0] as! DailyPuzzle
                    let puzzleAsData = puzzle._puzzle?.data(using: .utf8)
                    DAILY_PUZZLE = try! decoder.decode(Puzzle.self, from: puzzleAsData!)
                    LAST_DAY_PUZZLE_SYNCED = today
                }
            }
            group1.leave()
            return nil
        })
        
        group1.wait()
        DAILY_VARIABLES_GROUP.leave()
    }
    DAILY_VARIABLES_GROUP.wait()
    print("Daily puzzle data fetched\n")
}

// TODO: convert gets to synchronous
func getDailyPuzzleDataForDate(date: Date) -> Puzzle {
    DAILY_VARIABLES_GROUP.enter()
    var result: Puzzle?
    DispatchQueue.global(qos: .background).async {
        DAILY_DBD_GROUP.wait()
        print("Fetching daily puzzle data")
        
        let group1 = DispatchGroup()
        group1.enter()
        
        let dailyScan = getScanForMatchingKeys(table: DailyPuzzle.self, keyName: "date", matchingKeys: Set(arrayLiteral: DATE_FORMATTER.string(from: date)))
        dailyScan.continueWith(block: { (task: AWSTask) -> Any? in
            if let error = task.error as NSError? {
                  print("The top users request failed. Error: \(error)")
            }
            else if let paginatedOutput = task.result {
                let puzzle = paginatedOutput.items[0] as! DailyPuzzle
                let puzzleAsData = puzzle._puzzle?.data(using: .utf8)
                result = try! decoder.decode(Puzzle.self, from: puzzleAsData!)
            }
            group1.leave()
            return nil
        })
        
        group1.wait()
        DAILY_VARIABLES_GROUP.leave()
    }
    DAILY_VARIABLES_GROUP.wait()
    return result!
}

func postDailyPuzzle(puzzle: Puzzle, date: Date) {
    DAILY_DBD_GROUP.enter()
    DispatchQueue.global(qos: .background).async {
        print("Posting daily puzzle for \(date)")
        let newItem = DailyPuzzle(date: date, puzzle: puzzle)
        ddbMapper.save(newItem, completionHandler: {(error: Error?) -> Void in
            if let error = error {
                print("Amazon DBD Save Error while posting puzzle for day \(Date()): \(error)")
                print("Item:\n\(newItem)")
            } else {
                print("Daily puzzle posted for \(date)")
            }
        })
        DAILY_DBD_GROUP.leave()
    }
}


// MARK: Leaderboard Data
// Owned tables: PlayLeaderboard, DailyLeaderboard, ContributionsLeaderboard

func fetchTopUsersLeaderboardData(maxRows: Int = MAX_LEADERBOARD_LENGTH) {
    LEADERBOARD_READY_GROUP.enter()
    DispatchQueue.global(qos: .background).async {
        print("Fetching top leaderboard data")
        var toSkip = Set<String>()
        // A little hacky: checks Play first, which has the data on whether or not to skip
        for which in LeaderboardUtil.stateToDatatype {
            var topUsersData: [LeaderboardOutput] = []
            let group1 = DispatchGroup()
            group1.enter()
            let topUsersScan = which.0 == .daily ? getScanForTopNUsers(table: which.1, n: maxRows, keyword: "longestStreak") : getScanForTopNUsers(table: which.1, n: maxRows)
            topUsersScan.continueWith(block: { (task: AWSTask) -> Any? in
                if let error = task.error as NSError? {
                      print("The top users request failed. Error: \(error)")
                }
                else if let paginatedOutput = task.result {
                    var tmpData: [(NSNumber?, String?)] = []
                    for entry in paginatedOutput.items {
                        switch which.0 {
                        case .play:
                            let e = entry as! PlayLeaderboard
                            if e._showMe! as! Bool {
                                tmpData.append((e._score, e._username))
                            } else {
                                toSkip.insert(e._username!)
                            }
                        case .daily:
                            let e = entry as! DailyLeaderboard
                            if !toSkip.contains(e._username!) {
                                tmpData.append((e._streak, e._username))
                            }
                        case .contributions:
                            let e = entry as! ContributionsLeaderboard
                            if !toSkip.contains(e._username!) {
                                tmpData.append((e._totalScore, e._username))
                            }
                        }
                    }
                    tmpData.sort(by: { return Int(truncating: $0.0!) > Int(truncating: $1.0!) })
                    if !tmpData.isEmpty {
                        for rank in 0...min(maxRows, tmpData.count) - 1 {
                            topUsersData.append(LeaderboardOutput(rank: rank + 1, username: tmpData[rank].1!, score: tmpData[rank].0 as! Int))
                        }
                    }
                }
                group1.leave()
                return nil
            })
            
            group1.wait()
            TOP_USERS_LEADERBOARD_DATA[which.0] = LeaderboardTopUsersList(data: topUsersData)
        }
        print("Top leaderboard data fetched\n")
        LEADERBOARD_READY_GROUP.leave()
    }
}

func updateLeaderboardsForUser(user: User, which: LeaderboardState? = nil) {
    LEADERBOARD_READY_GROUP.enter()
    DispatchQueue.global(qos: .background).async {
        print("Updating leaderboard data for user \(user.username)\(which == nil ? "" : " for state \(which!)")")
        for pair in LeaderboardUtil.stateToDatatype {
            if which != nil && which != pair.0 {
                continue
            }
            switch pair.0 {
            case .play:
                let newItem = PlayLeaderboard(username: user.username, data: user.data.playData, showMe: user.preferences.showOnLeaderboard)
                ddbMapper.save(newItem, completionHandler: {(error: Error?) -> Void in
                    if let error = error {
                        print("Amazon DBD Save Error: \(error)")
                        print("Item:", newItem, "\n")
                    }
                })
            case .daily:
                let newItem = DailyLeaderboard(username: user.username, data: user.data.dailyData)
                ddbMapper.save(newItem, completionHandler: {(error: Error?) -> Void in
                    if let error = error {
                        print("Amazon DBD Save Error: \(error)")
                        print("Item:", newItem, "\n")
                    }
                })
            case .contributions:
                let newItem = ContributionsLeaderboard(username: user.username, data: user.data.contributionsData)
                ddbMapper.save(newItem, completionHandler: {(error: Error?) -> Void in
                    if let error = error {
                        print("Amazon DBD Save Error: \(error)")
                        print("Item:", newItem, "\n")
                    }
                })
            }
        }
        print("Leaderboard updated for user \(user.username)")
        LEADERBOARD_READY_GROUP.leave()
    }
}

func postUserFeedback(source: FeedbackSource, user: User, feedback: String) {
    DispatchQueue.global(qos: .background).async {
        print("Posting user feedback")
        let newItem = UserFeedback(source: source, now: Date(), user: user, feedback: feedback)
        ddbMapper.save(newItem, completionHandler: {(error: Error?) -> Void in
            if let error = error {
                print("Amazon DBD Save Error while posting user feedback): \(error)")
                print("Item:\n\(newItem)")
            } else {
                print("User feedback posted")
            }
        })
    }
}


// MARK: Metadata

func postUserMetadata(metadata: PuzzleMetadata, user: User) {
    print("Posting metadata for user \(user.username): \(metadata)")
}
