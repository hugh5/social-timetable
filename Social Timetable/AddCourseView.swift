//
//  AddCourseView.swift
//  Social Timetable
//
//  Created by Hugh Drummond on 1/3/2023.
//

import SwiftUI

struct AddCourseView: View {
    
    var course: Course
    @State var selection: [String:String] = [:]
    @Binding var message: String
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: AppViewModel
    
    var body: some View {
        GeometryReader { geo in
            ScrollView {
                VStack {
                    ForEach(course.groups.keys.sorted(), id:\.self) { key in
                        HStack {
                            Text(key)
                                .frame(width: geo.size.width / 4)
                            Picker(key, selection: Binding(get: {
                                selection[key] ?? course.groups[key]!.first!
                            }, set: {
                                selection[key] = $0
                            })) {
                                ForEach(course.groups[key]!, id:\.self) { code in
                                    if let act = getActivity(group: key, code: code) {
                                        ActivityView(activity: act)
                                    } else {
                                        Text("Activity not found")
                                    }
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(width: geo.size.width * 3 / 4)
                            .frame(height: 120)
                        }
                    }
                    
                    Button(action: {
                        message = viewModel.addCourse(code: course.code, semester: course.semester, events: getEvents())
                        dismiss()
                    }, label: {
                        Text("Add Course")
                            .padding(.vertical, 5)
                            .padding(.horizontal, 30)
                    })
                    .buttonStyle(.borderedProminent)
                }
            }
        }
    }
    
    func getActivity(group: String, code: String) -> Activity? {
        return course.activities.first(where: {$0.group == group && $0.code == code})
    }
    
    func getEvents() -> [Event] {
        return course.getEvents(activities: course.groups.keys.map({
            return ($0, selection[$0] ?? course.groups[$0]!.first!)
        }))
    }
}

struct ActivityView: View {
    var activity: Activity
    
    var body: some View {
        HStack(spacing: 40) {
            Text(activity.weekday)
            Text(activity.startTime)
            Text(activity.code)
        }
    }
}

struct AddCourseView_Previews: PreviewProvider {
    static var previews: some View {
        AddCourseView(course: Course.sampleData, message: .constant("Course already added"))
            .environmentObject(AppViewModel.sampleData)
    }
}

