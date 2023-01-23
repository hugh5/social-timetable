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
        
    let daysOfWeek = ["Mon", "Tue", "Wed", "Thur", "Fri"]
    
    @State var selection: Int
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    withAnimation {
                        date = calendar.date(byAdding: .day, value: -7, to: date) ?? date
                    }
                }, label: {
                    Image(systemName: "chevron.left")
                })
                .padding()
                Spacer()
                Text("\(getDate(dayOfWeek:selection + 2).formatted(date: .abbreviated, time: .omitted))")
                Spacer()
                Button(action: {
                    withAnimation {
                        date = calendar.date(byAdding: .day, value: 7, to: date) ?? date
                    }
                }, label: {
                    Image(systemName: "chevron.right")
                })
                .padding()
            }
            NavigationView {
                VStack(alignment: .leading) {
                    HStack {
                        ForEach(Array(daysOfWeek.enumerated()), id:\.0) { (ind, dayOfWeek) in
                            Button(action: {
                                withAnimation {
                                    selection = ind
                                }
                            }, label: {
                                VStack {
                                    Text(dayOfWeek)
                                        .bold(selection == ind)
                                        .foregroundColor(selection == ind ? .accentColor : .primary)
                                    RoundedRectangle(cornerRadius: 3)
                                        .frame(height: 3)
                                        .foregroundColor(selection == ind ? .accentColor : .clear)
                                }
                            })
                        }
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity)
                    }
                    TabView(selection: $selection) {
                        ForEach(0..<5) { day in
                            DayView(events: getEvents(dayOfWeek: day + 2))
                                .tag(day)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .animation(.default, value: selection)
                }
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
    
    func getEvents(dayOfWeek: Int) -> [Int:[UserEvent]] {
        let dateOfWeek = getDate(dayOfWeek: dayOfWeek)
        var events: [Int:[UserEvent]] = [:]
        if let day = calendar.ordinality(of: .day, in: .year, for: dateOfWeek) {
            for account in viewModel.users {
                account.events[day]?.forEach { event in
                    let i = calendar.component(.hour, from: event.startTime)
                    if events[i] == nil {
                        events[i] = [UserEvent(user: account, event: event)]
                    } else {
                        events[i]?.append(UserEvent(user: account, event: event))
                    }
                }
            }
        }
        return events
        
    }
    
}

struct WeekView_Previews: PreviewProvider {
    static var previews: some View {
        WeekView(user: .constant(User.sampleData), date: .now, selection: 0)
            .environmentObject(AppViewModel.sampleData)
    }
}
