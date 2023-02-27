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
            HStack {
                Text(event.classType)
                    .bold()
                Text("-")
                Text(event.activity)
            }
            Text(event.location.components(separatedBy: " ")[0])
                .font(.subheadline)
            Text(name)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .frame(width: 130, alignment: .leading)
        .frame(height: CGFloat(event.endTime.timeIntervalSince(event.startTime) / (60*60))*100 - 10, alignment: .top)
    }
}



struct EventCardView_Previews: PreviewProvider {
    static var previews: some View {
        EventCardView(name: User.sampleData.displayName, event: Event.sampleData[0])
    }
}
