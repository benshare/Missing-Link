//
//  AccountViewLayout.swift
//  Missing Link
//
//  Created by Benjamin Share on 7/19/20.
//  Copyright © 2020 Benjamin Share. All rights reserved.
//

import Foundation
import UIKit

class AccountViewLayout {
    // MARK: Properties
    
    // UI elements
    private var scrollView: UIScrollView
    private var contentView: UIStackView
    private var verticalBorders = [UIView]()
    private var horizontalBorders = [UIView]()
    private var submitButton: UIButton
    private var submitQuestion: UIButton
    private var leaderboardButton: UIButton
    private var leaderboardQuestion: UIButton
    private var collectButton: UIButton
    private var collectQuestion: UIButton
    private var coinsButton: UIButton
    
    // Constants
    private let emptyCheckbox = UIImage(named: "EmptyCheckbox")
    private let fullCheckbox = UIImage(named: "FullCheckbox")
    private let questionMark = UIImage(named: "Question")
    
    // Values to set
    private var contentWidth: CGFloat!
    
    // Constraint maps
    private var portraitHorizontalMap: [UIView: (CGFloat, CGFloat)]!
    private var portraitVerticalMap: [UIView: (CGFloat, CGFloat)]!
    private var landscapeHorizontalMap: [UIView: (CGFloat, CGFloat)]!
    private var landscapeVerticalMap: [UIView: (CGFloat, CGFloat)]!
    
    // Constraints
    private var portraitConstraints = [NSLayoutConstraint]()
    private var landscapeConstraints = [NSLayoutConstraint]()
    
    // MARK: Initialization
    init(scrollView: UIScrollView, contentView: UIStackView, submitButton: UIButton, submitQuestion: UIButton, leaderboardButton: UIButton, leaderboardQuestion: UIButton, collectButton: UIButton, collectQuestion: UIButton, coinsButton: UIButton) {
        self.scrollView = scrollView
        self.contentView = contentView
        self.submitButton = submitButton
        self.submitQuestion = submitQuestion
        self.leaderboardButton = leaderboardButton
        self.leaderboardQuestion = leaderboardQuestion
        self.collectButton = collectButton
        self.collectQuestion = collectQuestion
        self.coinsButton = coinsButton
    }
    
    func configureView(margins: UILayoutGuide, user: User, metadata: PuzzleMetadata, isGuest: Bool) {
        contentWidth = min(margins.layoutFrame.height, margins.layoutFrame.width) * 0.7
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.topAnchor.constraint(equalTo: margins.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: margins.bottomAnchor).isActive = true
        scrollView.leftAnchor.constraint(equalTo: margins.leftAnchor).isActive = true
        scrollView.rightAnchor.constraint(equalTo: margins.rightAnchor).isActive = true
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        contentView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        
        contentView.alignment = .leading
        
        addSections(user: user, metadata: metadata, isGuest: isGuest)
    }
    
    func activateConstraints(orientationIsPortrait: Bool) {
        if orientationIsPortrait {
            NSLayoutConstraint.deactivate(landscapeConstraints)
            NSLayoutConstraint.activate(portraitConstraints)
            contentView.axis = .vertical
            for border in horizontalBorders {
                border.isHidden = true
            }
            for border in verticalBorders {
                border.isHidden = false
            }
        } else {
            NSLayoutConstraint.deactivate(portraitConstraints)
            NSLayoutConstraint.activate(landscapeConstraints)
            contentView.axis = .horizontal
            for border in verticalBorders {
                border.isHidden = true
            }
            for border in horizontalBorders {
                border.isHidden = false
            }
        }
    }
    
    // MARK: Sections
    private func addSections(user: User, metadata: PuzzleMetadata, isGuest: Bool) {
        // Title section
        addTextSection(title: isGuest ? "Account Info for guest user" : "Account Info for \(user.username)", body: "", titleFont: 40, bodyFont: 15)
        
        // Preferences (Submits difficulty feedback, shown on leaderboard, allows metadata collection)
        addPreferencesSection(preferences: user.preferences)
        
        // Rewards (coins, color schemes). Place for purchases
        addRewardsSection(coins: user.rewards.coins)
        
        // Coming soon
        addTextSection(title: "More info coming soon!", body: "", titleFont: 30, bodyFont: 15)
        
        // Play Mode info (num puzzles completed, num levels completed, packs completed, average time per puzzle, most puzzles in one day)
        
        // Daily Mode info (daily puzzles completed, current streak, longest streak (and when))
        
        // Contributions (feedback submitted)
    }
    
    private func addTextSection(title: String, body: String, titleFont: CGFloat, bodyFont: CGFloat) {
        let titlePortraitHeight = 1.5 * titleFont * linesForLabel(font: titleFont, numChars: title.count, width: contentWidth / 0.7)
        let titleLandscapeHeight = 1.5 * titleFont * linesForLabel(font: titleFont, numChars: title.count, width: contentWidth)
        let bodyPortraitHeight = 1.5 * bodyFont * linesForLabel(font: bodyFont, numChars: body.count, width: contentWidth / 0.7)
        
        let newSection = UIView()
        contentView.addArrangedWithColor(subview: newSection)
        newSection.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        newSection.addSubview(titleLabel)
        titleLabel.text = title
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraint(equalTo: newSection.topAnchor).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: newSection.leftAnchor, constant: 10).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: newSection.rightAnchor, constant: -10).isActive = true
        titleLabel.font = .boldSystemFont(ofSize: titleFont)
        portraitConstraints.append(titleLabel.heightAnchor.constraint(equalToConstant: titlePortraitHeight))
        landscapeConstraints.append(titleLabel.heightAnchor.constraint(equalToConstant: titleLandscapeHeight))
        
        let bodyLabel = UILabel()
        newSection.addSubview(bodyLabel)
        bodyLabel.text = body
        bodyLabel.numberOfLines = 0
        bodyLabel.font = .systemFont(ofSize: bodyFont)
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        bodyLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor).isActive = true
        bodyLabel.leftAnchor.constraint(equalTo: newSection.leftAnchor, constant: 10).isActive = true
        bodyLabel.rightAnchor.constraint(equalTo: newSection.rightAnchor, constant: -10).isActive = true
        portraitConstraints.append(bodyLabel.heightAnchor.constraint(equalToConstant: bodyPortraitHeight))
        landscapeConstraints.append(bodyLabel.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor))
        
        portraitConstraints += [
            newSection.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            newSection.heightAnchor.constraint(equalToConstant: titlePortraitHeight + bodyPortraitHeight)
        ]
        landscapeConstraints += [
            newSection.widthAnchor.constraint(equalToConstant: contentWidth),
            newSection.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
        ]
        
        verticalBorders += addBorders(view: newSection, bottom: true, left: true, right: true)
        horizontalBorders += addBorders(view: newSection, right: true)
    }
    
    private func addPreferencesSection(preferences: UserPreferencesStruct) {
        let newSection = UIView()
        contentView.addArrangedWithColor(subview: newSection)
        newSection.translatesAutoresizingMaskIntoConstraints = false
        
        // Title
        let title = "User Preferences"
        let titleFont: CGFloat = 30
        
        let titlePortraitHeight = 1.5 * titleFont * linesForLabel(font: titleFont, numChars: title.count, width: contentWidth / 0.7)
        let titleLandscapeHeight = 1.5 * titleFont * linesForLabel(font: titleFont, numChars: title.count, width: contentWidth)
        
        let titleLabel = UILabel()
        newSection.addSubview(titleLabel)
        titleLabel.text = title
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraint(equalTo: newSection.topAnchor).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: newSection.leftAnchor, constant: 10).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: newSection.rightAnchor, constant: -10).isActive = true
        titleLabel.font = .boldSystemFont(ofSize: titleFont)
        portraitConstraints.append(titleLabel.heightAnchor.constraint(equalToConstant: titlePortraitHeight))
        landscapeConstraints.append(titleLabel.heightAnchor.constraint(equalToConstant: titleLandscapeHeight))
        
        // Submit difficulty feedback
        let submitView = UIView()
        let submitHeight: CGFloat = 50
        newSection.addSubview(submitView)
        submitView.translatesAutoresizingMaskIntoConstraints = false
        submitView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor).isActive = true
        submitView.leftAnchor.constraint(equalTo: newSection.leftAnchor, constant: 10).isActive = true
        submitView.heightAnchor.constraint(equalToConstant: submitHeight).isActive = true
        submitView.rightAnchor.constraint(equalTo: newSection.rightAnchor, constant: -10).isActive = true

        let submitLabel = UILabel()
        submitView.addSubview(submitLabel)
        submitLabel.translatesAutoresizingMaskIntoConstraints = false
        submitLabel.numberOfLines = 0
        submitLabel.text = "Submit puzzle difficulty feedback:"
        submitLabel.font = .systemFont(ofSize: 15)

        submitView.addSubview(submitButton)
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        submitButton.setBackgroundImage(preferences.submitDifficultyFeedback ? fullCheckbox : emptyCheckbox, for: .normal)

        submitView.addSubview(submitQuestion)
        submitQuestion.translatesAutoresizingMaskIntoConstraints = false
        submitQuestion.setBackgroundImage(questionMark, for: .normal)

        var verticalMap: [UIView : (CGFloat, CGFloat)] = [
            submitLabel: (0.8, 0.4),
            submitButton: (0.3, 0.4),
            submitQuestion: (0.3, 0.4),
        ]
        NSLayoutConstraint.activate(getFullVerticalConstraints(topAnchor: submitView.topAnchor, bottomAnchor: submitView.bottomAnchor, verticalConstraintMap: verticalMap, parentView: submitView))
        
        var horizontalSpacingMap: [UIView: CGFloat] = [
            submitLabel: 0.3,
            submitButton: 0.55,
            submitQuestion: 0.9,
        ]
        portraitConstraints += getHorizontalSpacingConstraints(leftAnchor: submitView.leftAnchor, rightAnchor: submitView.rightAnchor, spacingMap: horizontalSpacingMap, parentView: submitView)
        
        horizontalSpacingMap[submitButton] = 0.67
        horizontalSpacingMap[submitQuestion] = 0.92
        landscapeConstraints += getHorizontalSpacingConstraints(leftAnchor: submitView.leftAnchor, rightAnchor: submitView.rightAnchor, spacingMap: horizontalSpacingMap, parentView: submitView)
        
        NSLayoutConstraint.activate([
            submitLabel.widthAnchor.constraint(equalTo: submitView.widthAnchor, multiplier: 0.6),
            submitButton.widthAnchor.constraint(equalTo: submitButton.heightAnchor),
            submitQuestion.widthAnchor.constraint(equalTo: submitQuestion.heightAnchor),
        ])
        
        // Shown on leaderboard
        let leaderboardView = UIView()
        let leaderboardHeight: CGFloat = 50
        newSection.addSubview(leaderboardView)
        leaderboardView.translatesAutoresizingMaskIntoConstraints = false
        leaderboardView.topAnchor.constraint(equalTo: submitView.bottomAnchor).isActive = true
        leaderboardView.leftAnchor.constraint(equalTo: newSection.leftAnchor, constant: 10).isActive = true
        leaderboardView.heightAnchor.constraint(equalToConstant: leaderboardHeight).isActive = true
        leaderboardView.rightAnchor.constraint(equalTo: newSection.rightAnchor, constant: -10).isActive = true

        let leaderboardLabel = UILabel()
        leaderboardView.addSubview(leaderboardLabel)
        leaderboardLabel.translatesAutoresizingMaskIntoConstraints = false
        leaderboardLabel.numberOfLines = 0
        leaderboardLabel.text = "Show me on the leaderboard:"
        leaderboardLabel.font = .systemFont(ofSize: 15)

        leaderboardView.addSubview(leaderboardButton)
        leaderboardButton.translatesAutoresizingMaskIntoConstraints = false
        leaderboardButton.setBackgroundImage(preferences.showOnLeaderboard ? fullCheckbox : emptyCheckbox, for: .normal)

        leaderboardView.addSubview(leaderboardQuestion)
        leaderboardQuestion.translatesAutoresizingMaskIntoConstraints = false
        leaderboardQuestion.setBackgroundImage(questionMark, for: .normal)

        verticalMap = [
            leaderboardLabel: (0.8, 0.4),
            leaderboardButton: (0.3, 0.4),
            leaderboardQuestion: (0.3, 0.4),
        ]
        NSLayoutConstraint.activate(getFullVerticalConstraints(topAnchor: leaderboardView.topAnchor, bottomAnchor: leaderboardView.bottomAnchor, verticalConstraintMap: verticalMap, parentView: leaderboardView))

        horizontalSpacingMap = [
            leaderboardLabel: 0.3,
            leaderboardButton: 0.55,
            leaderboardQuestion: 0.9,
        ]
        portraitConstraints += getHorizontalSpacingConstraints(leftAnchor: leaderboardView.leftAnchor, rightAnchor: leaderboardView.rightAnchor, spacingMap: horizontalSpacingMap, parentView: leaderboardView)
        
        horizontalSpacingMap[leaderboardButton] = 0.67
        horizontalSpacingMap[leaderboardQuestion] = 0.92
        landscapeConstraints += getHorizontalSpacingConstraints(leftAnchor: leaderboardView.leftAnchor, rightAnchor: leaderboardView.rightAnchor, spacingMap: horizontalSpacingMap, parentView: leaderboardView)

        NSLayoutConstraint.activate([
            leaderboardLabel.widthAnchor.constraint(equalTo: leaderboardView.widthAnchor, multiplier: 0.6),
            leaderboardButton.widthAnchor.constraint(equalTo: leaderboardButton.heightAnchor),
            leaderboardQuestion.widthAnchor.constraint(equalTo: leaderboardQuestion.heightAnchor),
        ])
        
        // Allows metadata collection
        let metadataView = UIView()
        let metadataHeight: CGFloat = 0
        if true {
//            metadataHeight = 50
            newSection.addSubview(metadataView)
            metadataView.translatesAutoresizingMaskIntoConstraints = false
            metadataView.topAnchor.constraint(equalTo: leaderboardView.bottomAnchor).isActive = true
            metadataView.leftAnchor.constraint(equalTo: newSection.leftAnchor, constant: 10).isActive = true
            metadataView.heightAnchor.constraint(equalToConstant: metadataHeight).isActive = true
            metadataView.rightAnchor.constraint(equalTo: newSection.rightAnchor, constant: -10).isActive = true

            let metadataLabel = UILabel()
            metadataView.addSubview(metadataLabel)
            metadataLabel.translatesAutoresizingMaskIntoConstraints = false
            metadataLabel.numberOfLines = 0
            metadataLabel.text = "Collect info about my app usage:"
            metadataLabel.font = .systemFont(ofSize: 15)

            metadataView.addSubview(collectButton)
            collectButton.translatesAutoresizingMaskIntoConstraints = false
            collectButton.setBackgroundImage(preferences.allowMetadataCollection ? fullCheckbox : emptyCheckbox, for: .normal)

            metadataView.addSubview(collectQuestion)
            collectQuestion.translatesAutoresizingMaskIntoConstraints = false
            collectQuestion.setBackgroundImage(questionMark, for: .normal)

            verticalMap = [
                metadataLabel: (0.8, 0.4),
                collectButton: (0.3, 0.4),
                collectQuestion: (0.3, 0.4),
            ]
            NSLayoutConstraint.activate(getFullVerticalConstraints(topAnchor: metadataView.topAnchor, bottomAnchor: metadataView.bottomAnchor, verticalConstraintMap: verticalMap, parentView: metadataView))

            horizontalSpacingMap = [
                metadataLabel: 0.25,
                collectButton: 0.55,
                collectQuestion: 0.9,
            ]
            portraitConstraints += getHorizontalSpacingConstraints(leftAnchor: metadataView.leftAnchor, rightAnchor: metadataView.rightAnchor, spacingMap: horizontalSpacingMap, parentView: metadataView)
            
            horizontalSpacingMap[collectButton] = 0.67
            horizontalSpacingMap[collectQuestion] = 0.92
            landscapeConstraints += getHorizontalSpacingConstraints(leftAnchor: metadataView.leftAnchor, rightAnchor: metadataView.rightAnchor, spacingMap: horizontalSpacingMap, parentView: metadataView)
            
            NSLayoutConstraint.activate([
                metadataLabel.widthAnchor.constraint(equalTo: metadataView.widthAnchor, multiplier: 0.5),
                collectButton.widthAnchor.constraint(equalTo: collectButton.heightAnchor),
                collectQuestion.widthAnchor.constraint(equalTo: collectQuestion.heightAnchor),
            ])
        }
        
        // Section constraints
        portraitConstraints += [
            newSection.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            newSection.heightAnchor.constraint(equalToConstant: titlePortraitHeight + submitHeight + leaderboardHeight + metadataHeight)
        ]
        landscapeConstraints += [
            newSection.widthAnchor.constraint(equalToConstant: contentWidth),
            newSection.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
        ]
        
        verticalBorders += addBorders(view: newSection, bottom: true, left: true, right: true)
        horizontalBorders += addBorders(view: newSection, right: true)
    }
    
    private func addRewardsSection(coins: Int) {
        let newSection = UIView()
        contentView.addArrangedWithColor(subview: newSection)
        newSection.translatesAutoresizingMaskIntoConstraints = false
        
        // Title
        let title = "Rewards"
        let titleFont: CGFloat = 30
        
        let titlePortraitHeight = 1.5 * titleFont * linesForLabel(font: titleFont, numChars: title.count, width: contentWidth / 0.7)
        let titleLandscapeHeight = 1.5 * titleFont * linesForLabel(font: titleFont, numChars: title.count, width: contentWidth)
        
        let titleLabel = UILabel()
        newSection.addSubview(titleLabel)
        titleLabel.text = title
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraint(equalTo: newSection.topAnchor).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: newSection.leftAnchor, constant: 10).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: newSection.rightAnchor, constant: -10).isActive = true
        titleLabel.font = .boldSystemFont(ofSize: titleFont)
        portraitConstraints.append(titleLabel.heightAnchor.constraint(equalToConstant: titlePortraitHeight))
        landscapeConstraints.append(titleLabel.heightAnchor.constraint(equalToConstant: titleLandscapeHeight))
        
        // Coins
        let coinsView = UIView()
        let coinsHeight: CGFloat = 50
        newSection.addSubview(coinsView)
        coinsView.translatesAutoresizingMaskIntoConstraints = false
        coinsView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor).isActive = true
        coinsView.leftAnchor.constraint(equalTo: newSection.leftAnchor, constant: 10).isActive = true
        coinsView.heightAnchor.constraint(equalToConstant: coinsHeight).isActive = true
        coinsView.rightAnchor.constraint(equalTo: newSection.rightAnchor, constant: -10).isActive = true

        let coinsLabel = UILabel()
        coinsView.addSubview(coinsLabel)
        coinsLabel.translatesAutoresizingMaskIntoConstraints = false
        coinsLabel.numberOfLines = 0
        coinsLabel.text = "You currently have \(coins) coins."
        coinsLabel.font = .systemFont(ofSize: 15)

        coinsView.addSubview(coinsButton)
        coinsButton.translatesAutoresizingMaskIntoConstraints = false
        coinsButton.setTitle("Get More!", for: .normal)
        coinsButton.backgroundColor = .systemYellow

        var verticalMap: [UIView : (CGFloat, CGFloat)] = [
            coinsLabel: (0.8, 0.4),
            coinsButton: (0.6, 0.4),
        ]
        NSLayoutConstraint.activate(getFullVerticalConstraints(topAnchor: coinsView.topAnchor, bottomAnchor: coinsView.bottomAnchor, verticalConstraintMap: verticalMap, parentView: coinsView))
        
        var horizontalMap: [UIView: (CGFloat, CGFloat)] = [
            coinsLabel: (0.5, 0.25),
        ]
        NSLayoutConstraint.activate(getFullHorizontalConstraints(leftAnchor: coinsView.leftAnchor, rightAnchor: coinsView.rightAnchor, horizontalConstraintMap: horizontalMap, parentView: coinsView))
        NSLayoutConstraint.activate([coinsButton.widthAnchor.constraint(equalTo: coinsButton.heightAnchor, multiplier: 3)] + getHorizontalSpacingConstraints(leftAnchor: coinsView.leftAnchor, rightAnchor: coinsView.rightAnchor, spacingMap: [coinsButton: 0.75], parentView: coinsView))

        
        // Additional perks
        let perksView = UIView()
        let perksHeight: CGFloat = 70
        let perksSpacing: CGFloat = 50
        newSection.addSubview(perksView)
        perksView.translatesAutoresizingMaskIntoConstraints = false
        perksView.topAnchor.constraint(equalTo: coinsView.bottomAnchor, constant: perksSpacing).isActive = true
        perksView.leftAnchor.constraint(equalTo: newSection.leftAnchor, constant: 10).isActive = true
        perksView.heightAnchor.constraint(equalToConstant: perksHeight).isActive = true
        perksView.rightAnchor.constraint(equalTo: newSection.rightAnchor, constant: -10).isActive = true

        let perksLabel = UILabel()
        perksView.addSubview(perksLabel)
        perksLabel.translatesAutoresizingMaskIntoConstraints = false
        perksLabel.numberOfLines = 0
        perksLabel.text = "More rewards coming soon!"
        perksLabel.font = .italicSystemFont(ofSize: 18)
        perksLabel.textAlignment = .center

        verticalMap = [
            perksLabel: (1, 0.5),
        ]
        NSLayoutConstraint.activate(getFullVerticalConstraints(topAnchor: perksView.topAnchor, bottomAnchor: perksView.bottomAnchor, verticalConstraintMap: verticalMap, parentView: perksView))
        horizontalMap = [
            perksLabel: (1, 0.5),
        ]
        NSLayoutConstraint.activate(getFullHorizontalConstraints(leftAnchor: perksView.leftAnchor, rightAnchor: perksView.rightAnchor, horizontalConstraintMap: horizontalMap, parentView: perksView))
        
        // Section constraints
        portraitConstraints += [
            newSection.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            newSection.heightAnchor.constraint(equalToConstant: titlePortraitHeight + coinsHeight + perksHeight + perksSpacing)
        ]
        landscapeConstraints += [
            newSection.widthAnchor.constraint(equalToConstant: contentWidth),
            newSection.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
        ]
        
        verticalBorders += addBorders(view: newSection, bottom: true, left: true, right: true)
        horizontalBorders += addBorders(view: newSection, right: true)
    }

    // MARK: Buttons
    func setSubmit(checked: Bool) {
        submitButton.setBackgroundImage(checked ? fullCheckbox : emptyCheckbox, for: .normal)
    }
    
    func setLeaderboard(checked: Bool) {
        leaderboardButton.setBackgroundImage(checked ? fullCheckbox : emptyCheckbox, for: .normal)
    }
    
    func setCollect(checked: Bool) {
        collectButton.setBackgroundImage(checked ? fullCheckbox : emptyCheckbox, for: .normal)
    }
}


// MARK: Utility functions

func linesForLabel(font: CGFloat, text: String, width: CGFloat) -> CGFloat {
    let total = font * CGFloat(text.count) * 0.45
    let newLines = text.split(separator: "\n").count - 1
    return total / width + CGFloat(newLines) * 0.8 + 1
}

func linesForLabel(font: CGFloat, numChars: Int, width: CGFloat) -> CGFloat {
    let total = font * CGFloat(numChars) * 0.45
    return total / width + 1
}

extension UIStackView {
    func addArrangedWithColor(subview: UIView) {
        if self.arrangedSubviews.count % 2 == 1 {
            if #available(iOS 13.0, *) {
                subview.backgroundColor = .systemGray2
            } else {
                subview.backgroundColor = .lightGray
            }
        }
        self.addArrangedSubview(subview)
    }
}
