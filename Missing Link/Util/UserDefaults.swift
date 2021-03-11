//
//  UserDefaults.swift
//  Missing Link
//
//  Created by Benjamin Share on 11/30/20.
//  Copyright © 2020 Benjamin Share. All rights reserved.
//

import Foundation

private let userDefaults = UserDefaults.standard

func writeUserToDefaults(loggedInUser: LoggedInUser) {
    if loggedInUser.rememberMe {
        writeUserToDefaultsNoCheck(user: loggedInUser.user)
    }
}

func writeUserToDefaultsNoCheck(user: User) {
    let encoder = JSONEncoder()
    do {
        let remembered_user = try encoder.encode(user)
        userDefaults.setValue(remembered_user, forKey: "User")
    } catch {
        print("Failed to encode remembered user data")
    }
}

func readFromUserDefaults() -> User? {
    let decoder = JSONDecoder()
    do {
        guard let defaultData = userDefaults.data(forKey: "User") else { return nil }
        let user = try decoder.decode(User.self, from: defaultData)
        return user
    } catch {
        return nil
    }
}

func clearRememberedUser() {
    userDefaults.setValue(nil, forKey: "User")
//    UserDefaults.resetStandardUserDefaults()
}
