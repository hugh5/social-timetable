//
//  ShareViewController.swift
//  ShareTimetable
//
//  Created by Hugh Drummond on 23/2/2023.
//

import UIKit
import Social
import Firebase
import FirebaseAuth

class ShareViewController: SLComposeServiceViewController {
    
    private var events = [Int: [Event]]()
    private var courses = [String:Set<String>]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func isContentValid() -> Bool {
        if let item = extensionContext?.inputItems.first as? NSExtensionItem {
            if let attachment = item.attachments?.first {
                if attachment.hasRepresentationConforming(toTypeIdentifier: "com.apple.ical.ics") {
                    attachment.loadItem(forTypeIdentifier: "com.apple.ical.ics") { data, error in
                        if let result = data as? URL {
                            print("Data:")
                            do {
                                let contents = try String(contentsOf: result)
                                let result = convertUQPlannerToEvents(contents: contents, semester: .S1)
                                switch result {
                                case .success(let (events, courses)):
                                    print(events.values)
                                    self.events = events
                                    print(courses)
                                    self.courses = courses
                                case .failure(let error):
                                    print(error)
                                }
                            } catch {
                                print("No contents")
                            }
                        } else {
                            print("Wrong data")
                        }
                    }
                    return true
                }
            }
        }
        return false
    }

    override func didSelectPost() {
        FirebaseApp.configure()
        
        try? Auth.auth().useUserAccessGroup("group.com.hughdrummond.Social-Timetable")
        if let email = Auth.auth().currentUser?.email {
            getUserData(email: email) { result in
                switch result {
                case .success(let user):
                    if !self.events.keys.isEmpty && !self.courses.keys.isEmpty {
                        user.events = self.events
                        user.courses = self.courses
                        self.setUserData(user: user)
                    }
                case .failure(let error):
                    print("Error getting user data: \(error.localizedDescription)")
                }
            }
        }
        
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }

    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }
    
    private func getUserData(email: String, completion: @escaping ((Result<User, Error>) -> Void)) {
        let docRef = Firestore.firestore().collection("users").document(email)
        print("getUserData(\(email))")
        docRef.getDocument(as: User.self) { result in
            completion(result)
        }
    }
    
    private func setUserData(user: User) {
        let docRef = Firestore.firestore().collection("users").document(user.email)
        do {
            print("setUserData()")
            try docRef.setData(from: user)
        }
        catch {
            print("Error setting user data: \(error.localizedDescription)")
        }
        for semester in user.courses.keys {
            for course in user.courses[semester] ?? [] {
                var participants = [String]()
                print(course + "_" + semester)
                let docRef = Firestore.firestore().collection("chat").document(course + "_" + semester)
                
                docRef.getDocument { (document, error) in
                    if let document = document, document.exists {
                        let data = document.data()
                        participants.append(contentsOf: data!["participants"]! as? Array<String> ?? [])
                        print(participants)
                        if (!participants.contains(where: {$0 == user.email})) {
                            participants.append(user.email)
                            docRef.updateData(["participants":participants])
                        }
                    } else {
                        print("Document does not exist")
                    }
                }
            }
        }
    }

}
