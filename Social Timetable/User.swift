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
        var user = User(email: "user00@gmail.com", name: "Hugh")
        user.color = 2940464127
        user.events[Calendar.current.ordinality(of: .day, in: .year, for: .now) ?? 1] = Event.sampleData
        user.events[350] = Event.sampleData
        user.friends = ["gh378a@gmail.com", "vvj9t2@gmail.com"]
        user.incomingFriendRequests = ["bt489t@gmail.com", "kjr784@gmail.com"]
        user.outgoingFriendRequests = ["q9ew32@gmail.com", "u89jnk@gmail.com"]
        user.courses = ["S1":["CSSE2310", "COMP3506"]]
        return user
    }()
}

struct UserEvent: Identifiable, Equatable{
    static func == (lhs: UserEvent, rhs: UserEvent) -> Bool {
        return lhs.user == rhs.user && lhs.event.id == rhs.event.id
    }
    

    var id: UUID
    let user: User
    let event: Event
    
    init(user: User, event: Event) {
        self.id = event.id
        self.user = user
        self.event = event
    }
    
}
