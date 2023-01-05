//
//  Event.swift
//  UQ Social Timetable
//
//  Created by Hugh Drummond on 29/12/2022.
//

import Foundation

struct Event: Identifiable {
    let id: UUID
    let title: String
    let startTime: Date
    let endTime: Date
    let description: String
    
    init(id: UUID = UUID(), title: String, startTime: Date, endTime: Date, description: String) {
        self.id = id
        self.title = title
        self.startTime = startTime
        self.endTime = endTime
        self.description = description
    }
}

extension Event {
    static let sampleData: [Event] =
    [
        Event(title: "Event 1", startTime: Date.now, endTime: Date.now.advanced(by: 100), description: "First Event"),
        Event(title: "Event 2", startTime: Date.now, endTime: Date.now.advanced(by: 200), description: "Second Event"),
    ]
}

func parseICSEvents(fromFile fileName: String) -> [Event] {
    // Load the .ics file
    let fileUrl = Bundle.main.url(forResource: fileName, withExtension: nil)!
    let fileContent = try! String(contentsOf: fileUrl)

    // Split the file into lines
    let lines = fileContent.components(separatedBy: .newlines)

    // Initialize variables to store the current event data
    var eventTitle: String?
    var eventLocation: String?
    var eventStartTime: Date?
    var eventEndTime: Date?
    var eventDescription: String?

    // Initialize an array to store the parsed events
    var events: [Event] = []

    // Iterate through the lines of the file
    for line in lines {
        // Check the line type
        if line.hasPrefix("SUMMARY:") {
            // This is the event title
            eventTitle = line.replacingOccurrences(of: "SUMMARY:", with: "")
            print("Title: \(eventTitle!)")
        } else if line.hasPrefix("LOCATION:") {
            // This is the event title
            eventLocation = line.replacingOccurrences(of: "LOCATION:", with: "")
            print("Location: \(eventLocation!)")
        } else if line.hasPrefix("DTSTART;") {
            // This is the event start time
            let startTimeString = line.replacingOccurrences(of: "DTSTART;", with: "")
            eventStartTime = date(from: startTimeString)
            print("Start Time: \(eventStartTime!)")
        } else if line.hasPrefix("DTEND;") {
            // This is the event end time
            let endTimeString = line.replacingOccurrences(of: "DTEND;", with: "")
            eventEndTime = date(from: endTimeString)
            print("End Time: \(eventEndTime!)")
        } else if line.hasPrefix("DESCRIPTION:") {
            // This is the event description
            eventDescription = line.replacingOccurrences(of: "DESCRIPTION:", with: "")
            print("Description: \(eventDescription!)")
        } else if line == "END:VEVENT" {
            // This marks the end of the current event
            // Check if all the required event data is present
            guard let title = eventTitle, let startTime = eventStartTime, let endTime = eventEndTime else {
            continue
            }
            // Create a new event object with the parsed data
            let event = Event(title: title, startTime: startTime, endTime: endTime, description: eventDescription ?? "")
            // Add the event to the array
            events.append(event)
            // Reset the event data variables
            eventTitle = nil
            eventStartTime = nil
            eventEndTime = nil
            eventDescription = nil
        }
    }
    return events
}

// Helper function to parse a date string in the .ics format
func date(from dateString: String) -> Date? {
    // Split the date string into parts
    let parts = dateString.components(separatedBy: ":")
    if parts.count < 2 {
        return nil
    }
    // The second part is the actual date string
    let dateString = parts[1]
    
    let timeZoneParts = parts[0].components(separatedBy: "=")
    if timeZoneParts.count < 2 {
        return nil
    }
    let timeZone = timeZoneParts[1]

    // Initialize a date formatter to parse the date string
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = TimeZone(identifier: timeZone)
    dateFormatter.dateFormat = "yyyyMMdd'T'HHmmss"

    // Parse the date
    return dateFormatter.date(from: dateString)
}
