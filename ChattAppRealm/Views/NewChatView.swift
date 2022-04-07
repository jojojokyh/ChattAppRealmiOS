//
//  NewChatView.swift
//  ChattAppRealm
//
//  Created by Joanne Yager on 2022-04-05.
//

import SwiftUI
import Firebase

struct NewChatView: View {
    @State private var showChatView = false
    let db = Firestore.firestore()
    @State private var chatName: String = ""
    
    var body: some View {
        VStack {
        HStack {
            Text("To:")
            TextField("Type a name or group", text: $chatName)
        }
            List{
                Text("Billy")
                Text("Sammy")
                Text(chatName)
            }
            .onTapGesture {
                db.collection("tmp").addDocument(data: ["name" : "testtmpLuca"])
                showChatView = true
            }
        Spacer()
            NavigationLink(destination: ChatView(), isActive: $showChatView) {
                EmptyView()
            }.isDetailLink(false)
        }
    }
}

struct NewChatView_Previews: PreviewProvider {
    static var previews: some View {
        NewChatView()
    }
}