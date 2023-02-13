//
//  TimetableWidget.swift
//  TimetableWidget
//
//  Created by Hugh Drummond on 9/2/2023.
//

import WidgetKit
import SwiftUI
import Firebase
import FirebaseAuth

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), user: User.sampleData)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), user: User.sampleData)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let date = Date()

        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: date)!

        getFirestoreUser { user in
            let entry = SimpleEntry(date: date, user: user)
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
            completion(timeline)
        }
    
    }
    
    func getFirestoreUser(completion: @escaping (User?) ->()) {

        guard let email = Auth.auth().currentUser?.email else {
            completion(nil)
            return
        }
        let db = Firestore.firestore().collection("users").document(email)

        db.getDocument(as: User.self) { result in
            switch result {
            case .success(let data):
                completion(data)
            case .failure(_):
                completion(nil)
            }
        }

    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    var user: User?
}

struct TimetableWidgetEntryView : View {
    @Environment(\.widgetFamily) var widgetFamily
    var entry: Provider.Entry
    
    var body: some View {
        if let user = entry.user {
            if user.courses.keys.count != 0 {
                switch widgetFamily {
                case .systemSmall:
                    ZStack(alignment: .leading  ) {
                        Color(user.color)
                            .ignoresSafeArea()
                        EventCardView(data: getEvent(user), currentDate: entry.date, widgetFamily: widgetFamily)
                            .foregroundColor(Color(user.color).isDarkColor ? .white : .black)
                            .padding()
                    }
                case .accessoryRectangular:
                    EventCardView(data: getEvent(user), currentDate: entry.date, widgetFamily: widgetFamily)
                default:
                    Text("Not Supported")
                }
            } else {
                Text("Upload Timetable")
            }
        } else {
            Text("Please login")
        }
    }
    
    func getEvent(_ user: User) -> (event: Event?, error: String?) {
        var day = Calendar.current.ordinality(of: .day, in: .year, for: entry.date) ?? 0
        
        // Event is today
        if let events = user.events[day] {
            if events.filter({$0.startTime > entry.date}).isEmpty {
                day += 1
            } else {
                return (events.filter({$0.startTime > entry.date}).sorted(by: {$0.startTime < $1.startTime}).first!, nil)
            }
        }
        
        // Loop through days of year
        while user.events[day]?.isEmpty ?? true {
            day += 1
            if day > 365 {
                return (nil, "No Classes Found")
            }
        }
        var events = user.events[day]!
        events.sort(by: {$0.startTime < $1.startTime})
        guard let event = events.first else {
            return (nil, day.description)
        }
        return (event, nil)
    }
}

struct EventCardView: View {
    var data: (event: Event?, error: String?)
    var currentDate: Date
    var widgetFamily: WidgetFamily

    var body: some View {
        if let event = data.event {
            switch widgetFamily {
            case .systemSmall:
                VStack(alignment: .leading) {
                    Text(getDay(event))
                        .bold()
                    Text(getTime(event))
                        .bold()
                    Text(event.courseCode)
                        .bold()
                        .font(.title3)
                    HStack {
                        Text(event.classType)
                            .bold()
                        Text("-")
                        Text(event.activity)
                    }
                    Text(event.getDuration())
                        .bold()
                    Text(event.location.components(separatedBy: " ")[0])
                    Text("Last Update: " + currentDate.formatted(date: .omitted, time: .shortened))
                        .font(.caption2)
                }
                .lineLimit(1)
            case .accessoryRectangular:
                VStack(alignment: .leading) {
                    HStack {
                        Text(getDay(event))
                        Text(getTime(event))
                    }
                    .bold()
                    Text(event.courseCode)
                    HStack {
                        Text(event.classType)
                        Text("-")
                        Text(event.location.components(separatedBy: " ")[0])
                    }
                }
            default:
                Text("Not Supported")
            }
        } else {
            Text(data.error ?? "Error")
        }
    }
    
    func getDay(_ event: Event) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_AU")
        formatter.doesRelativeDateFormatting = true
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter.string(from: event.startTime)
    }
    
    func getTime(_ event: Event) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: event.startTime)
    }
}

struct TimetableWidget: Widget {
    init() {
        FirebaseApp.configure()
        do {
            try Auth.auth().useUserAccessGroup("group.com.hughdrummond.Social-Timetable")
        } catch {
            print(error.localizedDescription)
        }
    }
    
    let kind: String = "TimetableWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            TimetableWidgetEntryView(entry: entry)
        }
        .supportedFamilies([.systemSmall, .accessoryRectangular])
        .configurationDisplayName("Timetable Widget")
        .description("Know when your next class is")
    }
}

struct TimetableWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TimetableWidgetEntryView(entry: SimpleEntry(date: Date(), user: User.sampleData))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            TimetableWidgetEntryView(entry: SimpleEntry(date: Date(), user: User.sampleData))
                .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
        }
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
}
