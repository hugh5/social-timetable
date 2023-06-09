//
//  AppViewModel.swift
//  Social Timetable
//
//  Created by Hugh Drummond on 4/1/2023.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn
import FacebookLogin
import AuthenticationServices
import CryptoKit

enum FBError: Error, Identifiable {
    case error(String)
    
    var id: UUID {
        UUID()
    }
    
    var errorMessage: String {
        switch self {
        case .error(let message):
            return message
        }
    }
}

class AppViewModel: ObservableObject {
    
    let auth = Auth.auth()
    let db = Firestore.firestore()
    
    @Published var signedIn = false
    @Published var isLoading = false
        
    var isSignedIn: Bool {
        return auth.currentUser != nil
    }
    
    @Published var user: User? = nil
    @Published var users: [User] = []
    @Published var credentialError: String = ""
    
    private var currentNonce: String? = nil
    private var loginManager = LoginManager()
    
    init(){
        do {
            try Auth.auth().useUserAccessGroup("group.com.hughdrummond.Social-Timetable")
        } catch let error as NSError {
            print("Error changing user access group: %@", error)
        }
    }
    
    func signIn(email: String, password: String, completion: @escaping (Result<Bool, FBError>) -> Void) {
        isLoading = true
        auth.signIn(withEmail: email, password: password) { [weak self] result, error in
            if let error {
                DispatchQueue.main.async {
                    completion(.failure(.error(error.localizedDescription)))
                }
                self?.isLoading = false
            } else {
                DispatchQueue.main.async {
                    completion(.success(true))
                    self?.signedIn = true
                }
            }
        }
    }
    
    func signUp(email: String, password: String, completion: @escaping (Result<Bool, FBError>) -> Void) {
        isLoading = true
        auth.createUser(withEmail: email, password: password) { [weak self] result, error in
            if let error {
                DispatchQueue.main.async {
                    completion(.failure(.error(error.localizedDescription)))
                }
                self?.isLoading = false
            } else {
                DispatchQueue.main.async {
                    completion(.success(true))
                    self?.signedIn = true
                }
                self?.createUser()
                self?.setUserData()
                self?.getUsers()
            }
        }
    }
    
    func authenticateWithGoogle() {
        isLoading = true
        credentialError = ""
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            isLoading = false
            return
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
            
        // 4
        guard let presentingVC = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController else {
            isLoading = false
            return
        }
        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(withPresenting: presentingVC) { result, error in
            self.authenticateUser(for: result?.user, with: error)
        }

    }
    
    private func authenticateUser(for user: GIDGoogleUser?, with error: Error?) {
        // 1
        if let error = error {
            print(error.localizedDescription)
            isLoading = false
            return
        }

        // 2
        guard let accessToken = user?.accessToken, let idToken = user?.idToken else {
            isLoading = false
            return
        }

        let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString, accessToken: accessToken.tokenString)

        // 3
        auth.signIn(with: credential) { [unowned self] (_, error) in
            if let error = error {
                isLoading = false
                credentialError = error.localizedDescription
                print(error.localizedDescription)
            } else {
                self.signedIn = true
                if let profile = user?.profile {
                    print(profile.name)
                    let docRef = db.collection("users").document(profile.email)
                    docRef.getDocument { (document, error) in
                        if (document != nil && document!.exists) {
                            
                        } else {
                            self.user = User(email: profile.email, name: profile.givenName ?? profile.name)
                            self.setUserData()
                        }
                    }
                }
            }
        }
    }
    
    func authenticateWithFacebook() {
        isLoading = true
        credentialError = ""
        loginManager.logIn(permissions: ["public_profile", "email"], viewController: nil) { loginResult in
            switch loginResult {
            case .failed(let error):
                self.isLoading = false
                print(error)
            case .cancelled:
                self.isLoading = false
                print("User cancelled login.")
            case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                
                let accessTokenString = accessToken?.tokenString
                let credential = OAuthProvider.credential(withProviderID: "facebook.com", accessToken: accessTokenString!)
                Auth.auth().signIn(with: credential) { authResult, error in
                    self.isLoading = false
                    if let error = error {
                        self.credentialError = error.localizedDescription
                        print(error.localizedDescription)
                    } else {
                        self.signedIn = true
                    }
                }
                
                print("Logged in! \(grantedPermissions) \(declinedPermissions) \(String(describing: accessToken))")
                GraphRequest(graphPath: "me", parameters: ["fields": "email, name, first_name"]).start(completionHandler: { (connection, result, error) -> Void in
                    if let fbDetails = result as? NSDictionary {
                        guard let email = fbDetails.value(forKey: "email") as? String,
                                let firstName = fbDetails.value(forKey: "first_name") as? String else {
                            print("Error getting facebook details")
                            return
                        }
                        print(email)
                        print(firstName)
                        let docRef = self.db.collection("users").document(email)
                        docRef.getDocument { (document, error) in
                            if (document != nil && document!.exists) {
                                
                            } else {
                                self.user = User(email: email, name: firstName)
                                self.setUserData()
                            }
                        }
                    }
                })
            }
        }
    }
    
    func handleSignInWithAppleRequest(_ request: ASAuthorizationAppleIDRequest) {
        request.requestedScopes = [.fullName, .email]
        let nonce = randomNonceString()
        currentNonce = nonce
        request.nonce = sha256(nonce)
    }
    
    func handleSignInWithAppleCompletion(_ result: Result<ASAuthorization, Error>) {
        isLoading = true
        switch result {
        case .failure(let error):
            isLoading = false
            credentialError = error.localizedDescription
            print(error)
        case .success(let success):
            if let appleIdCredential = success.credential as? ASAuthorizationAppleIDCredential {
                guard let nonce = currentNonce else {
                    fatalError("Apple ID sign in: nonce is nil")
                }
                guard let appleIDToken = appleIdCredential.identityToken else {
                    credentialError = "Apple ID sign in: unable to fetch identity token"
                    return
                }
                guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                    credentialError = "Apple ID sign in: unable to serialise token"
                    return
                }
                let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
                
                auth.signIn(with: credential) { (authResult, error) in
                    if let result = authResult {
                        guard let email = result.user.email else {
                            self.isLoading = false
                            self.credentialError = "Email not found"
                            return
                        }
                        self.signedIn = true
                        self.isLoading = false

                        let docRef = self.db.collection("users").document(email)
                        docRef.getDocument { (document, error) in
                            if (document != nil && document!.exists) {
                                
                            } else {
                                if let name = result.user.displayName {
                                    self.user = User(email: email, name: name)
                                } else {
                                    self.user = User(email: email)
                                }
                                self.setUserData()
                            }
                        }
                    } else {
                        self.isLoading = false
                        self.credentialError = error?.localizedDescription ?? "Nil auth result"
                        print(error?.localizedDescription ?? "Nil auth result")
                        return
                    }
                }
            }
        }
    }
    
    func authenticateAsTester() {
        isLoading = true
        let email = "test@gmail.com"
        auth.signIn(withEmail: email, password: "password") { [weak self] result, error in
            if let error {
                self?.credentialError = error.localizedDescription
                self?.isLoading = false
            } else {
                self?.signedIn = true
                if let docRef = self?.db.collection("users").document(email) {
                    docRef.getDocument { (document, error) in
                        if (document != nil && document!.exists) {
                            
                        } else {
                            self?.user = User(email: email, name: email.prefix(4).description)
                            self?.setUserData()
                        }
                    }
                }
            }
        }
    }
    
    func signOut() {
        // 1
        GIDSignIn.sharedInstance.signOut()
      
        isLoading = false
        try? auth.signOut()
        self.user = nil
        self.users = []
        withAnimation(.default) {
            self.signedIn = false
        }
    }
    
    func resetPassword(email: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        auth.sendPasswordReset(withEmail: email) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
        }
    }
    
    var email: String? {
        auth.currentUser?.email
    }
    
    func createUser() {
        if let email = auth.currentUser?.email {
            self.user = User(email: email)
        }
    }
    
    func getData() {
        if let id = email {
            let docRef = db.collection("users").document(id)
            print("getUserData()")
            docRef.getDocument(as: User.self) { result in
                switch result {
                case .success(let user):
                    self.user = user
                    self.getUsers()
                case .failure(let error):
                    print("Error getting user data: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func getUsers() {
        if let user = user {
            print("getUsers()")
            if let idx = self.users.firstIndex(where: {$0.email == user.email}) {
                self.users[idx] = user
            } else {
                self.users.insert(user, at: 0)
            }
            for account in user.friends {
                let docRef = db.collection("users").document(account)
                docRef.getDocument(as: User.self) { result in
                    switch result {
                    case .success(let data):
                        if let idx = self.users.firstIndex(where: {$0.email == data.email}) {
                            self.users[idx] = data
                        } else if let idx = self.users.firstIndex(where: {data.email < $0.email && $0.email != self.email}) {
                            self.users.insert(data, at: idx)
                        } else {
                            self.users.append(data)
                        }
                        case .failure(let error):
                        print("Error getting user data: \(error.localizedDescription)")
                    }
                }
            }
            users = users.filter({user.friends.contains($0.email) || $0.email == user.email })
        }
    }
    
    func setUserData() {
        if let user = self.user {
            let docRef = db.collection("users").document(user.email)
            do {
                print("setUserData()")
                try docRef.setData(from: user)
            }
            catch {
                print("Error setting user data: \(error.localizedDescription)")
            }
        }
    }
    
    func setDisplayName(name: String) {
        if let user = self.user {
            if let id = user.id {
                let docRef = db.collection("users").document(id)
                print("setDisplayName(\(name)")
                docRef.updateData(["displayName": name])
            }
        }
    }
    
    func setUserColor(hex: Int) {
        if let user = self.user {
            if let id = user.id {
                let docRef = db.collection("users").document(id)
                print("setUserColor(#\(String(format:"%06X", hex))")
                docRef.updateData(["color": hex])
            }
        }
    }
    
    func addCourse(code: String, semester: Semester, events: [Event]) -> String {
        if let user = user {
            if user.courses[semester.rawValue]?.contains(code) ?? false {
                return "Course already added"
            }
            let docRef = db.collection("users").document(user.email)
            docRef.getDocument(as: User.self) { result in
                switch result {
                case .success(let user):
                    // Add events
                    for event in events {
                        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: event.startTime)!
                        if user.events[dayOfYear] == nil {
                            user.events[dayOfYear] = [event]
                        } else {
                            user.events[dayOfYear]?.append(event)
                        }
                    }
                    
                    // Add course
                    if (user.courses[semester.rawValue] == nil) {
                        user.courses[semester.rawValue] = []
                    }
                    if !user.courses[semester.rawValue]!.contains(where: {$0 == code}) {
                        user.courses[semester.rawValue]!.insert(code)
                    }
                    do {
                        print("Events added: \(events)")
                        print("Course added: \(code)")
                        try docRef.setData(from: user)
                        self.user = user
                    }
                    catch {
                        print("Error setting new data: \(error.localizedDescription)")
                    }
                case.failure(let error):
                    print(error.localizedDescription)
                }
            }
            
            // Add participant
            let chatRef = db.collection("chat").document(code + "_" + semester.rawValue)
            chatRef.getDocument() { result, error  in
                if let result = result {
                    var participants = [String]()
                    if let data = result.get("participants") {
                        participants.append(contentsOf: data as! [String])
                    }
                    if let email = self.email {
                        if (!participants.contains(where: {$0 == email})) {
                            participants.append(email)
                        }
                    }
                    print("Participant added: \(participants)")
                    if result.exists {
                        chatRef.updateData(["participants":participants])
                    } else {
                        chatRef.setData(["participants":participants])
                    }
                }
            }
            return "Course successfully added"
        }
        return "Failed to find user"
    }
    
    func removeCourse(code: String, semester: String) {
        if let user = user {
            let docRef = db.collection("users").document(user.email)
            docRef.getDocument(as: User.self) { result in
                switch result {
                case .success(let user):
                    for day in user.events.keys {
                        user.events[day]!.removeAll(where: {$0.courseCode == code && $0.semester == semester})
                        if user.events[day]!.isEmpty {
                            user.events.removeValue(forKey: day)
                        }
                    }
                    
                    // Remove Course
                    if user.courses[semester]?.contains(where: {$0 == code}) ?? false {
                        user.courses[semester]!.remove(code)
                        if user.courses[semester]?.isEmpty ?? false {
                            user.courses.removeValue(forKey: semester)
                        }
                    }
                    do {
                        print("Events added: \(user.events)")
                        print("Course added: \(user.courses)")
                        try docRef.setData(from: user)
                        self.user = user
                    }
                    catch {
                        print("Error setting new data: \(error.localizedDescription)")
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
                
            }
                        
            // Remove chat participant
            if let course = user.courses[semester]?.first(where: {$0 == code}) {
                let ref = db.collection("chat").document(course + "_" + semester)
                ref.getDocument { (document, error) in
                    if let document = document, document.exists {
                        let data = document.data()
                        var participants = data!["participants"]! as? Array<String> ?? []
                        if let idx = participants.firstIndex(where: {$0 == user.email}) {
                            participants.remove(at: idx)
                            print("Participant removed: \(participants)")
                            ref.updateData(["participants":participants])
                        }
                    }
                }
            }
        }
        
    }
    
    func getUserByEmail(email: String, completion: @escaping (Result<(email: String, name: String, color: Int), Error>) -> Void) {
        let docRef = db.collection("users").document(email)
        docRef.getDocument(as: User.self) { result in
            switch result {
            case .success(let data):
                completion(.success((data.email, data.displayName, data.color)))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getUserByName(name: String, completion: @escaping (Result<[(email: String, tag: String, name: String, color: Int)], Error>) -> Void) {
        var queriedUsers = [(String, String, String, Int)]()
        let query = db.collection("users").whereField("displayName", isGreaterThanOrEqualTo: name).whereField("displayName", isLessThan: "\(name)z")
        query.getDocuments() { (querySnapshot, err) in
            if let err = err {
                completion(.failure(err))
                print("Error getting user from display name: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let data = document.data()
                    guard let email = data["email"] as? String, let tag = data["tag"] as? String, let name = data["displayName"] as? String, let color = data["color"] as? Int else {
                        continue
                    }
                    print("Found: \(email), \(name)")
                    queriedUsers.append((email, tag, name, color))
                }
                completion(.success(queriedUsers))
            }
        }
    }
    
    func getUserByTag(tag: String, completion: @escaping (Result<[(email: String, tag: String, name: String, color: Int)], Error>) -> Void) {
        var queriedUsers = [(String, String, String, Int)]()
        let query = db.collection("users").whereField("tag", isGreaterThanOrEqualTo: tag.uppercased()).whereField("tag", isLessThan: "\(tag.uppercased())z")
        query.getDocuments() { (querySnapshot, err) in
            if let err = err {
                completion(.failure(err))
                print("Error getting user from tag: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let data = document.data()
                    guard let email = data["email"] as? String, let tag = data["tag"] as? String, let name = data["displayName"] as? String, let color = data["color"] as? Int else {
                        continue
                    }
                    print("Found: \(email), \(name)")
                    queriedUsers.append((email, tag, name, color))
                }
                completion(.success(queriedUsers))
            }
        }
    }
    
    func getFriendData(key: FriendKey, completion: @escaping (Result<(email: String, tag: String, name: String, color: Int), Error>) -> Void) {
        if let user = self.user {
            
            var accounts: [String]
            switch key {
            case.friend:
                accounts = user.friends
            case .incomingFriend:
                accounts = user.incomingFriendRequests
            case .outgoingFriend:
                accounts = user.outgoingFriendRequests
            }
            
            for account in accounts {
                let docRef = db.collection("users").document(account)
                docRef.getDocument(as: User.self) { result in
                    switch result {
                    case .success(let data):
                        completion(.success((data.email, data.tag, data.displayName, data.color)))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            }
        }
    }
    
    func setFriendData(key: FriendKey, _ friends: [String]) {
        if let user = self.user {
            
            let diff: CollectionDifference<String> = {
                switch key {
                case .friend:
                    return friends.difference(from: user.friends)
                case .incomingFriend:
                    return friends.difference(from: user.incomingFriendRequests)
                case .outgoingFriend:
                    return friends.difference(from: user.outgoingFriendRequests)
                }
            }()
            let updateKey: FriendKey = {
                switch key {
                case .friend: return .friend
                case .incomingFriend: return .outgoingFriend
                case .outgoingFriend: return .incomingFriend
                }
            }()
            for change in diff {
                switch change {
                case let .remove(_, element, _):
                    print("remove(email:\(element), key:\(updateKey.description), toRemove:\(user.email)")
                    removeFriendData(email: element, key: updateKey, toRemove: user.email)
                case let .insert(_, element, _):
                    print("insert(email:\(element), key:\(updateKey.description), toAdd:\(user.email)")
                    addFriendData(email: element, key: updateKey, toAdd: user.email)
                }
            }
            switch key {
            case .friend: user.friends = friends
            case .incomingFriend: user.incomingFriendRequests = friends
            case .outgoingFriend: user.outgoingFriendRequests = friends
            }
            
            if let id = user.id {
                let docRef = db.collection("users").document(id)
                print("update(email:\(user.email), key:\(key), newData:\(friends)")
                docRef.updateData([key.description: friends])
            }
        }
    }
    
    func removeFriendData(email: String, key: FriendKey, toRemove: String) {
        let docRef = db.collection("users").document(email)
        docRef.getDocument(as: User.self) { result in
            switch result {
            case .success(let data):
                var arr = []
                switch key {
                case .friend:
                    arr.append(contentsOf: data.friends)
                    if let idx = data.friends.firstIndex(of: toRemove) {
                        arr.remove(at: idx)
                    }
                case .incomingFriend:
                    arr.append(contentsOf: data.incomingFriendRequests)
                    if let idx = data.incomingFriendRequests.firstIndex(of: toRemove) {
                        arr.remove(at: idx)
                    }
                case .outgoingFriend:
                    arr.append(contentsOf: data.outgoingFriendRequests)
                    if let idx = data.outgoingFriendRequests.firstIndex(of: toRemove) {
                        arr.remove(at: idx)
                    }
                }
                docRef.updateData([key.description: arr])
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func addFriendData(email: String, key: FriendKey, toAdd: String) {
        let docRef = db.collection("users").document(email)
        docRef.getDocument(as: User.self) { result in
            switch result {
            case .success(let data):
                var arr: [String] = []
                switch key {
                case .friend:
                    arr.append(contentsOf: data.friends)
                    if !arr.contains(where: {$0 == toAdd}) {
                        arr.append(toAdd)
                    }
                    docRef.updateData([key.description: arr])
                case .incomingFriend:
                    arr.append(contentsOf: data.incomingFriendRequests)
                    if !arr.contains(where: {$0 == toAdd}) {
                        arr.append(toAdd)
                    }
                    docRef.updateData([key.description: arr])
                case .outgoingFriend:
                    arr.append(contentsOf: data.outgoingFriendRequests)
                    if !arr.contains(where: {$0 == toAdd}) {
                        arr.append(toAdd)
                    }
                    docRef.updateData([key.description: arr])
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    enum FriendKey {
        case friend
        case incomingFriend
        case outgoingFriend
        
        var description: String {
            switch self {
            case .friend: return "friends"
            case .incomingFriend: return "incomingFriendRequests"
            case .outgoingFriend: return "outgoingFriendRequests"
            }
        }
    }
    
    // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
    private func randomNonceString(length: Int = 32) -> String {
      precondition(length > 0)
      let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
      var result = ""
      var remainingLength = length

      while remainingLength > 0 {
        let randoms: [UInt8] = (0 ..< 16).map { _ in
          var random: UInt8 = 0
          let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
          if errorCode != errSecSuccess {
            fatalError(
              "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
            )
          }
          return random
        }

        randoms.forEach { random in
          if remainingLength == 0 {
            return
          }

          if random < charset.count {
            result.append(charset[Int(random)])
            remainingLength -= 1
          }
        }
      }

      return result
    }
    
    private func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData.compactMap {
        String(format: "%02x", $0)
      }.joined()

      return hashString
    }
}

extension AppViewModel {
    static let sampleData: AppViewModel = {
        let viewModel = AppViewModel()
        viewModel.user = User.sampleData
        viewModel.users = [User.sampleData]
        return viewModel
    }()
}
