//
//  AccountViewController.swift
//  Missing Link
//
//  Created by Benjamin Share on 7/19/20.
//  Copyright © 2020 Benjamin Share. All rights reserved.
//

import Foundation
import UIKit

class AccountViewController: UIViewController {
    
    // MARK: Properties
    public var loggedInUser: LoggedInUser?
    
    // Configurable elements
    private var submitButton: UIButton!
    private var submitQuestion: UIButton!
    private var leaderboardButton: UIButton!
    private var leaderboardQuestion: UIButton!
    private var collectButton: UIButton!
    private var collectQuestion: UIButton!
    private var coinsButton: UIButton!
    
    // Formatting
    private var layout: AccountViewLayout!
    private var orientationIsPortrait: Bool = true
    
    
    // MARK: Outlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIStackView!
    @IBOutlet weak var feedbackButton: UIBarButtonItem!
    
    // MARK: Initialization
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureElements()

        layout = AccountViewLayout(scrollView: scrollView, contentView: contentView, submitButton: submitButton, submitQuestion: submitQuestion, leaderboardButton: leaderboardButton, leaderboardQuestion: leaderboardQuestion, collectButton: collectButton, collectQuestion: collectQuestion, coinsButton: coinsButton)
        layout.configureView(margins: view.layoutMarginsGuide, user: loggedInUser!.user, metadata: loggedInUser!.user.data.playData.metadata, isGuest: loggedInUser!.isGuest)
        orientationIsPortrait = UIDevice.current.orientation.isPortrait || UIDevice.current.orientation.isFlat
        redrawScene()
    }
    
    func configureElements() {
        submitButton = UIButton()
        submitButton.addTarget(self, action: #selector(toggleSubmit), for: .touchDown)
        submitQuestion = UIButton()
        submitQuestion.addTarget(self, action: #selector(showSubmitInfo), for: .touchDown)
        leaderboardButton = UIButton()
        leaderboardButton.addTarget(self, action: #selector(toggleLeaderboard), for: .touchDown)
        leaderboardQuestion = UIButton()
        leaderboardQuestion.addTarget(self, action: #selector(showLeaderboardInfo), for: .touchDown)
        collectButton = UIButton()
        collectButton.addTarget(self, action: #selector(toggleCollect), for: .touchDown)
        collectQuestion = UIButton()
        collectQuestion.addTarget(self, action: #selector(showCollectInfo), for: .touchDown)
        coinsButton = UIButton()
        coinsButton.addTarget(self, action: #selector(showComingSoonAlert), for: .touchDown)
    }
    
    // MARK: UI
    private func redrawScene() {
        layout.activateConstraints(orientationIsPortrait: orientationIsPortrait)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if orientationIsPortrait != UIDevice.current.orientation.isPortrait || UIDevice.current.orientation.isFlat {
            orientationIsPortrait = !orientationIsPortrait
            redrawScene()
        }
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch (segue.identifier ?? "") {
        case "feedbackButton":
            let dest = segue.destination as! FeedbackViewController
            dest.loggedInUser = loggedInUser
            dest.source = .account
        default:
            fatalError("Unexpected Segue Identifier; \(segue.identifier ?? "unknown")")
        }
    }
    
    @IBAction func unwindToAccountPage(segue: UIStoryboardSegue) {
        if !(segue.source is FeedbackViewController) {
            print("Unexpected source for AccountViewController: \(segue.source)")
        }
    }
    
    // MARK: Button clicks
    @objc private func toggleSubmit() {
        loggedInUser!.user.preferences.submitDifficultyFeedback = !loggedInUser!.user.preferences.submitDifficultyFeedback
        layout.setSubmit(checked: loggedInUser!.user.preferences.submitDifficultyFeedback)
        updateSyncedUserPreferences(preferences: loggedInUser!.user.preferences)
    }
    
    @objc private func toggleLeaderboard() {
        loggedInUser!.user.preferences.showOnLeaderboard = !loggedInUser!.user.preferences.showOnLeaderboard
        layout.setLeaderboard(checked: loggedInUser!.user.preferences.showOnLeaderboard)
        updateSyncedUserPreferences(preferences: loggedInUser!.user.preferences)
    }

    @objc private func toggleCollect() {
        loggedInUser!.user.preferences.allowMetadataCollection = !loggedInUser!.user.preferences.allowMetadataCollection
        layout.setCollect(checked: loggedInUser!.user.preferences.allowMetadataCollection)
        updateSyncedUserPreferences(preferences: loggedInUser!.user.preferences)
    }
    
    @objc private func showSubmitInfo() {
        let alert = alertWithContent(controller: self, content: "This controls whether or not to ask you for a difficulty rating after you complete a puzzle in Play Mode. This is really helpful for us to gauge puzzle difficulty!")
        self.present(alert, animated: true, completion: {
            alert.view.superview?.isUserInteractionEnabled = true
            alert.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
        })
    }
    
    @objc private func showLeaderboardInfo() {
        let alert = alertWithContent(controller: self, content: "This controls whether or not to show your scores on other people's leaderboards. You'll still be able to see your scores relative to others if you uncheck, but they won't be able to see yours.")
        self.present(alert, animated: true, completion: {
            alert.view.superview?.isUserInteractionEnabled = true
            alert.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
        })
    }
    
    @objc private func showCollectInfo() {
        let alert = alertWithContent(controller: self, content: "If checked, we'll record info about your puzzle progress--number of puzzles completed, average time to complete, etc.--so we can show you cool statistics about it later. If you'd prefer not to have it recorded, feel free to uncheck.")
        self.present(alert, animated: true, completion: {
            alert.view.superview?.isUserInteractionEnabled = true
            alert.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
        })
    }
    
    @objc private func showComingSoonAlert() {
        let alert = UIAlertController(title: "Coming soon!", message: "", preferredStyle: .alert)
        self.present(alert, animated: true, completion: {
            alert.view.superview?.isUserInteractionEnabled = true
            alert.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
        })
    }
    
    @objc func alertControllerBackgroundTapped() {
        self.dismiss(animated: true, completion: nil)
    }
}
