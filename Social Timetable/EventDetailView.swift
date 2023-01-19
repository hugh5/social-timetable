//
//  EventDetailView.swift
//  UQ Social Timetable
//
//  Created by Hugh Drummond on 29/12/2022.
//

import SwiftUI

struct EventDetailView: View {
    var name: String
    var event: Event

    var body: some View {
        VStack(alignment: .leading) {
            Text(event.courseCode)
                .font(.title3)
                .lineLimit(1)
            HStack {
                Text(event.classType)
                    .bold()
                Text("-")
                Text(event.activity)
            }
            HStack {
                Text(event.location.components(separatedBy: " ")[0])
                Text("\((event.endTime.timeIntervalSince(event.startTime) / 3600).description) hrs")
            }
            .font(.subheadline)
            Text(name)
        }
    }
}



struct EventDetailView_Previews: PreviewProvider {
    static var previews: some View {
        EventDetailView(name: User.sampleData.displayName, event: Event.sampleData[0])
    }
}
