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
    @State var participants: [String] = []
    
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
                    value.scrollTo(messageManager.lastMessageId)
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
        .onAppear {
            getParticipants()
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    isPresenting.toggle()
                }, label: {
                    Label("Participants", systemImage: "person.3")
                })
                .buttonStyle(.bordered)
                .sheet(isPresented: $isPresenting, content: {
                    ParticipantListView(participants: $participants)
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
    
    func getParticipants() {
        messageManager.getParticipants(key: course) { result in
            participants = result.sorted()
        }
    }
}

struct ParticipantListView: View {
    @Binding var participants: [String]
    
    var body: some View {
        List {
            ForEach(participants, id:\.description) { account in
                PersonView(email: account)
            }
        }
    }
}

struct PersonView: View {
    
    var email: String
    @State var name: String = ""
    @State var color: Int? = nil
    
    @EnvironmentObject var viewModel: AppViewModel
    
    var body: some View {
        Label(title: {
            HStack {
                Text(name)
                Spacer()
                Text(email.prefix(while: {$0 != "@"}).description)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }, icon: {
            Image(systemName: "circle.fill")
                .foregroundColor(color == nil ? .clear : Color(color!))
        })
        .onAppear {
            getData(email: email)
        }
    }
    
    func getData(email: String) {
        viewModel.userExists(email: email) { result in
            switch result {
            case .success(let data):
                name = data.name
                color = data.color
            case .failure(_):
                name = email.prefix(while: {$0 != "@"}).description
            }
        }
        
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView(user: User.sampleData, course: "CSSE2310_S1")
            .environmentObject(MessagesManager.sampleData)
    }
}
