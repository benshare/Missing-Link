//
//  LeaderboardTableViewCell.swift
//  Missing Link
//
//  Created by Benjamin Share on 11/26/19.
//  Copyright © 2019 Benjamin Share. All rights reserved.
//

import UIKit

class LeaderboardTableViewCell: UITableViewCell {
    //MARK: Private Variables
    let isLoggedInUser: Bool = false
    
    //MARK: Outlets
    @IBOutlet var rankLabel: UILabel!
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var scoreLabel: UILabel!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let width = frame.width
        let height = frame.height
        let topLeft = CGPoint(x: frame.minX, y: frame.minY)
        
        self.rankLabel = UILabel(frame: CGRect(x: topLeft.x + width / 10, y: topLeft.y + height / 2, width: width / 5, height: height))
        self.usernameLabel = UILabel(frame: CGRect(x: topLeft.x + width * 2 / 5, y: topLeft.y + height / 2, width: width * 2 / 5, height: height))
        self.scoreLabel = UILabel(frame: CGRect(x: frame.maxX, y: topLeft.y + height / 2, width: width * 2 / 5, height: height))
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureCell(entry: LeaderboardOutput, isLoggedInUser: Bool=false) {
        rankLabel.text = entry.rank == -1 ? "--" : String(entry.rank)
        usernameLabel.text = entry.username
        scoreLabel.text = String(entry.score)
        if isLoggedInUser {
            rankLabel.font = UIFont.boldSystemFont(ofSize: 20)
            usernameLabel.font = UIFont.boldSystemFont(ofSize: 20)
            scoreLabel.font = UIFont.boldSystemFont(ofSize: 20)
        } else {
            rankLabel.font = UIFont.systemFont(ofSize: 16)
            usernameLabel.font = UIFont.systemFont(ofSize: 16)
            scoreLabel.font = UIFont.systemFont(ofSize: 16)
        }
        contentView.addSubview(rankLabel)
        contentView.addSubview(usernameLabel)
        contentView.addSubview(scoreLabel)
    }
    
    func configureBlankCell() {
        rankLabel.text = ""
        usernameLabel.text = ". . ."
        scoreLabel.text = ""
        contentView.addSubview(usernameLabel)
    }
}
