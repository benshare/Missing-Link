//
//  PuzzlePackCollectionViewCell.swift
//  Missing Link
//
//  Created by Benjamin Share on 9/7/19.
//  Copyright © 2019 Benjamin Share. All rights reserved.
//

import UIKit

class LevelSelectionCollectionViewCell: UICollectionViewCell {
    //MARK: Private Variables
    @IBOutlet var levelNumber: UILabel!
    @IBOutlet var statusImage: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateLevelNumber(labelText: String) {
        let frame = self.frame
        
        self.levelNumber = UILabel(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        self.levelNumber.text = labelText
        self.levelNumber.textAlignment = .center
        self.levelNumber.textColor = globalTextColor()
        self.levelNumber.font = self.levelNumber.font.withSize(80)
    }
    
    private func updateStatusImage(imageFn: String) {
        let frame = self.frame
        
        let ratio: CGFloat
        let alpha: CGFloat
        let fnToUse: String
        
        switch imageFn {
        case "Lock":
            ratio = 0.8
        case "None":
            ratio = 1.0
        case "CheckMark":
            ratio = 1.5
        default:
            fatalError("Unexpected filename.")
        }
        
        switch imageFn {
        case "None":
            alpha = 0
        default:
            alpha = 0.8
        }
        
        switch imageFn {
        case "None":
            fnToUse = "Lock"
        default:
            fnToUse = imageFn
        }
        self.statusImage = UIImageView(image: UIImage(named: fnToUse))
        self.statusImage.frame = CGRect(x: 0, y: 0, width: frame.width * ratio, height: frame.height * ratio)
        self.statusImage.center = self.contentView.center
        self.statusImage.alpha = alpha
    }
    
    public func updateDisplayedText(labelText: String) {
        updateLevelNumber(labelText: labelText)
        self.contentView.subviews[0].removeFromSuperview()
        self.contentView.addSubview(self.levelNumber)
        self.contentView.sendSubviewToBack(self.contentView.subviews[-1])
    }
    
    public func updateDisplayedImage(imageFn: String) {
        updateStatusImage(imageFn: imageFn)
        self.contentView.subviews[1].removeFromSuperview()
        self.contentView.addSubview(self.statusImage)
    }
    
    public func configure(imageFn: String, labelText: String) {
        updateLevelNumber(labelText: labelText)
        updateStatusImage(imageFn: imageFn)
        self.contentView.addSubview(self.levelNumber)
        self.contentView.addSubview(self.statusImage)
    }
}
