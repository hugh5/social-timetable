//
//  SearchCourseView.swift
//  Social Timetable
//
//  Created by Hugh Drummond on 1/3/2023.
//

import SwiftUI

struct SearchCourseView: View {

    @State var semester: Semester = .S1
    @State var campus: Campus = .stluc
    @State var delivery: DeliveryMode = .intern
    @State var searchTerm: String = ""
    @State var courses: [Course] = []
    @State var queryError: String = ""

    var body: some View {
        VStack {
            Picker("Semester", selection: $semester) {
                ForEach(Semester.allCases, id: \.self) { sem in
                    Text(sem.description)
                }
            }
            .pickerStyle(.segmented)
            Picker("Campus", selection: $campus) {
                ForEach(Campus.allCases.sorted(by: {$0.rawValue > $1.rawValue}), id: \.self) { campus in
                    Text(campus.description)
                }
            }
            .pickerStyle(.segmented)
            Picker("Mode", selection: $delivery) {
                ForEach(DeliveryMode.allCases, id: \.self) { delivery in
                    Text(delivery.description)
                }
            }
            .pickerStyle(.segmented)
            TextField("Course", text: $searchTerm)
                .textFieldStyle(.plain)
                .padding()
                .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 8))
                .onSubmit {
                    queryCourse()
                }
            if !queryError.isEmpty {
                Text(queryError)
                    .foregroundColor(queryError == "Course successfully added" ? .green : .red)
            } else {
                EmptyView()
            }
            List {
                ForEach(courses) { course in
                    NavigationLink(course.id, destination: {
                        AddCourseView(course: course, message: $queryError)
                            .navigationTitle(course.description)
                    })
                }
            }
            .listStyle(.sidebar)

        }

        .padding()
    }

    func queryCourse() {
        if searchTerm.isEmpty {
            queryError = "Enter course code"
            return
        } else {
            queryError = ""
        }
        courses.removeAll()
        Course.queryCourse(searchTerm: searchTerm, semester: semester, campus: campus, deliveryMode: delivery) { result in
            switch result {
            case .failure(let error):
                queryError = error.localizedDescription
            case .success(let data):
                if data.isEmpty {
                    queryError = "No course found"
                } else {
                    courses = data
                }
            }
        }
    }

}

struct SearchCourseView_Previews: PreviewProvider {
    static var previews: some View {
        SearchCourseView(courses: [Course.sampleData])
    }
}
