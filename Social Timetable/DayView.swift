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
    @State var horizontalOffset: CGFloat = .zero
        
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var viewModel: AppViewModel

    
    var body: some View {
        GeometryReader { geo in
            VStack(alignment: .leading, spacing: 0) {
                ScrollView(.vertical) {
                    ZStack(alignment: .topLeading) {
                        ForEach(0..<13) { num in
                            Divider()
//                            Rectangle()
                                .frame(width: UIScreen.main.bounds.width - 20, height: 1)
//                                .foregroundColor(colorScheme == .light ? .black : .white)
//                                .opacity(0.2)
                                .offset(y: CGFloat(num * 100))
                        }
                        GeometryReader { _ in
                            ZStack(alignment: .topLeading) {
                                Rectangle()
                                    .frame(width: getWidth())
                                    .foregroundColor(.clear)
                                ForEach(getHalfHourTimes(), id:\.self) { halfHour in
                                    let row = rows[getKey(halfHour)] ?? []
                                    ForEach(Array(row.enumerated()), id: \.0) { i, e in
                                        if let userEvent: UserEvent = e  {
                                            EventCardView(name: userEvent.user.displayName, event: userEvent.event)
                                                .foregroundColor(Color(userEvent.user.color).isDarkColor ? .white : .black)
                                                .background(Color(userEvent.user.color))
                                                .padding(.vertical, 5)
                                                .containerShape(RoundedRectangle(cornerRadius: 10))
                                                .offset(y: CGFloat((getKey(halfHour)) - 481) * 5 / 3)
                                                .offset(x: CGFloat(i * 135) + horizontalOffset + 100)
                                                .onTapGesture {
                                                    selected = userEvent
                                                    presenting.toggle()
                                                }
                                        } else {
                                            EmptyView()
                                        }
                                    }
                                }
                            }
                        }
                        .sheet(isPresented: $presenting) {
                            EventDetailView(userEvent: $selected)
                                .presentationDetents([.medium])
                        }
                        VStack(spacing: 0) {
                            ForEach(getTimes(), id:\.self) { hour in
                                Text("   " + hour.formatted(date: .omitted, time: .shortened).description)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .frame(height: 100)
                                    .overlay(Divider().offset(y: 0.5).padding(.leading, 15), alignment: .top)
                            }
                        }
                        .frame(width: 90)
                        .background(
                            Rectangle()
                                .fill(colorScheme == .light ? .white : .black)
                        )
                    }
                }
                if getWidth() > geo.size.width - 100 {
                    ScrollBarView(scrollOffset: $horizontalOffset, contentWidth: getWidth(), screenWidth: geo.size.width, length: getWidth() - geo.size.width + 100)
                } else {
                    EmptyView()
                }
            }
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

struct ScrollBarView: View {
    @Binding var scrollOffset: CGFloat
    @State var location: CGPoint = CGPoint(x: 0, y: 0) {
        didSet {
            let geoWidth = screenWidth - width - 20
            if self.location.x < 0 {
                self.location.x = 0
            } else if self.location.x > geoWidth {
                self.location.x = geoWidth
            }
            scrollOffset = -location.x / geoWidth * length
        }
    }
    @GestureState private var startLocation: CGPoint? = nil
    
    var contentWidth: CGFloat
    var screenWidth: CGFloat
    var length: CGFloat
    @State var width: CGFloat = 30
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 15)
                    .foregroundColor(Color(uiColor: .systemGray5))
                    .frame(maxWidth: .infinity)
                    .onTapGesture { location in
                        withAnimation {
                            self.location.x = location.x - width / 2
                        }
                    }
                    RoundedRectangle(cornerRadius: 5)
                        .frame(width: width, height: 10)
                        .foregroundColor(Color(uiColor: .systemGray))
                        .offset(x: CGFloat(location.x))
                        .simultaneousGesture(
                            DragGesture()
                                .onChanged { value in
                                    var newLocation = startLocation ?? location
                                    newLocation.x += value.translation.width
                                    self.location = newLocation
                                }.updating($startLocation) { (value, startLocation, transaction) in
                                    startLocation = startLocation ?? location
                                }
                        )
            }
            .onAppear {
                width = geo.size.width * geo.size.width / contentWidth
                location.x = 0
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 15)
        .padding(.horizontal, 10)
    }
}

extension UIColor {
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
        DayView(rows:
                [
                    481: [UserEvent(user: .sampleData, event: .sampleData[0])],
                    601: [nil, UserEvent(user: .sampleData, event: .sampleData[1])],
                    
                ]
        )
            .environmentObject(AppViewModel.sampleData)

    }
}
