//
//  NewSolutionViewLayout.swift
//  Missing Link
//
//  Created by Benjamin Share on 11/19/20.
//  Copyright © 2020 Benjamin Share. All rights reserved.
//

import Foundation
import UIKit

class NewSolutionViewLayout {
    // MARK: Properties
    
    // Constants
    
    // UI elements
    private var titleLabel: UILabel
    private var closeButton: UIButton
    private var submitButton: UIButton
    private var solutionCell: NewSolutionCell
    
    // Constraint maps
    private var portraitVerticalMap: [UIView: (CGFloat, CGFloat)]!
    private var portraitHorizontalMap: [UIView: (CGFloat, CGFloat)]!
    private var landscapeVerticalMap: [UIView: (CGFloat, CGFloat)]!
    private var landscapeHorizontalMap: [UIView: (CGFloat, CGFloat)]!
    
    // Constraints
    private var portraitConstraints = [NSLayoutConstraint]()
    private var landscapeConstraints = [NSLayoutConstraint]()
    
    
    // MARK: Initialization
    init(titleLabel: UILabel, closeButton: UIButton, submitButton: UIButton, solutionCell: NewSolutionCell) {
        // Set properties
        self.titleLabel = titleLabel
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.text = "New puzzle solution?\nFill in the fields below, then\npress submit."
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        
        self.closeButton = closeButton
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.titleLabel?.adjustsFontSizeToFitWidth = true
        closeButton.setTitle("X", for: .normal)
        closeButton.setTitleColor(.systemGray, for: .normal)
        _ = addBorders(view: closeButton, bottom: true, right: true)
        
        self.submitButton = submitButton
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        submitButton.titleLabel?.adjustsFontSizeToFitWidth = true
        submitButton.backgroundColor = .gray
        submitButton.setTitle("Submit", for: .normal)
        submitButton.setTitleColor(globalTextColor(), for: .normal)
        
        self.solutionCell = solutionCell
        solutionCell.translatesAutoresizingMaskIntoConstraints = false
        solutionCell.backgroundColor = .blue
        
        // Portrait
        portraitHorizontalMap = [
            titleLabel: (0.8, 0.5),
            solutionCell: (1, 0.5),
            submitButton: (0.3, 0.5),
        ]
        portraitVerticalMap = [
            titleLabel: (0.25, 0.2),
            solutionCell: (0.15, 0.5),
            submitButton: (0.1, 0.9),
        ]
        
        // Landscape
        landscapeHorizontalMap = [
            titleLabel: (0.8, 0.5),
            solutionCell: (1, 0.5),
            submitButton: (0.2, 0.5),
        ]
        landscapeVerticalMap = [
            titleLabel: (0.25, 0.2),
            solutionCell: (0.25, 0.52),
            submitButton: (0.15, 0.85),
        ]
        
        // Do other UI setup
        setUIDefaults()
    }
    
    func setUIDefaults() {
    }
    
    // MARK: Constraints
    func configureConstraints(view: UIView, isPortrait: Bool) {
        view.addSubview(titleLabel)
        view.addSubview(closeButton)
        view.addSubview(submitButton)
        view.addSubview(solutionCell)
        
        portraitConstraints += getFullHorizontalConstraints(leftAnchor: view.leftAnchor, rightAnchor: view.rightAnchor, horizontalConstraintMap: portraitHorizontalMap, parentView: view)
        portraitConstraints += getFullVerticalConstraints(topAnchor: view.topAnchor, bottomAnchor: view.bottomAnchor, verticalConstraintMap: portraitVerticalMap, parentView: view)
        portraitConstraints += [
            closeButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.1),
            closeButton.heightAnchor.constraint(equalTo: closeButton.widthAnchor),
            closeButton.leftAnchor.constraint(equalTo: view.leftAnchor),
            closeButton.topAnchor.constraint(equalTo: view.topAnchor),
        ]
        
        landscapeConstraints += getFullHorizontalConstraints(leftAnchor: view.leftAnchor, rightAnchor: view.rightAnchor, horizontalConstraintMap: landscapeHorizontalMap, parentView: view)
        landscapeConstraints += getFullVerticalConstraints(topAnchor: view.topAnchor, bottomAnchor: view.bottomAnchor, verticalConstraintMap: landscapeVerticalMap, parentView: view)
        landscapeConstraints += [
            closeButton.widthAnchor.constraint(equalTo: closeButton.heightAnchor),
            closeButton.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.1),
            closeButton.leftAnchor.constraint(equalTo: view.leftAnchor),
            closeButton.topAnchor.constraint(equalTo: view.topAnchor),
        ]
    }
    
    func activatePortraitConstraints() {
        NSLayoutConstraint.deactivate(landscapeConstraints)
        NSLayoutConstraint.activate(portraitConstraints)
    }
    
    func activateLandscapeConstraints() {
        NSLayoutConstraint.deactivate(portraitConstraints)
        NSLayoutConstraint.activate(landscapeConstraints)
    }
    
    // MARK: Other UI
    
}
