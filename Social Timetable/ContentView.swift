//
//  ContentView.swift
//  Social Timetable
//
//  Created by Hugh Drummond on 6/1/2023.
//

import SwiftUI

struct ContentView: View {
    
    @Binding var user: User?
//    let date = convertStringToDate(string: "TZID=Australia/Brisbane:20221022T100000")
    let date: Date = .now
    
    var body: some View {
        TabView {
            WeekView(user: $user, date: date, selection: getSelection())
                .tabItem {
                    Label("Week", systemImage: "rectangle.grid.1x2")
                }
            Text("Home")
                .tabItem {
                    Text("Timetable")
                    Image(systemName: "calendar")
                }
            CourseChatsView(user: user)
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
    
    func getSelection() -> Int {
        var selection = Calendar.current.component(.weekday, from: date) - 2
        selection = selection < 0 ? 0 : selection
        selection = selection > 4 ? 4 : selection
        return selection
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(user: .constant(User.sampleData))
            .environmentObject(AppViewModel.sampleData)
    }
}
