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
    @State var color: Color = .accentColor

    var body: some View {
        List {
            if let user = user {
                Label(user.displayName, systemImage: "person")
                HStack {
                    Label(title: {
                        Text("Colour")
                    }, icon: {
                        ColorPicker("", selection: $color, supportsOpacity: false)
                            .padding(.leading, -10)

                            .onDisappear {
                                if let hex = color.hex() {
                                    user.color = hex
                                    viewModel.setUserColor(hex: hex)
                                }
                            }
                    })
                }
                .onAppear() {
                    color = Color(user.color)
                }

                Label(user.email, systemImage: "envelope")
                Label("Friends", systemImage: "person.3")
                ForEach(user.friends, id: \.self) { friend in
                    Label(friend, systemImage: "person")
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
