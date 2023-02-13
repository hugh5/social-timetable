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
    var entry: Provider.Entry
    
    var body: some View {
        if let user = entry.user {
            if user.courses.keys.count != 0 {
                ZStack {
                    Color(user.color)
                        .ignoresSafeArea()
                    EventCardView(event: getEvent(user), currentDate: entry.date)
                        .foregroundColor(Color(user.color).isDarkColor ? .white : .black)
                        .padding()
                }
            } else {
                Text("Upload Timetable")
            }
        } else {
            Text("Please login")
        }
    }
    
    func getEvent(_ user: User) -> Event {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: entry.date) ?? 0
        var day = dayOfYear
        while user.events[day]?.isEmpty ?? true {
            day += 1
            if day > 365 {
                return (user.events.first?.value.first)!
            }
        }
        var events = user.events[day]!
        events = events.filter({$0.startTime > entry.date})
        events.sort(by: {$0.startTime < $1.startTime})
        return events.first!
    }
}

struct EventCardView: View {
    var event: Event
    var currentDate: Date

    var body: some View {
        VStack(alignment: .leading) {
            Text(getDay())
                .bold()
            Text(getTime())
                .bold()
            Text(event.courseCode)
                .bold()
                .font(.title3)
                .lineLimit(1)
            HStack {
                Text(event.classType)
                    .bold()
                Text("-")
                Text(event.activity)
            }
            Text(event.getDuration())
                .bold()
                .lineLimit(1, reservesSpace: true)
            Text(event.location.components(separatedBy: " ")[0])
                .lineLimit(1, reservesSpace: true)
        }
        .lineLimit(1)
    }
    
    func getDay() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_AU")
        formatter.doesRelativeDateFormatting = true
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter.string(from: event.startTime)
    }
    
    func getTime() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: event.startTime)
    }
    
    func timeUntil() -> String {
//        let formatter = RelativeDateTimeFormatter()
//        formatter.unitsStyle = .full
//        formatter.dateTimeStyle = .named
//        formatter.formattingContext = .beginningOfSentence
//        return formatter.string(for: event.startTime) ?? ""
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_AU")
        formatter.doesRelativeDateFormatting = true
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        let day = formatter.string(from: event.startTime)
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return day + "\n" + formatter.string(from: event.startTime)
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
        .supportedFamilies([.systemSmall])
        .configurationDisplayName("Timetable Widget")
        .description("Know when your next class is")
    }
}

struct TimetableWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TimetableWidgetEntryView(entry: SimpleEntry(date: Date(), user: User.sampleData))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
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
