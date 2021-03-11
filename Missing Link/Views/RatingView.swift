//
//  RatingView.swift
//  Missing Link
//
//  Created by Benjamin Share on 11/29/20.
//  Copyright © 2020 Benjamin Share. All rights reserved.
//

import Foundation
import UIKit

let RATING_GROUP = DispatchGroup()

class RatingView: UIView, UIGestureRecognizerDelegate {
    // MARK: Properties
    
    var user: User!
    var metadata: PuzzleMetadata!
    var puzzle: Puzzle!
    private var rating: Int!
    
    // Formatting
    var parentView: UIView!
    var parentController: PuzzleViewController!
    private var layout: RatingViewLayout?
    private var blurView: UIVisualEffectView
    private var portraitConstraints = [NSLayoutConstraint]()
    private var landscapeConstraints = [NSLayoutConstraint]()
    
    // UI elements
    private let titleLabel = UILabel()
    private var stars = [UIButton]()
    private let skipButton = UIButton()
    private let notAgainButton = UIButton()

    
    // MARK: Initialization
    init(numStars: Int=5, user: User, metadata: PuzzleMetadata, puzzle: Puzzle, parentController: PuzzleViewController) {
        self.user = user
        self.metadata = metadata
        self.puzzle = puzzle
        self.parentController = parentController
        self.parentView = parentController.view
        
        titleLabel.text = "How hard was that puzzle?"
        skipButton.setTitle("Skip Feedback", for: .normal)
        
        notAgainButton.setTitle("Skip and Don't Ask Again", for: .normal)
        
        self.blurView = Missing_Link.blurView(view: parentView)
        
        super.init(frame: CGRect())
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = globalBackgroundColor()

        for _ in 0...numStars-1 {
            let star = UIButton()
            star.addTarget(self, action: #selector(starPressed(sender:)), for: .touchUpInside)
            star.adjustsImageWhenHighlighted = false
            stars.append(star)
        }
        skipButton.addTarget(self, action: #selector(closeView), for: .touchUpInside)
        notAgainButton.addTarget(self, action: #selector(notAgain), for: .touchUpInside)
        
        self.layout = RatingViewLayout(titleLabel: titleLabel, stars: stars, skipButton: skipButton, notAgainButton: notAgainButton)
        layout!.configureConstraints(view: self)
        layout!.activateConstraints()
    }
    
    func configureView() {
        portraitConstraints.append(self.widthAnchor.constraint(equalTo: parentView.widthAnchor, multiplier: 0.6))
        landscapeConstraints.append(self.widthAnchor.constraint(equalTo: parentView.widthAnchor, multiplier: 0.35))
        self.heightAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.9).isActive = true
        self.centerXAnchor.constraint(equalTo: parentView.centerXAnchor).isActive = true
        self.centerYAnchor.constraint(equalTo: parentView.centerYAnchor).isActive = true
        RATING_GROUP.enter()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Constraints
    func activateConstraints(isPortrait: Bool) {
        if isPortrait {
            NSLayoutConstraint.deactivate(landscapeConstraints)
            NSLayoutConstraint.activate(portraitConstraints)
        } else {
            NSLayoutConstraint.deactivate(portraitConstraints)
            NSLayoutConstraint.activate(landscapeConstraints)
        }
    }
    
    
    // MARK: Buttons
    
    @objc private func starPressed(sender: UIButton) {
        for i in 0...stars.count-1 {
            if sender == stars[i] {
                layout?.fillStars(upTo: i)
                rating = i + 1
                Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(submitRating), userInfo: nil, repeats: false)
                break
            }
        }
    }
    
    // MARK: Submission
    
    @objc private func submitRating() {
        metadata.update(puzzle: puzzle, action: .rate, rating: PuzzleDifficultyRating(rating: rating))
        closeView()
    }
    
    @objc private func closeView() {
        blurView.removeFromSuperview()
        self.removeFromSuperview()
        parentController.ratingView = nil
        RATING_GROUP.leave()
    }
    
    @objc private func notAgain() {
        user.preferences.submitDifficultyFeedback = false
        updateSyncedUserPreferences(preferences: user.preferences)
        closeView()
    }
}

