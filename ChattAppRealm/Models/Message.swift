//
//  Message.swift
//  ChattAppRealm
//
//  Created by Joanne Yager on 2022-04-07.
//

import Foundation

struct Message : Codable, Identifiable {
    var sender : String
   // var receiver : String = ""
    var text : String
    var timestamp : Date = Date()
    var id : String = UUID().uuidString
}
