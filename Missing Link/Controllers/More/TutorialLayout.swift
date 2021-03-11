//
//  TutorialLayout.swift
//  Missing Link
//
//  Created by Benjamin Share on 11/30/20.
//  Copyright © 2020 Benjamin Share. All rights reserved.
//

import Foundation
import UIKit

class TutorialLayout {
    // MARK: Properties
    
    // UI elements
    private var scrollView: UIScrollView
    private var contentView: UIStackView
    private var verticalBorders = [UIView]()
    private var horizontalBorders = [UIView]()
    
    // Values to set
    private var sectionFullWidth: CGFloat!
    
    // Constraints
    private var portraitConstraints = [NSLayoutConstraint]()
    private var landscapeConstraints = [NSLayoutConstraint]()
    
    init(scrollView: UIScrollView, contentView: UIStackView) {
        self.scrollView = scrollView
        self.contentView = contentView
    }
    
    func configureView(margins: UILayoutGuide) {
        sectionFullWidth = min(margins.layoutFrame.height, margins.layoutFrame.width)
        
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
        
        addSections()
    }
    
    // MARK: Sections
    private func addSections() {
        // Title section
        addTextSection(title: "Welcome to Missing Link!", body: "Animated tutorial *hopefully* coming soon", titleFont: 40, bodyFont: 15)
        
        // Account
        addTextSection(title: "Account", body: "You should have created a username and password. Use these to log in to the app on any device.\n\nYour password is case-sensitive, but your username is not. Your password is always encrypted before it's saved!", titleFont: 30, bodyFont: 15)
        
        // Puzzles
        addTextSection(title: "Puzzles", body: """
        The core of Missing Link is its puzzles! The main puzzle format is:

            First Word             _____            Second Word

        where the goal is to fill in the blank so that the first and second word each pairs with the middle word.

        For example, the solution for:

                    Ice                _____              Cheese

        is "Cream", because "Ice Cream" and "Cream Cheese" are both common word pairs. Links can be compound words, phrases, or even famous names!
        """, titleFont: 30, bodyFont: 15, sectionWidthToUse: 1.3)
        
        // Play Mode
        addTextSection(title: "Play Mode", body: """
        The main mode for solving puzzles is through Play Mode. In Play Mode, puzzles are organized into levels, which are grouped into packs.

        Packs will usually have some sort of theme hinted at by its name--see if you can figure it out. Complete a pack to unlock the next one!
        """, titleFont: 30, bodyFont: 15, sectionWidthToUse: 0.75)
        
        // Daily Mode
        addTextSection(title: "Daily Mode", body: "Each day, there will also be a special Daily Puzzle. These are similar to the Play Mode puzzles, but you can earn a streak by solving these!", titleFont: 30, bodyFont: 15)
        
        
        // Rewards
        addTextSection(title: "Rewards", body: "Whenever you solve a puzzle, you'll get a coin in reward. Use these to get hints in puzzles. More ways to get and spend coins coming soon.", titleFont: 30, bodyFont: 15)
        
        
        // Feedback
        addTextSection(title: "Feedback", body: """
        We'd love to hear any feedback you have about the app! You can submit any type of feedback by clicking the "Submit Feedback" button on the top right of the screen. Once we've reviewed the feedback, you might get a shout out or reward for it!

        There's also specific tools for submitting puzzle feedback. After each puzzle we'll ask you how difficult it was on a scale of 1-5. Let us know what you think so we can calibrate the puzzle's difficulty.

        Meanwhile, if you come up with a solution to a puzzle that the game doesn't accept, you might have come up with a new solution for it! Hit the "New Solution" button in the bottom right of the page to submit. You might see your new puzzle in the next pack--and there might be a leaderboard added for this...
        """, titleFont: 30, bodyFont: 15, sectionWidthToUse: 1.3)
    }
    
    private func addTextSection(title: String, body: String, titleFont: CGFloat, bodyFont: CGFloat, sectionWidthToUse: CGFloat=0.7) {
        let titlePortraitHeight: CGFloat = 1.5 * titleFont * (titleFont == 40 ? 2 : 1)
        let titleLandscapeHeight: CGFloat = 1.5 * titleFont * (titleFont == 40 ? 2 : 1)
        let bodyPortraitHeight = 1.5 * bodyFont * (linesForLabel(font: bodyFont, text: body, width: sectionFullWidth) + 1)
        let bodyLandscapeHeight = bodyPortraitHeight / sectionWidthToUse + (title == "Puzzles" ? 30 : 0)
        
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
        bodyLabel.font = .italicSystemFont(ofSize: bodyFont)
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        bodyLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor).isActive = true
        bodyLabel.leftAnchor.constraint(equalTo: newSection.leftAnchor, constant: 10).isActive = true
        bodyLabel.rightAnchor.constraint(equalTo: newSection.rightAnchor, constant: -10).isActive = true
        
        portraitConstraints += [
            newSection.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            newSection.heightAnchor.constraint(equalToConstant: titlePortraitHeight + bodyPortraitHeight),
            bodyLabel.heightAnchor.constraint(equalToConstant: bodyPortraitHeight),
        ]
        landscapeConstraints += [
            newSection.widthAnchor.constraint(equalToConstant: sectionFullWidth * sectionWidthToUse),
            newSection.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
            bodyLabel.heightAnchor.constraint(equalToConstant: bodyLandscapeHeight),
        ]
        
        verticalBorders += addBorders(view: newSection, bottom: true, left: true, right: true)
        horizontalBorders += addBorders(view: newSection, right: true)
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
    
    // MARK: Other UI
}
