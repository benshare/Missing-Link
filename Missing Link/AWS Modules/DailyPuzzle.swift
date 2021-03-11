//
//  DailyPuzzle.swift
//  Missing Link
//
//  Created by Benjamin Share on 7/3/20.
//  Copyright © 2020 Benjamin Share. All rights reserved.
//

import Foundation
import UIKit
import AWSDynamoDB


@objcMembers class DailyPuzzle: AWSDynamoDBObjectModel, AWSDynamoDBModeling {

    var _date: String?
    var _puzzle: String?

    class func dynamoDBTableName() -> String {

        return "missinglink-mobilehub-2144505807-DailyPuzzle"
    }
    
    class func hashKeyAttribute() -> String {

        return "_date"
    }
    
    override class func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any] {
        return [
               "_date" : "date",
               "_puzzle" : "puzzle",
        ]
    }
    
    init(date: Date = Date(), puzzle: Puzzle) {
        super.init()
        _date = DATE_FORMATTER.string(from: date)
        let encoder = JSONEncoder()
        let puzzleAsData = try! encoder.encode(puzzle)
        _puzzle = String(data: puzzleAsData, encoding: .utf8)
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
