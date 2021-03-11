//
//  NewSolutionCellLayout.swift
//  Missing Link
//
//  Created by Benjamin Share on 11/26/20.
//  Copyright © 2020 Benjamin Share. All rights reserved.
//

import Foundation
import UIKit

class NewSolutionCellLayout {
    // MARK: Properties
    
    // Constants
    
    // UI elements
    private var firstLabel: UILabel
    private var firstField: UITextField
    private var answerLabel: UILabel
    private var answerField: UITextField
    private var lastLabel: UILabel
    private var lastField: UITextField
    
    // Constraint maps
    private var verticalMap: [UIView: (CGFloat, CGFloat)]!
    private var horizontalMap: [UIView: (CGFloat, CGFloat)]!
    
    // Constraints
    private var constraints = [NSLayoutConstraint]()
    
    
    // MARK: Initialization
    init(firstLabel: UILabel, firstField: UITextField, answerLabel: UILabel, answerField: UITextField, lastLabel: UILabel, lastField: UITextField) {
        // Set properties
        self.firstLabel = firstLabel
        firstLabel.translatesAutoresizingMaskIntoConstraints = false
        firstLabel.adjustsFontSizeToFitWidth = true
        firstLabel.textAlignment = .center
        firstLabel.textColor = globalTextColor()
        firstLabel.text = "First"
        _ = addBorders(view: firstLabel, right: true, width: 1)
        
        self.firstField = firstField
        firstField.translatesAutoresizingMaskIntoConstraints = false
        firstField.adjustsFontSizeToFitWidth = true
        firstField.textAlignment = .center
        firstField.backgroundColor = .lightGray
        firstField.autocapitalizationType = .allCharacters
        firstField.placeholder = "First Word"
        _ = addBorders(view: firstField, top: true, bottom: true, left: true, right: true, width: 1)
        
        self.answerLabel = answerLabel
        answerLabel.translatesAutoresizingMaskIntoConstraints = false
        answerLabel.adjustsFontSizeToFitWidth = true
        answerLabel.textAlignment = .center
        answerLabel.textColor = globalTextColor()
        answerLabel.text = "Link"
        
        self.answerField = answerField
        answerField.translatesAutoresizingMaskIntoConstraints = false
        answerField.adjustsFontSizeToFitWidth = true
        answerField.textAlignment = .center
        answerField.backgroundColor = .lightGray
        answerField.autocapitalizationType = .allCharacters
        answerField.placeholder = "Link"
        _ = addBorders(view: answerField, top: true, bottom: true, width: 1)
        
        self.lastLabel = lastLabel
        lastLabel.translatesAutoresizingMaskIntoConstraints = false
        lastLabel.adjustsFontSizeToFitWidth = true
        lastLabel.textAlignment = .center
        lastLabel.textColor = globalTextColor()
        lastLabel.text = "Last"
        _ = addBorders(view: lastLabel, left: true, width: 1)
        
        self.lastField = lastField
        lastField.translatesAutoresizingMaskIntoConstraints = false
        lastField.adjustsFontSizeToFitWidth = true
        lastField.textAlignment = .center
        lastField.backgroundColor = .lightGray
        lastField.autocapitalizationType = .allCharacters
        lastField.placeholder = "Last Word"
        _ = addBorders(view: lastField, top: true, bottom: true, left: true, right: true, width: 1)
        
        // Portrait and landscape constraints
        horizontalMap = [
            firstLabel: (0.3333, 0.1667),
            firstField: (0.3333, 0.1667),
            answerLabel: (0.3333, 0.5),
            answerField: (0.3333, 0.5),
            lastLabel: (0.3333, 0.8333),
            lastField: (0.3333, 0.8333),
        ]
        verticalMap = [
            firstLabel: (0.3333, 0.1667),
            firstField: (0.6666, 0.6666),
            answerLabel: (0.3333, 0.1667),
            answerField: (0.6666, 0.6666),
            lastLabel: (0.3333, 0.1667),
            lastField: (0.6666, 0.6666),
        ]
        
        // Do other UI setup
        setUIDefaults()
    }
    
    func setUIDefaults() {
    }
    
    // MARK: Constraints
    func configureConstraints(view: UIView) {
        view.addSubview(firstLabel)
        view.addSubview(firstField)
        view.addSubview(answerLabel)
        view.addSubview(answerField)
        view.addSubview(lastLabel)
        view.addSubview(lastField)
        constraints += getFullHorizontalConstraints(leftAnchor: view.leftAnchor, rightAnchor: view.rightAnchor, horizontalConstraintMap: horizontalMap, parentView: view)
        constraints += getFullVerticalConstraints(topAnchor: view.topAnchor, bottomAnchor: view.bottomAnchor, verticalConstraintMap: verticalMap, parentView: view)
    }
    
    func activateConstraints() {
        NSLayoutConstraint.activate(constraints)
    }
    
    // MARK: Other UI
    
}
