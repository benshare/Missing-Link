//
//  LeaderboardHeaderViewCell.swift
//  Missing Link
//
//  Created by Benjamin Share on 5/25/20.
//  Copyright © 2020 Benjamin Share. All rights reserved.
//

import UIKit

class LeaderboardHeaderViewCell: UITableViewCell {
    //MARK: Constants
    private final let headerSize = CGFloat(18)
    private final let tabWidth = CGFloat(150)
    private final let tabPadding = CGFloat(20)
    private final let leaderboardTabs = [
        (LeaderboardState.play, "Play"),
        (LeaderboardState.daily, "Streak"),
        (LeaderboardState.contributions, "Contributions")
    ]
    private final let tabNames = [
        LeaderboardState.play,
        LeaderboardState.daily,
        LeaderboardState.contributions
    ]
    
    //MARK: Instance Variables
    private var tabsView: UIView!
    private var columnLabelsView: UIView!
    public var leaderboardLabel: UILabel?
    private var tabs: [UIButton] = []
    
    private var leaderboardState: LeaderboardState = .play
    public var nextleaderboardState: LeaderboardState?
    public var parentTable: LeaderboardTableViewController!
    
//    //MARK: Outlets
    @IBOutlet var overallButton: UIButton!
//    @IBOutlet var streakButton: UIButton!
//    @IBOutlet var contributionsButton: UIButton!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let width = UIScreen.main.bounds.width
        let height = frame.height
        let topLeft = CGPoint(x: frame.minX, y: frame.minY)
        
        // Set up tabs view
        tabsView = UIScrollView(frame: CGRect(x: topLeft.x, y: topLeft.y, width: width, height: CGFloat(height)))
        tabsView.layer.addSublayer(CALayer())
        
        columnLabelsView = UIView(frame: CGRect(x: bounds.minX, y: bounds.minY + CGFloat(height), width: width, height: CGFloat(height)))
        addTopBorder(view: columnLabelsView)
        
        let columnHeight = frame.height
        let columnWidth = frame.width
        
        let rankLabel = UILabel(frame: CGRect(x: topLeft.x + columnWidth / 20, y: topLeft.y, width: columnWidth / 5, height: columnHeight))
        rankLabel.text = "Rank"
        rankLabel.font = UIFont.boldSystemFont(ofSize: headerSize)
        columnLabelsView.addSubview(rankLabel)
        
        let usernameLabel = UILabel(frame: CGRect(x: topLeft.x + columnWidth * 2 / 5, y: topLeft.y, width: columnWidth * 2 / 5, height: columnHeight))
        usernameLabel.text = "User"
        usernameLabel.font = UIFont.boldSystemFont(ofSize: headerSize)
        columnLabelsView.addSubview(usernameLabel)
        
        let scoreLabel = UILabel(frame: CGRect(x: topLeft.x + width * 0.8, y: topLeft.y, width: columnWidth / 5, height: columnHeight))
        scoreLabel.text = "Score"
        scoreLabel.font = UIFont.boldSystemFont(ofSize: headerSize)
        columnLabelsView.addSubview(scoreLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func configureCell() {
        configureButtons()
        
        contentView.addSubview(tabsView)
        contentView.addSubview(columnLabelsView)
    }
    
    private func configureButtons() {
        var ind = 0
        let widthUnit = UIScreen.main.bounds.width / 36
        for state in leaderboardTabs {
            let newButton = UIButton(frame: CGRect(x: tabsView.frame.minX + CGFloat(ind) * UIScreen.main.bounds.width / 3 + widthUnit, y: tabsView.frame.minY + tabsView.frame.height / 10, width: widthUnit * 10, height: tabsView.frame.height * 9 / 10))
            addTabBorder(view: newButton)
            newButton.setTitle(state.1, for: .normal)
            newButton.setTitleColor(UIColor.black, for: .normal)
            newButton.backgroundColor = .lightGray
            newButton.titleLabel!.adjustsFontSizeToFitWidth = true
            
            newButton.isEnabled = leaderboardState != state.0
            newButton.backgroundColor = leaderboardState != state.0 ? .lightGray : .darkGray
            // TODO: Figure out a way to make this a lambda
            switch state.0 {
            case .play:
                newButton.addTarget(self, action: #selector(setNextStateToOverall), for: .touchDown)
            case .daily:
                newButton.addTarget(self, action: #selector(setNextStateToStreak), for: .touchDown)
            case .contributions:
                newButton.addTarget(self, action: #selector(setNextStateToContributions), for: .touchDown)
            }
            newButton.addTarget(self, action: #selector(updateLeaderboardState), for: .touchDown)
            tabs.append(newButton)
            tabsView.addSubview(newButton)
            ind += 1
        }
    }
    
    func addTopBorder(view: UIView) {
        let border = CALayer()
        border.borderColor = UIColor.black.cgColor;
        border.borderWidth = 2;
        border.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 1)
        view.layer.addSublayer(border)
    }
    
    func addLeftBorder(view: UIView) {
        let border = CALayer()
        border.borderColor = UIColor.black.cgColor;
        border.borderWidth = 2;
        border.frame = CGRect(x: 0, y: 0, width: 1, height: view.frame.height)
        view.layer.addSublayer(border)
    }
    
    func addRightBorder(view: UIView) {
        let border = CALayer()
        border.borderColor = UIColor.black.cgColor;
        border.borderWidth = 2;
        border.frame = CGRect(x: view.frame.width, y: 0, width: 1, height: view.frame.height)
        view.layer.addSublayer(border)
    }
    
    func addTabBorder(view: UIView) {
        addTopBorder(view: view)
        addLeftBorder(view: view)
        addRightBorder(view: view)
    }
    
    @objc func setNextStateToOverall() {
        nextleaderboardState = .play
    }

    @objc func setNextStateToStreak() {
        nextleaderboardState = .daily
    }

    @objc func setNextStateToContributions() {
        nextleaderboardState = .contributions
    }
    
    @objc func updateLeaderboardState() {
        let oldInd = tabNames.firstIndex(of: leaderboardState)!
        let newInd = tabNames.firstIndex(of: nextleaderboardState!)!
        leaderboardState = nextleaderboardState!
        tabs[oldInd].isEnabled = true
        tabs[newInd].isEnabled = false
        parentTable.leaderboardState = leaderboardState
        parentTable.displayLeaderboardData()
    }
}

