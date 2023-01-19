//
//  LoginView.swift
//  Social Timetable
//
//  Created by Hugh Drummond on 6/1/2023.
//

import SwiftUI

struct LoginView: View {
    
    @State var studentID: Int?
    @State var password: String = ""
    @State var isSignIn: Bool = true
    
    @EnvironmentObject var viewModel: AppViewModel
    @State var idError: String? = nil
    @State var passwordError: String? = nil
    @State var fbError: String? = nil
    
    var body: some View {
        VStack {
            Label("Social Timetable", systemImage: "calendar")
                .font(.largeTitle)
            Picker(selection: $isSignIn, label: Text("Label")) {
                Text("Sign in")
                    .tag(true)
                Text("Create Account")
                    .tag(false)
            }
            .pickerStyle(.segmented)
            .padding(.vertical, 30)
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
            if idError != nil {
                Text(idError!)
                    .font(.caption)
                    .foregroundColor(.red)
            }
            
            SecureField("Password", text: $password)
                .autocorrectionDisabled(true)
                .textInputAutocapitalization(.never)
                .padding()
                .background(.tertiary, in: RoundedRectangle(cornerRadius: 8))
            if passwordError != nil {
                Text(passwordError!)
                    .font(.caption)
                    .foregroundColor(.red)
            }
            if fbError != nil {
                
            }
            if (viewModel.isLoading) {
                ProgressView()
                    .progressViewStyle(.circular)
                    .padding(30)
            } else {
                Text(fbError ?? "")
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(30)
            }
                           
            Button(action : {
                if (!isSignIn) {
                    withAnimation(.default) {
                        idError = studentID?.description.count != 8 ? "Student ID must be 8 digits" : nil
                    }
                    withAnimation(.default) {
                        passwordError = password.count < 6 ? "Password must be at least 6 characters in length" : nil
                    }
                } else {
                    // sign in
                    withAnimation(.default) {
                        idError = studentID == nil ? "Required Field" : nil
                    }
                    withAnimation(.default) {
                        passwordError = password.isEmpty ? "Required Field" : nil
                    }
                }
                
                if idError != nil || passwordError != nil {
                    return
                }

                let email = "s" + (studentID! / 10 ).description + "@student.uq.edu.au"
                fbError = nil
                if (!isSignIn) {
                    viewModel.signUp(email: email, password: password) { result in
                        switch result {
                        case .success(_):
                            fbError = nil
                        case .failure(let error):
                            fbError = error.localizedDescription
                        }
                    }
                } else {
                    viewModel.signIn(email: email, password: password) { result in
                        switch result {
                        case .success(_):
                            fbError = nil
                        case .failure(let error):
                            fbError = error.localizedDescription
                        }
                    }
                }
            }) {
                Text(isSignIn ? "Sign In" : "Create Account")
                    .frame(width: 200, height: 40)
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.isLoading)
        }
        .padding()
        .navigationTitle(isSignIn ? "Sign In" : "Create Account")
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(idError: "Student ID must be 8 digits", passwordError: "Password must be at least 6 characters in length")
            .environmentObject(AppViewModel())
    }
}