//
//  SocialTimetableApp.swift
//  Social Timetable
//
//  Created by Hugh Drummond on 29/12/2022.
//

import SwiftUI

@main
struct SocialTimetableApp: App {
    var body: some Scene {
        WindowGroup {
            YearView(date: .now)
        }
    }
}
