//
//  CourseChatsView.swift
//  Social Timetable
//
//  Created by Hugh Drummond on 19/1/2023.
//

import SwiftUI

struct CourseChatsView: View {
    
    var user: User?
    let semesters: [String] = ["S1", "S2", "S3"]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(semesters, id:\.self) {semester in
                    if let user = user {
                        if (user.courses[semester] != nil) {
                            Text(semester)
                        }
                        ForEach(user.courses[semester]?.sorted {$0 < $1} ?? [], id:\.description) { course in
                            NavigationLink {
                                Text("Coming Soon")
                                    .navigationTitle(course + "_" + semester)
                            } label: {
                                Text(course)
                            }
                        }
                    }
                }
            }
        }
    }
}

struct CourseChatsView_Previews: PreviewProvider {
    static var previews: some View {
        CourseChatsView(user: User.sampleData)
    }
}
