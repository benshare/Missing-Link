//
//  FeedbackViewController.swift
//  Missing Link
//
//  Created by Benjamin Share on 7/19/20.
//  Copyright © 2020 Benjamin Share. All rights reserved.
//

import Foundation
import UIKit

class FeedbackViewController: UIViewController, UITextViewDelegate {
    
    public var loggedInUser: LoggedInUser?
    public var source: FeedbackSource!
    
    // Formatting
    private var layout: FeedbackViewLayout!
    
    // MARK: Outlets
    @IBOutlet weak var headlineLabel: UILabel!
    @IBOutlet weak var feedbackField: UITextView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var thanksLabel: UILabel!
    
    // MARK: Initialization
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        feedbackField.delegate = self as UITextViewDelegate
        
        self.submitButton.addTarget(self, action: #selector(submitFeedback), for: .touchDown)
        self.submitButton.isEnabled = false
        
        layout = FeedbackViewLayout(headlineLabel: headlineLabel, feedbackField: feedbackField, submitButton: submitButton, thanksLabel: thanksLabel)
        layout.configureConstraints(view: view, margins: view.layoutMarginsGuide)
        redrawScene()
    }
    
    // MARK: UI
    private func redrawScene() {
        layout.activateConstraints(isPortrait: orientationIsPortrait())
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        redrawScene()
    }
    
    // MARK: Submission
    
    @IBAction func submitFeedback() {
        postUserFeedback(source: source, user: (loggedInUser?.user)!, feedback: feedbackField.text)
        if !loggedInUser!.isGuest {
            let data = (loggedInUser?.user.data.contributionsData)!
            data.updateAfterSubmittingFeedback()
            updateSyncedUserData(contributionsData: data)
        }
        let alert = UIAlertController(title: "Thanks for submitting feedback!", message: "", preferredStyle: .alert)
        self.present(alert, animated: true, completion: {
            alert.view.superview?.isUserInteractionEnabled = true
            alert.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
        })
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(unwindScene), userInfo: nil, repeats: false)
    }
    
    @objc func alertControllerBackgroundTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func unwindScene() {
        self.dismiss(animated: true, completion: nil)
        _ = navigationController?.popViewController(animated: true)
    }
    
    
    // MARK: Text Field
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        submitButton.isEnabled = !textView.text.isEmpty
    }
}
