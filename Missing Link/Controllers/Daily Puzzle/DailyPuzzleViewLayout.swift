//
//  DailyPuzzleViewLayout.swift
//  Missing Link
//
//  Created by Benjamin Share on 7/7/20.
//  Copyright © 2020 Benjamin Share. All rights reserved.
//

import Foundation
import UIKit

class DailyPuzzleViewLayout {
    // MARK: Properties
    
    // UI elements
    private var firstWord: UILabel
    private var lastWord: UILabel
    private var link: UITextField
    private var hintButton: UIButton
    private var coinsLabel: UILabel?
    private var streakLabel: UILabel?
    private var newSolutionButton: UIButton
    private var hintModeLetters: [UITextField]
    
    // Values to track
    private var lettersInAnswer: Int = 0
    private var inHintMode: Bool = false
    
    // Constraint maps
    private var portraitVerticalMap: [UIView: (CGFloat, CGFloat)]!
    private var portraitHorizontalMap: [UIView: (CGFloat, CGFloat)]!
    private var landscapeVerticalMap: [UIView: (CGFloat, CGFloat)]!
    private var landscapeHorizontalMap: [UIView: (CGFloat, CGFloat)]!
    
    // Constraints
    private var portraitConstraints = [NSLayoutConstraint]()
    private var landscapeConstraints = [NSLayoutConstraint]()
    private var hintLetterPortraitConstraints = [NSLayoutConstraint]()
    private var hintLetterLandscapeConstraints = [NSLayoutConstraint]()
    
    
    // MARK: Initialization
    init(firstWord: UILabel, lastWord: UILabel, link: UITextField, hintButton: UIButton, newSolutionButton: UIButton, hintModeLetters: [UITextField]) {
        self.firstWord = firstWord
        self.lastWord = lastWord
        self.link = link
        self.hintButton = hintButton
        self.newSolutionButton = newSolutionButton
        self.hintModeLetters = hintModeLetters
        
        // Portrait
        portraitVerticalMap = [
            firstWord: (0.1, CGFloat(1.0/3)),
            link: (0.1, 0.5),
            lastWord: (0.1, CGFloat(2.0/3)),
        ]
        portraitHorizontalMap = [
            firstWord: (0.8, 0.5),
            lastWord: (0.8, 0.5),
        ]
        
        // Landscape
        landscapeVerticalMap = [
            firstWord: (0.1, 0.35),
            link: (0.1, 0.5),
            lastWord: (0.1, 0.65),
        ]
        landscapeHorizontalMap = [
            firstWord: (0.4, 0.21),
            lastWord: (0.4, 0.79),
        ]
        
        // Do other UI setup
        _ = addBorders(view: hintButton, top: true, right: true)
        _ = addBorders(view: newSolutionButton, top: true, left: true)
        setUIDefaults()
    }
    
    func setUIDefaults() {
        for letter in hintModeLetters {
            _ = addBorders(view: letter, bottom: true, width: 3)
            letter.textAlignment = .center
            letter.adjustsFontSizeToFitWidth = true
            letter.font = .systemFont(ofSize: 40)
            letter.isEnabled = false
            letter.isHidden = true
            letter.translatesAutoresizingMaskIntoConstraints = false
        }
        centerAlignText(labels: [firstWord, lastWord])
        setButtonsToDefaults(buttons: [hintButton, newSolutionButton])
    }
    
    // MARK: Constraints
    func configureConstraints(view: UIView) {
        let margins = view.layoutMarginsGuide
        
        // Portrait
        portraitConstraints += getFullVerticalConstraints(topAnchor: margins.topAnchor, bottomAnchor: margins.bottomAnchor, verticalConstraintMap: portraitVerticalMap, parentView: view)
        portraitConstraints += getFullHorizontalConstraints(leftAnchor: margins.leftAnchor, rightAnchor: margins.rightAnchor, horizontalConstraintMap: portraitHorizontalMap, parentView: view)
        
        portraitConstraints += [link.centerXAnchor.constraint(equalTo: margins.centerXAnchor)]
        // Hint letter vertical constraints have to be done separately
        for field in hintModeLetters {
            portraitConstraints += [field.centerYAnchor.constraint(equalTo: link.centerYAnchor), field.heightAnchor.constraint(equalTo: link.heightAnchor)]
        }
        // Buttons are configured to the full view rather than the margins
        var buttonsVerticalMap = [
            hintButton: (CGFloat(1.0/12), CGFloat(23.0/24)),
            newSolutionButton: (CGFloat(1.0/12), CGFloat(23.0/24)),
        ]
        var buttonsHorizontalMap = [
            hintButton: (CGFloat(1.0/3), CGFloat(1.0/6)),
            newSolutionButton: (CGFloat(1.0/3), CGFloat(5.0/6)),
        ]
        portraitConstraints += getFullVerticalConstraints(topAnchor: view.topAnchor, bottomAnchor: view.bottomAnchor, verticalConstraintMap: buttonsVerticalMap, parentView: view)
        portraitConstraints += getFullHorizontalConstraints(leftAnchor: view.leftAnchor, rightAnchor: view.rightAnchor, horizontalConstraintMap: buttonsHorizontalMap, parentView: view)
        portraitConstraints.append((hintButton.titleLabel?.widthAnchor.constraint(equalTo: hintButton.widthAnchor, multiplier: 0.5))!)
        portraitConstraints.append((newSolutionButton.titleLabel?.widthAnchor.constraint(equalTo: newSolutionButton.widthAnchor, multiplier: 0.8))!)
        
        // Landscape
        landscapeConstraints += getFullVerticalConstraints(topAnchor: margins.topAnchor, bottomAnchor: margins.bottomAnchor, verticalConstraintMap: landscapeVerticalMap, parentView: view)
        landscapeConstraints += getFullHorizontalConstraints(leftAnchor: margins.leftAnchor, rightAnchor: margins.rightAnchor, horizontalConstraintMap: landscapeHorizontalMap, parentView: view)
        landscapeConstraints += [link.centerXAnchor.constraint(equalTo: margins.centerXAnchor)]
        for field in hintModeLetters {
            landscapeConstraints += [field.centerYAnchor.constraint(equalTo: link.centerYAnchor), field.heightAnchor.constraint(equalTo: link.heightAnchor)]
        }
        buttonsVerticalMap = [
            hintButton: (CGFloat(1.0/6), CGFloat(11.0/12)),
            newSolutionButton: (CGFloat(1.0/6), CGFloat(11.0/12)),
        ]
        buttonsHorizontalMap = [
            hintButton: (CGFloat(1.0/3), CGFloat(1.0/6)),
            newSolutionButton: (CGFloat(1.0/3), CGFloat(5.0/6)),
        ]
        landscapeConstraints += getFullVerticalConstraints(topAnchor: view.topAnchor, bottomAnchor: view.bottomAnchor, verticalConstraintMap: buttonsVerticalMap, parentView: view)
        landscapeConstraints += getFullHorizontalConstraints(leftAnchor: view.leftAnchor, rightAnchor: view.rightAnchor, horizontalConstraintMap: buttonsHorizontalMap, parentView: view)
        landscapeConstraints.append((hintButton.titleLabel?.widthAnchor.constraint(equalTo: hintButton.widthAnchor, multiplier: 0.3))!)
        landscapeConstraints.append((newSolutionButton.titleLabel?.widthAnchor.constraint(equalTo: newSolutionButton.widthAnchor, multiplier: 0.8))!)

        let (coins, coinPortrait, coinLandscape) = addCoinsToView(view: view, portrait: ((0.08, 0.15), (0.25, 0.15)), landscape: ((0.15, 0.13), (0.15, 0.3)))
        let (streak, streakPortrait, streakLandscape) = addStreakToView(view: view, portrait: ((0.08, 0.15), (0.25, 0.85)), landscape: ((0.15, 0.13), (0.15, 0.7)))
        portraitConstraints += coinPortrait + streakPortrait
        landscapeConstraints += coinLandscape + streakLandscape
        coinsLabel = coins
        streakLabel = streak
    }
    
    func configureHintLetterConstraints(view: UIView, length: Int) {
        let margins = view.layoutMarginsGuide
        
        // Deactivate previous horizontal constraints
        NSLayoutConstraint.deactivate(hintLetterPortraitConstraints)
        NSLayoutConstraint.deactivate(hintLetterLandscapeConstraints)
        
        // Overwrite with new constraints
        let (portraitMap, portraitWidth, landscapeMap, landscapeWidth) = getHorizontalMapsForHintModeLetters(hintModeLetters: hintModeLetters, length: length, portraitWidth: 0.11, portraitGap: 0.02, landscapeWidth: 0.05, landscapeGap: 0.01)
        let hintModeLinkWidthPortraitConstraint = link.widthAnchor.constraint(equalTo: margins.widthAnchor, multiplier: CGFloat(portraitWidth))
        hintLetterPortraitConstraints = getFullHorizontalConstraints(leftAnchor: margins.leftAnchor, rightAnchor: margins.rightAnchor, horizontalConstraintMap: portraitMap, parentView: view) + [hintModeLinkWidthPortraitConstraint]
        
        let hintModeLinkWidthLandscapeConstraint = link.widthAnchor.constraint(equalTo: margins.widthAnchor, multiplier: CGFloat(landscapeWidth))
        hintLetterLandscapeConstraints = getFullHorizontalConstraints(leftAnchor: margins.leftAnchor, rightAnchor: margins.rightAnchor, horizontalConstraintMap: landscapeMap, parentView: view) + [hintModeLinkWidthLandscapeConstraint]
        
        lettersInAnswer = length
    }
    
    func activateConstraints(isPortrait: Bool) {
        if isPortrait {
            NSLayoutConstraint.deactivate(landscapeConstraints)
            NSLayoutConstraint.activate(portraitConstraints)
            if inHintMode {
                NSLayoutConstraint.deactivate(hintLetterLandscapeConstraints)
                NSLayoutConstraint.activate(hintLetterPortraitConstraints)
            }
        } else  {
            NSLayoutConstraint.deactivate(portraitConstraints)
            NSLayoutConstraint.activate(landscapeConstraints)
            if inHintMode {
                NSLayoutConstraint.deactivate(hintLetterPortraitConstraints)
                NSLayoutConstraint.activate(hintLetterLandscapeConstraints)
            }
        }
    }
    
    // MARK: Other UI
    func activateHintMode(isPortrait: Bool) {
        inHintMode = true
        link.isOpaque = false
        link.textColor = globalBackgroundColor()
        link.tintColor = .clear
        link.placeholder = ""
        if isPortrait {
            NSLayoutConstraint.deactivate(hintLetterLandscapeConstraints)
            NSLayoutConstraint.activate(hintLetterPortraitConstraints)
        } else {
            NSLayoutConstraint.deactivate(hintLetterPortraitConstraints)
            NSLayoutConstraint.activate(hintLetterLandscapeConstraints)
        }
        for ind in 0...lettersInAnswer-1 {
            hintModeLetters[ind].isHidden = false
        }
    }
    
    func setCoinsAndStreakLabels(coins: Int, streak: Int, animate: Bool=false) {
        if !animate {
            coinsLabel?.text = String(coins)
            streakLabel?.text = String(streak)
            return
        }
        UIView.transition(with: streakLabel!, duration: 1, options: .transitionCrossDissolve, animations: { [weak self] in
            self?.coinsLabel?.text = String(coins)
            self?.streakLabel!.text = String(streak);
        }, completion: nil)
    }
    
    func setCoinsLabel(coins: Int) {
        UIView.transition(with: streakLabel!, duration: 2, options: .transitionCrossDissolve, animations: { [weak self] in
            self?.coinsLabel?.text = String(coins)
        }, completion: nil)
    }
}
