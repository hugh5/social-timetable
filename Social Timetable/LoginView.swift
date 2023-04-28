//
//  LoginView.swift
//  Social Timetable
//
//  Created by Hugh Drummond on 6/1/2023.
//

import SwiftUI
import AuthenticationServices

struct LoginView: View {
    
    @State var email: String = ""
    @State var password: String = ""
    @State var isSignIn: Bool = true
    
    @EnvironmentObject var viewModel: AppViewModel
    @State var idError: String? = nil
    @State var passwordError: String? = nil
    @State var fbError: String? = nil
    @State var passwordResetInfo: String = ""
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack {
            Image(colorScheme == .light ? "social-timetable-black" : "social-timetable-white")
                .resizable()
                .scaledToFit()
            Picker(selection: $isSignIn, label: Text("Label")) {
                Text("Sign in")
                    .tag(true)
                Text("Create Account")
                    .tag(false)
            }
            .pickerStyle(.segmented)
            .padding(.vertical, 30)
            .animation(.default, value: isSignIn)

            TextField("Email", text: $email)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .autocorrectionDisabled(true)
                .textInputAutocapitalization(.never)
                .padding()
                .background(.tertiary, in: RoundedRectangle(cornerRadius: 8))
            if idError != nil {
                Text(idError!)
                    .font(.caption)
                    .foregroundColor(.red)
            }
            
            SecureField("Password", text: $password)
                .textContentType(isSignIn ? UITextContentType.password : UITextContentType.newPassword)
                .autocorrectionDisabled(true)
                .textInputAutocapitalization(.never)
                .padding()
                .background(.tertiary, in: RoundedRectangle(cornerRadius: 8))
                .onSubmit {
                    signIn()
                }
            
            if passwordError != nil {
                Text(passwordError!)
                    .font(.caption)
                    .foregroundColor(.red)
            }
            if (isSignIn) {
                Button(action: {
                    if email.isEmpty {
                        return
                    }
                    viewModel.resetPassword(email: email) { result in
                        switch result {
                        case .success(_):
                            passwordResetInfo = "Password Reset Email Sent"
                        case .failure(let error):
                            passwordResetInfo = error.localizedDescription
                        }
                    }
                }, label: {
                    VStack {
                        Text("Forgot Password")
                            .font(.title3)
                    }
                })
                .padding()
                Text(passwordResetInfo)
                    .foregroundColor(passwordResetInfo == "Password Reset Email Sent" ? .primary : .red)
                    .font(.caption)
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
                           
            Button(action: {
                signIn()
            }) {
                Text(isSignIn ? "Sign In" : "Create Account")
                    .frame(width: 200, height: 40)
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.isLoading)
        }
        .padding()
    }
    
    func signIn() {
        if (!isSignIn) {
            withAnimation(.default) {
                idError = email.isEmpty ? "Email is required" : nil
            }
            withAnimation(.default) {
                passwordError = password.count < 6 ? "Password must be at least 6 characters in length" : nil
            }
        } else {
            // sign in
            withAnimation(.default) {
                idError = email.isEmpty ? "Email is required" : nil
            }
            withAnimation(.default) {
                passwordError = password.isEmpty ? "Password is required" : nil
            }
        }
        
        if idError != nil || passwordError != nil {
            return
        }

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
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(idError: "Student ID must be 8 digits", passwordError: "Password must be at least 6 characters in length", passwordResetInfo: "Password Reset Email Sent")
            .environmentObject(AppViewModel())
    }
}
