//
//  User.swift
//  Social Timetable
//
//  Created by Hugh Drummond on 9/1/2023.
//

import Foundation
import FirebaseFirestoreSwift

class User: Codable, Identifiable, ObservableObject {
        
    @DocumentID var id: String?
    var email: String
    var displayName: String
    var color: Int // hex
    var friends: [String]
    var events: [Int:[Event]]
    var courses: [String:Set<String>]

    init(email: String) {
        self.id = email
        self.email = email
        self.displayName = email.components(separatedBy: "@")[0]
        self.color = Int.random(in: 0..<Int(pow(2.0, 24)))
        self.friends = []
        self.events = [:]
        self.courses = [:]
    }
}

extension User {
    static let sampleData: User = {
        var user = User(email: "s4697741@student.uq.edu.au")
        user.events[11] = Event.sampleData
        user.friends = ["s1234567@student.uq.edu.au", "s7654321@student.uq.edu.au"]
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
