//
//  DayView.swift
//  Social Timetable
//
//  Created by Hugh Drummond on 10/1/2023.
//

import SwiftUI

struct DayView: View {
    var calendar = Calendar.brisbane
    var rows: [Int:[UserEvent?]]
    @State var presenting = false
    @State var selected: UserEvent? = nil
        
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var viewModel: AppViewModel
    
    @State private var location: CGPoint = CGPoint(x: 0, y: 0)
    @GestureState private var startLocation: CGPoint? = nil
    
    private var verticalDrag: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                var newLocation = startLocation ?? location
                newLocation.x += value.translation.width
                newLocation.y += value.translation.height
                self.location = newLocation
            }
            .updating($startLocation) { (value, startLocation, transaction) in
                startLocation = startLocation ?? location
            }
            .onEnded { value in
                withAnimation(.easeOut(duration: 0.3)) {
                    location.y += value.predictedEndTranslation.height - value.translation.height
                    location.y = max(min(location.y, 0), -15 * 100 + UIScreen.main.bounds.height)
                }
            }
    }
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                ZStack(alignment: .top) {
                    Rectangle()
                        .foregroundColor(Color(uiColor: .systemGray6))
                    ForEach(0..<13) { num in
                        Rectangle()
                            .frame(width: geo.size.width - 20, height: 1)
                            .foregroundColor(colorScheme == .light ? .black : .white)
                            .opacity(0.2)
                            .offset(y: CGFloat(num * 100) + location.y)
                    }
                    HStack {
                        VStack(spacing: 0) {
                            ForEach(getTimes(), id:\.self) { hour in
                                Text(hour.formatted(date: .omitted, time: .shortened).description)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .frame(height: 100)
                            }
                        }
                        .frame(width: 75)
                        .padding(.leading, 15)
                        .offset(y: location.y)
                        ScrollView(.horizontal) {
                            ZStack(alignment: .topLeading) {
                                Rectangle()
                                    .frame(width: getWidth())
                                    .foregroundColor(.clear)
                                ForEach(getHalfHourTimes(), id:\.self) { halfHour in
                                    let row = rows[getKey(halfHour)] ?? []
                                    ForEach(Array(row.enumerated()), id: \.0) { i, e in
                                        if let userEvent: UserEvent = e  {
//                                            Button(action: {
//                                                selected = userEvent
//                                                presenting.toggle()
//                                            }, label: {
                                                EventCardView(name: userEvent.user.displayName, event: userEvent.event)
                                                    .foregroundColor(Color(userEvent.user.color).isDarkColor ? .white : .black)
                                                    .background(Color(userEvent.user.color))
                                                    .padding(.vertical, 5)
                                                    .containerShape(RoundedRectangle(cornerRadius: 10))

//                                            })
//                                            .buttonStyle(.plain)
                                            .offset(y: location.y + CGFloat((getKey(halfHour)) - 481) * 5 / 3)
                                            .offset(x: CGFloat(i * 135))
                                            .onTapGesture(perform: {    })
                                        } else {
                                            EmptyView()
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.trailing, 5)
                        .sheet(isPresented: $presenting) {
                            EventDetailView(userEvent: $selected)
                                .presentationDetents([.medium])
                        }
                    }
                }
            }
            .gesture(verticalDrag)
        }
    }
    
    func getTimes() -> [Date] {
        var times: [Date] = []
        for i in 8..<20 {
            if let time = calendar.date(bySettingHour: i, minute: 0, second: 0, of: .now) {
                times.append(time)
            }
        }
        return times
    }
    
    func getHalfHourTimes() -> [Date] {
        var times: [Date] = []
        for i in 8..<20 {
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
        return calendar.ordinality(of: .minute, in: .day, for: halfHour)!
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

struct DayView_Previews: PreviewProvider {
    static var previews: some View {
        DayView(rows: [481: [UserEvent(user: .sampleData, event: .sampleData[0])], 601: [UserEvent(user: .sampleData, event: .sampleData[0])]])
            .environmentObject(AppViewModel.sampleData)

    }
}
