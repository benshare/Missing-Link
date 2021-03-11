//
//  TutorialViewController.swift
//  Missing Link
//
//  Created by Benjamin Share on 11/30/20.
//  Copyright © 2020 Benjamin Share. All rights reserved.
//

import Foundation
import UIKit

class TutorialViewController: UIViewController {
    
    // MARK: Properties
    public var loggedInUser: LoggedInUser?
    
    // Formatting
    private var layout: TutorialLayout!
    private var orientationIsPortrait: Bool = true
    
    // MARK: Outlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIStackView!
    @IBOutlet weak var feedbackButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        layout = TutorialLayout(scrollView: scrollView, contentView: contentView)
        layout.configureView(margins: view.layoutMarginsGuide)
        orientationIsPortrait = UIDevice.current.orientation.isPortrait || UIDevice.current.orientation.isFlat
        redrawScene()
    }
    
    // MARK: UI
    private func redrawScene() {
        layout.activateConstraints(orientationIsPortrait: orientationIsPortrait)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if orientationIsPortrait != UIDevice.current.orientation.isPortrait || UIDevice.current.orientation.isFlat {
            orientationIsPortrait = !orientationIsPortrait
            redrawScene()
        }
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch (segue.identifier ?? "") {
        case "feedbackButton":
            let dest = segue.destination as! FeedbackViewController
            dest.loggedInUser = loggedInUser
            dest.source = .tutorial
        default:
            fatalError("Unexpected Segue Identifier; \(segue.identifier ?? "unknown")")
        }
    }
    
    @IBAction func unwindToAccountPage(segue: UIStoryboardSegue) {
        if !(segue.source is FeedbackViewController) {
            print("Unexpected source for AccountViewController: \(segue.source)")
        }
    }
}
