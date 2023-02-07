//
//  EventCardView.swift
//  UQ Social Timetable
//
//  Created by Hugh Drummond on 29/12/2022.
//

import SwiftUI

struct EventCardView: View {
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
                Text(event.getDuration())
                    .bold()
                    .lineLimit(1, reservesSpace: true)
                Text(event.location.components(separatedBy: " ")[0])
                    .lineLimit(1, reservesSpace: true)
            }
            .font(.subheadline)
            Text(name)
        }
        .lineLimit(1)
    }
}



struct EventCardView_Previews: PreviewProvider {
    static var previews: some View {
        EventCardView(name: User.sampleData.displayName, event: Event.sampleData[0])
    }
}
