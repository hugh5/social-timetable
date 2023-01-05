//
//  AuthView.swift
//  Social Timetable
//
//  Created by Hugh Drummond on 4/1/2023.
//

import SwiftUI
import FirebaseAuth

class AppViewModel: ObservableObject {
    
    let auth = Auth.auth()
    
    @Published var signedIn = false
    
    var isSignedIn: Bool {
        return auth.currentUser != nil
    }
    
    func signIn(email: String, password: String) {
        auth.signIn(withEmail: email, password: password) { [weak self] result, error in
            guard result != nil, error == nil else {
                return
            }
            
            DispatchQueue.main.async {
                self?.signedIn = true
            }
        }
    }
    
    func signUp(email: String, password: String) {
        auth.createUser(withEmail: email, password: password) { [weak self] result, error in
            guard result != nil, error == nil else {
                return
            }
            
            DispatchQueue.main.async {
                self?.signedIn = true
            }
        }
    }
    
    func signOut() {
        try? auth.signOut()
        
        self.signedIn = false
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

struct LoginView: View {
    
    @State var studentID: Int?
    @State var password: String = ""
    var signUp: Bool
    @EnvironmentObject var viewModel: AppViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                Label("Social Timetable", systemImage: "calendar")
                    .font(.largeTitle)
                Spacer()
                HStack {
                    Text("Student ID")
                        .padding()
                    TextField("41234567", text: Binding(
                        get: { (studentID != nil) ? studentID!.description : ""},
                        set: { studentID = Int($0) ?? nil }
                    ))
                        .keyboardType(.numberPad)
                        .autocorrectionDisabled(true)
                        .textInputAutocapitalization(.never)
                        .padding()
                        .multilineTextAlignment(.trailing)
                }
                .background(.tertiary, in: RoundedRectangle(cornerRadius: 8))
                SecureField("Password", text: $password)
                    .autocorrectionDisabled(true)
                    .textInputAutocapitalization(.never)
                    .padding()
                    .background(.tertiary, in: RoundedRectangle(cornerRadius: 8))
                Spacer()
                Button(action : {
                    guard studentID ?? 0 > 0, !password.isEmpty else {
                        return
                    }
                    let email = "s" + (studentID! / 10 ).description + "@student.uq.edu.au"
                    if (signUp) {
                        viewModel.signUp(email: email, password: password)
                    } else {
                        viewModel.signIn(email: email, password: password)
                    }
                }) {
                    Text(signUp ? "Create Account" : "Sign In")
                        .frame(width: 200, height: 40)
                    
                }
                .buttonStyle(.borderedProminent)
                Spacer()
            }
            .padding()
            .navigationTitle(signUp ? "Create Account" : "Sign In")
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(signUp: true)
    }
}
