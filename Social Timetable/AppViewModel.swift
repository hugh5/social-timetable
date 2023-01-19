//
//  AppViewModel.swift
//  Social Timetable
//
//  Created by Hugh Drummond on 4/1/2023.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

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
                self?.getUserData()
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
            }
        }
    }
    
    func signOut() {
        isLoading = false
        try? auth.signOut()
        self.user = nil
        withAnimation(.default) {
            self.signedIn = false
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
    
    func getUserData() {
        if user != nil {
            return
        }
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
    
    func completionHandler(_ user: User) {
        users.append(user)
    }
    
    func getUsers() {
        if let user = user {
            users.append(user)
            for email in user.friends {
                
                let docRef = db.collection("users").document(email)
                docRef.getDocument(as: User.self) { result in
                    switch result {
                    case .success(let data):
                        self.completionHandler(data)
                    case .failure(let error):
                        print("Error getting user data: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    func setUserData() {
        if let id = self.user?.id {
            let docRef = db.collection("users").document(id)
            do {
                print("setUserData()")
                try docRef.setData(from: user)
            }
            catch {
                print("Error setting user data: \(error.localizedDescription)")
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
}

extension AppViewModel {
    static let sampleData: AppViewModel = {
        let viewModel = AppViewModel()
        viewModel.user = User.sampleData
        return viewModel
    }()
}
