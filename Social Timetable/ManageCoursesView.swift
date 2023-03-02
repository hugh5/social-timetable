//
//  ManageCoursesView.swift
//  Social Timetable
//
//  Created by Hugh Drummond on 2/3/2023.
//

import SwiftUI


struct ManageCoursesView: View {
    
    @EnvironmentObject var viewModel: AppViewModel

    var body: some View {
        if let user = viewModel.user {
            VStack {
                List {
                    ForEach(Array(user.courses.keys).sorted(), id: \.self) { semester in
                        Section(semester.description) {
                            ForEach(user.courses[semester]?.sorted() ?? [], id:\.self) { course in
                                HStack {
                                    Text(course)
                                    Spacer()
                                    Button(action: {
                                        viewModel.removeCourse(code: course, semester: semester)
                                    }, label: {
                                        Text("Delete")
                                    })
                                    .buttonStyle(.bordered)
                                    .foregroundColor(.red)
                                }
                            }
                        }
                    }
                    NavigationLink(destination: {
                        SearchCourseView()
                            .navigationTitle("Course Search")
                    }, label: {
                        Text("Add Courses")
                            .padding(.vertical, 5)
                            .padding(.horizontal, 30)
                    })
                    .buttonStyle(.bordered)
                }
            }
        } else {
            EmptyView()
        }
    }
}

struct ManageCoursesView_Previews: PreviewProvider {
    static var previews: some View {
        ManageCoursesView()
            .environmentObject(AppViewModel.sampleData)
    }
}
