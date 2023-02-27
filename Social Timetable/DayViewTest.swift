//
//  DayViewTest.swift
//  Social Timetable
//
//  Created by Hugh Drummond on 26/2/2023.
//

import SwiftUI

struct DayViewTest: View {
    var calendar = Calendar.current
    var rows: [Int:[UserEvent?]]
    @State var presenting = false
    @State var selected: UserEvent? = nil
        
    @EnvironmentObject var viewModel: AppViewModel

    
    var body: some View {
        ScrollView(.vertical) {
            HStack {
                VStack(spacing: 0) {
                    ForEach(getTimes(), id:\.self) { hour in
                        Text(hour.formatted(date: .omitted, time: .shortened).description)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .frame(height: 100)
                            .padding(.leading, 5)
                    }
                }
                .frame(width: 80)
                ScrollView(.horizontal) {
                    ZStack(alignment: .topLeading) {
                        Rectangle()
                            .frame(width: getWidth())
                            .foregroundColor(.clear)
                        ForEach(getHalfHourTimes(), id:\.self) { halfHour in
                            let row = rows[getKey(halfHour)] ?? []
                            ForEach(Array(row.enumerated()), id: \.0) { i, e in
                                if let userEvent: UserEvent = e  {
                                    EventCardTest(event: userEvent.event, name: userEvent.user.displayName, action: {
                                        selected = userEvent
                                        presenting.toggle()
                                    })
                                        .foregroundColor(Color(userEvent.user.color).isDarkColor ? .white : .black)
                                        .background(Color(userEvent.user.color))
                                        .padding(.vertical, 5)
                                        .containerShape(RoundedRectangle(cornerRadius: 10))
                                        .offset(y: CGFloat((getKey(halfHour) - 481) * 5 / 3))
                                        .offset(x: CGFloat(i * 135))
                                } else {
                                    EmptyView()
                                }
                            }
                        }
                    }
                }
                .padding(.trailing, 10)
                .sheet(isPresented: $presenting) {
                    EventDetailView(userEvent: $selected)
                        .presentationDetents([.medium])
                }
            }
        }
    }
    
    func getRange() -> Range<Int> {
        let currentSeconds = calendar.timeZone.secondsFromGMT()
        let brisbaneSeconds = TimeZone(identifier: "Australia/Brisbane")?.secondsFromGMT() ?? 10 * 3600

        let start = 8 - ((brisbaneSeconds - currentSeconds) / 3600)
        let end = start + 12
        return start..<end
    }
    
    func getTimes() -> [Date] {
        var times: [Date] = []
        for i in getRange() {
            if let time = calendar.date(bySettingHour: i, minute: 0, second: 0, of: .now) {
                times.append(time)
            }
        }
        return times
    }
    
    func getHalfHourTimes() -> [Date] {
        var times: [Date] = []
        for i in getRange() {
            if let time = calendar.date(bySettingHour: i, minute: 0, second: 0, of: .now) {
                times.append(time)
            }
            if let time = calendar.date(bySettingHour: i, minute: 30, second: 0, of: .now) {
                times.append(time)
            }
        }
        return times
    }
    
    func getKey(_ halfHour: Date) -> Int {
        return Calendar.current.ordinality(of: .minute, in: .day, for: halfHour) ?? 480
    }
    
    func getWidth() -> CGFloat {
        var maxIndex = 0
        for key in rows.keys {
            maxIndex = max(rows[key]?.count ?? 0, maxIndex)
        }
        return CGFloat(135 * maxIndex)
    }

}

extension UIColor
{
    var isDarkColor: Bool {
        var r, g, b, a: CGFloat
        (r, g, b, a) = (0, 0, 0, 0)
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        let lum = 0.2126 * r + 0.7152 * g + 0.0722 * b
        return  lum < 0.50
    }
}

extension Color {
    var isDarkColor : Bool {
        return UIColor(self).isDarkColor
    }
    
    init(_ hex: Int, alpha: Double = 1) {
        self.init(
          .sRGB,
          red: Double((hex >> 16) & 0xFF) / 255,
          green: Double((hex >> 8) & 0xFF) / 255,
          blue: Double(hex & 0xFF) / 255,
          opacity: alpha
        )
    }

    func hex() -> Int? {
        if let components = self.cgColor?.components {
            let rgb = components.map{Int(($0 * 255).rounded()) & 0xff}
            var hex = 0
            hex += rgb[0] << 16
            hex += rgb[1] << 8
            hex += rgb[2]
            return hex
        }
        return nil
    }
}

struct DayViewTest_Previews: PreviewProvider {
    static var previews: some View {
        DayViewTest(rows: [481: [UserEvent(user: .sampleData, event: .sampleData[0])], 541: [UserEvent(user: .sampleData, event: .sampleData[0])]])
            .environmentObject(AppViewModel.sampleData)

    }
}
