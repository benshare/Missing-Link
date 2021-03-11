//
//  HomePageViewController.swift
//  Missing Link
//
//  Created by Benjamin Share on 9/2/19.
//  Copyright © 2019 Benjamin Share. All rights reserved.
//

import UIKit

class HomePageViewController: UIViewController {
    //MARK: Properties
    
    public var loggedInUser: LoggedInUser!
    public var shouldDisplayTutorialAlert: Bool = false
    
    // Formatting
    private var layout: HomePageViewLayout!
    
    // MARK: Outlets
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var dailyButton: UIButton!
    @IBOutlet weak var leaderboardButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var feedbackButton: UIBarButtonItem!
    
    // MARK: Initialization
    override func viewDidLoad() {
        super.viewDidLoad()

        layout = HomePageViewLayout(welcomeLabel: welcomeLabel, usernameLabel: usernameLabel, playButton: playButton, dailyButton: dailyButton, leaderboardButton: leaderboardButton, accountButton: moreButton, username: loggedInUser.isGuest ? "Guest" : loggedInUser.user.username)
        layout.configureConstraints(view: view)
        layout.setCoinsAndStreakLabels(coins: loggedInUser.user.rewards.coins, streak: loggedInUser.user.data.dailyData.streak)
        
        moreButton.addTarget(self, action: #selector(openMoreMenu), for: .touchUpInside)
        redrawScene()
        
        if shouldDisplayTutorialAlert {
            let alert = tutorialAlert(controller: self, actions: [
                UIAlertAction(title: "Yes", style: .default, handler: {
                    action in
                    self.dismiss(animated: true, completion: nil)
                    self.performSegue(withIdentifier: "viewTutorialPage", sender: self)
                }),
                UIAlertAction(title: "Maybe Later", style: .default, handler: {
                    action in
                    self.dismiss(animated: true, completion: nil)
                })
            ])
            self.present(alert, animated: true, completion: {
                alert.view.superview?.isUserInteractionEnabled = true
                alert.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
            })
        }
    }
    
    // MARK: UI
    private func redrawScene() {
        layout.activateConstraints(isPortrait: orientationIsPortrait())
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        redrawScene()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "playButton":
            let dest = segue.destination as! PackSelectionCollectionViewController
            dest.loggedInUser = loggedInUser
        case "dailyButton":
            let dest = segue.destination as! DailyPuzzleViewController
            dest.loggedInUser = loggedInUser
        case "leaderboardButton":
            let dest = segue.destination as! LeaderboardTableViewController
            dest.loggedInUser = loggedInUser
        case "viewAccountPage":
            let dest = segue.destination as! AccountViewController
            dest.loggedInUser = loggedInUser
        case "viewTutorialPage":
            let dest = segue.destination as! TutorialViewController
            dest.loggedInUser = loggedInUser
        case "viewCreditsPage":
            let dest = segue.destination as! CreditsViewController
            dest.loggedInUser = loggedInUser
        case "feedbackButton":
            let dest = segue.destination as! FeedbackViewController
            dest.loggedInUser = loggedInUser
            dest.source = .home
        default:
            fatalError("Unknown segue from home page")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if self.isMovingFromParent {
            if !loggedInUser.isGuest {
                clearRememberedUser()
                syncUserProgress()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        layout.setCoinsAndStreakLabels(coins: loggedInUser.user.rewards.coins, streak: loggedInUser.user.data.dailyData.streak)
    }
    
    @IBAction func unwindToHomePage(segue: UIStoryboardSegue) {
        if !(segue.source is DailyPuzzleViewController || segue.source is FeedbackViewController) {
            print("Unexpected source for DailyPuzzleViewController: \(segue.source)")
        }
    }
    
    // MARK: More Menu
    @objc func openMoreMenu() {
        
        let alert = sheetWithActions(controller: self, actions: [
            UIAlertAction(title: "Account Info", style: .default, handler: {
                action in
                self.dismiss(animated: true, completion: nil)
                self.performSegue(withIdentifier: "viewAccountPage", sender: self)
            }),
            UIAlertAction(title: "Tutorial", style: .default, handler: {
                action in
                self.dismiss(animated: true, completion: nil)
                self.performSegue(withIdentifier: "viewTutorialPage", sender: self)
            }),
            UIAlertAction(title: "Credits", style: .default, handler: {
                action in
                self.dismiss(animated: true, completion: nil)
                self.performSegue(withIdentifier: "viewCreditsPage", sender: self)
            }),
            UIAlertAction(title: "Back", style: .cancel, handler: {
                action in
                self.dismiss(animated: true, completion: nil)
            })
        ])
        self.present(alert, animated: true, completion: {
            alert.view.superview?.isUserInteractionEnabled = true
            alert.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
        })
    }
    
    @objc func alertControllerBackgroundTapped() {
        self.dismiss(animated: true, completion: nil)
    }
}
