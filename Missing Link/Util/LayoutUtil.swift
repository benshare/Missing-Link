//
//  LayoutUtil.swift
//  Missing Link
//
//  Created by Benjamin Share on 7/20/20.
//  Copyright © 2020 Benjamin Share. All rights reserved.
//

import Foundation
import UIKit

// MARK: Spacing

// Constants
private let hintLetterPortraitWidth = 0.1
private let hintLetterPortraitGap = 0.03
private let hintLetterLandscapeWidth = 0.06
private let hintLetterLandscapeGap = 0.02

private func getAnyHorizontalConstraints(leftAnchor: NSLayoutAnchor<NSLayoutXAxisAnchor>, rightAnchor: NSLayoutAnchor<NSLayoutXAxisAnchor>, parentView: UIView, getWidthConstraints: Bool, widthMap: [UIView: CGFloat]?, getSpacingConstraints: Bool, spacingMap: [UIView: CGFloat]?) -> [NSLayoutConstraint] {
    var constraints = [NSLayoutConstraint]()
    
    let widthObj = UIView()
    parentView.addSubview(widthObj)
    widthObj.translatesAutoresizingMaskIntoConstraints = false
    constraints += [
        widthObj.leftAnchor.constraint(equalTo: leftAnchor),
        widthObj.rightAnchor.constraint(equalTo: rightAnchor),
    ]
    let widthAnchor = widthObj.widthAnchor
    
    if getWidthConstraints {
        let map = widthMap!
        for pair in map {
            let object = pair.key
            let objectWidth = pair.value
            constraints.append(object.widthAnchor.constraint(equalTo: widthAnchor, multiplier: objectWidth))
        }
    }
    if getSpacingConstraints {
        let map = spacingMap!
        for pair in map {
            let object = pair.key
            let objectCenter = pair.value
            let leftBuffer = UIView()
            leftBuffer.translatesAutoresizingMaskIntoConstraints = false
            parentView.addSubview(leftBuffer)
            constraints += [
                leftBuffer.leftAnchor.constraint(equalTo: leftAnchor),
                leftBuffer.rightAnchor.constraint(equalTo: object.centerXAnchor),
                leftBuffer.widthAnchor.constraint(equalTo: widthAnchor, multiplier: objectCenter),
            ]
        }
    }
    return constraints
}

func getFullHorizontalConstraints(leftAnchor: NSLayoutAnchor<NSLayoutXAxisAnchor>, rightAnchor: NSLayoutAnchor<NSLayoutXAxisAnchor>, horizontalConstraintMap: [UIView: (CGFloat, CGFloat)], parentView: UIView) -> [NSLayoutConstraint] {
    let widthMap: [UIView: CGFloat] = horizontalConstraintMap.mapValues( { value in return value.0})
    let spacingMap: [UIView: CGFloat] = horizontalConstraintMap.mapValues( { value in return value.1})
    return getAnyHorizontalConstraints(leftAnchor: leftAnchor, rightAnchor: rightAnchor, parentView: parentView, getWidthConstraints: true, widthMap: widthMap, getSpacingConstraints: true, spacingMap: spacingMap)
}

func getHorizontalWidthConstraints(leftAnchor: NSLayoutAnchor<NSLayoutXAxisAnchor>, rightAnchor: NSLayoutAnchor<NSLayoutXAxisAnchor>, widthMap: [UIView: CGFloat], parentView: UIView) -> [NSLayoutConstraint] {
    return getAnyHorizontalConstraints(leftAnchor: leftAnchor, rightAnchor: rightAnchor, parentView: parentView, getWidthConstraints: true, widthMap: widthMap, getSpacingConstraints: false, spacingMap: nil)
}

func getHorizontalSpacingConstraints(leftAnchor: NSLayoutAnchor<NSLayoutXAxisAnchor>, rightAnchor: NSLayoutAnchor<NSLayoutXAxisAnchor>, spacingMap: [UIView: CGFloat], parentView: UIView) -> [NSLayoutConstraint] {
    return getAnyHorizontalConstraints(leftAnchor: leftAnchor, rightAnchor: rightAnchor, parentView: parentView, getWidthConstraints: false, widthMap: nil, getSpacingConstraints: true, spacingMap: spacingMap)
}

private func getAnyVerticalConstraints(topAnchor: NSLayoutAnchor<NSLayoutYAxisAnchor>, bottomAnchor: NSLayoutAnchor<NSLayoutYAxisAnchor>, parentView: UIView, getHeightConstraints: Bool, heightMap: [UIView: CGFloat]?, getSpacingConstraints: Bool, spacingMap: [UIView: CGFloat]?) -> [NSLayoutConstraint] {
    var constraints = [NSLayoutConstraint]()
    
    let heightObj = UIView()
    parentView.addSubview(heightObj)
    heightObj.translatesAutoresizingMaskIntoConstraints = false
    constraints += [
        heightObj.topAnchor.constraint(equalTo: topAnchor),
        heightObj.bottomAnchor.constraint(equalTo: bottomAnchor),
    ]
    let heightAnchor = heightObj.heightAnchor
    
    if getHeightConstraints {
        let map = heightMap!
        for pair in map {
            let object = pair.key
            let objectHeight = pair.value
            constraints.append(object.heightAnchor.constraint(equalTo: heightAnchor, multiplier: objectHeight))
        }
    }
    if getSpacingConstraints {
        let map = spacingMap!
        for pair in map {
            let object = pair.key
            let objectCenter = pair.value
            let topBuffer = UIView()
            topBuffer.translatesAutoresizingMaskIntoConstraints = false
            parentView.addSubview(topBuffer)
            constraints += [
                topBuffer.topAnchor.constraint(equalTo: topAnchor),
                topBuffer.bottomAnchor.constraint(equalTo: object.centerYAnchor),
                topBuffer.heightAnchor.constraint(equalTo: heightAnchor, multiplier: objectCenter),
            ]
        }
    }
    return constraints
}

func getFullVerticalConstraints(topAnchor: NSLayoutAnchor<NSLayoutYAxisAnchor>, bottomAnchor: NSLayoutAnchor<NSLayoutYAxisAnchor>, verticalConstraintMap: [UIView: (CGFloat, CGFloat)], parentView: UIView) -> [NSLayoutConstraint] {
    let heightMap: [UIView: CGFloat] = verticalConstraintMap.mapValues( { value in return value.0})
    let spacingMap: [UIView: CGFloat] = verticalConstraintMap.mapValues( { value in return value.1})
    return getAnyVerticalConstraints(topAnchor: topAnchor, bottomAnchor: bottomAnchor, parentView: parentView, getHeightConstraints: true, heightMap: heightMap, getSpacingConstraints: true, spacingMap: spacingMap)
}

func getVerticalHeightConstraints(topAnchor: NSLayoutAnchor<NSLayoutYAxisAnchor>, bottomAnchor: NSLayoutAnchor<NSLayoutYAxisAnchor>, heightMap: [UIView: CGFloat], parentView: UIView) -> [NSLayoutConstraint] {
    return getAnyVerticalConstraints(topAnchor: topAnchor, bottomAnchor: bottomAnchor, parentView: parentView, getHeightConstraints: true, heightMap: heightMap, getSpacingConstraints: false, spacingMap: nil)
}

func getVerticalSpacingConstraints(topAnchor: NSLayoutAnchor<NSLayoutYAxisAnchor>, bottomAnchor: NSLayoutAnchor<NSLayoutYAxisAnchor>, spacingMap: [UIView: CGFloat], parentView: UIView) -> [NSLayoutConstraint] {
    return getAnyVerticalConstraints(topAnchor: topAnchor, bottomAnchor: bottomAnchor, parentView: parentView, getHeightConstraints: false, heightMap: nil, getSpacingConstraints: true, spacingMap: spacingMap)
}

func getHorizontalMapsForHintModeLetters(hintModeLetters: [UIView], length: Int, portraitWidth: Double, portraitGap: Double, landscapeWidth: Double, landscapeGap: Double) -> ([UIView: (CGFloat, CGFloat)], CGFloat, [UIView: (CGFloat, CGFloat)], CGFloat) {
    var portraitMap = [UIView: (CGFloat, CGFloat)]()
    let portraitTotalWidth = CGFloat(portraitWidth * Double(length) + portraitGap * Double((length - 1)))
    var landscapeMap = [UIView: (CGFloat, CGFloat)]()
    let landscapeTotalWidth = CGFloat(landscapeWidth * Double(length) + landscapeGap * Double((length - 1)))
    
    for isPortrait in [true, false] {
        let letterWidth = isPortrait ? portraitWidth : landscapeWidth
        let letterGap = isPortrait ? portraitGap : landscapeGap
        
        let totalWidth = letterWidth * Double(length) + letterGap * Double((length - 1))
        let leftmost = 0.5 - totalWidth / 2 + letterWidth / 2
        var map = [UIView: (CGFloat, CGFloat)]()
        if length > 0 {
            for i in 0...length-1 {
                let pair = (CGFloat(letterWidth), CGFloat(leftmost + Double(i) * (letterWidth + letterGap)))
                map[hintModeLetters[i]] = pair
            }
        }
        if isPortrait {
            portraitMap = map
        } else {
            landscapeMap = map
        }
    }
    return (portraitMap, portraitTotalWidth, landscapeMap, landscapeTotalWidth)
}


// MARK: Text

func setTextToDefaults(labels: [UILabel?]) {
    centerAlignText(labels: labels)
    setTextToResize(labels: labels)
}

func setButtonsToDefaults(buttons: [UIButton?], resize: Bool=true, withInsets: Int=0) {
    centerAlignText(labels: buttons.map( { $0?.titleLabel }))
    if resize {
        setTextToResize(labels: buttons.map( { $0?.titleLabel }))
    }
    if withInsets > 0 {
        setInsets(buttons: buttons, inset: CGFloat(withInsets))
    }
}

func centerAlignText(labels: [UILabel?]) {
    for label in labels {
        label?.textAlignment = .center
    }
}

private func setTextToResize(labels: [UILabel?]) {
    for label in labels {
        label?.font = label?.font.withSize(60)
        label?.adjustsFontSizeToFitWidth = true
        label?.baselineAdjustment = .alignCenters
    }
}

private func setInsets(buttons: [UIButton?], inset: CGFloat) {
    for button in buttons {
        button?.contentEdgeInsets = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
    }
}

// Debugging only
private func setTextBackgroundToRed(labels: [UILabel?]) {
    for label in labels {
        label?.backgroundColor = .red
    }
}

// MARK: Borders
func addBorders(view: UIView, top: Bool=false, bottom: Bool=false, left: Bool=false, right: Bool=false, width: CGFloat=2) -> [UIView] {
    var borders = [UIView]()
    if top {
        let border = UIView()
        border.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(border)
        border.heightAnchor.constraint(equalToConstant: width).isActive = true
        border.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        border.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        border.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        border.backgroundColor = .black
        borders.append(border)
    }
    if bottom {
        let border = UIView()
        border.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(border)
        border.heightAnchor.constraint(equalToConstant: width).isActive = true
        border.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        border.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        border.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        border.backgroundColor = .black
        borders.append(border)
    }
    if left {
        let border = UIView()
        border.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(border)
        border.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        border.widthAnchor.constraint(equalToConstant: width).isActive = true
        border.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        border.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        border.backgroundColor = .black
        borders.append(border)
    }
    if right {
        let border = UIView()
        border.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(border)
        border.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        border.widthAnchor.constraint(equalToConstant: width).isActive = true
        border.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        border.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        border.backgroundColor = .black
        borders.append(border)
    }
    return borders
}

// MARK: Streak and Coins

func addCoinsToView(view: UIView, portrait: ((CGFloat, CGFloat), (CGFloat, CGFloat)), landscape: ((CGFloat, CGFloat), (CGFloat, CGFloat))) -> (UILabel, [NSLayoutConstraint], [NSLayoutConstraint]) {
    let coinView = UIView()
    coinView.translatesAutoresizingMaskIntoConstraints = false
    
    let coinLabel = UILabel()
    coinLabel.translatesAutoresizingMaskIntoConstraints = false
    coinLabel.adjustsFontSizeToFitWidth = true
    coinLabel.font = .systemFont(ofSize: 30)
    coinLabel.textAlignment = .center
    coinView.addSubview(coinLabel)
    coinLabel.topAnchor.constraint(equalTo: coinView.topAnchor).isActive = true
    coinLabel.heightAnchor.constraint(equalTo: coinView.heightAnchor).isActive = true
    coinLabel.leftAnchor.constraint(equalTo: coinView.leftAnchor).isActive = true
    coinLabel.widthAnchor.constraint(equalTo: coinView.widthAnchor, multiplier: 0.5).isActive = true
    
    let coinImage = UIImageView(image: UIImage(named: "Coin"))
    coinImage.translatesAutoresizingMaskIntoConstraints = false
    coinView.addSubview(coinImage)
    coinImage.topAnchor.constraint(equalTo: coinView.topAnchor).isActive = true
    coinImage.heightAnchor.constraint(equalTo: coinView.heightAnchor).isActive = true
    coinImage.rightAnchor.constraint(equalTo: coinView.rightAnchor).isActive = true
    coinImage.widthAnchor.constraint(equalTo: coinView.widthAnchor, multiplier: 0.5).isActive = true
    
    let margins = view.layoutMarginsGuide
    view.addSubview(coinView)
    
    var vertical = portrait.0
    var horizontal = portrait.1
    let portraitConstraints = getFullVerticalConstraints(topAnchor: margins.topAnchor, bottomAnchor: margins.bottomAnchor, verticalConstraintMap: [coinView: vertical], parentView: view) + getFullHorizontalConstraints(leftAnchor: margins.leftAnchor, rightAnchor: margins.rightAnchor, horizontalConstraintMap: [coinView: horizontal], parentView: view)
    
    vertical = landscape.0
    horizontal = landscape.1
    let landscapeConstraints = getFullVerticalConstraints(topAnchor: margins.topAnchor, bottomAnchor: margins.bottomAnchor, verticalConstraintMap: [coinView: vertical], parentView: view) + getFullHorizontalConstraints(leftAnchor: margins.leftAnchor, rightAnchor: margins.rightAnchor, horizontalConstraintMap: [coinView: horizontal], parentView: view)
    
    return (coinLabel, portraitConstraints, landscapeConstraints)
}

func addStreakToView(view: UIView, portrait: ((CGFloat, CGFloat), (CGFloat, CGFloat)), landscape: ((CGFloat, CGFloat), (CGFloat, CGFloat))) -> (UILabel, [NSLayoutConstraint], [NSLayoutConstraint]) {
    let streakView = UIView()
    streakView.translatesAutoresizingMaskIntoConstraints = false
    
    let streakLabel = UILabel()
    streakLabel.translatesAutoresizingMaskIntoConstraints = false
    streakLabel.adjustsFontSizeToFitWidth = true
    streakLabel.font = .systemFont(ofSize: 30)
    streakLabel.textAlignment = .center
    streakView.addSubview(streakLabel)
    streakLabel.topAnchor.constraint(equalTo: streakView.topAnchor).isActive = true
    streakLabel.heightAnchor.constraint(equalTo: streakView.heightAnchor).isActive = true
    streakLabel.leftAnchor.constraint(equalTo: streakView.leftAnchor).isActive = true
    streakLabel.widthAnchor.constraint(equalTo: streakView.widthAnchor, multiplier: 0.5).isActive = true
    
    let streakImage = UIImageView(image: UIImage(named: "Streak"))
    streakImage.translatesAutoresizingMaskIntoConstraints = false
    streakView.addSubview(streakImage)
    streakImage.topAnchor.constraint(equalTo: streakView.topAnchor).isActive = true
    streakImage.heightAnchor.constraint(equalTo: streakView.heightAnchor).isActive = true
    streakImage.rightAnchor.constraint(equalTo: streakView.rightAnchor).isActive = true
    streakImage.widthAnchor.constraint(equalTo: streakView.widthAnchor, multiplier: 0.5).isActive = true
    
    let margins = view.layoutMarginsGuide
    view.addSubview(streakView)
    
    var vertical = portrait.0
    var horizontal = portrait.1
    let portraitConstraints = getFullVerticalConstraints(topAnchor: margins.topAnchor, bottomAnchor: margins.bottomAnchor, verticalConstraintMap: [streakView: vertical], parentView: view) + getFullHorizontalConstraints(leftAnchor: margins.leftAnchor, rightAnchor: margins.rightAnchor, horizontalConstraintMap: [streakView: horizontal], parentView: view)
    
    vertical = landscape.0
    horizontal = landscape.1
    let landscapeConstraints = getFullVerticalConstraints(topAnchor: margins.topAnchor, bottomAnchor: margins.bottomAnchor, verticalConstraintMap: [streakView: vertical], parentView: view) + getFullHorizontalConstraints(leftAnchor: margins.leftAnchor, rightAnchor: margins.rightAnchor, horizontalConstraintMap: [streakView: horizontal], parentView: view)
    
    return (streakLabel, portraitConstraints, landscapeConstraints)
}

// MARK: Blur
func blurView(view: UIView) -> UIVisualEffectView {
    let blurEffect = UIBlurEffect(style: .dark)
    let blurredEffectView = UIVisualEffectView(effect: blurEffect)
    blurredEffectView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(blurredEffectView)
    blurredEffectView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
    blurredEffectView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
    blurredEffectView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    blurredEffectView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    return blurredEffectView
}

// MARK: Orientation
func orientationIsPortrait() -> Bool {
    if UIDevice.current.orientation.isFlat {
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
    }
    return UIDevice.current.orientation.isPortrait || UIDevice.current.orientation.isFlat
}
