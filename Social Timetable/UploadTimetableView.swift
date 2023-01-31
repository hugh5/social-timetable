//
//  UploadTimetableView.swift
//  Social Timetable
//
//  Created by Hugh Drummond on 7/1/2023.
//

import SwiftUI
import FirebaseFirestore

struct UploadTimetableView: View {
    
    @State var timeTableLink: String = ""
    @EnvironmentObject var viewModel: AppViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    let db = Firestore.firestore()
    
    var body: some View {
        ScrollView {
            Text("How to Add Your UQ Timetable")
                .font(.largeTitle)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            Text("1. Navigate to the My Timetable Home page through [UQ Dashboard](https://portal.my.uq.edu.au/#/dashboard)")
                .font(.title3)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            Image("HomePageLink")
                .resizable()
                .scaledToFit()
                .padding()
            Text("2. Scroll to the bottom of the page and copy the URL seen below")
                .font(.title3)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            Image("TimetableICSLink")
                .resizable()
                .scaledToFit()
                .padding()
            Text("3. Paste the URL in the field below and save it")
                .font(.title3)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            HStack {
                TextField("https://timetable.my.uq.edu.au/...", text: $timeTableLink)
                    .padding()
                Button(action: {
                    saveUser()
                }) {
                    Text("Save")
                }
                .padding()
                .buttonStyle(.borderedProminent)
            }
            .background(.tertiary, in: RoundedRectangle(cornerRadius: 8))
            .padding()
        }
    }
    
    func saveUser() {
        if (!timeTableLink.isEmpty) {
            if let url = URL(string: timeTableLink) {
                Task {
                    let (events, courses) = await convertICSToEvents(from: url)
                    if events.isEmpty {
                        return
                    }
                    viewModel.user?.events = events
                    viewModel.user?.courses = courses
                    viewModel.setUserData()
                    viewModel.getUserData()
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
}

struct UploadTimetableView_Previews: PreviewProvider {
    static var previews: some View {
        UploadTimetableView()
            .environmentObject(AppViewModel())
    }
}
