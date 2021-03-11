//
//  LeaderboardTableViewController.swift
//  Missing Link
//
//  Created by Benjamin Share on 11/24/19.
//  Copyright © 2019 Benjamin Share. All rights reserved.
//

import UIKit
import AWSCore
import AWSDynamoDB

private let cellIdentifier = "LeaderboardTableViewCell"
private let headerIdentifier = "LeaderboardHeaderViewCell"
private let tabNames = [
    LeaderboardState.play,
    LeaderboardState.daily,
    LeaderboardState.contributions
]

enum UserLeaderboardPresence {
    case inTop, belowTop, notFound
}

public class LeaderboardEntry {
    var username: String
    var score: Int
    var presence: UserLeaderboardPresence
    
    init(username: String, score: Int, presence: UserLeaderboardPresence) {
        self.username = username
        self.score = score
        self.presence = presence
    }
}

class LeaderboardTableViewController: UITableViewController {
    // MARK: Private Variables
    private var cells: [UITableViewCell] = []
    private var currentLeaderboardList: LeaderboardTopUsersList = LeaderboardTopUsersList(data: [])
    private var currentUserLeaderboardEntry: LeaderboardEntry?
    
    // MARK: Public Variables
    var loggedInUser: LoggedInUser?
    var leaderboardState: LeaderboardState = .play
    
    // MARK: Outlets
    @IBOutlet weak var feedbackButton: UIBarButtonItem!
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(LeaderboardHeaderViewCell.self, forCellReuseIdentifier: headerIdentifier)
        tableView.register(LeaderboardTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        
        LEADERBOARD_READY_GROUP.wait()
        displayLeaderboardData()
    }
    
    //TODO: Change this to header
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < 0 {
            if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) {
                cell.frame.origin.y = scrollView.contentOffset.y + cell.frame.height * 0.7
            }
        }
    }
        
    // MARK: UICollectionViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // TODO: Remove once contributions are handled for leaderboard
        if leaderboardState == .contributions {
            return 2
        }
        
        if TOP_USERS_LEADERBOARD_DATA[leaderboardState] == nil {
            return 0
        }
        // Additional rows are: 1 for header, optional 2 for user entry and row above it, and then one row below all entries
        let additionalRows = currentUserLeaderboardEntry!.presence == .belowTop ? 4 : 2
        return currentLeaderboardList.data.count + additionalRows
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // TODO: convert to use header instead of hack.
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: headerIdentifier, for: indexPath) as! LeaderboardHeaderViewCell
            cell.parentTable = self
            cell.configureCell()
            cells.append(cell)
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! LeaderboardTableViewCell
        cells.append(cell)
        
        // TODO: Remove once contributions are handled for leaderboard
        if leaderboardState == .contributions {
            cell.rankLabel.text = "--"
            cell.usernameLabel.text = "Coming Soon!"
            cell.usernameLabel.adjustsFontSizeToFitWidth = true
            cell.scoreLabel.text = "--"
            return cell
        }
        
        // Schema is:
        // If the user is in the top OR not found for the leaderboard, display the max number of rows from the top, with a blank "..." row added at the bottom
        // If the user is not in the top but is found for the leaderboard, display the maximum number of rows from the top minus two, add a blank row, then the user's entry, then another blank row below
        switch currentUserLeaderboardEntry!.presence {
        case .inTop:
            switch indexPath.row {
            case self.currentLeaderboardList.data.count + 1:
                cell.configureBlankCell()
            default:
                let user = self.currentLeaderboardList.data[indexPath.row - 1]
                cell.configureCell(entry: LeaderboardOutput(rank: user.rank, username: user.username, score: user.score), isLoggedInUser: loggedInUser?.user.username == user.username)
            }
        case .notFound:
            switch indexPath.row {
            case self.currentLeaderboardList.data.count + 1:
                cell.configureBlankCell()
            default:
                let user = self.currentLeaderboardList.data[indexPath.row - 1]
                cell.configureCell(entry: LeaderboardOutput(rank: user.rank, username: user.username, score: user.score), isLoggedInUser: loggedInUser?.user.username == user.username)
            }
        case .belowTop:
            switch indexPath.row {
            // User ranking row
            case self.currentLeaderboardList.data.count + 2:
                cell.configureCell(entry: LeaderboardOutput(rank: -1, username: currentUserLeaderboardEntry!.username, score: currentUserLeaderboardEntry!.score), isLoggedInUser: true)
            // Blank lines above and below user ranking row
            case self.currentLeaderboardList.data.count + 1, self.currentLeaderboardList.data.count + 3:
                cell.configureBlankCell()
            default:
                let user = self.currentLeaderboardList.data[indexPath.row - 1]
                cell.configureCell(entry: LeaderboardOutput(rank: user.rank, username: user.username, score: user.score), isLoggedInUser: false)
            }
        }
        return cell
    }
    
    func displayLeaderboardData() {
        self.currentLeaderboardList =  TOP_USERS_LEADERBOARD_DATA[leaderboardState]!!
        
        let score: Int?
        switch leaderboardState {
        case .play:
            score = loggedInUser?.user.data.playData.score
        case .daily:
            score = loggedInUser?.user.data.dailyData.longestStreak
        case .contributions:
            score = loggedInUser?.user.data.contributionsData.score
            
        }

        if score == nil || score == 0 || (loggedInUser?.isGuest)! {
            self.currentUserLeaderboardEntry = LeaderboardEntry(username: (loggedInUser?.user.username)!, score: score!, presence: .notFound)
        } else {
            if score! > currentLeaderboardList.minScore || currentLeaderboardList.data.count < MAX_LEADERBOARD_LENGTH {
                self.currentUserLeaderboardEntry = LeaderboardEntry(username: (loggedInUser?.user.username)!, score: score!, presence: .inTop)
                insertUserEntryIntoTop(aboveMin: score! > currentLeaderboardList.minScore)
            } else {
                self.currentUserLeaderboardEntry = LeaderboardEntry(username: (loggedInUser?.user.username)!, score: score!, presence: .belowTop)
            }
        }
        
        cells.removeAll()
        tableView.reloadData()
    }
    
    func insertUserEntryIntoTop(aboveMin: Bool) {
        // This function is called when the user a) Has a valid non-zero score and b) either their score is above the minimum score of the leaderboard and/or the leaderboard is below the max leaderboard display length (and thus we should show them at the bottom anyway)
        let username = (self.currentUserLeaderboardEntry?.username)!
        let score = (self.currentUserLeaderboardEntry?.score)!
        
        // Case 1: the leaderboard is empty. Return a leaderboard consisting only of the user's entry
        if currentLeaderboardList.data.isEmpty {
            currentLeaderboardList.data.append(LeaderboardOutput(rank: 1, username: username, score: score))
            return
        }
        
        var found = false
        var index = 0
        for i in 0...currentLeaderboardList.data.count - 1 {
            let entry = currentLeaderboardList.data[i]
            if entry.username == loggedInUser?.user.username {
                found = true
                index = i
                break
            }
        }
        
        if found {
            if currentLeaderboardList.data[index].score == score {
                // Case 2: the user is listed in the leaderboard, and the score is the same as the local version. In this case, nothing needs to be done
                return
            }
            // Case 3: the user is listed in the leaderboard, and the score is not the same as the local score. Since the local copy can only be more up-to-date, we treat it as the source of truth. For now, our solution is to remove the existing entry and then fall through to the case where they do not have an entry
            currentLeaderboardList.data.remove(at: index)
        }
        
        if !aboveMin || currentLeaderboardList.data.isEmpty {
            // Case 4: they should simply be placed at the bottom
            currentLeaderboardList.data.append(LeaderboardOutput(rank: currentLeaderboardList.data.count + 1, username: username, score: score))
            return
        }
        
        // Case 5: find the appropriate spot for them
        for i in 0...currentLeaderboardList.data.count - 1 {
            if score > currentLeaderboardList.data[i].score {
                currentLeaderboardList.data.insert(LeaderboardOutput(rank: i + 1, username: username, score: score), at: i)
                for j in i+1...currentLeaderboardList.data.count - 1 {
                    currentLeaderboardList.data[j].rank = currentLeaderboardList.data[j].rank + 1
                }
                break
            }
        }
        
        // Check if this has pushed the list above the max length
        if currentLeaderboardList.data.count > MAX_LEADERBOARD_LENGTH {
            _ = currentLeaderboardList.data.popLast()
            currentLeaderboardList.minScore = (currentLeaderboardList.data.last?.score)!
        }
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch (segue.identifier ?? "") {
        case "feedbackButton":
            let dest = segue.destination as! FeedbackViewController
            dest.loggedInUser = loggedInUser
            dest.source = .leaderboard
        default:
            fatalError("Unexpected Segue Identifier; \(segue.identifier ?? "unknown")")
        }
    }
    
    @IBAction func unwindToLeaderboardPage(segue: UIStoryboardSegue) {
        if !(segue.source is FeedbackViewController) {
            print("Unexpected source for LeaderboardTableViewController: \(segue.source)")
        }
    }
}
