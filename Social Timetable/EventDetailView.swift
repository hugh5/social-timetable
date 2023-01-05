//
//  EventDetailView.swift
//  UQ Social Timetable
//
//  Created by Hugh Drummond on 29/12/2022.
//

import SwiftUI

struct EventDetailView: View {
  var event: Event

  var body: some View {
    VStack(alignment: .leading) {
      Text(event.title)
        .font(.title)
        Text("Date: \(event.startTime.description) to: \(event.endTime.description)")
      Text(event.description)
    }
    .padding()
  }
}


struct EventDetailView_Previews: PreviewProvider {
    static var previews: some View {
        EventDetailView(event: Event.sampleData[0])
    }
}
