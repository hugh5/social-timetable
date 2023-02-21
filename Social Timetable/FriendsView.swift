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
    
    @State var foundUsers = [(email: String, tag: String, name: String, color: Int)]()
    @State var testName = ""
    
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
                Section("Incoming Requests") {
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
                }
                Section("Find Friends") {
                    TextField("Name", text: $testName)
                        .onSubmit {
                            findFriendError = nil
                            if !testName.isEmpty {
                                viewModel.getUserByName(name: testName) { result in
                                    switch result {
                                    case .failure(let error):
                                        print(error.localizedDescription)
                                    case .success(let data):
                                        foundUsers = data
                                        foundUsers.removeAll(where: {
                                            $0.email == user?.email
                                        })
                                        if foundUsers.isEmpty {
                                            findFriendError = "No users found"
                                        }
                                    }
                                }
                            }
                        }
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
                    ForEach(foundUsers, id: \.email) { account in
                        HStack {
                            Label(title: {
                                Text(account.name)
                            }, icon: {
                                Image(systemName: "circle.fill")
                                    .foregroundColor(Color(account.color))
                            })
                            Spacer()
                            Text(account.tag)
                                .foregroundColor(.gray)
                                .font(.caption)
                        }
                        .swipeActions {
                            Button(action: {
                                if let user = user {
                                    if (user.email == account.email) {
                                        findFriendError = "Can't add yourself as a friend"
                                    } else if (user.friends.contains(account.email)) {
                                        findFriendError = "Already friends with this user"
                                    } else if (user.incomingFriendRequests.contains(account.email)) {
                                        findFriendError = "This user has sent you a request"
                                    } else if (user.outgoingFriendRequests.contains(account.email)) {
                                        findFriendError = "Request already sent"
                                    } else {
                                        findFriendError = nil
                                        outgoingFriends[account.email] = account.name
                                        viewModel.setFriendData(key: .outgoingFriend, Array(outgoingFriends.keys))
                                    }
                                }
                            }, label: {
                                Text("Add Friend")
                            })
                            .tint(.green)
                        }
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
