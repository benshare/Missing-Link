//
//  PackSelectionCollectionViewHeader.swift
//  Missing Link
//
//  Created by Benjamin Share on 11/17/19.
//  Copyright © 2019 Benjamin Share. All rights reserved.
//

import UIKit

class PackSelectionHeaderView: UICollectionReusableView {
    
    @IBOutlet var headerTitle: UILabel!
    
    override init(frame: CGRect) {
        self.headerTitle = UILabel()
        self.headerTitle.text = "Classic"
        self.headerTitle.isEnabled = true
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
