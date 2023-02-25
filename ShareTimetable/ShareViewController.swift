//
//  ShareViewController.swift
//  ShareTimetable
//
//  Created by Hugh Drummond on 23/2/2023.
//

import UIKit
import SwiftUI
import Social
import Firebase
import FirebaseAuth

class CustomShareViewController: UIViewController {
    private var contents: String?
    var sharedItems: [Any] = []

    var segmentedControl: UISegmentedControl!
    let tableView = UITableView(frame: .zero, style: .plain)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .systemGray6
        setupNavBar()
        setupViews()
        getContent()
    }

    private func setupNavBar() {
        self.navigationItem.title = "Add Timetable"

        let itemCancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelAction))
        self.navigationItem.setLeftBarButton(itemCancel, animated: false)

        let itemSave = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveAction))
        self.navigationItem.setRightBarButton(itemSave, animated: false)
    }
    
    private func setupViews() {
        
        let choose = UILabel()
        choose.text = "Adding for Semester:"
        choose.textAlignment = .center
        choose.frame = CGRect(x: 0, y: 200, width: view.bounds.width, height: 50)
        view.addSubview(choose)
        
        
        segmentedControl = UISegmentedControl(items: ["Semester 1", "Semester 2", "Semester 3"])
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
        segmentedControl.frame = CGRect(x: 0, y: 250, width: view.bounds.width, height: 30)
        view.addSubview(segmentedControl)
        
        let label = UILabel()
        label.text = "Found Courses:"
        label.textAlignment = .center
        label.frame = CGRect(x: 0, y: 350, width: view.bounds.width, height: 50)
        view.addSubview(label)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.frame = CGRect(x: 0, y: 400, width: view.bounds.width, height: 400)
        view.addSubview(tableView)
    }

    // 3: Define the actions for the navigation items
    @objc private func cancelAction () {
        let error = NSError(domain: "com.hughdrummond.Social-Timetable", code: 0, userInfo: [NSLocalizedDescriptionKey: "Cancellation action"])
        extensionContext?.cancelRequest(withError: error)
    }

    @objc private func saveAction() {
        if let contents = contents {
            let semester = self.getSemester()
            let result = convertUQPlannerToEvents(contents: contents, semester: semester)
            switch result {
            case .success(let (events, courses)):
                print(events.values)
                print(courses)
                
                FirebaseApp.configure()
                
                try? Auth.auth().useUserAccessGroup("group.com.hughdrummond.Social-Timetable")
                if let email = Auth.auth().currentUser?.email {
                    getUserData(email: email) { result in
                        switch result {
                        case .success(let user):
                            if !events.keys.isEmpty && !courses.keys.isEmpty {
                                self.removeCourses(email: user.email, courses: user.courses)
                                user.events = events
                                user.courses = courses
                                self.setUserData(user: user)
                            }
                        case .failure(let error):
                            print("Error getting user data: \(error.localizedDescription)")
                        }
                    }
                }
                
            case .failure(let error):
                print(error)
            }
        }

        extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }
    
    @objc func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        print("Semester \(segmentedControl.selectedSegmentIndex + 1)")
    }
    
    func getContent() {
        if let item = extensionContext?.inputItems.first as? NSExtensionItem {
            if let attachment = item.attachments?.first {
                if attachment.hasRepresentationConforming(toTypeIdentifier: "com.apple.ical.ics") {
                    attachment.loadItem(forTypeIdentifier: "com.apple.ical.ics") { data, error in
                        if let result = data as? URL {
                            print("Found data")
                            do {
                                self.contents = try String(contentsOf: result)
                                if let contents = self.contents {
                                    let result = convertUQPlannerToEvents(contents: contents, semester: .S1)
                                    switch result {
                                    case .success(let (_, courses)):
                                        self.sharedItems = Array(courses["S1"] ?? [])
                                        DispatchQueue.main.async {
                                            self.tableView.reloadData()
                                        }
                                    case .failure(let error):
                                        print(error)
                                    }
                                }
                            } catch {
                                print("No contents")
                            }
                        } else {
                            print("Wrong data")
                        }
                    }
                }
            }
        }
    }
    
    func getSemester() -> Semester {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            return .S1
        case 1:
            return .S2
        case 2:
            return .S3
        default:
            return .S1
        }
    }
    
    private func getUserData(email: String, completion: @escaping ((Result<User, Error>) -> Void)) {
        let docRef = Firestore.firestore().collection("users").document(email)
        print("getUserData(\(email))")
        docRef.getDocument(as: User.self) { result in
            completion(result)
        }
    }
    
    private func removeCourses(email: String, courses: [String:Set<String>]) {
        let ref = Firestore.firestore().collection("chat")
        for semester in Semester.allCases {
            for course in courses[semester.rawValue] ?? [] {
                print("Removing: " + course + "_" + semester.rawValue)
                let docRef = ref.document(course + "_" + semester.rawValue)
                
                docRef.getDocument { (document, error) in
                    if let document = document, document.exists {
                        let data = document.data()
                        var participants = data!["participants"]! as? Array<String> ?? []
                        if let idx = participants.firstIndex(where: {$0 == email}) {
                            participants.remove(at: idx)
                            docRef.updateData(["participants":participants])
                        }
                    }
                }
            }
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
                        docRef.setData(["participants":[user.email]])
                    }
                }
            }
        }
    }
}

extension CustomShareViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sharedItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "\(sharedItems[indexPath.row])"
        return cell
    }
}

extension CustomShareViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = sharedItems[indexPath.row]
        print("Selected item: \(selectedItem)")
    }
}



@objc(CustomShareNavigationController)
class CustomShareNavigationController: UINavigationController {
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.setViewControllers([CustomShareViewController()], animated: false)
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
