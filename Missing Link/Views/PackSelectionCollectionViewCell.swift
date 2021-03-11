//
//  PackSelectionCollectionViewCell.swift
//  Missing Link
//
//  Created by Benjamin Share on 10/26/19.
//  Copyright © 2019 Benjamin Share. All rights reserved.
//

import UIKit

class PackSelectionCollectionViewCell: UICollectionViewCell {
    @IBOutlet var packName: UILabel!
    @IBOutlet var statusImage: UIImageView!
    
    override init(frame: CGRect) {
            super.init(frame: frame)
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            fatalError("init(coder:) has not been implemented")
        }
        
        private func updatePackName(labelText: String) {
            let frame = self.frame
            
            self.packName = UILabel(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
            self.packName.text = labelText
            self.packName.textColor = globalTextColor()
            self.packName.font = self.packName.font.withSize(80)
            self.packName.adjustsFontSizeToFitWidth = true
            self.packName.font = self.packName.font.withSize(self.packName.font.pointSize * 0.4)
            self.packName.textAlignment = .center
        }
        
        private func updateStatusImage(imageFn: String) {
            let frame = self.frame
            
            let ratio: CGFloat
            let alpha: CGFloat
            let fnToUse: String
            
            switch imageFn {
            case "Lock":
                ratio = 0.8
            case "Unlocked", "FullStar":
                ratio = 1.0
            default:
                fatalError("Unknown filename.")
            }
            
            switch imageFn {
            case "Unlocked":
                alpha = 0
            default:
                alpha = 0.8
            }
            
            switch imageFn {
            case "Unlocked":
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
            updatePackName(labelText: labelText)
            self.contentView.subviews[0].removeFromSuperview()
            self.contentView.addSubview(self.packName)
            self.contentView.sendSubviewToBack(self.contentView.subviews[-1])
        }
        
        public func updateDisplayedImage(imageFn: String) {
            updateStatusImage(imageFn: imageFn)
            self.contentView.subviews[1].removeFromSuperview()
            self.contentView.addSubview(self.statusImage)
        }
        
        public func configure(imageFn: String, labelText: String) {
            updatePackName(labelText: labelText)
            updateStatusImage(imageFn: imageFn)
            self.contentView.addSubview(self.packName)
            self.contentView.addSubview(self.statusImage)
        }
    }

