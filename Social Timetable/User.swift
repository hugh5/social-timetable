//
//  User.swift
//  Social Timetable
//
//  Created by Hugh Drummond on 9/1/2023.
//

import Foundation
import FirebaseFirestoreSwift

class User: Codable, Identifiable, ObservableObject, Equatable {
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.email == rhs.email
    }
    
        
    @DocumentID var id: String?
    var tag: String
    var email: String
    var displayName: String
    var color: Int // hex
    var friends: [String]
    var incomingFriendRequests: [String]
    var outgoingFriendRequests: [String]

    var events: [Int:[Event]]
    var courses: [String:Set<String>]

    init(email: String) {
        print("New User")
        self.id = email
        self.tag = UUID().uuidString.prefix(8).description
        self.email = email
        self.displayName = email.components(separatedBy: "@")[0]
        self.color = Int.random(in: 0..<Int(pow(2.0, 24)))
        self.friends = []
        self.incomingFriendRequests = []
        self.outgoingFriendRequests = []
        self.events = [:]
        self.courses = [:]
    }
    
    init(email: String, name: String) {
        self.id = email
        self.tag = UUID().uuidString.prefix(8).description
        self.email = email
        self.displayName = name.prefix(12).description
        self.color = Int.random(in: 0..<Int(pow(2.0, 24)))
        self.friends = []
        self.incomingFriendRequests = []
        self.outgoingFriendRequests = []
        self.events = [:]
        self.courses = [:]
    }
}

extension User {
    static let sampleData: User = {
        var user = User(email: "s4697741@student.uq.edu.au", name: "Hugh")
        user.events[Calendar.current.ordinality(of: .day, in: .year, for: .now) ?? 1] = Event.sampleData
        user.events[350] = Event.sampleData
        user.friends = ["s1234567@student.uq.edu.au", "s2234567@student.uq.edu.au"]
        user.incomingFriendRequests = ["s3234567@student.uq.edu.au", "s4234567@student.uq.edu.au"]
        user.outgoingFriendRequests = ["s5234567@student.uq.edu.au", "s6234567@student.uq.edu.au"]
        user.courses = ["S1":["CSSE2310", "COMP3506"]]
        return user
    }()
}

struct UserEvent: Identifiable {

    var id: UUID
    let user: User
    let event: Event
    
    init(user: User, event: Event) {
        self.id = event.id
        self.user = user
        self.event = event
    }
    
}
