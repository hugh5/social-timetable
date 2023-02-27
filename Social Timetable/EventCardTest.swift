//
//  EventCardTest.swift
//  Social Timetable
//
//  Created by Hugh Drummond on 26/2/2023.
//

import SwiftUI

struct EventCardTest: View {
    var event: Event
    var name: String
    var action: () -> Void

    var body: some View {
        Button(action: {
            action()
        } , label: {
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
        })
        .buttonStyle(.plain)
    }
}



struct EventCardTest_Previews: PreviewProvider {
    static var previews: some View {
        EventCardTest(event: Event.sampleData[0], name: User.sampleData.displayName ,action: {})
    }
}
