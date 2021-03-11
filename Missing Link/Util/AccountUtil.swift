//
//  AccountUtil.swift
//  Missing Link
//
//  Created by Benjamin Share on 5/31/20.
//  Copyright © 2020 Benjamin Share. All rights reserved.
//

import Foundation
import CommonCrypto

struct AccountInfo {
    var username: String
    var hash: String
    var found: Bool
}

let passwordHashFunction: (String, String) -> String = md5
let ACCOUNT_DBD_GROUP = DispatchGroup()


//MARK: Utility Functions

func md5(username: String, password: String) -> String {
    let str = username.uppercased() + password
    if let strData = str.data(using: String.Encoding.utf8) {
        var digest = [UInt8](repeating: 0, count:Int(CC_MD5_DIGEST_LENGTH))
           _ = strData.withUnsafeBytes {
               CC_MD5($0.baseAddress, UInt32(strData.count), &digest)
           }
    
    
           var md5String = ""
           for byte in digest {
               md5String += String(format:"%02x", UInt8(byte))
           }
           return md5String
       }
       return ""
}

func sha256(data : Data) -> Data {
    print(data)
    print(Int(CC_SHA256_DIGEST_LENGTH))
    var hash = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
    data.withUnsafeBytes {
        _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
    }
    print(Data(hash))
    print(data)
    return Data(hash)
}

func sha256AsStrings(string : String) -> String {
    let data = string.data(using: .utf8)!
    return String(data: Data(sha256(data: data)), encoding: .utf8)!
}

func weakHashFunction(password: String) -> String {
    return password + String(password.count)
}
