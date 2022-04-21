//
//  FirestoreMessageDao.swift
//  ChattAppRealm
//
//  Created by Joanne Yager on 2022-04-07.
//

import Foundation
import Firebase

struct MessageData {
    var text: String
}
class FirestoreMessageDao : ObservableObject {
    static let firestoreMessageDao = FirestoreMessageDao()
    
    private init(){}
    
    let db = Firestore.firestore()
    @Published var messages = [Message]()
    @Published var lastMessage : Message?
    
    private let ID_KEY = "id"
    private let SENDER_KEY = "sender"
    private let TEXT_KEY = "text"
    private let TIMESTAMP_KEY = "timestamp"

    private let MESSAGES_COLLECTION = "messages"
    private let CHATS_COLLECTION = "chats"
    
    

    func saveMessage(message: Message, chatId : String) {
        
        do {
            print("enter do")
            try db.collection(CHATS_COLLECTION)
                .document(chatId).collection(MESSAGES_COLLECTION)
                .document(message.id).setData(from: message)
            print("first done")

            db.collection(CHATS_COLLECTION)
                .document(chatId)
                .setData([ "lastMessage": message.text ], merge: true)
            print("second done")


            messages.removeAll()
            
        } catch{
            
            print("Error saving newMessage to db")
        }
            
    }
    
    func listenToFirestore(chatId : String) {
        if chatId != "" {
          //  db.collection(CHATS_COLLECTION).document(chatId).collection(MESSAGES_COLLECTION).addSnapshotListener { snapshot, err in
                
                db.collection(CHATS_COLLECTION).document(chatId).collection(MESSAGES_COLLECTION).order(by: "timestamp", descending: false).addSnapshotListener { snapshot, err in
                
                guard let snapshot = snapshot else { return }
                if let err = err {
                    print("Error getting document \(err)")
                } else {
                    self.messages.removeAll()
                    for document in snapshot.documents {
                        let result = Result {
                            try document.data(as: Message.self)
                        }
                        switch result {
                        case .success(let message) :
                            self.messages.append(message)
                           // self.lastMessage = message
                          //  print("MessageDao-listenToFirestore lastMessage = \(message)")
//                            print("latestMessage = \(self.latestMessage)")
                        case .failure(let error) :
                            print("Error decoding item: \(error)")
                        }
                    }
                }
            }
            DispatchQueue.main.async {
                self.lastMessage = self.messages.last ?? Message()
            }
        }
    }
    
    func readLastMessage(chatId : String, completionHandler: (Message) -> Void) {
        var lastMessage = Message()
        
        db.collection(CHATS_COLLECTION).document(chatId).collection(MESSAGES_COLLECTION).order(by: "timestamp", descending: true).limit(to: 1).addSnapshotListener { snapshot, err in
            
            guard let snapshot = snapshot else { return }
            if let err = err {
                print("Error getting last message \(err)")
            } else {
                for document in snapshot.documents {
                    let result = Result {
                        try document.data(as: Message.self)
                    }
                    switch result {
                    case .success(let message) :
                        lastMessage = message
                        
                       // print("message in readLastMessage: \(message)")
                      // print("lastMessage in readLastMessage: \(self.lastMessage)")

                    case .failure(let error) :
                        print("Error decoding item: \(error)")
                    }
                }
            }
        }
        completionHandler(lastMessage)
        print("lastMessage in readLastMessage: \(String(describing: self.lastMessage))")

    }
}
