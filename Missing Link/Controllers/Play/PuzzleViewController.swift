//
//  PuzzleViewController.swift
//  Missing Link
//
//  Created by Benjamin Share on 8/30/19.
//  Copyright © 2019 Benjamin Share. All rights reserved.
//

import UIKit

class PuzzleViewController: UIViewController, UITextFieldDelegate {
    
    //MARK: Properties
    
    // Public variables
    var level: PuzzleLevel!
    var levelIndex: Int!
    var levelProgress: LevelProgress?
    var loggedInUser: LoggedInUser?
    
    // Formatting
    private var layout: PuzzleViewLayout!
    
    // Values to track
    private var answer: String = ""
    private var inHintMode: Bool = false
    private let showHintLetter: Bool = true
    private var shownHintLetterIndex: Int = -1
    private var shownHintLetterValue: String = ""
    private var lastActionTime: Date!
    
    // Outlets
    @IBOutlet weak var firstWord: UILabel!
    @IBOutlet weak var lastWord: UILabel!
    @IBOutlet weak var link: UITextField!
    @IBOutlet weak var feedbackButton: UIBarButtonItem!
    @IBOutlet weak var puzzleLabel: UILabel!
    @IBOutlet weak var hintButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var newSolutionButton: UIButton!
    
    // Other UI elements
    private var hintModeLetters = [UITextField]()
    private var newSolutionView: NewSolutionView?
    var ratingView: RatingView?
    
    
    // MARK: Initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        for _ in 0...MAX_LETTERS_IN_LINK-1 {
            let letter  = UITextField()
            hintModeLetters.append(letter)
            view.addSubview(letter)
        }
        
        setPuzzleWords()
        setPuzzleLabel()
        
        layout = PuzzleViewLayout(firstWord: firstWord, lastWord: lastWord, link: link, puzzleLabel: puzzleLabel, hintButton: hintButton, skipButton: skipButton, newSolutionButton: newSolutionButton, hintModeLetters: hintModeLetters)
        layout.configureConstraints(view: view)
        layout.configureHintLetterConstraints(view: view, length: answer.count)
        
        link.delegate = self as UITextFieldDelegate
        link.adjustsFontSizeToFitWidth = false
        link.autocapitalizationType = .allCharacters
        link.autocorrectionType = .no
        link.spellCheckingType = .no
        
        hintButton.addTarget(self, action: #selector(getHint), for: .touchUpInside)
        skipButton.addTarget(self, action: #selector(skipPuzzle), for: .touchUpInside)
        newSolutionButton.addTarget(self, action: #selector(getNewSolution), for: .touchUpInside)
        
        setCoinsLabel()
        
        if showHintLetter {
            shownHintLetterIndex = hintLetterToShow(level: level, answer: answer)
            shownHintLetterValue = String(answer[answer.index(answer.startIndex, offsetBy: shownHintLetterIndex)...answer.index(answer.startIndex, offsetBy: shownHintLetterIndex)])
            hintModeLetters[shownHintLetterIndex].font = UIFont.boldSystemFont(ofSize: hintModeLetters[shownHintLetterIndex].font!.pointSize)
        }
        
        redrawScene()

        view.backgroundColor = globalBackgroundColor()
    }
    
    // MARK: UI
    func redrawScene() {
        layout.activateConstraints(isPortrait: orientationIsPortrait())
    }
    
    func setPuzzleLabel() {
        puzzleLabel.text = "\(level.currentPuzzle() + 1) / \(level.length())"
    }
    
    @objc func setCoinsLabel() {
        layout.setCoinsLabel(coins: (loggedInUser?.user.rewards.coins)!)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        redrawScene()
        if newSolutionView != nil {
            newSolutionView?.redrawScene(newOrientation: orientationIsPortrait())
        }
        if ratingView != nil {
            ratingView?.activateConstraints(isPortrait: orientationIsPortrait())
        }
    }
    
    @objc func alertControllerBackgroundTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Puzzle
    func setPuzzleWords() {
        let puzzle = level!.getPuzzle()!
        firstWord.text = puzzle.first().uppercased()
        lastWord.text = puzzle.last().uppercased()
        answer = puzzle.answer().uppercased()
        lastActionTime = Date()
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
    
    @objc func textFieldDidChange() {
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
        level.completePuzzle()
        if levelProgress!.status == .completed {
            Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(nextPuzzle), userInfo: nil, repeats: false)
            return
        }
        // It was a new puzzle, so update accordingly
        layout.setCoinsLabel(coins: (loggedInUser?.user.rewards.coins)! + 1, animate: true)
        levelProgress?.completePuzzle(newNext: level.currentPuzzle())
        updateRewardsOnLevelComplete(rewards: (loggedInUser?.user.rewards)!)
        loggedInUser?.user.data.playData.updateOnPuzzleComplete()
        if (loggedInUser?.user.preferences.allowMetadataCollection)! {
            loggedInUser?.user.data.playData.metadata.update(puzzle: level.getPuzzle()!, action: .complete, time: Date().timeIntervalSince(lastActionTime))
        }
        
        if loggedInUser!.user.preferences.submitDifficultyFeedback {
            Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(getRatingView), userInfo: nil, repeats: false)
        }
        
        let wasLastPuzzle = level.isLevelComplete()
        if wasLastPuzzle {
            Timer.scheduledTimer(timeInterval: 1.1, target: self, selector: #selector(puzzlesCompleted), userInfo: nil, repeats: false)
        } else {
            updateSyncedUserProgress(progress: (loggedInUser?.user.progress)!)
            Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(nextPuzzle), userInfo: nil, repeats: false)
        }
    }
    
    @objc func nextPuzzle() {
        setPuzzleWords()
        setPuzzleLabel()
        resetHintMode()
    }
    
    @objc func puzzlesCompleted() {
        DispatchQueue.global(qos: .background).async {
            RATING_GROUP.wait()
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "doneWithLevel", sender: self)
            }
        }
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
    
    func resetHintMode() {
        layout.setLinkToDefaults()
        layout.configureHintLetterConstraints(view: view, length: answer.count)
        hintModeLetters[shownHintLetterIndex].font = UIFont.systemFont(ofSize: hintModeLetters[shownHintLetterIndex].font!.pointSize)
        shownHintLetterIndex = hintLetterToShow(level: level, answer: answer)
        shownHintLetterValue = String(answer[answer.index(answer.startIndex, offsetBy: shownHintLetterIndex)...answer.index(answer.startIndex, offsetBy: shownHintLetterIndex)])
        hintModeLetters[shownHintLetterIndex].font = UIFont.boldSystemFont(ofSize: hintModeLetters[shownHintLetterIndex].font!.pointSize)
        inHintMode = false
        redrawScene()
    }
    
    // MARK: New Solution
    @objc func getNewSolution() {
        hintButton.isEnabled = false
        newSolutionButton.isEnabled = false
        newSolutionView = openNewSolutionView(parentView: view, parentController: self, user: (loggedInUser?.user)!, first: firstWord.text!, last: lastWord.text!, answer: link.text!)
    }
    
    // MARK: Rating View
    @objc func getRatingView() {
        ratingView = RatingView(user: loggedInUser!.user, metadata: loggedInUser!.user.data.playData.metadata, puzzle: level.getPuzzle()!, parentController: self)
        view.addSubview(ratingView!)
        ratingView!.configureView()
        ratingView!.activateConstraints(isPortrait: orientationIsPortrait())
        ratingView!.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
    }
        
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch (segue.identifier ?? "") {
        case "doneWithLevel":
            let dest = segue.destination as! LevelSelectionCollectionViewController
            dest.loggedInUser = loggedInUser
        case "feedbackButton":
            let dest = segue.destination as! FeedbackViewController
            dest.loggedInUser = loggedInUser
            dest.source = .puzzle
        default:
            fatalError("Unexpected Segue Identifier; \(segue.identifier ?? "unknown")")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if self.isMovingFromParent {
            let ls = self.navigationController?.viewControllers.last as! LevelSelectionCollectionViewController
            ls.loggedInUser = loggedInUser
            if (loggedInUser?.user.preferences.allowMetadataCollection)! {
                loggedInUser?.user.data.playData.metadata.update(puzzle: level.getPuzzle()!, action: .skip, time: Date().timeIntervalSince(lastActionTime))
            }
        }
    }
    
    @IBAction func unwindToPuzzleView(segue: UIStoryboardSegue) {
        if !(segue.source is FeedbackViewController) {
            print("Unexpected source for PuzzleViewController: \(segue.source)")
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
        if purchase(rewards: (loggedInUser?.user.rewards)!, cost: PLAY_MODE_HINT_COST) {
            layout.setCoinsLabel(coins: (loggedInUser?.user.rewards.coins)!, animate: true)
            inHintMode = true
            layout.activateHintMode(isPortrait: orientationIsPortrait())
            link.text = String(link.text!.prefix(hintModeLetters.count))
            updateLettersToMatchLink()
            let now = Date()
            if (loggedInUser?.user.preferences.allowMetadataCollection)! {
                loggedInUser?.user.data.playData.metadata.update(puzzle: level.getPuzzle()!, action: .hint, time: now.timeIntervalSince(lastActionTime))
            }
            lastActionTime = now
        } else {
            let alert = notEnoughCoinsAlert(controller: self)
            self.present(alert, animated: true, completion: {
                alert.view.superview?.isUserInteractionEnabled = true
                alert.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
            })
        }
    }
    
    @IBAction func skipPuzzle() {
        level.skipPuzzle()
        levelProgress?.nextPuzzle = level.currentPuzzle()
        setPuzzleWords()
        setPuzzleLabel()
        resetHintMode()
        if (loggedInUser?.user.preferences.allowMetadataCollection)! {
            loggedInUser?.user.data.playData.metadata.update(puzzle: level.getPuzzle()!, action: .skip, time: Date().timeIntervalSince(lastActionTime))
        }
    }
}

