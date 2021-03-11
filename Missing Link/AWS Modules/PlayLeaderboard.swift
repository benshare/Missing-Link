//
//  PlayLeaderboard.swift
//  Missing Link
//
//  Copyright 2020 Amazon.com, Inc. or its affiliates (Amazon). All Rights Reserved.
//  Source code generated from template: aws-my-sample-app-ios-swift v0.21
//

import Foundation
import UIKit
import AWSDynamoDB

@objcMembers class PlayLeaderboard: AWSDynamoDBObjectModel, AWSDynamoDBModeling {

    var _username: String?
    var _score: NSNumber?
    var _puzzlesCompleted: NSNumber?
    var _levelsCompleted: NSNumber?
    var _packsCompleted: NSNumber?
    var _mostPuzzlesInOneDay: NSNumber?
    // TODO: Mode this to a better place
    var _showMe: NSNumber?

    class func dynamoDBTableName() -> String {
        return "missinglink-mobilehub-2144505807-PlayLeaderboard"
    }

    class func hashKeyAttribute() -> String {

        return "_username"
    }

    override class func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any] {
        return [
            "_username" : "username",
            "_score" : "score",
            "_puzzlesCompleted" : "puzzlesCompleted",
            "_levelsCompleted" : "levelsCompleted",
            "_packsCompleted" : "packsCompleted",
            "_mostPuzzlesInOneDay" : "mostPuzzlesInOneDay",
            "_showMe": "showMe",
        ]
    }

    init(username: String, data: PlayData, showMe: Bool=true) {
        super.init()
        _username = username
        _score = NSNumber(value: data.score)
        _puzzlesCompleted = NSNumber(value: data.puzzlesCompleted)
        _levelsCompleted = NSNumber(value: data.levelsCompleted)
        _packsCompleted = NSNumber(value: data.packsCompleted)
        _mostPuzzlesInOneDay = NSNumber(value: data.mostPuzzlesInOneDay)
        _showMe = NSNumber(value: showMe)
    }

    required init!(coder: NSCoder!) {
        super.init(coder: coder)
    }

    override init(dictionary dictionaryValue: [AnyHashable : Any]!, error: ()) throws {
        try super.init(dictionary: dictionaryValue, error: ())
    }

    override init!() {
        super.init()
    }
}
