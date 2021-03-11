//
//  NewSolutionView.swift
//  Missing Link
//
//  Created by Benjamin Share on 11/19/20.
//  Copyright © 2020 Benjamin Share. All rights reserved.
//

import Foundation
import UIKit

class NewSolutionView: UIView {
    // MARK: Properties
    private var user: User?
    private var blurView: UIVisualEffectView?
    var parentController: UIViewController?
    
    // Constants
    
    // Formatting
    private var orientationIsPortrait: Bool = true
    private var layout: NewSolutionViewLayout?
    var parentView: UIView!
    
    // UI elements
    private var titleLabel = UILabel()
    private var closeButton = UIButton()
    private var submitButton = UIButton()
    private var solutionCell = NewSolutionCell()
    
    
    // MARK: Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureView() {
        self.widthAnchor.constraint(equalTo: parentView.widthAnchor, multiplier: 0.75).isActive = true
        self.heightAnchor.constraint(equalTo: parentView.heightAnchor, multiplier: 0.75).isActive = true
        self.centerXAnchor.constraint(equalTo: parentView.centerXAnchor).isActive = true
        self.centerYAnchor.constraint(equalTo: parentView.centerYAnchor).isActive = true
        
        closeButton.addTarget(self, action: #selector(closeView), for: .touchUpInside)
        submitButton.addTarget(self, action: #selector(submit), for: .touchUpInside)
        
        if let controller = parentController as? DailyPuzzleViewController {
            controller.hintButton.isEnabled = false
            controller.newSolutionButton.isEnabled = false
        } else if let controller = parentController as? PuzzleViewController {
            controller.hintButton.isEnabled = false
            controller.skipButton.isEnabled = false
            controller.newSolutionButton.isEnabled = false
        } else {
            fatalError("Opened new solution view from unexpected source")
        }
        
        self.layout = NewSolutionViewLayout(titleLabel: titleLabel, closeButton: closeButton, submitButton: submitButton, solutionCell: solutionCell)
        orientationIsPortrait = UIDevice.current.orientation.isPortrait || UIDevice.current.orientation.isFlat
        layout!.configureConstraints(view: self, isPortrait: orientationIsPortrait)
        solutionCell.configureView()
        redrawScene(newOrientation: orientationIsPortrait)
    }
    
    func setSolutionCellWords(first: String, answer: String, last: String) {
        solutionCell.setWords(first: first, answer: answer, last: last)
    }
    
    func setUserAndBlur(user: User, blurView: UIVisualEffectView) {
        self.user = user
        self.blurView = blurView
    }
    
    // MARK: UI
    func redrawScene(newOrientation: Bool) {
        orientationIsPortrait = newOrientation
        if orientationIsPortrait {
            layout!.activatePortraitConstraints()
        } else {
            layout!.activateLandscapeConstraints()
        }
    }
    
    // MARK: Close
    @objc private func closeView() {
        if let controller = parentController as? DailyPuzzleViewController {
            controller.hintButton.isEnabled = true
            controller.newSolutionButton.isEnabled = true
        } else if let controller = parentController as? PuzzleViewController {
            controller.hintButton.isEnabled = true
            controller.skipButton.isEnabled = true
            controller.newSolutionButton.isEnabled = true
        } else {
            fatalError("Closing new solution view from unexpected source")
        }
        blurView?.removeFromSuperview()
        self.removeFromSuperview()
    }
    
    // MARK: Submit
    @objc private func submit() {
        postUserFeedback(source: .newSolution, user: user!, feedback: solutionCell.getFeedbackText())
        print("Thanks for submitting a new solution!")
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(closeView), userInfo: nil, repeats: false)
    }
}
