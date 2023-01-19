//
//  ContentView.swift
//  Social Timetable
//
//  Created by Hugh Drummond on 6/1/2023.
//

import SwiftUI

struct ContentView: View {
    
    @Binding var user: User?
    let date = convertStringToDate(string: "TZID=Australia/Brisbane:20221017T100000")
//    let date: Date = .now
    
    var body: some View {
        TabView {
            WeekView(user: $user, date: date)
                .tabItem {
                    Label("Week", systemImage: "rectangle.grid.1x2")
                }
            Text("Home")
                .tabItem {
                    Text("Timetable")
                    Image(systemName: "calendar")
                }
            Text("Course Chats")
                .tabItem {
                    Text("Course Chats")
                    Image(systemName: "message")
                }
            SettingsView(user: $user)
                .tabItem {
                    Text("Settings")
                    Image(systemName: "gearshape")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(user: .constant(User.sampleData))
    }
}
