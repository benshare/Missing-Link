//
//  DailyPuzzleViewController.swift
//  Missing Link
//
//  Created by Benjamin Share on 7/3/20.
//  Copyright © 2020 Benjamin Share. All rights reserved.
//

import Foundation
import UIKit

class DailyPuzzleViewController: UIViewController, UITextFieldDelegate {
    //MARK: Properties
    
    // Public variables
    var puzzle: Puzzle?
    var loggedInUser: LoggedInUser?
    var isPuzzleCompleted: Bool = false
    
    // Formatting
    private var layout: DailyPuzzleViewLayout!
    
    // Values to track
    private var answer: String = ""
    private var inHintMode: Bool = false
    private let showHintLetter: Bool = true
    private var shownHintLetterIndex: Int = -1
    private var shownHintLetterValue: String = ""

    // Outlets
    @IBOutlet weak var firstWord: UILabel!
    @IBOutlet weak var lastWord: UILabel!
    @IBOutlet weak var link: UITextField!
    @IBOutlet weak var hintButton: UIButton!
    @IBOutlet weak var newSolutionButton: UIButton!
    @IBOutlet weak var feedbackButton: UIBarButtonItem!
    
    // Other UI elements
    private var hintModeLetters = [UITextField]()
    private var newSolutionView: NewSolutionView?
    
    
    // MARK: Initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        
        puzzle = DAILY_PUZZLE
        isPuzzleCompleted = loggedInUser?.user.data.dailyData.lastDayInStreak == DATE_FORMATTER.string(from: Date())
        
        setPuzzleWords()
        if DAILY_PUZZLE.answer() == "" {
            layout = DailyPuzzleViewLayout(firstWord: firstWord, lastWord: lastWord, link: link, hintButton: hintButton, newSolutionButton: newSolutionButton, hintModeLetters: hintModeLetters)
            layout.configureConstraints(view: view)
            setLabels()
            redrawScene()
            hintButton.isEnabled = false
            newSolutionButton.isEnabled = false
            view.backgroundColor = globalBackgroundColor()
            return
        }
        
        if !isPuzzleCompleted {
            hintButton.addTarget(self, action: #selector(getHint), for: .touchUpInside)
            for _ in 0...MAX_LETTERS_IN_LINK-1 {
                let letter  = UITextField()
                hintModeLetters.append(letter)
                view.addSubview(letter)
            }
        }
        
        layout = DailyPuzzleViewLayout(firstWord: firstWord, lastWord: lastWord, link: link, hintButton: hintButton, newSolutionButton: newSolutionButton, hintModeLetters: hintModeLetters)
        layout.configureConstraints(view: view)
        
        link.delegate = self as UITextFieldDelegate
        link.adjustsFontSizeToFitWidth = false
        link.autocapitalizationType = .allCharacters
        link.autocorrectionType = .no
        link.spellCheckingType = .no
        
        setLabels()
        newSolutionButton.addTarget(self, action: #selector(getNewSolution), for: .touchUpInside)
        
        if !isPuzzleCompleted {
            layout.configureHintLetterConstraints(view: view, length: answer.count)
            if showHintLetter {
                shownHintLetterIndex = hintLetterToShow(level: PuzzleLevel(db_id: -1, puzzle_data: [[(puzzle?.first())!, (puzzle?.last())!, (puzzle?.answer())!]]), answer: answer)
                shownHintLetterValue = String(answer[answer.index(answer.startIndex, offsetBy: shownHintLetterIndex)...answer.index(answer.startIndex, offsetBy: shownHintLetterIndex)])
                hintModeLetters[shownHintLetterIndex].font = UIFont.boldSystemFont(ofSize: hintModeLetters[shownHintLetterIndex].font!.pointSize)
            }
        }
        
        redrawScene()
        
        view.backgroundColor = globalBackgroundColor()
    }
    
    // MARK: UI
    func redrawScene() {
        layout.activateConstraints(isPortrait: orientationIsPortrait())
    }
    
    @objc func setLabels() {
        layout.setCoinsAndStreakLabels(coins: (loggedInUser?.user.rewards.coins)!, streak: (loggedInUser?.user.data.dailyData.streak)!)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        redrawScene()
        if newSolutionView != nil {
            newSolutionView?.redrawScene(newOrientation: orientationIsPortrait())
        }
    }

    // MARK: Puzzle
    func setPuzzleWords() {
        let p = puzzle!
        firstWord.text = p.first().uppercased()
        lastWord.text = p.last().uppercased()
        if p.answer() == "" {
            link.text = "No puzzle today -- check back soon!"
            link.font = UIFont.systemFont(ofSize: 17)
            return
        }
        if isPuzzleCompleted {
            link.text = p.answer().uppercased()
            link.textColor = .green
            link.isEnabled = false
            return
        }
        answer = p.answer().uppercased()
    }
    
    func checkTextField() {
        if inHintMode {
            updateLettersToMatchLink()
        }
        if link.text! == answer {
            wordCorrect()
        } else {
            if inHintMode && showHintLetter && link.text!.count == shownHintLetterIndex && link.text! + shownHintLetterValue == answer {
                wordCorrect()
            }
        }
    }

    func wordCorrect() {
        if inHintMode {
            for letter in hintModeLetters {
                letter.textColor = .green
            }
        } else {
            link.textColor = .green
        }
        link.isEnabled = false
        let daily = (loggedInUser?.user.data.dailyData)!
        layout.setCoinsAndStreakLabels(coins: (loggedInUser?.user.rewards.coins)! + 1, streak: daily.streak + 1, animate: true)
        daily.updateOnDailyComplete()
        syncUserProgress()
        updateRewardsOnLevelComplete(rewards: (loggedInUser?.user.rewards)!)
        updateSyncedUserData(dailyData: daily)
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(puzzleCompleted), userInfo: nil, repeats: false)
    }
    
    // MARK: Hint Mode
    func updateLettersToMatchLink() {
        let text = link.text!
        for i in 0...hintModeLetters.count-1 {
            if showHintLetter {
                if i == shownHintLetterIndex {
                    hintModeLetters[i].text = shownHintLetterValue
                    continue
                }
            }
            if link.text!.count > i {
                hintModeLetters[i].text = String(text[text.index(text.startIndex, offsetBy: i)])
            }
            else {
                hintModeLetters[i].text = ""
            }
        }
    }
    
    @objc func setCursorToEnd(textField: UITextField) {
        textField.selectedTextRange = textField.textRange(from: textField.endOfDocument, to: textField.endOfDocument)
    }
    
    @objc func puzzleCompleted() {
        performSegue(withIdentifier: "doneWithDaily", sender: self)
    }
    
    // MARK: New Solution
    @objc func getNewSolution() {
        hintButton.isEnabled = false
        newSolutionButton.isEnabled = false
        newSolutionView = openNewSolutionView(parentView: view, parentController: self, user: (loggedInUser?.user)!, first: firstWord.text!, last: lastWord.text!, answer: link.text!)
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch (segue.identifier ?? "") {
        case "feedbackButton":
            let dest = segue.destination as! FeedbackViewController
            dest.loggedInUser = loggedInUser
            dest.source = .dailyPuzzle
        case "doneWithDaily":
            let dest = segue.destination as! HomePageViewController
            dest.loggedInUser = loggedInUser
        default:
            fatalError("Unexpected Segue Identifier; \(segue.identifier ?? "unknown")")
        }
    }
    
    @IBAction func unwindToDailyPuzzle(segue: UIStoryboardSegue) {
        if !(segue.source is FeedbackViewController) {
            print("Unexpected source for DailyPuzzleViewController: \(segue.source)")
        }
    }
    
    // MARK: Text Field Delegate
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !inHintMode {
            self.view.endEditing(true)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField != link {
            fatalError("Unknown text field being edited")
        }
        if inHintMode {
            setCursorToEnd(textField: textField)
        }
        let char = string.cString(using: String.Encoding.utf8)
        let isBackSpace = strcmp(char, "\\b")
        if isBackSpace == -92 {
            if inHintMode && showHintLetter && link.text!.count == shownHintLetterIndex + 1 {
                link.text! = String(link.text!.dropLast())
            }
            return true
        }
        if textField.text?.count == MAX_LETTERS_IN_LINK {
            return false
        }
        if inHintMode {
            if textField.text!.count >= answer.count {
                return false
            }
            if showHintLetter && textField.text!.count == shownHintLetterIndex {
                link.text! += shownHintLetterValue
            }
        }
        link.text! += string.uppercased()
        checkTextField()
        
        return false
    }
    
    // MARK: Menu
    @IBAction func getHint() {
        if purchase(rewards: (loggedInUser?.user.rewards)!, cost: DAILY_MODE_HINT_COST) {
            layout.setCoinsLabel(coins: (loggedInUser?.user.rewards.coins)!)
            inHintMode = true
            layout.activateHintMode(isPortrait: orientationIsPortrait())
            link.text = String(link.text!.prefix(answer.count))
            updateLettersToMatchLink()
        } else {
            let alert = UIAlertController(title: "Not enough coins", message: "Sorry, you need to have at least \(DAILY_MODE_HINT_COST) coins for that action!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: {
                action in
                self.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: {
                alert.view.superview?.isUserInteractionEnabled = true
                alert.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
            })
        }
    }
    
    @objc func alertControllerBackgroundTapped() {
        self.dismiss(animated: true, completion: nil)
    }
}

