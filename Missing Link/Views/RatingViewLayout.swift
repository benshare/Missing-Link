//
//  RatingViewLayout.swift
//  Missing Link
//
//  Created by Benjamin Share on 11/29/20.
//  Copyright © 2020 Benjamin Share. All rights reserved.
//

import Foundation
import UIKit

class RatingViewLayout {
    // MARK: Properties
    
    // UI elements
    private let titleLabel: UILabel
    private var stars: [UIButton]
    private let skipButton: UIButton
    private let notAgainButton: UIButton
    
    // Constraint maps
    private var verticalMap = [UIView: (CGFloat, CGFloat)]()
    private var horizontalMap = [UIView: (CGFloat, CGFloat)]()
    
    // Constraints
    private var constraints = [NSLayoutConstraint]()
    
    // Constants
    let emptyStar: UIImage
    let fullStar: UIImage
    
    
    // MARK: Initialization
    init(titleLabel: UILabel, stars: [UIButton], skipButton: UIButton, notAgainButton: UIButton) {
        // Set properties
        self.titleLabel = titleLabel
        self.stars = stars
        self.skipButton = skipButton
        self.notAgainButton = notAgainButton
        self.emptyStar = UIImage(named: "EmptyStar")!
        self.fullStar = UIImage(named: "FullStar")!
        
        verticalMap[titleLabel] = (0.2, 0.1)
        horizontalMap[titleLabel] = (0.9, 0.5)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let starWidth = 1 / Double(stars.count)
        for i in 0...stars.count-1 {
            let star = stars[i]
            star.translatesAutoresizingMaskIntoConstraints = false
            star.setBackgroundImage(emptyStar, for: .normal)
            verticalMap[star] = (0.2, 0.4)
            horizontalMap[star] = (CGFloat(starWidth), CGFloat(starWidth * (Double(i) + 0.5)))
            
        }
        verticalMap[skipButton] = (0.1, 0.7)
        horizontalMap[skipButton] = (0.5, 0.5)
        skipButton.translatesAutoresizingMaskIntoConstraints = false
        skipButton.setTitleColor(.lightGray, for: .normal)
        
        verticalMap[notAgainButton] = (0.1, 0.9)
        horizontalMap[notAgainButton] = (0.8, 0.5)
        notAgainButton.translatesAutoresizingMaskIntoConstraints = false
        notAgainButton.setTitleColor(.lightGray, for: .normal)
        
        setTextToDefaults(labels: [titleLabel])
        setButtonsToDefaults(buttons: [skipButton, notAgainButton])
    }
    
    // MARK: Constraints
    func configureConstraints(view: UIView) {
        view.addSubview(titleLabel)
        for star in stars {
            view.addSubview(star)
        }
        view.addSubview(skipButton)
        view.addSubview(notAgainButton)
        constraints += getFullHorizontalConstraints(leftAnchor: view.leftAnchor, rightAnchor: view.rightAnchor, horizontalConstraintMap: horizontalMap, parentView: view)
        constraints += getFullVerticalConstraints(topAnchor: view.topAnchor, bottomAnchor: view.bottomAnchor, verticalConstraintMap: verticalMap, parentView: view)
        
        _ = addBorders(view: view, top: true, bottom: true, left: true, right: true)
    }
    
    func activateConstraints() {
        NSLayoutConstraint.activate(constraints)
    }
    
    // MARK: Other UI
    func emptyStars() {
        for star in stars {
            star.setImage(emptyStar, for: .normal)
        }
    }
    
    func fillStars(upTo: Int) {
        if upTo >= stars.count {
            print("Fill stars called for index outside range")
            return
        }
        for i in 0...upTo {
            let star = stars[i]
            star.setBackgroundImage(fullStar, for: .normal)
        }
    }
    
}
