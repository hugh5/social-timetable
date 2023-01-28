//
//  ChatViewModel.swift
//  Social Timetable
//
//  Created by Hugh Drummond on 27/1/2023.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct Message: Identifiable, Codable {
    var id: String
    var text: String
    var userid: String
    var username: String
    var usercolor: Int
    var timestamp: Date
}

class MessagesManager: ObservableObject {
    @Published private(set) var messages: [Message] = []
    @Published private(set) var lastMessageId: String = ""
    
    var channel: String
    
    // Create an instance of our Firestore database
    let db = Firestore.firestore()
    
    // On initialize of the MessagesManager class, get the messages from Firestore
    init(channel: String) {
        self.channel = channel
        getMessages()
    }

    // Read message from Firestore in real-time with the addSnapShotListener
    func getMessages() {
        db.collection("chat").document(channel).collection("messages").addSnapshotListener { querySnapshot, error in
            
            // If we don't have documents, exit the function
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(String(describing: error))")
                return
            }
            
            // Mapping through the documents
            self.messages = documents.compactMap { document -> Message? in
                do {
                    // Converting each document into the Message model
                    // Note that data(as:) is a function available only in FirebaseFirestoreSwift package - remember to import it at the top
                    print("Getting messages from: " + document.reference.path.description)
                    return try document.data(as: Message.self)
                } catch {
                    // If we run into an error, print the error in the console
                    print("Error decoding document into Message: \(error)")

                    // Return nil if we run into an error - but the compactMap will not include it in the final array
                    return nil
                }
            }
            
            // Sorting the messages by sent date
            self.messages.sort { $0.timestamp < $1.timestamp }
            
            // Getting the ID of the last message so we automatically scroll to it in ContentView
            if let id = self.messages.last?.id {
                self.lastMessageId = id
            }
        }
    }
    
    // Add a message in Firestore
    func sendMessage(user: User, text: String) {

            
            
        // Create a new Message instance, with a unique ID, the text we passed, a received value set to false (since the user will always be the sender), and a timestamp
        let newMessage = Message(id: UUID().uuidString, text: text, userid: user.email, username: user.displayName, usercolor: user.color, timestamp: Date())
        
        let courseRef = db.collection("chat").document(channel)
        courseRef.getDocument { (document, error) in
            if let document = document, document.exists {
                
            } else {
                self.db.collection("chat").document(self.channel).setData([:])
            }
        }
        do {
            try courseRef.collection("messages").document().setData(from: newMessage)
        } catch {
            // If we run into an error, print the error in the console
            print("Error adding message to Firestore: \(error)")
        }
        // Create a new document in Firestore with the newMessage variable above, and use setData(from:) to convert the Message into Firestore data
        // Note that setData(from:) is a function available only in FirebaseFirestoreSwift package - remember to import it at the top
            
        
    }
}

extension MessagesManager {
    static let sampleData: MessagesManager = {
        let mm = MessagesManager(channel: "CSSE2310_S1")
        let id = UUID().uuidString
        mm.messages = [
            Message(id: UUID().uuidString, text: "Hello", userid: User.sampleData.email, username: User.sampleData.displayName, usercolor: User.sampleData.color, timestamp: convertStringToDate(string: "TZID=Australia/Brisbane:20221023T100000")),
            Message(id: id, text: "Hello", userid: User.sampleData.email, username: User.sampleData.displayName, usercolor: User.sampleData.color, timestamp: .now)]
        mm.lastMessageId = id
        return mm
    }()
}

extension Message {
    static let sampleData: Message = Message(id: UUID().uuidString, text: "UeVXtHUDQW LyQNErsjRp tnVBmyoiMH XjNcjWHGfe nESYUqrJDw jopLuuLFCc QjapuIcApw mnaxsvxpLo DsQuFemtrr IzplBpApsF", userid: User.sampleData.email, username: User.sampleData.displayName, usercolor: User.sampleData.color, timestamp: .now)
}
