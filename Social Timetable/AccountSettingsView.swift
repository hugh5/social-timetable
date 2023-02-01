//
//  AccountSettingsView.swift
//  Social Timetable
//
//  Created by Hugh Drummond on 7/1/2023.
//

import SwiftUI

struct AccountSettingsView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @Binding var user: User?
    @State var displayName: String = ""
    @State var color: Color = .accentColor
    
    @State var passwordResetInfo = ""

    var body: some View {
        List {
            if let user = user {
                Label(user.email, systemImage: "envelope")
                Label(title: {
                    TextField("Username", text: $displayName)
                        .padding(5)
                        .background(.tertiary)
                        .containerShape(RoundedRectangle(cornerRadius: 5))
                        .onDisappear() {
                            if !displayName.isEmpty {
                                if user.displayName != displayName {
                                    user.displayName = displayName
                                    viewModel.setDisplayName(name: displayName)
                                }
                            }
                        }
                }, icon: {
                    Image(systemName: "person")
                })
                Label(title: {
                    ColorPicker("", selection: $color, supportsOpacity: false)
                        .onDisappear() {
                            if let hex = color.hex() {
                                if user.color != hex {
                                    user.color = hex
                                    viewModel.setUserColor(hex: hex)
                                }
                            }
                        }
                        .frame(width: 0)
                        .padding(.horizontal)
                }, icon: {
                    Image(systemName: "paintpalette")
                })
                .onAppear() {
                    displayName = user.displayName
                    color = Color(user.color)
                }
                Button(action: {
                    viewModel.resetPassword(email: user.email) { result in
                        switch result {
                        case .success(_):
                            passwordResetInfo = "Password Reset Email Sent"
                        case .failure(let error):
                            passwordResetInfo = error.localizedDescription
                        }
                    }
                }, label: {
                    Label(title: {
                        VStack(alignment: .leading) {
                            Text("Reset Password")
                            if !passwordResetInfo.isEmpty {
                                Text(passwordResetInfo)
                                    .foregroundColor(passwordResetInfo == "Password Reset Email Sent" ? .primary : .red)
                                    .font(.subheadline)
                            }
                        }
                    }, icon: {
                        Image(systemName: "lock.rotation")
                    })
                })
            }
            Button(action: {
                viewModel.signOut()
            }) {
                Label("Logout", systemImage: "lock")
            }

        }

    }
}

struct AccountSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        AccountSettingsView(user: .constant(User.sampleData), passwordResetInfo: "Password Reset Email Sent")
            .environmentObject(AppViewModel.sampleData)
        
    }
}
