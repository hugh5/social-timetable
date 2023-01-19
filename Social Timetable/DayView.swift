//
//  DayView.swift
//  Social Timetable
//
//  Created by Hugh Drummond on 10/1/2023.
//

import SwiftUI

struct DayView: View {
    
    let calendar = Calendar.current
    @Binding var user: User?
    var events: [Int:[Event]]
        
    var body: some View {
        List {
            ForEach(getTimes(), id: \.self) { time in
                HStack {
                    Text(time.formatted(date: .omitted, time: .shortened))
                        .frame(height: 80)
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(events[calendar.component(.hour, from: time)] ?? []) { event in
                                Button(action: {
                                    
                                }) {
                                    EventDetailView(name: user?.displayName ?? "", event: event)
                                        .padding(5)
                                        .frame(width: 140)
                                }
                                .buttonStyle(.plain)
                                .foregroundColor(Color(user?.color ?? 0).isDarkColor ? .white : .black)
                                .background(Color(user?.color ?? 0xffffff))
                                .containerShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }
                    }
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

struct DayView_Previews: PreviewProvider {
    static var previews: some View {
        DayView(user: .constant(User.sampleData), events: [8:Event.sampleData])
    }
}
