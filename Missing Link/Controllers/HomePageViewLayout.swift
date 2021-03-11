//
//  HomePageViewLayout.swift
//  Missing Link
//
//  Created by Benjamin Share on 7/18/20.
//  Copyright © 2020 Benjamin Share. All rights reserved.
//

import Foundation
import UIKit

class HomePageViewLayout {
    // MARK: Properties
    
    // UI elements
    private var welcomeLabel: UILabel!
    private var usernameLabel: UILabel!
    private var playButton: UIButton!
    private var dailyButton: UIButton!
    private var leaderboardButton: UIButton!
    private var accountButton: UIButton!
    private var coinsLabel: UILabel?
    private var streakLabel: UILabel?
    
    // Constraint maps
    private var portraitHorizontalMap: [UIView: (CGFloat, CGFloat)]!
    private var portraitVerticalMap: [UIView: (CGFloat, CGFloat)]!
    private var landscapeHorizontalMap: [UIView: (CGFloat, CGFloat)]!
    private var landscapeVerticalMap: [UIView: (CGFloat, CGFloat)]!
    
    // Constraints
    private var portraitConstraints = [NSLayoutConstraint]()
    private var landscapeConstraints = [NSLayoutConstraint]()
    
    init(welcomeLabel: UILabel, usernameLabel: UILabel, playButton: UIButton, dailyButton: UIButton, leaderboardButton: UIButton, accountButton: UIButton, username: String) {
        self.welcomeLabel = welcomeLabel
        self.usernameLabel = usernameLabel
        self.playButton = playButton
        self.dailyButton = dailyButton
        self.leaderboardButton = leaderboardButton
        self.accountButton = accountButton
        
        let attributedText = NSMutableAttributedString(string: "Logged in as ")
        attributedText.append(NSMutableAttributedString(string: username, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20)]))
        usernameLabel.attributedText = attributedText
        
        setTextToDefaults(labels: [welcomeLabel, usernameLabel])
        setButtonsToDefaults(buttons: [playButton, dailyButton, leaderboardButton, accountButton], resize: false)

        var topBuffer: CGFloat = 0.25
        var buttonSpacing: CGFloat = (1 - topBuffer) / 4
        var buttonHeight: CGFloat = buttonSpacing / 3
        
        // Portrait
        portraitVerticalMap = [
            welcomeLabel: (0.1, 0.05),
            usernameLabel: (0.05, 0.12),
            playButton: (buttonHeight, topBuffer + buttonHeight * 1.5),
            dailyButton: (buttonHeight, topBuffer + buttonHeight * 1.5 + buttonSpacing),
            leaderboardButton: (buttonHeight, topBuffer + buttonHeight * 1.5 + 2 * buttonSpacing),
            accountButton: (buttonHeight, topBuffer + buttonHeight * 1.5 + 3 * buttonSpacing),
        ]
        
        portraitHorizontalMap = [
            welcomeLabel: (0.9, 0.5),
            usernameLabel: (0.5, 0.5),
            playButton: (0.6, 0.5),
            dailyButton: (0.6, 0.5),
            leaderboardButton: (0.7, 0.5),
            accountButton: (0.6, 0.5),
        ]
        
        topBuffer = 0.4
        buttonSpacing = (1 - topBuffer) / 2
        buttonHeight = buttonSpacing / 3
        
        // Landscape
        landscapeVerticalMap = [
            welcomeLabel: (0.15, 0.1),
            usernameLabel: (0.1, 0.25),
            playButton: (buttonHeight, topBuffer + buttonHeight * 1.5),
            dailyButton: (buttonHeight, topBuffer + buttonHeight * 1.5 + buttonSpacing),
            leaderboardButton: (buttonHeight, topBuffer + buttonHeight * 1.5),
            accountButton: (buttonHeight, topBuffer + buttonHeight * 1.5 + buttonSpacing),
        ]
        
        landscapeHorizontalMap = [
            welcomeLabel: (0.7, 0.5),
            usernameLabel: (0.35, 0.5),
            playButton: (0.3, 0.25),
            dailyButton: (0.4, 0.25),
            leaderboardButton: (0.4, 0.75),
            accountButton: (0.3, 0.75),
        ]
    }
    
    // MARK: Constraints
    
    func configureConstraints(view: UIView)  {
        let margins = view.layoutMarginsGuide
        view.backgroundColor = globalBackgroundColor()
        
        portraitConstraints += getFullHorizontalConstraints(leftAnchor: margins.leftAnchor, rightAnchor: margins.rightAnchor, horizontalConstraintMap: portraitHorizontalMap, parentView: view)
        portraitConstraints += getFullVerticalConstraints(topAnchor: margins.topAnchor, bottomAnchor: margins.bottomAnchor, verticalConstraintMap: portraitVerticalMap, parentView: view)
        
        landscapeConstraints += getFullHorizontalConstraints(leftAnchor: margins.leftAnchor, rightAnchor: margins.rightAnchor, horizontalConstraintMap: landscapeHorizontalMap, parentView: view)
        landscapeConstraints += getFullVerticalConstraints(topAnchor: margins.topAnchor, bottomAnchor: margins.bottomAnchor, verticalConstraintMap: landscapeVerticalMap, parentView: view)
        
        let (coins, coinPortrait, coinLandscape) = addCoinsToView(view: view, portrait: ((0.08, 0.25), (0.25, 0.13)), landscape: ((0.15, 0.3), (0.15, 0.1)))
        let (streak, streakPortrait, streakLandscape) = addStreakToView(view: view, portrait: ((0.08, 0.25), (0.25, 0.87)), landscape: ((0.15, 0.3), (0.15, 0.9)))
        portraitConstraints += coinPortrait + streakPortrait
        landscapeConstraints += coinLandscape + streakLandscape
        coinsLabel = coins
        streakLabel = streak
    }
    
    func activateConstraints(isPortrait: Bool) {
        if isPortrait {
            NSLayoutConstraint.deactivate(landscapeConstraints)
            NSLayoutConstraint.activate(portraitConstraints)
        } else {
            NSLayoutConstraint.deactivate(portraitConstraints)
            NSLayoutConstraint.activate(landscapeConstraints)
        }
    }
    
    // MARK: Other UI
    func setCoinsAndStreakLabels(coins: Int, streak: Int) {
        coinsLabel?.text = String(coins)
        streakLabel?.text = String(streak)
    }
}
