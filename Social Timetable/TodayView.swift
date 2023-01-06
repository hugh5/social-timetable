//
//  TodayView.swift
//  Social Timetable
//
//  Created by Hugh Drummond on 6/1/2023.
//

import SwiftUI

struct TodayView: View {
    let days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
    
    var body: some View {
        NavigationView {
            TabView {
                ForEach(0..<days.count, id: \.self) { i in
                    Text("\(days[i])")
                        .tabItem {
                            Image(systemName: "person")
                        }
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
        }
    }
}

struct TodayView_Previews: PreviewProvider {
    static var previews: some View {
        TodayView()
    }
}
