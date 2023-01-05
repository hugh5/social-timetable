//
//  MonthView.swift
//  UQ Social Timetable
//
//  Created by Hugh Drummond on 29/12/2022.
//

import SwiftUI

struct MonthView: View {
    let weekdaySymbols: [String] = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
    @State var date: Date
    @State var presenting = false

    @EnvironmentObject var viewModel: AppViewModel

    var body: some View {
        NavigationStack {
            VStack() {
                HStack {
                    ForEach(0..<weekdaySymbols.count, id: \.self) { day in
                        Text(weekdaySymbols[day])
                            .font(.system(size: 20))
                            .frame(width: 45, height: 60)
                            .foregroundColor(.red)
                    }
                }
                DayGridView(date: $date)
            }
            .toolbar {
                ToolbarItemGroup(placement: .principal) {
                    HStack {
                        Button(action: {
                            presenting = true
                        }) {
                            MonthYearText(date: $date)
                        }
                    }
                }
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button(action: {
                        self.previousMonth()
                    }) {
                        Image(systemName: "chevron.left")
                    }
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: {
                        self.nextMonth()
                    }) {
                        Image(systemName: "chevron.right")
                    }
                }
                ToolbarItemGroup(placement: .bottomBar) {
                    Button(action: {
                        viewModel.signOut()
                    }) {
                        Text("Sign Out")
                    }
                }

            }
        }
        .gesture(DragGesture(minimumDistance: 10, coordinateSpace: .global)
            .onEnded({ value in
                if value.translation.width < 0 {
                    self.nextMonth()
                }
                
                if value.translation.width > 0 {
                    self.previousMonth()
                }
                if value.translation.height < 0 {
                    // up
                }
                
                if value.translation.height > 0 {
                    // down
                }
            })
        )
        .fullScreenCover(isPresented: $presenting) {
            YearView(date: $date)
        }
    }
    
    func previousMonth() {
        withAnimation(.easeInOut(duration: 0.5)) {
            // Decrement the month and year and update the current date
            let calendar = Calendar.current
            date = calendar.date(byAdding: .month, value: -1, to: date)!
        }
    }
    
    func nextMonth() {
        withAnimation(.easeInOut(duration: 0.5)) {
            // Increment the month and year and update the current date
            let calendar = Calendar.current
            date = calendar.date(byAdding: .month, value: 1, to: date)!
        }
    }
}

struct MonthYearText: View {
    @Binding var date: Date
    
    var body: some View {
        let monthYearFormatter = DateFormatter()
        monthYearFormatter.dateFormat = "MMM YYYY"
        return Text(monthYearFormatter.string(from: date))
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        MonthView(date: .now)
    }
}
