//
//  AlertUtil.swift
//  Missing Link
//
//  Created by Benjamin Share on 11/29/20.
//  Copyright © 2020 Benjamin Share. All rights reserved.
//

import Foundation
import UIKit

func tutorialAlert(controller: UIViewController, actions: [UIAlertAction]) -> UIAlertController {
    let alert = UIAlertController(title: "First time?", message: "Want to view the Missing Link tutorial?", preferredStyle: .alert)
    for action in actions {
        alert.addAction(action)
    }
    return alert
}

func notEnoughCoinsAlert(controller: UIViewController) -> UIAlertController {
    let alert = UIAlertController(title: "Not enough coins", message: "Sorry, you need to have at least \(PLAY_MODE_HINT_COST) coins for that action!", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: {
        action in
        controller.dismiss(animated: true, completion: nil)
    }))
    return alert
}

func sheetWithActions(controller: UIViewController, actions: [UIAlertAction]) -> UIAlertController {
    let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    for action in actions {
        alert.addAction(action)
    }
    alert.pruneNegativeWidthConstraints()
    return alert
}

func alertWithContent(controller: UIViewController, content: String) -> UIAlertController {
    let alert = UIAlertController(title: "What does this option mean?", message: content, preferredStyle: .alert)
    return alert
}

extension UIAlertController {
    func pruneNegativeWidthConstraints() {
        for subView in self.view.subviews {
            for constraint in subView.constraints where constraint.debugDescription.contains("width == - 16") {
                subView.removeConstraint(constraint)
            }
        }
    }
}
