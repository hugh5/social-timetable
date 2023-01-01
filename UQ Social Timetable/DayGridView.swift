//
//  DayGridView.swift
//  UQ Social Timetable
//
//  Created by Hugh Drummond on 1/1/2023.
//

import SwiftUI

struct DayGridView: View {
    @Binding var date: Date
    
    var fullscreen = true
    
    var body: some View {
        VStack {
            ForEach(0..<getRows(), id: \.self) { row in
                HStack {
                    ForEach(0..<7, id: \.self) { col in
                        if (fullscreen) {
                            Button (action: {}) {
                                DayText(day: getDay(row: row, col:col))
                            }
                        } else {
                            DayText(day: getDay(row: row, col:col))
                        }
                    }
                }
                Divider()
            }
            if (fullscreen) {
                Spacer()
            }
        }
    }
    
    func getRows() -> Int {
        let calendar = Calendar.current
        var firstday = calendar.component(.weekday, from: date.startOfMonth())
        firstday = (firstday + 5) % 7
        
        let range = calendar.range(of: .day, in: .month, for: date)
        let numDays = range?.count ?? 0
        
        return Int(ceil(Double(firstday + numDays) / 7))
    }
    
    func getDay(row: Int, col: Int) -> Int {
        let calendar = Calendar.current
        var firstday = calendar.component(.weekday, from: date.startOfMonth())
        firstday = (firstday + 5) % 7
        return row * 7 + col - firstday + 1
    }
    
    func DayText(day: Int) -> some View {
        let calendar = Calendar.current
        
        let range = calendar.range(of: .day, in: .month, for: date)
        let numDays = range?.count
        
        var dateOfMonth: Date?
        var dayOfMonth = 0
        var textColor: Color = .primary
        if day <= 0 {
            dateOfMonth = calendar.date(byAdding: .day, value: -1 + day, to: date.startOfMonth())
            dayOfMonth = calendar.component(.day, from: dateOfMonth!)
            textColor = .gray
        } else if day > numDays! {
            dateOfMonth = calendar.date(byAdding: .day, value: -1 + day - numDays!, to: date.endOfMonth())
            dayOfMonth = calendar.component(.day, from: dateOfMonth!)
            textColor = .gray
        } else {
            dateOfMonth = calendar.date(bySetting: .day, value: day, of: date)
            dayOfMonth = day
            textColor = .primary
        }
        let currentDay = calendar.isDateInToday(dateOfMonth!)
        if (currentDay) {
            textColor = .red
        }
        
        return Text(dayOfMonth.description)
            .font(.system(size: fullscreen ? 20 : 7))
            .foregroundColor(textColor)
            .bold(currentDay)
            .frame(width: fullscreen ? 45 : 11, height: fullscreen ? 60 : 7)
    }
}

extension Date {

    func startOfMonth() -> Date {
        let interval = Calendar.current.dateInterval(of: .month, for: self)
        return (interval?.start)!
    }
    
    func endOfMonth() -> Date {
        let interval = Calendar.current.dateInterval(of: .month, for: self)
        return (interval?.end)!
    }
    
    func sameDay(_ date: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.component(.year, from: self) == calendar.component(.year, from: date) && calendar.component(.month, from: self) == calendar.component(.month, from: date) && calendar.component(.day, from: self) == calendar.component(.day, from: date)
    }
}

struct DayGridView_Previews: PreviewProvider {
    static var previews: some View {
        DayGridView(date: .constant(Date.now))
    }
}
