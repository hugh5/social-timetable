//
//  SocialTimetableApp.swift
//  Social Timetable
//
//  Created by Hugh Drummond on 29/12/2022.
//

import SwiftUI
import Firebase

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct SocialTimetableApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
      
    var body: some Scene {
        WindowGroup {
            let viewModel = AppViewModel()
            ContentView()
                .environmentObject(viewModel)
        }
    }
}
