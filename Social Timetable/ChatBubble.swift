//
//  ChatBubble.swift
//  Social Timetable
//
//  Created by Hugh Drummond on 27/1/2023.
//

import SwiftUI

struct ChatBubble: View {
    
    var message: Message
    var sent: Bool
        
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(Color(message.usercolor))
                    .frame(width: 5, height: 20)
                Text(message.username)
                    .font(.subheadline)
                Spacer()
                Text(getTime(date:message.timestamp))
                    .font(.subheadline)
            }
            Text(message.text)
                .font(.callout)
        }
        .padding(8)
        .background(.tertiary)
        .containerShape(RoundedRectangle(cornerRadius: 10))
        .contextMenu {
            Button(action: {
                UIPasteboard.general.string = message.text
            }) {
                Text("Copy")
                Image(systemName: "doc.on.doc")
            }
            Button(action: {
                
            }, label: {
                Text("Reply")
                Image(systemName: "arrowshape.turn.up.left")
            })
            if (sent) {
                Button(role: .destructive, action: {
                    
                }, label: {
                    Text("Delete")
                    Image(systemName: "trash")
                })
            }
        }
        .padding(sent ? .leading : .trailing, 50)
    }
    
    func getTime(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.doesRelativeDateFormatting = true
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct ChatBubble_Previews: PreviewProvider {
    static var previews: some View {
        ChatBubble(message: Message.sampleData, sent: true)
    }
}
