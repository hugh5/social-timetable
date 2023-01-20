//
//  FriendsView.swift
//  Social Timetable
//
//  Created by Hugh Drummond on 20/1/2023.
//

import SwiftUI

struct FriendsView: View {
    
    @Binding var user: User?
    @State var friends: [String] = []
    @State var studentID: String = ""
    
    var body: some View {
        VStack {
            List {
                ForEach($friends, id: \.self) { $friend in
                    Label(friend, systemImage: "person")
                        .swipeActions {
                            Button("Remove Friend") {
                                print(friend)
                            }
                            .tint(.red)
                        }
                }
                Button(action: {
                    if (studentID.count == 8) {
                        friends.append("s" +  studentID.prefix(7) + "@student.uq.edu.au")
                    }
                }, label: {
                    Label(title: {
                        HStack {
                            TextField("41234567", text: $studentID)
                                .foregroundColor(studentID.count == 8 ? .primary : .secondary)
                                .keyboardType(.numberPad)
                        }
                    },icon: {
                        Image(systemName: "plus")
                            .foregroundColor(studentID.count == 8 ? .accentColor : .secondary)
                    })
                })
            }
            .onAppear {
                if let user = user {
                    friends = user.friends
                }
            }
            .onDisappear {
                if let user = user {
                    user.friends = friends
                }
            }
        }
        .navigationTitle("Friends")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct FriendsView_Previews: PreviewProvider {
    static var previews: some View {
        FriendsView(user: .constant(User.sampleData))
    }
}
