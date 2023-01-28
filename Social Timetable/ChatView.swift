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
    
    @EnvironmentObject var messageManager: MessagesManager
    
    var body: some View {
        VStack {
            Button(action: {
                
            }, label: {
                Label("Participants", systemImage: "person.3")
            })
            .buttonStyle(.bordered)
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

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView(user: User.sampleData, course: "CSSE2310_S1")
            .environmentObject(MessagesManager.sampleData)
    }
}
