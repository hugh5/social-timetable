//
//  Course.swift
//  Social Timetable
//
//  Created by Hugh Drummond on 1/3/2023.
//

import Foundation

import Foundation

enum Campus: String, CaseIterable {
    case gttn = "GTTN", herst = "HERST", stluc = "STLUC"
    
    var description: String {
        switch self {
        case .gttn:
            return "Gatton"
        case .herst:
            return "Herston"
        case .stluc:
            return "St Lucia"
        }
    }
}

enum DeliveryMode: String, CaseIterable {
    case intern = "IN", extern = "EX", workex = "WE", intens = "IT"
    
    var description: String {
        switch self {
        case .intern:
            return "Internal"
        case .extern:
            return "External"
        case .workex:
            return "Work Exp"
        case .intens:
            return "Intensive"
        }
    }
}

struct Course: Identifiable {
    var id: String {
        return code + "_" + semester.rawValue + "_" + campus.rawValue + "_" + delivery.rawValue
    }
    var toString: String {
        return "\(code) - \(semester.description) - \(delivery.description)"
    }
    var code: String = ""
    var description: String = ""
    var semester: Semester = .S1
    var campus: Campus = .stluc
    var delivery: DeliveryMode = .intern
    var activities: [Activity] = []
    var groups: [String:[String]] = [:]
}

struct Activity: Identifiable {
    var group: String // Lec1
    var code: String // 01
    var weekday: String
    var startTime: String
    var location: String
    var duration: Int
    var startDates: [Date]
    
    var id: String {
        return group + code
    }
    
    func getEvents(course: Course) -> [Event] {
        var events: [Event] = []
        for date in startDates {
            events.append(Event(course: course.description, courseCode: course.code, semester: course.semester.rawValue, classType: group, activity: code, location: location, startTime: date, endTime: date.addingTimeInterval(TimeInterval(duration * 60))))
        }
        return events
    }
}

extension Course {
    public static func queryCourse(searchTerm: String, semester: Semester, campus: Campus, deliveryMode: DeliveryMode, completion: @escaping (Result<[Course], Error>) -> Void) {
        let headers = [
            "Accept": "application/json",
            "Accept-Language": "en-US,en;q=0.5",
            "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8",
            "X-Requested-With": "XMLHttpRequest",
            "Origin": "https://timetable.my.uq.edu.au",
            "DNT": "1",
            "Referer": "https://timetable.my.uq.edu.au/odd/timetable/",
            "Sec-Fetch-Dest": "empty",
            "Sec-Fetch-Mode": "cors",
            "Sec-Fetch-Site": "same-origin",
        ]
        
        var courses: [Course] = []
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 10 * 3600)!
        dateFormatter.dateFormat = "dd/MM/yyyy'T'HH:mm:ss"
        
        let postData = NSMutableData(data: "search-term=\(searchTerm)".data(using: String.Encoding.utf8)!)
        postData.append("&semester=\(semester.rawValue)".data(using: String.Encoding.utf8)!)
        postData.append("&campus=\(campus.rawValue)".data(using: String.Encoding.utf8)!)
        let request = NSMutableURLRequest(url: NSURL(string: "https://timetable.my.uq.edu.au/odd/rest/timetable/subjects")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = postData as Data
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if let error = error {
                print(error)
                completion(.failure(error))
                return
            } else {
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode != 200 {
                        completion(.failure(NSError(domain:"", code: httpResponse.statusCode, userInfo: nil)))
                        return
                    }
                }
                if let data = data {
                    if let responseJSON = try? JSONSerialization.jsonObject(with: data, options: []) {
                        if let responseJSON = responseJSON as? [String : Any] {
                            let dict = responseJSON as [String : Any]
                            for key in dict.keys.sorted() {
                                var course = Course()
                                if let courseDict = dict[key] as? [String : Any] {
                                    if let activitiesDict = courseDict["activities"] as? [String : Any] {
                                        for activityKey in activitiesDict.keys.sorted() {
                                            if let activityData = activitiesDict[activityKey] as? [String: Any] {
                                                guard let subject_code = activityData["subject_code"] as? String, var activity_group_code = activityData["activity_group_code"] as? String, var activity_code = activityData["activity_code"] as? String, let day_of_week = activityData["day_of_week"] as? String, let start_time = activityData["start_time"] as? String, let location = activityData["location"] as? String, let duration = activityData["duration"] as? String, let description = activityData["description"] as? String, let activitiesDays = activityData["activitiesDays"] as? [String] else {
                                                    continue
                                                }
                                                let courseComponents = subject_code.components(separatedBy: "_")
                                                guard courseComponents.count >= 4 else {
                                                    continue
                                                }
                                                guard let duration = Int(duration) else {
                                                    continue
                                                }
                                                guard let semester = Semester(rawValue: courseComponents[1]), let campus = Campus(rawValue: courseComponents[2]), let delivery = DeliveryMode(rawValue: courseComponents[3]) else {
                                                    continue
                                                }
                                                if course.description.isEmpty {
                                                    course.code = courseComponents[0]
                                                    course.description = description
                                                    course.semester = semester
                                                    course.campus = campus
                                                    course.delivery = delivery
                                                }
                                                
                                                let codeComponents = activity_code.components(separatedBy: "-")
                                                if codeComponents.count > 1 {
                                                    activity_group_code.append(contentsOf: "-" + codeComponents[1])
                                                    activity_code = codeComponents[0]
                                                }
                                                
                                                if course.groups[activity_group_code] == nil {
                                                    course.groups[activity_group_code] = [activity_code]
                                                } else {
                                                    course.groups[activity_group_code]!.append(activity_code)
                                                }
                                                
                                                let activitiesDates = activitiesDays.map({
                                                    dateFormatter.date(from: "\($0)T\(start_time):00") ?? .init(timeIntervalSince1970: 0)
                                                })
                                                
                                                let activity = Activity(group: activity_group_code, code: activity_code, weekday: day_of_week, startTime: start_time, location: location, duration: duration, startDates: activitiesDates)
                                                course.activities.append(activity)
                                            }
                                        }
                                    }
                                }
                                courses.append(course)
                            }
                            completion(.success(courses.filter({$0.delivery == deliveryMode})))
                        }
                    }
                }
            }
        })
        
        dataTask.resume()
    }
}

extension Course {
    func getEvents(activities: [(String, String)]) -> [Event] {
        var events: [Event] = []
        activities.forEach { (group, code) in
            if let activity = self.activities.first(where: {$0.group == group && $0.code == code}) {
                events.append(contentsOf: activity.getEvents(course: self))
            }
        }
        return events
    }
}

extension Course {
    static let sampleData: Course = Course(code: "CSSE1001", description: "Course Description", semester: .S1, activities: [Activity(group: "LEC1", code: "01", weekday: "Mon", startTime: "12:00", location: "01-201", duration: 120, startDates: [.now])], groups: ["LEC1":["01"]])
}
