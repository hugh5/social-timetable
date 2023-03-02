//
//  ChatView.swift
//  Social Timetable
//
//  Created by Hugh Drummond on 27/1/2023.
//

import SwiftUI

struct ChatView: View {
    
    var user: User
    var course: String
    @State var messageToSend = ""
    @State var isPresenting = false
    
    @EnvironmentObject var messageManager: MessagesManager
    
    var body: some View {
        VStack {
            ScrollViewReader { value in
                ScrollView {
                    ForEach(messageManager.messages) { message in
                        ChatBubble(message: message, sent: user.email == message.userid)
                        .tag(message.id)
                    }
                    .onAppear {
                        value.scrollTo(messageManager.lastMessageId)
                    }
                    if (messageManager.messages.isEmpty) {
                        Text("Looks like it's empty in here\nSend a message!")
                            .padding(.vertical, 200)
                            .foregroundColor(.secondary)
                    }
                }
                .refreshable {
                    withAnimation {
                        messageManager.increaseLimit()
                        messageManager.getMessages()
                    }
//                    value.scrollTo(messageManager.lastMessageId)
                }
            }
            .padding(.horizontal)
            .scrollDismissesKeyboard(.immediately)
            HStack {
                TextField("Message", text: $messageToSend)
                    .onSubmit {
                        sendMessage()
                    }
                    .padding()
                Button(action: {sendMessage()}, label: {
                    Image(systemName: "paperplane")
                })
                .padding()
            }
            .background(.tertiary)
            .cornerRadius(16)
            .padding(.horizontal)
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    isPresenting.toggle()
                }, label: {
                    Label("Participants", systemImage: "person.3.sequence")
                })
                .sheet(isPresented: $isPresenting, content: {
                    ParticipantListView()
                        .presentationDetents([.medium])
                })
            }
        }
    }
    
    func sendMessage() {
        if messageToSend.isEmpty {
            return
        }
        withAnimation {
            messageManager.sendMessage(user: user, text: messageToSend)
            messageToSend = ""
        }
    }
}

struct ParticipantListView: View {
    @State var participants: [String] = []
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var messageManager: MessagesManager
    
    var body: some View {
        VStack {
            Button(action: {
                dismiss()
            }, label: {
                RoundedRectangle(cornerRadius: 5)
                    .frame(width: UIScreen.main.bounds.width / 8, height: 3)
                    .foregroundColor(.gray)
                    .padding()
            })
            List {
                ForEach(participants, id:\.description) { account in
                    PersonView(email: account)
                }
            }
        }
        .onAppear {
            getParticipants()
        }
    }
    
    func getParticipants() {
        messageManager.getParticipants() { result in
            participants = result.sorted()
        }
    }
}

struct PersonView: View {
    
    var email: String
    @State var name: String = ""
    @State var color: Int? = nil
    @State var label: any View = EmptyView()
    
    @State var friends: [String] = []
    @State var incoming: [String] = []
    @State var outgoing: [String] = []
    
    @EnvironmentObject var viewModel: AppViewModel
    
    var body: some View {
        Label(title: {
            HStack {
                Text(name)
                Spacer()
                Label(title: {
                    Text(name)
                }, icon: {
                    if viewModel.email == email {
                        Text("")
                    } else if (friends.contains(where: {$0 == email})) {
                        Image(systemName: "person")
                            .foregroundColor(.gray)
                    } else if (incoming.contains(where: {$0 == email})) {
                        Button(action: {
                            guard var incomingFriends = viewModel.user?.incomingFriendRequests, var userFriends = viewModel.user?.friends else {
                                return
                            }
                            if let idx = incomingFriends.firstIndex(of: email) {
                                userFriends.append(incomingFriends.remove(at: idx))
                                viewModel.setFriendData(key: .incomingFriend, incomingFriends)
                                viewModel.setFriendData(key: .friend, userFriends)
                                getFriends()
                            }
                        }, label: {
                            Text("Accept")
                        })
                        .buttonStyle(.plain)
                        .foregroundColor(.accentColor)
                    } else if (outgoing.contains(where: {$0 == email})) {
                        Text("Pending")
                            .foregroundColor(.gray)
                    } else {
                        Button(action: {
                            guard var outgoingFriends = viewModel.user?.outgoingFriendRequests else {
                                return
                            }
                            if !outgoingFriends.contains(where: {$0 == email}) {
                                outgoingFriends.append(email)
                                viewModel.setFriendData(key: .outgoingFriend, outgoingFriends)
                                getFriends()
                            }
                        }, label: {
                            Image(systemName: "plus")
                        })
                        .buttonStyle(.plain)
                        .foregroundColor(.accentColor)
                    }
                })
                .labelStyle(.iconOnly)
            }
        }, icon: {
            Image(systemName: "circle.fill")
                .foregroundColor(color == nil ? .clear : Color(color!))
        })
        .onAppear {
            getData(email: email)
            getFriends()
        }
    }
    
    func getLabel() {
        
    }
    
    func getData(email: String) {
        viewModel.getUserByEmail(email: email) { result in
            switch result {
            case .success(let data):
                name = data.name
                color = data.color
            case .failure(_):
                name = email.prefix(while: {$0 != "@"}).description
            }
        }
    }
    
    func getFriends() {
        withAnimation {
            friends = viewModel.user?.friends ?? []
            incoming = viewModel.user?.incomingFriendRequests ?? []
            outgoing = viewModel.user?.outgoingFriendRequests ?? []
        }
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ChatView(user: User.sampleData, course: "CSSE2310_S1")
                .environmentObject(MessagesManager.sampleData)
            ParticipantListView()
                .environmentObject(AppViewModel.sampleData)
                .environmentObject(MessagesManager.sampleData)
        }
    }
}
