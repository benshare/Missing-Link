//
//  CreditsLayout.swift
//  Missing Link
//
//  Created by Benjamin Share on 11/30/20.
//  Copyright © 2020 Benjamin Share. All rights reserved.
//

import Foundation
import UIKit

class CreditsLayout {
    // MARK: Properties
    
    // UI elements
    private var scrollView: UIScrollView
    private var contentView: UIStackView
    private var verticalBorders = [UIView]()
    private var horizontalBorders = [UIView]()
    
    // Values to set
    private var contentWidth: CGFloat!
    
    // Constraints
    private var portraitConstraints = [NSLayoutConstraint]()
    private var landscapeConstraints = [NSLayoutConstraint]()
    
    init(scrollView: UIScrollView, contentView: UIStackView) {
        self.scrollView = scrollView
        self.contentView = contentView
    }
    
    func configureView(margins: UILayoutGuide) {
        contentWidth = min(margins.layoutFrame.height, margins.layoutFrame.width) * 0.7
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.topAnchor.constraint(equalTo: margins.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: margins.bottomAnchor).isActive = true
        scrollView.leftAnchor.constraint(equalTo: margins.leftAnchor).isActive = true
        scrollView.rightAnchor.constraint(equalTo: margins.rightAnchor).isActive = true
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        contentView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        
        contentView.alignment = .leading
        
        addSections()
    }
    
    // MARK: Sections
    private func addSections() {
        // Title section
        addTextSection(title: "Credits", body: "", titleFont: 40, bodyFont: 15)
        
        // Author
        addTextSection(title: "Game Design and App Creation", body: "Benjamin Share", titleFont: 30, bodyFont: 15)
        
        // Special thanks
        addTextSection(title: "Special Thanks", body: """
            - Rachel Share-Sapolsky, for creating many of the puzzles

            - Rachel, Lisa, and Robert Share-Sapolsky for developing the app idea

            - Jen He and Ayush Shah for being early playtesters
        """, titleFont: 30, bodyFont: 15)
        
        // Icon credits
        addTextSection(title: "Icon Credits", body: """
            - Fire Icon - The DailyWTF

            - App Icon - PNGJoy.com

            - Star Icons - css-tricks.com

            - Checkbox Icons - leenix.co.uk

            - Question Mark Icon - cleanpng.com
        """, titleFont: 30, bodyFont: 15)
        
        // Beta testing
        addTextSection(title: "Beta Testing Feedback", body: "All of you!!\n(To be updated)", titleFont: 30, bodyFont: 15)
    }
    
    private func addTextSection(title: String, body: String, titleFont: CGFloat, bodyFont: CGFloat) {
        let titlePortraitHeight = 1.5 * titleFont * linesForLabel(font: titleFont, text: title, width: contentWidth / 0.7)
        let titleLandscapeHeight = 1.5 * titleFont * linesForLabel(font: titleFont, text: title, width: contentWidth)
        let bodyPortraitHeight = 1.5 * bodyFont * (linesForLabel(font: bodyFont, text: body, width: contentWidth / 0.7) + 1)
        
        let newSection = UIView()
        contentView.addArrangedWithColor(subview: newSection)
        newSection.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        newSection.addSubview(titleLabel)
        titleLabel.text = title
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraint(equalTo: newSection.topAnchor).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: newSection.leftAnchor, constant: 10).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: newSection.rightAnchor, constant: -10).isActive = true
        titleLabel.font = .boldSystemFont(ofSize: titleFont)
        portraitConstraints.append(titleLabel.heightAnchor.constraint(equalToConstant: titlePortraitHeight))
        landscapeConstraints.append(titleLabel.heightAnchor.constraint(equalToConstant: titleLandscapeHeight))
        
        let bodyLabel = UILabel()
        newSection.addSubview(bodyLabel)
        bodyLabel.text = body
        bodyLabel.numberOfLines = 0
        bodyLabel.font = .italicSystemFont(ofSize: bodyFont)
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        bodyLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor).isActive = true
        bodyLabel.leftAnchor.constraint(equalTo: newSection.leftAnchor, constant: 10).isActive = true
        bodyLabel.rightAnchor.constraint(equalTo: newSection.rightAnchor, constant: -10).isActive = true
        portraitConstraints.append(bodyLabel.heightAnchor.constraint(equalToConstant: bodyPortraitHeight))
        landscapeConstraints.append(bodyLabel.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor))
        
        portraitConstraints += [
            newSection.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            newSection.heightAnchor.constraint(equalToConstant: titlePortraitHeight + bodyPortraitHeight)
        ]
        landscapeConstraints += [
            newSection.widthAnchor.constraint(equalToConstant: contentWidth),
            newSection.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
        ]
        
        verticalBorders += addBorders(view: newSection, bottom: true, left: true, right: true)
        horizontalBorders += addBorders(view: newSection, right: true)
    }
    
    func activateConstraints(orientationIsPortrait: Bool) {
        if orientationIsPortrait {
            NSLayoutConstraint.deactivate(landscapeConstraints)
            NSLayoutConstraint.activate(portraitConstraints)
            contentView.axis = .vertical
            for border in horizontalBorders {
                border.isHidden = true
            }
            for border in verticalBorders {
                border.isHidden = false
            }
        } else {
            NSLayoutConstraint.deactivate(portraitConstraints)
            NSLayoutConstraint.activate(landscapeConstraints)
            contentView.axis = .horizontal
            for border in verticalBorders {
                border.isHidden = true
            }
            for border in horizontalBorders {
                border.isHidden = false
            }
        }
    }
    
    // MARK: Other UI
}
