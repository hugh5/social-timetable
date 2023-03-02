//
//  SettingsView.swift
//  Social Timetable
//
//  Created by Hugh Drummond on 6/1/2023.
//

import SwiftUI

struct SettingsView: View {
    
    @Binding var user: User?

    
    var body: some View {
        NavigationView {
            List {
                NavigationLink {
                    AccountSettingsView(user: $user)
                        .navigationTitle("Account Settings")
                } label: {
                    Label("Account Settings", systemImage: "person.crop.circle")
                }
                NavigationLink {
                    FriendsView(user: $user)
                } label: {
                    Label("Friends", systemImage: "person.3")
                }
                
//                NavigationLink {
//                    UploadTimetableView()
//                        .navigationTitle("Upload Timetable")
//                } label: {
//                    Label("Add Timetable", systemImage: "calendar.badge.plus")
//                }
            }
            .navigationTitle("Settings")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(user: .constant(User.sampleData))
            .environmentObject(AppViewModel.sampleData)
    }
}
