//
//  Globals.swift
//  Missing Link
//
//  Created by Benjamin Share on 9/23/19.
//  Copyright © 2019 Benjamin Share. All rights reserved.
//

import Foundation
import CommonCrypto
import UIKit

// MARK: Constants

let USER_TABLE_KEY = "user_table_key"
let localDir = "Users/benjaminshare/Dropbox/Missing Link/Missing Link"
let rememberUserUrl = URL(fileURLWithPath: "Local Data/remembered_user")

enum APP_USER {
    case admin
    case maintenance
    case user
}

let APP_USER_TYPE: APP_USER = .maintenance

func globalBackgroundColor() -> UIColor {
    if #available(iOS 13.0, *) {
        return UIColor.systemBackground
    } else {
        return UIColor.white
    }
}

func globalTextColor() -> UIColor {
    if #available(iOS 13.0, *) {
        return UIColor.label
    } else {
        return UIColor.black
    }
}

