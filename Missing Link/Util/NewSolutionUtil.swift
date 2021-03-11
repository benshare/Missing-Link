//
//  NewSolutionUtil.swift
//  Missing Link
//
//  Created by Benjamin Share on 11/19/20.
//  Copyright © 2020 Benjamin Share. All rights reserved.
//

import Foundation
import UIKit


// MARK: New Play or Daily Solution
func openNewSolutionView(parentView: UIView, parentController: UIViewController, user: User, first: String, last: String, answer: String) -> NewSolutionView {
    let newSolutionView = NewSolutionView(frame: parentView.frame)
    let blur = blurView(view: parentView)
    configureNewSolutionView(newSolutionView: newSolutionView, parentView: parentView, parentController: parentController, user: user, blurView: blur, first: first, last: last, answer: answer)
    return newSolutionView
}

private func configureNewSolutionView(newSolutionView: NewSolutionView, parentView: UIView, parentController: UIViewController, user: User, blurView: UIVisualEffectView, first: String, last: String, answer: String) {
    newSolutionView.parentView = parentView
    newSolutionView.parentController = parentController
    newSolutionView.backgroundColor = globalBackgroundColor()
    _ = addBorders(view: newSolutionView, top: true, bottom: true, left: true, right: true)
    newSolutionView.translatesAutoresizingMaskIntoConstraints = false
    parentView.addSubview(newSolutionView)
    newSolutionView.configureView()
    newSolutionView.setSolutionCellWords(first: first, answer: answer, last: last)
    newSolutionView.setUserAndBlur(user: user, blurView: blurView)
}
