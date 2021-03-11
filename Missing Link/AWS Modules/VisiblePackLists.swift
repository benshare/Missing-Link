//
//  VisiblePackLists.swift
//  Missing Link
//
//  Created by Benjamin Share on 12/11/20.
//  Copyright © 2020 Benjamin Share. All rights reserved.
//

import Foundation
import UIKit
import AWSDynamoDB

struct VisiblePackWrapper: Codable {
    let id: Int
    let name: String
    
    init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
}

class VisibleSectionsWrapper: Codable {
    var map: [String: [VisiblePackWrapper]]
    
    enum CodingKeys: String, CodingKey {
        case map
    }
        
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.map = try container.decode([String: [VisiblePackWrapper]].self, forKey: .map)
    }
    
    init() {
        map = [:]
    }
    
    func addPack(section: String, pack: (Int, String)) {
        if !map.keys.contains(section) {
            map[section] = [VisiblePackWrapper]()
        }
        map[section]?.append(VisiblePackWrapper(id: pack.0, name: pack.1))
    }
        
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys)
//        try container.encode(self.username, forKey: .username)
//        try container.encode(self.passwordHash, forKey: .password)
//        try container.encode(self.progress, forKey: .progress)
//        try container.encode(self.data, forKey: .data)
//        try container.encode(self.rewards, forKey: .rewards)
//        try container.encode(self.preferences, forKey: .preferences)
//    }
}

@objcMembers class VisiblePackInfo: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    var _visibilityCategory: String?
    var _visibility: String?
    var _packInfo: String?
    
    class func dynamoDBTableName() -> String {

        return "missinglink-mobilehub-2144505807-VisiblePacks"
    }
    
    class func hashKeyAttribute() -> String {

        return "_visibilityCategory"
    }
    
    class func rangeKeyAttribute() -> String {

        return "_visibility"
    }
    
    override class func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any] {
        return [
               "_visibilityCategory" : "visibilityCategory",
               "_visibility" : "visibility",
               "_packInfo" : "packInfo",
        ]
    }
            
    init(category: String="user", visibility: String="general", packInfo: VisibleSectionsWrapper) {
        super.init()
        _visibilityCategory = category
        _visibility = visibility
        let encoder = JSONEncoder()
        let asData = try! encoder.encode(packInfo)
//        let asData = try! encoder.encode(packIdsAndNames.map( { PackInfoWrapper(id: $0.0, name: $0.1) } ))
        _packInfo = String(data: asData, encoding: .utf8)
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
