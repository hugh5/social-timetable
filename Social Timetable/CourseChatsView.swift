//
//  CourseChatsView.swift
//  Social Timetable
//
//  Created by Hugh Drummond on 19/1/2023.
//

import SwiftUI

struct CourseChatsView: View {
    
    @Binding var user: User?
    let semesters: [String] = ["S1", "S2", "S3"]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(semesters, id:\.self) {semester in
                    if let user = user {
                        if (user.courses[semester] != nil) {
                            Section(header: Text(semester)) {
                                ForEach(user.courses[semester]?.sorted {$0 < $1} ?? [], id:\.description) { course in
                                    NavigationLink {
                                        ChatView(user: user, course: course + "_" + semester)
                                            .navigationTitle(course + "_" + semester)
                                            .environmentObject(MessagesManager(channel: course + "_" + semester))
                                    } label: {
                                        Text(course)
                                    }
                                }
                            }
                        } else {
                            EmptyView()
                        }
                    }
                }
                if (user?.courses.keys.count ?? 0 == 0) {
                    Text("Upload your timetable!")
                        .padding()
                    NavigationLink {
                        UploadTimetableView()
                            .navigationTitle("Upload Timetable")
                    } label: {
                        Label("Add Timetable", systemImage: "calendar.badge.plus")
                    }
                }
            }
            .listStyle(.sidebar)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct CourseChatsView_Previews: PreviewProvider {
    static var previews: some View {
        CourseChatsView(user: .constant(User.sampleData))
            .environmentObject(MessagesManager.sampleData)
    }
}
