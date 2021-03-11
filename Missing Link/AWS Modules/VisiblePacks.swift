// DEPRECATED
//
//  VisiblePacks.swift
//  Missing Link
//
//  Created by Benjamin Share on 6/12/20.
//  Copyright © 2020 Benjamin Share. All rights reserved.
//

//import Foundation
//import UIKit
//import AWSDynamoDB
//
//
//@objcMembers class VisiblePacks: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
//
//    var _visibilityCategory: String?
//    var _visibility: String?
//    var _packInfo: String?
//
//    class func dynamoDBTableName() -> String {
//
//        return "missinglink-mobilehub-2144505807-VisiblePacks"
//    }
//
//    class func hashKeyAttribute() -> String {
//
//        return "_visibilityCategory"
//    }
//
//    class func rangeKeyAttribute() -> String {
//
//        return "_visibility"
//    }
//
//    override class func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any] {
//        return [
//               "_visibilityCategory" : "visibilityCategory",
//               "_visibility" : "visibility",
//               "_packInfo" : "packInfo",
//        ]
//    }
//
//    init(category: String="user", visibility: String="general", packInfo: PackInfoWrapper) {
//        super.init()
//        _visibilityCategory = category
//        _visibility = visibility
//        let encoder = JSONEncoder()
//        let infoAsData = try! encoder.encode(packInfo)
//        _packInfo = String(data: infoAsData, encoding: .utf8)
//    }
//
//    required init!(coder: NSCoder!) {
//        super.init(coder: coder)
//    }
//
//    override init(dictionary dictionaryValue: [AnyHashable : Any]!, error: ()) throws {
//        try super.init(dictionary: dictionaryValue, error: ())
//    }
//
//    override init!() {
//        super.init()
//    }
//}
