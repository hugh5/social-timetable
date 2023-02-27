//
//  TestView.swift
//  Social Timetable
//
//  Created by Hugh Drummond on 26/2/2023.
//

import SwiftUI

struct TestView: View {
    let daysOfWeek: [String] = Calendar.current.shortWeekdaySymbols
    let calendar = Calendar.current
    
    @State var date: Date = .now
    @State var page: Int = 0
    @State var hiddenUsers: [User] = []

    @EnvironmentObject var viewModel: AppViewModel
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                HStack {
                    Button(action: {
                        page -= 7
                    }, label: {
                        Image(systemName: "chevron.left.2")
                    })
                    Button(action: {
                        page -= 1
                    }, label: {
                        Image(systemName: "chevron.left")
                    })
                    Spacer()

                    DatePicker("", selection: Binding(
                        get: { calendar.date(byAdding: .day, value: page, to: .now) ?? .now },
                        set: { newVal in
                            let new = calendar.startOfDay(for: newVal)
                            let old = calendar.startOfDay(for: calendar.date(byAdding: .day, value: page, to: .now) ?? .now)
                            
                            let numberOfDays = calendar.dateComponents([.day], from: old, to: new).day!
                            page += numberOfDays
                        }
                    ), displayedComponents: [.date])
                        .datePickerStyle(.compact)
                        .labelsHidden()

                    Spacer()
                    Button(action: {
                        page += 1
                    }, label: {
                        Image(systemName: "chevron.right")
                    })
                    Button(action: {
                            page += 7
                    }, label: {
                        Image(systemName: "chevron.right.2")
                    })
                }
                .padding(.top, 5)
                .padding(.horizontal)
                
                HStack {
                    ForEach(Array(daysOfWeek.enumerated()), id:\.0) { (ind, dayOfWeek) in
                        Button(action: {
                            let date = calendar.date(byAdding: .day, value: page, to: .now) ?? .now
                            let curr = calendar.component(.weekday, from: date)
                            page += ind + 1 - curr
                        }, label: {
                            VStack {
                                Text(dayOfWeek)
                                    .font(.subheadline)
                                    .foregroundColor(currIndex() == ind ? .accentColor : .primary)
                                RoundedRectangle(cornerRadius: 3)
                                    .frame(height: 3)
                                    .foregroundColor(currIndex() == ind ? .accentColor : .clear)
                            }
                        })
                    }
                }
                .padding(.top, 5)
                .padding(.horizontal)
                
                InfiniteTabPageView(currentPage: $page, width: geometry.size.width) { curr in
                    DayViewTest(rows: getRows(events: getEvents(day: curr + (Calendar.current.ordinality(of: .day, in: .year, for: .now) ?? 0))))
                }
                
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
        }
        .onAppear {
            viewModel.getUserData()
        }
    }
    
    func currIndex() -> Int {
        return calendar.component(.weekday, from: calendar.date(byAdding: .day, value: page, to: .now) ?? .now) - 1
    }
    
    func getEvents(day: Int) -> [UserEvent] {
        var events: [UserEvent] = []
        for account in viewModel.users {
            if hiddenUsers.contains(account) {
                continue
            }
            account.events[day]?.forEach { event in
                events.append(UserEvent(user: account, event: event))
            }
        }
        return events
    }
    
    func getRows(events: [UserEvent]) -> [Int:[UserEvent?]] {
        var rows = [Int:[UserEvent?]]()
        for userEvent in events {
            let event = userEvent.event
            let count = Int(event.startTime.distance(to: event.endTime) / (30*60))
            let key = Calendar.current.ordinality(of: .minute, in: .day, for: event.startTime) ?? 480
            var current = key
            var maxIndex = 0
            for _ in 0..<count {
                maxIndex = max(maxIndex,rows[current]?.count ?? 0)
                current += 30
            }
            current = key
            for _ in 0..<count {
                if rows[current] == nil {
                    rows[current] = []
                }
                while rows[current]!.count < maxIndex {
                    rows[current]!.append(nil)
                }
                if current == key {
                    rows[current]!.append(userEvent)
                } else {
                    rows[current]!.append(nil)
                }
                current += 30
            }
        }
        return rows
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
            .environmentObject(AppViewModel.sampleData)
    }
}
