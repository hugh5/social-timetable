//
//  YearView.swift
//  UQ Social Timetable
//
//  Created by Hugh Drummond on 31/12/2022.
//

import SwiftUI

struct YearView: View {
    let calendar = Calendar.current
    
    @State var presenting = false
    @State var date: Date
    
    var body: some View {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM yyyy"
        
        return NavigationStack {
            VStack {
                ForEach(0..<4, id: \.self) { row in
                    HStack() {
                        Spacer()
                        ForEach(0..<3, id: \.self) { col in
                            Button(action: {
                                date = getDate(month: row * 3 + col + 1)
                                presenting = true
                            } ) {
                                VStack {
                                    Text(dateFormatter.string(from: getDate(month: row * 3 + col + 1)))
                                        .foregroundColor(.red)
                                    DayGridView(date: .constant(getDate(month: row * 3 + col + 1)), fullscreen: false)
                                }
                            }
                            .fullScreenCover(isPresented: $presenting) {
                                MonthView(date: $date)
                            }
                            Spacer()
                        }
                    }
                    Spacer()
                }
            }
        }
    }
    
    func getDate(month: Int) -> Date {
        var components = calendar.dateComponents([.day, .month, .year], from: .now)
        components.day = 1
        components.month = month
        return calendar.date(from: components) ?? Date.now
    }
    
    func getDate(month: Int, year: Int) -> Date {
        var components = calendar.dateComponents([.day, .month, .year], from: .now)
        components.day = 1
        components.month = month
        components.year = year
        return calendar.date(from: components) ?? Date.now
    }
}

struct YearView_Previews: PreviewProvider {
    static var previews: some View {
        YearView(date: .now)
    }
}
