//
//  Event.swift
//  UQ Social Timetable
//
//  Created by Hugh Drummond on 29/12/2022.
//

import Foundation

struct Event: Identifiable, Codable, CustomStringConvertible {
    let id: UUID
    var course: String
    var courseCode: String
    var semester: String
    var classType: String
    var activity: String
    var location: String
    var startTime: Date
    var endTime: Date
    
    init(id: UUID = UUID(), course: String, courseCode: String, semester: String, classType: String, activity: String, location: String, startTime: Date, endTime: Date) {
        self.id = id
        self.course = course
        self.courseCode = courseCode
        self.semester = semester
        self.classType = classType
        self.activity = activity
        self.location = location
        self.startTime = startTime
        self.endTime = endTime
    }
    
    var description: String {
        return "\(courseCode) - \(classType)"
    }
    
    public func getDuration() -> String {
        let components = Calendar.current.dateComponents([.hour, .minute], from: startTime, to: endTime)
        return String(format: "%dh", components.hour ?? 0).appending(components.minute ?? 0 != 0 ? String(format: " %dm", components.minute ?? 0) : "")
    }
}

extension Event {
    static let sampleData: [Event] =
    [
        Event(course: "Algorithms & Data Structures", courseCode: "COMP3506", semester: "S2", classType: "LEC1", activity: "01", location: "49-200 - Advanced Engineering Building, Learning Theatre (GHD Auditorium)", startTime: convertStringToDate(string: "TZID=Australia/Brisbane:20230228T080000"), endTime: convertStringToDate(string: "TZID=Australia/Brisbane:20230228T100000")),
        Event(course: "Introduction to Electrical Systems", courseCode: "ENGG1300", semester: "S2", classType: "LEC1", activity: "01", location: "23-101 - Abel Smith Lecture Theatre, Learning Theatre", startTime: convertStringToDate(string: "TZID=Australia/Brisbane:20221017T110000"), endTime: convertStringToDate(string: "TZID=Australia/Brisbane:20221017T130000"))
    ]
}

func convertICSToEvents(from url: URL) async -> Result<([Int: [Event]], [String:Set<String>]), Error> {
    // Parse the .ics file
    
    let result: Result = await loadURLContents(url: url)
    var contents: String
    switch result {
    case .failure(let error):
        return .failure(error)
    case .success(let data):
        contents = data
    }
    
    let lines = contents.components(separatedBy: "\n")
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

    // Initialize variables for creating events
    var courses: [String:Set<String>] = [:]
    
    var events: [Int: [Event]] = [:]
    var event: Event
    var eventCourse: String?
    var eventCode: String?
    var eventSemester: String?
    var eventClass: String?
    var eventActivity: String?
    var eventLocation: String?
    var eventStartTime: Date?
    var eventEndTime: Date?

    // Loop through each line in the .ics file
    for line in lines {
        
        // Split the line into key-value pairs
        let components = line.contains(";") ? line.components(separatedBy: ";") : line.components(separatedBy: ":")
        if components.count < 2 {
            continue
        }
        if !line.contains(";") {
            let key = components[0]
            let value = components[1].replacing("\r", with: "")

            switch key {
            case "BEGIN":
                if value.contains("VEVENT") {
                    eventCourse = nil
                    eventCode = nil
                    eventSemester = nil
                    eventClass = nil
                    eventActivity = nil
                    eventLocation = nil
                    eventStartTime = nil
                    eventEndTime = nil
                }
            case "END":
                if value.contains("VEVENT") {
                    guard let course = eventCourse, let code = eventCode, let semester = eventSemester, let classType = eventClass, let activity = eventActivity, let location = eventLocation, let startTime = eventStartTime, let endTime = eventEndTime else {
                        continue
                    }
                    event = Event(course: course, courseCode: code, semester: semester, classType: classType, activity: activity, location: location, startTime: startTime, endTime: endTime)
                    if (courses[semester] == nil) {
                        courses[semester] = Set()
                    }
                    courses[semester]?.insert(code)
                    let dayOfYear = getDayOfYear(date: event.startTime)
                    if events[dayOfYear] == nil {
                        events[dayOfYear] = [event]
                    } else {
                        events[dayOfYear]?.append(event)
                    }
                }
            case "SUMMARY":
                // Set the title of the event
                let summaryComponents = value.components(separatedBy: "\\, ")
                if (summaryComponents.count == 2) {
                    eventCourse = summaryComponents[0]
                    eventClass = summaryComponents[1]
                }
            case "LOCATION":
                // Set the location of the event
                eventLocation = value.replacingOccurrences(of: "\\", with: "")
            case "DESCRIPTION":
                let descriptionComponents = value.components(separatedBy: "\\, ")
                if (descriptionComponents.count >= 3) {
                    let courseComponents = descriptionComponents[0].components(separatedBy: "_")
                    if (courseComponents.count >= 2) {
                        eventCode = courseComponents[0]
                        eventSemester = courseComponents[1]
                    }
                    eventActivity = descriptionComponents[2].prefix(while: {
                        $0.isNumber
                    }).description
                    
                }
            default:
                break
            }
        } else {
            let key = components[0]
            let value = components[1].replacing("\r", with: "")
                    
            switch key {
            case "DTSTART":
                eventStartTime = convertStringToDate(string: value)
            case "DTEND":
                eventEndTime = convertStringToDate(string: value)
            default:
                break
            }
        }

    }

    return .success((events, courses))
}

enum Semester: String, CaseIterable {    
    case S1 = "S1", S2 = "S2", S3 = "S3"
    
    var description: String {
        switch self {
        case .S1:
            return "Semester 1"
        case .S2:
            return "Semester 2"
        case .S3:
            return "Summer"
        }
    }
}

func convertUQPlannerToEvents(contents: String, semester: Semester) -> Result<([Int: [Event]], [String:Set<String>]), Error> {
    
    let semester = semester.rawValue
    let lines = contents.components(separatedBy: "\n")

    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = TimeZone(abbreviation: "AEST")
    dateFormatter.dateFormat = "yyyyMMdd'T'HHmmss"

    // Initialize variables for creating events
    var courses: [String:Set<String>] = [:]

    var events: [Int: [Event]] = [:]
    var event: Event
    var eventCode: String?
    var eventClass: String?
    var eventActivity: String?
    var eventLocation: String?
    var eventStartTime: Date?
    var eventEndTime: Date?

    // Loop through each line in the .ics file
    for line in lines {

        // Split the line into key-value pairs
        let components = line.contains(";") ? line.components(separatedBy: ";") : line.components(separatedBy: ":")
        if components.count < 2 {
            continue
        }
        let key = components[0]
        let value = components[1]
        
///        ["BEGIN", "VEVENT"]
///        ["DESCRIPTION", "LEC1"]
///        ["DTSTART", "VALUE=DATE-TIME:20230221T100000"]
///        ["DTEND", "VALUE=DATE-TIME:20230221T120000"]
///        ["LOCATION", "42-115"]
///        ["SUMMARY", "LANGUAGE=en-us:CSSE3012 LEC101"]
///        ["END", "VEVENT"]

        switch key {
        case "BEGIN":
            if value.contains("VEVENT") {
                eventCode = nil
                eventClass = nil
                eventActivity = nil
                eventLocation = nil
                eventStartTime = nil
                eventEndTime = nil
            }
        case "END":
            if value.contains("VEVENT") {
                guard let code = eventCode, let classType = eventClass, let activity = eventActivity, let location = eventLocation, let startTime = eventStartTime, let endTime = eventEndTime else {
                    continue
                }
                event = Event(course: "", courseCode: code, semester: semester, classType: classType, activity: activity, location: location, startTime: startTime, endTime: endTime)
                if (courses[semester] == nil) {
                    courses[semester] = Set()
                }
                courses[semester]?.insert(code)
                let dayOfYear = getDayOfYear(date: event.startTime)
                if events[dayOfYear] == nil {
                    events[dayOfYear] = [event]
                } else {
                    events[dayOfYear]?.append(event)
                }
            }
        case "DESCRIPTION":
            eventClass = value
        case "LOCATION":
            eventLocation = value
        case "SUMMARY":
            let summaryComponents = value.components(separatedBy: ":")
            if (summaryComponents.count == 2) {
                let courseComponents = summaryComponents[1].components(separatedBy: " ")
                if (courseComponents.count == 2) {
                    eventCode = courseComponents[0]
                    eventActivity = summaryComponents[1].suffix(2).description
                }
            }
        case "DTSTART":
            let timeStampComponents = value.components(separatedBy: ":")
            if timeStampComponents.count == 2 {
                if let date = dateFormatter.date(from: timeStampComponents[1]) {
                    eventStartTime = date
                }
            }
        case "DTEND":
            let timeStampComponents = value.components(separatedBy: ":")
            if timeStampComponents.count == 2 {
                if let date = dateFormatter.date(from: timeStampComponents[1]) {
                    eventEndTime = date
                }
            }
        default:
            break
        }
    }

    return .success((events, courses))
}

func convertStringToDate(string: String) -> Date {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyyMMdd'T'HHmmss"

    let components = string.components(separatedBy: ":")
    if components.count == 2 {
        let timeZoneString = components[0]
        let dateString = components[1]

        // Extract the time zone identifier from the time zone string
        let timeZoneComponents = timeZoneString.components(separatedBy: "=")
        if timeZoneComponents.count == 2 {
            let timeZoneIdentifier = timeZoneComponents[1]
            dateFormatter.timeZone = TimeZone(identifier: timeZoneIdentifier)
        }

        let date = dateFormatter.date(from: dateString)!
        return date
    } else {
        return Date()
    }
}

func getDayOfYear(date: Date) -> Int {
    let calendar = Calendar.current
    return calendar.ordinality(of: .day, in: .year, for: date)!
}

func loadURLContents(url: URL) async -> Result<String, Error> {
    do {
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            return .failure(NSError())
        }
        guard let contents = String(data: data, encoding: .utf8) else {
            return .failure(NSError())
        }
        return .success(contents)
    } catch {
        return .failure(error)
    }

}
