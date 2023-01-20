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
                HStack {
                    Label(title: {
                        Text("Colour")
                    }, icon: {
                        ColorPicker("", selection: $color, supportsOpacity: false)
                            .padding(.leading, -10)

                            .onDisappear() {
                                if let hex = color.hex() {
                                    if user.color != hex {
                                        user.color = hex
                                        viewModel.setUserColor(hex: hex)
                                    }
                                }
                            }
                    })
                }
                .onAppear() {
                    displayName = user.displayName
                    color = Color(user.color)
                }
                NavigationLink {
                    FriendsView(user: $user)
                } label: {
                    Label("Friends", systemImage: "person.3")
                }
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
        AccountSettingsView(user: .constant(User.sampleData))
            .environmentObject(AppViewModel.sampleData)
        
    }
}
