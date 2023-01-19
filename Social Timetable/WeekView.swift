//
//  WeekView.swift
//  Social Timetable
//
//  Created by Hugh Drummond on 6/1/2023.
//

import SwiftUI

struct WeekView: View {

    
    let calendar = Calendar.current
    @Binding var user: User?
    @State var date: Date
    @State private var dragOffset = CGSize.zero
    @EnvironmentObject var viewModel: AppViewModel
    
    let daysOfWeek = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
    
    @State private var selection: Int = 0
    
    var body: some View {
        VStack {
            NavigationView {
                VStack(alignment: .leading) {
                    ScrollSlidingTabBar(selection: $selection, tabs: daysOfWeek)
                    TabView(selection: $selection) {
                        ForEach(0..<5) { day in
                            DayView(user: $user, events: getEvents(dayOfWeek: day + 2))
                                .tag(day)
                        }
                    }
                    .navigationTitle("\(getDate(dayOfWeek:selection + 2).formatted(date: .abbreviated, time: .omitted))")
                    .navigationBarTitleDisplayMode(.inline)
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .animation(.default, value: selection)
                }
            }
            .onAppear {
                selection = calendar.component(.weekday, from: date) - 2
                selection = selection < 0 || selection > 4 ? 0 : selection
            }
            ScrollView(.horizontal) {
                HStack {
                    ForEach(viewModel.users) { account in
                        Label(title: {
                            Text(account.displayName)
                        }, icon: {
                            Image(systemName: "circle.fill")
                                .foregroundColor(Color(account.color))
                        })
                    }
                }
                .padding()
            }
        }
    }
    
    func getDate(dayOfWeek: Int) -> Date {
        let currentDay = calendar.component(.weekday, from: date)
        let dateOfWeek = calendar.date(byAdding: .day, value: dayOfWeek - currentDay, to: date)
        return dateOfWeek ?? date
    }
    
    func getEvents(dayOfWeek: Int) -> [Int:[Event]] {
        let dateOfWeek = getDate(dayOfWeek: dayOfWeek)
        var events: [Int:[Event]] = [:]
        if let day = calendar.ordinality(of: .day, in: .year, for: dateOfWeek) {
            user?.events[day]?.forEach { event in
                let i = calendar.component(.hour, from: event.startTime)
                if events[i] == nil {
                    events[i] = [event]
                } else {
                    events[i]?.append(event)
                }
            }
        }
        return events
        
    }
    
}

struct WeekView_Previews: PreviewProvider {
    static var previews: some View {
        WeekView(user: .constant(User.sampleData), date: .now)
            .environmentObject(AppViewModel.sampleData)
    }
}
