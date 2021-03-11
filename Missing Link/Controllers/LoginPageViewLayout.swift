//
//  LoginPageViewLayout.swift
//  Missing Link
//
//  Created by Benjamin Share on 10/17/20.
//  Copyright © 2020 Benjamin Share. All rights reserved.
//

import Foundation
import UIKit

class LoginPageViewLayout {
    // MARK: Properties
    
    // UI elements
    private var titleLabel: UILabel!
    private var welcomeLabel: UILabel!
    private var usernameLabel: UILabel!
    private var usernameField: UITextField!
    private var passwordLabel: UILabel!
    private var passwordField: UITextField!
    private var showPasswordButton: UIButton!
    private var rememberLabel: UILabel!
    private var rememberSwitch: UISwitch!
    private var invalidLabel: UILabel!
    private var signInButton: UIButton!
    private var guestButton: UIButton!
    private var newUserButton: UIButton!
    
    // Constraint maps
    private var portraitVerticalMap = [UIView: (CGFloat, CGFloat)]()
    private var portraitHorizontalMap = [UIView: (CGFloat, CGFloat)]()
    private var landscapeVerticalMap = [UIView: (CGFloat, CGFloat)]()
    private var landscapeHorizontalMap = [UIView: (CGFloat, CGFloat)]()
    
    // Constraints
    private var portraitConstraints = [NSLayoutConstraint]()
    private var landscapeConstraints = [NSLayoutConstraint]()
    
    // Values to track
    private var isPortrait: Bool = true
    

    init(titleLabel: UILabel, welcomeLabel: UILabel, usernameLabel: UILabel, usernameField: UITextField, passwordLabel: UILabel, passwordField: UITextField, showPasswordButton: UIButton,  rememberLabel: UILabel, rememberSwitch: UISwitch, invalidLabel: UILabel, signInButton: UIButton, guestButton: UIButton, newUserButton: UIButton) {
        self.titleLabel = titleLabel
        self.welcomeLabel = welcomeLabel
        self.usernameLabel = usernameLabel
        self.usernameField = usernameField
        self.passwordLabel = passwordLabel
        self.passwordField = passwordField
        self.showPasswordButton = showPasswordButton
        self.invalidLabel = invalidLabel
        self.rememberLabel = rememberLabel
        self.rememberSwitch = rememberSwitch
        self.signInButton = signInButton
        self.newUserButton = newUserButton
        self.guestButton = guestButton
        
        
        // Portrait
        portraitVerticalMap = [
            titleLabel: (0.15, 0.08),
            welcomeLabel: (0.1, 0.22),
            usernameLabel: (0.1, 0.35),
            usernameField: (0.05, 0.35),
            passwordLabel: (0.06, 0.5),
            passwordField: (0.05, 0.5),
            showPasswordButton: (0.05, 0.575),
            rememberLabel: (0.1, 0.65),
            rememberSwitch: (0.1, 0.73),
            signInButton: (0.1, 0.69),
            invalidLabel: (0.1, 0.58),
            guestButton: (0.1, 0.8),
            newUserButton: (0.1, 0.9),
        ]
        portraitHorizontalMap = [
            titleLabel: (0.8, 0.5),
            welcomeLabel: (0.6, 0.5),
            usernameLabel: (0.2, 0.1),
            usernameField: (0.7, 0.6),
            passwordLabel: (0.2, 0.1),
            passwordField: (0.7, 0.6),
            showPasswordButton: (0.15, 0.875),
            rememberLabel: (0.2, 0.25),
            rememberSwitch: (0.1, 0.25),
            signInButton: (0.25, 0.7),
            invalidLabel: (0.6, 0.5),
            guestButton: (0.45, 0.5),
            newUserButton: (0.65, 0.5),
        ]
        
        // Landscape
        landscapeVerticalMap = [
            titleLabel: (0.19, 0.1),
            welcomeLabel: (0.1, 0.25),
            usernameLabel: (0.1, 0.45),
            usernameField: (0.08, 0.45),
            passwordLabel: (0.1, 0.6),
            passwordField: (0.08, 0.6),
            showPasswordButton: (0.07, 0.75),
            rememberLabel: (0.1, 0.71),
            rememberSwitch: (0.1, 0.79),
            signInButton: (0.1, 0.45),
            invalidLabel: (0.1, 0.9),
            newUserButton: (0.1, 0.75),
            guestButton: (0.1, 0.6),
        ]
        landscapeHorizontalMap = [
            titleLabel: (0.6, 0.5),
            welcomeLabel: (0.4, 0.5),
            usernameLabel: (0.15, 0.1),
            usernameField: (0.4, 0.4),
            passwordLabel: (0.15, 0.1),
            passwordField: (0.4, 0.4),
            showPasswordButton: (0.08, 0.56),
            rememberLabel: (0.1, 0.35),
            rememberSwitch: (0.05, 0.33),
            signInButton: (0.12, 0.85),
            invalidLabel: (0.35, 0.5),
            newUserButton: (0.3, 0.85),
            guestButton: (0.2, 0.85),
        ]
        
        // Do other UI setup
        setUIDefaults()
    }
    
    func setUIDefaults() {
        setTextToDefaults(labels: [titleLabel, welcomeLabel, usernameLabel, passwordLabel, rememberLabel, invalidLabel])
        setButtonsToDefaults(buttons: [newUserButton, signInButton, guestButton])
        setButtonsToDefaults(buttons: [showPasswordButton], withInsets: 10)
        
        usernameField.layer.borderColor = globalTextColor().cgColor
        passwordField.layer.borderColor = globalTextColor().cgColor
        usernameField.text = ""
        passwordField.text = ""
        invalidLabel.text = ""
        invalidLabel.font = .italicSystemFont(ofSize: 30)
        invalidLabel.isHidden = true
        signInButton.isEnabled = false
        showPasswordButton.setTitle("Show", for: .normal)
        showPasswordButton.setTitleColor(.gray, for: .normal)
        showPasswordButton.layer.cornerRadius = 5
        showPasswordButton.layer.borderColor = globalTextColor().cgColor
        showPasswordButton.layer.borderWidth = 1
    }
    
    // MARK: Constraints

    func configureConstraints(view: UIView)  {
        let margins = view.layoutMarginsGuide
        
        // Portrait
        portraitConstraints += getFullVerticalConstraints(topAnchor: margins.topAnchor, bottomAnchor: margins.bottomAnchor, verticalConstraintMap: portraitVerticalMap, parentView: view)
        portraitConstraints += getFullHorizontalConstraints(leftAnchor: margins.leftAnchor, rightAnchor: margins.rightAnchor, horizontalConstraintMap: portraitHorizontalMap, parentView: view)
        
        // Landscape
        landscapeConstraints += getFullVerticalConstraints(topAnchor: margins.topAnchor, bottomAnchor: margins.bottomAnchor, verticalConstraintMap: landscapeVerticalMap, parentView: view)
        landscapeConstraints += getFullHorizontalConstraints(leftAnchor: margins.leftAnchor, rightAnchor: margins.rightAnchor, horizontalConstraintMap: landscapeHorizontalMap, parentView: view)
        
        view.backgroundColor = globalBackgroundColor()
    }
    
    func activateConstraints(isPortrait: Bool) {
        if isPortrait {
            NSLayoutConstraint.deactivate(landscapeConstraints)
            NSLayoutConstraint.activate(portraitConstraints)
            if signInButton.titleLabel?.text == "Sign In" {
                welcomeLabel.text = "Welcome!\nPlease sign in to continue."
            } else {
                welcomeLabel.text = "Welcome!\nCreate an account below."
            }
            self.isPortrait = true
        } else {
            NSLayoutConstraint.deactivate(portraitConstraints)
            NSLayoutConstraint.activate(landscapeConstraints)
            if signInButton.titleLabel?.text == "Sign In" {
                welcomeLabel.text = "Welcome! Please sign in to continue."
            } else {
                welcomeLabel.text = "Welcome! Create an account below."
            }
            self.isPortrait = false
        }
    }
    
    func switchToReturningUser() {
        invalidLabel.isHidden = true
        welcomeLabel.text = isPortrait ? "Welcome!\nPlease sign in to continue." : "Welcome! Please sign in to continue."
        signInButton.setTitle("Sign In", for: .normal)
        newUserButton.setTitle("New user? Create an account!", for: .normal)
    }
    
    func switchToNewUser() {
        invalidLabel.isHidden = true
        welcomeLabel.text = isPortrait ? "Welcome!\nCreate an account below." : "Welcome! Create an account below."
        signInButton.setTitle("Create", for: .normal)
        newUserButton.setTitle("Returning user? Sign in!", for: .normal)
    }
}
