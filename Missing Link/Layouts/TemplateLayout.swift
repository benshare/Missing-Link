//
//  TemplateLayout.swift
//  Missing Link
//
//  Created by Benjamin Share on 11/30/20.
//  Copyright © 2020 Benjamin Share. All rights reserved.
//

import Foundation
import UIKit

class TemplateLayout {
    // MARK: Properties
    
    // UI elements
    
    // Constraint maps
    private var portraitHorizontalMap: [UIView: (CGFloat, CGFloat)]!
    private var portraitVerticalMap: [UIView: (CGFloat, CGFloat)]!
    private var landscapeHorizontalMap: [UIView: (CGFloat, CGFloat)]!
    private var landscapeVerticalMap: [UIView: (CGFloat, CGFloat)]!
    
    // Constraints
    private var portraitConstraints = [NSLayoutConstraint]()
    private var landscapeConstraints = [NSLayoutConstraint]()
    
    init() {
        
        setTextToDefaults(labels: [])
        setButtonsToDefaults(buttons: [])
        
        // Portrait
        portraitVerticalMap = [:
        ]
        
        portraitHorizontalMap = [:
        ]
        
        // Landscape
        landscapeVerticalMap = [:
        ]
        
        landscapeHorizontalMap = [:
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
