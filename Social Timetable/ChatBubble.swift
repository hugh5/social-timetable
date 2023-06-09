//
//  ChatBubble.swift
//  Social Timetable
//
//  Created by Hugh Drummond on 27/1/2023.
//

import SwiftUI

struct ChatBubble: View {
    
    @State var name = ""
    @State var color: Int? = nil
    var message: Message
    var sent: Bool
    
    @EnvironmentObject var viewModel: AppViewModel
    @EnvironmentObject var messageManager: MessagesManager
        
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(color == nil ? .clear : Color(color!))
                    .frame(width: 5, height: 20)
                Text(name)
                    .font(.subheadline)
                Spacer()
                Text(getTime(date:message.timestamp))
                    .font(.subheadline)
            }
            Text(message.text == message.id ? " ⃠ This message was deleted" : message.text)
                .font(.callout)
                .italic(message.text == message.id)
        }
        .padding(8)
        .background(.tertiary)
        .containerShape(RoundedRectangle(cornerRadius: 10))
        .contextMenu {
            Button(action: {
                if message.text != message.id {
                    UIPasteboard.general.string = message.text
                }
            }) {
                Text("Copy")
                Image(systemName: "doc.on.doc")
            }
            Button(action: {
                
            }, label: {
                Text("Reply")
                Image(systemName: "arrowshape.turn.up.left")
            })
            if (sent && message.text != message.id) {
                Button(role: .destructive, action: {
                    messageManager.deleteMessage(message: message)
                }, label: {
                    Text("Delete")
                    Image(systemName: "trash")
                })
            }
        }
        .padding(sent ? .leading : .trailing, 50)
        .onAppear {
            getUser(email: message.userid)
        }
    }
    
    func getTime(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.doesRelativeDateFormatting = true
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    func getUser(email: String) {
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
}

struct ChatBubble_Previews: PreviewProvider {
    static var previews: some View {
        ChatBubble(message: Message.sampleData, sent: true)
            .environmentObject(AppViewModel.sampleData)
    }
}
