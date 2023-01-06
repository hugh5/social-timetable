//
//  AuthView.swift
//  Social Timetable
//
//  Created by Hugh Drummond on 4/1/2023.
//

import SwiftUI
import FirebaseAuth

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
    
    @Published var signedIn = false
    @Published var isLoading = false
    
    var isSignedIn: Bool {
        return auth.currentUser != nil
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
            }
        }
    }
    
    func signOut() {
        isLoading = false
        try? auth.signOut()
        withAnimation(.default) {
            self.signedIn = false
        }
    }
}

struct AuthView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Label("Social Timetable", systemImage: "calendar")
                    .font(.largeTitle)
                NavigationLink {
                    LoginView(signUp: false)
                } label: {
                    Text("Sign In")
                        .font(.title3)
                        .frame(width: 200, height: 40)
                }
                .padding()
                .buttonStyle(.borderedProminent)

                NavigationLink {
                    LoginView(signUp: true)
                } label: {
                    Text("Create Account")
                        .font(.title3)
                        .frame(width: 200, height: 40)
                }
                .padding()
                .buttonStyle(.borderedProminent)
            }
        }
    }
}


struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView()
    }
}
