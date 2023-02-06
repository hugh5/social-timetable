//
//  FriendsView.swift
//  Social Timetable 
//
//  Created by Hugh Drummond on 20/1/2023.
//

import SwiftUI

struct FriendsView: View {
    
    @Binding var user: User?
    @State var friends = [String:String]()
    @State var incomingFriends = [String:String]()
    @State var outgoingFriends = [String:String]()

    @State var email: String = ""
    @State var findFriendError: String? = nil
    @State var loading = false
    
    @EnvironmentObject var viewModel: AppViewModel
    
    var body: some View {
        VStack {
            List {
                Section("Friends") {
                    ForEach(Array(friends.keys.sorted()), id:\.self) { key in
                        Label(title: {
                            Text(friends[key]!)
                        }, icon: {
                            Image(systemName: "person")
                        })
                            .swipeActions {
                                Button("Remove Friend") {
                                    withAnimation {
                                        friends.removeValue(forKey: key)
                                        return
                                    }
                                    viewModel.setFriendData(key: .friend, Array(friends.keys))
                                }
                                .tint(.red)
                            }
                    }
                }
                Section("Friend Requests") {
                    ForEach(Array(incomingFriends.keys.sorted()), id:\.self) { key in
                        Label(title: {
                            Text(incomingFriends[key]!)
                        }, icon: {
                            Image(systemName: "person")
                        })
                            .swipeActions {
                                Button("Decline") {
                                    withAnimation {
                                        incomingFriends.removeValue(forKey: key)
                                        return
                                    }
                                    viewModel.setFriendData(key: .incomingFriend, Array(incomingFriends.keys))
                                }
                                .tint(.red)
                                Button("Accept") {
                                    withAnimation {
                                        friends[key] = incomingFriends.removeValue(forKey: key)
                                        return
                                    }
                                    viewModel.setFriendData(key: .incomingFriend, Array(incomingFriends.keys))
                                    viewModel.setFriendData(key: .friend, Array(friends.keys))
                                }
                                .tint(.green)
                            }
                    }
                }
                Section("Outgoing Requests") {
                    ForEach(Array(outgoingFriends.keys.sorted()), id:\.self) { key in
                        Label(title: {
                            Text(outgoingFriends[key]!)
                        }, icon: {
                            Image(systemName: "person")
                        })
                            .swipeActions {
                                Button("Rescind") {
                                    withAnimation {
                                        outgoingFriends.removeValue(forKey: key)
                                        return
                                    }
                                    viewModel.setFriendData(key: .outgoingFriend, Array(outgoingFriends.keys))
                                }
                                .tint(.red)
                            }
                    }
                    Button(action: {
                        if (email.isEmpty) {
                            return
                        }
                        let temp = email
                        email = ""
                        if let user = user {
                            if (user.email == temp) {
                                findFriendError = "Can't add yourself as a friend"
                            } else if (user.friends.contains(temp)) {
                                findFriendError = "Already friends with this user"
                            } else {
                                viewModel.userExists(email: temp) { result in
                                    switch result {
                                    case .success(let data):
                                        findFriendError = nil
                                        outgoingFriends[data.0] = data.1
                                        viewModel.setFriendData(key: .outgoingFriend, Array(outgoingFriends.keys))
                                    case .failure(let error):
                                        findFriendError = "User Not Found\n" + error.localizedDescription
                                    }
                                }
                            }
                        }
                    }, label: {
                        Label(title: {
                            HStack {
                                TextField("friend@gmail.com", text: $email)
                                    .autocorrectionDisabled(true)
                                    .autocapitalization(.none)
                            }
                        },icon: {
                            Image(systemName: "plus")
                                .foregroundColor(email.isEmpty ? .gray : .accentColor)
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
            }
            .onAppear {
                fetchData()
            }
            .refreshable {
                fetchData()
            }
        }
        .navigationTitle("Friends")
        .navigationBarTitleDisplayMode(.large)
    }
    
    func fetchData() {
        loading = true
        viewModel.getUserData()
        friends.removeAll()
        viewModel.getFriendData(key: .friend) { result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let data):
                print(data)
                friends[data.0] = data.1
            }
        }
        incomingFriends.removeAll()
        viewModel.getFriendData(key: .incomingFriend) { result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let data):
                print("getFriendData(in)")
                incomingFriends[data.0] = data.1
            }
        }
        outgoingFriends.removeAll()
        viewModel.getFriendData(key: .outgoingFriend) { result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let data):
                print("getFriendData(out)")
                outgoingFriends[data.0] = data.1
            }
        }
        loading = false
    }
}

struct FriendsView_Previews: PreviewProvider {
    static var previews: some View {
        FriendsView(user: .constant(User.sampleData), findFriendError: "Not Found")
            .environmentObject(AppViewModel.sampleData)
    }
}
