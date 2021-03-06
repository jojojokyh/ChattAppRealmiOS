//
//  NewChatView.swift
//  ChattAppRealm
//
//  Created by Joanne Yager on 2022-04-05.
//

import SwiftUI
import Firebase

struct NewChatView: View {
        
    @State var usersInChat : [String] = [UserManager.userManager.currentUser?.id ?? User().id]
    
    @State private var searchTerm: String = ""
    @State private var selection = Set<User>()
    @State private var isEditMode: EditMode = .active
    @State var newChatName : String = ""
    
    @ObservedObject var state: StateController
    
    var body: some View {
        
        VStack {
            HStack {
                
                Button(action: {
                    state.appState = .Chats
                }, label: {
                    Image(systemName: "chevron.backward")
                    Text("Back")
                })
                    .padding(.leading)
                    .padding(.top, 20)
                Spacer()
            }
            
            HStack {
                
                Text("To:")
                TextField("Type a name or group", text: $searchTerm)
                    .autocapitalization(.none)
                
            }
            .padding()
            
            List(searchResult(), id: \.self, selection: $selection){ user in
                
                Text(user.username)
                
            }
            .searchable(text: $searchTerm)
        }
        .environment(\.editMode, self.$isEditMode)
        
        Spacer()
        
        HStack{
            
            Button {
                
                for user in selection{
                    
                    usersInChat.append(user.id)
                }
                
                removeDoubles()
                let newChat = checkIfChatExists()
                
                if newChat == ""{
                    
                    state.chatId = ""
                    state.usersInChat = usersInChat
                    newChatName = FirestoreChatDao.firestoreChatDao.createChatName(usersInChat: usersInChat)
                    state.chatName = FirestoreChatDao.firestoreChatDao.removeCurrentFromChatName(chatName: newChatName)
                    
                }else{
                    
                    var chat: Chat?
                    
                    for oldChat in FirestoreChatDao.firestoreChatDao.chats{
                        if oldChat.id == newChat{
                            chat = oldChat
                        }
                    }
                    state.chatId = chat!.id
                    state.usersInChat = chat!.users_in_chat
                    state.chatName = chat!.chat_name
                    print("exists!!")
                }
                state.appState = .Message
                
            } label: {
                
                Text("Start Chatting!!")
                
            }
        }
    }
    
    func removeDoubles(){
        
        var index = -1
        
        for item in usersInChat{
            
            var counter = 0
            
            for item2 in usersInChat{
                
                if item == item2{
                    counter += 1
                    if counter > 1{
                        index = usersInChat.firstIndex(of: item2)!
                    }
                }
            }
            if index > -1{
                usersInChat.remove(at: index)
                index = -1
            }
        }
    }
    
    
    func checkIfChatExists() -> String {
        
        for chat in FirestoreChatDao.firestoreChatDao.chats{
            
            if chat.users_in_chat.count == usersInChat.count{
                
                if chat.users_in_chat.sorted() == usersInChat.sorted(){
                    print("found")
                    return chat.id
                }
            }
        }
        print("not found")
        return ""
        
    }
    
    func searchResult() -> [User]{
        
        var result = [User]()
        
        if !searchTerm.isEmpty {
            
            FirestoreUserDao.firestoreContactDao.removeCurrentUser()
            for user in FirestoreUserDao.firestoreContactDao.registeredUsers{
                
                if user.username.localizedCaseInsensitiveContains(searchTerm) {
                    
                    result.append(user)
                    
                }
            }
        }
        
        return result
        
    }
}
