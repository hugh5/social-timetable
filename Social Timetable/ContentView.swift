//
//  ContentView.swift
//  Social Timetable
//
//  Created by Hugh Drummond on 6/1/2023.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            Text("Today")
                .tabItem {
                    Label("Today", systemImage: "rectangle.grid.1x2")
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
            AccountView()
                .tabItem {
                    Text("Account")
                    Image(systemName: "person")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
