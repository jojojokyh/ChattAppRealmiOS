//
//  Chat.swift
//  ChattAppRealm
//
//  Created by Joanne Yager on 2022-04-08.
//

import Foundation
import RealmSwift

class Chat : Object, Codable, Identifiable {
    @Persisted(primaryKey: true) var id : String = UUID().uuidString
    var users_in_chat = [String]()
    var lastMessage : String = ""
    @Persisted var chat_name = ""
}
