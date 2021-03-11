//
//  LoginPageViewController.swift
//  Missing Link
//
//  Created by Benjamin Share on 9/20/19.
//  Copyright © 2019 Benjamin Share. All rights reserved.
//

import UIKit

class LoginPageViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var showPasswordButton: UIButton!
    @IBOutlet weak var rememberLabel: UILabel!
    @IBOutlet weak var rememberSwitch: UISwitch!
    @IBOutlet weak var invalidLabel: UILabel!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var guestButton: UIButton!
    @IBOutlet weak var newUserButton: UIButton!
    
    // MARK: User info
    private var rememberedUser: User?
    private var userLoggingIn: User?
    
    // MARK: Values to track
    private var usernameIsValid: Bool = false
    private var passwordisValid: Bool = false
    private var isReturningUser: Bool = true
    
    // MARK: Formatting
    private var layout: LoginPageViewLayout!
    
    // MARK: Initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        
        layout = LoginPageViewLayout(titleLabel: titleLabel, welcomeLabel: welcomeLabel, usernameLabel: usernameLabel, usernameField: usernameField, passwordLabel: passwordLabel, passwordField: passwordField, showPasswordButton: showPasswordButton, rememberLabel: rememberLabel, rememberSwitch: rememberSwitch, invalidLabel: invalidLabel, signInButton: signInButton, guestButton: guestButton, newUserButton: newUserButton)
        layout.configureConstraints(view: view)
        redrawScene()
        
        usernameField.delegate = self as UITextFieldDelegate
        usernameField.addTarget(self, action: #selector(usernameFieldDidChange), for: .editingChanged)
        
        passwordField.delegate = self as UITextFieldDelegate
        passwordField.addTarget(self, action: #selector(passwordFieldDidChange), for: .editingChanged)
        passwordField.isSecureTextEntry = true
        
        showPasswordButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        
        signInButton.addTarget(self, action: #selector(signIn), for: .touchDown)
        newUserButton.addTarget(self, action: #selector(toggleNewUser), for: .touchDown)
        
        if !isReturningUser {
            toggleNewUser()
        }
        
        if checkForConnection() {
            fetchTopUsersLeaderboardData()
            fetchNewDailyPuzzleData()
                
            rememberedUser = readFromUserDefaults()
            if rememberedUser != nil {
                logInRememberedUser(user: rememberedUser!)
            }
        } else {
            fatalError("Offline behavior not implemented.")
        }
    }
    
    // MARK: UI
    private func redrawScene() {
        layout.activateConstraints(isPortrait: orientationIsPortrait())
    }
    
    override func viewDidLayoutSubviews() {
        redrawScene()
    }
    
    // MARK: Text Field Delegate
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: User Input
    @objc func usernameFieldDidChange() {
        usernameIsValid = isValidUsername(username: usernameField.text!)
        signInButton.isEnabled = usernameIsValid && passwordisValid
    }
    
    @objc func passwordFieldDidChange() {
        passwordisValid = isValidPassword(password: passwordField.text!)
        signInButton.isEnabled = usernameIsValid && passwordisValid
    }
    
    private func isValidUsername(username: String) -> Bool {
        return username.count > 2
    }
    
    private func isValidPassword(password: String) -> Bool {
        return password.count > 2
    }

    private func doesPasswordConvertToHash(username: String, password: String, hash: String) -> Bool {
        return passwordHashFunction(username, password) == hash
    }
    

    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let homepage = segue.destination as! HomePageViewController
        
        fetchVisiblePackData()
        fetchDataForPacks(packs: getDefaultUnlockedPackNames())
//        fetchAggregatePackData(progresses: [:])
//        fetchVisiblePackData()
//        fetchAggregatePackData(progresses: userLoggingIn!.progress.pack_progresses)
        
        var loggedInUser: LoggedInUser
        switch segue.identifier {
        case "newUserSegue":
            homepage.shouldDisplayTutorialAlert = true
            fallthrough
        case "returningUserSegue":
            loggedInUser = LoggedInUser(user: userLoggingIn!, rememberMe: rememberSwitch.isOn)
            loggedInUser.isGuest = false
        case "guestSegue":
            userLoggingIn = User(username: "", password: "")
            loggedInUser = LoggedInUser(user: userLoggingIn!, rememberMe: false)
            loggedInUser.isGuest = true
            homepage.shouldDisplayTutorialAlert = true
        case "feedbackButton":
            fatalError("Feedback button not implemented from login page")
        default:
            fatalError("Unexpected segue from login page.")
        }
        homepage.loggedInUser = loggedInUser
        if !loggedInUser.isGuest {
            setUserToSync(user: loggedInUser.user, remember: loggedInUser.rememberMe)
        }
        
        // Reset UI
        layout.setUIDefaults()
    }
    
    @IBAction func unwindToLoginPage(segue: UIStoryboardSegue) {
        if !(segue.source is FeedbackViewController) {
            print("Unexpected source for LoginPageViewController: \(segue.source)")
        }
    }

    // MARK: Buttons
    @IBAction func toggleNewUser() {
        isReturningUser = !isReturningUser
        if isReturningUser {
            layout.switchToReturningUser()
        } else {
            layout.switchToNewUser()
        }
    }
    
    @IBAction func signIn() {
        if isReturningUser {
            guard var username = usernameField.text else {
                fatalError("Couldn't access username field")
            }
            guard let password = passwordField.text else {
                fatalError("Couldn't access password field")
            }
            username = username.trimmingCharacters(in: .whitespacesAndNewlines)
            
            let newUser = User(username: username, password: password)
            let info = getLoginForUser(user: newUser)
            if !info.found {
                invalidLabel.text = "Sorry, unknown username. Try again."
                invalidLabel.isHidden = false
                return
            }
            if !doesPasswordConvertToHash(username: username, password: password, hash: info.hash) {
                invalidLabel.text = "Sorry, incorrect password. Try again."
                invalidLabel.isHidden = false
                return
            }
            userLoggingIn = newUser
            // Needed cause of caps
            userLoggingIn?.username = info.username
            let progressAndData = getFullProgressForUser(user: userLoggingIn!)
            userLoggingIn?.progress = progressAndData.0
            userLoggingIn?.data = progressAndData.1
            userLoggingIn?.rewards = progressAndData.2
            userLoggingIn?.preferences = progressAndData.3
            userLoggingIn?.data.playData.updateTodayIfExpired()
            userLoggingIn?.data.dailyData.updateStreakIfExpired()
            if rememberSwitch.isOn {
                writeUserToDefaultsNoCheck(user: userLoggingIn!)
            }
            performSegue(withIdentifier: "returningUserSegue", sender: self)
        } else {
            print()
            guard let username = usernameField.text else {
                fatalError("Couldn't access username field")
            }
            guard let password = passwordField.text else {
                fatalError("Couldn't access password field")
            }
            let newUser = User(username: username, password: password)
            if createAccountForUser(user: newUser) {
                userLoggingIn = newUser
                if rememberSwitch.isOn {
                    writeUserToDefaultsNoCheck(user: userLoggingIn!)
                }
                performSegue(withIdentifier: "newUserSegue", sender: self)
            } else {
                invalidLabel.text = "Username already exists. Try again."
                invalidLabel.isHidden = false
            }
        }
    }
    
    @IBAction func togglePasswordVisibility() {
        if showPasswordButton.titleLabel!.text == "Show" {
            passwordField.isSecureTextEntry = false
            showPasswordButton.setTitle("Hide", for: .normal)
        } else {
            passwordField.isSecureTextEntry = true
            showPasswordButton.setTitle("Show", for: .normal)
        }
    }
    
    func logInRememberedUser(user: User) {
        let info = getLoginForUser(user: user)
        if !info.found || user.passwordHash != info.hash {
            print("Remembered user contains outdated information, deleting.\n")
            clearRememberedUser()
            return
        }

        userLoggingIn = user
        let fetched = getFullProgressForUser(user: userLoggingIn!)
        resolveRememberedAndFetchedProgresses(rememberedUser: userLoggingIn!, fetchedProgress: fetched)
        userLoggingIn?.data.playData.updateTodayIfExpired()
        userLoggingIn?.data.dailyData.updateStreakIfExpired()
        writeUserToDefaultsNoCheck(user: userLoggingIn!)
        rememberSwitch.isOn = true
        performSegue(withIdentifier: "returningUserSegue", sender: self)
    }
}
