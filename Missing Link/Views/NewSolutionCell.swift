//
//  NewSolutionCell.swift
//  Missing Link
//
//  Created by Benjamin Share on 11/26/20.
//  Copyright © 2020 Benjamin Share. All rights reserved.
//

import Foundation
import UIKit

class NewSolutionCell: UIView, UITextFieldDelegate {
    // MARK: Properties
    
    // Constants
    
    // Formatting
    var parentView: UIView?
    private var layout: NewSolutionCellLayout?
    
    // UI elements
    private var firstLabel = UILabel()
    private var firstField = UITextField()
    private var answerLabel = UILabel()
    private var answerField = UITextField()
    private var lastLabel = UILabel()
    private var lastField = UITextField()

    
    // MARK: Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureView() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = globalBackgroundColor()
        _ = addBorders(view: self, top: true, bottom: true, left: true, right: true)

        self.layout = NewSolutionCellLayout(firstLabel: firstLabel, firstField: firstField, answerLabel: answerLabel, answerField: answerField, lastLabel: lastLabel, lastField: lastField)
        layout!.configureConstraints(view: self)
        layout!.activateConstraints()
        
        firstField.delegate = self as UITextFieldDelegate
        answerField.delegate = self as UITextFieldDelegate
        lastField.delegate = self as UITextFieldDelegate
    }
    
    // MARK: Puzzle text
    func setWords(first: String, answer: String, last: String) {
        firstField.text = first
        answerField.text = answer
        lastField.text = last
    }
    
    func getFeedbackText() -> String {
        return firstField.text! + " - " + answerField.text! + " - " + lastField.text!
    }
    
    // MARK: Text Field Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let char = string.cString(using: String.Encoding.utf8)
        if strcmp(char, "\\b") == -92 {
            return true
        }
        if textField == firstField || textField == answerField || textField == lastField {
            textField.text! += string.uppercased()
        } else {
            print("Unknown field provided for editing in New Solution view")
        }
        return false
    }
}
