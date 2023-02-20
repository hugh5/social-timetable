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
    @State var uploadError = " "
    @EnvironmentObject var viewModel: AppViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    let db = Firestore.firestore()
    
    var body: some View {
        ScrollView {
            Text("How to Add Your UQ Timetable")
                .font(.largeTitle)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            Text("1. Navigate to your My Timetable **Home** page through **[UQ Dashboard](https://portal.my.uq.edu.au/#/dashboard)**")
                .font(.title3)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .contextMenu {
                    Button(action: {
                        UIPasteboard.general.string = "https://portal.my.uq.edu.au/#/dashboard"
                    }) {
                        Text("Copy Link")
                        Image(systemName: "doc.on.doc")
                    }
                }
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
            
            if uploadError.isEmpty {
                ProgressView()
            } else {
                Text(uploadError).foregroundColor(.red).font(.title3)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
            }
            HStack {
                TextField("https://timetable.my.uq.edu.au/...", text: $timeTableLink)
                    .padding()
                    .onSubmit {
                        saveUser()
                    }
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .lineLimit(3)
                Button(action: {
                    saveUser()
                }) {
                    Text("Save")
                }
                .padding(.horizontal)
                .buttonStyle(.borderedProminent)
            }
            .background(.tertiary, in: RoundedRectangle(cornerRadius: 8))
            .padding()
        }
    }
    
    func saveUser() {
        uploadError.removeAll()
        if (!timeTableLink.isEmpty) {
            if let url = URL(string: timeTableLink) {
                timeTableLink = ""
                Task {
                    let result = await convertICSToEvents(from: url)
                    switch result {
                    case .failure(let error):
                        uploadError = error.localizedDescription
                    case .success(let (events, courses)):
                        if events.isEmpty {
                            uploadError = "This URL contains no content"
                        } else {
                            presentationMode.wrappedValue.dismiss()
                            viewModel.user?.events = events
                            viewModel.user?.courses = courses
                            viewModel.setUserData()
                            viewModel.getUserData()
                        }
                    }
                }
            }
        } else {
            uploadError = " "
        }
    }
}

struct UploadTimetableView_Previews: PreviewProvider {
    static var previews: some View {
        UploadTimetableView(uploadError: "")
            .environmentObject(AppViewModel())
    }
}
