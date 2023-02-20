//
//  TimetableView.swift
//  Social Timetable
//
//  Created by Hugh Drummond on 20/2/2023.
//

import SwiftUI

struct TimetableView: View {
    let daysOfWeek: [String] = Calendar.current.shortWeekdaySymbols
    let calendar = Calendar.current
    
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
                        Image(systemName: "chevron.left")
                    })
                    Spacer()

                    Text((calendar.date(byAdding: .day, value: page, to: .now) ?? .now) .formatted(date: .abbreviated, time: .omitted))
                    Spacer()
                    Button(action: {
                        page += 7
                    }, label: {
                        Image(systemName: "chevron.right")
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
                    DayView(events: getEvents(day: curr + (Calendar.current.ordinality(of: .day, in: .year, for: .now) ?? 0)))
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
    
    func getEvents(day: Int) -> [Int:[UserEvent]] {
        var events: [Int:[UserEvent]] = [:]
        for account in viewModel.users {
            if hiddenUsers.contains(account) {
                continue
            }
            account.events[day]?.forEach { event in
                let i = Calendar.current.component(.hour, from: event.startTime)
                if events[i] == nil {
                    events[i] = [UserEvent(user: account, event: event)]
                } else {
                    events[i]?.append(UserEvent(user: account, event: event))
                }
            }
        }
        return events
    }
}

struct TimetableView_Previews: PreviewProvider {
    static var previews: some View {
        TimetableView()
            .environmentObject(AppViewModel.sampleData)
    }
}
