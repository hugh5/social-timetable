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
    @State var findFriendError: String? = nil
    @EnvironmentObject var viewModel: AppViewModel
    
    var body: some View {
        VStack {
            List {
                ForEach($friends, id: \.self) { $friend in
                    Label(getDisplayName(email: friend), systemImage: "person")
                        .swipeActions {
                            Button("Remove Friend") {
                                if let idx = friends.firstIndex(of:friend) {
                                    friends.remove(at: idx)
                                }
                            }
                            .tint(.red)
                        }
                }
                Button(action: {
                    if (studentID.count == 8) {
                        if let user = user {
                            let email = "s" +  studentID.prefix(7) + "@student.uq.edu.au"
                            studentID = ""
                            if (user.email == email) {
                                findFriendError = "Can't add yourself as a friend"
                            } else if (user.friends.contains(email)) {
                                findFriendError = "Already friends with this user"
                            } else {
                                viewModel.userExists(email: email) { result in
                                    switch result {
                                    case .success(_):
                                        findFriendError = nil
                                        friends.append(email)
                                    case .failure(let error):
                                        findFriendError = "User Not Found\n" + error.localizedDescription
                                    }
                                }
                            }
                        }
                        
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
                if findFriendError != nil {
                    Label(title: {
                        Text(findFriendError!)
                    }, icon: {
                        Image(systemName: "exclamationmark.square")
                            .imageScale(.large)
                    })
                    .font(.caption)
                    .foregroundColor(.red)
                }
            }
            .onAppear {
                if let user = user {
                    friends = user.friends
                }
            }
            .onDisappear {
                if let user = user {
                    if (user.friends != friends) {
                        user.friends = friends
                        viewModel.setFriends()
                        viewModel.users.removeAll(where: {
                            if ($0.email == user.email) {
                                return false
                            } else {
                                return !friends.contains($0.email)
                            }
                        })
                        viewModel.getUsers()
                    }
                }
            }
        }
        .navigationTitle("Friends")
        .navigationBarTitleDisplayMode(.large)
    }
    
    func getDisplayName(email: String) -> String {
        if let idx = viewModel.users.firstIndex(where: {$0.email == email}) {
            return viewModel.users[idx].displayName
        } else {
            return email
        }
    }
}

struct FriendsView_Previews: PreviewProvider {
    static var previews: some View {
        FriendsView(user: .constant(User.sampleData), findFriendError: "Not Found")
            .environmentObject(AppViewModel.sampleData)
    }
}
