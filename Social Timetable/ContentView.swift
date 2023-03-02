//
//  ContentView.swift
//  Social Timetable
//
//  Created by Hugh Drummond on 6/1/2023.
//

import SwiftUI

struct ContentView: View {
    @Binding var user: User?
    
    var body: some View {
        TabView {
            TimetableView()
                .tabItem {
                    Text("Timetable")
                    Image(systemName: "calendar")
                }
            CourseChatsView(user: $user)
                .tabItem {
                    Text("Course Chats")
                    Image(systemName: "message")
                }
            ManageCoursesView()
                .tabItem {
                    Text("Courses")
                    Image(systemName: "rectangle.grid.1x2.fill")
                }
            SettingsView(user: $user)
                .tabItem {
                    Text("Profile")
                    Image(systemName: "person")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(user: .constant(User.sampleData))
            .environmentObject(AppViewModel.sampleData)
    }
}
