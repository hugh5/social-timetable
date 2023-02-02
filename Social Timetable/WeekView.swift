//
//  WeekView.swift
//  Social Timetable
//
//  Created by Hugh Drummond on 6/1/2023.
//

import SwiftUI

struct WeekView: View {

    let calendar = Calendar.current
    let daysOfWeek = ["Mon", "Tue", "Wed", "Thu", "Fri"]

    @Binding var user: User?
    @State var date: Date
    @State var selection: Int
    @State var hiddenUsers: [User] = []

    @EnvironmentObject var viewModel: AppViewModel
    
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
                                    date = calendar.date(byAdding: .day, value: ind - selection, to: date)!
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
            .navigationViewStyle(StackNavigationViewStyle())
            ScrollView(.horizontal) {
                HStack {
                    ForEach(viewModel.users) { account in
                        Button(action: {
                            withAnimation {
                                if let ind = hiddenUsers.firstIndex(of: account) {
                                    hiddenUsers.remove(at: ind)
                                } else {
                                    hiddenUsers.append(account)
                                }
                            }
                        }, label: {
                            Label(title: {
                                Text(account.displayName)
                                    .foregroundColor(.primary)
                            }, icon: {
                                Image(systemName: "circle.fill")
                                    .foregroundColor(Color(account.color))
                            })
                            .opacity(hiddenUsers.contains(account) ? 0.45: 1.0)
                        })
                        .buttonStyle(.bordered)
                    }
                }
                .padding()
            }
        }
        .onAppear {
            viewModel.getUserData()
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
                if hiddenUsers.contains(account) {
                    continue
                }
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
