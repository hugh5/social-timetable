//
//  EventDetailView.swift
//  Social Timetable
//
//  Created by Hugh Drummond on 20/1/2023.
//

import SwiftUI

struct EventDetailView: View {
    
    @Binding var userEvent: UserEvent?
    @Environment(\.dismiss) var dismiss

    var body: some View {
        if let event = userEvent?.event, let user = userEvent?.user {
            VStack {
                Button(action: {
                    dismiss()
                }, label: {
                    Image(systemName: "chevron.down")
                })
                .padding(.top)
                List {
                    HStack {
                        Text("Student")
                            .frame(width: 70)
                        Text(user.displayName)
                            .bold()
                            .padding(6)
                            .foregroundColor(Color(user.color).isDarkColor ? .white : .black)
                            .background(Color(user.color))
                            .containerShape(RoundedRectangle(cornerRadius: 5))
                    }
                    HStack {
                        Text("Course")
                            .frame(width: 70)
                        Text(event.courseCode + " - " + event.semester)
                            .bold()
                    }
                    HStack {
                        Text("Name")
                            .frame(width: 70)
                        Text(event.course)
                            .bold()
                    }
                    HStack {
                        Text("Activity")
                            .frame(width: 70)
                        Text(event.classType + " - " + event.activity)
                            .bold()
                    }
                    HStack {
                        Text("Location")
                            .frame(width: 70)
                        Text(event.location)
                            .font(.subheadline)
                            .bold()
                    }
                    HStack {
                        Text("Time")
                            .frame(width: 70)
                        Text(event.startTime.formatted() + " - " + event.endTime.formatted(date: .omitted, time: .shortened))
                            .font(.subheadline)
                            .bold()
                    }
                    HStack {
                        Text("Duration")
                            .frame(width: 70)
                        Text(event.getDuration())
                            .font(.subheadline)
                            .bold()
                    }
                }
            }
        }
    }
    }

struct EventDetailView_Previews: PreviewProvider {
    static var previews: some View {
        EventDetailView(userEvent: .constant(UserEvent(user: User.sampleData, event: Event.sampleData[0])))
    }
}
