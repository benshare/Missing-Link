//
//  FeedbackViewLayout.swift
//  Missing Link
//
//  Created by Benjamin Share on 7/19/20.
//  Copyright © 2020 Benjamin Share. All rights reserved.
//

import Foundation
import UIKit

class FeedbackViewLayout {
    
    private var headlineLabel: UILabel!
    private var feedbackField: UITextView!
    private var submitButton: UIButton!
    private var thanksLabel: UILabel!
    
    private let portraitVerticalMap: [UIView: (CGFloat, CGFloat)]!
    private let portraitHorizontalMap: [UIView: (CGFloat, CGFloat)]!
    private let landscapeVerticalMap: [UIView: (CGFloat, CGFloat)]!
    private let landscapeHorizontalMap: [UIView: (CGFloat, CGFloat)]!
    
    private var portraitConstraints: [NSLayoutConstraint] = []
    private var landscapeConstraints: [NSLayoutConstraint] = []
    
    init(headlineLabel: UILabel, feedbackField: UITextView, submitButton: UIButton, thanksLabel: UILabel) {
        self.headlineLabel = headlineLabel
        self.feedbackField = feedbackField
        self.submitButton = submitButton
        self.thanksLabel = thanksLabel
        
        setTextToDefaults(labels: [headlineLabel, submitButton.titleLabel, thanksLabel])
        headlineLabel.numberOfLines = 2
        feedbackField.font = .systemFont(ofSize: 20)
        feedbackField.layer.borderWidth = 5.0
        feedbackField.layer.borderColor = UIColor.lightGray.cgColor
        
        portraitVerticalMap = [
            headlineLabel: (0.4, 0.1),
            feedbackField: (0.5, 0.45),
            submitButton: (0.05, 0.77),
            thanksLabel: (0.1, 0.9),
        ]
        portraitHorizontalMap = [
            headlineLabel: (0.8, 0.5),
            feedbackField: (0.9, 0.5),
            submitButton: (0.2, 0.5),
            thanksLabel: (0.9, 0.5),
        ]
        landscapeVerticalMap = [
            headlineLabel: (0.2, 0.1),
            feedbackField: (0.5, 0.45),
            submitButton: (0.05, 0.75),
            thanksLabel: (0.1, 0.9),
        ]
        landscapeHorizontalMap = [
            headlineLabel: (0.8, 0.5),
            feedbackField: (0.9, 0.5),
            submitButton: (0.1, 0.5),
            thanksLabel: (0.7, 0.5),
        ]
    }
    
    func configureConstraints(view: UIView, margins: UILayoutGuide)  {
        portraitConstraints += getFullVerticalConstraints(topAnchor: margins.topAnchor, bottomAnchor: margins.bottomAnchor, verticalConstraintMap: portraitVerticalMap, parentView: view)
        portraitConstraints += getFullHorizontalConstraints(leftAnchor: margins.leftAnchor, rightAnchor: margins.rightAnchor, horizontalConstraintMap: portraitHorizontalMap, parentView: view)
        landscapeConstraints += getFullVerticalConstraints(topAnchor: margins.topAnchor, bottomAnchor: margins.bottomAnchor, verticalConstraintMap: landscapeVerticalMap, parentView: view)
        landscapeConstraints += getFullHorizontalConstraints(leftAnchor: margins.leftAnchor, rightAnchor: margins.rightAnchor, horizontalConstraintMap: landscapeHorizontalMap, parentView: view)
        
        view.backgroundColor = globalBackgroundColor()
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
}
