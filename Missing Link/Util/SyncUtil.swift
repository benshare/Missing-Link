//
//  SyncUtil.swift
//  Missing Link
//
//  Created by Benjamin Share on 6/20/20.
//  Copyright © 2020 Benjamin Share. All rights reserved.
//

import Foundation

// OUTDATED
/* Pattern for synced user data:
 When user logs in, fetch user progress from DB (and possible remembered file). Update userToSync to equal this
 When any update to user's progress occurs, userToSync should be updated to reflect it
 When leaderboard data is required, leaderboard will first be recalculated from progress (TODO: change to happen at the time)
 When app exits, first leaderboard data will be updated, then DB set to synced user (as well as rememberedUser, if necessary
*/

private var userToSync: User?
private var lastSynced: User?
private var shouldRemember: Bool = false

func setUserToSync(user: User, remember: Bool) {
    userToSync = user
    shouldRemember = remember
}

func updateSyncedUserProgress(progress: AppProgress) {
    userToSync?.progress = progress
}

func updateSyncedUserData(playData: PlayData?=nil, dailyData: DailyData?=nil, contributionsData: ContributionsData?=nil) {
    if playData != nil {
        userToSync?.data.playData = playData!
    }
    if dailyData != nil {
        userToSync?.data.dailyData = dailyData!
    }
    if contributionsData != nil {
        userToSync?.data.contributionsData = contributionsData!
    }
}

func updateSyncedUserRewards(rewards: Rewards) {
    userToSync?.rewards = rewards
}

func updateSyncedUserPreferences(preferences: UserPreferencesStruct) {
    userToSync?.preferences = preferences
}

func syncUserProgress() {
    if userToSync == nil {
        return
    }
//    if userToSync == lastSynced {
//        return
//    }
    updateProgressForUser(user: userToSync!)
    updateLeaderboardsForUser(user: userToSync!)
    lastSynced = userToSync
    
    if shouldRemember {
        writeUserToDefaults(loggedInUser: LoggedInUser(user: userToSync!, rememberMe: true))
    }
}
