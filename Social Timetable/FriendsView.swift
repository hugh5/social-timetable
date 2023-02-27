//
//  FriendsView.swift
//  Social Timetable 
//
//  Created by Hugh Drummond on 20/1/2023.
//

import SwiftUI

struct FriendsView: View {
    
    @Binding var user: User?
    @State var friends = [String:(tag: String, name: String, color: Int)]()
    @State var incomingFriends = [String:(tag: String, name: String, color: Int)]()
    @State var outgoingFriends = [String:(tag: String, name: String, color: Int)]()

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
                        HStack {
                            Image(systemName: "circle.fill")
                                .foregroundColor(Color(friends[key]!.color))
                            VStack(alignment: .leading) {
                                Text(friends[key]!.name)
                                Text(friends[key]!.tag)
                                    .foregroundColor(.gray)
                                    .font(.caption)
                            }
                            Spacer()
                            Button("Remove") {
                                withAnimation {
                                    friends.removeValue(forKey: key)
                                    return
                                }
                                viewModel.setFriendData(key: .friend, Array(friends.keys))
                            }
                            .font(.caption)
                            .buttonStyle(.bordered)
                        }
                    }
                }
                Section("Incoming Requests") {
                    ForEach(Array(incomingFriends.keys.sorted()), id:\.self) { key in
                        HStack {
                            Image(systemName: "circle.fill")
                                .foregroundColor(Color(incomingFriends[key]!.color))
                            VStack(alignment: .leading) {
                                Text(incomingFriends[key]!.name)
                                Text(incomingFriends[key]!.tag)
                                    .foregroundColor(.gray)
                                    .font(.caption)
                            }
                            Spacer()
                            Button("Decline") {
                                withAnimation {
                                    incomingFriends.removeValue(forKey: key)
                                    return
                                }
                                viewModel.setFriendData(key: .incomingFriend, Array(incomingFriends.keys))
                            }
                            .font(.caption)
                            .buttonStyle(.bordered)
                            Button("Accept") {
                                withAnimation {
                                    friends[key] = incomingFriends.removeValue(forKey: key)
                                    return
                                }
                                viewModel.setFriendData(key: .incomingFriend, Array(incomingFriends.keys))
                                viewModel.setFriendData(key: .friend, Array(friends.keys))
                            }
                            .font(.caption)
                            .buttonStyle(.borderedProminent)
                        }
                    }
                }
                Section("Outgoing Requests") {
                    ForEach(Array(outgoingFriends.keys.sorted()), id:\.self) { key in
                        HStack {
                            Image(systemName: "circle.fill")
                                .foregroundColor(Color(outgoingFriends[key]!.color))
                            VStack(alignment: .leading) {
                                Text(outgoingFriends[key]!.name)
                                Text(outgoingFriends[key]!.tag)
                                    .foregroundColor(.gray)
                                    .font(.caption)
                            }
                            Spacer()
                            Button("Rescind") {
                                withAnimation {
                                    outgoingFriends.removeValue(forKey: key)
                                    return
                                }
                                viewModel.setFriendData(key: .outgoingFriend, Array(outgoingFriends.keys))
                            }
                            .font(.caption)
                            .buttonStyle(.bordered)
                        }
                    }
                }
                Section("Find Friends") {
                    TextField("Name or Tag", text: $testName)
                        .autocorrectionDisabled()
                        .autocapitalization(.none)
                        .textFieldStyle(.roundedBorder)
                        .onSubmit {
                            findFriendError = nil
                            if !testName.isEmpty {
                                foundUsers.removeAll()
                                viewModel.getUserByName(name: testName) { result in
                                    switch result {
                                    case .failure(let error):
                                        print(error.localizedDescription)
                                    case .success(let data):
                                        foundUsers.append(contentsOf: data)
                                        foundUsers.removeAll(where: {
                                            $0.email == user?.email
                                        })
                                    }
                                }
                                viewModel.getUserByTag(tag: testName) { result in
                                    switch result {
                                    case .failure(let error):
                                        print(error.localizedDescription)
                                    case .success(let data):
                                        for account in data {
                                            if !foundUsers.contains(where: {$0 == account}) {
                                                foundUsers.append(account)
                                            }
                                        }
                                        foundUsers.removeAll(where: {
                                            $0.email == user?.email
                                        })
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
                            Image(systemName: "circle.fill")
                                .foregroundColor(Color(account.color))
                            VStack(alignment: .leading) {
                                Text(account.name)
                                Text(account.tag)
                                    .foregroundColor(.gray)
                                    .font(.caption)
                            }
                            Spacer()
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
                                        outgoingFriends[account.email] = (account.tag, account.name, account.color)
                                        viewModel.setFriendData(key: .outgoingFriend, Array(outgoingFriends.keys))
                                    }
                                }
                            }, label: {
                                Text("Add")
                            })
                            .font(.caption)
                            .buttonStyle(.borderedProminent)
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
                friends[data.email] = (data.tag, data.name, data.color)
            }
        }
        incomingFriends.removeAll()
        viewModel.getFriendData(key: .incomingFriend) { result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let data):
                print("getFriendData(in)")
                incomingFriends[data.email] = (data.tag, data.name, data.color)
            }
        }
        outgoingFriends.removeAll()
        viewModel.getFriendData(key: .outgoingFriend) { result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let data):
                print("getFriendData(out)")
                outgoingFriends[data.email] = (data.tag, data.name, data.color)
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
